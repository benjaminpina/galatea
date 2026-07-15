package world

import (
	"testing"

	"galatea/engine/internal/adapters/storage"
)

func testConfig() Config {
	return Config{
		ProjectName:      "Test",
		NumNutrients:     4,
		NumLoci:          5,
		NumStages:        2,
		NumPrototypesM:   2,
		NumPrototypesF:   2,
		NumPrototypes:    6, // 2 stages + 2M + 2F
		NumResourceTypes: 3,
		NumSubstrates:    7,
		NumBehaviors:     12,
		NumDirections:    8,
		GridWidth:        50,
		GridHeight:       50,
		InitialCapacity:  16,
	}
}

func TestNewWorld(t *testing.T) {
	cfg := testConfig()
	w := New(cfg)

	if w.Agents.Count != 0 {
		t.Fatalf("expected 0 agents, got %d", w.Agents.Count)
	}
	if w.Agents.Cap != 16 {
		t.Fatalf("expected cap=16, got %d", w.Agents.Cap)
	}
	if w.Substrates.Width != 50 || w.Substrates.Height != 50 {
		t.Fatalf("unexpected grid dimensions: %dx%d", w.Substrates.Width, w.Substrates.Height)
	}
	if w.Tick != 0 {
		t.Fatalf("expected tick=0, got %d", w.Tick)
	}
}

func TestAddAgent(t *testing.T) {
	cfg := testConfig()
	w := New(cfg)

	idx := w.AddAgent()
	if idx != 0 {
		t.Fatalf("expected idx=0, got %d", idx)
	}
	if w.Agents.Count != 1 {
		t.Fatalf("expected count=1, got %d", w.Agents.Count)
	}

	// Set some values.
	w.Agents.PosX[idx] = 10.5
	w.Agents.PosY[idx] = 20.5
	w.Agents.Sex[idx] = SexMale
	w.Agents.StageID[idx] = 0

	// Verify.
	if w.Agents.PosX[0] != 10.5 {
		t.Fatalf("expected PosX=10.5, got %f", w.Agents.PosX[0])
	}
}

func TestAddAgentGrow(t *testing.T) {
	cfg := testConfig()
	cfg.InitialCapacity = 4
	w := New(cfg)

	// Add more agents than initial capacity.
	for i := 0; i < 10; i++ {
		idx := w.AddAgent()
		w.Agents.PosX[idx] = float64(i * 10)
		w.Agents.Age[idx] = int32(i)
	}

	if w.Agents.Count != 10 {
		t.Fatalf("expected count=10, got %d", w.Agents.Count)
	}
	if w.Agents.Cap < 10 {
		t.Fatalf("expected cap>=10, got %d", w.Agents.Cap)
	}

	// Verify data integrity after growth.
	for i := 0; i < 10; i++ {
		if w.Agents.PosX[i] != float64(i*10) {
			t.Fatalf("agent %d: expected PosX=%f, got %f", i, float64(i*10), w.Agents.PosX[i])
		}
		if w.Agents.Age[i] != int32(i) {
			t.Fatalf("agent %d: expected Age=%d, got %d", i, i, w.Agents.Age[i])
		}
	}
}

func TestRemoveAgentSwapAndPop(t *testing.T) {
	cfg := testConfig()
	w := New(cfg)

	// Add 5 agents with distinct positions.
	for i := 0; i < 5; i++ {
		idx := w.AddAgent()
		w.Agents.PosX[idx] = float64(i + 1) // 1, 2, 3, 4, 5
		w.Agents.Age[idx] = int32(i * 10)   // 0, 10, 20, 30, 40
	}

	// Remove agent at index 1 (PosX=2). Last agent (PosX=5) should move to index 1.
	w.RemoveAgent(1)

	if w.Agents.Count != 4 {
		t.Fatalf("expected count=4, got %d", w.Agents.Count)
	}

	// Index 1 should now have the data from the former index 4.
	if w.Agents.PosX[1] != 5.0 {
		t.Fatalf("expected PosX[1]=5.0 after swap, got %f", w.Agents.PosX[1])
	}
	if w.Agents.Age[1] != 40 {
		t.Fatalf("expected Age[1]=40 after swap, got %d", w.Agents.Age[1])
	}

	// Other indices should be unchanged.
	if w.Agents.PosX[0] != 1.0 {
		t.Fatalf("expected PosX[0]=1.0, got %f", w.Agents.PosX[0])
	}
	if w.Agents.PosX[2] != 3.0 {
		t.Fatalf("expected PosX[2]=3.0, got %f", w.Agents.PosX[2])
	}
	if w.Agents.PosX[3] != 4.0 {
		t.Fatalf("expected PosX[3]=4.0, got %f", w.Agents.PosX[3])
	}
}

