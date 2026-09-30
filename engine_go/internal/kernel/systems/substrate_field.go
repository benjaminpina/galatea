package systems

import (
	"math"
	"math/bits"
)

// SubstrateField holds the precomputed substrate-perception result for the
// CONSTANT case of the enfoque B optimization.
//
// The legacy ProveePercepcionesSustratos sweeps, for every agent and every
// tick, the square of cells around the agent within each substrate's perception
// radius, accumulating an Attractiveness/Distance tendency into the octant of
// the perceived cell and one interaction contribution per cell. That sweep is
// O(agents × radius² × ticks) and is one of the two hot spots the new engine
// exists to eliminate.
//
// When a substrate's attractiveness/radius formulas are CONSTANT (do not depend
// on agent/world state and are not stochastic), the entire sweep result for a
// given perceiver depends only on WHERE the agent stands, not on when. So we
// compute it ONCE at load time, per (perceiver, cell), and the hot path just
// reads it back and rotates the tendencies by the agent's heading.
//
// Tendencies are stored in ABSOLUTE angle buckets (0..7 clockwise from North,
// matching dirAngleTable), because they do not depend on heading. At runtime
// the agent's facing rotates each absolute bucket into the relative tendency
// slot (DirNW..DirSE), exactly as accumulateTendency would have via
// relativeDirection.
//
// The field carries the CONSTANT-case tendency (attractiveness→direction) and,
// when the substrate's interaction formulas are also constant, the interaction
// contribution to the behavior-probability average (legacy PromediaProbaDecision:
// one contribution per substrate cell in range). Substrates whose attractiveness,
// radius, or interaction formulas are DYNAMIC are excluded from the field and
// handled by the per-agent branch in perceiveSubstrate.
type SubstrateField struct {
	numPerceivers int
	numBehaviors  int
	width         int
	height        int

	// tendAbs holds, per (perceiver, cell), the 8 absolute-angle tendency
	// buckets. Layout: [(perceiver*cells + cellY*width + cellX)*8 + absAngle].
	tendAbs []int32

	// interSum holds, per (perceiver, cell), the summed interaction weight per
	// behavior over all constant substrate cells in range. Layout:
	// [(perceiver*cells + cell)*numBehaviors + behavior].
	interSum []int32

	// interCount holds, per (perceiver, cell), how many constant substrate cells
	// in range contributed an interaction (the PromediaProbaDecision denominator
	// for the field's share). Layout: [perceiver*cells + cell].
	interCount []int32

	// perceivedMask holds, per (perceiver, cell), a bitmask of substrate indices
	// perceived within range from that cell (bit i set → substrate index i was
	// in radius). Layout: [(perceiver*cells + cell) * maskWords + word].
	// This lets the hot path mark substrate perception memory without a re-scan.
	perceivedMask []uint64
	maskWords     int
}

// HasSubstrateField reports whether a usable constant field was built.
func (f *SubstrateField) HasSubstrateField() bool {
	return f != nil && len(f.tendAbs) > 0
}

// NewSubstrateField allocates a zeroed field.
func NewSubstrateField(numPerceivers, numBehaviors, width, height, numSubstrates int) *SubstrateField {
	cells := width * height
	maskWords := (numSubstrates + 63) / 64
	if maskWords < 1 {
		maskWords = 1
	}
	return &SubstrateField{
		numPerceivers: numPerceivers,
		numBehaviors:  numBehaviors,
		width:         width,
		height:        height,
		tendAbs:       make([]int32, numPerceivers*cells*8),
		interSum:      make([]int32, numPerceivers*cells*numBehaviors),
		interCount:    make([]int32, numPerceivers*cells),
		perceivedMask: make([]uint64, numPerceivers*cells*maskWords),
		maskWords:     maskWords,
	}
}

// AddInteraction adds one substrate cell's per-behavior interaction contribution
// at the standpoint (perceiver, x, y) and bumps the contributing-cell count once
// (one PromediaProbaDecision contribution per perceived substrate cell). Values
// beyond numBehaviors are ignored.
func (f *SubstrateField) AddInteraction(perceiver, x, y int, perBehavior []int32) {
	base := f.cellBase(perceiver, x, y)
	if base < 0 {
		return
	}
	off := base * f.numBehaviors
	for b := 0; b < f.numBehaviors && b < len(perBehavior); b++ {
		f.interSum[off+b] += perBehavior[b]
	}
	f.interCount[base]++
}

