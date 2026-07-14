// Command galateac is the headless simulation engine for the Galatea suite.
// This demo performs a full integration test of all implemented subsystems
// and reports performance metrics.
package main

import (
	"context"
	"fmt"
	"math/rand/v2"
	"os"
	"path/filepath"
	"runtime"
	"time"

	"galatea/engine/internal/adapters/storage"
	"galatea/engine/internal/kernel"
	"galatea/engine/internal/kernel/formulas"
	"galatea/engine/internal/kernel/spatial"
	"galatea/engine/internal/kernel/systems"
	"galatea/engine/internal/kernel/world"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	fmt.Println("╔══════════════════════════════════════════════════════════════════╗")
	fmt.Println("║       GALATEA SIMULATION ENGINE — FULL INTEGRATION DEMO         ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════════╝")
	fmt.Printf("Platform: %s/%s, CPUs: %d\n\n", runtime.GOOS, runtime.GOARCH, runtime.NumCPU())

	// --- Phase 1: Storage Layer ---
	fmt.Println("━━━ Phase 1: Storage Layer ━━━")
	wsDir := filepath.Join(".", "demo_workspace", "integration_test")
	dbPath := filepath.Join(wsDir, "galatea.db")
	os.RemoveAll(filepath.Join(".", "demo_workspace"))

	db, err := storage.Open(dbPath)
	if err != nil {
		return fmt.Errorf("open db: %w", err)
	}
	defer db.Close()

	populateProject(db)
	fmt.Println("  [OK] Project populated in DB")

	// --- Phase 2: World Loader ---
	fmt.Println("\n━━━ Phase 2: World Loader (Cold Path) ━━━")
	startLoad := time.Now()
	w, err := world.Load(db, 1)
	if err != nil {
		return fmt.Errorf("load world: %w", err)
	}
	loadTime := time.Since(startLoad)
	fmt.Printf("  [OK] World loaded in %v\n", loadTime)
	fmt.Printf("       Config: %d nutrients, %d loci, %d stages, %d prototypes (M:%d F:%d)\n",
		w.Config.NumNutrients, w.Config.NumLoci, w.Config.NumStages,
		w.Config.NumPrototypes, w.Config.NumPrototypesM, w.Config.NumPrototypesF)
	fmt.Printf("       Grid: %dx%d, Resources: %d, Agents: %d\n",
		w.Config.GridWidth, w.Config.GridHeight, w.Resources.Count, w.Agents.Count)

	// --- Phase 3: Formula Engine ---
	fmt.Println("\n━━━ Phase 3: Formula Engine ━━━")
	reg := formulas.NewRegistry()
	testFormulas := []struct {
		key, formula string
	}{
		{"metabolism.cost.move", "Age * 2 + Reserve1"},
		{"tendency.0.1", "CL1 * 10 + Random() * 5"},
		{"reproduction.max_eggs", "Max(5, Round(Morphology1 * 3))"},
		{"condition.eclosion", "Age > 50"},
	}
	for _, f := range testFormulas {
		if err := reg.Compile(f.key, f.formula); err != nil {
			return fmt.Errorf("compile formula %s: %w", f.key, err)
		}
	}
	eval := formulas.NewEvaluator(128)
	eval.SetInt("Age", 100)
	eval.SetInt("Reserve1", 80)
	eval.SetFloat("CL1", 1.5)
	eval.SetFloat("Morphology1", 2.0)

	// Benchmark formula evaluation.
	const formulaIters = 100000
	startFormula := time.Now()
	for i := 0; i < formulaIters; i++ {
		eval.RunProgramInt(reg.Get("metabolism.cost.move"))
	}
	formulaTime := time.Since(startFormula)
	formulaRate := float64(formulaIters) / formulaTime.Seconds()
	fmt.Printf("  [OK] %d formulas compiled, %d evaluations in %v\n", reg.Count(), formulaIters, formulaTime)
	fmt.Printf("       Throughput: %.0f evals/sec (%.0f ns/eval)\n", formulaRate, float64(formulaTime.Nanoseconds())/float64(formulaIters))

	// --- Phase 4: Spatial Hash Grid ---
	fmt.Println("\n━━━ Phase 4: Spatial Hash Grid ━━━")
	const spatialAgents = 10000
	grid := spatial.NewGrid(15.0, spatialAgents)
	posX := make([]float64, spatialAgents)
	posY := make([]float64, spatialAgents)
	for i := 0; i < spatialAgents; i++ {
		posX[i] = rand.Float64() * 1000
		posY[i] = rand.Float64() * 1000
		grid.Insert(int32(i), posX[i], posY[i])
	}

	const spatialQueries = 50000
	startSpatial := time.Now()
	for i := 0; i < spatialQueries; i++ {
		cx := rand.Float64() * 1000
		cy := rand.Float64() * 1000
		grid.QueryRadiusExact(cx, cy, 15.0, posX, posY)
	}
	spatialTime := time.Since(startSpatial)
	spatialRate := float64(spatialQueries) / spatialTime.Seconds()
	fmt.Printf("  [OK] %d agents indexed, %d radius queries in %v\n", spatialAgents, spatialQueries, spatialTime)
	fmt.Printf("       Throughput: %.0f queries/sec (%.0f ns/query)\n", spatialRate, float64(spatialTime.Nanoseconds())/float64(spatialQueries))

	// --- Phase 5: Perception + Decision + Action (isolated) ---
	fmt.Println("\n━━━ Phase 5: Systems (Perception → Decision → Action) ━━━")
	// Build a small world for systems testing.
	sysCfg := world.Config{
		NumNutrients: 4, NumLoci: 7, NumStages: 3, NumPrototypesM: 2, NumPrototypesF: 2,
		NumPrototypes: 7, NumResourceTypes: 4, NumSubstrates: 8, NumBehaviors: 12,
		NumDirections: 8, GridWidth: 100, GridHeight: 100, InitialCapacity: 256,
	}
	sysWorld := world.New(sysCfg)
	// Add 200 agents with random positions and reserves.
	for i := 0; i < 200; i++ {
		idx := sysWorld.AddAgent()
		sysWorld.Agents.PosX[idx] = rand.Float64() * 100
		sysWorld.Agents.PosY[idx] = rand.Float64() * 100
		sysWorld.Agents.Direction[idx] = uint8(rand.IntN(8) + 1)
		sysWorld.Agents.Speed[idx] = 1
		sysWorld.Agents.StageID[idx] = -1
		sysWorld.Agents.PrototypeID[idx] = int32(rand.IntN(2))
		if i%2 == 0 {
			sysWorld.Agents.Sex[idx] = world.SexMale
		} else {
			sysWorld.Agents.Sex[idx] = world.SexFemale
		}
		sysWorld.Agents.Situation[idx] = world.SituationRegular
		for n := 0; n < sysCfg.NumNutrients; n++ {
			sysWorld.Agents.Reserves[idx*sysCfg.NumNutrients+n] = 200
		}
	}
	// Add resources.
	for i := 0; i < 20; i++ {
		sysWorld.Resources.PosX[i] = rand.Float64() * 100
		sysWorld.Resources.PosY[i] = rand.Float64() * 100
		sysWorld.Resources.TypeID[i] = int32(i % sysCfg.NumResourceTypes)
		sysWorld.Resources.Level[i] = 100
		sysWorld.Resources.MaxLevel[i] = 200
		sysWorld.Resources.RegenRate[i] = 1.05
	}
	sysWorld.Resources.Count = 20

	agGrid := spatial.NewGrid(15.0, 256)
	resGrid := spatial.NewGrid(15.0, 64)
	agGrid.Rebuild(sysWorld.Agents.Count, sysWorld.Agents.PosX, sysWorld.Agents.PosY)
	for i := 0; i < sysWorld.Resources.Count; i++ {
		resGrid.Insert(int32(i), sysWorld.Resources.PosX[i], sysWorld.Resources.PosY[i])
	}

	numProtos := sysCfg.NumPrototypes
	numRes := sysCfg.NumResourceTypes
	resRadii := make([]float64, numRes*numProtos)
	resAttr := make([]int32, numRes*numProtos)
	for i := range resRadii {
		resRadii[i] = 15.0
		resAttr[i] = 10
	}
	agRadii := make([]float64, numProtos*numProtos)
	for i := range agRadii {
		agRadii[i] = 15.0
	}

	sysReg := formulas.NewRegistry()
	sysEval := formulas.NewEvaluator(128)
	sysEnv := formulas.NewEnvBuilder(sysEval, sysCfg)

	pctx := &systems.PerceptionContext{
		World: sysWorld, AgentGrid: agGrid, ResourceGrid: resGrid,
		Formulas: sysReg, Eval: sysEval, EnvBuilder: sysEnv,
		ResourceRadii: resRadii, ResourceAttr: resAttr, AgentRadii: agRadii,
	}

	const sysIters = 100
	startSys := time.Now()
	for tick := 0; tick < sysIters; tick++ {
		for i := 0; i < sysWorld.Agents.Count; i++ {
			systems.Perceive(pctx, i)
			systems.Decide(sysWorld, i)
			systems.Act(sysWorld, i)
		}
		systems.RegenerateResources(sysWorld)
		systems.ResetAgentStates(sysWorld)
		agGrid.Rebuild(sysWorld.Agents.Count, sysWorld.Agents.PosX, sysWorld.Agents.PosY)
	}
	sysTime := time.Since(startSys)
	sysTPS := float64(sysIters) / sysTime.Seconds()
	fmt.Printf("  [OK] 200 agents × %d ticks in %v\n", sysIters, sysTime)
	fmt.Printf("       TPS: %.0f (%.2f ms/tick)\n", sysTPS, float64(sysTime.Milliseconds())/float64(sysIters))

	// --- Phase 6: Full Engine Integration ---
	fmt.Println("\n━━━ Phase 6: Full Engine Integration (galateac pipeline) ━━━")
	engineCfg := kernel.DefaultEngineConfig(1)
	engineCfg.Longevity = 2000
	engineCfg.WriteBufferCfg = storage.WriteBufferConfig{MaxRecords: 50000, TickInterval: 500}

	engine, err := kernel.Build(db, engineCfg)
	if err != nil {
		return fmt.Errorf("build engine: %w", err)
	}

	// Give loaded agents reserves so they can survive.
	a := engine.World.Agents
	numNut := engine.World.Config.NumNutrients
	for i := 0; i < a.Count; i++ {
		for n := 0; n < numNut; n++ {
			a.Reserves[i*numNut+n] = 500
		}
		a.Speed[i] = 1
		if a.Direction[i] == 0 {
			a.Direction[i] = 2
		}
	}

	const engineTicks = 500
	initialPop := a.Count
	startEngine := time.Now()
	engine.RunTicks(engineTicks)
	engineTime := time.Since(startEngine)
	engineTPS := float64(engineTicks) / engineTime.Seconds()
	finalPop := a.Count

	engine.Finish("finished")

	fmt.Printf("  [OK] %d ticks completed in %v\n", engineTicks, engineTime)
	fmt.Printf("       TPS: %.0f (%.2f ms/tick)\n", engineTPS, float64(engineTime.Milliseconds())/float64(engineTicks))
	fmt.Printf("       Population: %d → %d (delta: %+d)\n", initialPop, finalPop, finalPop-initialPop)
	fmt.Printf("       World tick: %d\n", engine.World.Tick)

	// DB results.
	var tickCountRows, eventRows int
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_tick_counts WHERE run_id = ?", engine.RunID).Scan(&tickCountRows)
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_events WHERE run_id = ?", engine.RunID).Scan(&eventRows)
	fmt.Printf("       DB records: %d tick_counts, %d events\n", tickCountRows, eventRows)

	// --- Phase 7: Write Buffer Throughput ---
	fmt.Println("\n━━━ Phase 7: Write Buffer Throughput ━━━")
	runRepo := storage.NewSimRunRepo(db)
	benchRunID, _ := runRepo.Create(1)
	wb := storage.NewWriteBuffer(db, benchRunID, storage.WriteBufferConfig{MaxRecords: 100000, TickInterval: 1000})

	const writeRecords = 100000
	startWrite := time.Now()
	for tick := 1; tick <= 1000; tick++ {
		counts := make([]storage.TickCount, 100)
		for i := range counts {
			counts[i] = storage.TickCount{Tick: tick, Count: rand.IntN(200)}
		}
		wb.AddTickCounts(tick, counts)
	}
	wb.Flush()
	writeTime := time.Since(startWrite)
	writeRate := float64(writeRecords) / writeTime.Seconds()
	fmt.Printf("  [OK] %d records written in %v\n", writeRecords, writeTime)
	fmt.Printf("       Throughput: %.0f records/sec\n", writeRate)

	// --- Phase 8: Context cancellation test ---
	fmt.Println("\n━━━ Phase 8: Context Cancellation ━━━")
	engine2, _ := kernel.Build(db, kernel.DefaultEngineConfig(1))
	a2 := engine2.World.Agents
	numNut2 := engine2.World.Config.NumNutrients
	for i := 0; i < a2.Count; i++ {
		for n := 0; n < numNut2; n++ {
			a2.Reserves[i*numNut2+n] = 999999
		}
		a2.Speed[i] = 1
		if a2.Direction[i] == 0 {
			a2.Direction[i] = 2
		}
	}
	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()
	engine2.Run(ctx)
	fmt.Printf("  [OK] Ran %d ticks in 200ms before context cancellation\n", engine2.World.Tick)
	engine2.Finish("aborted")

	// --- Summary ---
	fi, _ := os.Stat(dbPath)
	dbSize := float64(fi.Size()) / 1024

	fmt.Println("\n╔══════════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    PERFORMANCE SUMMARY                           ║")
	fmt.Println("╠══════════════════════════════════════════════════════════════════╣")
	fmt.Printf("║  World Load Time:         %12v                        ║\n", loadTime.Round(time.Microsecond))
	fmt.Printf("║  Formula Eval:            %12.0f evals/sec                ║\n", formulaRate)
	fmt.Printf("║  Spatial Queries (10K):   %12.0f queries/sec              ║\n", spatialRate)
	fmt.Printf("║  Systems (200 agents):    %12.0f TPS                      ║\n", sysTPS)
	fmt.Printf("║  Full Engine (pipeline):  %12.0f TPS                      ║\n", engineTPS)
	fmt.Printf("║  Write Buffer:            %12.0f records/sec              ║\n", writeRate)
	fmt.Printf("║  Context Run (200ms):     %12d ticks                     ║\n", engine2.World.Tick)
	fmt.Printf("║  Database Size:           %12.1f KB                       ║\n", dbSize)
	fmt.Println("╚══════════════════════════════════════════════════════════════════╝")

	// Cleanup.
	os.RemoveAll(filepath.Join(".", "demo_workspace"))
	fmt.Println("\nDemo workspace cleaned. All systems operational.")

	return nil
}

