package systems

import (
	"fmt"
	"galatea/engine/internal/kernel/formulas"
	"galatea/engine/internal/kernel/world"
)

// StageConfig holds transition parameters for a single life stage.
type StageConfig struct {
	CyclesRequired int32   // Minimum cycles in stage before transition.
	NutrientReqs   []int32 // Required reserve level per nutrient.
	NutrientCosts  []int32 // Cost deducted on transition per nutrient.

	// Custom conditions: each is `<formula> <op> <value>`. The formula is
	// compiled in the registry under Condition1Key/Condition2Key; its evaluated
	// result is compared against the threshold with the operator. An empty key
	// means the condition is absent (treated as neutral for its logic).
	Condition1Key   string
	Condition1Op    string
	Condition1Value float64
	Condition2Key   string
	Condition2Op    string
	Condition2Value float64

	LogicCyclesReqs bool // Legacy Y_O:    cycles vs reqs   (true=AND, false=OR).
	LogicReqsConds  bool // Legacy Y_OR:   reqs vs conds    (true=AND, false=OR).
	LogicCond1Cond2 bool // Legacy Y_OC1C2: cond1 vs cond2  (true=AND, false=OR).
	LinkedPrototype int  // Linked prototype index (-1 = unlinked).
}

// AssignmentCriterion is one prototype-assignment rule: a formula (compiled in
// the registry under Key), an operator and a threshold. The prototype is chosen
// when evalLogic(eval(Key), Op, Threshold) is true.
type AssignmentCriterion struct {
	Key       string // Registry key of the criterion formula.
	Op        string
	Threshold float64
}

// OntogenyConfig holds all stage configurations and prototype assignment criteria.
type OntogenyConfig struct {
	Stages         []StageConfig
	NumStages      int
	NumPrototypesM int
	NumPrototypesF int

	// Prototype assignment (legacy PrototipoAsignado). Priority lists give the
	// order in which prototypes are evaluated (per sex); the first prototype
	// whose criterion passes wins, else the first in the list is the default.
	// Criteria are indexed by the 0-based prototype index within the sex.
	AssignmentPriorityM []int
	AssignmentPriorityF []int
	AssignmentCriteriaM []AssignmentCriterion
	AssignmentCriteriaF []AssignmentCriterion

	// Formula engine references for morphology evaluation.
	Registry   *formulas.Registry
	Eval       *formulas.Evaluator
	EnvBuilder *formulas.EnvBuilder
}

// EvaluateEggs checks each egg for eclosion conditions and converts them to agents.
// EvaluateEggViability runs the per-tick survive/die decision for every egg,
// mirroring the legacy: an egg reads two columns from its CARRIER's interaction
// matrix — Egg_Survive and Egg_Die — and picks one by weighted roulette. If it
// picks "die", the egg is removed. If the carrier has vanished (a dead carrier
// agent), the egg is forced to die (orphaned). When neither weight is
// configured (both zero), the egg survives by default.
//
// Carrier resolution:
//   - Carrier AGENT: weights come from interaction.agent.<carrierProto>.<carrierProto>.<Egg_*>.
//   - Carrier SITE: oviposition sites are not part of the source-interaction
//     matrix (that matrix is per-nutrient), so a site-borne egg currently
//     always survives unless its site is gone. Configurable site viability is a
//     known follow-up.
//
// Must run before EvaluateEggs (eclosion) each tick.
func EvaluateEggViability(
	w *world.World,
	reg *formulas.Registry, eval *formulas.Evaluator, envBuilder *formulas.EnvBuilder,
) int {
	eggs := w.Eggs
	a := w.Agents
	cfg := w.Config
	surviveIdx := EggSurviveBehaviorIdx(cfg)
	dieIdx := EggDieBehaviorIdx(cfg)

	died := 0
	envBuilder.SetWorldVars(w)

	// Reverse iteration so swap-and-pop removals are safe.
	for i := eggs.Count - 1; i >= 0; i-- {
		carrierAgent := eggs.CarrierAgentIdx[i]
		carrierSite := eggs.CarrierResourceIdx[i]

		var survive, die int32

		switch {
		case carrierAgent >= 0:
			if int(carrierAgent) >= a.Count || a.Situation[carrierAgent] == world.SituationDead {
				// Orphaned: carrier gone → forced death.
				removeEgg(w, i)
				died++
				continue
			}
			// Evaluate the carrier's egg-viability columns. Expose the carrier's
			// own variables so the formula can depend on the carrier's state.
			envBuilder.SetAgentVars(w, int(carrierAgent))
			proto := getPerceiverIndex(a, int(carrierAgent), cfg)
			survive = evalInteractionInt(reg, eval, InteractionKeyAgent(proto, proto, surviveIdx))
			die = evalInteractionInt(reg, eval, InteractionKeyAgent(proto, proto, dieIdx))

		case carrierSite >= 0:
			if int(carrierSite) >= w.Resources.Count ||
				w.Resources.TypeID[carrierSite] != world.ResourceTypeOvipositionSite {
				// Site gone → forced death.
				removeEgg(w, i)
				died++
				continue
			}
			// Site viability is not configurable via the current matrices;
			// default to survival (survive=1, die=0).
			survive, die = 1, 0

		default:
			// No carrier at all → forced death.
			removeEgg(w, i)
			died++
			continue
		}

		// Roulette between survive and die. If both are zero, survive.
		if survive == 0 && die == 0 {
			continue
		}
		weights := []int32{survive, die}
		if Roulette(weights) == 1 { // index 1 = die
			removeEgg(w, i)
			died++
		}
	}
	return died
}

