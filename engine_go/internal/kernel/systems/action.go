package systems

import (
	"math/rand/v2"

	"galatea/engine/internal/kernel/world"
)

// Act executes the decided behavior for the agent at idx.
// It modifies world state according to the behavior type.
func Act(w *world.World, idx int) {
	a := w.Agents
	a.State[idx] = world.StateActing
	decision := int(a.Decision[idx])

	switch {
	case decision == behaviorMove:
		actMove(w, idx)
	case decision == behaviorRest:
		// Rest: do nothing (agent stays in place).
	case decision >= behaviorOffsetFeed && decision < behaviorOffsetFeed+w.Config.NumResourceTypes:
		actFeed(w, idx)
	case isCombatBehavior(decision, w.Config):
		actCombatSignal(w, idx)
	case isCourtshipBehavior(decision, w.Config):
		actCourtshipSignal(w, idx)
	case decision == ovipositBehaviorIdx(w.Config):
		actOviposit(w, idx)
	default:
		// Unknown or die — handled by physiology.
	}

	// Update behavior memory.
	updateBehaviorMemory(a, idx, decision, w.Config.NumBehaviors)
}

// actMove changes agent position based on direction and speed.
func actMove(w *world.World, idx int) {
	a := w.Agents
	tendBase := idx * 8
	tendencies := a.Tendencies[tendBase : tendBase+8]

	// Select direction via roulette on tendencies.
	chosenDir := Roulette(tendencies)

	// Convert relative direction to absolute.
	absDir := absoluteDirection(a.Direction[idx], uint8(chosenDir+1))

	// Update facing direction.
	a.Direction[idx] = absDir

	// Compute new position.
	speed := float64(a.Speed[idx])
	dx := float64(dirDeltaX[absDir]) * speed
	dy := float64(dirDeltaY[absDir]) * speed

	newX := a.PosX[idx] + dx
	newY := a.PosY[idx] + dy

	// Clamp to grid bounds.
	maxX := float64(w.Config.GridWidth) - 1
	maxY := float64(w.Config.GridHeight) - 1
	if newX < 0 {
		newX = 0
	} else if newX > maxX {
		newX = maxX
	}
	if newY < 0 {
		newY = 0
	} else if newY > maxY {
		newY = maxY
	}

	a.PosX[idx] = newX
	a.PosY[idx] = newY
}

// actFeed transfers resources from the interactant resource to the agent's reserves.
func actFeed(w *world.World, idx int) {
	a := w.Agents
	r := w.Resources
	cfg := w.Config

	interactant := a.InteractantIdx[idx]
	if interactant < 0 || int(interactant) >= r.Count {
		return // No valid resource to feed from.
	}

	resourceType := int(r.TypeID[interactant])
	if resourceType < 0 || resourceType >= cfg.NumNutrients {
		return // Resource type doesn't map to a nutrient.
	}

	// Transfer: take up to speed units from resource, cap at available level.
	amount := a.Speed[idx] // Use speed as a proxy for feeding rate.
	if amount <= 0 {
		amount = 1
	}
	available := r.Level[interactant]
	if amount > available {
		amount = available
	}

	// Add to reserves (simple: resource type index = nutrient index).
	reserveIdx := idx*cfg.NumNutrients + resourceType
	a.Reserves[reserveIdx] += amount

	// Deplete resource.
	r.Level[interactant] -= amount
}

// actCombatSignal signals the opponent with the chosen combat action.
func actCombatSignal(w *world.World, idx int) {
	a := w.Agents
	cfg := w.Config
	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes

	interactant := a.InteractantIdx[idx]
	if interactant < 0 || int(interactant) >= a.Count {
		// Opponent gone — win by default.
		winCombat(a, idx)
		return
	}

	decision := int(a.Decision[idx])
	retreatIdx := fightDisplayIdx + 4

	if decision == retreatIdx {
		// Retreat: opponent wins, self returns to regular.
		winCombat(a, int(interactant))
		a.Situation[idx] = world.SituationRegular
		a.InteractantIdx[idx] = -1
		return
	}

	// Signal display or escalate to opponent (stored as LastOpponentAction).
	action := uint8(decision - fightDisplayIdx + 1) // 1=display, 2=escalate
	a.LastOpponentAction[interactant] = action
}

