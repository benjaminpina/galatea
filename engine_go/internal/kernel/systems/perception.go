// Package systems implements the simulation systems that operate on the World
// during the Hot Path tick loop. Each system is a pure function that reads
// and writes World state via index-based SoA access.
package systems

import (
	"math"

	"galatea/engine/internal/kernel/formulas"
	"galatea/engine/internal/kernel/spatial"
	"galatea/engine/internal/kernel/util"
	"galatea/engine/internal/kernel/world"
)

// Direction constants for tendency array indexing (0-based).
const (
	DirNW = 0
	DirN  = 1
	DirNE = 2
	DirW  = 3
	DirE  = 4
	DirSW = 5
	DirS  = 6
	DirSE = 7
)

// Behavioral tuning constants.
const (
	contiguousDistance   = 1.5 // Max distance to consider elements "adjacent".
	defaultAgentAttr     = 5   // Default base attractiveness for agents.
	fightBoostDisplay    = 5   // VDecision boost for fight when contender detected.
	fightBoostEscalate   = 3   // VDecision boost for escalate when contender detected.
	courtBoostDisplay    = 5   // VDecision boost for courtship when mate detected.
	courtBoostEscalate   = 3   // VDecision boost for courtship escalate.
	criticalReserveLevel = 5   // Reserve level below which agent is in critical state.
	behaviorOffsetFeed   = 2   // First feed behavior index (0=move, 1=rest, 2+=feed).
	contiguousBoost      = 1   // Extra VDecision weight for contiguous resources.
)

// Lookup tables for direction conversions (replace switch statements).
// dirAngleTable maps direction code (1-8) to clockwise angular index (0-7 from N).
var dirAngleTable = [9]int{0, 7, 0, 1, 6, 2, 5, 4, 3} // index 0 unused

// angleDirTable maps clockwise angle (0-7) to direction code (1-8).
var angleDirTable = [8]uint8{2, 3, 5, 8, 7, 6, 4, 1}

// angleRelTable maps relative clockwise angle (0-7) to tendency array index.
var angleRelTable = [8]int{DirN, DirNE, DirE, DirSE, DirS, DirSW, DirW, DirNW}

// dirDeltaX and dirDeltaY map direction code (1-8) to movement deltas.
var dirDeltaX = [9]int{0, -1, 0, 1, -1, 1, -1, 0, 1} // index 0 unused
var dirDeltaY = [9]int{0, -1, -1, -1, 0, 0, 1, 1, 1} // index 0 unused

// PerceptionContext holds pre-computed data needed during perception.
// It is created once per tick and reused across all agents.
type PerceptionContext struct {
	World        *world.World
	AgentGrid    *spatial.Grid
	ResourceGrid *spatial.Grid
	Formulas     *formulas.Registry
	Eval         *formulas.Evaluator
	EnvBuilder   *formulas.EnvBuilder

	// Precomputed attractiveness radii per (resource_type, perceiver_prototype).
	// Index: [resourceType * numPerceivers + perceiverIdx]
	ResourceRadii []float64
	ResourceAttr  []int32

	// Agent attractiveness radii: [observed * numPerceivers + perceiverIdx]
	AgentRadii []float64
}

// Perceive runs the full perception pipeline for agent at idx.
// It resets tendencies and VDecision, queries the spatial grids,
// accumulates attractiveness-weighted tendencies and behavior probabilities,
// then applies filters and boundary avoidance.
func Perceive(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config

	resetVectors(a, idx, cfg.NumBehaviors)

	ctx.EnvBuilder.SetWorldVars(w)
	ctx.EnvBuilder.SetAgentVars(w, idx)

	perceiveResources(ctx, idx)
	perceiveAgents(ctx, idx)
	applyBaseTendencies(ctx, idx)
	applyFilters(ctx, idx)
	applyBoundaryAvoidance(ctx, idx)
	ensureNonZeroDecision(ctx, idx)
}

// resetVectors zeroes out tendencies and VDecision for an agent.
func resetVectors(a *world.AgentArrays, idx int, numBehaviors int) {
	tendBase := idx * 8
	for d := 0; d < 8; d++ {
		a.Tendencies[tendBase+d] = 0
	}
	vdBase := idx * numBehaviors
	for b := 0; b < numBehaviors; b++ {
		a.VDecision[vdBase+b] = 0
	}
}

