package systems

import (
	"math"
	"math/rand/v2"

	"galatea/engine/internal/kernel/spatial"
	"galatea/engine/internal/kernel/world"
)

// Behavior index offsets relative to the config.
// 0 = move, 1 = rest, 2..2+N = feed per resource type,
// then: fightDisplay, fightEscalate, courtDisplay, courtEscalate, oviposit, die.
const (
	behaviorMove = 0
	behaviorRest = 1
)

// Combat decision indices (within VPeleas equivalent).
const (
	combatDisplay  = 0
	combatEscalate = 1
	combatRetreat  = 2
)

// Courtship decision indices (within VCortejos equivalent).
const (
	courtshipDisplay  = 0
	courtshipEscalate = 1
	courtshipAccept   = 2
	courtshipReject   = 3
)

// Roulette performs proportional random selection on a weighted slice.
// It returns the 0-based index of the selected element.
// If all weights are zero, all are set to 1 (uniform) before selection.
// Negative weights are clamped to 0.
func Roulette(weights []int32) int {
	sum := int32(0)
	for i := range weights {
		if weights[i] < 0 {
			weights[i] = 0
		}
		sum += weights[i]
	}

	if sum == 0 {
		// All zero: uniform distribution.
		return rand.IntN(len(weights))
	}

	target := rand.Int32N(sum) + 1
	cumulative := int32(0)
	for i, w := range weights {
		cumulative += w
		if target <= cumulative {
			return i
		}
	}

	// Should not reach here, but safe fallback.
	return len(weights) - 1
}

// Decide selects a behavior for the agent based on its current situation.
// It reads VDecision (for regular), VPeleas-equivalent (for combat),
// or VCortejos-equivalent (for courtship) and sets the Decision field.
func Decide(w *world.World, idx int) {
	a := w.Agents
	if a.State[idx] == world.StateDecided {
		return // Already decided this tick.
	}

	cfg := w.Config
	vdBase := idx * cfg.NumBehaviors

	switch a.Situation[idx] {
	case world.SituationImmature, world.SituationRegular:
		decideRegular(a, idx, cfg, vdBase)
	case world.SituationCombat:
		decideCombat(a, idx, cfg, vdBase)
	case world.SituationCourtship:
		decideCourtship(a, idx, cfg, vdBase)
	}

	a.State[idx] = world.StateDecided
}

// decideRegular uses the full VDecision vector for behavior selection.
func decideRegular(a *world.AgentArrays, idx int, cfg world.Config, vdBase int) {
	weights := a.VDecision[vdBase : vdBase+cfg.NumBehaviors]
	chosen := Roulette(weights)
	a.Decision[idx] = uint8(chosen)
}

// decideCombat selects among combat-specific behaviors: display, escalate, retreat.
func decideCombat(a *world.AgentArrays, idx int, cfg world.Config, vdBase int) {
	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	fightEscalateIdx := fightDisplayIdx + 1

	// Build a 3-element weight vector: [display, escalate, retreat].
	var combatWeights [3]int32
	if fightDisplayIdx < cfg.NumBehaviors {
		combatWeights[combatDisplay] = clampPositive(a.VDecision[vdBase+fightDisplayIdx])
	}
	if fightEscalateIdx < cfg.NumBehaviors {
		combatWeights[combatEscalate] = clampPositive(a.VDecision[vdBase+fightEscalateIdx])
	}
	combatWeights[combatRetreat] = 1 // Always at least some chance to retreat.

	chosen := Roulette(combatWeights[:])

	// Map combat choice back to the global behavior index.
	switch chosen {
	case combatDisplay:
		a.Decision[idx] = uint8(fightDisplayIdx)
	case combatEscalate:
		a.Decision[idx] = uint8(fightEscalateIdx)
	case combatRetreat:
		a.Decision[idx] = uint8(fightDisplayIdx + 4) // retreat uses a distinct slot
	}
}

// decideCourtship selects among courtship-specific behaviors.
func decideCourtship(a *world.AgentArrays, idx int, cfg world.Config, vdBase int) {
	courtDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 2
	courtEscalateIdx := courtDisplayIdx + 1

	// Build a 4-element weight vector: [display, escalate, accept, reject].
	var courtWeights [4]int32
	if courtDisplayIdx < cfg.NumBehaviors {
		courtWeights[courtshipDisplay] = clampPositive(a.VDecision[vdBase+courtDisplayIdx])
	}
	if courtEscalateIdx < cfg.NumBehaviors {
		courtWeights[courtshipEscalate] = clampPositive(a.VDecision[vdBase+courtEscalateIdx])
	}
	courtWeights[courtshipAccept] = 1
	courtWeights[courtshipReject] = 1

	chosen := Roulette(courtWeights[:])

	// Map courtship choice to decision code.
	// Use indices relative to courtDisplay for compact representation.
	a.Decision[idx] = uint8(courtDisplayIdx + chosen)
}

