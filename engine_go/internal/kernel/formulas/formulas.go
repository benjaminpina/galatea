// Package formulas provides the formula compilation and evaluation engine for Galatea.
// Formulas are compiled to bytecode during the Cold Path and evaluated efficiently
// during the Hot Path using a reusable environment map.
package formulas

import (
	"fmt"
	"math"
	"math/rand/v2"

	"github.com/expr-lang/expr"
	"github.com/expr-lang/expr/vm"
)

// Program wraps a compiled expr program with its source for debugging.
type Program struct {
	Source   string
	Compiled *vm.Program
}

// Registry holds all compiled formula programs indexed by a string key.
// Keys follow the pattern: "category.entity.field" (e.g., "prototype.1.longevity").
type Registry struct {
	programs    map[string]*Program
	options     []expr.Option
	customFuncs *CustomFuncRegistry
}

// NewRegistry creates a new formula registry with standard custom functions registered.
func NewRegistry() *Registry {
	r := &Registry{
		programs:    make(map[string]*Program),
		customFuncs: NewCustomFuncRegistry(),
	}
	r.options = buildOptions()
	return r
}

// CustomFuncs returns the custom function registry for registering user-defined functions.
func (r *Registry) CustomFuncs() *CustomFuncRegistry {
	return r.customFuncs
}

// Compile compiles a formula string and stores it in the registry under the given key.
// If the formula is empty or "0", it still gets compiled (evaluates to 0).
// User-defined custom functions are macro-expanded before compilation.
func (r *Registry) Compile(key, formula string) error {
	if formula == "" {
		formula = "0"
	}

	// Expand user-defined functions via macro substitution.
	expanded, err := r.customFuncs.Expand(formula)
	if err != nil {
		return fmt.Errorf("expand custom functions in %q (key=%s): %w", formula, key, err)
	}

	program, err := expr.Compile(expanded, r.options...)
	if err != nil {
		return fmt.Errorf("compile formula %q (expanded: %q, key=%s): %w", formula, expanded, key, err)
	}

	r.programs[key] = &Program{
		Source:   formula,
		Compiled: program,
	}
	return nil
}

// Get retrieves a compiled program by key. Returns nil if not found.
func (r *Registry) Get(key string) *Program {
	return r.programs[key]
}

// MustGet retrieves a compiled program by key. Panics if not found.
func (r *Registry) MustGet(key string) *Program {
	p := r.programs[key]
	if p == nil {
		panic(fmt.Sprintf("formula not found: %s", key))
	}
	return p
}

// Count returns the number of compiled programs in the registry.
func (r *Registry) Count() int {
	return len(r.programs)
}

// Keys returns all registered formula keys.
func (r *Registry) Keys() []string {
	keys := make([]string, 0, len(r.programs))
	for k := range r.programs {
		keys = append(keys, k)
	}
	return keys
}

// buildOptions returns the expr compilation options with custom functions.
func buildOptions() []expr.Option {
	return []expr.Option{
		expr.AllowUndefinedVariables(),
		// --- Random / Stochastic ---
		expr.Function("Random", funcRandom),
		expr.Function("RandG", funcRandG, new(func(float64, float64) float64)),
		expr.Function("Dice", funcDice, new(func(int) int)),
		expr.Function("RandInt", funcRandInt, new(func(int, int) int)),
		expr.Function("Bernoulli", funcBernoulli, new(func(float64) int)),
		// --- Math ---
		expr.Function("Max", funcMax, new(func(float64, float64) float64)),
		expr.Function("Min", funcMin, new(func(float64, float64) float64)),
		expr.Function("Abs", funcAbs, new(func(float64) float64)),
		expr.Function("Sqrt", funcSqrt, new(func(float64) float64)),
		expr.Function("Round", funcRound, new(func(float64) int)),
		expr.Function("Floor", funcFloor, new(func(float64) int)),
		expr.Function("Ceil", funcCeil, new(func(float64) int)),
		expr.Function("Pow", funcPow, new(func(float64, float64) float64)),
		expr.Function("Log", funcLog, new(func(float64) float64)),
		expr.Function("Log10", funcLog10, new(func(float64) float64)),
		// --- Clamping / Interpolation ---
		expr.Function("Clamp", funcClamp, new(func(float64, float64, float64) float64)),
		expr.Function("Lerp", funcLerp, new(func(float64, float64, float64) float64)),
		// --- Activation / Threshold ---
		expr.Function("Sigmoid", funcSigmoid, new(func(float64, float64, float64) float64)),
		expr.Function("Step", funcStep, new(func(float64, float64) float64)),
		// --- Conditional ---
		expr.Function("If", funcIf, new(func(bool, float64, float64) float64)),
	}
}

// --- Custom Functions ---

// funcRandom returns a uniform random float in [0, 1).
func funcRandom(params ...any) (any, error) {
	return rand.Float64(), nil
}

