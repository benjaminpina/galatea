package formulas

import (
	"github.com/expr-lang/expr/ast"
	"github.com/expr-lang/expr/parser"
)

// stochasticFuncs are the built-in functions whose result changes between
// evaluations even with identical inputs. A formula calling any of these is
// never constant.
var stochasticFuncs = map[string]bool{
	"Random":    true,
	"RandG":     true,
	"Dice":      true,
	"RandInt":   true,
	"Bernoulli": true,
}

// IsConstantFormula reports whether a formula always evaluates to the same value
// regardless of agent/world state and across evaluations. A formula is constant
// when it references no variables (identifiers that are not function names) and
// calls no stochastic function. Custom user functions are expanded first, so
// their bodies are analyzed too.
//
// This lets the Cold Path decide, per formula, whether a result can be computed
// ONCE and cached, or must be evaluated per-agent in the hot path. Substrate
// attractiveness/interaction are the prime beneficiaries: when constant (the
// common case), the expensive per-cell terrain sweep is precomputed once.
//
// On a parse error the formula is conservatively treated as NOT constant.
func (r *Registry) IsConstantFormula(formula string) bool {
	if formula == "" {
		return true // Empty → "0".
	}
	expanded, err := r.customFuncs.Expand(formula)
	if err != nil {
		return false
	}
	tree, err := parser.Parse(expanded)
	if err != nil {
		return false
	}

	// First pass: collect identifier nodes that are function callees (so they
	// are not mistaken for variable references), and detect stochastic calls.
	pre := &calleeCollector{callees: map[*ast.IdentifierNode]bool{}}
	ast.Walk(&tree.Node, pre)
	if pre.stochastic {
		return false
	}

	// Second pass: any identifier that is not a callee is a variable → dynamic.
	v := &varDetector{callees: pre.callees, constant: true}
	ast.Walk(&tree.Node, v)
	return v.constant
}

// calleeCollector records identifiers used as function callees and flags any
// stochastic function call.
type calleeCollector struct {
	callees    map[*ast.IdentifierNode]bool
	stochastic bool
}

func (c *calleeCollector) Visit(node *ast.Node) {
	if call, ok := (*node).(*ast.CallNode); ok {
		if id, ok := call.Callee.(*ast.IdentifierNode); ok {
			c.callees[id] = true
			if stochasticFuncs[id.Value] {
				c.stochastic = true
			}
		}
	}
}

// varDetector flips constant to false when it finds an identifier that is not a
// function callee (i.e. a real variable reference).
type varDetector struct {
	callees  map[*ast.IdentifierNode]bool
	constant bool
}

func (v *varDetector) Visit(node *ast.Node) {
	if id, ok := (*node).(*ast.IdentifierNode); ok {
		if !v.callees[id] {
			v.constant = false
		}
	}
}
