package kernel

import (
	"context"
	"os"
	"path/filepath"
	"testing"
	"time"

	"galatea/engine/internal/adapters/storage"
)

// TestEndToEndWorkspace creates a reference workspace, runs the engine on it,
// and verifies the full pipeline produces coherent results.
func TestEndToEndWorkspace(t *testing.T) {
	// Create workspace in a temp directory.
	wsDir := t.TempDir()
	dbPath := filepath.Join(wsDir, "galatea.db")

	db, err := storage.Open(dbPath)
	if err != nil {
		t.Fatalf("Open: %v", err)
	}
	defer db.Close()

	populateReferenceProject(t, db)

	// Build and run engine.
	cfg := DefaultEngineConfig(1)
	cfg.Longevity = 5000
	cfg.WriteBufferCfg = storage.WriteBufferConfig{MaxRecords: 50000, TickInterval: 100}

	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	// Bootstrap reserves.
	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 1000
		}
		if a.Speed[i] <= 0 {
			a.Speed[i] = 1
		}
		if a.Direction[i] == 0 {
			a.Direction[i] = 2
		}
	}

	initialPop := a.Count
	t.Logf("Initial population: %d agents, %d resources", initialPop, engine.World.Resources.Count)
	t.Logf("Config: %d nutrients, %d loci, %d stages, %d protos (M:%d F:%d), %dx%d grid",
		engine.World.Config.NumNutrients, engine.World.Config.NumLoci,
		engine.World.Config.NumStages, engine.World.Config.NumPrototypes,
		engine.World.Config.NumPrototypesM, engine.World.Config.NumPrototypesF,
		engine.World.Config.GridWidth, engine.World.Config.GridHeight)

	// Run 500 ticks.
	start := time.Now()
	engine.RunTicks(500)
	elapsed := time.Since(start)

	finalPop := a.Count
	tps := float64(500) / elapsed.Seconds()

	t.Logf("Ran 500 ticks in %v (%.0f TPS)", elapsed, tps)
	t.Logf("Population: %d → %d (delta: %+d)", initialPop, finalPop, finalPop-initialPop)
	t.Logf("World tick: %d, Eggs: %d", engine.World.Tick, engine.World.Eggs.Count)

	// Verify basic coherence.
	if engine.World.Tick == 0 {
		t.Fatal("no ticks executed")
	}
	if tps < 100 {
		t.Errorf("TPS too low: %.0f (expected > 100)", tps)
	}

	// Flush and check DB results.
	engine.Finish("finished")

	var tickCountRows int
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_tick_counts WHERE run_id = ?", engine.RunID).Scan(&tickCountRows)
	t.Logf("DB tick_count rows: %d", tickCountRows)

	if tickCountRows == 0 {
		t.Error("no tick counts written to DB")
	}

	// Verify run status.
	var status string
	db.Conn.QueryRow("SELECT status FROM sim_runs WHERE id = ?", engine.RunID).Scan(&status)
	if status != "finished" {
		t.Errorf("expected run status=finished, got %q", status)
	}

	t.Logf("DB size: %.1f KB", float64(fileSize(dbPath))/1024)
}

// TestEndToEndContextCancel verifies the engine stops cleanly on context cancellation.
func TestEndToEndContextCancel(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	cfg := DefaultEngineConfig(1)
	engine, err := Build(db, cfg)
	if err != nil {
		t.Fatalf("Build: %v", err)
	}

	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 999999
		}
		a.Speed[i] = 1
		a.Direction[i] = 2
	}

	ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cancel()
	engine.Run(ctx)
	engine.Finish("aborted")

	if engine.World.Tick < 5 {
		t.Fatalf("expected at least 5 ticks, got %d", engine.World.Tick)
	}
	t.Logf("Ran %d ticks before cancel", engine.World.Tick)
}

