package systems

import (
	"galatea/engine/internal/kernel/world"
)

// StageConfig holds transition parameters for a single life stage.
type StageConfig struct {
	CyclesRequired   int32   // Minimum cycles in stage before transition.
	NutrientReqs     []int32 // Required reserve level per nutrient.
	NutrientCosts    []int32 // Cost deducted on transition per nutrient.
	Condition1Value  float64 // Custom condition 1 threshold.
	Condition2Value  float64 // Custom condition 2 threshold.
	LogicCyclesReqs  bool    // true=AND, false=OR between cycles and requirements.
	LogicReqsConds   bool    // true=AND, false=OR between requirements and conditions.
	LogicCond1Cond2  bool    // true=AND, false=OR between condition1 and condition2.
	LinkedPrototype  int     // Linked prototype index (-1 = unlinked).
}

// OntogenyConfig holds all stage configurations and prototype assignment criteria.
type OntogenyConfig struct {
	Stages             []StageConfig
	NumStages          int
	NumPrototypesM     int
	NumPrototypesF     int
	// AssignmentCriteria: indexed [prototypeIdx] = threshold value.
	// Evaluated in priority order; first match wins.
	AssignmentPriorityM []int // Prototype indices in evaluation order (males).
	AssignmentPriorityF []int // Prototype indices in evaluation order (females).
	AssignmentThresholds []float64 // Threshold per prototype index.
}

// EvaluateEggs checks each egg for eclosion conditions and converts them to agents.
// Returns the number of eggs that eclosed.
func EvaluateEggs(w *world.World, ontCfg OntogenyConfig, genCfg GeneticsConfig) int {
	eggs := w.Eggs
	eclosed := 0

	// Process in reverse to safely remove during iteration.
	for i := eggs.Count - 1; i >= 0; i-- {
		if shouldEclose(eggs, i, ontCfg, w.Config) {
			ecloseEgg(w, i, ontCfg, genCfg)
			removeEgg(w, i)
			eclosed++
		}
	}
	return eclosed
}

// shouldEclose evaluates whether an egg meets the first stage's transition conditions.
func shouldEclose(eggs *world.EggArrays, idx int, ontCfg OntogenyConfig, cfg world.Config) bool {
	if ontCfg.NumStages == 0 || len(ontCfg.Stages) == 0 {
		return false
	}

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

	// Combine with logic operators (simplified: conditions always true for eggs).
	if stage.LogicCyclesReqs {
		return cyclesMet && reqsMet
	}
	return cyclesMet || reqsMet
}

// ecloseEgg converts an egg into a new agent (immature, first stage).
func ecloseEgg(w *world.World, eggIdx int, ontCfg OntogenyConfig, genCfg GeneticsConfig) {
	eggs := w.Eggs
	cfg := w.Config
	numLoci := cfg.NumLoci
	numNut := cfg.NumNutrients

	// Create new agent.
	agentIdx := w.AddAgent()
	a := w.Agents

	// Transfer position.
	a.PosX[agentIdx] = eggs.PosX[eggIdx]
	a.PosY[agentIdx] = eggs.PosY[eggIdx]

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
func removeEgg(w *world.World, idx int) {
	eggs := w.Eggs
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

	// Conditions (simplified: always met for now; full formula eval in engine).
	condsMet := true

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

	// Advance to next stage or become adult.
	nextStage := currentStage + 1
	if nextStage >= ontCfg.NumStages {
		// Become adult.
		becomeAdult(w, idx, ontCfg)
	} else {
		a.StageID[idx] = int32(nextStage)
		a.TimeInStage[idx] = 0
	}

	return true
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
	FixMorphology(w, idx)
}

// AssignPrototype determines which adult prototype an agent receives based on
// hierarchical criteria evaluation. Returns the 0-based prototype index.
func AssignPrototype(w *world.World, idx int, ontCfg OntogenyConfig) int {
	a := w.Agents
	sex := a.Sex[idx]

	var priorities []int
	if sex == world.SexMale {
		priorities = ontCfg.AssignmentPriorityM
	} else {
		priorities = ontCfg.AssignmentPriorityF
	}

	// If no priorities defined, assign first available prototype.
	if len(priorities) == 0 {
		return 0
	}

	// Evaluate criteria in priority order (simplified: use genetic expression as criteria).
	// In full implementation, this evaluates formula from AssignmentCriteria table.
	// For now, assign based on the first locus expressed value vs threshold.
	numLoci := w.Config.NumLoci
	if numLoci > 0 && len(ontCfg.AssignmentThresholds) > 0 {
		expressed := ExpressLocusCont(a.GenotypeCont, a.DominanceCont, idx, 0, numLoci)
		for _, protoIdx := range priorities {
			if protoIdx < len(ontCfg.AssignmentThresholds) {
				if expressed >= ontCfg.AssignmentThresholds[protoIdx] {
					return protoIdx
				}
			}
		}
	}

	// Default: first in priority list.
	return priorities[0]
}

// FixMorphology freezes the genetically-determined morphological values for an adult agent.
// After this, morphology no longer changes (congenital traits fixed at maturity).
func FixMorphology(w *world.World, idx int) {
	a := w.Agents
	numLoci := w.Config.NumLoci
	morphBase := idx * numLoci

	for locus := 0; locus < numLoci; locus++ {
		a.MorphologyCont[morphBase+locus] = ExpressLocusCont(a.GenotypeCont, a.DominanceCont, idx, locus, numLoci)
		a.MorphologyDisc[morphBase+locus] = ExpressLocusDisc(a.GenotypeDisc, a.DominanceDisc, idx, locus, numLoci)
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
func ResolveCourtshipDynamics(w *world.World, maxTicks int32, reproCfg ReproductionConfig, genCfg GeneticsConfig) int {
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
			Copulate(w, maleIdx, femaleIdx, reproCfg, genCfg)
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
func combineLogic(cycles, reqs, conds bool, logicCyclesReqs, logicReqsConds bool) bool {
	var first bool
	if logicCyclesReqs {
		first = cycles && reqs
	} else {
		first = cycles || reqs
	}

	if logicReqsConds {
		return first && conds
	}
	return first || conds
}