// perceiveResources queries the resource grid and accumulates tendencies + VDecision.
func perceiveResources(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	r := w.Resources
	cfg := w.Config

	ax := a.PosX[idx]
	ay := a.PosY[idx]
	aDir := a.Direction[idx]
	perceiverIdx := getPerceiverIndex(a, idx, cfg)

	maxRadius := maxFloat64(ctx.ResourceRadii)
	if maxRadius <= 0 {
		return
	}

	candidates := ctx.ResourceGrid.QueryRadiusExact(ax, ay, maxRadius, r.PosX, r.PosY)
	tendBase := idx * 8
	vdBase := idx * cfg.NumBehaviors

	for _, rIdx := range candidates {
		rx := r.PosX[rIdx]
		ry := r.PosY[rIdx]
		dist := distance(ax, ay, rx, ry)
		resourceType := int(r.TypeID[rIdx])

		radiusKey := resourceType*cfg.NumPrototypes + perceiverIdx
		if radiusKey >= len(ctx.ResourceRadii) || dist > ctx.ResourceRadii[radiusKey] {
			continue
		}

		attractiveness := getResourceAttractiveness(ctx, radiusKey, dist)
		accumulateTendency(a, tendBase, aDir, ax, ay, rx, ry, attractiveness)

		feedBehavior := behaviorOffsetFeed + resourceType
		if feedBehavior < cfg.NumBehaviors {
			a.VDecision[vdBase+feedBehavior] += clampPositive(attractiveness)
			if dist <= contiguousDistance {
				a.VDecision[vdBase+feedBehavior] += contiguousBoost
			}
		}
	}
}

// perceiveAgents queries the agent grid and accumulates tendencies + VDecision.
func perceiveAgents(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config

	ax := a.PosX[idx]
	ay := a.PosY[idx]
	aDir := a.Direction[idx]
	perceiverIdx := getPerceiverIndex(a, idx, cfg)

	maxRadius := maxFloat64(ctx.AgentRadii)
	if maxRadius <= 0 {
		return
	}

	candidates := ctx.AgentGrid.QueryRadiusExact(ax, ay, maxRadius, a.PosX, a.PosY)
	tendBase := idx * 8

	hasContender := false
	hasMate := false

	for _, cIdx := range candidates {
		if cIdx == int32(idx) || int(cIdx) >= a.Count {
			continue
		}

		cx := a.PosX[cIdx]
		cy := a.PosY[cIdx]
		dist := distance(ax, ay, cx, cy)

		observedIdx := getPerceiverIndex(a, int(cIdx), cfg)
		radiusKey := observedIdx*cfg.NumPrototypes + perceiverIdx
		if radiusKey >= len(ctx.AgentRadii) || dist > ctx.AgentRadii[radiusKey] {
			continue
		}

		attractiveness := computeAgentAttractiveness(dist)
		accumulateTendency(a, tendBase, aDir, ax, ay, cx, cy, attractiveness)

		if dist <= contiguousDistance {
			c, m := classifyNeighbor(a.Sex[idx], a.Sex[cIdx], a.Situation[cIdx])
			hasContender = hasContender || c
			hasMate = hasMate || m
		}
	}

	applyAgentDetectionBoosts(a, idx, cfg, hasContender, hasMate)
}

// classifyNeighbor determines if a contiguous agent is a contender, a mate, or neither.
func classifyNeighbor(agentSex, otherSex, otherSituation uint8) (contender, mate bool) {
	if otherSituation != world.SituationRegular && otherSituation != world.SituationImmature {
		return false, false
	}
	contender = agentSex == otherSex || agentSex == world.SexUndefined || otherSex == world.SexUndefined
	mate = (agentSex == world.SexMale && otherSex == world.SexFemale) ||
		(agentSex == world.SexFemale && otherSex == world.SexMale)
	return contender, mate
}

// applyAgentDetectionBoosts adds fight/court weights when contenders/mates are found.
func applyAgentDetectionBoosts(a *world.AgentArrays, idx int, cfg world.Config, hasContender, hasMate bool) {
	vdBase := idx * cfg.NumBehaviors
	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	fightEscalateIdx := fightDisplayIdx + 1
	courtDisplayIdx := fightDisplayIdx + 2
	courtEscalateIdx := fightDisplayIdx + 3

	if hasContender {
		if fightDisplayIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+fightDisplayIdx] += fightBoostDisplay
		}
		if fightEscalateIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+fightEscalateIdx] += fightBoostEscalate
		}
	}
	if hasMate {
		if courtDisplayIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+courtDisplayIdx] += courtBoostDisplay
		}
		if courtEscalateIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+courtEscalateIdx] += courtBoostEscalate
		}
	}
}