// evalInteractionInt evaluates a compiled interaction formula by key, returning
// 0 when the key is absent or evaluation fails.
func evalInteractionInt(reg *formulas.Registry, eval *formulas.Evaluator, key string) int32 {
	p := reg.Get(key)
	if p == nil {
		return 0
	}
	v, err := eval.RunProgramInt(p)
	if err != nil {
		return 0
	}
	return int32(v)
}

// Returns the number of eggs that eclosed.
func EvaluateEggs(w *world.World, ontCfg OntogenyConfig, genCfg GeneticsConfig) int {
	eggs := w.Eggs
	eclosed := 0

	// Process in reverse to safely remove during iteration.
	for i := eggs.Count - 1; i >= 0; i-- {
		if shouldEclose(w, i, ontCfg) {
			ecloseEgg(w, i, ontCfg, genCfg)
			removeEgg(w, i)
			eclosed++
		}
	}
	return eclosed
}

// shouldEclose evaluates whether an egg meets the first stage's transition conditions.
func shouldEclose(w *world.World, idx int, ontCfg OntogenyConfig) bool {
	if ontCfg.NumStages == 0 || len(ontCfg.Stages) == 0 {
		return false
	}

	eggs := w.Eggs
	cfg := w.Config
	stage := ontCfg.Stages[0] // Eclosion uses the first stage's conditions.
	age := eggs.Age[idx]

	// Condition: cycles in egg >= required.
	cyclesMet := age >= stage.CyclesRequired

	// Condition: reserves meet requirements.
	reqsMet := true
	numNut := cfg.NumNutrients
	resBase := idx * numNut
	for n := 0; n < numNut && n < len(stage.NutrientReqs); n++ {
		if eggs.Reserves[resBase+n] < stage.NutrientReqs[n] {
			reqsMet = false
			break
		}
	}

	// Custom conditions of the eclosion stage, combined per its cond logic.
	condsMet := evalStageConditionsEgg(w, idx, stage, ontCfg)

	return combineLogic(cyclesMet, reqsMet, condsMet, stage.LogicCyclesReqs, stage.LogicReqsConds)
}

