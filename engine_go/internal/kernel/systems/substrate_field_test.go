package systems

import (
	"testing"

	"galatea/engine/internal/kernel/world"
)

// TestSubstrateFieldTendencyRotation verifies that a precomputed absolute-angle
// tendency is rotated into the correct relative slot according to the agent's
// heading. A substrate to the geographic NORTH of the standpoint must register
// as "forward" (DirN) when the agent faces north, and as "backward" (DirS) when
// the agent faces south.
func TestSubstrateFieldTendencyRotation(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	field := NewSubstrateField(cfg.NumPrototypes, cfg.NumBehaviors, cfg.GridWidth, cfg.GridHeight, cfg.NumSubstrates)

	const perceiver = 0
	sx, sy := 25, 25

	// Substrate cell is due north of the standpoint (smaller y). Absolute angle
	// of the vector standpoint->substrate is North.
	absAngle := AbsoluteAngleOf(float64(sx), float64(sy), float64(sx), float64(sy-3))
	if absAngle < 0 {
		t.Fatalf("unexpected coincident points")
	}
	field.AddTendency(perceiver, sx, sy, absAngle, 10)

	// Agent facing north (direction 2): the northern substrate is forward.
	idx := w.AddAgent()
	w.Agents.PosX[idx] = float64(sx)
	w.Agents.PosY[idx] = float64(sy)
	w.Agents.StageID[idx] = 0
	w.Agents.Direction[idx] = 2 // North

	ctx := setupPerceptionContext(w)
	ctx.SubstrateField = field

	resetVectors(w.Agents, idx, cfg.NumBehaviors)
	field.applyTo(ctx, idx, perceiver, sx, sy)

	tendBase := idx * 8
	if w.Agents.Tendencies[tendBase+DirN] != 10 {
		t.Fatalf("facing north: expected forward (DirN) tendency 10, got %d", w.Agents.Tendencies[tendBase+DirN])
	}
	if w.Agents.Tendencies[tendBase+DirS] != 0 {
		t.Fatalf("facing north: expected no backward tendency, got %d", w.Agents.Tendencies[tendBase+DirS])
	}

	// Now face south (direction 7): the same northern substrate is behind.
	w.Agents.Direction[idx] = 7 // South
	resetVectors(w.Agents, idx, cfg.NumBehaviors)
	field.applyTo(ctx, idx, perceiver, sx, sy)
	if w.Agents.Tendencies[tendBase+DirS] != 10 {
		t.Fatalf("facing south: expected backward (DirS) tendency 10, got %d", w.Agents.Tendencies[tendBase+DirS])
	}
	if w.Agents.Tendencies[tendBase+DirN] != 0 {
		t.Fatalf("facing south: expected no forward tendency, got %d", w.Agents.Tendencies[tendBase+DirN])
	}
}

// TestSubstrateFieldMarksPerceptionMemory verifies that applyTo marks the
// substrate perception memory for every substrate recorded in range from the
// standpoint cell.
func TestSubstrateFieldMarksPerceptionMemory(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	field := NewSubstrateField(cfg.NumPrototypes, cfg.NumBehaviors, cfg.GridWidth, cfg.GridHeight, cfg.NumSubstrates)
	const perceiver = 0
	sx, sy := 10, 10
	field.MarkPerceivedSubstrate(perceiver, sx, sy, 2) // substrate index 2 in range

	idx := w.AddAgent()
	w.Agents.PosX[idx] = float64(sx)
	w.Agents.PosY[idx] = float64(sy)
	w.Agents.StageID[idx] = 0
	w.Agents.Direction[idx] = 2

	ctx := setupPerceptionContext(w)
	ctx.SubstrateField = field
	resetPerceivedThisTick(ctx, cfg.MemPerceptionSlots())

	field.applyTo(ctx, idx, perceiver, sx, sy)

	slot := cfg.MemSlotSubstrate(2)
	if slot < 0 || slot >= len(ctx.perceivedThisTick) || !ctx.perceivedThisTick[slot] {
		t.Fatalf("expected substrate 2 marked perceived at slot %d", slot)
	}
}