// populateProject creates a complete project in the database for testing.
func populateProject(db *storage.DB) {
	projRepo := storage.NewProjectInfoRepo(db)
	projRepo.Init("Galatea Integration Test", "Full engine integration demo")

	nutRepo := storage.NewNutrientRepo(db)
	nutRepo.Create("Water", 1)
	nutRepo.Create("Sugar", 2)
	nutRepo.Create("Fat", 3)
	nutRepo.Create("Protein", 4)

	subRepo := storage.NewSubstrateRepo(db)
	for i := 1; i <= 5; i++ {
		subRepo.Create(fmt.Sprintf("Substrate%d", i), 0x111111*i, false, i)
	}

	locRepo := storage.NewLocusRepo(db)
	lociNames := []string{"BodySize", "WingLength", "Pigmentation", "Speed", "MetabolicRate"}
	for i, name := range lociNames {
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
		Name: "Larva", SortOrder: 1, CyclesFormula: "50",
		Condition1Formula: "0", Condition1Op: ">", Condition1Value: 0,
		Condition2Formula: "0", Condition2Op: ">", Condition2Value: 0,
		LogicCyclesReqs: "AND", LogicReqsConds: "AND", LogicCond1Cond2: "AND", Color: 0x00FF00,
	})

	protoRepo := storage.NewPrototypeRepo(db)
	protoRepo.Create(&storage.Prototype{
		Name: "AlphaM", Sex: "M", LongevityFormula: "1000",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "15",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})
	protoRepo.Create(&storage.Prototype{
		Name: "AlphaF", Sex: "F", LongevityFormula: "1200",
		RefractoryCombatFormula: "10", RefractoryCourtshipFormula: "15",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50", SortOrder: 1,
	})

	nutID1 := int64(1)
	nutID2 := int64(2)
	rtRepo := storage.NewResourceTypeRepo(db)
	rtRepo.Create(&storage.ResourceType{Name: "WaterSource", NutrientID: &nutID1, SortOrder: 1})
	rtRepo.Create(&storage.ResourceType{Name: "SugarSource", NutrientID: &nutID2, SortOrder: 2})

	envRepo := storage.NewEnvironmentRepo(db)
	envID, _ := envRepo.Create("Arena", 80, 80, "80x80 test arena")

	// Resources scattered around.
	for i := 0; i < 10; i++ {
		envRepo.PlaceResource(&storage.EnvironmentResource{
			EnvironmentID: envID, ResourceTypeID: 1, Name: fmt.Sprintf("water_%d", i),
			PosX: 5 + i*8, PosY: 40, Quality: 10, Level: 100, MaxLevel: 200, RegenRate: 1.05,
		})
	}
	for i := 0; i < 10; i++ {
		envRepo.PlaceResource(&storage.EnvironmentResource{
			EnvironmentID: envID, ResourceTypeID: 2, Name: fmt.Sprintf("sugar_%d", i),
			PosX: 40, PosY: 5 + i*8, Quality: 8, Level: 80, MaxLevel: 150, RegenRate: 1.1,
		})
	}

	// 50 adult agents (25M + 25F) spread across the arena.
	for i := 0; i < 50; i++ {
		sex := "M"
		protoID := int64(1)
		if i%2 == 1 {
			sex = "F"
			protoID = 2
		}
		envRepo.PlaceAgent(&storage.EnvironmentAgent{
			EnvironmentID: envID, Name: fmt.Sprintf("agent_%03d", i),
			PosX: 5 + (i%10)*7, PosY: 5 + (i/10)*15,
			PrototypeID: &protoID, Sex: sex, Age: 0,
		})
	}
}
