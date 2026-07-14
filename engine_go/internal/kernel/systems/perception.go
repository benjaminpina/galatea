// Package systems implements the simulation systems that operate on the World
// during the Hot Path tick loop. Each system is a pure function that reads
// and writes World state via index-based SoA access.
package systems

import (
	"math"

	"galatea/engine/internal/kernel/formulas"
	"galatea/engine/internal/kernel/spatial"
	"galatea/engine/internal/kernel/util"
	"galatea/engine/internal/kernel/world"
)

// Direction constants for tendency indexing (0-based internally, 1-based in legacy).
// Mapped to: NW=0, N=1, NE=2, W=3, E=4, SW=5, S=6, SE=7
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
	ResourceAttr  []int32 // Base attractiveness values (pre-evaluated where static).

	// Agent attractiveness radii: [observed * numPerceivers + perceiverIdx]
	AgentRadii []float64
}

// Perceive runs the full perception pipeline for agent at idx.
// It resets tendencies and VDecision, queries the spatial grids,
// accumulates attractiveness-weighted tendencies and behavior probabilities,
// then applies filters and boundary avoidance.
func Perceive(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config

	// Reset tendencies and VDecision for this agent.
	tendBase := idx * 8
	for d := 0; d < 8; d++ {
		a.Tendencies[tendBase+d] = 0
	}
	vdBase := idx * cfg.NumBehaviors
	for b := 0; b < cfg.NumBehaviors; b++ {
		a.VDecision[vdBase+b] = 0
	}

	// Set up the formula evaluator with this agent's variables.
	ctx.EnvBuilder.SetWorldVars(w)
	ctx.EnvBuilder.SetAgentVars(w, idx)

	// Perceive resources.
	perceiveResources(ctx, idx)

	// Perceive other agents.
	perceiveAgents(ctx, idx)

	// Apply base tendencies from prototype/stage formulas.
	applyBaseTendencies(ctx, idx)

	// Apply post-perception filters.
	applyFilters(ctx, idx)

	// Apply boundary avoidance.
	applyBoundaryAvoidance(ctx, idx)

	// Ensure at least one behavior is non-zero (force movement if all zero).
	ensureNonZeroDecision(ctx, idx)
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

	// Determine the maximum resource perception radius for broad query.
	maxRadius := 0.0
	for i := range ctx.ResourceRadii {
		if ctx.ResourceRadii[i] > maxRadius {
			maxRadius = ctx.ResourceRadii[i]
		}
	}
	if maxRadius <= 0 {
		return
	}

	// Query resource grid for candidates.
	candidates := ctx.ResourceGrid.QueryRadiusExact(ax, ay, maxRadius, r.PosX, r.PosY)

	tendBase := idx * 8
	vdBase := idx * cfg.NumBehaviors

	for _, rIdx := range candidates {
		rx := r.PosX[rIdx]
		ry := r.PosY[rIdx]
		dx := rx - ax
		dy := ry - ay
		dist := math.Sqrt(dx*dx + dy*dy)

		resourceType := int(r.TypeID[rIdx])

		// Check if within this specific resource type's perception radius for this agent.
		perceiverIdx := getPerceiverIndex(a, idx, cfg)
		radiusKey := resourceType*cfg.NumPrototypes + perceiverIdx
		if radiusKey >= len(ctx.ResourceRadii) || dist > ctx.ResourceRadii[radiusKey] {
			continue
		}

		// Calculate attractiveness (attenuated by distance).
		attractiveness := int32(0)
		if radiusKey < len(ctx.ResourceAttr) {
			attractiveness = ctx.ResourceAttr[radiusKey]
		}
		if dist > 0 && attractiveness != 0 {
			attractiveness = attractiveness / int32(math.Max(1, dist))
		}

		// Accumulate directional tendency.
		dir := relativeDirection(aDir, ax, ay, rx, ry)
		if dir >= 0 && dir < 8 {
			a.Tendencies[tendBase+dir] += attractiveness
		}

		// Accumulate VDecision influences from interaction formulas.
		// The behavior influenced depends on resource type (feeding behavior = 2 + resourceType).
		feedBehavior := 2 + resourceType // Behaviors: 0=move, 1=rest, 2..2+N=feed
		if feedBehavior < cfg.NumBehaviors {
			influence := attractiveness
			if influence < 0 {
				influence = 0
			}
			a.VDecision[vdBase+feedBehavior] += influence
		}

		// Mark resource as contiguous if distance <= 1 (for interaction establishment).
		if dist <= 1.5 {
			// Store perception flag in a compact way via VDecision boost.
			a.VDecision[vdBase+feedBehavior] += 1
		}
	}
}