// TestSubstrateFieldInteractionAveraged verifies that constant interaction
// contributions folded by the field feed the behavior-probability average
// (legacy PromediaProbaDecision): with two contributing cells of weight 6 and 0
// the average for that behavior is 3.
func TestSubstrateFieldInteractionAveraged(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	field := NewSubstrateField(cfg.NumPrototypes, cfg.NumBehaviors, cfg.GridWidth, cfg.GridHeight, cfg.NumSubstrates)
	const perceiver = 0
	sx, sy := 20, 20

	behavior := 2 // Feed_0
	vec := make([]int32, cfg.NumBehaviors)
	vec[behavior] = 6
	field.AddInteraction(perceiver, sx, sy, vec) // contributes 6
	zero := make([]int32, cfg.NumBehaviors)
	field.AddInteraction(perceiver, sx, sy, zero) // contributes 0 -> avg (6+0)/2

	idx := w.AddAgent()
	w.Agents.PosX[idx] = float64(sx)
	w.Agents.PosY[idx] = float64(sy)
	w.Agents.StageID[idx] = 0
	w.Agents.Direction[idx] = 2

	ctx := setupPerceptionContext(w)
	ctx.SubstrateField = field

	resetInteractionAccumulators(ctx, cfg.NumBehaviors)
	resetVectors(w.Agents, idx, cfg.NumBehaviors)
	resetPerceivedThisTick(ctx, cfg.MemPerceptionSlots())

	field.applyTo(ctx, idx, perceiver, sx, sy)
	applyInteractionAverages(ctx, idx)

	vdBase := idx * cfg.NumBehaviors
	if got := w.Agents.VDecision[vdBase+behavior]; got != 3 {
		t.Fatalf("expected averaged interaction 3, got %d", got)
	}
}

// TestPerceiveSubstrateDynamicSweep verifies the per-agent dynamic branch:
// a substrate flagged dynamic contributes an attractiveness tendency toward a
// perceived cell and its interaction weight, evaluated per-agent from the
// registry. A northern cell of the dynamic substrate must push the forward
// tendency and add the interaction weight.
func TestPerceiveSubstrateDynamicSweep(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Fill the map with substrate 0 everywhere, then a patch of substrate 1
	// (the dynamic one) just north of the agent.
	for y := 0; y < cfg.GridHeight; y++ {
		for x := 0; x < cfg.GridWidth; x++ {
			w.Substrates.Set(x, y, 0)
		}
	}
	ax, ay := 25, 25
	w.Substrates.Set(ax, ay-2, 1) // dynamic substrate to the north

	idx := w.AddAgent()
	w.Agents.PosX[idx] = float64(ax)
	w.Agents.PosY[idx] = float64(ay)
	w.Agents.StageID[idx] = 0
	w.Agents.Direction[idx] = 2 // facing North
	w.Agents.Speed[idx] = 1

	ctx := setupPerceptionContext(w)

	// Register the dynamic attractiveness formula and the interaction formula
	// for substrate 1, perceiver 0. "10" is technically constant, but the spec
	// forces the per-agent path (simulating a formula the classifier deemed
	// dynamic), which is what we want to exercise.
	if err := ctx.Formulas.Compile(SubstrateAttractKey(1, 0), "10"); err != nil {
		t.Fatalf("compile attract: %v", err)
	}
	feed := 2
	if err := ctx.Formulas.Compile(InteractionKeySubstrate(1, 0, feed), "8"); err != nil {
		t.Fatalf("compile interaction: %v", err)
	}

	// Spec: substrate 1 is dynamic (attr + interaction), radius 5 constant.
	spec := make(DynamicSubstrateSpec, cfg.NumPrototypes)
	for p := range spec {
		spec[p] = make([]*DynamicSubstrate, cfg.NumSubstrates)
	}
	spec[0][1] = &DynamicSubstrate{AttrDynamic: true, InterDynamic: true, Radius: 5}
	ctx.DynamicSubstrates = spec

	ctx.EnvBuilder.SetWorldVars(w)
	ctx.EnvBuilder.SetAgentVars(w, idx)
	resetInteractionAccumulators(ctx, cfg.NumBehaviors)
	resetVectors(w.Agents, idx, cfg.NumBehaviors)
	resetPerceivedThisTick(ctx, cfg.MemPerceptionSlots())

	perceiveSubstrate(ctx, idx)
	applyInteractionAverages(ctx, idx)

	tendBase := idx * 8
	if w.Agents.Tendencies[tendBase+DirN] <= 0 {
		t.Fatalf("expected positive forward tendency from northern dynamic substrate, got %d",
			w.Agents.Tendencies[tendBase+DirN])
	}
	vdBase := idx * cfg.NumBehaviors
	if w.Agents.VDecision[vdBase+feed] <= 0 {
		t.Fatalf("expected positive feed weight from dynamic interaction, got %d",
			w.Agents.VDecision[vdBase+feed])
	}

	// The dynamic substrate must be marked perceived.
	slot := cfg.MemSlotSubstrate(1)
	if !ctx.perceivedThisTick[slot] {
		t.Fatalf("expected dynamic substrate 1 marked perceived")
	}
}

