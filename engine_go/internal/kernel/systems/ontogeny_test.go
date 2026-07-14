package systems

import (
	"testing"

	"galatea/engine/internal/kernel/world"
)

func testOntogenyCfg() OntogenyConfig {
	return OntogenyConfig{
		NumStages:      2,
		NumPrototypesM: 1,
		NumPrototypesF: 1,
		Stages: []StageConfig{
			{ // Stage 0 (egg eclosion).
				CyclesRequired:  10,
				NutrientReqs:    []int32{5, 5},
				NutrientCosts:   []int32{2, 2},
				LogicCyclesReqs: true,  // AND
				LogicReqsConds:  false, // OR (conditions always true → doesn't matter)
				LogicCond1Cond2: true,
				LinkedPrototype: -1,
			},
			{ // Stage 1 (larva → adult).
				CyclesRequired:  20,
				NutrientReqs:    []int32{10, 10},
				NutrientCosts:   []int32{3, 3},
				LogicCyclesReqs: true,
				LogicReqsConds:  false,
				LogicCond1Cond2: true,
				LinkedPrototype: -1,
			},
		},
		AssignmentPriorityM:  []int{0},
		AssignmentPriorityF:  []int{0},
		AssignmentThresholds: []float64{0.5},
	}
}

func TestEvaluateEggs_Eclosion(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	ontCfg := testOntogenyCfg()
	genCfg := GeneticsConfig{NumLoci: cfg.NumLoci}

	// Manually add an egg that meets eclosion conditions.
	eggs := w.Eggs
	eggs.Count = 1
	eggs.PosX[0] = 15
	eggs.PosY[0] = 20
	eggs.Age[0] = 15 // >= 10 required.
	eggs.Sex[0] = world.SexMale
	eggs.Reserves[0*cfg.NumNutrients+0] = 10 // >= 5 required.
	eggs.Reserves[0*cfg.NumNutrients+1] = 10

	eclosed := EvaluateEggs(w, ontCfg, genCfg)

	if eclosed != 1 {
		t.Fatalf("expected 1 eclosion, got %d", eclosed)
	}
	if eggs.Count != 0 {
		t.Fatalf("expected 0 eggs remaining, got %d", eggs.Count)
	}
	if w.Agents.Count != 1 {
		t.Fatalf("expected 1 new agent, got %d", w.Agents.Count)
	}

	// Verify new agent properties.
	a := w.Agents
	if a.PosX[0] != 15 || a.PosY[0] != 20 {
		t.Fatalf("agent position: expected (15,20), got (%f,%f)", a.PosX[0], a.PosY[0])
	}
	if a.Sex[0] != world.SexMale {
		t.Fatalf("expected male, got %d", a.Sex[0])
	}
	if a.Situation[0] != world.SituationImmature {
		t.Fatalf("expected immature, got %d", a.Situation[0])
	}
	// Reserves should have eclosion costs deducted: 10-2=8.
	if a.Reserves[0*cfg.NumNutrients+0] != 8 {
		t.Fatalf("expected reserve0=8, got %d", a.Reserves[0*cfg.NumNutrients+0])
	}
}

func TestEvaluateEggs_NotReady(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	ontCfg := testOntogenyCfg()
	genCfg := GeneticsConfig{NumLoci: cfg.NumLoci}

	// Egg that doesn't meet age requirement.
	eggs := w.Eggs
	eggs.Count = 1
	eggs.Age[0] = 5 // < 10 required.
	eggs.Reserves[0*cfg.NumNutrients+0] = 10
	eggs.Reserves[0*cfg.NumNutrients+1] = 10

	eclosed := EvaluateEggs(w, ontCfg, genCfg)

	if eclosed != 0 {
		t.Fatalf("expected 0 eclosions (age not met), got %d", eclosed)
	}
	if eggs.Count != 1 {
		t.Fatalf("egg should still exist")
	}
}

