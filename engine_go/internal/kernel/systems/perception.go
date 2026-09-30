// Package systems implements the simulation systems that operate on the World
// during the Hot Path tick loop. Each system is a pure function that reads
// and writes World state via index-based SoA access.
package systems

import (
	"fmt"
	"math"

	"galatea/engine/internal/kernel/formulas"
	"galatea/engine/internal/kernel/spatial"
	"galatea/engine/internal/kernel/util"
	"galatea/engine/internal/kernel/world"
)

// Direction constants for tendency array indexing (0-based).
const (
	DirNW = 0
	DirN  = 1
	DirNE = 2
	DirW  = 3
	DirE  = 4
	DirSW = 5
	DirS  = 6
	DirSE = 7
)

// Behavioral tuning constants.
const (
	contiguousDistance   = 1.5 // Max distance to consider elements "adjacent".
	fightBoostDisplay    = 5   // VDecision boost for fight when contender detected.
	fightBoostEscalate   = 3   // VDecision boost for escalate when contender detected.
	courtBoostDisplay    = 5   // VDecision boost for courtship when mate detected.
	courtBoostEscalate   = 3   // VDecision boost for courtship escalate.
	criticalReserveLevel = 5   // Reserve level below which agent is in critical state.
	behaviorOffsetFeed   = 2   // First feed behavior index (0=move, 1=rest, 2+=feed).
	contiguousBoost      = 1   // Extra VDecision weight for contiguous resources.
)

// --- Interaction-matrix registry keys ---
//
// These build the formula-registry keys for the behavior-probability
// interaction matrices. They are defined here (in systems) because both the
// Cold Path (which compiles the formulas) and the Hot Path (which evaluates
// them) must agree on the key format. observedIdx/perceiverIdx are the unified
// prototype index (stages, then males, then females).

// InteractionKeyAgent builds the registry key for an agent-interaction cell.
func InteractionKeyAgent(observedIdx, perceiverIdx, behaviorIdx int) string {
	return fmt.Sprintf("interaction.agent.%d.%d.%d", observedIdx, perceiverIdx, behaviorIdx)
}

// InteractionKeySource builds the registry key for a source-interaction cell.
func InteractionKeySource(resourceType, perceiverIdx, behaviorIdx int) string {
	return fmt.Sprintf("interaction.source.%d.%d.%d", resourceType, perceiverIdx, behaviorIdx)
}

// InteractionKeySubstrate builds the registry key for a substrate-interaction cell.
func InteractionKeySubstrate(substrateIdx, perceiverIdx, behaviorIdx int) string {
	return fmt.Sprintf("interaction.substrate.%d.%d.%d", substrateIdx, perceiverIdx, behaviorIdx)
}

// --- Combat/Courtship strategy-matrix registry keys ---
//
// These index a prototype's strategy matrix by (my action, opponent's last
// action), mirroring the legacy TPrototipo.Combate[i,j] / Cortejo[i,j]. Both
// action indices are 1-based, exactly as stored by the editor and the legacy:
//
//	Combat action    (1..3): 1=Display, 2=Escalate, 3=Retreat
//	Combat oppAction (1..2): 1=Opp.Display, 2=Opp.Escalate
//	Court action     (1..4): 1=Display, 2=Escalate, 3=Accept, 4=Reject
//	Court oppAction  (1..3): 1=Opp.Display, 2=Opp.Escalate, 3=Opp.Accept
//
// protoIdx is the agent's 0-based PrototypeID (DB id - 1), matching how
// reference.go keys the other per-prototype formulas.

// CombatStrategyKey builds the registry key for a combat strategy cell.
func CombatStrategyKey(protoIdx, action, oppAction int) string {
	return fmt.Sprintf("combat.%d.%d.%d", protoIdx, action, oppAction)
}

// CourtshipStrategyKey builds the registry key for a courtship strategy cell.
func CourtshipStrategyKey(protoIdx, action, oppAction int) string {
	return fmt.Sprintf("courtship.%d.%d.%d", protoIdx, action, oppAction)
}

// Lookup tables for direction conversions (replace switch statements).
// dirAngleTable maps direction code (1-8) to clockwise angular index (0-7 from N).
var dirAngleTable = [9]int{0, 7, 0, 1, 6, 2, 5, 4, 3} // index 0 unused

// angleDirTable maps clockwise angle (0-7) to direction code (1-8).
var angleDirTable = [8]uint8{2, 3, 5, 8, 7, 6, 4, 1}

