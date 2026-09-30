package systems

import (
	"testing"

	"galatea/engine/internal/kernel/formulas"
	"galatea/engine/internal/kernel/spatial"
	"galatea/engine/internal/kernel/world"
)

func testCfg() world.Config {
	return world.Config{
		NumNutrients:     2,
		NumLoci:          2,
		NumCharacters:    2,
		NumStages:        1,
		NumPrototypesM:   1,
		NumPrototypesF:   1,
		NumPrototypes:    3, // 1 stage + 1M + 1F
		NumResourceTypes: 2,
		NumSubstrates:    3,
		NumBehaviors:     12,
		NumDirections:    8,
		GridWidth:        50,
		GridHeight:       50,
		InitialCapacity:  32,
	}
}

func setupPerceptionContext(w *world.World) *PerceptionContext {
	cfg := w.Config

	agentGrid := spatial.NewGrid(15.0, cfg.InitialCapacity)
	resourceGrid := spatial.NewGrid(15.0, 64)

	// Build agent grid.
	for i := 0; i < w.Agents.Count; i++ {
		agentGrid.Insert(int32(i), w.Agents.PosX[i], w.Agents.PosY[i])
	}
	// Build resource grid.
	for i := 0; i < w.Resources.Count; i++ {
		resourceGrid.Insert(int32(i), w.Resources.PosX[i], w.Resources.PosY[i])
	}

	reg := formulas.NewRegistry()
	eval := formulas.NewEvaluator(128)
	envBuilder := formulas.NewEnvBuilder(eval, cfg)

	// Set up radii: all resource types have radius 10 for all perceivers.
	numRadii := cfg.NumResourceTypes * cfg.NumPrototypes
	resourceRadii := make([]float64, numRadii)
	resourceAttr := make([]int32, numRadii)
	for i := range resourceRadii {
		resourceRadii[i] = 10.0
		resourceAttr[i] = 10
	}

	// Agent radii: all agent types perceive each other at radius 10.
	agentRadii := make([]float64, cfg.NumPrototypes*cfg.NumPrototypes)
	for i := range agentRadii {
		agentRadii[i] = 10.0
	}

	return &PerceptionContext{
		World:         w,
		AgentGrid:     agentGrid,
		ResourceGrid:  resourceGrid,
		Formulas:      reg,
		Eval:          eval,
		EnvBuilder:    envBuilder,
		ResourceRadii: resourceRadii,
		ResourceAttr:  resourceAttr,
		AgentRadii:    agentRadii,
	}
}

func TestPerceiveResourceAccumulatesTendency(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Place a resource to the north of the agent (25, 20).
	w.Resources.PosX[0] = 25
	w.Resources.PosY[0] = 20
	w.Resources.TypeID[0] = 0
	w.Resources.Level[0] = 50
	w.Resources.Quality[0] = 10
	w.Resources.Count = 1

	// Place an agent at (25, 25) facing North (direction=2).
	idx := w.AddAgent()
	w.Agents.PosX[idx] = 25
	w.Agents.PosY[idx] = 25
	w.Agents.Direction[idx] = 2 // North
	w.Agents.Speed[idx] = 1
	w.Agents.StageID[idx] = 0
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 50

	ctx := setupPerceptionContext(w)

	// Configure the source-interaction matrix so that perceiving this resource
	// (type 0) contributes weight to the Feed_0 behavior (index 2) for the
	// perceiver (stage index 0). This is the legacy model: the behavior weight
	// comes from the interaction matrix, not from attractiveness (which only
	// drives directional tendency).
	feedBehavior := behaviorOffsetFeed + 0 // Feed for resource type 0.
	if err := ctx.Formulas.Compile(
		InteractionKeySource(0, 0, feedBehavior), "7"); err != nil {
		t.Fatalf("compile source interaction: %v", err)
	}

	Perceive(ctx, idx)

	// The resource is directly north, so the forward (N) tendency should be highest.
	tendBase := idx * 8
	forwardTendency := w.Agents.Tendencies[tendBase+DirN]
	if forwardTendency <= 0 {
		t.Fatalf("expected positive forward tendency towards resource, got %d", forwardTendency)
	}

	// VDecision for the feed behavior reflects the interaction-matrix formula,
	// AVERAGED over all perceived elements (legacy PromediaProbaDecision): the
	// current substrate contributes 0 (no configured cell) and the source
	// contributes 7, so the average is (0 + 7) / 2 = 3.
	vdBase := idx * cfg.NumBehaviors
	feedWeight := w.Agents.VDecision[vdBase+feedBehavior]
	if feedWeight != 3 {
		t.Fatalf("expected feed VDecision = 3 (avg of substrate 0 and source 7), got %d", feedWeight)
	}
}

