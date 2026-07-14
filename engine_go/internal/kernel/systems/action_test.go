package systems

import (
	"testing"

	"galatea/engine/internal/kernel/world"
)

func TestActMoveChangesPosition(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.PosX[idx] = 25
	w.Agents.PosY[idx] = 25
	w.Agents.Direction[idx] = 2 // North
	w.Agents.Speed[idx] = 1
	w.Agents.Decision[idx] = behaviorMove

	// Set tendency: all forward (N).
	tendBase := idx * 8
	w.Agents.Tendencies[tendBase+DirN] = 100

	Act(w, idx)

	// Agent should have moved north (Y decreases).
	if w.Agents.PosY[idx] >= 25 {
		t.Fatalf("expected Y < 25 after moving north, got %f", w.Agents.PosY[idx])
	}
	if w.Agents.State[idx] != world.StateActing {
		t.Fatalf("expected state=Acting, got %d", w.Agents.State[idx])
	}
}

func TestActMoveClampsToBounds(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.PosX[idx] = 0
	w.Agents.PosY[idx] = 0
	w.Agents.Direction[idx] = 1 // NW
	w.Agents.Speed[idx] = 5
	w.Agents.Decision[idx] = behaviorMove

	// Set tendency: forward (NW relative to NW facing = NW absolute).
	tendBase := idx * 8
	w.Agents.Tendencies[tendBase+DirN] = 100

	Act(w, idx)

	// Should be clamped to 0.
	if w.Agents.PosX[idx] < 0 || w.Agents.PosY[idx] < 0 {
		t.Fatalf("position went negative: (%f, %f)", w.Agents.PosX[idx], w.Agents.PosY[idx])
	}
}

func TestActFeedTransfersResources(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.PosX[idx] = 10
	w.Agents.PosY[idx] = 10
	w.Agents.Speed[idx] = 5
	w.Agents.Decision[idx] = uint8(behaviorOffsetFeed) // Feed from resource type 0.
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 20    // Current water reserve.

	// Place resource of type 0 with level 50.
	w.Resources.PosX[0] = 10
	w.Resources.PosY[0] = 10
	w.Resources.TypeID[0] = 0
	w.Resources.Level[0] = 50
	w.Resources.Count = 1

	w.Agents.InteractantIdx[idx] = 0

	Act(w, idx)

	// Agent should have gained resources (speed=5 units transferred).
	expectedReserve := int32(20 + 5)
	if w.Agents.Reserves[idx*cfg.NumNutrients+0] != expectedReserve {
		t.Fatalf("expected reserve=%d, got %d", expectedReserve, w.Agents.Reserves[idx*cfg.NumNutrients+0])
	}
	// Resource should have been depleted.
	if w.Resources.Level[0] != 45 {
		t.Fatalf("expected resource level=45, got %d", w.Resources.Level[0])
	}
}

func TestActFeedLimitedByResourceLevel(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Speed[idx] = 10
	w.Agents.Decision[idx] = uint8(behaviorOffsetFeed)
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 0

	// Resource with only 3 units left.
	w.Resources.PosX[0] = 0
	w.Resources.PosY[0] = 0
	w.Resources.TypeID[0] = 0
	w.Resources.Level[0] = 3
	w.Resources.Count = 1

	w.Agents.InteractantIdx[idx] = 0

	Act(w, idx)

	// Should only take 3 (limited by resource level).
	if w.Agents.Reserves[idx*cfg.NumNutrients+0] != 3 {
		t.Fatalf("expected reserve=3, got %d", w.Agents.Reserves[idx*cfg.NumNutrients+0])
	}
	if w.Resources.Level[0] != 0 {
		t.Fatalf("expected resource level=0, got %d", w.Resources.Level[0])
	}
}

func TestActCombatRetreat(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Initiator retreats.
	idx0 := w.AddAgent()
	w.Agents.Situation[idx0] = world.SituationCombat
	retreatIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 4
	w.Agents.Decision[idx0] = uint8(retreatIdx)

	// Opponent.
	idx1 := w.AddAgent()
	w.Agents.Situation[idx1] = world.SituationCombat
	w.Agents.InteractantIdx[idx0] = int32(idx1)
	w.Agents.InteractantIdx[idx1] = int32(idx0)

	Act(w, idx0)

	// Retreater returns to regular.
	if w.Agents.Situation[idx0] != world.SituationRegular {
		t.Fatalf("retreater should be regular, got %d", w.Agents.Situation[idx0])
	}
	// Opponent wins.
	if w.Agents.Situation[idx1] != world.SituationRegular {
		t.Fatalf("winner should be regular, got %d", w.Agents.Situation[idx1])
	}
}