// angleRelTable maps relative clockwise angle (0-7) to tendency array index.
var angleRelTable = [8]int{DirN, DirNE, DirE, DirSE, DirS, DirSW, DirW, DirNW}

// dirDeltaX and dirDeltaY map direction code (1-8) to movement deltas.
var dirDeltaX = [9]int{0, -1, 0, 1, -1, 1, -1, 0, 1} // index 0 unused
var dirDeltaY = [9]int{0, -1, -1, -1, 0, 0, 1, 1, 1} // index 0 unused

// PerceptionContext holds pre-computed data needed during perception.
// It is created once per tick and reused across all agents.
type PerceptionContext struct {
	World        *world.World
	AgentGrid    *spatial.Grid
	ResourceGrid *spatial.Grid
	Formulas     *formulas.Registry
	Eval         *formulas.Evaluator
	EnvBuilder   *formulas.EnvBuilder

	// Precomputed attractiveness radii per (resource_type, perceiver_prototype).
	// Index: [resourceType * numPerceivers + perceiverIdx]
	ResourceRadii []float64
	ResourceAttr  []int32

	// Agent attractiveness radii: [observed * numPerceivers + perceiverIdx]
	AgentRadii []float64

	// Agent attractiveness values: [observed * numPerceivers + perceiverIdx].
	// Defaults to 0 (no attraction) when not configured in the DB.
	AgentAttr []int32

	// SubstrateField holds the precomputed constant-case substrate perception
	// (tendencies + interaction) per (perceiver, cell). Nil when no constant
	// substrate attractiveness is configured. See enfoque B / SubstrateField.
	SubstrateField *SubstrateField

	// Per-agent reference values (set before each agent's perception).
	Ref *AgentRef

	// Interaction-matrix accumulators (reused across agents, reset per agent).
	// The legacy averages each behavior's weight over all perceived elements
	// (PromediaProbaDecision): interSum holds the running sum of formula
	// results per behavior, interCount the number of contributing elements.
	// VDecision[b] is later set to interSum[b] / interCount[b].
	interSum   []int32
	interCount []int32

	// perceivedThisTick marks, per memory slot, whether the current agent
	// perceived that element this tick (reused across agents, reset per agent).
	// It feeds the per-tick perception-memory update (legacy ActualizaMemoria).
	perceivedThisTick []bool
}

// Perceive runs the full perception pipeline for agent at idx.
// It resets tendencies and VDecision, queries the spatial grids,
// accumulates attractiveness-weighted tendencies and behavior probabilities,
// then applies filters and boundary avoidance.
func Perceive(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config

	resetVectors(a, idx, cfg.NumBehaviors)
	resetInteractionAccumulators(ctx, cfg.NumBehaviors)
	resetPerceivedThisTick(ctx, cfg.MemPerceptionSlots())

	ctx.EnvBuilder.SetWorldVars(w)
	ctx.EnvBuilder.SetAgentVars(w, idx)

	perceiveSubstrate(ctx, idx)
	perceiveResources(ctx, idx)
	hasContender, hasMate := perceiveAgents(ctx, idx)

	// Convert the accumulated interaction weights into VDecision using the
	// legacy averaging model (sum / count per behavior).
	applyInteractionAverages(ctx, idx)

	applyBaseTendencies(ctx, idx)
	// Detection boosts are applied AFTER base tendencies and only reinforce
	// combat/courtship weights the agent already has configured (> 0). This
	// mirrors the legacy default where an unconfigured prototype never fights
	// or courts, so agents just wander past each other instead of getting
	// locked into combat on contact.
	applyAgentDetectionBoosts(a, idx, cfg, hasContender, hasMate)
	applyFilters(ctx, idx)
	applyBoundaryAvoidance(ctx, idx)
	ensureNonZeroDecision(ctx, idx)

	// Update the agent's perception memory from what it perceived this tick
	// (legacy ActualizaMemoria): perceived elements reset their "last" counter
	// to 0 and increment their "num" counter; the rest age by one tick.
	updatePerceptionMemory(ctx, idx)
}

// AgeMemory ages the perception/interaction memory of an agent by one tick
// (all "last" counters that are not -1 are incremented), WITHOUT recording any
// new perception. It is used for agents that skip the perception phase this
// tick (those in combat/courtship), so their memory keeps aging consistently,
// mirroring the legacy where ActualizaMemoria runs for every agent each tick.
func AgeMemory(w *world.World, idx int) {
	a := w.Agents
	cfg := w.Config
	slots := cfg.MemPerceptionSlots()
	base := idx * slots
	for s := 0; s < slots; s++ {
		mi := base + s
		if a.MemoryLastPerceived[mi] >= 0 {
			a.MemoryLastPerceived[mi]++
		}
		if a.MemoryLastInteracted[mi] >= 0 {
			a.MemoryLastInteracted[mi]++
		}
	}
}