func TestEvaluateStageTransition_Advances(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	ontCfg := testOntogenyCfg()

	idx := w.AddAgent()
	a := w.Agents
	a.StageID[idx] = 1                      // In stage 1 (larva).
	a.TimeInStage[idx] = 25                 // >= 20 required.
	a.Reserves[idx*cfg.NumNutrients+0] = 50 // >= 10 required.
	a.Reserves[idx*cfg.NumNutrients+1] = 50
	a.Sex[idx] = world.SexFemale
	// Set genotype for prototype assignment.
	genoBase := idx * cfg.NumLoci * 2
	a.GenotypeCont[genoBase] = 1.0
	a.DominanceCont[genoBase] = 1
	a.GenotypeCont[genoBase+1] = 0.8
	a.DominanceCont[genoBase+1] = 1

	transitioned := EvaluateStageTransition(w, idx, ontCfg)

	if !transitioned {
		t.Fatal("expected transition")
	}
	// Stage 1 is last stage → becomes adult.
	if a.StageID[idx] != -1 {
		t.Fatalf("expected adult (stageID=-1), got %d", a.StageID[idx])
	}
	if a.Situation[idx] != world.SituationRegular {
		t.Fatalf("expected regular situation, got %d", a.Situation[idx])
	}
	if a.PrototypeID[idx] < 0 {
		t.Fatalf("expected prototype assigned, got %d", a.PrototypeID[idx])
	}
	if !a.MorphologyFixed[idx] {
		t.Fatal("expected morphology fixed")
	}
	// Costs deducted: 50 - 3 = 47.
	if a.Reserves[idx*cfg.NumNutrients+0] != 47 {
		t.Fatalf("expected reserve0=47, got %d", a.Reserves[idx*cfg.NumNutrients+0])
	}
}

func TestEvaluateStageTransition_NotReady(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	// Use AND for all logic operators to ensure cycles must be met.
	ontCfg := OntogenyConfig{
		NumStages:      2,
		NumPrototypesM: 1,
		NumPrototypesF: 1,
		Stages: []StageConfig{
			{CyclesRequired: 10, NutrientReqs: []int32{5, 5}, NutrientCosts: []int32{2, 2}, LogicCyclesReqs: true, LogicReqsConds: true},
			{CyclesRequired: 20, NutrientReqs: []int32{10, 10}, NutrientCosts: []int32{3, 3}, LogicCyclesReqs: true, LogicReqsConds: true},
		},
		AssignmentPriorityM:  []int{0},
		AssignmentPriorityF:  []int{0},
		AssignmentThresholds: []float64{0.5},
	}

	idx := w.AddAgent()
	a := w.Agents
	a.StageID[idx] = 1
	a.TimeInStage[idx] = 5 // < 20 required.
	a.Reserves[idx*cfg.NumNutrients+0] = 50
	a.Reserves[idx*cfg.NumNutrients+1] = 50

	transitioned := EvaluateStageTransition(w, idx, ontCfg)

	if transitioned {
		t.Fatal("should not transition (cycles not met with AND logic)")
	}
	if a.StageID[idx] != 1 {
		t.Fatal("stage should not change")
	}
}

func TestEvaluateStageTransition_AdvancesToNextStage(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// 3 stages: transitions from 0 to 1 (not to adult).
	ontCfg := OntogenyConfig{
		NumStages:      3,
		NumPrototypesM: 1,
		NumPrototypesF: 1,
		Stages: []StageConfig{
			{CyclesRequired: 5, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{1, 1}, LogicCyclesReqs: true, LogicReqsConds: false},
			{CyclesRequired: 10, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{1, 1}, LogicCyclesReqs: true, LogicReqsConds: false},
			{CyclesRequired: 15, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{1, 1}, LogicCyclesReqs: true, LogicReqsConds: false},
		},
		AssignmentPriorityM:  []int{0},
		AssignmentPriorityF:  []int{0},
		AssignmentThresholds: []float64{0},
	}

	idx := w.AddAgent()
	a := w.Agents
	a.StageID[idx] = 0
	a.TimeInStage[idx] = 6 // >= 5 for stage 0.
	a.Reserves[idx*cfg.NumNutrients+0] = 50
	a.Reserves[idx*cfg.NumNutrients+1] = 50

	transitioned := EvaluateStageTransition(w, idx, ontCfg)

	if !transitioned {
		t.Fatal("expected transition")
	}
	if a.StageID[idx] != 1 {
		t.Fatalf("expected stageID=1, got %d", a.StageID[idx])
	}
	if a.TimeInStage[idx] != 0 {
		t.Fatalf("expected timeInStage reset to 0, got %d", a.TimeInStage[idx])
	}
}

func TestFixMorphology(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	a := w.Agents
	numLoci := cfg.NumLoci

	// Set genotype: locus 0 = codominant (1.0, 3.0) → expressed 2.0.
	genoBase := idx * numLoci * 2
	a.GenotypeCont[genoBase+0] = 1.0
	a.GenotypeCont[genoBase+1] = 3.0
	a.DominanceCont[genoBase+0] = 1
	a.DominanceCont[genoBase+1] = 1

	// Locus 1: paternal dominant.
	a.GenotypeCont[genoBase+2] = 5.0
	a.GenotypeCont[genoBase+3] = 9.0
	a.DominanceCont[genoBase+2] = 1
	a.DominanceCont[genoBase+3] = 0

	FixMorphology(w, idx)

	morphBase := idx * numLoci
	if a.MorphologyCont[morphBase+0] != 2.0 {
		t.Fatalf("expected morph[0]=2.0, got %f", a.MorphologyCont[morphBase+0])
	}
	if a.MorphologyCont[morphBase+1] != 5.0 {
		t.Fatalf("expected morph[1]=5.0 (paternal dominant), got %f", a.MorphologyCont[morphBase+1])
	}
	if !a.MorphologyFixed[idx] {
		t.Fatal("expected MorphologyFixed=true")
	}
}