// applyBaseTendencies evaluates the base tendency formulas for the agent's prototype/stage.
func applyBaseTendencies(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config
	tendBase := idx * 8
	vdBase := idx * cfg.NumBehaviors

	perceiverIdx := getPerceiverIndex(a, idx, cfg)
	prefix := "tendency." + util.Itoa(perceiverIdx) + "."

	for d := 0; d < 8; d++ {
		p := ctx.Formulas.Get(prefix + util.Itoa(d+1))
		if p != nil {
			val, err := ctx.Eval.RunProgramInt(p)
			if err == nil {
				a.Tendencies[tendBase+d] += int32(val)
			}
		}
	}

	vdPrefix := "vdecision." + util.Itoa(perceiverIdx) + "."
	for b := 0; b < cfg.NumBehaviors; b++ {
		p := ctx.Formulas.Get(vdPrefix + util.Itoa(b+1))
		if p != nil {
			val, err := ctx.Eval.RunProgramInt(p)
			if err == nil {
				a.VDecision[vdBase+b] += int32(val)
			}
		}
	}
}

// applyFilters zeroes out behaviors that are unavailable given current state.
func applyFilters(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config
	vdBase := idx * cfg.NumBehaviors

	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	fightEscalateIdx := fightDisplayIdx + 1
	courtDisplayIdx := fightDisplayIdx + 2
	courtEscalateIdx := fightDisplayIdx + 3
	ovipositIdx := fightDisplayIdx + 4

	// Disable escalate if no display weight exists.
	if a.VDecision[vdBase+fightDisplayIdx] == 0 {
		a.VDecision[vdBase+fightEscalateIdx] = 0
	}
	if a.VDecision[vdBase+courtDisplayIdx] == 0 {
		a.VDecision[vdBase+courtEscalateIdx] = 0
	}

	// Disable oviposition for males or agents with no fertilized eggs.
	if a.Sex[idx] == world.SexMale || a.FertilizedCount[idx] == 0 {
		if ovipositIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+ovipositIdx] = 0
		}
	}

	// Disable fight and courtship when reserves are critical.
	if isReserveCritical(a, idx, cfg) {
		zeroIfValid(a.VDecision, vdBase+fightDisplayIdx, cfg.NumBehaviors)
		zeroIfValid(a.VDecision, vdBase+fightEscalateIdx, cfg.NumBehaviors)
		zeroIfValid(a.VDecision, vdBase+courtDisplayIdx, cfg.NumBehaviors)
		zeroIfValid(a.VDecision, vdBase+courtEscalateIdx, cfg.NumBehaviors)
	}

	// Clamp negative values to 0.
	for b := 0; b < cfg.NumBehaviors; b++ {
		if a.VDecision[vdBase+b] < 0 {
			a.VDecision[vdBase+b] = 0
		}
	}
}

// applyBoundaryAvoidance zeroes tendencies that would move the agent outside the grid.
func applyBoundaryAvoidance(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config
	tendBase := idx * 8

	x := a.PosX[idx]
	y := a.PosY[idx]
	speed := float64(a.Speed[idx])
	dir := a.Direction[idx]

	maxX := float64(cfg.GridWidth) - 1
	maxY := float64(cfg.GridHeight) - 1

	atBoundary := x <= speed || x >= maxX-speed || y <= speed || y >= maxY-speed
	if !atBoundary {
		return
	}

	// Add 1 to all tendencies to eliminate zeros before blocking (legacy behavior).
	for d := 0; d < 8; d++ {
		a.Tendencies[tendBase+d] += 1
	}

	// Block directions that would exit bounds.
	for relDir := 0; relDir < 8; relDir++ {
		absDir := absoluteDirection(dir, uint8(relDir+1))
		dx := dirDeltaX[absDir]
		dy := dirDeltaY[absDir]

		newX := x + float64(dx)*speed
		newY := y + float64(dy)*speed

		if newX < 0 || newX > maxX || newY < 0 || newY > maxY {
			a.Tendencies[tendBase+relDir] = 0
		}
	}
}