// EstablishInteraction assigns the interactant for an agent based on its decision.
// For feeding: finds the nearest contiguous resource of the appropriate type.
// For combat/courtship: finds the nearest contiguous agent of appropriate sex.
func EstablishInteraction(w *world.World, idx int, agentGrid, resourceGrid *spatial.Grid) {
	a := w.Agents
	cfg := w.Config
	decision := int(a.Decision[idx])

	a.TimeInInteraction[idx]++

	// If already in combat or courtship, interaction is maintained.
	if a.Situation[idx] == world.SituationCombat || a.Situation[idx] == world.SituationCourtship {
		return
	}

	// Move or rest: no interaction needed.
	if decision == behaviorMove || decision == behaviorRest {
		a.InteractantIdx[idx] = -1
		a.TimeInInteraction[idx] = 0
		return
	}

	ax := a.PosX[idx]
	ay := a.PosY[idx]

	// Feeding behaviors: find contiguous resource.
	if decision >= behaviorOffsetFeed && decision < behaviorOffsetFeed+cfg.NumResourceTypes {
		resourceType := int32(decision - behaviorOffsetFeed)
		rIdx := findContiguousResource(w, ax, ay, resourceType, resourceGrid)
		a.InteractantIdx[idx] = rIdx
		return
	}

	// Fight or courtship initiation: find contiguous agent.
	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	courtDisplayIdx := fightDisplayIdx + 2

	if decision >= fightDisplayIdx && decision < courtDisplayIdx {
		// Fight: find same-sex or any adult contiguous agent.
		target := findContiguousAgent(w, idx, ax, ay, agentGrid, false)
		a.InteractantIdx[idx] = target
		if target >= 0 {
			initiateCombat(a, idx, int(target))
		}
		return
	}

	if decision >= courtDisplayIdx && decision < courtDisplayIdx+4 {
		// Courtship: find opposite-sex contiguous agent.
		target := findContiguousAgent(w, idx, ax, ay, agentGrid, true)
		a.InteractantIdx[idx] = target
		if target >= 0 {
			initiateCourtship(a, idx, int(target))
		}
		return
	}

	// Oviposition or other: clear interaction.
	a.InteractantIdx[idx] = -1
}

// findContiguousResource returns the index of the nearest resource of the given type
// within contiguous distance, or -1 if none found.
func findContiguousResource(w *world.World, ax, ay float64, resourceType int32, grid *spatial.Grid) int32 {
	r := w.Resources
	candidates := grid.QueryRadiusExact(ax, ay, contiguousDistance, r.PosX, r.PosY)

	bestIdx := int32(-1)
	bestDist := math.MaxFloat64

	for _, rIdx := range candidates {
		if r.TypeID[rIdx] != resourceType {
			continue
		}
		dist := distance(ax, ay, r.PosX[rIdx], r.PosY[rIdx])
		if dist < bestDist {
			bestDist = dist
			bestIdx = rIdx
		}
	}
	return bestIdx
}

// findContiguousAgent returns the index of the nearest contiguous agent suitable
// for interaction. If oppositeSex is true, looks for opposite sex; otherwise same sex.
// The target must be in Regular situation and Undecided state.
func findContiguousAgent(w *world.World, selfIdx int, ax, ay float64, grid *spatial.Grid, oppositeSex bool) int32 {
	a := w.Agents
	candidates := grid.QueryRadiusExact(ax, ay, contiguousDistance, a.PosX, a.PosY)
	selfSex := a.Sex[selfIdx]

	bestIdx := int32(-1)
	bestDist := math.MaxFloat64

	for _, cIdx := range candidates {
		if cIdx == int32(selfIdx) || int(cIdx) >= a.Count {
			continue
		}
		if a.Situation[cIdx] != world.SituationRegular {
			continue
		}

		otherSex := a.Sex[cIdx]
		if oppositeSex {
			if !isOppositeSex(selfSex, otherSex) {
				continue
			}
		} else {
			if isOppositeSex(selfSex, otherSex) {
				continue
			}
		}

		dist := distance(ax, ay, a.PosX[cIdx], a.PosY[cIdx])
		if dist < bestDist {
			bestDist = dist
			bestIdx = cIdx
		}
	}
	return bestIdx
}

// initiateCombat puts both agents into combat situation.
func initiateCombat(a *world.AgentArrays, initiatorIdx, targetIdx int) {
	a.Situation[initiatorIdx] = world.SituationCombat
	a.Situation[targetIdx] = world.SituationCombat
	a.InteractantIdx[targetIdx] = int32(initiatorIdx)
	a.TimeInInteraction[initiatorIdx] = 0
	a.TimeInInteraction[targetIdx] = 0
}

// initiateCourtship puts both agents into courtship situation.
func initiateCourtship(a *world.AgentArrays, initiatorIdx, targetIdx int) {
	a.Situation[initiatorIdx] = world.SituationCourtship
	a.Situation[targetIdx] = world.SituationCourtship
	a.InteractantIdx[targetIdx] = int32(initiatorIdx)
	a.TimeInInteraction[initiatorIdx] = 0
	a.TimeInInteraction[targetIdx] = 0
}

// isOppositeSex returns true if the two sexes are male/female or female/male.
func isOppositeSex(a, b uint8) bool {
	return (a == world.SexMale && b == world.SexFemale) ||
		(a == world.SexFemale && b == world.SexMale)
}