// ecloseEgg converts an egg into a new agent (immature, first stage).
func ecloseEgg(w *world.World, eggIdx int, ontCfg OntogenyConfig, genCfg GeneticsConfig) {
	eggs := w.Eggs
	cfg := w.Config
	numLoci := cfg.NumLoci
	numNut := cfg.NumNutrients

	// Resolve the eclosion position from the CURRENT carrier position: a
	// carrier agent may have moved since the egg was laid (the legacy reads
	// Huevo.Portador.X/Y at eclosion). Fall back to the egg's stored position
	// if the carrier is gone.
	hatchX, hatchY := eggs.PosX[eggIdx], eggs.PosY[eggIdx]
	if carrierIdx := eggs.CarrierAgentIdx[eggIdx]; carrierIdx >= 0 && int(carrierIdx) < w.Agents.Count {
		hatchX, hatchY = w.Agents.PosX[carrierIdx], w.Agents.PosY[carrierIdx]
	} else if siteIdx := eggs.CarrierResourceIdx[eggIdx]; siteIdx >= 0 && int(siteIdx) < w.Resources.Count {
		hatchX, hatchY = w.Resources.PosX[siteIdx], w.Resources.PosY[siteIdx]
	}

	// Create new agent.
	agentIdx := w.AddAgent()
	a := w.Agents

	// Transfer position (from the carrier at eclosion time).
	a.PosX[agentIdx] = hatchX
	a.PosY[agentIdx] = hatchY

	// Set identity: immature, first stage after egg.
	startStage := int32(0)
	if ontCfg.NumStages > 1 {
		startStage = 1 // Stage 0 = egg (just eclosed), start at stage 1.
	}
	a.StageID[agentIdx] = startStage
	a.PrototypeID[agentIdx] = -1
	a.Sex[agentIdx] = eggs.Sex[eggIdx]
	a.Age[agentIdx] = 0
	a.Situation[agentIdx] = world.SituationImmature
	a.Direction[agentIdx] = uint8(1 + eggs.Age[eggIdx]%8) // Pseudo-random direction.
	a.Speed[agentIdx] = 1

	// Transfer reserves (minus eclosion costs).
	eggResBase := eggIdx * numNut
	agentResBase := agentIdx * numNut
	for n := 0; n < numNut; n++ {
		reserve := eggs.Reserves[eggResBase+n]
		if len(ontCfg.Stages) > 0 && n < len(ontCfg.Stages[0].NutrientCosts) {
			reserve -= ontCfg.Stages[0].NutrientCosts[n]
		}
		if reserve < 0 {
			reserve = 0
		}
		a.Reserves[agentResBase+n] = reserve
	}

	// Transfer genotype.
	genoSize := numLoci * 2
	eggGenoBase := eggIdx * genoSize
	agentGenoBase := agentIdx * genoSize
	copy(a.GenotypeCont[agentGenoBase:agentGenoBase+genoSize], eggs.GenotypeCont[eggGenoBase:eggGenoBase+genoSize])
	copy(a.GenotypeDisc[agentGenoBase:agentGenoBase+genoSize], eggs.GenotypeDisc[eggGenoBase:eggGenoBase+genoSize])
	copy(a.DominanceCont[agentGenoBase:agentGenoBase+genoSize], eggs.DominanceCont[eggGenoBase:eggGenoBase+genoSize])
	copy(a.DominanceDisc[agentGenoBase:agentGenoBase+genoSize], eggs.DominanceDisc[eggGenoBase:eggGenoBase+genoSize])
}

// removeEgg removes an egg by swapping with the last and decrementing Count.
// It first releases the egg's slot on its carrier: an oviposition site's egg
// count (Level) or a carrier agent's CarriedEggs count is decremented, so the
// carrier's bookkeeping stays correct after the egg ecloses or dies (mirrors
// the legacy THuevo.Destroy, which decrements Acarreados/Nivel on the carrier).
func removeEgg(w *world.World, idx int) {
	eggs := w.Eggs

	// Free the slot the egg occupied on its carrier.
	if siteIdx := eggs.CarrierResourceIdx[idx]; siteIdx >= 0 && int(siteIdx) < w.Resources.Count {
		if w.Resources.TypeID[siteIdx] == world.ResourceTypeOvipositionSite && w.Resources.Level[siteIdx] > 0 {
			w.Resources.Level[siteIdx]--
		}
	} else if carrierIdx := eggs.CarrierAgentIdx[idx]; carrierIdx >= 0 && int(carrierIdx) < w.Agents.Count {
		if w.Agents.CarriedEggs[carrierIdx] > 0 {
			w.Agents.CarriedEggs[carrierIdx]--
		}
	}

	last := eggs.Count - 1
	if idx != last {
		swapEggs(eggs, idx, last, w.Config)
	}
	eggs.Count--
}