func TestActCourtshipReject(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx0 := w.AddAgent()
	w.Agents.Situation[idx0] = world.SituationCourtship
	courtRejectIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 2 + courtshipReject
	w.Agents.Decision[idx0] = uint8(courtRejectIdx)

	idx1 := w.AddAgent()
	w.Agents.Situation[idx1] = world.SituationCourtship
	w.Agents.InteractantIdx[idx0] = int32(idx1)
	w.Agents.InteractantIdx[idx1] = int32(idx0)

	Act(w, idx0)

	if w.Agents.Situation[idx0] != world.SituationRegular {
		t.Fatalf("rejecter should be regular, got %d", w.Agents.Situation[idx0])
	}
	if w.Agents.Situation[idx1] != world.SituationRegular {
		t.Fatalf("rejected should be regular, got %d", w.Agents.Situation[idx1])
	}
}

func TestActRest(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.PosX[idx] = 25
	w.Agents.PosY[idx] = 25
	w.Agents.Decision[idx] = behaviorRest

	Act(w, idx)

	// Position unchanged.
	if w.Agents.PosX[idx] != 25 || w.Agents.PosY[idx] != 25 {
		t.Fatalf("rest should not move agent, got (%f,%f)", w.Agents.PosX[idx], w.Agents.PosY[idx])
	}
}

func TestChargeNutrientsWithCosts(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 40
	w.Agents.Decision[idx] = behaviorMove

	// Cost table: move costs 3 water, 2 sugar.
	costs := make([]int32, cfg.NumBehaviors*cfg.NumNutrients)
	costs[behaviorMove*cfg.NumNutrients+0] = 3
	costs[behaviorMove*cfg.NumNutrients+1] = 2

	ChargeNutrients(w, idx, costs)

	if w.Agents.Reserves[idx*cfg.NumNutrients+0] != 47 {
		t.Fatalf("expected water=47, got %d", w.Agents.Reserves[idx*cfg.NumNutrients+0])
	}
	if w.Agents.Reserves[idx*cfg.NumNutrients+1] != 38 {
		t.Fatalf("expected sugar=38, got %d", w.Agents.Reserves[idx*cfg.NumNutrients+1])
	}
}

func TestChargeNutrientsDefaultCost(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 10
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 10
	w.Agents.Decision[idx] = behaviorMove

	ChargeNutrients(w, idx, nil) // No cost table → default 1 per nutrient.

	if w.Agents.Reserves[idx*cfg.NumNutrients+0] != 9 {
		t.Fatalf("expected water=9, got %d", w.Agents.Reserves[idx*cfg.NumNutrients+0])
	}
}

func TestChargeNutrientsRestNoCost(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 10
	w.Agents.Decision[idx] = behaviorRest

	ChargeNutrients(w, idx, nil)

	// Rest has no cost.
	if w.Agents.Reserves[idx*cfg.NumNutrients+0] != 10 {
		t.Fatalf("rest should not deduct, got %d", w.Agents.Reserves[idx*cfg.NumNutrients+0])
	}
}

func TestChargeNutrientsClampsToZero(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 2
	w.Agents.Decision[idx] = behaviorMove

	costs := make([]int32, cfg.NumBehaviors*cfg.NumNutrients)
	costs[behaviorMove*cfg.NumNutrients+0] = 10 // Cost exceeds reserve.

	ChargeNutrients(w, idx, costs)

	if w.Agents.Reserves[idx*cfg.NumNutrients+0] != 0 {
		t.Fatalf("expected clamped to 0, got %d", w.Agents.Reserves[idx*cfg.NumNutrients+0])
	}
}

func TestUpdateAgentStarvation(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	// All reserves at 0 → starvation.
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 0
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 0

	UpdateAgent(w, idx, 1000)

	if w.Agents.Situation[idx] != world.SituationDead {
		t.Fatalf("expected dead from starvation, got %d", w.Agents.Situation[idx])
	}
}

func TestUpdateAgentOldAge(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.StageID[idx] = -1 // Adult.
	w.Agents.Age[idx] = 501
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 50

	UpdateAgent(w, idx, 500) // Longevity = 500.

	if w.Agents.Situation[idx] != world.SituationDead {
		t.Fatalf("expected dead from old age, got %d", w.Agents.Situation[idx])
	}
}