// perceiveAgents queries the agent grid and accumulates tendencies + VDecision.
func perceiveAgents(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config

	ax := a.PosX[idx]
	ay := a.PosY[idx]
	aDir := a.Direction[idx]

	// Use maximum agent radius for broad query.
	maxRadius := 0.0
	for i := range ctx.AgentRadii {
		if ctx.AgentRadii[i] > maxRadius {
			maxRadius = ctx.AgentRadii[i]
		}
	}
	if maxRadius <= 0 {
		return
	}

	candidates := ctx.AgentGrid.QueryRadiusExact(ax, ay, maxRadius, a.PosX, a.PosY)

	tendBase := idx * 8
	vdBase := idx * cfg.NumBehaviors

	// Behavior indices for combat and courtship.
	fightDisplayIdx := 2 + cfg.NumResourceTypes      // fight_display
	fightEscalateIdx := 2 + cfg.NumResourceTypes + 1 // fight_escalate
	courtDisplayIdx := 2 + cfg.NumResourceTypes + 2  // court_display
	courtEscalateIdx := 2 + cfg.NumResourceTypes + 3 // court_escalate

	hasContender := false
	hasMate := false

	for _, cIdx := range candidates {
		if cIdx == int32(idx) {
			continue // Skip self.
		}
		if int(cIdx) >= a.Count {
			continue // Stale index.
		}

		cx := a.PosX[cIdx]
		cy := a.PosY[cIdx]
		dx := cx - ax
		dy := cy - ay
		dist := math.Sqrt(dx*dx + dy*dy)

		// Determine observed prototype index.
		observedIdx := getPerceiverIndex(a, int(cIdx), cfg)
		perceiverIdx := getPerceiverIndex(a, idx, cfg)

		// Check if within perception radius.
		radiusKey := observedIdx*cfg.NumPrototypes + perceiverIdx
		if radiusKey >= len(ctx.AgentRadii) || dist > ctx.AgentRadii[radiusKey] {
			continue
		}

		// Calculate attractiveness.
		attractiveness := int32(5) // Default base attractiveness.
		if dist > 0 {
			attractiveness = attractiveness / int32(math.Max(1, dist))
		}

		// Accumulate directional tendency.
		dir := relativeDirection(aDir, ax, ay, cx, cy)
		if dir >= 0 && dir < 8 {
			a.Tendencies[tendBase+dir] += attractiveness
		}

		// Check if contiguous (dist <= 1.5) for interaction availability.
		if dist <= 1.5 {
			// Determine if contender or mate.
			agentSex := a.Sex[idx]
			otherSex := a.Sex[cIdx]
			otherSituation := a.Situation[cIdx]

			// Only consider regular adults for interaction.
			if otherSituation == world.SituationRegular || otherSituation == world.SituationImmature {
				// Same sex or both undefined = potential contender.
				if agentSex == otherSex || agentSex == world.SexUndefined || otherSex == world.SexUndefined {
					hasContender = true
				}
				// Opposite sex = potential mate.
				if (agentSex == world.SexMale && otherSex == world.SexFemale) ||
					(agentSex == world.SexFemale && otherSex == world.SexMale) {
					hasMate = true
				}
			}
		}
	}

	// Boost fight/court behaviors based on detected contenders/mates.
	if hasContender {
		if fightDisplayIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+fightDisplayIdx] += 5
		}
		if fightEscalateIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+fightEscalateIdx] += 3
		}
	}
	if hasMate {
		if courtDisplayIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+courtDisplayIdx] += 5
		}
		if courtEscalateIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+courtEscalateIdx] += 3
		}
	}
}

// applyBaseTendencies evaluates the base tendency formulas for the agent's prototype/stage.
func applyBaseTendencies(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	tendBase := idx * 8

	// Look up tendency formulas by key: "tendency.<perceiverIdx>.<dir>"
	perceiverIdx := getPerceiverIndex(a, idx, w.Config)
	for d := 0; d < 8; d++ {
		key := "tendency." + util.Itoa(perceiverIdx) + "." + util.Itoa(d+1)
		p := ctx.Formulas.Get(key)
		if p != nil {
			val, err := ctx.Eval.RunProgramInt(p)
			if err == nil {
				a.Tendencies[tendBase+d] += int32(val)
			}
		}
	}

	// Apply base VDecision from interaction formulas (substrate-based).
	// Key: "vdecision.<perceiverIdx>.<behavior>"
	vdBase := idx * w.Config.NumBehaviors
	for b := 0; b < w.Config.NumBehaviors; b++ {
		key := "vdecision." + util.Itoa(perceiverIdx) + "." + util.Itoa(b+1)
		p := ctx.Formulas.Get(key)
		if p != nil {
			val, err := ctx.Eval.RunProgramInt(p)
			if err == nil {
				a.VDecision[vdBase+b] += int32(val)
			}
		}
	}
}

