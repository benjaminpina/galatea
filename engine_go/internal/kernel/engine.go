// Package kernel contains the simulation engine that orchestrates all systems.
package kernel

import (
	"context"
	"fmt"
	"math/rand/v2"

	"galatea/engine/internal/adapters/storage"
	"galatea/engine/internal/kernel/formulas"
	"galatea/engine/internal/kernel/spatial"
	"galatea/engine/internal/kernel/systems"
	"galatea/engine/internal/kernel/world"
)

// Engine is the main simulation controller. It loads a project from a database,
// builds the execution pipeline during the Cold Path, and runs the tick loop
// during the Hot Path.
type Engine struct {
	World    *world.World
	DB       *storage.DB
	RunID    int64

	// Grids for spatial queries.
	AgentGrid    *spatial.Grid
	ResourceGrid *spatial.Grid

	// Formula engine.
	Registry   *formulas.Registry
	Eval       *formulas.Evaluator
	EnvBuilder *formulas.EnvBuilder

	// Configuration for sub-systems.
	OntogenyCfg  systems.OntogenyConfig
	GeneticsCfg  systems.GeneticsConfig
	ReproCfg     systems.ReproductionConfig
	BehaviorCosts []int32 // Flat: [behavior * numNutrients + nutrient] = cost.
	OptimalLevels []int32 // Per nutrient: level needed for reproduction.
	Longevity     int32   // Default adult longevity (ticks).
	CombatTimeout int32   // Max ticks in combat before timeout.
	CourtTimeout  int32   // Max ticks in courtship before timeout.

	// Write buffer for simulation results.
	WriteBuffer *storage.WriteBuffer

	// Reusable permutation slice for agent ordering.
	permutation []int

	// Tick callback (optional, called after each tick with tick number).
	OnTick func(tick int64)
}

// EngineConfig holds parameters for building an engine.
type EngineConfig struct {
	EnvironmentID  int64
	CellSize       float64 // Spatial grid cell size (default: 15).
	Longevity      int32   // Default longevity if not formula-driven.
	CombatTimeout  int32   // Default: 20.
	CourtTimeout   int32   // Default: 30.
	WriteBufferCfg storage.WriteBufferConfig
}

// DefaultEngineConfig returns sensible defaults.
func DefaultEngineConfig(environmentID int64) EngineConfig {
	return EngineConfig{
		EnvironmentID:  environmentID,
		CellSize:       15.0,
		Longevity:      1000,
		CombatTimeout:  20,
		CourtTimeout:   30,
		WriteBufferCfg: storage.DefaultWriteBufferConfig(),
	}
}

