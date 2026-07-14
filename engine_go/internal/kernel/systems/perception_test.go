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
	Perceive(ctx, idx)

	// The resource is directly north, so the forward (N) tendency should be highest.
	tendBase := idx * 8
	forwardTendency := w.Agents.Tendencies[tendBase+DirN]
	if forwardTendency <= 0 {
		t.Fatalf("expected positive forward tendency towards resource, got %d", forwardTendency)
	}

	// VDecision for feed behavior (index 2 + resourceType 0 = 2) should be positive.
	vdBase := idx * cfg.NumBehaviors
	feedWeight := w.Agents.VDecision[vdBase+2]
	if feedWeight <= 0 {
		t.Fatalf("expected positive feed VDecision, got %d", feedWeight)
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

	// Fight behaviors should have weight (contender detected).
	vdBase := idx0 * cfg.NumBehaviors
	fightDisplayIdx := 2 + cfg.NumResourceTypes // = 4
	if w.Agents.VDecision[vdBase+fightDisplayIdx] <= 0 {
		t.Fatalf("expected positive fight_display weight, got %d", w.Agents.VDecision[vdBase+fightDisplayIdx])
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

	// Courtship behaviors should have weight.
	vdBase := idx0 * cfg.NumBehaviors
	courtDisplayIdx := 2 + cfg.NumResourceTypes + 2 // = 6
	if w.Agents.VDecision[vdBase+courtDisplayIdx] <= 0 {
		t.Fatalf("expected positive court_display weight, got %d", w.Agents.VDecision[vdBase+courtDisplayIdx])
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
		dx, dy := directionDelta(tc.dir)
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
