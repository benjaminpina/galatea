package formulas

import (
	"fmt"

	"github.com/expr-lang/expr/vm"
)

// Evaluator runs compiled formula programs against an environment map.
// It is designed to be reused across multiple evaluations by updating the
// env map in place (avoiding allocations in the Hot Path).
type Evaluator struct {
	env map[string]any
}

// NewEvaluator creates an Evaluator with a pre-allocated environment map.
func NewEvaluator(initialCapacity int) *Evaluator {
	if initialCapacity < 64 {
		initialCapacity = 64
	}
	return &Evaluator{
		env: make(map[string]any, initialCapacity),
	}
}

// Env returns the internal environment map for direct manipulation.
// Callers should set variable values here before calling Run/RunInt/RunFloat.
func (e *Evaluator) Env() map[string]any {
	return e.env
}

// Set sets a variable in the environment.
func (e *Evaluator) Set(name string, value any) {
	e.env[name] = value
}

// SetInt sets an integer variable.
func (e *Evaluator) SetInt(name string, value int) {
	e.env[name] = value
}

// SetFloat sets a float64 variable.
func (e *Evaluator) SetFloat(name string, value float64) {
	e.env[name] = value
}

// Clear removes all variables from the environment.
func (e *Evaluator) Clear() {
	for k := range e.env {
		delete(e.env, k)
	}
}

// Run executes a compiled program and returns the raw result.
func (e *Evaluator) Run(program *vm.Program) (any, error) {
	result, err := vm.Run(program, e.env)
	if err != nil {
		return nil, fmt.Errorf("formula eval: %w", err)
	}
	return result, nil
}

// RunInt executes a compiled program and returns the result as int.
func (e *Evaluator) RunInt(program *vm.Program) (int, error) {
	result, err := e.Run(program)
	if err != nil {
		return 0, err
	}
	return toInt(result), nil
}

// RunFloat executes a compiled program and returns the result as float64.
func (e *Evaluator) RunFloat(program *vm.Program) (float64, error) {
	result, err := e.Run(program)
	if err != nil {
		return 0, err
	}
	return toFloat64(result), nil
}

// RunProgram is a convenience method that takes a *Program from the registry.
func (e *Evaluator) RunProgram(p *Program) (any, error) {
	if p == nil {
		return 0, nil
	}
	return e.Run(p.Compiled)
}

// RunProgramInt evaluates a Program and returns int.
func (e *Evaluator) RunProgramInt(p *Program) (int, error) {
	if p == nil {
		return 0, nil
	}
	return e.RunInt(p.Compiled)
}

// RunProgramFloat evaluates a Program and returns float64.
func (e *Evaluator) RunProgramFloat(p *Program) (float64, error) {
	if p == nil {
		return 0, nil
	}
	return e.RunFloat(p.Compiled)
}

// EvalRegistryInt is a convenience that looks up a key in the registry and evaluates as int.
func EvalRegistryInt(reg *Registry, eval *Evaluator, key string) (int, error) {
	p := reg.Get(key)
	if p == nil {
		return 0, fmt.Errorf("formula key not found: %s", key)
	}
	return eval.RunInt(p.Compiled)
}

// EvalRegistryFloat is a convenience that looks up a key and evaluates as float64.
func EvalRegistryFloat(reg *Registry, eval *Evaluator, key string) (float64, error) {
	p := reg.Get(key)
	if p == nil {
		return 0, fmt.Errorf("formula key not found: %s", key)
	}
	return eval.RunFloat(p.Compiled)
}