// Build constructs the engine from a database (Cold Path).
// It loads the world, compiles formulas, builds spatial grids, and prepares all configs.
func Build(db *storage.DB, cfg EngineConfig) (*Engine, error) {
	// Load world from DB.
	w, err := world.Load(db, cfg.EnvironmentID)
	if err != nil {
		return nil, fmt.Errorf("engine build: load world: %w", err)
	}

	// Create simulation run record.
	runRepo := storage.NewSimRunRepo(db)
	runID, err := runRepo.Create(cfg.EnvironmentID)
	if err != nil {
		return nil, fmt.Errorf("engine build: create run: %w", err)
	}

	// Build spatial grids.
	cellSize := cfg.CellSize
	if cellSize <= 0 {
		cellSize = 15.0
	}
	agentGrid := spatial.NewGrid(cellSize, w.Agents.Cap)
	resourceGrid := spatial.NewGrid(cellSize, w.Resources.Cap)

	// Populate grids with initial positions.
	for i := 0; i < w.Agents.Count; i++ {
		agentGrid.Insert(int32(i), w.Agents.PosX[i], w.Agents.PosY[i])
	}
	for i := 0; i < w.Resources.Count; i++ {
		resourceGrid.Insert(int32(i), w.Resources.PosX[i], w.Resources.PosY[i])
	}

	// Formula registry (compile formulas from DB in future; empty for now).
	registry := formulas.NewRegistry()
	eval := formulas.NewEvaluator(128)
	envBuilder := formulas.NewEnvBuilder(eval, w.Config)

	// Build write buffer.
	wb := storage.NewWriteBuffer(db, runID, cfg.WriteBufferCfg)

	// Build perception radii (default: all elements perceive at cellSize).
	numProtos := w.Config.NumPrototypes
	numResTypes := w.Config.NumResourceTypes
	resourceRadii := make([]float64, numResTypes*numProtos)
	resourceAttr := make([]int32, numResTypes*numProtos)
	for i := range resourceRadii {
		resourceRadii[i] = cellSize
		resourceAttr[i] = 10
	}
	agentRadii := make([]float64, numProtos*numProtos)
	for i := range agentRadii {
		agentRadii[i] = cellSize
	}

	// Build default behavior costs (1 per nutrient per non-rest behavior).
	numBeh := w.Config.NumBehaviors
	numNut := w.Config.NumNutrients
	behaviorCosts := make([]int32, numBeh*numNut)
	for b := 0; b < numBeh; b++ {
		if b == 1 { // Rest has no cost.
			continue
		}
		for n := 0; n < numNut; n++ {
			behaviorCosts[b*numNut+n] = 1
		}
	}

	// Default optimal levels for reproduction.
	optimalLevels := make([]int32, numNut)
	for n := range optimalLevels {
		optimalLevels[n] = 50
	}

	// Default reproduction config.
	gameteCosts := make([]int32, numNut)
	for n := range gameteCosts {
		gameteCosts[n] = 5
	}
	reproCfg := systems.ReproductionConfig{
		MaxGametes:         10,
		GameteCosts:        gameteCosts,
		PacksTransferred:   2,
		MaxStoredPacks:     5,
		FractionFertilized: 0.5,
		PackFraction:       0.5,
		EggFraction:        0.1,
		EggsPerCycle:       2,
		Paternity:          100,
		ConsumptionRate:    0.05,
		SpermDegradation:   0.05,
		MaleRatio:          50,
		FemaleRatio:        50,
	}

	// Default ontogeny config (minimal: 1 stage then adult).
	ontCfg := systems.OntogenyConfig{
		NumStages:            w.Config.NumStages,
		NumPrototypesM:       w.Config.NumPrototypesM,
		NumPrototypesF:       w.Config.NumPrototypesF,
		Stages:               buildDefaultStages(w.Config.NumStages, numNut),
		AssignmentPriorityM:  buildPriorityList(w.Config.NumPrototypesM),
		AssignmentPriorityF:  buildPriorityList(w.Config.NumPrototypesF),
		AssignmentThresholds: make([]float64, max(w.Config.NumPrototypesM, w.Config.NumPrototypesF)),
	}

	// Genetics config (defaults: no mutation).
	genCfg := systems.GeneticsConfig{
		NumLoci:  w.Config.NumLoci,
		LociCont: make([]systems.LocusConfig, w.Config.NumLoci),
		LociDisc: make([]systems.LocusConfig, w.Config.NumLoci),
	}

	// Pre-allocate permutation slice.
	permutation := make([]int, w.Agents.Cap)

	e := &Engine{
		World:        w,
		DB:           db,
		RunID:        runID,
		AgentGrid:    agentGrid,
		ResourceGrid: resourceGrid,
		Registry:     registry,
		Eval:         eval,
		EnvBuilder:   envBuilder,
		OntogenyCfg:  ontCfg,
		GeneticsCfg:  genCfg,
		ReproCfg:     reproCfg,
		BehaviorCosts: behaviorCosts,
		OptimalLevels: optimalLevels,
		Longevity:    cfg.Longevity,
		CombatTimeout: cfg.CombatTimeout,
		CourtTimeout:  cfg.CourtTimeout,
		WriteBuffer:  wb,
		permutation:  permutation,
	}

	return e, nil
}

