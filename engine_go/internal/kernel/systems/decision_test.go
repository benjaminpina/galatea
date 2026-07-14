package systems

import (
	"math"
	"testing"

	"galatea/engine/internal/kernel/spatial"
	"galatea/engine/internal/kernel/world"
)

func TestRouletteBasicDistribution(t *testing.T) {
	weights := []int32{50, 30, 20}
	counts := [3]int{}
	const iterations = 100000

	for i := 0; i < iterations; i++ {
		idx := Roulette(weights)
		counts[idx]++
	}

	// Expected proportions: 50%, 30%, 20% (±2% tolerance).
	tolerance := 0.02 * float64(iterations)
	if math.Abs(float64(counts[0])-50000) > tolerance {
		t.Errorf("weight 50: expected ~50000, got %d", counts[0])
	}
	if math.Abs(float64(counts[1])-30000) > tolerance {
		t.Errorf("weight 30: expected ~30000, got %d", counts[1])
	}
	if math.Abs(float64(counts[2])-20000) > tolerance {
		t.Errorf("weight 20: expected ~20000, got %d", counts[2])
	}
}

func TestRouletteAllZero(t *testing.T) {
	weights := []int32{0, 0, 0, 0}
	counts := [4]int{}
	const iterations = 40000

	for i := 0; i < iterations; i++ {
		idx := Roulette(weights)
		counts[idx]++
	}

	// Uniform: each should get ~25%.
	for i, c := range counts {
		ratio := float64(c) / float64(iterations)
		if ratio < 0.15 || ratio > 0.35 {
			t.Errorf("index %d: expected ~25%%, got %.1f%%", i, ratio*100)
		}
	}
}

func TestRouletteNegativesClamped(t *testing.T) {
	weights := []int32{-5, 10, -3}
	// After clamping: {0, 10, 0} → always selects index 1.
	for i := 0; i < 100; i++ {
		idx := Roulette(weights)
		if idx != 1 {
			t.Fatalf("expected index 1 (only positive weight), got %d", idx)
		}
	}
}

func TestRouletteSingleWeight(t *testing.T) {
	weights := []int32{0, 0, 100, 0}
	for i := 0; i < 50; i++ {
		idx := Roulette(weights)
		if idx != 2 {
			t.Fatalf("expected index 2 (only nonzero), got %d", idx)
		}
	}
}

func TestDecideRegular(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Situation[idx] = world.SituationRegular
	w.Agents.State[idx] = world.StateUndecided

	// Set VDecision: only rest (index 1) has weight.
	vdBase := idx * cfg.NumBehaviors
	w.Agents.VDecision[vdBase+1] = 100

	Decide(w, idx)

	if w.Agents.State[idx] != world.StateDecided {
		t.Fatal("expected state = Decided")
	}
	if w.Agents.Decision[idx] != 1 {
		t.Fatalf("expected decision=1 (rest), got %d", w.Agents.Decision[idx])
	}
}

func TestDecideAlreadyDecided(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.State[idx] = world.StateDecided
	w.Agents.Decision[idx] = 5

	Decide(w, idx)

	// Should not change.
	if w.Agents.Decision[idx] != 5 {
		t.Fatalf("expected decision unchanged at 5, got %d", w.Agents.Decision[idx])
	}
}

func TestDecideCombat(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Situation[idx] = world.SituationCombat
	w.Agents.State[idx] = world.StateUndecided

	// Set fight display weight high.
	vdBase := idx * cfg.NumBehaviors
	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	w.Agents.VDecision[vdBase+fightDisplayIdx] = 100

	Decide(w, idx)

	if w.Agents.State[idx] != world.StateDecided {
		t.Fatal("expected state = Decided")
	}
	// Decision should be one of the combat behaviors.
	decision := int(w.Agents.Decision[idx])
	if decision < fightDisplayIdx {
		t.Fatalf("expected combat decision >= %d, got %d", fightDisplayIdx, decision)
	}
}

func TestDecideCourtship(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Situation[idx] = world.SituationCourtship
	w.Agents.State[idx] = world.StateUndecided

	// Set courtship display weight high.
	vdBase := idx * cfg.NumBehaviors
	courtDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 2
	w.Agents.VDecision[vdBase+courtDisplayIdx] = 100

	Decide(w, idx)

	if w.Agents.State[idx] != world.StateDecided {
		t.Fatal("expected state = Decided")
	}
	decision := int(w.Agents.Decision[idx])
	if decision < courtDisplayIdx {
		t.Fatalf("expected courtship decision >= %d, got %d", courtDisplayIdx, decision)
	}
}

func TestEstablishInteractionFeeding(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Agent at (10, 10) decides to feed from resource type 0 (behavior index 2).
	idx := w.AddAgent()
	w.Agents.PosX[idx] = 10
	w.Agents.PosY[idx] = 10
	w.Agents.Decision[idx] = uint8(behaviorOffsetFeed) // feed type 0
	w.Agents.Situation[idx] = world.SituationRegular

	// Place resource of type 0 at (10.5, 10) — within contiguous distance.
	w.Resources.PosX[0] = 10.5
	w.Resources.PosY[0] = 10
	w.Resources.TypeID[0] = 0
	w.Resources.Count = 1

	// Place another resource of type 1 (should not be selected).
	w.Resources.PosX[1] = 11
	w.Resources.PosY[1] = 10
	w.Resources.TypeID[1] = 1
	w.Resources.Count = 2

	resourceGrid := spatial.NewGrid(5.0, 64)
	for i := 0; i < w.Resources.Count; i++ {
		resourceGrid.Insert(int32(i), w.Resources.PosX[i], w.Resources.PosY[i])
	}
	agentGrid := spatial.NewGrid(5.0, 64)
	agentGrid.Insert(int32(idx), w.Agents.PosX[idx], w.Agents.PosY[idx])

	EstablishInteraction(w, idx, agentGrid, resourceGrid)

	if w.Agents.InteractantIdx[idx] != 0 {
		t.Fatalf("expected interactant=0 (resource type 0), got %d", w.Agents.InteractantIdx[idx])
	}
}