// resetPerceivedThisTick (re)allocates and clears the per-slot "perceived this
// tick" buffer for the current agent.
func resetPerceivedThisTick(ctx *PerceptionContext, slots int) {
	if len(ctx.perceivedThisTick) < slots {
		ctx.perceivedThisTick = make([]bool, slots)
	}
	for s := 0; s < slots; s++ {
		ctx.perceivedThisTick[s] = false
	}
}

// markPerceived records that the current agent perceived the element at the
// given memory slot this tick.
func markPerceived(ctx *PerceptionContext, slot int) {
	if slot >= 0 && slot < len(ctx.perceivedThisTick) {
		ctx.perceivedThisTick[slot] = true
	}
}

// updatePerceptionMemory applies the legacy ActualizaMemoria perception update:
// for each memory slot, if perceived this tick set MemoryLastPerceived=0 and
// increment MemoryNumPerceived; otherwise age MemoryLastPerceived (when not -1).
// Interaction memory is updated separately, at interaction/action time.
func updatePerceptionMemory(ctx *PerceptionContext, idx int) {
	a := ctx.World.Agents
	cfg := ctx.World.Config
	slots := cfg.MemPerceptionSlots()
	base := idx * slots
	for s := 0; s < slots; s++ {
		mi := base + s
		if ctx.perceivedThisTick[s] {
			a.MemoryLastPerceived[mi] = 0
			a.MemoryNumPerceived[mi]++
		} else if a.MemoryLastPerceived[mi] >= 0 {
			a.MemoryLastPerceived[mi]++
		}
		// Age interaction memory too (interactions set their slot to 0 when
		// they happen, in the action phase).
		if a.MemoryLastInteracted[mi] >= 0 {
			a.MemoryLastInteracted[mi]++
		}
	}
}

// resetVectors zeroes out tendencies and VDecision for an agent.
func resetVectors(a *world.AgentArrays, idx int, numBehaviors int) {
	tendBase := idx * 8
	for d := 0; d < 8; d++ {
		a.Tendencies[tendBase+d] = 0
	}
	vdBase := idx * numBehaviors
	for b := 0; b < numBehaviors; b++ {
		a.VDecision[vdBase+b] = 0
	}
}

// resetInteractionAccumulators (re)allocates and zeroes the per-behavior
// interaction sum/count buffers for the current agent.
func resetInteractionAccumulators(ctx *PerceptionContext, numBehaviors int) {
	if len(ctx.interSum) < numBehaviors {
		ctx.interSum = make([]int32, numBehaviors)
		ctx.interCount = make([]int32, numBehaviors)
	}
	for b := 0; b < numBehaviors; b++ {
		ctx.interSum[b] = 0
		ctx.interCount[b] = 0
	}
}

// accumulateInteraction evaluates the interaction-matrix formula for every
// behavior of a single perceived element and adds each result to the running
// per-behavior average (one contribution per element, per the legacy
// PromediaProbaDecision). keyFn builds the registry key for a given behavior.
// The evaluator environment must already be set for the perceiver and, when
// relevant, the observed element/contender.
func accumulateInteraction(ctx *PerceptionContext, keyFn func(behaviorIdx int) string, numBehaviors int) {
	for b := 0; b < numBehaviors; b++ {
		p := ctx.Formulas.Get(keyFn(b))
		if p == nil {
			// No configured cell for this behavior: it still counts as a
			// contribution of 0, matching the legacy which averages over all
			// perceived elements regardless of whether the cell is non-zero.
			ctx.interCount[b]++
			continue
		}
		val, err := ctx.Eval.RunProgramInt(p)
		if err == nil {
			ctx.interSum[b] += int32(val)
		}
		ctx.interCount[b]++
	}
}

// applyInteractionAverages writes the averaged interaction weights into the
// agent's VDecision (VDecision[b] = round(sum/count)). Behaviors with no
// contributing element are left at 0.
func applyInteractionAverages(ctx *PerceptionContext, idx int) {
	cfg := ctx.World.Config
	vdBase := idx * cfg.NumBehaviors
	a := ctx.World.Agents
	for b := 0; b < cfg.NumBehaviors; b++ {
		if ctx.interCount[b] > 0 {
			a.VDecision[vdBase+b] += ctx.interSum[b] / ctx.interCount[b]
		}
	}
}