func TestResolveCombatDynamics_Timeout(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx0 := w.AddAgent()
	idx1 := w.AddAgent()
	a := w.Agents

	a.Situation[idx0] = world.SituationCombat
	a.Situation[idx1] = world.SituationCombat
	a.InteractantIdx[idx0] = int32(idx1)
	a.InteractantIdx[idx1] = int32(idx0)
	a.TimeInInteraction[idx0] = 20
	a.TimeInInteraction[idx1] = 15

	ResolveCombatDynamics(w, 18) // maxTicks=18, agent 0 exceeds.

	if a.Situation[idx0] != world.SituationRegular {
		t.Fatalf("timeout agent should be regular, got %d", a.Situation[idx0])
	}
	// Agent 1 wins.
	if a.Situation[idx1] != world.SituationRegular {
		t.Fatalf("winner should be regular, got %d", a.Situation[idx1])
	}
}

func TestResolveCourtshipDynamics_MutualAcceptance(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	male := w.AddAgent()
	female := w.AddAgent()
	a := w.Agents

	a.Sex[male] = world.SexMale
	a.Sex[female] = world.SexFemale
	a.Situation[male] = world.SituationCourtship
	a.Situation[female] = world.SituationCourtship
	a.InteractantIdx[male] = int32(female)
	a.InteractantIdx[female] = int32(male)
	a.LastOpponentAction[male] = 3   // Female accepted.
	a.LastOpponentAction[female] = 3 // Male accepted.
	a.GametesCount[male] = 5
	a.GametesCount[female] = 10
	a.Reserves[male*cfg.NumNutrients+0] = 50
	a.Reserves[female*cfg.NumNutrients+0] = 50

	reproCfg := ReproductionConfig{
		PacksTransferred:   2,
		MaxStoredPacks:     10,
		FractionFertilized: 0.5,
	}
	genCfg := GeneticsConfig{NumLoci: cfg.NumLoci}

	copulations := ResolveCourtshipDynamics(w, 100, reproCfg, genCfg)

	if copulations != 1 {
		t.Fatalf("expected 1 copulation, got %d", copulations)
	}
	if a.Situation[male] != world.SituationRegular {
		t.Fatalf("male should be regular after copulation, got %d", a.Situation[male])
	}
	if a.SpermPacksCount[female] != 2 {
		t.Fatalf("female should have 2 sperm packs, got %d", a.SpermPacksCount[female])
	}
}

func TestResolveCourtshipDynamics_Timeout(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx0 := w.AddAgent()
	idx1 := w.AddAgent()
	a := w.Agents

	a.Situation[idx0] = world.SituationCourtship
	a.Situation[idx1] = world.SituationCourtship
	a.InteractantIdx[idx0] = int32(idx1)
	a.InteractantIdx[idx1] = int32(idx0)
	a.LastOpponentAction[idx0] = 1 // Still displaying.
	a.LastOpponentAction[idx1] = 1
	a.TimeInInteraction[idx0] = 50
	a.TimeInInteraction[idx1] = 50

	reproCfg := ReproductionConfig{}
	genCfg := GeneticsConfig{NumLoci: cfg.NumLoci}

	ResolveCourtshipDynamics(w, 30, reproCfg, genCfg) // maxTicks=30, both exceed.

	if a.Situation[idx0] != world.SituationRegular {
		t.Fatalf("idx0 should be regular after timeout, got %d", a.Situation[idx0])
	}
	if a.Situation[idx1] != world.SituationRegular {
		t.Fatalf("idx1 should be regular after timeout, got %d", a.Situation[idx1])
	}
}

func TestCombineLogic(t *testing.T) {
	// AND, OR
	if !combineLogic(true, true, true, true, false) {
		t.Error("T AND T OR T should be true")
	}
	if combineLogic(true, false, false, true, true) {
		t.Error("(T AND F) AND F should be false")
	}
	if !combineLogic(true, false, true, false, true) {
		t.Error("(T OR F) AND T should be true")
	}
	if !combineLogic(false, false, true, true, false) {
		t.Error("(F AND F) OR T should be true")
	}
}