// swapEggs swaps all data between two egg indices.
func swapEggs(eggs *world.EggArrays, i, j int, cfg world.Config) {
	numLoci := cfg.NumLoci
	numNut := cfg.NumNutrients
	genoSize := numLoci * 2

	eggs.PosX[i], eggs.PosX[j] = eggs.PosX[j], eggs.PosX[i]
	eggs.PosY[i], eggs.PosY[j] = eggs.PosY[j], eggs.PosY[i]
	eggs.Age[i], eggs.Age[j] = eggs.Age[j], eggs.Age[i]
	eggs.Sex[i], eggs.Sex[j] = eggs.Sex[j], eggs.Sex[i]
	eggs.CarrierAgentIdx[i], eggs.CarrierAgentIdx[j] = eggs.CarrierAgentIdx[j], eggs.CarrierAgentIdx[i]
	eggs.CarrierResourceIdx[i], eggs.CarrierResourceIdx[j] = eggs.CarrierResourceIdx[j], eggs.CarrierResourceIdx[i]
	eggs.ParentMale[i], eggs.ParentMale[j] = eggs.ParentMale[j], eggs.ParentMale[i]
	eggs.ParentFemale[i], eggs.ParentFemale[j] = eggs.ParentFemale[j], eggs.ParentFemale[i]

	// Reserves.
	for n := 0; n < numNut; n++ {
		eggs.Reserves[i*numNut+n], eggs.Reserves[j*numNut+n] = eggs.Reserves[j*numNut+n], eggs.Reserves[i*numNut+n]
	}
	// Genotype.
	for k := 0; k < genoSize; k++ {
		eggs.GenotypeCont[i*genoSize+k], eggs.GenotypeCont[j*genoSize+k] = eggs.GenotypeCont[j*genoSize+k], eggs.GenotypeCont[i*genoSize+k]
		eggs.GenotypeDisc[i*genoSize+k], eggs.GenotypeDisc[j*genoSize+k] = eggs.GenotypeDisc[j*genoSize+k], eggs.GenotypeDisc[i*genoSize+k]
		eggs.DominanceCont[i*genoSize+k], eggs.DominanceCont[j*genoSize+k] = eggs.DominanceCont[j*genoSize+k], eggs.DominanceCont[i*genoSize+k]
		eggs.DominanceDisc[i*genoSize+k], eggs.DominanceDisc[j*genoSize+k] = eggs.DominanceDisc[j*genoSize+k], eggs.DominanceDisc[i*genoSize+k]
	}
	// VDecision.
	eggs.VDecision[i*2], eggs.VDecision[j*2] = eggs.VDecision[j*2], eggs.VDecision[i*2]
	eggs.VDecision[i*2+1], eggs.VDecision[j*2+1] = eggs.VDecision[j*2+1], eggs.VDecision[i*2+1]
}

// EvaluateStageTransition checks if an immature agent should advance to the next stage
// or become an adult. Returns true if a transition occurred.
func EvaluateStageTransition(w *world.World, idx int, ontCfg OntogenyConfig) bool {
	a := w.Agents
	cfg := w.Config
	currentStage := int(a.StageID[idx])

	if currentStage < 0 || currentStage >= ontCfg.NumStages {
		return false // Already adult or invalid.
	}
	if currentStage >= len(ontCfg.Stages) {
		return false
	}

	stage := ontCfg.Stages[currentStage]

	// Evaluate transition conditions.
	cyclesMet := a.TimeInStage[idx] >= stage.CyclesRequired

	reqsMet := true
	numNut := cfg.NumNutrients
	resBase := idx * numNut
	for n := 0; n < numNut && n < len(stage.NutrientReqs); n++ {
		if a.Reserves[resBase+n] < stage.NutrientReqs[n] {
			reqsMet = false
			break
		}
	}

	// Evaluate the custom conditions (formula op value), combined per the
	// stage's cond1/cond2 logic.
	condsMet := evalStageConditionsAgent(w, idx, stage, ontCfg)

	shouldTransition := combineLogic(cyclesMet, reqsMet, condsMet, stage.LogicCyclesReqs, stage.LogicReqsConds)
	if !shouldTransition {
		return false
	}

	// Deduct transition costs.
	for n := 0; n < numNut && n < len(stage.NutrientCosts); n++ {
		a.Reserves[resBase+n] -= stage.NutrientCosts[n]
		if a.Reserves[resBase+n] < 0 {
			a.Reserves[resBase+n] = 0
		}
	}

	// Advance to the next stage (which may be a prototype-linked branch) or
	// become adult.
	nextStage := nextStageFor(w, idx, currentStage, ontCfg)
	if nextStage >= ontCfg.NumStages {
		// Become adult.
		becomeAdult(w, idx, ontCfg)
	} else {
		a.StageID[idx] = int32(nextStage)
		a.TimeInStage[idx] = 0
	}

	return true
}

