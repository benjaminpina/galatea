package systems

import (
	"testing"

	"galatea/engine/internal/kernel/formulas"
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
		AssignmentPriorityM: []int{0},
		AssignmentPriorityF: []int{0},
		Registry:            formulas.NewRegistry(),
		Eval:                formulas.NewEvaluator(16),
		EnvBuilder:          formulas.NewEnvBuilder(formulas.NewEvaluator(16), testCfg()),
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

// TestEclosionFreesOvipositionSiteCapacity verifies that when an egg held in an
// oviposition site ecloses, the site's egg count (Level) is decremented so the
// freed capacity becomes available again.
func TestEclosionFreesOvipositionSiteCapacity(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	ontCfg := testOntogenyCfg()
	genCfg := GeneticsConfig{NumLoci: cfg.NumLoci}

	// Oviposition site currently holding 2 eggs.
	site := w.Resources.Count
	w.Resources.PosX[site] = 15
	w.Resources.PosY[site] = 20
	w.Resources.TypeID[site] = world.ResourceTypeOvipositionSite
	w.Resources.Level[site] = 2
	w.Resources.MaxLevel[site] = 5
	w.Resources.Count++

	// One egg (of those 2) is ready to eclose and references the site.
	eggs := w.Eggs
	eggs.Count = 1
	eggs.PosX[0] = 15
	eggs.PosY[0] = 20
	eggs.Age[0] = 15
	eggs.Sex[0] = world.SexMale
	eggs.CarrierResourceIdx[0] = int32(site)
	eggs.CarrierAgentIdx[0] = -1
	eggs.Reserves[0*cfg.NumNutrients+0] = 10
	eggs.Reserves[0*cfg.NumNutrients+1] = 10

	if EvaluateEggs(w, ontCfg, genCfg) != 1 {
		t.Fatal("expected 1 eclosion")
	}
	// Site egg count must drop from 2 to 1.
	if w.Resources.Level[site] != 1 {
		t.Fatalf("expected site level 1 after eclosion, got %d", w.Resources.Level[site])
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
		AssignmentPriorityM: []int{0},
		AssignmentPriorityF: []int{0},
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
		AssignmentPriorityM: []int{0},
		AssignmentPriorityF: []int{0},
		Registry:            formulas.NewRegistry(),
		Eval:                formulas.NewEvaluator(16),
		EnvBuilder:          formulas.NewEnvBuilder(formulas.NewEvaluator(16), testCfg()),
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

	FixMorphology(w, idx, formulas.NewRegistry(), formulas.NewEvaluator(16), formulas.NewEnvBuilder(formulas.NewEvaluator(16), cfg))

	morphBase := idx * cfg.NumCharacters
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

	copulations := ResolveCourtshipDynamics(w, 100, reproCfg, genCfg, nil, nil, nil, nil)

	if copulations != 1 {
		t.Fatalf("expected 1 copulation, got %d", copulations)
	}
	if a.Situation[male] != world.SituationRegular {
		t.Fatalf("male should be regular after copulation, got %d", a.Situation[male])
	}
	// 2 packs transferred; fertilization (target 5, capped by 2 packs)
	// consumes both packs and produces 2 retained fertilized eggs.
	if a.SpermPackCount(female) != 0 {
		t.Fatalf("female should have 0 sperm packs after fertilization, got %d", a.SpermPackCount(female))
	}
	if a.FertilizedCount(female) != 2 {
		t.Fatalf("female should have 2 fertilized eggs, got %d", a.FertilizedCount(female))
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

	ResolveCourtshipDynamics(w, 30, reproCfg, genCfg, nil, nil, nil, nil) // maxTicks=30, both exceed.

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

// eggViabilityCtx builds the registry/eval/envBuilder trio for egg-viability tests.
func eggViabilityCtx(w *world.World) (*formulas.Registry, *formulas.Evaluator, *formulas.EnvBuilder) {
	reg := formulas.NewRegistry()
	eval := formulas.NewEvaluator(128)
	envBuilder := formulas.NewEnvBuilder(eval, w.Config)
	return reg, eval, envBuilder
}

// TestEggViabilityAgentCarrierDies verifies an egg carried by an agent dies when
// the carrier's interaction matrix gives all weight to Egg_Die.
func TestEggViabilityAgentCarrierDies(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	carrier := w.AddAgent()
	w.Agents.StageID[carrier] = 0 // perceiver index 0
	w.Agents.Situation[carrier] = world.SituationRegular

	eggs := w.Eggs
	eggs.Count = 1
	eggs.CarrierAgentIdx[0] = int32(carrier)
	eggs.CarrierResourceIdx[0] = -1

	reg, eval, envBuilder := eggViabilityCtx(w)
	// Carrier proto index 0: survive=0, die=1 → certain death.
	_ = reg.Compile(InteractionKeyAgent(0, 0, EggSurviveBehaviorIdx(cfg)), "0")
	_ = reg.Compile(InteractionKeyAgent(0, 0, EggDieBehaviorIdx(cfg)), "1")

	died := EvaluateEggViability(w, reg, eval, envBuilder)
	if died != 1 {
		t.Fatalf("expected 1 egg to die, got %d", died)
	}
	if w.Eggs.Count != 0 {
		t.Fatalf("expected 0 eggs remaining, got %d", w.Eggs.Count)
	}
}

// TestEggViabilityAgentCarrierSurvives verifies an egg survives when the
// carrier's matrix gives all weight to Egg_Survive.
func TestEggViabilityAgentCarrierSurvives(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	carrier := w.AddAgent()
	w.Agents.StageID[carrier] = 0
	w.Agents.Situation[carrier] = world.SituationRegular

	eggs := w.Eggs
	eggs.Count = 1
	eggs.CarrierAgentIdx[0] = int32(carrier)
	eggs.CarrierResourceIdx[0] = -1

	reg, eval, envBuilder := eggViabilityCtx(w)
	_ = reg.Compile(InteractionKeyAgent(0, 0, EggSurviveBehaviorIdx(cfg)), "1")
	_ = reg.Compile(InteractionKeyAgent(0, 0, EggDieBehaviorIdx(cfg)), "0")

	died := EvaluateEggViability(w, reg, eval, envBuilder)
	if died != 0 {
		t.Fatalf("expected no egg to die, got %d", died)
	}
	if w.Eggs.Count != 1 {
		t.Fatalf("expected 1 egg remaining, got %d", w.Eggs.Count)
	}
}

// TestEggViabilityOrphanDies verifies an egg whose carrier agent is dead is
// forced to die (orphaned), regardless of any matrix.
func TestEggViabilityOrphanDies(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	carrier := w.AddAgent()
	w.Agents.StageID[carrier] = 0
	w.Agents.Situation[carrier] = world.SituationDead // carrier is gone

	eggs := w.Eggs
	eggs.Count = 1
	eggs.CarrierAgentIdx[0] = int32(carrier)
	eggs.CarrierResourceIdx[0] = -1

	reg, eval, envBuilder := eggViabilityCtx(w)
	// Even with survive=1, the orphan must die.
	_ = reg.Compile(InteractionKeyAgent(0, 0, EggSurviveBehaviorIdx(cfg)), "1")

	died := EvaluateEggViability(w, reg, eval, envBuilder)
	if died != 1 {
		t.Fatalf("expected orphan egg to die, got %d", died)
	}
}

// TestEggViabilitySiteSurvivesByDefault verifies an egg in an oviposition site
// survives by default (site viability is not matrix-configured yet).
func TestEggViabilitySiteSurvivesByDefault(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	site := w.Resources.Count
	w.Resources.TypeID[site] = world.ResourceTypeOvipositionSite
	w.Resources.MaxLevel[site] = 5
	w.Resources.Level[site] = 1
	w.Resources.Count++

	eggs := w.Eggs
	eggs.Count = 1
	eggs.CarrierAgentIdx[0] = -1
	eggs.CarrierResourceIdx[0] = int32(site)

	reg, eval, envBuilder := eggViabilityCtx(w)
	died := EvaluateEggViability(w, reg, eval, envBuilder)
	if died != 0 {
		t.Fatalf("expected site egg to survive, got %d died", died)
	}
	if w.Eggs.Count != 1 {
		t.Fatalf("expected 1 egg remaining, got %d", w.Eggs.Count)
	}
}

// TestCombineLogicPascalPrecedence verifies the four legacy combinations,
// respecting Pascal's and > or precedence.
func TestCombineLogicPascalPrecedence(t *testing.T) {
	// cases: cycles, reqs, conds, Y_O, Y_OR → want
	cases := []struct {
		cycles, reqs, conds bool
		yo, yor             bool
		want                bool
	}{
		// Y_O=T Y_OR=T : cycles AND reqs AND conds
		{true, true, true, true, true, true},
		{true, false, true, true, true, false},
		// Y_O=F Y_OR=T : cycles OR (reqs AND conds)
		{false, true, true, false, true, true},
		{false, true, false, false, true, false}, // reqs&&conds=false, cycles=false → false
		{true, false, false, false, true, true},  // cycles=true → true
		// Y_O=T Y_OR=F : (cycles AND reqs) OR conds
		{false, false, true, true, false, true},  // conds=true → true
		{true, true, false, true, false, true},   // cycles&&reqs=true → true
		{true, false, false, true, false, false}, // both branches false
		// Y_O=F Y_OR=F : cycles OR reqs OR conds
		{false, false, false, false, false, false},
		{false, false, true, false, false, true},
	}
	for i, c := range cases {
		got := combineLogic(c.cycles, c.reqs, c.conds, c.yo, c.yor)
		if got != c.want {
			t.Errorf("case %d: combineLogic(%v,%v,%v, yo=%v yor=%v) = %v, want %v",
				i, c.cycles, c.reqs, c.conds, c.yo, c.yor, got, c.want)
		}
	}
}

// TestEvalLogicOperators verifies the legacy comparison operators, including
// the unknown-operator fallback to equality.
func TestEvalLogicOperators(t *testing.T) {
	cases := []struct {
		v1   float64
		op   string
		v2   float64
		want bool
	}{
		{5, "=", 5, true}, {5, "=", 6, false},
		{5, "<>", 6, true}, {5, "<>", 5, false},
		{4, "<", 5, true}, {5, "<", 5, false},
		{6, ">", 5, true}, {5, ">", 5, false},
		{5, "<=", 5, true}, {6, "<=", 5, false},
		{5, ">=", 5, true}, {4, ">=", 5, false},
		{5, "=<", 5, true}, {5, "=>", 5, true},
		{5, "??", 5, true}, {5, "??", 6, false}, // unknown → equality
	}
	for i, c := range cases {
		if got := evalLogic(c.v1, c.op, c.v2); got != c.want {
			t.Errorf("case %d: evalLogic(%v,%q,%v) = %v, want %v", i, c.v1, c.op, c.v2, got, c.want)
		}
	}
}

// TestStageTransitionCustomConditionBlocks verifies a custom condition can
// gate a stage transition: with cycles+reqs met but the condition failing
// (combined via AND), the agent does not transition; when it passes, it does.
func TestStageTransitionCustomConditionBlocks(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	reg := formulas.NewRegistry()
	eval := formulas.NewEvaluator(32)
	env := formulas.NewEnvBuilder(eval, cfg)
	// Condition formula: the agent's Age. We'll compare Age > 100.
	_ = reg.Compile("stage.0.cond1", "Age")

	ontCfg := OntogenyConfig{
		NumStages:      2,
		NumPrototypesM: 1,
		NumPrototypesF: 1,
		Stages: []StageConfig{
			{
				CyclesRequired:  5,
				NutrientReqs:    []int32{0, 0},
				NutrientCosts:   []int32{0, 0},
				Condition1Key:   "stage.0.cond1",
				Condition1Op:    ">",
				Condition1Value: 100,
				LogicCyclesReqs: true, // cycles AND reqs
				LogicReqsConds:  true, // ... AND conds
				LogicCond1Cond2: true,
				LinkedPrototype: -1,
			},
			{LinkedPrototype: -1},
		},
		AssignmentPriorityM: []int{0},
		AssignmentPriorityF: []int{0},
		Registry:            reg,
		Eval:                eval,
		EnvBuilder:          env,
	}

	idx := w.AddAgent()
	a := w.Agents
	a.StageID[idx] = 0
	a.TimeInStage[idx] = 10 // cycles met
	a.Age[idx] = 50         // condition Age > 100 → FALSE

	if EvaluateStageTransition(w, idx, ontCfg) {
		t.Fatal("should not transition: custom condition (Age>100) fails and logic is AND")
	}

	// Now make the condition pass.
	a.Age[idx] = 150
	if !EvaluateStageTransition(w, idx, ontCfg) {
		t.Fatal("should transition: custom condition (Age>100) now passes")
	}
}

// TestAssignPrototypeUsesCriteria verifies prototype assignment evaluates the
// criteria in priority order and picks the first prototype whose criterion
// passes, mirroring the legacy PrototipoAsignado.
func TestAssignPrototypeUsesCriteria(t *testing.T) {
	cfg := testCfg()
	cfg.NumPrototypesM = 2 // Two male prototypes so criteria are evaluated.
	w := world.New(cfg)

	reg := formulas.NewRegistry()
	eval := formulas.NewEvaluator(32)
	env := formulas.NewEnvBuilder(eval, cfg)
	// Prototype 0 criterion: Age > 100. Prototype 1 criterion: Age > 0.
	_ = reg.Compile("assign.M.0", "Age")
	_ = reg.Compile("assign.M.1", "Age")

	ontCfg := OntogenyConfig{
		NumStages:           1,
		NumPrototypesM:      2,
		NumPrototypesF:      1,
		AssignmentPriorityM: []int{0, 1}, // evaluate proto 0 first, then 1
		AssignmentCriteriaM: []AssignmentCriterion{
			{Key: "assign.M.0", Op: ">", Threshold: 100},
			{Key: "assign.M.1", Op: ">", Threshold: 0},
		},
		AssignmentPriorityF: []int{0},
		Registry:            reg,
		Eval:                eval,
		EnvBuilder:          env,
	}

	idx := w.AddAgent()
	a := w.Agents
	a.Sex[idx] = world.SexMale

	// Age 50: proto 0 (Age>100) fails, proto 1 (Age>0) passes → expect 1.
	a.Age[idx] = 50
	if got := AssignPrototype(w, idx, ontCfg); got != 1 {
		t.Fatalf("Age=50: expected prototype 1, got %d", got)
	}

	// Age 150: proto 0 (Age>100) passes first → expect 0 (short-circuit).
	a.Age[idx] = 150
	if got := AssignPrototype(w, idx, ontCfg); got != 0 {
		t.Fatalf("Age=150: expected prototype 0, got %d", got)
	}
}

// linkedStagesCfg builds an OntogenyConfig with prototype-linked stage branches
// for a male with two prototypes. Stage layout (NumStages=3):
//
//	stage 0: unlinked (the starting immature stage)
//	stage 1: linked to male prototype 0  (unified index NumStages+0 = 3)
//	stage 2: linked to male prototype 1  (unified index NumStages+1 = 4)
//
// The agent's assigned prototype (chosen by the criteria) selects which branch
// it takes out of stage 0.
func linkedStagesCfg(cfg world.Config, reg *formulas.Registry, eval *formulas.Evaluator, env *formulas.EnvBuilder) OntogenyConfig {
	numStages := 3
	return OntogenyConfig{
		NumStages:      numStages,
		NumPrototypesM: 2,
		NumPrototypesF: 1,
		Stages: []StageConfig{
			{CyclesRequired: 1, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{0, 0}, LogicCyclesReqs: true, LogicReqsConds: false, LinkedPrototype: -1},
			{CyclesRequired: 1, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{0, 0}, LogicCyclesReqs: true, LogicReqsConds: false, LinkedPrototype: numStages + 0},
			{CyclesRequired: 1, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{0, 0}, LogicCyclesReqs: true, LogicReqsConds: false, LinkedPrototype: numStages + 1},
		},
		AssignmentPriorityM: []int{0, 1},
		AssignmentCriteriaM: []AssignmentCriterion{
			{Key: "assign.M.0", Op: ">", Threshold: 100}, // proto 0 if Age > 100
			{Key: "assign.M.1", Op: ">", Threshold: 0},   // else proto 1 (Age > 0)
		},
		AssignmentPriorityF: []int{0},
		Registry:            reg,
		Eval:                eval,
		EnvBuilder:          env,
	}
}

// TestNextStageLinkedBranchSelected verifies an agent takes the stage branch
// linked to its assigned prototype.
func TestNextStageLinkedBranchSelected(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	reg := formulas.NewRegistry()
	eval := formulas.NewEvaluator(32)
	env := formulas.NewEnvBuilder(eval, cfg)
	_ = reg.Compile("assign.M.0", "Age")
	_ = reg.Compile("assign.M.1", "Age")
	ontCfg := linkedStagesCfg(cfg, reg, eval, env)

	idx := w.AddAgent()
	a := w.Agents
	a.Sex[idx] = world.SexMale
	a.StageID[idx] = 0
	a.TimeInStage[idx] = 5 // meets stage 0's cycle requirement

	// Age 50: proto 0 (Age>100) fails, proto 1 (Age>0) passes → assigned proto 1
	// → its linked branch is stage 2.
	a.Age[idx] = 50
	if !EvaluateStageTransition(w, idx, ontCfg) {
		t.Fatal("expected a transition")
	}
	if a.StageID[idx] != 2 {
		t.Fatalf("expected branch to stage 2 (proto 1), got stage %d", a.StageID[idx])
	}
}

// TestNextStageLinkedBranchOther verifies the other prototype selects the other
// branch (first-match selection).
func TestNextStageLinkedBranchOther(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	reg := formulas.NewRegistry()
	eval := formulas.NewEvaluator(32)
	env := formulas.NewEnvBuilder(eval, cfg)
	_ = reg.Compile("assign.M.0", "Age")
	_ = reg.Compile("assign.M.1", "Age")
	ontCfg := linkedStagesCfg(cfg, reg, eval, env)

	idx := w.AddAgent()
	a := w.Agents
	a.Sex[idx] = world.SexMale
	a.StageID[idx] = 0
	a.TimeInStage[idx] = 5

	// Age 150: proto 0 (Age>100) passes → assigned proto 0 → branch is stage 1.
	a.Age[idx] = 150
	if !EvaluateStageTransition(w, idx, ontCfg) {
		t.Fatal("expected a transition")
	}
	if a.StageID[idx] != 1 {
		t.Fatalf("expected branch to stage 1 (proto 0), got stage %d", a.StageID[idx])
	}
}

// TestNextStageUnlinkedLinearAdvance verifies that when the next stage is not
// prototype-linked, the agent advances linearly regardless of prototype.
func TestNextStageUnlinkedLinearAdvance(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	reg := formulas.NewRegistry()
	eval := formulas.NewEvaluator(32)
	env := formulas.NewEnvBuilder(eval, cfg)
	ontCfg := OntogenyConfig{
		NumStages:      3,
		NumPrototypesM: 1,
		NumPrototypesF: 1,
		Stages: []StageConfig{
			{CyclesRequired: 1, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{0, 0}, LogicCyclesReqs: true, LinkedPrototype: -1},
			{CyclesRequired: 1, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{0, 0}, LogicCyclesReqs: true, LinkedPrototype: -1},
			{CyclesRequired: 1, NutrientReqs: []int32{0, 0}, NutrientCosts: []int32{0, 0}, LogicCyclesReqs: true, LinkedPrototype: -1},
		},
		AssignmentPriorityM: []int{0},
		AssignmentPriorityF: []int{0},
		Registry:            reg,
		Eval:                eval,
		EnvBuilder:          env,
	}

	idx := w.AddAgent()
	a := w.Agents
	a.Sex[idx] = world.SexMale
	a.StageID[idx] = 0
	a.TimeInStage[idx] = 5

	if !EvaluateStageTransition(w, idx, ontCfg) {
		t.Fatal("expected a transition")
	}
	if a.StageID[idx] != 1 {
		t.Fatalf("expected linear advance to stage 1, got %d", a.StageID[idx])
	}
}