// MarkPerceivedSubstrate records that, from (perceiver, x, y), substrate index
// s was within perception range.
func (f *SubstrateField) MarkPerceivedSubstrate(perceiver, x, y, s int) {
	base := f.cellBase(perceiver, x, y)
	if base < 0 || s < 0 {
		return
	}
	word := s / 64
	if word >= f.maskWords {
		return
	}
	f.perceivedMask[base*f.maskWords+word] |= 1 << uint(s%64)
}

// cellBase returns the flat (perceiver, cell) base index, or -1 if out of range.
func (f *SubstrateField) cellBase(perceiver, x, y int) int {
	if perceiver < 0 || perceiver >= f.numPerceivers {
		return -1
	}
	if x < 0 || x >= f.width || y < 0 || y >= f.height {
		return -1
	}
	return perceiver*(f.width*f.height) + y*f.width + x
}

// AddTendency accumulates an absolute-angle tendency at (perceiver, x, y).
func (f *SubstrateField) AddTendency(perceiver, x, y, absAngle int, weight int32) {
	base := f.cellBase(perceiver, x, y)
	if base < 0 || absAngle < 0 || absAngle >= 8 {
		return
	}
	f.tendAbs[base*8+absAngle] += weight
}

// applyTo folds the precomputed field for the agent standing at (x, y) into the
// perception accumulators: heading-rotated tendencies, constant interaction
// contributions, and substrate perception memory. It mirrors a per-agent
// substrate sweep (for the constant substrates) at O(8 + numBehaviors) cost.
func (f *SubstrateField) applyTo(ctx *PerceptionContext, idx, perceiver, x, y int) {
	base := f.cellBase(perceiver, x, y)
	if base < 0 {
		return
	}
	a := ctx.World.Agents
	cfg := ctx.World.Config
	tendBase := idx * 8
	aDir := a.Direction[idx]

	// Rotate absolute-angle tendencies into the agent's relative slots.
	angAgent := dirAngleTable[aDir]
	tOff := base * 8
	for absAngle := 0; absAngle < 8; absAngle++ {
		w := f.tendAbs[tOff+absAngle]
		if w == 0 {
			continue
		}
		relAngle := (absAngle - angAgent + 8) % 8
		slot := angleRelTable[relAngle]
		a.Tendencies[tendBase+slot] += w
	}

	// Fold the constant interaction contributions into the running behavior
	// average. The field stored the SUM per behavior and the count of
	// contributing substrate cells; adding both to the tick accumulators lets
	// applyInteractionAverages divide by the total (legacy PromediaProbaDecision).
	cnt := f.interCount[base]
	if cnt != 0 {
		iOff := base * f.numBehaviors
		for b := 0; b < cfg.NumBehaviors && b < f.numBehaviors; b++ {
			ctx.interSum[b] += f.interSum[iOff+b]
			ctx.interCount[b] += cnt
		}
	}

	// Mark substrate perception memory for every substrate that was in range
	// from this cell (decoded from the precomputed bitmask, no re-scan).
	mOff := base * f.maskWords
	for word := 0; word < f.maskWords; word++ {
		w := f.perceivedMask[mOff+word]
		for w != 0 {
			b := bits.TrailingZeros64(w)
			s := word*64 + b
			markPerceived(ctx, cfg.MemSlotSubstrate(s))
			w &= w - 1 // clear lowest set bit
		}
	}
}

// AbsoluteAngleOf returns the absolute clockwise-from-North angle bucket (0..7)
// of the vector from (ax,ay) to (tx,ty), or -1 if the points coincide. It is
// the heading-independent counterpart used when precomputing the field.
func AbsoluteAngleOf(ax, ay, tx, ty float64) int {
	dx := tx - ax
	dy := ty - ay
	if dx == 0 && dy == 0 {
		return -1
	}
	absDir := computeAbsoluteDirection(dx, dy)
	return dirAngleTable[absDir]
}

// SubstrateEuclid is the distance helper used by the precompute (kept separate
// from the hot-path distance for clarity).
func SubstrateEuclid(x1, y1, x2, y2 int) float64 {
	dx := float64(x2 - x1)
	dy := float64(y2 - y1)
	return math.Sqrt(dx*dx + dy*dy)
}