// Tick executes one simulation cycle.
func (e *Engine) Tick() {
	w := e.World
	a := w.Agents
	w.Tick++

	// 1. Build perception context for this tick.
	ctx := &systems.PerceptionContext{
		World:         w,
		AgentGrid:     e.AgentGrid,
		ResourceGrid:  e.ResourceGrid,
		Formulas:      e.Registry,
		Eval:          e.Eval,
		EnvBuilder:    e.EnvBuilder,
		ResourceRadii: e.resourceRadii(),
		ResourceAttr:  e.resourceAttr(),
		AgentRadii:    e.agentRadii(),
	}

	// 2. Generate random permutation for agent processing order.
	perm := e.shuffleAgents(a.Count)

	// 3. Perceive (in shuffled order).
	for _, idx := range perm {
		if a.Situation[idx] == world.SituationCombat || a.Situation[idx] == world.SituationCourtship {
			continue // Combat/courtship agents skip perception.
		}
		systems.Perceive(ctx, idx)
	}

	// 4. Decide (all agents).
	for _, idx := range perm {
		systems.Decide(w, idx)
	}

	// 5. Establish interactions.
	for _, idx := range perm {
		systems.EstablishInteraction(w, idx, e.AgentGrid, e.ResourceGrid)
	}

	// 6. Act (all agents).
	for _, idx := range perm {
		systems.Act(w, idx)
	}

	// 7. Charge nutrient costs.
	for i := 0; i < a.Count; i++ {
		systems.ChargeNutrients(w, i, e.BehaviorCosts)
	}

	// 8. Physiological update (age, starvation, old age).
	for i := 0; i < a.Count; i++ {
		systems.UpdateAgent(w, i, e.Longevity)
	}

	// 9. Reproduction: gametogenesis for adults at optimal reserves.
	for i := 0; i < a.Count; i++ {
		if a.StageID[i] == -1 && systems.IsOptimalForReproduction(a, i, w.Config.NumNutrients, e.OptimalLevels) {
			systems.Gametogenesis(w, i, e.ReproCfg)
		}
	}

	// 10. Sperm consumption for females.
	for i := 0; i < a.Count; i++ {
		if a.Sex[i] == world.SexFemale && a.StageID[i] == -1 {
			systems.SpermConsumption(w, i, e.ReproCfg)
		}
	}

	// 11. Resolve combat/courtship dynamics.
	systems.ResolveCombatDynamics(w, e.CombatTimeout)
	systems.ResolveCourtshipDynamics(w, e.CourtTimeout, e.ReproCfg, e.GeneticsCfg)

	// 12. Ontogeny: evaluate eggs and stage transitions.
	systems.EvaluateEggs(w, e.OntogenyCfg, e.GeneticsCfg)
	for i := 0; i < a.Count; i++ {
		if a.StageID[i] >= 0 {
			systems.EvaluateStageTransition(w, i, e.OntogenyCfg)
		}
	}

	// 13. Remove dead agents and rebuild spatial grid.
	removed := systems.RemoveDeadAgents(w)
	if removed > 0 {
		e.AgentGrid.Rebuild(a.Count, a.PosX, a.PosY)
	} else {
		// Update grid positions for agents that moved.
		for i := 0; i < a.Count; i++ {
			e.AgentGrid.Move(int32(i), a.PosX[i], a.PosY[i])
		}
	}

	// 14. Regenerate resources.
	systems.RegenerateResources(w)

	// 15. Reset agent states for next tick.
	systems.ResetAgentStates(w)

	// 16. Record results.
	e.recordTick()

	// 17. Callback.
	if e.OnTick != nil {
		e.OnTick(w.Tick)
	}
}

// Run executes the simulation loop until the context is cancelled or all agents die.
func (e *Engine) Run(ctx context.Context) error {
	for {
		select {
		case <-ctx.Done():
			return e.finish("aborted")
		default:
		}

		if e.World.Agents.Count == 0 {
			return e.finish("finished")
		}

		e.Tick()
	}
}

// RunTicks executes exactly n ticks.
func (e *Engine) RunTicks(n int) {
	for i := 0; i < n; i++ {
		if e.World.Agents.Count == 0 {
			break
		}
		e.Tick()
	}
}