// TestDetectionBoostRequiresBaseWeight verifies the fix for "the game of the
// enchanted": detecting a contiguous contender adds fight weight ONLY when the
// agent already has a positive configured fight weight. With no configured
// combat tendency (the default), detection adds nothing, so agents never enter
// spontaneous combat on contact.
func TestDetectionBoostRequiresBaseWeight(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	idx := w.AddAgent()
	w.Agents.Sex[idx] = world.SexMale
	vdBase := idx * cfg.NumBehaviors
	fightDisplayIdx := 2 + cfg.NumResourceTypes

	// Case 1: no base fight weight -> detection adds nothing.
	for b := 0; b < cfg.NumBehaviors; b++ {
		w.Agents.VDecision[vdBase+b] = 0
	}
	applyAgentDetectionBoosts(w.Agents, idx, cfg, true /*hasContender*/, false)
	if w.Agents.VDecision[vdBase+fightDisplayIdx] != 0 {
		t.Fatalf("expected no fight weight without base config, got %d",
			w.Agents.VDecision[vdBase+fightDisplayIdx])
	}

	// Case 2: a positive base fight weight -> detection reinforces it.
	w.Agents.VDecision[vdBase+fightDisplayIdx] = 2
	applyAgentDetectionBoosts(w.Agents, idx, cfg, true /*hasContender*/, false)
	if w.Agents.VDecision[vdBase+fightDisplayIdx] <= 2 {
		t.Fatalf("expected fight weight reinforced above base, got %d",
			w.Agents.VDecision[vdBase+fightDisplayIdx])
	}
}

func TestPerceiveAgentDetectsContender(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Agent 0: male adult at (25, 25).
	idx0 := w.AddAgent()
	w.Agents.PosX[idx0] = 25
	w.Agents.PosY[idx0] = 25
	w.Agents.Direction[idx0] = 2
	w.Agents.Speed[idx0] = 1
	w.Agents.Sex[idx0] = world.SexMale
	w.Agents.StageID[idx0] = -1
	w.Agents.PrototypeID[idx0] = 0
	w.Agents.Situation[idx0] = world.SituationRegular
	w.Agents.Reserves[idx0*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx0*cfg.NumNutrients+1] = 50

	// Agent 1: male adult at (26, 25) — contiguous.
	idx1 := w.AddAgent()
	w.Agents.PosX[idx1] = 26
	w.Agents.PosY[idx1] = 25
	w.Agents.Direction[idx1] = 2
	w.Agents.Speed[idx1] = 1
	w.Agents.Sex[idx1] = world.SexMale
	w.Agents.StageID[idx1] = -1
	w.Agents.PrototypeID[idx1] = 0
	w.Agents.Situation[idx1] = world.SituationRegular
	w.Agents.Reserves[idx1*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx1*cfg.NumNutrients+1] = 50

	ctx := setupPerceptionContext(w)
	Perceive(ctx, idx0)

	// With no configured combat tendency, detecting a contender must NOT
	// inject fight weight (fix for the "enchanted" bug).
	vdBase := idx0 * cfg.NumBehaviors
	fightDisplayIdx := 2 + cfg.NumResourceTypes // = 4
	if w.Agents.VDecision[vdBase+fightDisplayIdx] != 0 {
		t.Fatalf("expected zero fight_display weight without config, got %d", w.Agents.VDecision[vdBase+fightDisplayIdx])
	}
}

func TestPerceiveAgentDetectsMate(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Agent 0: male adult.
	idx0 := w.AddAgent()
	w.Agents.PosX[idx0] = 25
	w.Agents.PosY[idx0] = 25
	w.Agents.Direction[idx0] = 2
	w.Agents.Speed[idx0] = 1
	w.Agents.Sex[idx0] = world.SexMale
	w.Agents.StageID[idx0] = -1
	w.Agents.PrototypeID[idx0] = 0
	w.Agents.Situation[idx0] = world.SituationRegular
	w.Agents.Reserves[idx0*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx0*cfg.NumNutrients+1] = 50

	// Agent 1: female adult nearby.
	idx1 := w.AddAgent()
	w.Agents.PosX[idx1] = 26
	w.Agents.PosY[idx1] = 25
	w.Agents.Direction[idx1] = 2
	w.Agents.Speed[idx1] = 1
	w.Agents.Sex[idx1] = world.SexFemale
	w.Agents.StageID[idx1] = -1
	w.Agents.PrototypeID[idx1] = 0
	w.Agents.Situation[idx1] = world.SituationRegular
	w.Agents.Reserves[idx1*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx1*cfg.NumNutrients+1] = 50

	ctx := setupPerceptionContext(w)
	Perceive(ctx, idx0)

	// With no configured courtship tendency, detecting a mate must NOT inject
	// courtship weight (fix for the "enchanted" bug — applies to courtship too).
	vdBase := idx0 * cfg.NumBehaviors
	courtDisplayIdx := 2 + cfg.NumResourceTypes + 2 // = 6
	if w.Agents.VDecision[vdBase+courtDisplayIdx] != 0 {
		t.Fatalf("expected zero court_display weight without config, got %d", w.Agents.VDecision[vdBase+courtDisplayIdx])
	}
}

