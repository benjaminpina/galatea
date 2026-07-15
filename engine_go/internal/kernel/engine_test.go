package kernel

import (
	"context"
	"testing"
	"time"

	"galatea/engine/internal/adapters/storage"
)

// setupTestDB creates an in-memory DB with a minimal but complete project.
func setupTestDB(t *testing.T) *storage.DB {
	t.Helper()
	db, err := storage.OpenMemory()
	if err != nil {
		t.Fatalf("OpenMemory: %v", err)
	}

	projRepo := storage.NewProjectInfoRepo(db)
	projRepo.Init("EngineTest", "Integration test project")

	nutRepo := storage.NewNutrientRepo(db)
	nutRepo.Create("Water", 0, 1)
	nutRepo.Create("Sugar", 0, 2)

	subRepo := storage.NewSubstrateRepo(db)
	subRepo.Create("Grass", 0x00FF00, false, 1)
	subRepo.Create("Sand", 0xFFFF00, false, 2)
	subRepo.Create("Rock", 0x808080, false, 3)

	locRepo := storage.NewLocusRepo(db)
	locRepo.Create(&storage.Locus{Name: "Size", IsContinuous: true, DominantValue: 1, RecessiveValue: 0.5, SortOrder: 1, DefaultExpression: "0"})
	locRepo.Create(&storage.Locus{Name: "Speed", IsContinuous: true, DominantValue: 1, RecessiveValue: 0.5, SortOrder: 2, DefaultExpression: "0"})

	stageRepo := storage.NewStageRepo(db)
	stageRepo.Create(&storage.Stage{
		Name: "Larva", SortOrder: 1, CyclesFormula: "50",
		Condition1Formula: "0", Condition1Op: ">", Condition1Value: 0,
		Condition2Formula: "0", Condition2Op: ">", Condition2Value: 0,
		LogicCyclesReqs: "AND", LogicReqsConds: "AND", LogicCond1Cond2: "AND", Color: 0x00FF00,
	})

	protoRepo := storage.NewPrototypeRepo(db)
	protoRepo.Create(&storage.Prototype{
		Name: "MaleA", Sex: "M", LongevityFormula: "500",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "10",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})
	protoRepo.Create(&storage.Prototype{
		Name: "FemaleA", Sex: "F", LongevityFormula: "600",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "10",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})


	// Create environment 30x30.
	envRepo := storage.NewEnvironmentRepo(db)
	envID, _ := envRepo.Create("TestArena", 30, 30, "")

	// Place resources.
	envRepo.PlaceSource(&storage.EnvironmentSource{
		EnvironmentID: envID, NutrientID: 1, Name: "spring1",
		PosX: 10, PosY: 10, Quality: 10, Level: 100, MaxLevel: 200, RegenRate: 1.05,
	})
	envRepo.PlaceSource(&storage.EnvironmentSource{
		EnvironmentID: envID, NutrientID: 2, Name: "flower1",
		PosX: 20, PosY: 20, Quality: 8, Level: 80, MaxLevel: 150, RegenRate: 1.1,
	})

	// Place 10 agents (mix of male and female adults).
	for i := 0; i < 10; i++ {
		sex := "M"
		if i%2 == 1 {
			sex = "F"
		}
		protoID := int64(1) // MaleA
		if sex == "F" {
			protoID = 2 // FemaleA
		}
		envRepo.PlaceAgent(&storage.EnvironmentAgent{
			EnvironmentID: envID,
			Name:          "agent" + string(rune('A'+i)),
			PosX:          5 + i*2, PosY: 5 + i*2,
			PrototypeID: &protoID, Sex: sex, Age: 0,
		})
	}

	return db
}

func TestBuild(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	cfg := DefaultEngineConfig(1)
	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	if engine.World == nil {
		t.Fatal("World is nil")
	}
	if engine.World.Agents.Count != 10 {
		t.Fatalf("expected 10 agents, got %d", engine.World.Agents.Count)
	}
	if engine.World.Resources.Count != 2 {
		t.Fatalf("expected 2 resources, got %d", engine.World.Resources.Count)
	}
	if engine.RunID <= 0 {
		t.Fatalf("expected positive RunID, got %d", engine.RunID)
	}
}