// TestMixedSubstrateInteractionComposed verifies the unified criterion: a mixed
// substrate's interaction is the fraction-weighted combination of its simple
// components' formulas (legacy GetInteraccionSustratos), NOT a row read by the
// mixed index. Components 0 and 1 at 50/50 with weights 10 and 4 give
// 0.5*10 + 0.5*4 = 7 for the behavior, contributed as ONE element.
func TestMixedSubstrateInteractionComposed(t *testing.T) {
	cfg := testCfg()
	// Substrate index 2 is mixed: 50% substrate 0 + 50% substrate 1.
	cfg.SubstrateComposition = make([][]world.SubstrateComponent, cfg.NumSubstrates)
	cfg.SubstrateComposition[2] = []world.SubstrateComponent{
		{SimpleIdx: 0, Fraction: 0.5},
		{SimpleIdx: 1, Fraction: 0.5},
	}
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.StageID[idx] = 0
	w.Agents.Direction[idx] = 2

	ctx := setupPerceptionContext(w)
	behavior := 3
	// Component formulas: substrate 0 → 10, substrate 1 → 4, for perceiver 0.
	if err := ctx.Formulas.Compile(InteractionKeySubstrate(0, 0, behavior), "10"); err != nil {
		t.Fatalf("compile comp0: %v", err)
	}
	if err := ctx.Formulas.Compile(InteractionKeySubstrate(1, 0, behavior), "4"); err != nil {
		t.Fatalf("compile comp1: %v", err)
	}

	ctx.EnvBuilder.SetWorldVars(w)
	ctx.EnvBuilder.SetAgentVars(w, idx)
	resetInteractionAccumulators(ctx, cfg.NumBehaviors)
	resetVectors(w.Agents, idx, cfg.NumBehaviors)

	accumulateSubstrateInteractionAt(ctx, 2 /*mixed*/, 0 /*perceiver*/)
	applyInteractionAverages(ctx, idx)

	vdBase := idx * cfg.NumBehaviors
	if got := w.Agents.VDecision[vdBase+behavior]; got != 7 {
		t.Fatalf("expected composed mixed interaction 7 (0.5*10+0.5*4), got %d", got)
	}
	// It must count as exactly one perceived element (denominator 1).
	if ctx.interCount[behavior] != 1 {
		t.Fatalf("expected mixed cell to count as one element, got count %d", ctx.interCount[behavior])
	}
}

// TestSubstrateFieldHasField verifies HasSubstrateField gating.
func TestSubstrateFieldHasField(t *testing.T) {
	var nilField *SubstrateField
	if nilField.HasSubstrateField() {
		t.Fatalf("nil field must report no field")
	}
	cfg := testCfg()
	f := NewSubstrateField(cfg.NumPrototypes, cfg.NumBehaviors, cfg.GridWidth, cfg.GridHeight, cfg.NumSubstrates)
	if !f.HasSubstrateField() {
		t.Fatalf("allocated field must report a usable field")
	}
}
