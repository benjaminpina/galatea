package storage

import (
	"testing"
	"time"
)

func mustOpenMemory(t *testing.T) *DB {
	t.Helper()
	db, err := OpenMemory()
	if err != nil {
		t.Fatalf("OpenMemory failed: %v", err)
	}
	t.Cleanup(func() { db.Close() })
	return db
}

func TestOpenMemory(t *testing.T) {
	db := mustOpenMemory(t)

	version, err := db.SchemaVersion()
	if err != nil {
		t.Fatalf("SchemaVersion failed: %v", err)
	}
	if version != 1 {
		t.Fatalf("expected schema version 1, got %d", version)
	}

	// Verify a sample table exists.
	var count int
	err = db.Conn.QueryRow("SELECT COUNT(*) FROM nutrients").Scan(&count)
	if err != nil {
		t.Fatalf("query nutrients table failed: %v", err)
	}
}

func TestProjectInfo(t *testing.T) {
	db := mustOpenMemory(t)
	repo := NewProjectInfoRepo(db)

	// Init
	err := repo.Init("Test Project", "A test description")
	if err != nil {
		t.Fatalf("Init: %v", err)
	}

	// Get
	p, err := repo.Get()
	if err != nil {
		t.Fatalf("Get: %v", err)
	}
	if p == nil {
		t.Fatal("expected project info, got nil")
	}
	if p.Name != "Test Project" {
		t.Fatalf("expected name 'Test Project', got %q", p.Name)
	}
	if p.Description != "A test description" {
		t.Fatalf("expected description 'A test description', got %q", p.Description)
	}

	// Update
	err = repo.Update("Updated", "Updated desc")
	if err != nil {
		t.Fatalf("Update: %v", err)
	}
	p, _ = repo.Get()
	if p.Name != "Updated" {
		t.Fatalf("after update, expected name 'Updated', got %q", p.Name)
	}

	// Cannot insert second row (singleton enforced).
	_, err = db.Conn.Exec("INSERT INTO project_info (id, name) VALUES (2, 'bad')")
	if err == nil {
		t.Fatal("expected error inserting second project_info row")
	}
}

func TestNutrientCRUD(t *testing.T) {
	db := mustOpenMemory(t)
	repo := NewNutrientRepo(db)

	id1, err := repo.Create("Water", 0, 1)
	if err != nil {
		t.Fatalf("Create Water: %v", err)
	}
	id2, _ := repo.Create("Sugar", 0, 2)
	repo.Create("Fat", 0, 3)

	// GetByID
	n, err := repo.GetByID(id1)
	if err != nil {
		t.Fatalf("GetByID: %v", err)
	}
	if n.Name != "Water" {
		t.Fatalf("expected Water, got %q", n.Name)
	}

	// List
	nutrients, err := repo.List()
	if err != nil {
		t.Fatalf("List: %v", err)
	}
	if len(nutrients) != 3 {
		t.Fatalf("expected 3 nutrients, got %d", len(nutrients))
	}
	if nutrients[0].Name != "Water" || nutrients[1].Name != "Sugar" || nutrients[2].Name != "Fat" {
		t.Fatalf("unexpected order: %v", nutrients)
	}

	// Delete
	repo.Delete(id2)
	nutrients, _ = repo.List()
	if len(nutrients) != 2 {
		t.Fatalf("expected 2 after delete, got %d", len(nutrients))
	}
}

func TestSubstrateCRUD(t *testing.T) {
	db := mustOpenMemory(t)
	repo := NewSubstrateRepo(db)

	// Create simple substrates
	s1, _ := repo.Create("Sand", 0xFFFF00, false, 1)
	s2, _ := repo.Create("Rock", 0x808080, false, 2)

	// Create mixed substrate
	mix, _ := repo.Create("SandyRock", 0xC0C000, true, 3)

	// Add compositions
	repo.AddComposition(mix, s1, 60)
	repo.AddComposition(mix, s2, 40)

	// Verify
	sub, err := repo.GetByID(mix)
	if err != nil {
		t.Fatalf("GetByID: %v", err)
	}
	if !sub.IsMixed {
		t.Fatal("expected mixed=true")
	}

	comps, err := repo.GetCompositions(mix)
	if err != nil {
		t.Fatalf("GetCompositions: %v", err)
	}
	if len(comps) != 2 {
		t.Fatalf("expected 2 compositions, got %d", len(comps))
	}
	total := comps[0].Percentage + comps[1].Percentage
	if total != 100 {
		t.Fatalf("expected percentages to sum to 100, got %d", total)
	}

	// List
	substrates, _ := repo.List()
	if len(substrates) != 3 {
		t.Fatalf("expected 3 substrates, got %d", len(substrates))
	}
}

