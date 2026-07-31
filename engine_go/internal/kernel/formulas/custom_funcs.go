package formulas

import (
	"fmt"
	"regexp"
	"strings"
)

// CustomFuncDef represents a user-defined function loaded from the database.
type CustomFuncDef struct {
	Name   string
	Params []string // Parameter names (e.g., ["x", "k", "x0"])
	Body   string   // Formula body (e.g., "1 / (1 + exp(-k * (x - x0)))")
}

// CustomFuncRegistry holds user-defined functions and provides macro-expansion.
type CustomFuncRegistry struct {
	funcs map[string]*CustomFuncDef
}

// NewCustomFuncRegistry creates an empty custom function registry.
func NewCustomFuncRegistry() *CustomFuncRegistry {
	return &CustomFuncRegistry{
		funcs: make(map[string]*CustomFuncDef),
	}
}

// Register adds a user-defined function to the registry.
// Returns an error if the function body references itself (no recursion allowed).
func (r *CustomFuncRegistry) Register(name string, params []string, body string) error {
	// Check for self-reference.
	selfPattern := regexp.MustCompile(`\b` + regexp.QuoteMeta(name) + `\s*\(`)
	if selfPattern.MatchString(body) {
		return fmt.Errorf("function %q references itself (recursion not allowed)", name)
	}
	r.funcs[name] = &CustomFuncDef{
		Name:   name,
		Params: params,
		Body:   body,
	}
	return nil
}

// Get retrieves a function definition by name.
func (r *CustomFuncRegistry) Get(name string) *CustomFuncDef {
	return r.funcs[name]
}

// Names returns all registered custom function names.
func (r *CustomFuncRegistry) Names() []string {
	names := make([]string, 0, len(r.funcs))
	for name := range r.funcs {
		names = append(names, name)
	}
	return names
}

// Count returns the number of registered functions.
func (r *CustomFuncRegistry) Count() int {
	return len(r.funcs)
}

// Expand performs macro-expansion on a formula string, replacing all calls to
// user-defined functions with their bodies (parameter substitution).
//
// For example, if Sigmoid(x, k, x0) = "1 / (1 + exp(-k * (x - x0)))"
// then "Sigmoid(Age, 0.1, 250)" becomes "1 / (1 + exp(-(0.1) * ((Age) - (250))))"
//
// Expansion is applied iteratively (up to maxDepth levels) to support functions
// that call other user-defined functions, but NOT recursion (a function cannot
// call itself).
func (r *CustomFuncRegistry) Expand(formula string) (string, error) {
	if len(r.funcs) == 0 {
		return formula, nil
	}

	const maxDepth = 10
	result := formula

	for depth := 0; depth < maxDepth; depth++ {
		expanded, changed, err := r.expandOnce(result)
		if err != nil {
			return "", err
		}
		if !changed {
			return expanded, nil
		}
		result = expanded
	}

	return "", fmt.Errorf("custom function expansion exceeded max depth %d (possible circular reference) in: %s", maxDepth, formula)
}

// expandOnce performs a single pass of expansion over the formula.
func (r *CustomFuncRegistry) expandOnce(formula string) (string, bool, error) {
	changed := false
	result := formula

	for name, def := range r.funcs {
		// Build regex to find calls: FuncName( ... )
		pattern := regexp.MustCompile(`\b` + regexp.QuoteMeta(name) + `\s*\(`)

		for {
			loc := pattern.FindStringIndex(result)
			if loc == nil {
				break
			}

			// Find the matching closing parenthesis.
			callStart := loc[0]
			argsStart := loc[1] // position right after the opening '('
			parenDepth := 1
			pos := argsStart
			for pos < len(result) && parenDepth > 0 {
				switch result[pos] {
				case '(':
					parenDepth++
				case ')':
					parenDepth--
				}
				pos++
			}
			if parenDepth != 0 {
				return "", false, fmt.Errorf("unmatched parenthesis in call to %s", name)
			}

			// Extract the arguments string.
			argsStr := result[argsStart : pos-1]
			args := splitArgs(argsStr)

			if len(args) != len(def.Params) {
				return "", false, fmt.Errorf(
					"function %s expects %d parameters (%s), got %d",
					name, len(def.Params), strings.Join(def.Params, ", "), len(args),
				)
			}

			// Substitute parameters into the body.
			expanded := expandBody(def.Body, def.Params, args)

			// Replace the call in the formula with the expanded body (wrapped in parens).
			result = result[:callStart] + "(" + expanded + ")" + result[pos:]
			changed = true
		}
	}

	return result, changed, nil
}

// splitArgs splits a comma-separated argument string respecting nested parentheses.
func splitArgs(s string) []string {
	s = strings.TrimSpace(s)
	if s == "" {
		return nil
	}

	var args []string
	depth := 0
	start := 0

	for i := 0; i < len(s); i++ {
		switch s[i] {
		case '(':
			depth++
		case ')':
			depth--
		case ',':
			if depth == 0 {
				args = append(args, strings.TrimSpace(s[start:i]))
				start = i + 1
			}
		}
	}
	args = append(args, strings.TrimSpace(s[start:]))
	return args
}

// expandBody substitutes parameter names in the body with argument expressions.
// Each argument is wrapped in parentheses to preserve precedence.
func expandBody(body string, params []string, args []string) string {
	result := body
	// Replace longest param names first to avoid partial matches.
	// Sort by length descending.
	type paramArg struct {
		param string
		arg   string
	}
	pairs := make([]paramArg, len(params))
	for i := range params {
		pairs[i] = paramArg{params[i], args[i]}
	}
	// Sort descending by param name length.
	for i := range pairs {
		for j := i + 1; j < len(pairs); j++ {
			if len(pairs[j].param) > len(pairs[i].param) {
				pairs[i], pairs[j] = pairs[j], pairs[i]
			}
		}
	}

	for _, p := range pairs {
		// Use word boundary replacement to avoid replacing substrings.
		re := regexp.MustCompile(`\b` + regexp.QuoteMeta(p.param) + `\b`)
		result = re.ReplaceAllString(result, "("+p.arg+")")
	}

	return result
}