// applyFilters zeroes out behaviors that are unavailable given current state.
func applyFilters(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config
	vdBase := idx * cfg.NumBehaviors

	// Behavior indices for combat and courtship.
	fightDisplayIdx := 2 + cfg.NumResourceTypes
	fightEscalateIdx := 2 + cfg.NumResourceTypes + 1
	courtDisplayIdx := 2 + cfg.NumResourceTypes + 2
	courtEscalateIdx := 2 + cfg.NumResourceTypes + 3
	ovipositIdx := 2 + cfg.NumResourceTypes + 4

	// Disable fight if no contenders detected or in refractory period.
	if a.VDecision[vdBase+fightDisplayIdx] == 0 {
		a.VDecision[vdBase+fightEscalateIdx] = 0
	}

	// Disable courtship if no mates detected.
	if a.VDecision[vdBase+courtDisplayIdx] == 0 {
		a.VDecision[vdBase+courtEscalateIdx] = 0
	}

	// Disable oviposition if agent is male, or has no fertilized eggs.
	if a.Sex[idx] == world.SexMale || a.FertilizedCount[idx] == 0 {
		if ovipositIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+ovipositIdx] = 0
		}
	}

	// If reserves are at critical levels, disable fight and courtship.
	isCritical := false
	for n := 0; n < cfg.NumNutrients; n++ {
		reserve := a.Reserves[idx*cfg.NumNutrients+n]
		// Critical threshold check (simplified: < 10% of a nominal max).
		if reserve <= 5 {
			isCritical = true
			break
		}
	}
	if isCritical {
		if fightDisplayIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+fightDisplayIdx] = 0
			a.VDecision[vdBase+fightEscalateIdx] = 0
		}
		if courtDisplayIdx < cfg.NumBehaviors {
			a.VDecision[vdBase+courtDisplayIdx] = 0
			a.VDecision[vdBase+courtEscalateIdx] = 0
		}
	}

	// Clamp negative values to 0.
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

	// Add 1 to all tendencies to eliminate zeros before blocking (legacy behavior).
	atBoundary := x <= speed || x >= maxX-speed || y <= speed || y >= maxY-speed
	if !atBoundary {
		return
	}

	for d := 0; d < 8; d++ {
		a.Tendencies[tendBase+d] += 1
	}

	// Block directions that would exit bounds.
	// Directions are relative to agent's facing direction.
	// We compute the absolute direction for each relative direction and check bounds.
	for relDir := 0; relDir < 8; relDir++ {
		absDir := absoluteDirection(dir, uint8(relDir+1))
		dx, dy := directionDelta(absDir)

		newX := x + float64(dx)*speed
		newY := y + float64(dy)*speed

		if newX < 0 || newX > maxX || newY < 0 || newY > maxY {
			a.Tendencies[tendBase+relDir] = 0
		}
	}
}

// ensureNonZeroDecision forces at least movement if all VDecision weights are zero.
func ensureNonZeroDecision(ctx *PerceptionContext, idx int) {
	w := ctx.World
	a := w.Agents
	cfg := w.Config
	vdBase := idx * cfg.NumBehaviors

	allZero := true
	for b := 0; b < cfg.NumBehaviors; b++ {
		if a.VDecision[vdBase+b] > 0 {
			allZero = false
			break
		}
	}
	if allZero {
		a.VDecision[vdBase+0] = 1 // Force movement.
	}
}

// --- Helper functions ---

// getPerceiverIndex returns the unified index of an agent in the prototype listing:
// stages occupy 0..NumStages-1, males occupy NumStages..NumStages+NumPrototypesM-1, etc.
func getPerceiverIndex(a *world.AgentArrays, idx int, cfg world.Config) int {
	stageID := a.StageID[idx]
	if stageID >= 0 {
		return int(stageID) // Immature: index = stage index.
	}
	protoID := a.PrototypeID[idx]
	if a.Sex[idx] == world.SexMale {
		return cfg.NumStages + int(protoID)
	}
	return cfg.NumStages + cfg.NumPrototypesM + int(protoID)
}

// relativeDirection computes which of the 8 directional buckets a target point
// falls into, relative to the agent's facing direction.
// Returns 0-7 (NW,N,NE,W,E,SW,S,SE) or -1 if overlapping.
func relativeDirection(agentDir uint8, ax, ay, tx, ty float64) int {
	dx := tx - ax
	dy := ty - ay

	if dx == 0 && dy == 0 {
		return -1 // Overlap, no direction.
	}

	// Compute absolute direction to target.
	absDir := computeAbsoluteDirection(dx, dy)

	// Convert to relative direction based on agent's facing.
	return absoluteToRelative(agentDir, absDir)
}

