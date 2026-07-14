// Command galateac is the headless simulation engine for the Galatea suite.
// This demo exercises the storage layer by creating a workspace, populating it
// with sample data, and reading it back.
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"galatea/engine/internal/adapters/storage"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run() error {
	// Each project lives in its own directory with a galatea.db file.
	wsDir := filepath.Join(".", "demo_workspace", "aedes_aegypti")
	dbPath := filepath.Join(wsDir, "galatea.db")

	// Clean previous demo run.
	os.RemoveAll(filepath.Join(".", "demo_workspace"))

	fmt.Println("=== Galatea Storage Layer Demo ===")
	fmt.Printf("Creating project workspace at: %s\n\n", dbPath)

	// Open database (creates directory and file, applies migrations).
	db, err := storage.Open(dbPath)
	if err != nil {
		return fmt.Errorf("open db: %w", err)
	}
	defer db.Close()

	version, _ := db.SchemaVersion()
	fmt.Printf("Schema version: %d\n\n", version)

	// --- Initialize project info (singleton) ---
	projRepo := storage.NewProjectInfoRepo(db)
	err = projRepo.Init("Aedes aegypti Simulation", "Reproductive strategies of Aedes aegypti mosquitoes")
	if err != nil {
		return fmt.Errorf("init project: %w", err)
	}
	fmt.Println("Initialized project info")

	// --- Define nutrients ---
	nutRepo := storage.NewNutrientRepo(db)
	nutrients := []string{"Water", "Carbohydrates", "Lipids", "Protein"}
	nutIDs := make([]int64, len(nutrients))
	for i, name := range nutrients {
		id, err := nutRepo.Create(name, i+1)
		if err != nil {
			return fmt.Errorf("create nutrient %s: %w", name, err)
		}
		nutIDs[i] = id
	}
	fmt.Printf("Created %d nutrients: %v\n", len(nutrients), nutrients)

	// --- Define substrates ---
	subRepo := storage.NewSubstrateRepo(db)
	subNames := []string{"Water Surface", "Vegetation", "Soil", "Rock", "Mud", "Concrete", "Bark"}
	subIDs := make([]int64, len(subNames))
	for i, name := range subNames {
		id, err := subRepo.Create(name, 0x333333+i*0x111111, false, i+1)
		if err != nil {
			return fmt.Errorf("create substrate %s: %w", name, err)
		}
		subIDs[i] = id
	}
	// Mixed substrate
	mixID, _ := subRepo.Create("Muddy Vegetation", 0x556B2F, true, 8)
	subRepo.AddComposition(mixID, subIDs[1], 60)
	subRepo.AddComposition(mixID, subIDs[4], 40)
	fmt.Printf("Created %d substrates (7 simple + 1 mixed)\n", len(subNames)+1)

	// --- Define loci ---
	locRepo := storage.NewLocusRepo(db)
	loci := []struct {
		name       string
		continuous bool
	}{
		{"BodySize", true},
		{"WingLength", true},
		{"Pigmentation", true},
		{"FlightSpeed", true},
		{"MetabolicRate", true},
		{"EggBatchSize", false},
		{"HostPreference", false},
	}
	for i, l := range loci {
		_, err := locRepo.Create(&storage.Locus{
			Name:              l.name,
			IsContinuous:      l.continuous,
			DominantValue:     1.0,
			RecessiveValue:    0.5,
			MutationRateDom:   0.01,
			MutationRateRec:   0.01,
			MutationRangeDom:  0.1,
			MutationRangeRec:  0.1,
			DefaultExpression: "CL1",
			SortOrder:         i + 1,
		})
		if err != nil {
			return fmt.Errorf("create locus %s: %w", l.name, err)
		}
	}
	fmt.Printf("Created %d loci\n", len(loci))

	// --- Define stages ---
	stageRepo := storage.NewStageRepo(db)
	stages := []string{"Egg", "Larva", "Pupa"}
	stageIDs := make([]int64, len(stages))
	for i, name := range stages {
		id, err := stageRepo.Create(&storage.Stage{
			Name:              name,
			SortOrder:         i + 1,
			CyclesFormula:     fmt.Sprintf("%d", (i+1)*50),
			Condition1Formula: "Age",
			Condition1Op:      ">",
			Condition1Value:   float64((i + 1) * 50),
			Condition2Formula: "0",
			Condition2Op:      ">",
			Condition2Value:   0,
			LogicCyclesReqs:   "AND",
			LogicReqsConds:    "OR",
			LogicCond1Cond2:   "AND",
			Color:             0x00FF00 + i*0x005500,
		})
		if err != nil {
			return fmt.Errorf("create stage %s: %w", name, err)
		}
		stageIDs[i] = id
	}
	fmt.Printf("Created %d stages: %v\n", len(stages), stages)

	// --- Define prototypes ---
	protoRepo := storage.NewPrototypeRepo(db)
	protos := []struct {
		name string
		sex  string
	}{
		{"Territorial Male", "M"},
		{"Sneaker Male", "M"},
		{"Large Female", "F"},
		{"Small Female", "F"},
	}
	for i, p := range protos {
		_, err := protoRepo.Create(&storage.Prototype{
			Name:                       p.name,
			Sex:                        p.sex,
			Color:                      0x0000FF + i*0x003300,
			LongevityFormula:           "500",
			RefractoryCombatFormula:    "10",
			RefractoryCourtshipFormula: "15",
			SexRatioMalesFormula:       "50",
			SexRatioFemalesFormula:     "50",
			SortOrder:                  i + 1,
		})
		if err != nil {
			return fmt.Errorf("create prototype %s: %w", p.name, err)
		}
	}
	fmt.Printf("Created %d prototypes\n", len(protos))

	// --- Define resource types ---
	rtRepo := storage.NewResourceTypeRepo(db)
	resourceTypes := []struct {
		name   string
		nutIdx int
		ovipos bool
	}{
		{"Puddle", 0, false},
		{"Nectar Flower", 1, false},
		{"Blood Host", 3, false},
		{"Oviposition Site", -1, true},
	}
	rtIDs := make([]int64, len(resourceTypes))
	for i, rt := range resourceTypes {
		r := &storage.ResourceType{
			Name:          rt.name,
			IsOviposition: rt.ovipos,
			Color:         0xFF0000 + i*0x003300,
			SortOrder:     i + 1,
		}
		if rt.nutIdx >= 0 {
			r.NutrientID = &nutIDs[rt.nutIdx]
		}
		id, err := rtRepo.Create(r)
		if err != nil {
			return fmt.Errorf("create resource type %s: %w", rt.name, err)
		}
		rtIDs[i] = id
	}
	fmt.Printf("Created %d resource types\n", len(resourceTypes))

	// --- Create environment ---
	envRepo := storage.NewEnvironmentRepo(db)
	envID, err := envRepo.Create("Urban Garden", 100, 100, "A 100x100 urban garden environment")
	if err != nil {
		return fmt.Errorf("create environment: %w", err)
	}
	fmt.Printf("Created environment ID=%d (100x100)\n", envID)

	// Place resources
	for i := 0; i < 5; i++ {
		envRepo.PlaceResource(&storage.EnvironmentResource{
			EnvironmentID: envID, ResourceTypeID: rtIDs[0],
			Name: fmt.Sprintf("puddle_%d", i+1),
			PosX: 10 + i*20, PosY: 50, Quality: 10, Level: 80, MaxLevel: 100, RegenRate: 1.05,
		})
	}
	for i := 0; i < 8; i++ {
		envRepo.PlaceResource(&storage.EnvironmentResource{
			EnvironmentID: envID, ResourceTypeID: rtIDs[1],
			Name: fmt.Sprintf("flower_%d", i+1),
			PosX: 5 + i*12, PosY: 30, Quality: 8, Level: 50, MaxLevel: 100, RegenRate: 1.1,
		})
	}
	for i := 0; i < 3; i++ {
		envRepo.PlaceResource(&storage.EnvironmentResource{
			EnvironmentID: envID, ResourceTypeID: rtIDs[3],
			Name: fmt.Sprintf("ovisite_%d", i+1),
			PosX: 20 + i*30, PosY: 80, Quality: 10, Level: 0, MaxLevel: 50, RegenRate: 1.0,
		})
	}
	fmt.Println("Placed 16 resources (5 puddles, 8 flowers, 3 oviposition sites)")

	// Place initial agents
	for i := 0; i < 20; i++ {
		sid := stageIDs[1] // Larva stage
		envRepo.PlaceAgent(&storage.EnvironmentAgent{
			EnvironmentID: envID,
			Name:          fmt.Sprintf("agent_%03d", i+1),
			PosX:          5 + i*4, PosY: 5 + i*4,
			StageID: &sid, Sex: "U", Age: 0,
		})
	}
	fmt.Println("Placed 20 initial agents (larvae)")

	// --- Simulate write buffer usage ---
	fmt.Println("\n--- Simulating write buffer (1000 ticks) ---")
	runRepo := storage.NewSimRunRepo(db)
	runID, _ := runRepo.Create(envID)

	cfg := storage.DefaultWriteBufferConfig()
	wb := storage.NewWriteBuffer(db, runID, cfg)

	start := time.Now()
	for tick := 1; tick <= 1000; tick++ {
		counts := make([]storage.TickCount, 4)
		for i := range counts {
			counts[i] = storage.TickCount{Tick: tick, Count: 100 + tick/10 + i*5}
		}
		wb.AddTickCounts(tick, counts)

		if tick%50 == 0 {
			wb.AddEvent(storage.SimEvent{
				Tick: tick, EventType: "birth", AgentName: fmt.Sprintf("agent_%d", tick),
				Details: fmt.Sprintf(`{"parent":"agent_%d"}`, tick-1),
			})
		}
	}
	wb.Flush()
	elapsed := time.Since(start)

	runRepo.Finish(runID, 1000, "finished")

	// Report
	var tickRows, eventRows int
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_tick_counts WHERE run_id = ?", runID).Scan(&tickRows)
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_events WHERE run_id = ?", runID).Scan(&eventRows)

	fmt.Printf("Written %d tick count records + %d events in %v\n", tickRows, eventRows, elapsed)
	fmt.Printf("Throughput: %.0f records/sec\n", float64(tickRows+eventRows)/elapsed.Seconds())

	// --- Read back summary ---
	fmt.Println("\n--- Workspace Summary ---")
	proj, _ := projRepo.Get()
	fmt.Printf("Project: %s\n", proj.Name)

	nutsRead, _ := nutRepo.List()
	fmt.Printf("Nutrients: %d", len(nutsRead))
	for _, n := range nutsRead {
		fmt.Printf(" [%s]", n.Name)
	}
	fmt.Println()

	subsRead, _ := subRepo.List()
	fmt.Printf("Substrates: %d\n", len(subsRead))

	lociRead, _ := locRepo.List()
	fmt.Printf("Loci: %d\n", len(lociRead))

	stagesRead, _ := stageRepo.List()
	fmt.Printf("Stages: %d\n", len(stagesRead))

	protosRead, _ := protoRepo.List("")
	fmt.Printf("Prototypes: %d\n", len(protosRead))

	rtsRead, _ := rtRepo.List()
	fmt.Printf("Resource Types: %d\n", len(rtsRead))

	env, _ := envRepo.GetByID(envID)
	fmt.Printf("Environment: %s (%dx%d)\n", env.Name, env.Width, env.Height)

	resources, _ := envRepo.ListResources(envID)
	fmt.Printf("Placed Resources: %d\n", len(resources))

	agents, _ := envRepo.ListAgents(envID)
	fmt.Printf("Initial Agents: %d\n", len(agents))

	simRun, _ := runRepo.GetByID(runID)
	fmt.Printf("Simulation Run: %d ticks, status=%s\n", simRun.TotalTicks, simRun.Status)

	fmt.Printf("\nWorkspace: %s\n", wsDir)
	fi, _ := os.Stat(dbPath)
	fmt.Printf("Database size: %.1f KB\n", float64(fi.Size())/1024)

	fmt.Println("\n=== Demo Complete ===")
	return nil
}