// TestPerceiveAgentNoAttractionByDefault verifies that with no configured
// agent attractiveness (AgentAttr nil/zero), a nearby agent contributes ZERO
// movement tendency toward itself. This guards the clumping bug where a
// hardcoded positive attractiveness made agents stick together with defaults.
func TestPerceiveAgentNoAttractionByDefault(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Agent 0 facing north at (25, 25).
	idx0 := w.AddAgent()
	w.Agents.PosX[idx0] = 25
	w.Agents.PosY[idx0] = 25
	w.Agents.Direction[idx0] = 2
	w.Agents.Speed[idx0] = 1
	w.Agents.Sex[idx0] = world.SexMale
	w.Agents.StageID[idx0] = -1
	w.Agents.PrototypeID[idx0] = 0
	w.Agents.Situation[idx0] = world.SituationRegular
	w.Agents.Reserves[idx0*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx0*cfg.NumNutrients+1] = 50

	// Agent 1 nearby.
	idx1 := w.AddAgent()
	w.Agents.PosX[idx1] = 27
	w.Agents.PosY[idx1] = 25
	w.Agents.Direction[idx1] = 2
	w.Agents.Speed[idx1] = 1
	w.Agents.Sex[idx1] = world.SexMale
	w.Agents.StageID[idx1] = -1
	w.Agents.PrototypeID[idx1] = 0
	w.Agents.Situation[idx1] = world.SituationRegular
	w.Agents.Reserves[idx1*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx1*cfg.NumNutrients+1] = 50

	ctx := setupPerceptionContext(w) // AgentAttr is nil -> no attraction.
	Perceive(ctx, idx0)

	// No resources, no base tendencies configured, no agent attraction:
	// all tendency slots contributed by perception must be zero. (Base
	// tendencies and boundary avoidance add later, but here the registry has
	// no tendency formulas, so perception+base contribute nothing except the
	// boundary-avoidance +1 which is uniform. We assert the perceived neighbor
	// did NOT bias any single direction toward it.)
	tendBase := idx0 * 8
	// The neighbor is due East. Without attraction, the East-ward tendency
	// must not exceed the others (no directional bias toward the neighbor).
	// With the old bug it would be strictly higher. We check it's uniform.
	first := w.Agents.Tendencies[tendBase]
	uniform := true
	for d := 1; d < 8; d++ {
		if w.Agents.Tendencies[tendBase+d] != first {
			uniform = false
			break
		}
	}
	if !uniform {
		t.Fatalf("expected uniform tendencies with no attraction, got %v",
			w.Agents.Tendencies[tendBase:tendBase+8])
	}
}

func TestFilterDisablesOvipositForMale(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.PosX[idx] = 25
	w.Agents.PosY[idx] = 25
	w.Agents.Direction[idx] = 2
	w.Agents.Speed[idx] = 1
	w.Agents.Sex[idx] = world.SexMale
	w.Agents.StageID[idx] = -1
	w.Agents.PrototypeID[idx] = 0
	w.Agents.Situation[idx] = world.SituationRegular
	// Give reserves so not critical.
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 50

	ctx := setupPerceptionContext(w)

	// Manually set oviposit weight high.
	ovipositIdx := 2 + cfg.NumResourceTypes + 4
	vdBase := idx * cfg.NumBehaviors
	w.Agents.VDecision[vdBase+ovipositIdx] = 100

	applyFilters(ctx, idx)

	// Should be zeroed for males.
	if w.Agents.VDecision[vdBase+ovipositIdx] != 0 {
		t.Fatalf("expected oviposit zeroed for male, got %d", w.Agents.VDecision[vdBase+ovipositIdx])
	}
}

