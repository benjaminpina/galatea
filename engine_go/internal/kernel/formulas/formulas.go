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
	programs map[string]*Program
	options  []expr.Option
}

// NewRegistry creates a new formula registry with standard custom functions registered.
func NewRegistry() *Registry {
	r := &Registry{
		programs: make(map[string]*Program),
	}
	r.options = buildOptions()
	return r
}

// Compile compiles a formula string and stores it in the registry under the given key.
// If the formula is empty or "0", it still gets compiled (evaluates to 0).
func (r *Registry) Compile(key, formula string) error {
	if formula == "" {
		formula = "0"
	}

	program, err := expr.Compile(formula, r.options...)
	if err != nil {
		return fmt.Errorf("compile formula %q (key=%s): %w", formula, key, err)
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
		expr.Function("Random", funcRandom),
		expr.Function("RandG", funcRandG, new(func(float64, float64) float64)),
		expr.Function("Dice", funcDice, new(func(int) int)),
		expr.Function("Max", funcMax, new(func(float64, float64) float64)),
		expr.Function("Min", funcMin, new(func(float64, float64) float64)),
		expr.Function("Abs", funcAbs, new(func(float64) float64)),
		expr.Function("Sqrt", funcSqrt, new(func(float64) float64)),
		expr.Function("Round", funcRound, new(func(float64) int)),
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