func TestRemoveLastAgent(t *testing.T) {
	cfg := testConfig()
	w := New(cfg)

	w.AddAgent()
	idx := w.AddAgent()
	w.Agents.PosX[idx] = 99.0

	// Remove the last agent (no swap needed).
	w.RemoveAgent(1)

	if w.Agents.Count != 1 {
		t.Fatalf("expected count=1, got %d", w.Agents.Count)
	}
	if w.Agents.PosX[0] != 0 {
		t.Fatalf("expected PosX[0]=0, got %f", w.Agents.PosX[0])
	}
}

func TestSubstrateMap(t *testing.T) {
	m := NewSubstrateMap(10, 10)

	m.Set(3, 5, 7)
	if m.Get(3, 5) != 7 {
		t.Fatalf("expected substrate 7 at (3,5), got %d", m.Get(3, 5))
	}

	m.Set(0, 0, 1)
	m.Set(9, 9, 2)
	if m.Get(0, 0) != 1 || m.Get(9, 9) != 2 {
		t.Fatal("boundary values incorrect")
	}
}

// --- Integration test: Load from DB ---

func setupTestDB(t *testing.T) *storage.DB {
	t.Helper()
	db, err := storage.OpenMemory()
	if err != nil {
		t.Fatalf("OpenMemory: %v", err)
	}
	t.Cleanup(func() { db.Close() })

	// Populate with a minimal project.
	projRepo := storage.NewProjectInfoRepo(db)
	projRepo.Init("LoadTest", "Testing the loader")

	nutRepo := storage.NewNutrientRepo(db)
	nutRepo.Create("Water", 0, 1)
	nutRepo.Create("Sugar", 0, 2)
	nutRepo.Create("Fat", 0, 3)
	nutRepo.Create("Protein", 0, 4)

	subRepo := storage.NewSubstrateRepo(db)
	for i := 1; i <= 5; i++ {
		subRepo.Create("Sub"+string(rune('A'+i-1)), 0x111111*i, false, i)
	}

	locRepo := storage.NewLocusRepo(db)
	for i := 1; i <= 3; i++ {
		locRepo.Create(&storage.Locus{
			Name: "Locus" + string(rune('0'+i)), IsContinuous: true,
			DominantValue: 1, RecessiveValue: 0.5,
			DefaultExpression: "0", SortOrder: i,
		})
	}

	stageRepo := storage.NewStageRepo(db)
	stageRepo.Create(&storage.Stage{
		Name: "Egg", SortOrder: 1, CyclesFormula: "50",
		Condition1Formula: "0", Condition1Op: ">", Condition1Value: 0,
		Condition2Formula: "0", Condition2Op: ">", Condition2Value: 0,
		LogicCyclesReqs: "AND", LogicReqsConds: "AND", LogicCond1Cond2: "AND", Color: 0,
	})
	stageRepo.Create(&storage.Stage{
		Name: "Larva", SortOrder: 2, CyclesFormula: "100",
		Condition1Formula: "0", Condition1Op: ">", Condition1Value: 0,
		Condition2Formula: "0", Condition2Op: ">", Condition2Value: 0,
		LogicCyclesReqs: "AND", LogicReqsConds: "AND", LogicCond1Cond2: "AND", Color: 0,
	})

	protoRepo := storage.NewPrototypeRepo(db)
	protoRepo.Create(&storage.Prototype{
		Name: "AlphaM", Sex: "M", LongevityFormula: "500",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "10",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})
	protoRepo.Create(&storage.Prototype{
		Name: "AlphaF", Sex: "F", LongevityFormula: "600",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "10",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})


	// Create environment.
	envRepo := storage.NewEnvironmentRepo(db)
	envID, _ := envRepo.Create("TestEnv", 20, 20, "")

	// Place resources.
	envRepo.PlaceSource(&storage.EnvironmentSource{
		EnvironmentID: envID, NutrientID: 1, Name: "spring1",
		PosX: 5, PosY: 5, Quality: 10, Level: 80, MaxLevel: 100, RegenRate: 1.1,
	})
	envRepo.PlaceSource(&storage.EnvironmentSource{
		EnvironmentID: envID, NutrientID: 2, Name: "flower1",
		PosX: 15, PosY: 15, Quality: 8, Level: 50, MaxLevel: 100, RegenRate: 1.2,
	})

	// Place agents.
	stageIDVal := int64(2) // Larva
	for i := 0; i < 10; i++ {
		envRepo.PlaceAgent(&storage.EnvironmentAgent{
			EnvironmentID: envID, Name: "agent" + string(rune('A'+i)),
			PosX: i * 2, PosY: i, StageID: &stageIDVal, Sex: "U", Age: i * 5,
		})
	}

	return db
}