// nextStageFor determines the stage an immature agent advances to from
// currentStage, mirroring the legacy SiguienteEstadio with prototype-linked
// branching:
//
//   - If the immediately following stage is NOT linked to a prototype
//     (LinkedPrototype < 0), advance linearly to currentStage+1.
//   - If it IS linked, the agent takes the branch matching its (tentatively)
//     assigned prototype: among the remaining stages, pick the FIRST whose
//     LinkedPrototype matches the assigned prototype's unified index, or is
//     unlinked. (The legacy takes the last match; per project decision we take
//     the first.)
//
// Returns a stage index; a value >= NumStages means "become adult".
func nextStageFor(w *world.World, idx, currentStage int, ontCfg OntogenyConfig) int {
	next := currentStage + 1
	if next >= ontCfg.NumStages {
		return next // Becomes adult.
	}

	// If the next stage is unlinked, simple linear advance. A stage is
	// "linked" only when it points at an actual adult prototype, whose unified
	// index is >= NumStages; any value below that (including the -1 sentinel
	// and the Go zero value) means unlinked. This mirrors the legacy where
	// Prototipo=0 means "not linked".
	if next >= len(ontCfg.Stages) || !isLinkedPrototype(ontCfg.Stages[next].LinkedPrototype, ontCfg.NumStages) {
		return next
	}

	// The next stage is prototype-linked: resolve the agent's tentative
	// prototype and pick the first matching (or unlinked) branch.
	assignedUnified := assignedPrototypeUnifiedIdx(w, idx, ontCfg)
	for s := next; s < ontCfg.NumStages && s < len(ontCfg.Stages); s++ {
		linked := ontCfg.Stages[s].LinkedPrototype
		if !isLinkedPrototype(linked, ontCfg.NumStages) || linked == assignedUnified {
			return s
		}
	}
	// No matching branch: proceed to adulthood.
	return ontCfg.NumStages
}

// isLinkedPrototype reports whether a stage's LinkedPrototype value refers to an
// actual adult prototype (unified index >= numStages). Values below that —
// including -1 and the zero default — mean the stage is not prototype-linked.
func isLinkedPrototype(linked, numStages int) bool {
	return linked >= numStages
}

// assignedPrototypeUnifiedIdx returns the unified prototype index (stages, then
// males, then females — the same space LinkedPrototype uses) of the prototype
// the agent would be assigned, so it can be compared against a stage's
// LinkedPrototype.
func assignedPrototypeUnifiedIdx(w *world.World, idx int, ontCfg OntogenyConfig) int {
	a := w.Agents
	protoWithinSex := AssignPrototype(w, idx, ontCfg)
	base := ontCfg.NumStages
	if a.Sex[idx] == world.SexFemale {
		base += ontCfg.NumPrototypesM
	}
	return base + protoWithinSex
}

// becomeAdult transitions an agent from immature to adult status.
func becomeAdult(w *world.World, idx int, ontCfg OntogenyConfig) {
	a := w.Agents

	// Assign prototype.
	protoIdx := AssignPrototype(w, idx, ontCfg)
	a.PrototypeID[idx] = int32(protoIdx)
	a.StageID[idx] = -1
	a.Situation[idx] = world.SituationRegular
	a.TimeInStage[idx] = 0

	// Fix morphology.
	FixMorphology(w, idx, ontCfg.Registry, ontCfg.Eval, ontCfg.EnvBuilder)
}