// perceiveSubstrate accumulates interaction weights from the substrate the
// agent currently stands on. The legacy also perceives nearby substrates within
// a radius; here we contribute the current cell's substrate (the dominant
// signal) so substrate interaction formulas take effect. Tendency/attraction of
// substrates is handled separately by the attractiveness matrices.
func perceiveSubstrate(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config

	sx := int(a.PosX[idx])
	sy := int(a.PosY[idx])
	if sx < 0 || sx >= cfg.GridWidth || sy < 0 || sy >= cfg.GridHeight {
		return
	}
	substrateIdx := int(w.Substrates.Get(sx, sy))
	perceiverIdx := getPerceiverIndex(a, idx, cfg)

	// The agent stands on this substrate → it perceives it (memory tracks the
	// substrate cell, mixed or simple, by its own index).
	markPerceived(ctx, cfg.MemSlotSubstrate(substrateIdx))

	// Enfoque B, constant case: when a precomputed substrate field exists, fold
	// in the radius-swept attractiveness→tendency contribution (rotated by the
	// agent's heading) and mark perception memory for the substrates in range.
	// This replaces the legacy per-agent O(radius²) tendency sweep with an O(8)
	// lookup. The interaction contribution below still runs for the agent's own
	// cell (surrounding-cell interaction is a later entry).
	if ctx.SubstrateField.HasSubstrateField() {
		ctx.SubstrateField.applyTo(ctx, idx, perceiverIdx, sx, sy)
	}

	if !cfg.IsMixedSubstrate(substrateIdx) {
		// Simple substrate: one interaction contribution.
		accumulateInteraction(ctx, func(b int) string {
			return InteractionKeySubstrate(substrateIdx, perceiverIdx, b)
		}, cfg.NumBehaviors)
		return
	}

	// Mixed substrate: its interaction contribution is the weighted combination
	// of its simple components (legacy GetInteraccionSustratos for X>7). For
	// each behavior, sum the components' formula results scaled by their
	// fractions; the mixed cell counts as ONE perceived element overall (a
	// single PromediaProbaDecision contribution), not one per component.
	comps := cfg.SubstrateComposition[substrateIdx]
	for b := 0; b < cfg.NumBehaviors; b++ {
		combined := 0.0
		for _, comp := range comps {
			p := ctx.Formulas.Get(InteractionKeySubstrate(comp.SimpleIdx, perceiverIdx, b))
			if p == nil {
				continue
			}
			if val, err := ctx.Eval.RunProgramInt(p); err == nil {
				combined += float64(val) * comp.Fraction
			}
		}
		ctx.interSum[b] += int32(combined + 0.5) // round
		ctx.interCount[b]++                      // one contribution for the whole mixed cell
	}
}

// perceiveResources queries the resource grid and accumulates tendencies + VDecision.
func perceiveResources(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	r := w.Resources
	cfg := w.Config

	ax := a.PosX[idx]
	ay := a.PosY[idx]
	aDir := a.Direction[idx]
	perceiverIdx := getPerceiverIndex(a, idx, cfg)

	maxRadius := maxFloat64(ctx.ResourceRadii)
	if maxRadius <= 0 {
		return
	}

	candidates := ctx.ResourceGrid.QueryRadiusExact(ax, ay, maxRadius, r.PosX, r.PosY)
	tendBase := idx * 8
	vdBase := idx * cfg.NumBehaviors

	for _, rIdx := range candidates {
		rx := r.PosX[rIdx]
		ry := r.PosY[rIdx]
		dist := distance(ax, ay, rx, ry)
		resourceType := int(r.TypeID[rIdx])

		radiusKey := resourceType*cfg.NumPrototypes + perceiverIdx
		if radiusKey >= len(ctx.ResourceRadii) || dist > ctx.ResourceRadii[radiusKey] {
			continue
		}

		attractiveness := getResourceAttractiveness(ctx, radiusKey, dist)
		accumulateTendency(a, tendBase, aDir, ax, ay, rx, ry, attractiveness)

		// Accumulate this source's interaction-matrix contribution to every
		// behavior (legacy PromediaProbaDecision). Expose the element's
		// variables so formulas can reference DynamicElementLevel/Quality.
		if resourceType >= 0 {
			// Perceived this source type this tick (only real nutrient
			// sources have a memory slot; oviposition sites do not).
			if resourceType < cfg.NumResourceTypes {
				markPerceived(ctx, cfg.MemSlotSource(resourceType))
			}
			ctx.EnvBuilder.SetResourceVars(w, int(rIdx))
			accumulateInteraction(ctx, func(b int) string {
				return InteractionKeySource(resourceType, perceiverIdx, b)
			}, cfg.NumBehaviors)
		}
	}
	_ = vdBase
}

