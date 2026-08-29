package systems

import (
	"galatea/engine/internal/kernel/formulas"
	"galatea/engine/internal/kernel/world"
)

// AgentRef holds dynamically-evaluated reference values for a single agent.
// These are recalculated every tick (or as needed) using the formula engine,
// mirroring the legacy TMediador.ProveeValoresReferencia behavior.
type AgentRef struct {
	Longevity           int32
	RefractoryCombat    int32
	RefractoryCourtship int32
	Speed               int32
	MaxReserves         []int32 // per nutrient
	OptimalReserves     []int32 // per nutrient
	CriticalReserves    []int32 // per nutrient
	MinReserves         []int32 // per nutrient
	MaxGametes          int32
	GameteCosts         []int32 // per nutrient
	BehaviorCosts       []int32 // flat: [behavior * numNutrients + nutrient]
	// Offspring sex ratio, taken from the prototype (females carry the
	// meaningful ratio; the legacy reads it from the mother's prototype).
	SexRatioMales   int32
	SexRatioFemales int32
}

// NewAgentRef creates an AgentRef with pre-allocated slices.
func NewAgentRef(numNutrients, numBehaviors int) *AgentRef {
	return &AgentRef{
		Longevity:           1000,
		RefractoryCombat:    10,
		RefractoryCourtship: 10,
		Speed:               1,
		SexRatioMales:       50,
		SexRatioFemales:     50,
		MaxReserves:         make([]int32, numNutrients),
		OptimalReserves:     make([]int32, numNutrients),
		CriticalReserves:    make([]int32, numNutrients),
		MinReserves:         make([]int32, numNutrients),
		MaxGametes:          10,
		GameteCosts:         make([]int32, numNutrients),
		BehaviorCosts:       make([]int32, numBehaviors*numNutrients),
	}
}

// EvalRefValues evaluates all formula-based reference values for the agent at idx.
// It uses the formula registry to look up compiled formulas and the evaluator
// (with agent variables already set) to compute them.
//
// Formula key patterns:
//   - "metabolism.<nutrientIdx>.min", ".critical", ".optimal", ".max"
//   - "prototype.<protoIdx>.longevity", ".refractory_combat", ".refractory_courtship",
//     ".sex_ratio_males", ".sex_ratio_females"
//   - "behavior_cost.<behaviorIdx>.<nutrientIdx>"
//   - "gamete_cost.<M|F>.<nutrientIdx>"
//   - "reproduction.max_gametes"
//   - "substrate_velocity.<substrateId>"
func EvalRefValues(
	w *world.World,
	idx int,
	reg *formulas.Registry,
	eval *formulas.Evaluator,
	envBuilder *formulas.EnvBuilder,
	ref *AgentRef,
) {
	a := w.Agents
	cfg := w.Config

	// Set agent variables in evaluator.
	envBuilder.SetWorldVars(w)
	envBuilder.SetAgentVars(w, idx)

	// Prototype-level formulas.
	protoID := a.PrototypeID[idx]
	if protoID >= 0 {
		protoKey := "prototype." + itoa(int(protoID)) + "."
		ref.Longevity = evalIntFormula(reg, eval, protoKey+"longevity", int(ref.Longevity))
		ref.RefractoryCombat = evalIntFormula(reg, eval, protoKey+"refractory_combat", int(ref.RefractoryCombat))
		ref.RefractoryCourtship = evalIntFormula(reg, eval, protoKey+"refractory_courtship", int(ref.RefractoryCourtship))
		ref.SexRatioMales = evalIntFormula(reg, eval, protoKey+"sex_ratio_males", int(ref.SexRatioMales))
		ref.SexRatioFemales = evalIntFormula(reg, eval, protoKey+"sex_ratio_females", int(ref.SexRatioFemales))
	}

	// Metabolism per nutrient.
	for n := 0; n < cfg.NumNutrients; n++ {
		metaKey := "metabolism." + itoa(n) + "."
		ref.MinReserves[n] = evalIntFormula(reg, eval, metaKey+"min", 0)
		ref.CriticalReserves[n] = evalIntFormula(reg, eval, metaKey+"critical", 10)
		ref.OptimalReserves[n] = evalIntFormula(reg, eval, metaKey+"optimal", 50)
		ref.MaxReserves[n] = evalIntFormula(reg, eval, metaKey+"max", 100)
	}

	// Gamete costs per nutrient, keyed by the agent's sex ("M"/"F"). This
	// respects per-sex configuration from the gamete_costs table.
	sexKey := "M"
	if a.Sex[idx] == world.SexFemale {
		sexKey = "F"
	}
	for n := 0; n < cfg.NumNutrients; n++ {
		ref.GameteCosts[n] = evalIntFormula(reg, eval, "gamete_cost."+sexKey+"."+itoa(n), 5)
	}
	ref.MaxGametes = evalIntFormula(reg, eval, "reproduction.max_gametes", 10)

	// Behavior costs per behavior × nutrient.
	for b := 0; b < cfg.NumBehaviors; b++ {
		for n := 0; n < cfg.NumNutrients; n++ {
			key := "behavior_cost." + itoa(b) + "." + itoa(n)
			defaultCost := int32(1)
			if b == 1 { // Rest has no cost.
				defaultCost = 0
			}
			ref.BehaviorCosts[b*cfg.NumNutrients+n] = evalIntFormula(reg, eval, key, int(defaultCost))
		}
	}

	// Substrate velocity (based on current substrate).
	subX := int(a.PosX[idx])
	subY := int(a.PosY[idx])
	if subX >= 0 && subX < cfg.GridWidth && subY >= 0 && subY < cfg.GridHeight {
		subID := w.Substrates.Get(subX, subY)
		velKey := "substrate_velocity." + itoa(int(subID))
		ref.Speed = evalIntFormula(reg, eval, velKey, 1)
	}
}

// evalIntFormula evaluates a formula by key, returning defaultVal if not found or on error.
func evalIntFormula(reg *formulas.Registry, eval *formulas.Evaluator, key string, defaultVal int) int32 {
	p := reg.Get(key)
	if p == nil {
		return int32(defaultVal)
	}
	result, err := eval.RunProgramInt(p)
	if err != nil {
		return int32(defaultVal)
	}
	return int32(result)
}

// itoa is a minimal int-to-string for hot path use.
func itoa(n int) string {
	if n < 0 {
		return "-" + itoa(-n)
	}
	if n < 10 {
		return string(rune('0' + n))
	}
	return itoa(n/10) + string(rune('0'+n%10))
}