// AssignPrototype determines which adult prototype an agent receives, mirroring
// the legacy PrototipoAsignado: prototypes are evaluated in priority order and
// the first whose criterion (formula op threshold) passes wins; if none pass,
// the first prototype in the priority list is the default. With a single
// prototype for the sex, that prototype is returned directly. Returns the
// 0-based prototype index within the sex.
func AssignPrototype(w *world.World, idx int, ontCfg OntogenyConfig) int {
	a := w.Agents
	sex := a.Sex[idx]

	var priorities []int
	var criteria []AssignmentCriterion
	if sex == world.SexMale {
		priorities = ontCfg.AssignmentPriorityM
		criteria = ontCfg.AssignmentCriteriaM
	} else {
		priorities = ontCfg.AssignmentPriorityF
		criteria = ontCfg.AssignmentCriteriaF
	}

	// No priorities, or a single prototype: assign the first available.
	if len(priorities) == 0 {
		return 0
	}
	if len(priorities) == 1 {
		return priorities[0]
	}

	// Set up the evaluator with this agent's variables so criterion formulas
	// can reference its morphology/genetics/physiology.
	if ontCfg.Registry != nil && ontCfg.Eval != nil && ontCfg.EnvBuilder != nil {
		ontCfg.EnvBuilder.SetWorldVars(w)
		ontCfg.EnvBuilder.SetAgentVars(w, idx)

		for _, protoIdx := range priorities {
			if protoIdx < 0 || protoIdx >= len(criteria) {
				continue
			}
			c := criteria[protoIdx]
			if c.Key == "" {
				continue
			}
			p := ontCfg.Registry.Get(c.Key)
			if p == nil {
				continue
			}
			val, err := ontCfg.Eval.RunProgramFloat(p)
			if err != nil {
				continue
			}
			if evalLogic(val, c.Op, c.Threshold) {
				return protoIdx
			}
		}
	}

	// Default: first in priority order.
	return priorities[0]
}

// FixMorphology freezes the genetically-determined morphological values for an adult agent.
// After this, morphology no longer changes (congenital traits fixed at maturity).
// FixMorphology computes and freezes the morphological character values for an adult agent.
// Each character's value is computed by evaluating its formula (which can reference
// genetic loci CL_X/DL_X, age, reserves, or any other available variable).
//
// The formula lookup order:
// 1. Per-prototype formula: "morph.<prototypeID>.<charIdx>.gen"
// 2. Default character formula: "morph.default.<charIdx>"
// 3. Fallback: expressed locus value at same index (if exists), or 0
func FixMorphology(w *world.World, idx int, reg *formulas.Registry, eval *formulas.Evaluator, envBuilder *formulas.EnvBuilder) {
	a := w.Agents
	cfg := w.Config
	numChars := cfg.NumCharacters
	numLoci := cfg.NumLoci
	morphBase := idx * numChars
	protoID := a.PrototypeID[idx]

	// Set up evaluator environment with this agent's variables.
	envBuilder.SetWorldVars(w)
	envBuilder.SetAgentVars(w, idx)

	for char := 0; char < numChars; char++ {
		var value float64
		evaluated := false

		// Try per-prototype formula first.
		if protoID >= 0 {
			// Prototype IDs in DB are 1-based, but protoID in engine is 0-based index.
			// The formula key uses the DB prototype ID. We need to compute it.
			// For now, use the 0-based index + 1 as approximation for DB ID.
			dbProtoID := int(protoID) + 1
			genKey := fmt.Sprintf("morph.%d.%d.gen", dbProtoID, char)
			if prog := reg.Get(genKey); prog != nil {
				result, err := eval.RunProgramFloat(prog)
				if err == nil {
					value = result
					evaluated = true
				}
			}
		}

		// Try default character formula.
		if !evaluated {
			defaultKey := fmt.Sprintf("morph.default.%d", char)
			if prog := reg.Get(defaultKey); prog != nil {
				result, err := eval.RunProgramFloat(prog)
				if err == nil {
					value = result
					evaluated = true
				}
			}
		}

		// Final fallback: expressed locus value at same index.
		if !evaluated {
			if char < numLoci {
				value = ExpressLocusCont(a.GenotypeCont, a.DominanceCont, idx, char, numLoci)
			}
		}

		a.MorphologyCont[morphBase+char] = value

		// Discrete version: same logic but with int.
		var discValue int32
		if !evaluated && char < numLoci {
			discValue = ExpressLocusDisc(a.GenotypeDisc, a.DominanceDisc, idx, char, numLoci)
		} else {
			discValue = int32(value)
		}
		a.MorphologyDisc[morphBase+char] = discValue
	}
	a.MorphologyFixed[idx] = true
}