// perceiveAgents queries the agent grid and accumulates attractiveness-driven
// tendencies. It returns whether a contiguous contender/mate was detected, so
// the caller can conditionally reinforce combat/courtship weights AFTER base
// tendencies are applied. It does NOT itself inject any behavior weight.
func perceiveAgents(ctx *PerceptionContext, idx int) (hasContender, hasMate bool) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config

	ax := a.PosX[idx]
	ay := a.PosY[idx]
	aDir := a.Direction[idx]
	perceiverIdx := getPerceiverIndex(a, idx, cfg)

	maxRadius := maxFloat64(ctx.AgentRadii)
	if maxRadius <= 0 {
		return false, false
	}

	candidates := ctx.AgentGrid.QueryRadiusExact(ax, ay, maxRadius, a.PosX, a.PosY)
	tendBase := idx * 8

	for _, cIdx := range candidates {
		if cIdx == int32(idx) || int(cIdx) >= a.Count {
			continue
		}

		cx := a.PosX[cIdx]
		cy := a.PosY[cIdx]
		dist := distance(ax, ay, cx, cy)

		observedIdx := getPerceiverIndex(a, int(cIdx), cfg)
		radiusKey := observedIdx*cfg.NumPrototypes + perceiverIdx
		if radiusKey >= len(ctx.AgentRadii) || dist > ctx.AgentRadii[radiusKey] {
			continue
		}

		attractiveness := getAgentAttractiveness(ctx, radiusKey, dist)
		accumulateTendency(a, tendBase, aDir, ax, ay, cx, cy, attractiveness)

		// Perceived this observed prototype this tick.
		markPerceived(ctx, cfg.MemSlotPrototype(observedIdx))

		// Accumulate this observed agent's interaction-matrix contribution to
		// every behavior (legacy PromediaProbaDecision). Expose the observed
		// agent as the "contender" so formulas can reference Contender* vars.
		ctx.EnvBuilder.SetContenderVars(w, int(cIdx))
		accumulateInteraction(ctx, func(b int) string {
			return InteractionKeyAgent(observedIdx, perceiverIdx, b)
		}, cfg.NumBehaviors)

		if dist <= contiguousDistance {
			c, m := classifyNeighbor(a.Sex[idx], a.Sex[cIdx], a.Situation[cIdx])
			hasContender = hasContender || c
			hasMate = hasMate || m
		}
	}

	return hasContender, hasMate
}

// classifyNeighbor determines if a contiguous neighbor is a contender, a mate,
// or neither, following the legacy sex rules:
//   - A contender (for combat) is ANY adult, regardless of sex.
//   - A mate (for courtship) is an OPPOSITE-SEX adult only.
//
// Only adults (SituationRegular, with a defined sex) qualify; immature agents
// and eggs never trigger combat or courtship.
func classifyNeighbor(agentSex, otherSex, otherSituation uint8) (contender, mate bool) {
	if otherSituation != world.SituationRegular {
		return false, false
	}
	// The perceiver itself must be a sexed adult to fight or court.
	if agentSex != world.SexMale && agentSex != world.SexFemale {
		return false, false
	}
	if otherSex != world.SexMale && otherSex != world.SexFemale {
		return false, false
	}
	contender = true // Any adult neighbor is a potential combat opponent.
	mate = (agentSex == world.SexMale && otherSex == world.SexFemale) ||
		(agentSex == world.SexFemale && otherSex == world.SexMale)
	return contender, mate
}

// applyAgentDetectionBoosts reinforces fight/court weights when a contender or
// mate is contiguous — but ONLY for behaviors the agent already has a positive
// configured weight for. If a prototype has no combat/courtship tendency
// (the default), detecting a neighbor adds nothing, so agents wander past each
// other instead of getting locked into spontaneous combat ("the game of the
// enchanted"). This must run AFTER applyBaseTendencies so the base weights
// (from the user's VDecision formulas) are already present.
func applyAgentDetectionBoosts(a *world.AgentArrays, idx int, cfg world.Config, hasContender, hasMate bool) {
	vdBase := idx * cfg.NumBehaviors
	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	fightEscalateIdx := fightDisplayIdx + 1
	courtDisplayIdx := fightDisplayIdx + 2
	courtEscalateIdx := fightDisplayIdx + 3

	// boostIfConfigured adds `boost` to slot only if the slot already has a
	// positive base weight (i.e. the user enabled that behavior).
	boostIfConfigured := func(slot int, boost int32) {
		if slot < cfg.NumBehaviors && a.VDecision[vdBase+slot] > 0 {
			a.VDecision[vdBase+slot] += boost
		}
	}

	if hasContender {
		boostIfConfigured(fightDisplayIdx, fightBoostDisplay)
		boostIfConfigured(fightEscalateIdx, fightBoostEscalate)
	}
	if hasMate {
		boostIfConfigured(courtDisplayIdx, courtBoostDisplay)
		boostIfConfigured(courtEscalateIdx, courtBoostEscalate)
	}
}