func TestBoundaryAvoidance(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Place agent at left boundary facing West.
	idx := w.AddAgent()
	w.Agents.PosX[idx] = 0
	w.Agents.PosY[idx] = 25
	w.Agents.Direction[idx] = 4 // West
	w.Agents.Speed[idx] = 1
	w.Agents.StageID[idx] = 0

	// Set all tendencies to 10.
	tendBase := idx * 8
	for d := 0; d < 8; d++ {
		w.Agents.Tendencies[tendBase+d] = 10
	}

	ctx := setupPerceptionContext(w)
	applyBoundaryAvoidance(ctx, idx)

	// Some tendencies pointing left (west) should be zeroed.
	// When facing West, forward (N relative) = West absolute.
	// Movements that go further left (X<0) should be blocked.
	hasZero := false
	for d := 0; d < 8; d++ {
		if w.Agents.Tendencies[tendBase+d] == 0 {
			hasZero = true
			break
		}
	}
	if !hasZero {
		t.Fatal("expected at least one tendency zeroed at boundary")
	}
}

func TestEnsureNonZeroDecision(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	// All VDecision are zero by default from AddAgent.

	ctx := setupPerceptionContext(w)
	ensureNonZeroDecision(ctx, idx)

	// Movement (index 0) should be forced to 1.
	vdBase := idx * cfg.NumBehaviors
	if w.Agents.VDecision[vdBase+0] != 1 {
		t.Fatalf("expected VDecision[0]=1 (forced move), got %d", w.Agents.VDecision[vdBase+0])
	}
}

func TestDirectionHelpers(t *testing.T) {
	// Agent facing North (2), target directly east: should be DirE (right).
	dir := relativeDirection(2, 10, 10, 20, 10)
	if dir != DirE {
		t.Fatalf("target east of north-facing agent: expected DirE(%d), got %d", DirE, dir)
	}

	// Agent facing North, target directly north: should be DirN (forward).
	dir = relativeDirection(2, 10, 10, 10, 0)
	if dir != DirN {
		t.Fatalf("target north of north-facing agent: expected DirN(%d), got %d", DirN, dir)
	}

	// Agent facing East (5), target directly north: should be DirW (left).
	dir = relativeDirection(5, 10, 10, 10, 0)
	if dir != DirW {
		t.Fatalf("target north of east-facing agent: expected DirW(%d), got %d", DirW, dir)
	}

	// Overlap: should return -1.
	dir = relativeDirection(2, 10, 10, 10, 10)
	if dir != -1 {
		t.Fatalf("overlap: expected -1, got %d", dir)
	}
}

func TestDirectionDelta(t *testing.T) {
	cases := []struct {
		dir    uint8
		dx, dy int
	}{
		{1, -1, -1}, // NW
		{2, 0, -1},  // N
		{3, 1, -1},  // NE
		{4, -1, 0},  // W
		{5, 1, 0},   // E
		{6, -1, 1},  // SW
		{7, 0, 1},   // S
		{8, 1, 1},   // SE
	}
	for _, tc := range cases {
		dx := dirDeltaX[tc.dir]
		dy := dirDeltaY[tc.dir]
		if dx != tc.dx || dy != tc.dy {
			t.Fatalf("dir %d: expected (%d,%d), got (%d,%d)", tc.dir, tc.dx, tc.dy, dx, dy)
		}
	}
}

func TestFullPerceiveNoResources(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Single agent, no resources, no other agents.
	idx := w.AddAgent()
	w.Agents.PosX[idx] = 25
	w.Agents.PosY[idx] = 25
	w.Agents.Direction[idx] = 2
	w.Agents.Speed[idx] = 1
	w.Agents.StageID[idx] = 0
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 50

	ctx := setupPerceptionContext(w)
	Perceive(ctx, idx)

	// With no elements perceived, VDecision[0] (move) should be forced to 1.
	vdBase := idx * cfg.NumBehaviors
	if w.Agents.VDecision[vdBase+0] != 1 {
		t.Fatalf("expected move forced to 1, got %d", w.Agents.VDecision[vdBase+0])
	}
}