// --- Combat/Courtship dynamics ---

// ResolveCombatDynamics checks combat interactions and resolves timeouts.
// If both agents have been in combat for more than maxTicks, the initiator retreats.
func ResolveCombatDynamics(w *world.World, maxTicks int32) {
	a := w.Agents
	for i := 0; i < a.Count; i++ {
		if a.Situation[i] != world.SituationCombat {
			continue
		}
		if a.TimeInInteraction[i] > maxTicks {
			// Timeout: this agent retreats.
			interactant := a.InteractantIdx[i]
			if interactant >= 0 && int(interactant) < a.Count {
				winCombat(a, int(interactant))
			}
			a.Situation[i] = world.SituationRegular
			a.InteractantIdx[i] = -1
			a.TimeInInteraction[i] = 0
		}
	}
}

// ResolveCourtshipDynamics checks courtship interactions and resolves mutual acceptance
// into copulation, or timeouts into rejection.
func ResolveCourtshipDynamics(
	w *world.World, maxTicks int32, reproCfg ReproductionConfig,
	genCfg GeneticsConfig,
	reg *formulas.Registry, eval *formulas.Evaluator,
	envBuilder *formulas.EnvBuilder, ref *AgentRef,
) int {
	a := w.Agents
	copulations := 0

	for i := 0; i < a.Count; i++ {
		if a.Situation[i] != world.SituationCourtship {
			continue
		}

		interactant := a.InteractantIdx[i]
		if interactant < 0 || int(interactant) >= a.Count {
			rejectCourtship(a, i)
			continue
		}

		// Check for mutual acceptance: both signaled accept (LastOpponentAction == 3).
		if a.LastOpponentAction[i] == 3 && a.LastOpponentAction[interactant] == 3 {
			// Copulation! Determine male/female.
			maleIdx, femaleIdx := i, int(interactant)
			if a.Sex[i] == world.SexFemale {
				maleIdx, femaleIdx = int(interactant), i
			}
			// Offspring sex ratio comes from the FEMALE's prototype. Evaluate
			// it per-copulation so each mother uses her own configured ratio
			// instead of a hardcoded 50/50.
			cfgForPair := reproCfg
			if reg != nil && eval != nil && ref != nil {
				EvalRefValues(w, femaleIdx, reg, eval, envBuilder, ref)
				cfgForPair.MaleRatio = int(ref.SexRatioMales)
				cfgForPair.FemaleRatio = int(ref.SexRatioFemales)
			}
			Copulate(w, maleIdx, femaleIdx, cfgForPair, genCfg)
			copulations++
			continue
		}

		// Timeout.
		if a.TimeInInteraction[i] > maxTicks {
			rejectCourtship(a, i)
			if int(interactant) < a.Count {
				rejectCourtship(a, int(interactant))
			}
		}
	}
	return copulations
}

// --- Logic helpers ---

// combineLogic applies the legacy 3-level boolean logic:
// result = logic1(cycles, reqs) logic2(prev_result, conditions)
// combineLogic combines the three transition predicates exactly as the legacy
// EvaluaPasoEstadio/EvaluaHuevo does, respecting Pascal operator precedence
// (and > or). logicCyclesReqs is the legacy Y_O flag (cycles vs reqs) and
// logicReqsConds is Y_OR (reqs vs conds). The four cases are:
//
//	Y_O=T Y_OR=T : cycles AND reqs AND conds
//	Y_O=F Y_OR=T : cycles OR (reqs AND conds)
//	Y_O=T Y_OR=F : (cycles AND reqs) OR conds
//	Y_O=F Y_OR=F : cycles OR reqs OR conds
func combineLogic(cycles, reqs, conds bool, logicCyclesReqs, logicReqsConds bool) bool {
	switch {
	case logicCyclesReqs && logicReqsConds:
		return cycles && reqs && conds
	case !logicCyclesReqs && logicReqsConds:
		return cycles || (reqs && conds)
	case logicCyclesReqs && !logicReqsConds:
		return (cycles && reqs) || conds
	default: // !logicCyclesReqs && !logicReqsConds
		return cycles || reqs || conds
	}
}