// applyBaseTendencies evaluates the base tendency formulas for the agent's prototype/stage.
func applyBaseTendencies(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config
	tendBase := idx * 8
	vdBase := idx * cfg.NumBehaviors

	perceiverIdx := getPerceiverIndex(a, idx, cfg)
	prefix := "tendency." + util.Itoa(perceiverIdx) + "."

	// Tendency keys use the 0-based engine slot (DirNW=0..DirSE=7), matching
	// how compileTendencies registers them.
	for d := 0; d < 8; d++ {
		p := ctx.Formulas.Get(prefix + util.Itoa(d))
		if p != nil {
			val, err := ctx.Eval.RunProgramInt(p)
			if err == nil {
				a.Tendencies[tendBase+d] += int32(val)
			}
		}
	}

	vdPrefix := "vdecision." + util.Itoa(perceiverIdx) + "."
	for b := 0; b < cfg.NumBehaviors; b++ {
		p := ctx.Formulas.Get(vdPrefix + util.Itoa(b+1))
		if p != nil {
			val, err := ctx.Eval.RunProgramInt(p)
			if err == nil {
				a.VDecision[vdBase+b] += int32(val)
			}
		}
	}
}

// applyFilters zeroes out behaviors that are unavailable given current state.
// This mirrors the legacy's VDecision filtering logic from ProveePercepciones.
func applyFilters(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config
	vdBase := idx * cfg.NumBehaviors
	ref := ctx.Ref

	fightDisplayIdx := behaviorOffsetFeed + cfg.NumResourceTypes
	fightEscalateIdx := fightDisplayIdx + 1
	courtDisplayIdx := fightDisplayIdx + 2
	courtEscalateIdx := fightDisplayIdx + 3
	ovipositIdx := fightDisplayIdx + 4

	// --- Disable feeding if reserve is at max for that nutrient ---
	if ref != nil {
		for n := 0; n < cfg.NumResourceTypes && n < cfg.NumNutrients; n++ {
			feedIdx := behaviorOffsetFeed + n
			if feedIdx < cfg.NumBehaviors {
				reserveBase := idx * cfg.NumNutrients
				if n < len(ref.MaxReserves) && a.Reserves[reserveBase+n] >= ref.MaxReserves[n] {
					a.VDecision[vdBase+feedIdx] = 0
				}
			}
		}
	}

	// --- Disable fight if in refractory period ---
	if ref != nil && ref.RefractoryCombat > 0 {
		memBase := idx * cfg.NumBehaviors
		// Check last retreat and last win-fight memory.
		// Retreat is at fightDisplayIdx+4 relative to behavior offset.
		retreatBehavior := fightDisplayIdx + 4
		if retreatBehavior < cfg.NumBehaviors {
			lastRetreat := a.MemoryLastBehavior[memBase+retreatBehavior]
			if lastRetreat >= 0 && lastRetreat < int32(ref.RefractoryCombat) {
				zeroIfValid(a.VDecision, vdBase+fightDisplayIdx, cfg.NumBehaviors)
				zeroIfValid(a.VDecision, vdBase+fightEscalateIdx, cfg.NumBehaviors)
			}
		}
	}

	// --- Disable courtship if in refractory period ---
	// Triggered by an actual COPULATION (LastCopulation), not by a rejection.
	// This corrects the legacy bug where the courtship refractory read the
	// "reject" memory slot instead of the copulation one.
	if ref != nil && ref.RefractoryCourtship > 0 {
		lastCopulate := a.LastCopulation[idx]
		if lastCopulate >= 0 && lastCopulate < int32(ref.RefractoryCourtship) {
			zeroIfValid(a.VDecision, vdBase+courtDisplayIdx, cfg.NumBehaviors)
			zeroIfValid(a.VDecision, vdBase+courtEscalateIdx, cfg.NumBehaviors)
		}
	}

	// --- Disable escalate if no display weight exists ---
	if a.VDecision[vdBase+fightDisplayIdx] == 0 {
		a.VDecision[vdBase+fightEscalateIdx] = 0
	}
	if a.VDecision[vdBase+courtDisplayIdx] == 0 {
		a.VDecision[vdBase+courtEscalateIdx] = 0
	}

	// --- Disable oviposition for males, if no fertilized eggs, or if there is
	// nowhere to deposit them. The legacy allows laying into a contiguous
	// oviposition site OR onto a contiguous adult agent (carried eggs), so
	// oviposition is only vetoed when NEITHER carrier is available. ---
	if ovipositIdx < cfg.NumBehaviors {
		hasCarrier := false
		if ctx.ResourceGrid != nil &&
			findContiguousOvipositionSite(w, a.PosX[idx], a.PosY[idx], ctx.ResourceGrid) >= 0 {
			hasCarrier = true
		} else if ctx.AgentGrid != nil &&
			findContiguousAgent(w, idx, a.PosX[idx], a.PosY[idx], ctx.AgentGrid, false) >= 0 {
			hasCarrier = true
		}
		if a.Sex[idx] == world.SexMale || a.FertilizedCount(idx) == 0 || !hasCarrier {
			a.VDecision[vdBase+ovipositIdx] = 0
		}
	}

	// --- Disable fight and courtship when reserves are critical ---
	if ref != nil {
		isCritical := false
		reserveBase := idx * cfg.NumNutrients
		for n := 0; n < cfg.NumNutrients; n++ {
			if n < len(ref.CriticalReserves) && a.Reserves[reserveBase+n] <= ref.CriticalReserves[n] {
				isCritical = true
				break
			}
		}
		if isCritical {
			zeroIfValid(a.VDecision, vdBase+fightDisplayIdx, cfg.NumBehaviors)
			zeroIfValid(a.VDecision, vdBase+fightEscalateIdx, cfg.NumBehaviors)
			zeroIfValid(a.VDecision, vdBase+courtDisplayIdx, cfg.NumBehaviors)
			zeroIfValid(a.VDecision, vdBase+courtEscalateIdx, cfg.NumBehaviors)
		}
	} else if isReserveCritical(a, idx, cfg) {
		zeroIfValid(a.VDecision, vdBase+fightDisplayIdx, cfg.NumBehaviors)
		zeroIfValid(a.VDecision, vdBase+fightEscalateIdx, cfg.NumBehaviors)
		zeroIfValid(a.VDecision, vdBase+courtDisplayIdx, cfg.NumBehaviors)
		zeroIfValid(a.VDecision, vdBase+courtEscalateIdx, cfg.NumBehaviors)
	}

	// --- Clamp negative values to 0 ---
	for b := 0; b < cfg.NumBehaviors; b++ {
		if a.VDecision[vdBase+b] < 0 {
			a.VDecision[vdBase+b] = 0
		}
	}
}