func TestPrototypeCRUD(t *testing.T) {
	db := mustOpenMemory(t)
	repo := NewPrototypeRepo(db)

	p := &Prototype{
		Name:                       "Alpha Male",
		Sex:                        "M",
		Color:                      0x0000FF,
		LongevityFormula:           "500",
		RefractoryCombatFormula:    "10",
		RefractoryCourtshipFormula: "20",
		SexRatioMalesFormula:       "50",
		SexRatioFemalesFormula:     "50",
		SortOrder:                  1,
	}

	id, err := repo.Create(p)
	if err != nil {
		t.Fatalf("Create: %v", err)
	}

	repo.Create(&Prototype{Name: "Beta Male", Sex: "M", SortOrder: 2,
		LongevityFormula: "400", RefractoryCombatFormula: "5", RefractoryCourtshipFormula: "10",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50"})
	repo.Create(&Prototype{Name: "Alpha Female", Sex: "F", SortOrder: 1,
		LongevityFormula: "600", RefractoryCombatFormula: "8", RefractoryCourtshipFormula: "15",
		SexRatioMalesFormula: "50", SexRatioFemalesFormula: "50"})

	// GetByID
	got, err := repo.GetByID(id)
	if err != nil {
		t.Fatalf("GetByID: %v", err)
	}
	if got.Name != "Alpha Male" {
		t.Fatalf("expected 'Alpha Male', got %q", got.Name)
	}

	// List (all)
	all, _ := repo.List("")
	if len(all) != 3 {
		t.Fatalf("expected 3, got %d", len(all))
	}

	// List (males only)
	males, _ := repo.List("M")
	if len(males) != 2 {
		t.Fatalf("expected 2 males, got %d", len(males))
	}

	// List (females only)
	females, _ := repo.List("F")
	if len(females) != 1 {
		t.Fatalf("expected 1 female, got %d", len(females))
	}
}

func TestEnvironmentWithElements(t *testing.T) {
	db := mustOpenMemory(t)

	nutRepo := NewNutrientRepo(db)
	nutID, _ := nutRepo.Create("Water", 0, 1)


	stageRepo := NewStageRepo(db)
	stageID, _ := stageRepo.Create(&Stage{
		Name: "Larva", SortOrder: 1,
		CyclesFormula: "100", Condition1Formula: "0", Condition1Op: ">", Condition1Value: 0,
		Condition2Formula: "0", Condition2Op: ">", Condition2Value: 0,
		LogicCyclesReqs: "AND", LogicReqsConds: "AND", LogicCond1Cond2: "AND", Color: 0x00FF00,
	})

	envRepo := NewEnvironmentRepo(db)
	envID, err := envRepo.Create("Test Environment", 50, 50, "A test env")
	if err != nil {
		t.Fatalf("Create env: %v", err)
	}

	// Place resources
	_, err = envRepo.PlaceSource(&EnvironmentSource{
		EnvironmentID: envID, NutrientID: nutID, Name: "Spring1",
		PosX: 10, PosY: 20, Quality: 10, Level: 80, MaxLevel: 100, RegenRate: 1.1,
	})
	if err != nil {
		t.Fatalf("PlaceResource: %v", err)
	}

	// Place agents
	_, err = envRepo.PlaceAgent(&EnvironmentAgent{
		EnvironmentID: envID, Name: "agent001",
		PosX: 5, PosY: 5, StageID: &stageID, Sex: "U", Age: 0,
	})
	if err != nil {
		t.Fatalf("PlaceAgent: %v", err)
	}

	// Verify
	resources, _ := envRepo.ListSources(envID)
	if len(resources) != 1 {
		t.Fatalf("expected 1 resource, got %d", len(resources))
	}
	if resources[0].Name != "Spring1" {
		t.Fatalf("expected 'Spring1', got %q", resources[0].Name)
	}

	agents, _ := envRepo.ListAgents(envID)
	if len(agents) != 1 {
		t.Fatalf("expected 1 agent, got %d", len(agents))
	}
	if agents[0].Name != "agent001" {
		t.Fatalf("expected 'agent001', got %q", agents[0].Name)
	}

	// Verify cascade delete
	envRepo.Delete(envID)
	resources, _ = envRepo.ListSources(envID)
	if len(resources) != 0 {
		t.Fatalf("expected 0 resources after delete, got %d", len(resources))
	}
}

func TestWriteBuffer(t *testing.T) {
	db := mustOpenMemory(t)

	envRepo := NewEnvironmentRepo(db)
	envID, _ := envRepo.Create("Env", 10, 10, "")
	runRepo := NewSimRunRepo(db)
	runID, _ := runRepo.Create(envID)

	cfg := WriteBufferConfig{MaxRecords: 50, TickInterval: 10}
	wb := NewWriteBuffer(db, runID, cfg)

	// Add tick counts below threshold.
	counts := []TickCount{
		{Tick: 1, Count: 100},
		{Tick: 1, Count: 50},
	}
	err := wb.AddTickCounts(1, counts)
	if err != nil {
		t.Fatalf("AddTickCounts: %v", err)
	}

	if wb.Pending() != 2 {
		t.Fatalf("expected 2 pending, got %d", wb.Pending())
	}

	// Add events.
	wb.AddEvent(SimEvent{Tick: 1, EventType: "birth", AgentName: "a1", Details: "{}"})

	if wb.Pending() != 3 {
		t.Fatalf("expected 3 pending, got %d", wb.Pending())
	}

	// Force flush.
	err = wb.Flush()
	if err != nil {
		t.Fatalf("Flush: %v", err)
	}
	if wb.Pending() != 0 {
		t.Fatalf("expected 0 pending after flush, got %d", wb.Pending())
	}

	// Verify data in DB.
	var tickCountRows int
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_tick_counts WHERE run_id = ?", runID).Scan(&tickCountRows)
	if tickCountRows != 2 {
		t.Fatalf("expected 2 tick_count rows, got %d", tickCountRows)
	}

	var eventRows int
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_events WHERE run_id = ?", runID).Scan(&eventRows)
	if eventRows != 1 {
		t.Fatalf("expected 1 event row, got %d", eventRows)
	}
}

func TestWriteBufferAutoFlush(t *testing.T) {
	db := mustOpenMemory(t)

	envRepo := NewEnvironmentRepo(db)
	envID, _ := envRepo.Create("Env", 10, 10, "")
	runRepo := NewSimRunRepo(db)
	runID, _ := runRepo.Create(envID)

	cfg := WriteBufferConfig{MaxRecords: 5, TickInterval: 1000}
	wb := NewWriteBuffer(db, runID, cfg)

	// Add 6 records — should trigger auto-flush after 5th.
	for i := 0; i < 6; i++ {
		wb.AddEvent(SimEvent{Tick: 1, EventType: "death", AgentName: "a", Details: ""})
	}

	if wb.Pending() != 1 {
		t.Fatalf("expected 1 pending after auto-flush, got %d", wb.Pending())
	}

	var rows int
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_events WHERE run_id = ?", runID).Scan(&rows)
	if rows != 5 {
		t.Fatalf("expected 5 flushed events, got %d", rows)
	}
}

func TestWriteBufferThroughput(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping throughput test in short mode")
	}

	db := mustOpenMemory(t)

	envRepo := NewEnvironmentRepo(db)
	envID, _ := envRepo.Create("Env", 100, 100, "")
	runRepo := NewSimRunRepo(db)
	runID, _ := runRepo.Create(envID)

	cfg := WriteBufferConfig{MaxRecords: 50000, TickInterval: 100}
	wb := NewWriteBuffer(db, runID, cfg)

	const totalRecords = 50000

	start := time.Now()

	for tick := 1; tick <= 500; tick++ {
		counts := make([]TickCount, 100)
		for i := range counts {
			counts[i] = TickCount{Tick: tick, Count: i + 1}
		}
		wb.AddTickCounts(tick, counts)
	}
	wb.Flush()

	elapsed := time.Since(start)
	rate := float64(totalRecords) / elapsed.Seconds()

	t.Logf("Wrote %d records in %v (%.0f records/sec)", totalRecords, elapsed, rate)

	if rate < 50000 {
		t.Logf("WARNING: throughput %.0f records/sec is below target of 50000", rate)
	}

	var rows int
	db.Conn.QueryRow("SELECT COUNT(*) FROM sim_tick_counts WHERE run_id = ?", runID).Scan(&rows)
	if rows != totalRecords {
		t.Fatalf("expected %d rows, got %d", totalRecords, rows)
	}
}
