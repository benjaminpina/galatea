// Package kernel contains the simulation engine that orchestrates all systems.
package kernel

import (
	"context"
	"fmt"
	"math/rand/v2"
	"strings"

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
	World *world.World
	DB    *storage.DB
	RunID int64

	// Grids for spatial queries.
	AgentGrid    *spatial.Grid
	ResourceGrid *spatial.Grid

	// Formula engine.
	Registry   *formulas.Registry
	Eval       *formulas.Evaluator
	EnvBuilder *formulas.EnvBuilder

	// Configuration for sub-systems.
	OntogenyCfg   systems.OntogenyConfig
	GeneticsCfg   systems.GeneticsConfig
	ReproCfg      systems.ReproductionConfig
	BehaviorCosts []int32 // Flat: [behavior * numNutrients + nutrient] = cost.
	OptimalLevels []int32 // Per nutrient: level needed for reproduction.
	Longevity     int32   // Default adult longevity (ticks).
	CombatTimeout int32   // Max ticks in combat before timeout.
	CourtTimeout  int32   // Max ticks in courtship before timeout.

	// Precomputed perception config from the DB (attractiveness tables).
	// Layouts:
	//   agentAttrArr/agentRadiiArr:       [observedIdx * NumPrototypes + perceiverIdx]
	//   resourceAttrArr/resourceRadiiArr: [resourceType * NumPrototypes + perceiverIdx]
	// Attraction defaults to 0 (no attraction); radii default to cellSize.
	agentAttrArr     []int32
	resourceAttrArr  []int32
	agentRadiiArr    []float64
	resourceRadiiArr []float64

	// Write buffer for simulation results.
	WriteBuffer *storage.WriteBuffer

	// Reusable permutation slice for agent ordering.
	permutation []int

	// Per-agent reference values (reusable, evaluated per tick).
	agentRef *systems.AgentRef

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

	// Formula registry: load custom functions from DB, then compile formulas.
	registry := formulas.NewRegistry()

	// Load user-defined custom functions.
	customFuncRows, err := db.Conn.Query(
		"SELECT name, params, body FROM custom_functions ORDER BY sort_order")
	if err == nil {
		defer customFuncRows.Close()
		for customFuncRows.Next() {
			var name, params, body string
			if err := customFuncRows.Scan(&name, &params, &body); err != nil {
				continue
			}
			paramList := splitCSV(params)
			if regErr := registry.CustomFuncs().Register(name, paramList, body); regErr != nil {
				// Log but don't fail: invalid user functions are skipped.
				_ = regErr
			}
		}
	}

	eval := formulas.NewEvaluator(128)
	envBuilder := formulas.NewEnvBuilder(eval, w.Config)

	// Compile morphology formulas from prototype_morphology table.
	// Key pattern: "morph.<prototypeID>.<characterIdx>.gen" and ".env"
	morphRows, err := db.Conn.Query(
		`SELECT pm.prototype_id, pm.character_id, pm.genetic_formula, pm.environmental_formula,
		        mc.sort_order
		 FROM prototype_morphology pm
		 JOIN morphological_characters mc ON mc.id = pm.character_id
		 ORDER BY pm.prototype_id, mc.sort_order`)
	if err == nil {
		defer morphRows.Close()
		for morphRows.Next() {
			var protoID, charID, sortOrder int64
			var genFormula, envFormula string
			if err := morphRows.Scan(&protoID, &charID, &genFormula, &envFormula, &sortOrder); err != nil {
				continue
			}
			charIdx := int(sortOrder - 1) // sort_order is 1-based
			genKey := fmt.Sprintf("morph.%d.%d.gen", protoID, charIdx)
			envKey := fmt.Sprintf("morph.%d.%d.env", protoID, charIdx)
			if compErr := registry.Compile(genKey, genFormula); compErr != nil {
				_ = compErr // Skip invalid formulas silently.
			}
			if compErr := registry.Compile(envKey, envFormula); compErr != nil {
				_ = compErr
			}
		}
	}

	// Also compile default expressions for characters without prototype overrides.
	defaultCharRows, err := db.Conn.Query(
		"SELECT id, default_expression, sort_order FROM morphological_characters ORDER BY sort_order")
	if err == nil {
		defer defaultCharRows.Close()
		for defaultCharRows.Next() {
			var charID, sortOrder int64
			var defaultExpr string
			if err := defaultCharRows.Scan(&charID, &defaultExpr, &sortOrder); err != nil {
				continue
			}
			charIdx := int(sortOrder - 1)
			key := fmt.Sprintf("morph.default.%d", charIdx)
			if compErr := registry.Compile(key, defaultExpr); compErr != nil {
				_ = compErr
			}
		}
	}

	// Compile metabolism formulas.
	metabRows, err := db.Conn.Query(
		"SELECT nutrient_id, min_formula, critical_formula, optimal_formula, max_formula FROM metabolism ORDER BY nutrient_id")
	if err == nil {
		defer metabRows.Close()
		for metabRows.Next() {
			var nutID int64
			var minF, critF, optF, maxF string
			if err := metabRows.Scan(&nutID, &minF, &critF, &optF, &maxF); err != nil {
				continue
			}
			nIdx := int(nutID - 1)
			registry.Compile(fmt.Sprintf("metabolism.%d.min", nIdx), minF)
			registry.Compile(fmt.Sprintf("metabolism.%d.critical", nIdx), critF)
			registry.Compile(fmt.Sprintf("metabolism.%d.optimal", nIdx), optF)
			registry.Compile(fmt.Sprintf("metabolism.%d.max", nIdx), maxF)
		}
	}

	// Compile prototype formulas (longevity, refractories, offspring sex ratio).
	// reference.go looks these up under the agent's PrototypeID, which the world
	// loader sets to (DB id - 1). So we compile under that same index.
	protoFormulaRows, err := db.Conn.Query(
		`SELECT id, longevity_formula, refractory_combat_formula,
		        refractory_courtship_formula, sex_ratio_males_formula,
		        sex_ratio_females_formula
		 FROM prototypes ORDER BY id`)
	if err == nil {
		defer protoFormulaRows.Close()
		for protoFormulaRows.Next() {
			var protoID int64
			var longF, refCombatF, refCourtF, ratioMF, ratioFF string
			if err := protoFormulaRows.Scan(&protoID, &longF, &refCombatF, &refCourtF, &ratioMF, &ratioFF); err != nil {
				continue
			}
			// protoID is 1-based in DB, but engine uses 0-based index.
			pIdx := int(protoID - 1)
			registry.Compile(fmt.Sprintf("prototype.%d.longevity", pIdx), longF)
			registry.Compile(fmt.Sprintf("prototype.%d.refractory_combat", pIdx), refCombatF)
			registry.Compile(fmt.Sprintf("prototype.%d.refractory_courtship", pIdx), refCourtF)
			registry.Compile(fmt.Sprintf("prototype.%d.sex_ratio_males", pIdx), ratioMF)
			registry.Compile(fmt.Sprintf("prototype.%d.sex_ratio_females", pIdx), ratioFF)
		}
	}

	// Compile behavior cost formulas.
	costRows, err := db.Conn.Query(
		"SELECT behavior, nutrient_id, cost_formula FROM behavior_costs")
	if err == nil {
		defer costRows.Close()
		for costRows.Next() {
			var behavior string
			var nutID int64
			var costF string
			if err := costRows.Scan(&behavior, &nutID, &costF); err != nil {
				continue
			}
			nIdx := int(nutID - 1)
			// Map the editor's behavior name to the engine's numeric behavior
			// index, then compile under the SAME key reference.go reads
			// ("behavior_cost.<behaviorIdx>.<nutrientIdx>"). Previously this
			// used a "behavior_cost_named.*" key that reference.go never read,
			// so the behavior_costs table had no effect at all.
			bIdx := behaviorNameToIndex(behavior, nIdx, w.Config)
			if bIdx < 0 {
				continue
			}
			registry.Compile(
				fmt.Sprintf("behavior_cost.%d.%d", bIdx, nIdx), costF)
		}
	}

	// Compile substrate velocity formulas.
	velRows, err := db.Conn.Query(
		"SELECT substrate_id, velocity_formula FROM substrate_velocities")
	if err == nil {
		defer velRows.Close()
		for velRows.Next() {
			var subID int64
			var velF string
			if err := velRows.Scan(&subID, &velF); err != nil {
				continue
			}
			registry.Compile(fmt.Sprintf("substrate_velocity.%d", subID), velF)
		}
	}

	// Load and evaluate reproduction formulas from the singleton table.
	// These are global (not per-agent), so we evaluate them once here and use
	// the values directly in reproCfg instead of hardcoded constants.
	// Defaults (used if the row is missing) mirror the schema defaults.
	reproVals := struct {
		maxGametes, maxSperm, packs, paternity, maxStored, eggsPerCycle int32
		fracFert, consumption, eggFrac, packFrac, spermDeg              float64
	}{
		maxGametes: 10, maxSperm: 10, packs: 1, paternity: 100,
		maxStored: 5, eggsPerCycle: 1,
		fracFert: 0.5, consumption: 0.1, eggFrac: 0.5, packFrac: 0.5,
		spermDeg: 0.05,
	}
	var reproRow struct {
		maxEggs, maxSperm, packs, fracFert, paternity, maxStored, consumption, eggsPerCycle, eggFrac, packFrac, spermDeg string
	}
	err = db.Conn.QueryRow(
		`SELECT max_eggs_formula, max_sperm_packs_formula, packs_transferred_formula,
		        fraction_fertilized_formula, paternity_formula, max_stored_packs_formula,
		        consumption_rate_formula, eggs_per_cycle_formula, egg_fraction_formula,
		        pack_fraction_formula, sperm_degradation_formula
		 FROM reproduction WHERE id = 1`).Scan(
		&reproRow.maxEggs, &reproRow.maxSperm, &reproRow.packs,
		&reproRow.fracFert, &reproRow.paternity, &reproRow.maxStored,
		&reproRow.consumption, &reproRow.eggsPerCycle, &reproRow.eggFrac,
		&reproRow.packFrac, &reproRow.spermDeg)
	if err == nil {
		// max_gametes is also compiled into the registry because it is
		// re-evaluated per-agent (agents may have formulas referencing their
		// own state). The rest are global scalars used directly in reproCfg.
		registry.Compile("reproduction.max_gametes", reproRow.maxEggs)

		reproVals.maxGametes = evalConstFormula(eval, reproRow.maxEggs, reproVals.maxGametes)
		reproVals.maxSperm = evalConstFormula(eval, reproRow.maxSperm, reproVals.maxSperm)
		reproVals.packs = evalConstFormula(eval, reproRow.packs, reproVals.packs)
		reproVals.paternity = evalConstFormula(eval, reproRow.paternity, reproVals.paternity)
		reproVals.maxStored = evalConstFormula(eval, reproRow.maxStored, reproVals.maxStored)
		reproVals.eggsPerCycle = evalConstFormula(eval, reproRow.eggsPerCycle, reproVals.eggsPerCycle)
		reproVals.fracFert = evalConstFloatFormula(eval, reproRow.fracFert, reproVals.fracFert)
		reproVals.consumption = evalConstFloatFormula(eval, reproRow.consumption, reproVals.consumption)
		reproVals.eggFrac = evalConstFloatFormula(eval, reproRow.eggFrac, reproVals.eggFrac)
		reproVals.packFrac = evalConstFloatFormula(eval, reproRow.packFrac, reproVals.packFrac)
		reproVals.spermDeg = evalConstFloatFormula(eval, reproRow.spermDeg, reproVals.spermDeg)
	} else {
		// No reproduction row: still register a default max_gametes so the
		// per-agent lookup has something.
		registry.Compile("reproduction.max_gametes", "10")
	}

	// Compile gamete cost formulas, keyed by sex so male and female costs are
	// kept separate ("gamete_cost.<M|F>.<nutrientIdx>"). Previously the sex was
	// dropped and whichever row compiled last won for both sexes.
	gameteCostRows, err := db.Conn.Query(
		"SELECT sex, nutrient_id, cost_formula FROM gamete_costs")
	if err == nil {
		defer gameteCostRows.Close()
		for gameteCostRows.Next() {
			var sex string
			var nutID int64
			var costF string
			if err := gameteCostRows.Scan(&sex, &nutID, &costF); err != nil {
				continue
			}
			nIdx := int(nutID - 1)
			registry.Compile(fmt.Sprintf("gamete_cost.%s.%d", sex, nIdx), costF)
		}
	}

	// Compile movement tendency formulas (relative-turn weights).
	// The editor stores a turnIndex (0..7) ordered by turn angle; the engine's
	// tendency array uses relative-direction slots (DirNW=0..DirSE=7).
	// turnSlotToEngine maps the DB turnIndex to the engine tendency slot.
	compileTendencies(db, registry, w.Config)

	// Precompute attractiveness + radius arrays from the DB. Attraction
	// defaults to 0 (no attraction); radii default to cellSize. This ensures
	// agents/resources only attract when the user configures it, instead of a
	// hardcoded constant, while still perceiving at cellSize by default.
	agentAttrArr, agentRadiiArr := buildAgentAttractiveness(db, w.Config, eval, cellSize)
	resourceAttrArr, resourceRadiiArr := buildResourceAttractiveness(db, w.Config, eval, cellSize)

	// Build write buffer.
	wb := storage.NewWriteBuffer(db, runID, cfg.WriteBufferCfg)

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
		MaxGametes:         reproVals.maxGametes,
		GameteCosts:        gameteCosts,
		PacksTransferred:   reproVals.packs,
		MaxStoredPacks:     reproVals.maxStored,
		FractionFertilized: reproVals.fracFert,
		PackFraction:       reproVals.packFrac,
		EggFraction:        reproVals.eggFrac,
		EggsPerCycle:       reproVals.eggsPerCycle,
		Paternity:          reproVals.paternity,
		ConsumptionRate:    reproVals.consumption,
		SpermDegradation:   reproVals.spermDeg,
		// Fallback sex ratio; overridden per-female in ResolveCourtshipDynamics
		// using the mother's prototype sex_ratio_males/females formulas.
		MaleRatio:   50,
		FemaleRatio: 50,
	}

	// Ontogeny config: load real stages from the DB (falls back to sensible
	// defaults only when the stages table is empty).
	stageConfigs := buildStagesFromDB(db, w.Config, numNut, eval)
	ontCfg := systems.OntogenyConfig{
		NumStages:            w.Config.NumStages,
		NumPrototypesM:       w.Config.NumPrototypesM,
		NumPrototypesF:       w.Config.NumPrototypesF,
		Stages:               stageConfigs,
		AssignmentPriorityM:  buildPriorityList(w.Config.NumPrototypesM),
		AssignmentPriorityF:  buildPriorityList(w.Config.NumPrototypesF),
		AssignmentThresholds: make([]float64, max(w.Config.NumPrototypesM, w.Config.NumPrototypesF)),
		Registry:             registry,
		Eval:                 eval,
		EnvBuilder:           envBuilder,
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
		World:            w,
		DB:               db,
		RunID:            runID,
		AgentGrid:        agentGrid,
		ResourceGrid:     resourceGrid,
		Registry:         registry,
		Eval:             eval,
		EnvBuilder:       envBuilder,
		OntogenyCfg:      ontCfg,
		GeneticsCfg:      genCfg,
		ReproCfg:         reproCfg,
		BehaviorCosts:    behaviorCosts,
		OptimalLevels:    optimalLevels,
		Longevity:        cfg.Longevity,
		CombatTimeout:    cfg.CombatTimeout,
		CourtTimeout:     cfg.CourtTimeout,
		WriteBuffer:      wb,
		permutation:      permutation,
		agentRef:         systems.NewAgentRef(numNut, numBeh),
		agentAttrArr:     agentAttrArr,
		resourceAttrArr:  resourceAttrArr,
		agentRadiiArr:    agentRadiiArr,
		resourceRadiiArr: resourceRadiiArr,
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
		AgentAttr:     e.agentAttrArr,
	}

	// 2. Generate random permutation for agent processing order.
	perm := e.shuffleAgents(a.Count)

	// 3. Perceive (in shuffled order).
	ctx.Ref = e.agentRef
	for _, idx := range perm {
		if a.Situation[idx] == world.SituationCombat || a.Situation[idx] == world.SituationCourtship {
			continue // Combat/courtship agents skip perception.
		}
		// Evaluate reference values for this agent (needed by filters + speed).
		systems.EvalRefValues(w, idx, e.Registry, e.Eval, e.EnvBuilder, e.agentRef)
		a.Speed[idx] = e.agentRef.Speed
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

	// 7. Charge nutrient costs (using per-agent evaluated costs).
	for i := 0; i < a.Count; i++ {
		systems.EvalRefValues(w, i, e.Registry, e.Eval, e.EnvBuilder, e.agentRef)
		systems.ChargeNutrients(w, i, e.agentRef.BehaviorCosts)
	}

	// 8. Physiological update (age, starvation, old age with dynamic longevity).
	for i := 0; i < a.Count; i++ {
		systems.EvalRefValues(w, i, e.Registry, e.Eval, e.EnvBuilder, e.agentRef)
		systems.UpdateAgent(w, i, e.agentRef.Longevity)
	}

	// 9. Reproduction: gametogenesis for adults at optimal reserves.
	for i := 0; i < a.Count; i++ {
		if a.StageID[i] == -1 {
			systems.EvalRefValues(w, i, e.Registry, e.Eval, e.EnvBuilder, e.agentRef)
			if systems.IsOptimalForReproduction(a, i, w.Config.NumNutrients, e.agentRef.OptimalReserves) {
				e.ReproCfg.MaxGametes = e.agentRef.MaxGametes
				e.ReproCfg.GameteCosts = e.agentRef.GameteCosts
				systems.Gametogenesis(w, i, e.ReproCfg)
			}
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
	systems.ResolveCourtshipDynamics(
		w, e.CourtTimeout, e.ReproCfg, e.GeneticsCfg,
		e.Registry, e.Eval, e.EnvBuilder, e.agentRef)

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
	// Precomputed from attractiveness_sources.radius_formula (default cellSize).
	return e.resourceRadiiArr
}

func (e *Engine) resourceAttr() []int32 {
	// Precomputed from the attractiveness_sources table (default 0 = no
	// attraction). See buildResourceAttractiveness.
	return e.resourceAttrArr
}

func (e *Engine) agentRadii() []float64 {
	// Precomputed from attractiveness_agents.radius_formula (default cellSize).
	return e.agentRadiiArr
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

// splitCSV splits a comma-separated string into trimmed parts.
// Returns nil for empty input.
func splitCSV(s string) []string {
	if s == "" {
		return nil
	}
	parts := strings.Split(s, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		trimmed := strings.TrimSpace(p)
		if trimmed != "" {
			result = append(result, trimmed)
		}
	}
	return result
}

// turnSlotToEngine maps the editor's turnIndex (0..7, ordered by turn angle)
// to the engine's relative-direction tendency slot (DirNW=0..DirSE=7).
//
// Editor turnIndex:  0=Reverse(180), 1=BackL(135), 2=HardL(90), 3=SlightL(45),
//
//	4=Straight(0),  5=SlightR(45), 6=HardR(90), 7=BackR(135)
//
// Engine slots:      DirNW=0(-45), DirN=1(0), DirNE=2(+45), DirW=3(-90),
//
//	DirE=4(+90),  DirSW=5(-135), DirS=6(180), DirSE=7(+135)
var turnSlotToEngine = [8]int{
	6, // 0 Reverse   -> DirS
	5, // 1 Back-left -> DirSW
	3, // 2 Hard-left -> DirW
	0, // 3 Slight-left -> DirNW
	1, // 4 Straight  -> DirN
	2, // 5 Slight-right -> DirNE
	4, // 6 Hard-right -> DirE
	7, // 7 Back-right -> DirSE
}

// compileTendencies loads movement tendency formulas from the DB and compiles
// them under keys "tendency.<perceiverIdx>.<engineSlot>" so the perception
// system can evaluate base tendencies per agent.
//
// The perceiver index is the unified prototype listing used by the perception
// system: stages [0..NumStages), then males, then females.
func compileTendencies(db *storage.DB, registry *formulas.Registry, cfg world.Config) {
	// --- Stage tendencies ---
	// Stage perceiverIdx = stageID - 1 (1-based DB id to 0-based index).
	stageRows, err := db.Conn.Query(
		"SELECT stage_id, turn_index, formula FROM stage_tendencies")
	if err == nil {
		defer stageRows.Close()
		for stageRows.Next() {
			var stageID int64
			var turnIndex int
			var formula string
			if err := stageRows.Scan(&stageID, &turnIndex, &formula); err != nil {
				continue
			}
			if turnIndex < 0 || turnIndex > 7 {
				continue
			}
			perceiverIdx := int(stageID - 1)
			slot := turnSlotToEngine[turnIndex]
			registry.Compile(
				fmt.Sprintf("tendency.%d.%d", perceiverIdx, slot), formula)
		}
	}

	// --- Prototype tendencies ---
	// Build prototype_id -> perceiverIdx map, matching the loader's ordering:
	// males first (by sort_order), then females (by sort_order), offset by
	// NumStages.
	protoPerceiver := make(map[int64]int)
	assignPerceiver := func(sex string, base int) {
		rows, qErr := db.Conn.Query(
			"SELECT id FROM prototypes WHERE sex = ? ORDER BY sort_order", sex)
		if qErr != nil {
			return
		}
		defer rows.Close()
		i := 0
		for rows.Next() {
			var id int64
			if err := rows.Scan(&id); err != nil {
				continue
			}
			protoPerceiver[id] = base + i
			i++
		}
	}
	assignPerceiver("M", cfg.NumStages)
	assignPerceiver("F", cfg.NumStages+cfg.NumPrototypesM)

	protoRows, err := db.Conn.Query(
		"SELECT prototype_id, turn_index, formula FROM prototype_tendencies")
	if err == nil {
		defer protoRows.Close()
		for protoRows.Next() {
			var protoID int64
			var turnIndex int
			var formula string
			if err := protoRows.Scan(&protoID, &turnIndex, &formula); err != nil {
				continue
			}
			if turnIndex < 0 || turnIndex > 7 {
				continue
			}
			perceiverIdx, ok := protoPerceiver[protoID]
			if !ok {
				continue
			}
			slot := turnSlotToEngine[turnIndex]
			registry.Compile(
				fmt.Sprintf("tendency.%d.%d", perceiverIdx, slot), formula)
		}
	}
}

// buildProtoPerceiverMap returns a map from prototype DB id to the unified
// perceiver index used by the perception system (stages [0..NumStages),
// then males by sort_order, then females by sort_order).
func buildProtoPerceiverMap(db *storage.DB, cfg world.Config) map[int64]int {
	protoPerceiver := make(map[int64]int)
	assign := func(sex string, base int) {
		rows, qErr := db.Conn.Query(
			"SELECT id FROM prototypes WHERE sex = ? ORDER BY sort_order", sex)
		if qErr != nil {
			return
		}
		defer rows.Close()
		i := 0
		for rows.Next() {
			var id int64
			if err := rows.Scan(&id); err != nil {
				continue
			}
			protoPerceiver[id] = base + i
			i++
		}
	}
	assign("M", cfg.NumStages)
	assign("F", cfg.NumStages+cfg.NumPrototypesM)
	return protoPerceiver
}

// resolvePerceiverIdx maps a (stageID, prototypeID) pair from an attractiveness
// row to the unified perceiver index. Stage takes precedence (immature agents);
// otherwise the prototype map is used. Returns -1 if it cannot be resolved.
func resolvePerceiverIdx(stageID, protoID *int64, protoMap map[int64]int) int {
	if stageID != nil {
		return int(*stageID - 1) // 1-based DB id -> 0-based stage index.
	}
	if protoID != nil {
		if idx, ok := protoMap[*protoID]; ok {
			return idx
		}
	}
	return -1
}

// evalConstFormula compiles and evaluates a formula with no agent context,
// returning defaultVal on any error. Intended for build-time scalar config
// like attractiveness weights (typically constants).
func evalConstFormula(eval *formulas.Evaluator, formula string, defaultVal int32) int32 {
	reg := formulas.NewRegistry()
	if err := reg.Compile("_tmp", formula); err != nil {
		return defaultVal
	}
	p := reg.Get("_tmp")
	if p == nil {
		return defaultVal
	}
	v, err := eval.RunProgramInt(p)
	if err != nil {
		return defaultVal
	}
	return int32(v)
}

// evalConstFloatFormula is the float64 variant of evalConstFormula, for
// fractional config values (fertilization fraction, degradation rate, etc.).
func evalConstFloatFormula(eval *formulas.Evaluator, formula string, defaultVal float64) float64 {
	reg := formulas.NewRegistry()
	if err := reg.Compile("_tmp", formula); err != nil {
		return defaultVal
	}
	p := reg.Get("_tmp")
	if p == nil {
		return defaultVal
	}
	v, err := eval.RunProgramFloat(p)
	if err != nil {
		return defaultVal
	}
	return v
}

// buildAgentAttractiveness precomputes the agent-to-agent attractiveness and
// perception-radius arrays from the attractiveness_agents table.
// Layout: [observedIdx * NumPrototypes + perceiverIdx].
// Attraction defaults to 0 (no attraction); radius defaults to defaultRadius.
func buildAgentAttractiveness(
	db *storage.DB, cfg world.Config,
	eval *formulas.Evaluator, defaultRadius float64,
) (attr []int32, radii []float64) {
	n := cfg.NumPrototypes * cfg.NumPrototypes
	attr = make([]int32, n) // all zeros (no attraction) by default
	radii = make([]float64, n)
	for i := range radii {
		radii[i] = defaultRadius
	}
	protoMap := buildProtoPerceiverMap(db, cfg)

	rows, err := db.Conn.Query(
		`SELECT observed_stage_id, observed_prototype_id,
		        perceiver_stage_id, perceiver_prototype_id,
		        attractiveness_formula, radius_formula
		 FROM attractiveness_agents`)
	if err != nil {
		return attr, radii
	}
	defer rows.Close()

	for rows.Next() {
		var obsStage, obsProto, perStage, perProto *int64
		var formula, radiusFormula string
		if err := rows.Scan(&obsStage, &obsProto, &perStage, &perProto, &formula, &radiusFormula); err != nil {
			continue
		}
		observedIdx := resolvePerceiverIdx(obsStage, obsProto, protoMap)
		perceiverIdx := resolvePerceiverIdx(perStage, perProto, protoMap)
		if observedIdx < 0 || perceiverIdx < 0 {
			continue
		}
		key := observedIdx*cfg.NumPrototypes + perceiverIdx
		if key < 0 || key >= n {
			continue
		}
		attr[key] = evalConstFormula(eval, formula, 0)
		radii[key] = float64(evalConstFormula(eval, radiusFormula, int32(defaultRadius)))
	}
	return attr, radii
}

// buildResourceAttractiveness precomputes the resource attractiveness and
// perception-radius arrays from the attractiveness_sources table.
// Layout: [resourceType * NumPrototypes + perceiverIdx].
// Attraction defaults to 0 (no attraction); radius defaults to defaultRadius.
func buildResourceAttractiveness(
	db *storage.DB, cfg world.Config,
	eval *formulas.Evaluator, defaultRadius float64,
) (attr []int32, radii []float64) {
	n := cfg.NumResourceTypes * cfg.NumPrototypes
	attr = make([]int32, n) // all zeros (no attraction) by default
	radii = make([]float64, n)
	for i := range radii {
		radii[i] = defaultRadius
	}
	protoMap := buildProtoPerceiverMap(db, cfg)

	rows, err := db.Conn.Query(
		`SELECT nutrient_id, perceiver_stage_id, perceiver_prototype_id,
		        attractiveness_formula, radius_formula
		 FROM attractiveness_sources`)
	if err != nil {
		return attr, radii
	}
	defer rows.Close()

	for rows.Next() {
		var nutrientID int64
		var perStage, perProto *int64
		var formula, radiusFormula string
		if err := rows.Scan(&nutrientID, &perStage, &perProto, &formula, &radiusFormula); err != nil {
			continue
		}
		resourceType := int(nutrientID - 1) // 1-based nutrient id -> 0-based type.
		perceiverIdx := resolvePerceiverIdx(perStage, perProto, protoMap)
		if resourceType < 0 || perceiverIdx < 0 {
			continue
		}
		key := resourceType*cfg.NumPrototypes + perceiverIdx
		if key < 0 || key >= n {
			continue
		}
		attr[key] = evalConstFormula(eval, formula, 0)
		radii[key] = float64(evalConstFormula(eval, radiusFormula, int32(defaultRadius)))
	}
	return attr, radii
}

// behaviorNameToIndex maps a canonical behavior name (shared with the editor;
// see world.BuildBehaviorNames) to the engine's numeric behavior index, for a
// given nutrient index. Returns -1 if the name is unknown.
//
// Engine behavior layout:
//
//	0            Move
//	1            Rest
//	2..2+N-1     Feed_<nutrient n>   (the generic "Feed" maps to Feed_<nIdx>)
//	2+N          Fight_Attack
//	2+N+1        Fight_Defend
//	2+N+2        Fight_Retreat
//	2+N+3        Court_Display
//	2+N+4        Court_Accept
//	2+N+5        Court_Reject
//	2+N+6        Oviposit
func behaviorNameToIndex(name string, nIdx int, cfg world.Config) int {
	feedBase := 2
	fightBase := feedBase + cfg.NumResourceTypes
	switch name {
	case "Move":
		return 0
	case "Rest":
		return 1
	case "Feed":
		if nIdx < 0 || nIdx >= cfg.NumResourceTypes {
			return -1
		}
		return feedBase + nIdx
	case "Fight_Attack":
		return fightBase + 0
	case "Fight_Defend":
		return fightBase + 1
	case "Fight_Retreat":
		return fightBase + 2
	case "Court_Display":
		return fightBase + 3
	case "Court_Accept":
		return fightBase + 4
	case "Court_Reject":
		return fightBase + 5
	case "Oviposit":
		return fightBase + 6
	default:
		return -1
	}
}

// buildStagesFromDB loads stage configurations from the `stages` and
// `stage_nutrient_requirements` tables, evaluating their formulas. The returned
// slice is ordered by sort_order so its index matches the agent StageID.
// Falls back to buildDefaultStages when the stages table is empty.
func buildStagesFromDB(
	db *storage.DB, cfg world.Config, numNut int, eval *formulas.Evaluator,
) []systems.StageConfig {
	stageRepo := storage.NewStageRepo(db)
	stages, err := stageRepo.List() // Ordered by sort_order.
	if err != nil || len(stages) == 0 {
		return buildDefaultStages(cfg.NumStages, numNut)
	}

	protoMap := buildProtoPerceiverMap(db, cfg)

	// Preload nutrient requirements/costs per stage id.
	// reqByStage[stageID][nutrientIdx] = (requirement, cost).
	type reqCost struct{ req, cost int32 }
	reqByStage := make(map[int64][]reqCost)
	reqRows, rErr := db.Conn.Query(
		`SELECT stage_id, nutrient_id, requirement_formula, cost_formula
		 FROM stage_nutrient_requirements`)
	if rErr == nil {
		defer reqRows.Close()
		for reqRows.Next() {
			var stageID, nutID int64
			var reqF, costF string
			if err := reqRows.Scan(&stageID, &nutID, &reqF, &costF); err != nil {
				continue
			}
			nIdx := int(nutID - 1)
			if nIdx < 0 || nIdx >= numNut {
				continue
			}
			if reqByStage[stageID] == nil {
				reqByStage[stageID] = make([]reqCost, numNut)
			}
			reqByStage[stageID][nIdx] = reqCost{
				req:  evalConstFormula(eval, reqF, 0),
				cost: evalConstFormula(eval, costF, 0),
			}
		}
	}

	result := make([]systems.StageConfig, len(stages))
	for i, s := range stages {
		reqs := make([]int32, numNut)
		costs := make([]int32, numNut)
		if rc := reqByStage[s.ID]; rc != nil {
			for n := 0; n < numNut; n++ {
				reqs[n] = rc[n].req
				costs[n] = rc[n].cost
			}
		}

		linked := -1
		if s.LinkedPrototypeID != nil {
			if idx, ok := protoMap[*s.LinkedPrototypeID]; ok {
				linked = idx
			}
		}

		result[i] = systems.StageConfig{
			CyclesRequired:  evalConstFormula(eval, s.CyclesFormula, 0),
			NutrientReqs:    reqs,
			NutrientCosts:   costs,
			Condition1Value: s.Condition1Value,
			Condition2Value: s.Condition2Value,
			LogicCyclesReqs: logicIsAnd(s.LogicCyclesReqs),
			LogicReqsConds:  logicIsAnd(s.LogicReqsConds),
			LogicCond1Cond2: logicIsAnd(s.LogicCond1Cond2),
			LinkedPrototype: linked,
		}
	}
	return result
}

// logicIsAnd maps the DB logic string ("AND"/"OR") to the engine's bool
// convention (true = AND).
func logicIsAnd(s string) bool {
	return s != "OR"
}