func TestTickExecutes(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	cfg := DefaultEngineConfig(1)
	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	// Give agents enough reserves to survive.
	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 100
		}
		a.Speed[i] = 1
		a.Direction[i] = 2
	}

	initialCount := a.Count
	engine.Tick()

	if engine.World.Tick != 1 {
		t.Fatalf("expected tick=1, got %d", engine.World.Tick)
	}
	// Agents should mostly survive one tick (reserves=100, cost=1).
	if a.Count < initialCount-2 {
		t.Fatalf("too many agents died in 1 tick: %d → %d", initialCount, a.Count)
	}
}

func TestRunTicks(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	cfg := DefaultEngineConfig(1)
	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	// Give agents reserves.
	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 200
		}
		a.Speed[i] = 1
		a.Direction[i] = 2
	}

	engine.RunTicks(100)

	if engine.World.Tick != 100 {
		t.Fatalf("expected tick=100, got %d", engine.World.Tick)
	}
	// With 200 reserves and 1 cost/tick, most should survive 100 ticks.
	// But some may starve due to movement costs etc. At least some should survive.
	if a.Count == 0 {
		t.Fatal("all agents died within 100 ticks — population should be sustainable")
	}
	t.Logf("After 100 ticks: %d agents alive", a.Count)
}

func TestRunContextCancellation(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	cfg := DefaultEngineConfig(1)
	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	// Give infinite reserves so it never stops naturally.
	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 999999
		}
		a.Speed[i] = 1
		a.Direction[i] = 2
	}

	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	engine.Run(ctx)

	// Should have run multiple ticks before cancellation.
	if engine.World.Tick < 10 {
		t.Fatalf("expected at least 10 ticks, got %d", engine.World.Tick)
	}
	t.Logf("Ran %d ticks before context cancellation", engine.World.Tick)
}

func TestRunStopsWhenAllDead(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	cfg := DefaultEngineConfig(1)
	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	// Give agents very low reserves — they should die quickly.
	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 3 // Will starve in ~3 ticks.
		}
		a.Speed[i] = 1
		a.Direction[i] = 2
	}

	ctx := context.Background()
	engine.Run(ctx)

	if a.Count != 0 {
		t.Fatalf("expected all agents dead, got %d alive", a.Count)
	}
	if engine.World.Tick < 2 || engine.World.Tick > 10 {
		t.Fatalf("expected death within 2-10 ticks, ran %d", engine.World.Tick)
	}
	t.Logf("All agents died at tick %d", engine.World.Tick)
}

func TestResultsWrittenToDB(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	cfg := DefaultEngineConfig(1)
	cfg.WriteBufferCfg = storage.WriteBufferConfig{MaxRecords: 10000, TickInterval: 10}
	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 500
		}
		a.Speed[i] = 1
		a.Direction[i] = 2
	}

	engine.RunTicks(50)
	engine.Finish("finished")

	// Check sim_runs.
	var status string
	var totalTicks int
	db.Conn.QueryRow("SELECT status, total_ticks FROM sim_runs WHERE id = ?", engine.RunID).Scan(&status, &totalTicks)
	if status != "finished" {
		t.Fatalf("expected status=finished, got %q", status)
	}
	if totalTicks != 50 {
		t.Fatalf("expected total_ticks=50, got %d", totalTicks)
	}

	// Check tick counts were written.
	var countRows int
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_tick_counts WHERE run_id = ?", engine.RunID).Scan(&countRows)
	if countRows == 0 {
		t.Fatal("expected tick count rows in DB")
	}
	t.Logf("Written %d tick count records to DB", countRows)
}

func TestEnginePerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping performance test in short mode")
	}

	db := setupTestDB(t)
	defer db.Close()

	cfg := DefaultEngineConfig(1)
	cfg.WriteBufferCfg = storage.WriteBufferConfig{MaxRecords: 100000, TickInterval: 1000}
	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	// Give agents large reserves so they don't die.
	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 999999
		}
		a.Speed[i] = 1
		a.Direction[i] = 2
	}

	start := time.Now()
	engine.RunTicks(1000)
	elapsed := time.Since(start)

	tps := float64(1000) / elapsed.Seconds()
	t.Logf("10 agents × 1000 ticks in %v (%.0f TPS)", elapsed, tps)

	if tps < 1000 {
		t.Logf("WARNING: TPS %.0f is below expected minimum of 1000", tps)
	}
}