// actCourtshipSignal signals the partner with the chosen courtship action.
func actCourtshipSignal(w *world.World, idx int) {
	a := w.Agents
	cfg := w.Config
	courtDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 2

	interactant := a.InteractantIdx[idx]
	if interactant < 0 || int(interactant) >= a.Count {
		// Partner gone — rejected.
		rejectCourtship(a, idx)
		return
	}

	decision := int(a.Decision[idx])
	relativeDecision := decision - courtDisplayIdx // 0=display, 1=escalate, 2=accept, 3=reject

	switch relativeDecision {
	case courtshipReject:
		rejectCourtship(a, idx)
		rejectCourtship(a, int(interactant))
	case courtshipAccept:
		// Signal acceptance — copulation resolved externally.
		a.LastOpponentAction[interactant] = 3 // 3 = accept signal
	default:
		// Display or escalate signal.
		action := uint8(relativeDecision + 1) // 1=display, 2=escalate
		a.LastOpponentAction[interactant] = action
	}
}

// actOviposit placeholder — actual oviposition logic is in reproduction system.
func actOviposit(w *world.World, idx int) {
	// Oviposition is handled in the reproduction system (Task 8).
	// Here we just mark the behavior as executed.
	_ = w
	_ = idx
}

// --- Combat/Courtship resolution helpers ---

// winCombat resolves a combat victory for the given agent.
func winCombat(a *world.AgentArrays, winnerIdx int) {
	a.Situation[winnerIdx] = world.SituationRegular
	a.InteractantIdx[winnerIdx] = -1
	a.TimeInInteraction[winnerIdx] = 0
}

// rejectCourtship returns an agent to regular state after courtship ends.
func rejectCourtship(a *world.AgentArrays, idx int) {
	a.Situation[idx] = world.SituationRegular
	a.InteractantIdx[idx] = -1
	a.TimeInInteraction[idx] = 0
}

// updateBehaviorMemory records when a behavior was last performed and increments count.
func updateBehaviorMemory(a *world.AgentArrays, idx, behavior, numBehaviors int) {
	if behavior < 0 || behavior >= numBehaviors {
		return
	}
	memBase := idx * numBehaviors
	a.MemoryLastBehavior[memBase+behavior] = 0
	a.MemoryNumBehavior[memBase+behavior]++

	// Increment "last" counter for all other behaviors.
	for b := 0; b < numBehaviors; b++ {
		if b != behavior && a.MemoryLastBehavior[memBase+b] >= 0 {
			a.MemoryLastBehavior[memBase+b]++
		}
	}
}

// --- Behavior index helpers ---

func isCombatBehavior(decision int, cfg world.Config) bool {
	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	retreatIdx := fightDisplayIdx + 4
	return decision >= fightDisplayIdx && decision <= retreatIdx &&
		decision < fightDisplayIdx+2 || decision == retreatIdx
}

func isCourtshipBehavior(decision int, cfg world.Config) bool {
	courtDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 2
	return decision >= courtDisplayIdx && decision < courtDisplayIdx+4
}

func ovipositBehaviorIdx(cfg world.Config) int {
	return behaviorOffsetFeed + cfg.NumResourceTypes + 4
}

// MovementDirection selects a movement direction for the given agent via
// roulette on its tendency vector. Returns the absolute direction code (1-8).
// Exported for use by other systems that need to compute movement without executing it.
func MovementDirection(w *world.World, idx int) uint8 {
	a := w.Agents
	tendBase := idx * 8
	tendencies := a.Tendencies[tendBase : tendBase+8]

	// Ensure at least uniform if all zero.
	allZero := true
	for _, t := range tendencies {
		if t > 0 {
			allZero = false
			break
		}
	}
	if allZero {
		return angleDirTable[rand.IntN(8)]
	}

	chosenDir := Roulette(tendencies)
	return absoluteDirection(a.Direction[idx], uint8(chosenDir+1))
}