func populateReferenceProject(t *testing.T, db *storage.DB) {
	t.Helper()

	projRepo := storage.NewProjectInfoRepo(db)
	projRepo.Init("Reference Project", "End-to-end integration test")

	nutRepo := storage.NewNutrientRepo(db)
	nutRepo.Create("Water", 0, 1)
	nutRepo.Create("Carbohydrates", 0, 2)
	nutRepo.Create("Lipids", 0, 3)
	nutRepo.Create("Protein", 0, 4)

	subRepo := storage.NewSubstrateRepo(db)
	subRepo.Create("Grass", 0x228B22, false, 1)
	subRepo.Create("Sand", 0xC2B280, false, 2)
	subRepo.Create("Water", 0x1E90FF, false, 3)
	subRepo.Create("Rock", 0x696969, false, 4)
	subRepo.Create("Forest", 0x006400, false, 5)

	locRepo := storage.NewLocusRepo(db)
	for i, name := range []string{"BodySize", "WingLength", "Pigmentation", "FlightSpeed", "MetabolicRate"} {
		locRepo.Create(&storage.Locus{
			Name: name, IsContinuous: true,
			DominantValue: 1.0, RecessiveValue: 0.5,
			MutationRateDom: 0.01, MutationRateRec: 0.01,
			MutationRangeDom: 0.1, MutationRangeRec: 0.1,
			DefaultExpression: "0", SortOrder: i + 1,
		})
	}

	stageRepo := storage.NewStageRepo(db)
	stageRepo.Create(&storage.Stage{
		Name: "Egg", SortOrder: 1, CyclesFormula: "30",
		Condition1Formula: "0", Condition1Op: ">", Condition1Value: 0,
		Condition2Formula: "0", Condition2Op: ">", Condition2Value: 0,
		LogicCyclesReqs: "AND", LogicReqsConds: "AND", LogicCond1Cond2: "AND", Color: 0xFFFF00,
	})
	stageRepo.Create(&storage.Stage{
		Name: "Larva", SortOrder: 2, CyclesFormula: "80",
		Condition1Formula: "0", Condition1Op: ">", Condition1Value: 0,
		Condition2Formula: "0", Condition2Op: ">", Condition2Value: 0,
		LogicCyclesReqs: "AND", LogicReqsConds: "AND", LogicCond1Cond2: "AND", Color: 0x00FF00,
	})

	protoRepo := storage.NewPrototypeRepo(db)
	protoRepo.Create(&storage.Prototype{
		Name: "TerritorialMale", Sex: "M", LongevityFormula: "2000",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "15",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})
	protoRepo.Create(&storage.Prototype{
		Name: "SneakerMale", Sex: "M", LongevityFormula: "1500",
		RefractoryCombatFormula: "5", RefractoryCourtshipFormula: "10",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 2,
	})
	protoRepo.Create(&storage.Prototype{
		Name: "LargeFemale", Sex: "F", LongevityFormula: "2500",
		RefractoryCombatFormula: "8", RefractoryCourtshipFormula: "12",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})
	protoRepo.Create(&storage.Prototype{
		Name: "SmallFemale", Sex: "F", LongevityFormula: "2000",
		RefractoryCombatFormula: "6", RefractoryCourtshipFormula: "10",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 2,
	})


	envRepo := storage.NewEnvironmentRepo(db)
	envID, _ := envRepo.Create("ReferenceArena", 80, 80, "80x80 reference environment")

	// Place resources.
	for i := 0; i < 12; i++ {
		envRepo.PlaceSource(&storage.EnvironmentSource{
			EnvironmentID: envID, NutrientID: 1, Name: "water_" + itoa(i),
			PosX: 5 + i*6, PosY: 40, Quality: 10, Level: 150, MaxLevel: 300, RegenRate: 1.05,
		})
	}
	for i := 0; i < 10; i++ {
		envRepo.PlaceSource(&storage.EnvironmentSource{
			EnvironmentID: envID, NutrientID: 2, Name: "flower_" + itoa(i),
			PosX: 40, PosY: 5 + i*7, Quality: 8, Level: 100, MaxLevel: 200, RegenRate: 1.1,
		})
	}
	for i := 0; i < 8; i++ {
		envRepo.PlaceSource(&storage.EnvironmentSource{
			EnvironmentID: envID, NutrientID: 3, Name: "tree_" + itoa(i),
			PosX: 10 + i*9, PosY: 65, Quality: 12, Level: 120, MaxLevel: 250, RegenRate: 1.06,
		})
	}

	// Place 100 adult agents.
	for i := 0; i < 100; i++ {
		sex := "M"
		protoID := int64(1 + i%2) // Alternate between 2 male prototypes.
		if i%2 == 1 {
			sex = "F"
			protoID = int64(3 + i%2) // Alternate between 2 female prototypes.
		}
		envRepo.PlaceAgent(&storage.EnvironmentAgent{
			EnvironmentID: envID, Name: "agent_" + itoa(i),
			PosX: 5 + (i%10)*7, PosY: 5 + (i/10)*7,
			PrototypeID: &protoID, Sex: sex, Age: 0,
		})
	}
}

func itoa(n int) string {
	if n < 10 {
		return string(rune('0' + n))
	}
	return itoa(n/10) + string(rune('0'+n%10))
}

func fileSize(path string) int64 {
	fi, err := os.Stat(path)
	if err != nil {
		return 0
	}
	return fi.Size()
}