// TestInteractionAgentMatrixModulatesVDecision verifies that perceiving another
// agent contributes to VDecision through the agent-interaction matrix (legacy
// MatrizAgentes → PromediaProbaDecision), for the specific behavior configured.
func TestInteractionAgentMatrixModulatesVDecision(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	// Perceiver at (25,25), adult stage index 0.
	self := w.AddAgent()
	w.Agents.PosX[self] = 25
	w.Agents.PosY[self] = 25
	w.Agents.Direction[self] = 2
	w.Agents.StageID[self] = 0
	w.Agents.Reserves[self*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[self*cfg.NumNutrients+1] = 50

	// Observed agent nearby, also stage index 0.
	other := w.AddAgent()
	w.Agents.PosX[other] = 26
	w.Agents.PosY[other] = 25
	w.Agents.StageID[other] = 0

	ctx := setupPerceptionContext(w)

	// Configure the agent-interaction matrix: observed 0, perceiver 0, behavior
	// Fight_Attack contributes 10. fightAttack index = 2 + NumResourceTypes.
	fightAttack := behaviorOffsetFeed + cfg.NumResourceTypes
	if err := ctx.Formulas.Compile(
		InteractionKeyAgent(0, 0, fightAttack), "10"); err != nil {
		t.Fatalf("compile agent interaction: %v", err)
	}

	Perceive(ctx, self)

	// The perceiver perceives: its substrate (contributes 0 to fightAttack) and
	// one agent (contributes 10). Average = (0 + 10) / 2 = 5.
	vdBase := self * cfg.NumBehaviors
	got := w.Agents.VDecision[vdBase+fightAttack]
	if got != 5 {
		t.Fatalf("expected Fight_Attack VDecision = 5 (avg of substrate 0 and agent 10), got %d", got)
	}
}

// TestInteractionMatrixUsesContenderVars verifies interaction formulas can read
// the observed agent's variables (Contender*), so behavior can depend on who is
// perceived — a core capability of the legacy matrices.
func TestInteractionMatrixUsesContenderVars(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	self := w.AddAgent()
	w.Agents.PosX[self] = 25
	w.Agents.PosY[self] = 25
	w.Agents.StageID[self] = 0
	w.Agents.Reserves[self*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[self*cfg.NumNutrients+1] = 50

	// Observed male agent → ContenderIsMale should be true in the formula.
	other := w.AddAgent()
	w.Agents.PosX[other] = 26
	w.Agents.PosY[other] = 25
	w.Agents.StageID[other] = 0
	w.Agents.Sex[other] = world.SexMale

	ctx := setupPerceptionContext(w)

	// Formula: attack weight 20 if the observed agent is male, else 0.
	fightAttack := behaviorOffsetFeed + cfg.NumResourceTypes
	if err := ctx.Formulas.Compile(
		InteractionKeyAgent(0, 0, fightAttack), "If(ContenderIsMale, 20, 0)"); err != nil {
		t.Fatalf("compile: %v", err)
	}

	Perceive(ctx, self)

	// (substrate 0 + agent 20) / 2 = 10.
	vdBase := self * cfg.NumBehaviors
	got := w.Agents.VDecision[vdBase+fightAttack]
	if got != 10 {
		t.Fatalf("expected Fight_Attack = 10 (contender-dependent), got %d", got)
	}
}

// TestCourtshipRefractoryTriggeredByCopulation verifies the corrected legacy
// behavior: the courtship refractory is driven by an actual copulation
// (LastCopulation), disabling courtship for RefractoryCourtship ticks — and a
// non-copulating agent (LastCopulation == -1) is never blocked.
func TestCourtshipRefractoryTriggeredByCopulation(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.PosX[idx] = 25
	w.Agents.PosY[idx] = 25
	w.Agents.StageID[idx] = -1
	w.Agents.PrototypeID[idx] = 0
	w.Agents.Sex[idx] = world.SexMale
	w.Agents.Situation[idx] = world.SituationRegular
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 50
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 50

	courtDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 2

	ctx := setupPerceptionContext(w)
	ref := NewAgentRef(cfg.NumNutrients, cfg.NumBehaviors)
	ref.RefractoryCourtship = 10
	// Keep reserves above critical so the critical-reserve filter doesn't also
	// zero courtship (isolate the refractory effect).
	for n := range ref.CriticalReserves {
		ref.CriticalReserves[n] = 0
	}
	ctx.Ref = ref

	// Helper: run applyFilters with a fresh court display weight and report it.
	courtWeightAfterFilter := func() int32 {
		vdBase := idx * cfg.NumBehaviors
		w.Agents.VDecision[vdBase+courtDisplayIdx] = 100
		applyFilters(ctx, idx)
		return w.Agents.VDecision[vdBase+courtDisplayIdx]
	}

	// Never copulated → not blocked.
	w.Agents.LastCopulation[idx] = -1
	if got := courtWeightAfterFilter(); got == 0 {
		t.Fatal("agent that never copulated should not be in courtship refractory")
	}

	// Just copulated (0 < 10) → blocked.
	w.Agents.LastCopulation[idx] = 0
	if got := courtWeightAfterFilter(); got != 0 {
		t.Fatalf("just-copulated agent should be blocked, got weight %d", got)
	}

	// Copulated long ago (>= refractory) → not blocked.
	w.Agents.LastCopulation[idx] = 10
	if got := courtWeightAfterFilter(); got == 0 {
		t.Fatal("agent past the refractory period should court again")
	}
}