func TestUpdateAgentSurvives(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Age[idx] = 10
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 50

	UpdateAgent(w, idx, 1000)

	if w.Agents.Situation[idx] == world.SituationDead {
		t.Fatal("agent should survive")
	}
	if w.Agents.Age[idx] != 11 {
		t.Fatalf("expected age=11, got %d", w.Agents.Age[idx])
	}
}

func TestRegenerateResources(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	w.Resources.Level[0] = 50
	w.Resources.MaxLevel[0] = 100
	w.Resources.RegenRate[0] = 1.1
	w.Resources.Level[1] = 95
	w.Resources.MaxLevel[1] = 100
	w.Resources.RegenRate[1] = 1.5
	w.Resources.Level[2] = 0
	w.Resources.MaxLevel[2] = 100
	w.Resources.RegenRate[2] = 1.2
	w.Resources.Count = 3

	RegenerateResources(w)

	// Resource 0: 50 * 1.1 = 55.
	if w.Resources.Level[0] != 55 {
		t.Fatalf("resource 0: expected 55, got %d", w.Resources.Level[0])
	}
	// Resource 1: 95 * 1.5 = 142 → capped at 100.
	if w.Resources.Level[1] != 100 {
		t.Fatalf("resource 1: expected 100 (capped), got %d", w.Resources.Level[1])
	}
	// Resource 2: 0 * 1.2 = 0 → reset to 1 (prevent permanent depletion).
	if w.Resources.Level[2] != 1 {
		t.Fatalf("resource 2: expected 1 (anti-depletion), got %d", w.Resources.Level[2])
	}
}

func TestRemoveDeadAgents(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Add 5 agents, mark 2 as dead.
	for i := 0; i < 5; i++ {
		idx := w.AddAgent()
		w.Agents.PosX[idx] = float64(i + 1)
		w.Agents.Reserves[idx*cfg.NumNutrients+0] = 50
		w.Agents.Reserves[idx*cfg.NumNutrients+1] = 50
	}
	w.Agents.Situation[1] = world.SituationDead
	w.Agents.Situation[3] = world.SituationDead

	removed := RemoveDeadAgents(w)

	if removed != 2 {
		t.Fatalf("expected 2 removed, got %d", removed)
	}
	if w.Agents.Count != 3 {
		t.Fatalf("expected 3 remaining, got %d", w.Agents.Count)
	}

	// No dead agents should remain.
	for i := 0; i < w.Agents.Count; i++ {
		if w.Agents.Situation[i] == world.SituationDead {
			t.Fatalf("dead agent at index %d should have been removed", i)
		}
	}
}

func TestRemoveDeadNotifiesCombatPartner(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx0 := w.AddAgent()
	idx1 := w.AddAgent()

	// Agent 0 dies while in combat with agent 1.
	w.Agents.Situation[idx0] = world.SituationDead
	w.Agents.Situation[idx1] = world.SituationCombat
	w.Agents.InteractantIdx[idx0] = int32(idx1)
	w.Agents.InteractantIdx[idx1] = int32(idx0)
	w.Agents.Reserves[idx1*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx1*cfg.NumNutrients+1] = 50

	RemoveDeadAgents(w)

	// Agent 1 should be freed (won by default).
	if w.Agents.Count != 1 {
		t.Fatalf("expected 1 agent remaining, got %d", w.Agents.Count)
	}
	if w.Agents.Situation[0] != world.SituationRegular {
		t.Fatalf("surviving agent should be regular, got %d", w.Agents.Situation[0])
	}
}

func TestBehaviorMemoryUpdate(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	memBase := idx * cfg.NumBehaviors

	// Set some initial memory values.
	w.Agents.MemoryLastBehavior[memBase+0] = 5
	w.Agents.MemoryLastBehavior[memBase+1] = 3

	w.Agents.Decision[idx] = behaviorMove

	Act(w, idx)

	// Move (0) should be reset to 0 and count incremented.
	if w.Agents.MemoryLastBehavior[memBase+0] != 0 {
		t.Fatalf("expected MemoryLastBehavior[move]=0, got %d", w.Agents.MemoryLastBehavior[memBase+0])
	}
	if w.Agents.MemoryNumBehavior[memBase+0] != 1 {
		t.Fatalf("expected MemoryNumBehavior[move]=1, got %d", w.Agents.MemoryNumBehavior[memBase+0])
	}
	// Other behaviors should have been incremented.
	if w.Agents.MemoryLastBehavior[memBase+1] != 4 {
		t.Fatalf("expected MemoryLastBehavior[rest]=4, got %d", w.Agents.MemoryLastBehavior[memBase+1])
	}
}