// applyBoundaryAvoidance zeroes tendencies that would move the agent outside the grid.
func applyBoundaryAvoidance(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config
	tendBase := idx * 8

	x := a.PosX[idx]
	y := a.PosY[idx]
	speed := float64(a.Speed[idx])
	dir := a.Direction[idx]

	maxX := float64(cfg.GridWidth) - 1
	maxY := float64(cfg.GridHeight) - 1

	atBoundary := x <= speed || x >= maxX-speed || y <= speed || y >= maxY-speed
	if !atBoundary {
		return
	}

	// Add 1 to all tendencies to eliminate zeros before blocking (legacy behavior).
	for d := 0; d < 8; d++ {
		a.Tendencies[tendBase+d] += 1
	}

	// Block directions that would exit bounds.
	for relDir := 0; relDir < 8; relDir++ {
		absDir := absoluteDirection(dir, uint8(relDir+1))
		dx := dirDeltaX[absDir]
		dy := dirDeltaY[absDir]

		newX := x + float64(dx)*speed
		newY := y + float64(dy)*speed

		if newX < 0 || newX > maxX || newY < 0 || newY > maxY {
			a.Tendencies[tendBase+relDir] = 0
		}
	}
}

// ensureNonZeroDecision forces at least movement if all VDecision weights are zero.
func ensureNonZeroDecision(ctx *PerceptionContext, idx int) {
	a := ctx.World.Agents
	cfg := ctx.World.Config
	vdBase := idx * cfg.NumBehaviors

	for b := 0; b < cfg.NumBehaviors; b++ {
		if a.VDecision[vdBase+b] > 0 {
			return
		}
	}
	a.VDecision[vdBase] = 1 // Force movement.
}