// ensureNonZeroDecision forces at least movement if all VDecision weights are zero.
func ensureNonZeroDecision(ctx *PerceptionContext, idx int) {
	a := ctx.World.Agents
	cfg := ctx.World.Config
	vdBase := idx * cfg.NumBehaviors

	for b := 0; b < cfg.NumBehaviors; b++ {
		if a.VDecision[vdBase+b] > 0 {
			return
		}
	}
	a.VDecision[vdBase] = 1 // Force movement.
}

// --- Utility helpers ---

// getPerceiverIndex returns the unified index of an agent in the prototype listing.
func getPerceiverIndex(a *world.AgentArrays, idx int, cfg world.Config) int {
	if stageID := a.StageID[idx]; stageID >= 0 {
		return int(stageID)
	}
	protoID := int(a.PrototypeID[idx])
	if a.Sex[idx] == world.SexMale {
		return cfg.NumStages + protoID
	}
	return cfg.NumStages + cfg.NumPrototypesM + protoID
}

// relativeDirection computes which of the 8 directional buckets a target point
// falls into, relative to the agent's facing direction. Returns -1 if overlapping.
func relativeDirection(agentDir uint8, ax, ay, tx, ty float64) int {
	dx := tx - ax
	dy := ty - ay
	if dx == 0 && dy == 0 {
		return -1
	}
	absDir := computeAbsoluteDirection(dx, dy)
	return absoluteToRelative(agentDir, absDir)
}

// computeAbsoluteDirection returns the cardinal direction (1-8) from deltas.
func computeAbsoluteDirection(dx, dy float64) uint8 {
	adx := math.Abs(dx)
	ady := math.Abs(dy)

	if ady >= 2*adx+1 {
		if dy < 0 {
			return 2 // N
		}
		return 7 // S
	}
	if adx >= 2*ady+1 {
		if dx < 0 {
			return 4 // W
		}
		return 5 // E
	}
	if dx < 0 && dy < 0 {
		return 1 // NW
	}
	if dx > 0 && dy < 0 {
		return 3 // NE
	}
	if dx < 0 && dy > 0 {
		return 6 // SW
	}
	return 8 // SE
}

// absoluteToRelative converts an absolute direction to a relative direction index (0-7).
func absoluteToRelative(agentDir, absDir uint8) int {
	angAgent := dirAngleTable[agentDir]
	angTarget := dirAngleTable[absDir]
	relAngle := (angTarget - angAgent + 8) % 8
	return angleRelTable[relAngle]
}

// absoluteDirection converts a facing + relative direction to an absolute direction code.
func absoluteDirection(agentDir uint8, relDir uint8) uint8 {
	angAgent := dirAngleTable[agentDir]
	relAngle := dirAngleTable[relDir]
	absAngle := (angAgent + relAngle) % 8
	return angleDirTable[absAngle]
}

// --- Small helpers to reduce cognitive complexity ---

func distance(x1, y1, x2, y2 float64) float64 {
	dx := x2 - x1
	dy := y2 - y1
	return math.Sqrt(dx*dx + dy*dy)
}

func maxFloat64(s []float64) float64 {
	m := 0.0
	for _, v := range s {
		if v > m {
			m = v
		}
	}
	return m
}

func getResourceAttractiveness(ctx *PerceptionContext, radiusKey int, dist float64) int32 {
	if radiusKey >= len(ctx.ResourceAttr) {
		return 0
	}
	attr := ctx.ResourceAttr[radiusKey]
	if dist > 0 && attr != 0 {
		attr /= int32(math.Max(1, dist))
	}
	return attr
}

func computeAgentAttractiveness(dist float64) int32 {
	attr := int32(defaultAgentAttr)
	if dist > 0 {
		attr /= int32(math.Max(1, dist))
	}
	return attr
}

func accumulateTendency(a *world.AgentArrays, tendBase int, aDir uint8, ax, ay, tx, ty float64, attr int32) {
	dir := relativeDirection(aDir, ax, ay, tx, ty)
	if dir >= 0 && dir < 8 {
		a.Tendencies[tendBase+dir] += attr
	}
}

func clampPositive(v int32) int32 {
	if v < 0 {
		return 0
	}
	return v
}

func isReserveCritical(a *world.AgentArrays, idx int, cfg world.Config) bool {
	for n := 0; n < cfg.NumNutrients; n++ {
		if a.Reserves[idx*cfg.NumNutrients+n] <= criticalReserveLevel {
			return true
		}
	}
	return false
}

func zeroIfValid(slice []int32, idx int, max int) {
	if idx < max && idx < len(slice) {
		slice[idx] = 0
	}
}