// computeAbsoluteDirection returns the cardinal direction (1-8) from deltas.
// 1=NW, 2=N, 3=NE, 4=W, 5=E, 6=SW, 7=S, 8=SE
func computeAbsoluteDirection(dx, dy float64) uint8 {
	adx := math.Abs(dx)
	ady := math.Abs(dy)

	// Predominantly vertical.
	if ady >= 2*adx+1 {
		if dy < 0 {
			return 2 // N
		}
		return 7 // S
	}

	// Predominantly horizontal.
	if adx >= 2*ady+1 {
		if dx < 0 {
			return 4 // W
		}
		return 5 // E
	}

	// Diagonal.
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

// absoluteToRelative converts an absolute direction to a relative direction
// given the agent's facing direction. Uses lookup table approach.
// agentDir: 1-8, absDir: 1-8. Returns 0-7 relative index.
func absoluteToRelative(agentDir, absDir uint8) int {
	// The offset is (absDir - agentDir) mod 8, then remap to our 0-7 layout.
	// Directions are 1-indexed: 1=NW,2=N,3=NE,4=W,5=E,6=SW,7=S,8=SE
	// Order around compass: NW(1),N(2),NE(3),E(5),SE(8),S(7),SW(6),W(4)
	// Use a simpler mapping: map both to an angular index and compute delta.

	// Map direction to angular order (clockwise from N):
	// N=0, NE=1, E=2, SE=3, S=4, SW=5, W=6, NW=7
	angAgent := dirToAngle(agentDir)
	angTarget := dirToAngle(absDir)

	// Relative angle (clockwise offset from agent's forward).
	relAngle := (angTarget - angAgent + 8) % 8

	// Map relative angle back to our direction index:
	// 0=forward(N)=1, 1=front-right(NE)=2, 2=right(E)=4, 3=back-right(SE)=7
	// 4=back(S)=6, 5=back-left(SW)=5, 6=left(W)=3, 7=front-left(NW)=0
	return angleToRelIdx(relAngle)
}

// dirToAngle maps direction code (1-8) to clockwise angular index (0-7 from N).
func dirToAngle(d uint8) int {
	switch d {
	case 2:
		return 0 // N
	case 3:
		return 1 // NE
	case 5:
		return 2 // E
	case 8:
		return 3 // SE
	case 7:
		return 4 // S
	case 6:
		return 5 // SW
	case 4:
		return 6 // W
	case 1:
		return 7 // NW
	default:
		return 0
	}
}

// angleToRelIdx maps a relative clockwise angle (0-7) to our tendency array index.
// Forward=0° maps to DirN(1), etc.
func angleToRelIdx(angle int) int {
	// Relative angle 0=front, 1=front-right, 2=right, 3=back-right,
	//                4=back, 5=back-left, 6=left, 7=front-left
	switch angle {
	case 0:
		return DirN // Forward
	case 1:
		return DirNE // Front-right
	case 2:
		return DirE // Right
	case 3:
		return DirSE // Back-right
	case 4:
		return DirS // Back
	case 5:
		return DirSW // Back-left
	case 6:
		return DirW // Left
	case 7:
		return DirNW // Front-left
	default:
		return DirN
	}
}

// absoluteDirection converts a relative direction to absolute given the agent's facing.
func absoluteDirection(agentDir uint8, relDir uint8) uint8 {
	angAgent := dirToAngle(agentDir)
	relAngle := dirToAngle(relDir) // Same mapping as dirToAngle.
	absAngle := (angAgent + relAngle) % 8
	return angleToDirCode(absAngle)
}

// angleToDirCode maps clockwise angle (0-7) to direction code (1-8).
func angleToDirCode(angle int) uint8 {
	switch angle {
	case 0:
		return 2 // N
	case 1:
		return 3 // NE
	case 2:
		return 5 // E
	case 3:
		return 8 // SE
	case 4:
		return 7 // S
	case 5:
		return 6 // SW
	case 6:
		return 4 // W
	case 7:
		return 1 // NW
	default:
		return 2
	}
}

// directionDelta returns the x,y movement delta for an absolute direction code.
func directionDelta(dir uint8) (int, int) {
	switch dir {
	case 1:
		return -1, -1 // NW
	case 2:
		return 0, -1 // N
	case 3:
		return 1, -1 // NE
	case 4:
		return -1, 0 // W
	case 5:
		return 1, 0 // E
	case 6:
		return -1, 1 // SW
	case 7:
		return 0, 1 // S
	case 8:
		return 1, 1 // SE
	default:
		return 0, 0
	}
}