// --- Utility helpers ---

// getPerceiverIndex returns the unified index of an agent in the prototype listing.
func getPerceiverIndex(a *world.AgentArrays, idx int, cfg world.Config) int {
	if stageID := a.StageID[idx]; stageID >= 0 {
		return int(stageID)
	}
	protoID := int(a.PrototypeID[idx])
	if a.Sex[idx] == world.SexMale {
		return cfg.NumStages + protoID
	}
	return cfg.NumStages + cfg.NumPrototypesM + protoID
}

// relativeDirection computes which of the 8 directional buckets a target point
// falls into, relative to the agent's facing direction. Returns -1 if overlapping.
func relativeDirection(agentDir uint8, ax, ay, tx, ty float64) int {
	dx := tx - ax
	dy := ty - ay
	if dx == 0 && dy == 0 {
		return -1
	}
	absDir := computeAbsoluteDirection(dx, dy)
	return absoluteToRelative(agentDir, absDir)
}

// computeAbsoluteDirection returns the cardinal direction (1-8) from deltas.
func computeAbsoluteDirection(dx, dy float64) uint8 {
	adx := math.Abs(dx)
	ady := math.Abs(dy)

	if ady >= 2*adx+1 {
		if dy < 0 {
			return 2 // N
		}
		return 7 // S
	}
	if adx >= 2*ady+1 {
		if dx < 0 {
			return 4 // W
		}
		return 5 // E
	}
	if dx < 0 && dy < 0 {
		return 1 // NW
	}
	if dx > 0 && dy < 0 {
		return 3 // NE
	}
	if dx < 0 && dy > 0 {
		return 6 // SW
	}
	return 8 // SE
}

// absoluteToRelative converts an absolute direction to a relative direction index (0-7).
func absoluteToRelative(agentDir, absDir uint8) int {
	angAgent := dirAngleTable[agentDir]
	angTarget := dirAngleTable[absDir]
	relAngle := (angTarget - angAgent + 8) % 8
	return angleRelTable[relAngle]
}

// absoluteDirection converts a facing + relative direction to an absolute direction code.
func absoluteDirection(agentDir uint8, relDir uint8) uint8 {
	angAgent := dirAngleTable[agentDir]
	relAngle := dirAngleTable[relDir]
	absAngle := (angAgent + relAngle) % 8
	return angleDirTable[absAngle]
}

// --- Small helpers to reduce cognitive complexity ---

func distance(x1, y1, x2, y2 float64) float64 {
	dx := x2 - x1
	dy := y2 - y1
	return math.Sqrt(dx*dx + dy*dy)
}

func maxFloat64(s []float64) float64 {
	m := 0.0
	for _, v := range s {
		if v > m {
			m = v
		}
	}
	return m
}

func getResourceAttractiveness(ctx *PerceptionContext, radiusKey int, dist float64) int32 {
	if radiusKey >= len(ctx.ResourceAttr) {
		return 0
	}
	attr := ctx.ResourceAttr[radiusKey]
	if dist > 0 && attr != 0 {
		attr /= int32(math.Max(1, dist))
	}
	return attr
}

// getAgentAttractiveness reads the configured agent-to-agent attractiveness
// from the perception context (populated from the attractiveness_agents table),
// falling off with distance. Returns 0 when no attraction is configured, so by
// default agents do NOT attract each other.
func getAgentAttractiveness(ctx *PerceptionContext, radiusKey int, dist float64) int32 {
	if radiusKey < 0 || radiusKey >= len(ctx.AgentAttr) {
		return 0
	}
	attr := ctx.AgentAttr[radiusKey]
	if dist > 0 && attr != 0 {
		attr /= int32(math.Max(1, dist))
	}
	return attr
}

func accumulateTendency(a *world.AgentArrays, tendBase int, aDir uint8, ax, ay, tx, ty float64, attr int32) {
	dir := relativeDirection(aDir, ax, ay, tx, ty)
	if dir >= 0 && dir < 8 {
		a.Tendencies[tendBase+dir] += attr
	}
}

func clampPositive(v int32) int32 {
	if v < 0 {
		return 0
	}
	return v
}

func isReserveCritical(a *world.AgentArrays, idx int, cfg world.Config) bool {
	for n := 0; n < cfg.NumNutrients; n++ {
		if a.Reserves[idx*cfg.NumNutrients+n] <= criticalReserveLevel {
			return true
		}
	}
	return false
}

func zeroIfValid(slice []int32, idx int, max int) {
	if idx < max && idx < len(slice) {
		slice[idx] = 0
	}
}