// Finish flushes remaining data and marks the run as complete.
func (e *Engine) finish(status string) error {
	if e.WriteBuffer != nil {
		e.WriteBuffer.Flush()
	}
	if e.DB != nil {
		runRepo := storage.NewSimRunRepo(e.DB)
		runRepo.Finish(e.RunID, int(e.World.Tick), status)
	}
	return nil
}

// Finish is the public version for external callers.
func (e *Engine) Finish(status string) error {
	return e.finish(status)
}

// --- Internal helpers ---

func (e *Engine) resourceRadii() []float64 {
	numProtos := e.World.Config.NumPrototypes
	numResTypes := e.World.Config.NumResourceTypes
	n := numResTypes * numProtos
	radii := make([]float64, n)
	for i := range radii {
		radii[i] = e.AgentGrid.CellSize
	}
	return radii
}

func (e *Engine) resourceAttr() []int32 {
	numProtos := e.World.Config.NumPrototypes
	numResTypes := e.World.Config.NumResourceTypes
	n := numResTypes * numProtos
	attr := make([]int32, n)
	for i := range attr {
		attr[i] = 10
	}
	return attr
}

func (e *Engine) agentRadii() []float64 {
	numProtos := e.World.Config.NumPrototypes
	n := numProtos * numProtos
	radii := make([]float64, n)
	for i := range radii {
		radii[i] = e.AgentGrid.CellSize
	}
	return radii
}

// shuffleAgents generates a Fisher-Yates permutation of indices [0, count).
func (e *Engine) shuffleAgents(count int) []int {
	if count > len(e.permutation) {
		e.permutation = make([]int, count)
	}
	perm := e.permutation[:count]
	for i := range perm {
		perm[i] = i
	}
	rand.Shuffle(count, func(i, j int) {
		perm[i], perm[j] = perm[j], perm[i]
	})
	return perm
}

// recordTick writes population counts to the write buffer.
func (e *Engine) recordTick() {
	if e.WriteBuffer == nil {
		return
	}

	w := e.World
	a := w.Agents
	tick := int(w.Tick)

	// Count agents per stage/prototype.
	counts := make([]storage.TickCount, 0, w.Config.NumPrototypes+1)

	// Count by stage.
	for s := 0; s < w.Config.NumStages; s++ {
		c := 0
		for i := 0; i < a.Count; i++ {
			if a.StageID[i] == int32(s) {
				c++
			}
		}
		if c > 0 {
			stageID := int64(s + 1)
			counts = append(counts, storage.TickCount{Tick: tick, StageID: &stageID, Count: c})
		}
	}

	// Count by prototype (adults).
	for p := 0; p < w.Config.NumPrototypesM+w.Config.NumPrototypesF; p++ {
		c := 0
		for i := 0; i < a.Count; i++ {
			if a.StageID[i] == -1 && a.PrototypeID[i] == int32(p) {
				c++
			}
		}
		if c > 0 {
			protoID := int64(p + 1)
			counts = append(counts, storage.TickCount{Tick: tick, PrototypeID: &protoID, Count: c})
		}
	}

	// Total egg count.
	if w.Eggs.Count > 0 {
		counts = append(counts, storage.TickCount{Tick: tick, Count: w.Eggs.Count})
	}

	if len(counts) > 0 {
		e.WriteBuffer.AddTickCounts(tick, counts)
	}
}

// buildDefaultStages creates minimal stage configs.
func buildDefaultStages(numStages, numNutrients int) []systems.StageConfig {
	stages := make([]systems.StageConfig, numStages)
	for i := range stages {
		reqs := make([]int32, numNutrients)
		costs := make([]int32, numNutrients)
		for n := range reqs {
			reqs[n] = 10
			costs[n] = 2
		}
		stages[i] = systems.StageConfig{
			CyclesRequired:  int32((i + 1) * 50),
			NutrientReqs:    reqs,
			NutrientCosts:   costs,
			LogicCyclesReqs: true,
			LogicReqsConds:  false,
			LinkedPrototype: -1,
		}
	}
	return stages
}

// buildPriorityList creates a simple priority list [0, 1, 2, ...].
func buildPriorityList(n int) []int {
	list := make([]int, n)
	for i := range list {
		list[i] = i
	}
	return list
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