func TestLoadWorld(t *testing.T) {
	db := setupTestDB(t)

	w, err := Load(db, 1)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}

	// Verify config.
	if w.Config.ProjectName != "LoadTest" {
		t.Fatalf("expected project name 'LoadTest', got %q", w.Config.ProjectName)
	}
	if w.Config.NumNutrients != 4 {
		t.Fatalf("expected 4 nutrients, got %d", w.Config.NumNutrients)
	}
	if w.Config.NumLoci != 3 {
		t.Fatalf("expected 3 loci, got %d", w.Config.NumLoci)
	}
	if w.Config.NumStages != 2 {
		t.Fatalf("expected 2 stages, got %d", w.Config.NumStages)
	}
	if w.Config.NumPrototypesM != 1 {
		t.Fatalf("expected 1 male prototype, got %d", w.Config.NumPrototypesM)
	}
	if w.Config.NumPrototypesF != 1 {
		t.Fatalf("expected 1 female prototype, got %d", w.Config.NumPrototypesF)
	}
	if w.Config.NumResourceTypes != 4 {
		t.Fatalf("expected 4 resource types, got %d", w.Config.NumResourceTypes)
	}
	if w.Config.GridWidth != 20 || w.Config.GridHeight != 20 {
		t.Fatalf("expected 20x20 grid, got %dx%d", w.Config.GridWidth, w.Config.GridHeight)
	}

	// Verify resources loaded.
	if w.Resources.Count != 2 {
		t.Fatalf("expected 2 resources, got %d", w.Resources.Count)
	}
	if w.Resources.PosX[0] != 5 || w.Resources.PosY[0] != 5 {
		t.Fatalf("resource 0 position incorrect: (%f,%f)", w.Resources.PosX[0], w.Resources.PosY[0])
	}
	if w.Resources.Level[0] != 80 {
		t.Fatalf("expected resource 0 level=80, got %d", w.Resources.Level[0])
	}

	// Verify agents loaded.
	if w.Agents.Count != 10 {
		t.Fatalf("expected 10 agents, got %d", w.Agents.Count)
	}
	// Verify first agent.
	if w.Agents.PosX[0] != 0 || w.Agents.PosY[0] != 0 {
		t.Fatalf("agent 0 position incorrect: (%f,%f)", w.Agents.PosX[0], w.Agents.PosY[0])
	}
	if w.Agents.Age[0] != 0 {
		t.Fatalf("expected agent 0 age=0, got %d", w.Agents.Age[0])
	}
	if w.Agents.Situation[0] != SituationImmature {
		t.Fatalf("expected agent 0 situation=Immature, got %d", w.Agents.Situation[0])
	}
	// Verify last agent.
	if w.Agents.PosX[9] != 18 || w.Agents.PosY[9] != 9 {
		t.Fatalf("agent 9 position incorrect: (%f,%f)", w.Agents.PosX[9], w.Agents.PosY[9])
	}
	if w.Agents.Age[9] != 45 {
		t.Fatalf("expected agent 9 age=45, got %d", w.Agents.Age[9])
	}
}