func TestEstablishInteractionMove(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Decision[idx] = behaviorMove
	w.Agents.Situation[idx] = world.SituationRegular
	w.Agents.InteractantIdx[idx] = 5 // Previously interacting.

	agentGrid := spatial.NewGrid(5.0, 64)
	resourceGrid := spatial.NewGrid(5.0, 64)

	EstablishInteraction(w, idx, agentGrid, resourceGrid)

	if w.Agents.InteractantIdx[idx] != -1 {
		t.Fatalf("expected interactant=-1 for move, got %d", w.Agents.InteractantIdx[idx])
	}
}

func TestEstablishInteractionCombat(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Initiator at (10, 10).
	idx0 := w.AddAgent()
	w.Agents.PosX[idx0] = 10
	w.Agents.PosY[idx0] = 10
	w.Agents.Sex[idx0] = world.SexMale
	w.Agents.Situation[idx0] = world.SituationRegular
	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	w.Agents.Decision[idx0] = uint8(fightDisplayIdx)
	w.Agents.StageID[idx0] = -1
	w.Agents.PrototypeID[idx0] = 0

	// Target at (10.5, 10) — same sex, regular, contiguous.
	idx1 := w.AddAgent()
	w.Agents.PosX[idx1] = 10.5
	w.Agents.PosY[idx1] = 10
	w.Agents.Sex[idx1] = world.SexMale
	w.Agents.Situation[idx1] = world.SituationRegular
	w.Agents.StageID[idx1] = -1
	w.Agents.PrototypeID[idx1] = 0

	agentGrid := spatial.NewGrid(5.0, 64)
	agentGrid.Insert(int32(idx0), w.Agents.PosX[idx0], w.Agents.PosY[idx0])
	agentGrid.Insert(int32(idx1), w.Agents.PosX[idx1], w.Agents.PosY[idx1])
	resourceGrid := spatial.NewGrid(5.0, 64)

	EstablishInteraction(w, idx0, agentGrid, resourceGrid)

	if w.Agents.InteractantIdx[idx0] != int32(idx1) {
		t.Fatalf("expected initiator interactant=%d, got %d", idx1, w.Agents.InteractantIdx[idx0])
	}
	if w.Agents.Situation[idx0] != world.SituationCombat {
		t.Fatalf("expected initiator in combat, got %d", w.Agents.Situation[idx0])
	}
	if w.Agents.Situation[idx1] != world.SituationCombat {
		t.Fatalf("expected target in combat, got %d", w.Agents.Situation[idx1])
	}
	if w.Agents.InteractantIdx[idx1] != int32(idx0) {
		t.Fatalf("expected target interactant=%d, got %d", idx0, w.Agents.InteractantIdx[idx1])
	}
}

func TestEstablishInteractionCourtship(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Male initiator.
	idx0 := w.AddAgent()
	w.Agents.PosX[idx0] = 10
	w.Agents.PosY[idx0] = 10
	w.Agents.Sex[idx0] = world.SexMale
	w.Agents.Situation[idx0] = world.SituationRegular
	courtDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 2
	w.Agents.Decision[idx0] = uint8(courtDisplayIdx)
	w.Agents.StageID[idx0] = -1
	w.Agents.PrototypeID[idx0] = 0

	// Female target.
	idx1 := w.AddAgent()
	w.Agents.PosX[idx1] = 10.5
	w.Agents.PosY[idx1] = 10
	w.Agents.Sex[idx1] = world.SexFemale
	w.Agents.Situation[idx1] = world.SituationRegular
	w.Agents.StageID[idx1] = -1
	w.Agents.PrototypeID[idx1] = 0

	agentGrid := spatial.NewGrid(5.0, 64)
	agentGrid.Insert(int32(idx0), w.Agents.PosX[idx0], w.Agents.PosY[idx0])
	agentGrid.Insert(int32(idx1), w.Agents.PosX[idx1], w.Agents.PosY[idx1])
	resourceGrid := spatial.NewGrid(5.0, 64)

	EstablishInteraction(w, idx0, agentGrid, resourceGrid)

	if w.Agents.Situation[idx0] != world.SituationCourtship {
		t.Fatalf("expected initiator in courtship, got %d", w.Agents.Situation[idx0])
	}
	if w.Agents.Situation[idx1] != world.SituationCourtship {
		t.Fatalf("expected target in courtship, got %d", w.Agents.Situation[idx1])
	}
}

func TestIsOppositeSex(t *testing.T) {
	if !isOppositeSex(world.SexMale, world.SexFemale) {
		t.Error("M/F should be opposite")
	}
	if !isOppositeSex(world.SexFemale, world.SexMale) {
		t.Error("F/M should be opposite")
	}
	if isOppositeSex(world.SexMale, world.SexMale) {
		t.Error("M/M should not be opposite")
	}
	if isOppositeSex(world.SexFemale, world.SexFemale) {
		t.Error("F/F should not be opposite")
	}
	if isOppositeSex(world.SexUndefined, world.SexMale) {
		t.Error("U/M should not be opposite")
	}
}