// funcRandG returns a Gaussian random number with given mean and stddev.
// Uses the Marsaglia-Bray polar method (same algorithm as the legacy system).
func funcRandG(params ...any) (any, error) {
	mean := toFloat64(params[0])
	stddev := toFloat64(params[1])
	return rand.NormFloat64()*stddev + mean, nil
}

// funcDice returns a random integer from 1 to faces (inclusive).
func funcDice(params ...any) (any, error) {
	faces := toInt(params[0])
	if faces <= 0 {
		return 1, nil
	}
	return rand.IntN(faces) + 1, nil
}

// funcMax returns the larger of two values.
func funcMax(params ...any) (any, error) {
	a := toFloat64(params[0])
	b := toFloat64(params[1])
	return math.Max(a, b), nil
}

// funcMin returns the smaller of two values.
func funcMin(params ...any) (any, error) {
	a := toFloat64(params[0])
	b := toFloat64(params[1])
	return math.Min(a, b), nil
}

// funcAbs returns the absolute value.
func funcAbs(params ...any) (any, error) {
	return math.Abs(toFloat64(params[0])), nil
}

// funcSqrt returns the square root.
func funcSqrt(params ...any) (any, error) {
	return math.Sqrt(toFloat64(params[0])), nil
}

// funcRound rounds to the nearest integer.
func funcRound(params ...any) (any, error) {
	return int(math.Round(toFloat64(params[0]))), nil
}

// funcFloor returns the largest integer <= x.
func funcFloor(params ...any) (any, error) {
	return int(math.Floor(toFloat64(params[0]))), nil
}

// funcCeil returns the smallest integer >= x.
func funcCeil(params ...any) (any, error) {
	return int(math.Ceil(toFloat64(params[0]))), nil
}

// funcPow returns base raised to the power of exp.
func funcPow(params ...any) (any, error) {
	return math.Pow(toFloat64(params[0]), toFloat64(params[1])), nil
}

// funcLog returns the natural logarithm of x (ln).
func funcLog(params ...any) (any, error) {
	return math.Log(toFloat64(params[0])), nil
}

// funcLog10 returns the base-10 logarithm of x.
func funcLog10(params ...any) (any, error) {
	return math.Log10(toFloat64(params[0])), nil
}

// funcClamp constrains x to be within [min, max].
func funcClamp(params ...any) (any, error) {
	x := toFloat64(params[0])
	lo := toFloat64(params[1])
	hi := toFloat64(params[2])
	if x < lo {
		return lo, nil
	}
	if x > hi {
		return hi, nil
	}
	return x, nil
}

// funcLerp linearly interpolates between a and b by t (t=0→a, t=1→b).
func funcLerp(params ...any) (any, error) {
	a := toFloat64(params[0])
	b := toFloat64(params[1])
	t := toFloat64(params[2])
	return a + (b-a)*t, nil
}

// funcSigmoid returns the logistic sigmoid: 1 / (1 + exp(-k*(x-x0))).
func funcSigmoid(params ...any) (any, error) {
	x := toFloat64(params[0])
	k := toFloat64(params[1])
	x0 := toFloat64(params[2])
	return 1.0 / (1.0 + math.Exp(-k*(x-x0))), nil
}

// funcStep returns 0 if x < threshold, 1 otherwise.
func funcStep(params ...any) (any, error) {
	x := toFloat64(params[0])
	threshold := toFloat64(params[1])
	if x < threshold {
		return 0.0, nil
	}
	return 1.0, nil
}

// funcIf returns trueVal if condition is true, falseVal otherwise.
func funcIf(params ...any) (any, error) {
	cond := false
	switch v := params[0].(type) {
	case bool:
		cond = v
	case int:
		cond = v != 0
	case float64:
		cond = v != 0
	}
	if cond {
		return toFloat64(params[1]), nil
	}
	return toFloat64(params[2]), nil
}

// funcRandInt returns a random integer in [min, max] inclusive.
func funcRandInt(params ...any) (any, error) {
	min := toInt(params[0])
	max := toInt(params[1])
	if max <= min {
		return min, nil
	}
	return min + rand.IntN(max-min+1), nil
}

// funcBernoulli returns 1 with probability p, 0 otherwise.
func funcBernoulli(params ...any) (any, error) {
	p := toFloat64(params[0])
	if rand.Float64() < p {
		return 1, nil
	}
	return 0, nil
}

// --- Type Conversion Helpers ---

func toFloat64(v any) float64 {
	switch val := v.(type) {
	case float64:
		return val
	case float32:
		return float64(val)
	case int:
		return float64(val)
	case int32:
		return float64(val)
	case int64:
		return float64(val)
	case uint:
		return float64(val)
	case uint8:
		return float64(val)
	default:
		return 0
	}
}

func toInt(v any) int {
	switch val := v.(type) {
	case int:
		return val
	case int32:
		return int(val)
	case int64:
		return int(val)
	case float64:
		return int(val)
	case float32:
		return int(val)
	case uint:
		return int(val)
	default:
		return 0
	}
}
