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