// evalStageConditionsAgent evaluates a stage's custom conditions for an AGENT
// (exposing the agent's variables), combined per the stage's cond1/cond2 logic.
func evalStageConditionsAgent(w *world.World, idx int, stage StageConfig, ontCfg OntogenyConfig) bool {
	return evalStageConditions(stage, ontCfg, func() {
		ontCfg.EnvBuilder.SetWorldVars(w)
		ontCfg.EnvBuilder.SetAgentVars(w, idx)
	})
}

// evalStageConditionsEgg evaluates the eclosion stage's custom conditions for an
// EGG (exposing the egg's variables), combined per the stage's cond1/cond2 logic.
func evalStageConditionsEgg(w *world.World, eggIdx int, stage StageConfig, ontCfg OntogenyConfig) bool {
	return evalStageConditions(stage, ontCfg, func() {
		ontCfg.EnvBuilder.SetWorldVars(w)
		ontCfg.EnvBuilder.SetEggVars(w, eggIdx)
	})
}

// evalStageConditions evaluates a stage's two custom conditions (each a
// compiled formula compared to a threshold via an operator) and combines them
// with the stage's cond1/cond2 logic (LogicCond1Cond2: true=AND, false=OR),
// mirroring the legacy EvaluaPasoEstadio condition block. A condition with an
// empty formula key is treated as neutral for the combining operator (AND→true,
// OR→false) so it doesn't distort the result. setupVars exposes the evaluating
// entity's variables (agent or egg) before the formulas are evaluated.
func evalStageConditions(stage StageConfig, ontCfg OntogenyConfig, setupVars func()) bool {
	reg, eval, env := ontCfg.Registry, ontCfg.Eval, ontCfg.EnvBuilder

	has1 := stage.Condition1Key != ""
	has2 := stage.Condition2Key != ""

	// When NO custom condition is configured, conditions must not influence the
	// stage transition. The "conds" predicate is combined with the rest via
	// LogicReqsConds (Y_OR): the neutral element there is true for AND and false
	// for OR. Returning that neutral keeps unconfigured conditions inert.
	if !has1 && !has2 {
		return stage.LogicReqsConds
	}
	if reg == nil || eval == nil || env == nil {
		return stage.LogicReqsConds
	}
	setupVars()

	// Evaluate a single condition; an unconfigured one is neutral for the
	// cond1/cond2 combining operator (AND→true, OR→false).
	evalCond := func(key, op string, threshold float64) bool {
		if key == "" {
			return stage.LogicCond1Cond2
		}
		p := reg.Get(key)
		if p == nil {
			return stage.LogicCond1Cond2
		}
		v, err := eval.RunProgramFloat(p)
		if err != nil {
			return stage.LogicCond1Cond2
		}
		return evalLogic(v, op, threshold)
	}

	c1 := evalCond(stage.Condition1Key, stage.Condition1Op, stage.Condition1Value)
	c2 := evalCond(stage.Condition2Key, stage.Condition2Op, stage.Condition2Value)

	if stage.LogicCond1Cond2 {
		return c1 && c2
	}
	return c1 || c2
}

// evalLogic implements the legacy Logica(v1, op, v2): compares two reals with
// the given string operator. Unknown operators fall back to equality, matching
// the legacy OpLogico default.
func evalLogic(v1 float64, op string, v2 float64) bool {
	switch op {
	case "=":
		return v1 == v2
	case "<>":
		return v1 != v2
	case "<":
		return v1 < v2
	case ">":
		return v1 > v2
	case "<=", "=<":
		return v1 <= v2
	case ">=", "=>":
		return v1 >= v2
	default:
		return v1 == v2
	}
}
