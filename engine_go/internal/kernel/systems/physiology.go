package systems

import (
	"galatea/engine/internal/kernel/world"
)

// ChargeNutrients deducts the metabolic cost of the executed behavior from the agent's reserves.
// costs is a flat array: [behavior * numNutrients + nutrient] = cost amount.
// If costs is nil, a default cost of 1 per nutrient is applied for non-rest behaviors.
func ChargeNutrients(w *world.World, idx int, costs []int32) {
	a := w.Agents
	cfg := w.Config
	decision := int(a.Decision[idx])
	numNut := cfg.NumNutrients

	reserveBase := idx * numNut

	if costs != nil && decision >= 0 && decision < cfg.NumBehaviors {
		costBase := decision * numNut
		for n := 0; n < numNut; n++ {
			if costBase+n < len(costs) {
				a.Reserves[reserveBase+n] -= costs[costBase+n]
				if a.Reserves[reserveBase+n] < 0 {
					a.Reserves[reserveBase+n] = 0
				}
			}
		}
	} else if decision != behaviorRest {
		// Default: deduct 1 per nutrient for non-rest behaviors.
		for n := 0; n < numNut; n++ {
			a.Reserves[reserveBase+n]--
			if a.Reserves[reserveBase+n] < 0 {
				a.Reserves[reserveBase+n] = 0
			}
		}
	}
}

// UpdateAgent performs end-of-tick physiological updates for an agent:
// - Increments age and time counters
// - Checks for death by starvation (any reserve at 0)
// - Checks for death by old age (if adult and age > longevity)
func UpdateAgent(w *world.World, idx int, longevity int32) {
	a := w.Agents
	cfg := w.Config

	a.Age[idx]++
	a.TimeInStage[idx]++

	// Check starvation: if any reserve is at 0, agent dies.
	if isStarving(a, idx, cfg) {
		markDead(a, idx)
		return
	}

	// Check old age (only adults).
	if a.StageID[idx] == -1 && longevity > 0 && a.Age[idx] > longevity {
		markDead(a, idx)
	}
}

// RegenerateResources updates all dynamic resource levels by their regeneration rate.
// Level = min(floor(Level * Rate), MaxLevel). If level is 0, it's reset to a minimum of 1
// to prevent permanent depletion (legacy behavior).
func RegenerateResources(w *world.World) {
	r := w.Resources
	for i := 0; i < r.Count; i++ {
		newLevel := int32(float64(r.Level[i]) * r.RegenRate[i])
		if newLevel > r.MaxLevel[i] {
			newLevel = r.MaxLevel[i]
		}
		// Prevent permanent zero (legacy: Nivel := 10 if Nivel = 0).
		if newLevel <= 0 && r.MaxLevel[i] > 0 {
			newLevel = 1
		}
		r.Level[i] = newLevel
	}
}

// ResetAgentStates resets all agent states to Undecided for the next tick.
// Also clears decisions for living agents.
func ResetAgentStates(w *world.World) {
	a := w.Agents
	for i := 0; i < a.Count; i++ {
		if a.Situation[i] != world.SituationDead {
			a.State[i] = world.StateUndecided
		}
	}
}

// RemoveDeadAgents removes all agents marked as dead using swap-and-pop.
// Returns the number of agents removed.
func RemoveDeadAgents(w *world.World) int {
	a := w.Agents
	removed := 0
	i := 0
	for i < a.Count {
		if a.Situation[i] == world.SituationDead {
			// Notify interactant (if in combat/courtship, partner wins/is rejected).
			notifyInteractantOfDeath(a, i)
			w.RemoveAgent(i)
			removed++
			// Don't increment i — the swapped-in agent needs to be checked too.
		} else {
			i++
		}
	}
	return removed
}

// --- Internal helpers ---

// isStarving returns true if any reserve has reached 0.
func isStarving(a *world.AgentArrays, idx int, cfg world.Config) bool {
	base := idx * cfg.NumNutrients
	for n := 0; n < cfg.NumNutrients; n++ {
		if a.Reserves[base+n] <= 0 {
			return true
		}
	}
	return false
}

// markDead sets the agent's situation to dead and clears interactions.
func markDead(a *world.AgentArrays, idx int) {
	a.Situation[idx] = world.SituationDead
}

// notifyInteractantOfDeath handles the case where a dying agent was in combat/courtship.
func notifyInteractantOfDeath(a *world.AgentArrays, idx int) {
	interactant := a.InteractantIdx[idx]
	if interactant < 0 || int(interactant) >= a.Count {
		return
	}
	// If the interactant was pointing back at us, free them.
	if a.InteractantIdx[interactant] == int32(idx) {
		switch a.Situation[interactant] {
		case world.SituationCombat:
			winCombat(a, int(interactant))
		case world.SituationCourtship:
			rejectCourtship(a, int(interactant))
		}
	}
}
