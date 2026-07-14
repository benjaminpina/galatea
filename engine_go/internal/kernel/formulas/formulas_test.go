package formulas

import (
	"math"
	"testing"

	"galatea/engine/internal/kernel/world"
)

func TestCompileAndEvalBasic(t *testing.T) {
	reg := NewRegistry()

	err := reg.Compile("test.add", "2 + 3")
	if err != nil {
		t.Fatalf("Compile: %v", err)
	}

	eval := NewEvaluator(16)
	result, err := eval.RunProgramInt(reg.Get("test.add"))
	if err != nil {
		t.Fatalf("RunProgramInt: %v", err)
	}
	if result != 5 {
		t.Fatalf("expected 5, got %d", result)
	}
}

func TestCompileWithVariables(t *testing.T) {
	reg := NewRegistry()
	reg.Compile("test.formula", "Age * 2 + Reserve1")

	eval := NewEvaluator(16)
	eval.SetInt("Age", 100)
	eval.SetInt("Reserve1", 50)

	result, err := eval.RunProgramInt(reg.Get("test.formula"))
	if err != nil {
		t.Fatalf("RunProgramInt: %v", err)
	}
	if result != 250 {
		t.Fatalf("expected 250, got %d", result)
	}
}

func TestCompileArithmetic(t *testing.T) {
	reg := NewRegistry()
	eval := NewEvaluator(16)

	cases := []struct {
		formula string
		vars    map[string]any
		expect  float64
	}{
		{"10 / 2", nil, 5},
		{"3 * 4 + 1", nil, 13},
		{"(A + B) * C", map[string]any{"A": 2, "B": 3, "C": 4}, 20},
		{"A ^ 2", map[string]any{"A": 5.0}, 25},
		{"100 % 7", nil, 2},
	}

	for _, tc := range cases {
		key := "test." + tc.formula
		err := reg.Compile(key, tc.formula)
		if err != nil {
			t.Fatalf("Compile %q: %v", tc.formula, err)
		}

		eval.Clear()
		for k, v := range tc.vars {
			eval.Set(k, v)
		}

		result, err := eval.RunProgramFloat(reg.Get(key))
		if err != nil {
			t.Fatalf("Eval %q: %v", tc.formula, err)
		}
		if math.Abs(result-tc.expect) > 0.001 {
			t.Fatalf("%q: expected %f, got %f", tc.formula, tc.expect, result)
		}
	}
}

func TestCustomFuncRandom(t *testing.T) {
	reg := NewRegistry()
	reg.Compile("test.rnd", "Random()")

	eval := NewEvaluator(16)

	// Run multiple times, verify result is in [0,1).
	for i := 0; i < 100; i++ {
		result, err := eval.RunProgramFloat(reg.Get("test.rnd"))
		if err != nil {
			t.Fatalf("Random(): %v", err)
		}
		if result < 0 || result >= 1 {
			t.Fatalf("Random() returned %f, expected [0,1)", result)
		}
	}
}

func TestCustomFuncRandG(t *testing.T) {
	reg := NewRegistry()
	reg.Compile("test.randg", "RandG(0.5, 0.1)")

	eval := NewEvaluator(16)

	// Run many times and verify the mean is approximately 0.5.
	sum := 0.0
	n := 10000
	for i := 0; i < n; i++ {
		result, err := eval.RunProgramFloat(reg.Get("test.randg"))
		if err != nil {
			t.Fatalf("RandG(): %v", err)
		}
		sum += result
	}
	mean := sum / float64(n)
	if math.Abs(mean-0.5) > 0.02 {
		t.Fatalf("RandG mean: expected ~0.5, got %f", mean)
	}
}

func TestCustomFuncDice(t *testing.T) {
	reg := NewRegistry()
	reg.Compile("test.dice", "Dice(6)")

	eval := NewEvaluator(16)

	for i := 0; i < 100; i++ {
		result, err := eval.RunProgramInt(reg.Get("test.dice"))
		if err != nil {
			t.Fatalf("Dice(): %v", err)
		}
		if result < 1 || result > 6 {
			t.Fatalf("Dice(6) returned %d, expected [1,6]", result)
		}
	}
}

func TestCustomFuncMath(t *testing.T) {
	reg := NewRegistry()
	eval := NewEvaluator(16)

	reg.Compile("t.max", "Max(3.0, 7.0)")
	reg.Compile("t.min", "Min(3.0, 7.0)")
	reg.Compile("t.abs", "Abs(-5.0)")
	reg.Compile("t.sqrt", "Sqrt(16.0)")
	reg.Compile("t.round", "Round(3.7)")

	r, _ := eval.RunProgramFloat(reg.Get("t.max"))
	if r != 7 {
		t.Fatalf("Max: expected 7, got %f", r)
	}
	r, _ = eval.RunProgramFloat(reg.Get("t.min"))
	if r != 3 {
		t.Fatalf("Min: expected 3, got %f", r)
	}
	r, _ = eval.RunProgramFloat(reg.Get("t.abs"))
	if r != 5 {
		t.Fatalf("Abs: expected 5, got %f", r)
	}
	r, _ = eval.RunProgramFloat(reg.Get("t.sqrt"))
	if r != 4 {
		t.Fatalf("Sqrt: expected 4, got %f", r)
	}
	ri, _ := eval.RunProgramInt(reg.Get("t.round"))
	if ri != 4 {
		t.Fatalf("Round: expected 4, got %d", ri)
	}
}

func TestCompileError(t *testing.T) {
	reg := NewRegistry()
	err := reg.Compile("test.bad", "1 +")
	if err == nil {
		t.Fatal("expected compile error for '1 +', got nil")
	}
}

func TestEmptyFormula(t *testing.T) {
	reg := NewRegistry()
	err := reg.Compile("test.empty", "")
	if err != nil {
		t.Fatalf("empty formula should compile to 0: %v", err)
	}

	eval := NewEvaluator(16)
	result, _ := eval.RunProgramInt(reg.Get("test.empty"))
	if result != 0 {
		t.Fatalf("empty formula: expected 0, got %d", result)
	}
}

func TestUndefinedVariableReturnsZero(t *testing.T) {
	reg := NewRegistry()
	// AllowUndefinedVariables is set, so undefined vars evaluate to nil/zero.
	reg.Compile("test.undef", "UnknownVar")

	eval := NewEvaluator(16)
	result, err := eval.RunProgramInt(reg.Get("test.undef"))
	if err != nil {
		t.Fatalf("undefined var eval: %v", err)
	}
	if result != 0 {
		t.Fatalf("undefined var: expected 0, got %d", result)
	}
}

func TestRegistryCount(t *testing.T) {
	reg := NewRegistry()
	reg.Compile("a", "1")
	reg.Compile("b", "2")
	reg.Compile("c", "3")

	if reg.Count() != 3 {
		t.Fatalf("expected count=3, got %d", reg.Count())
	}
}

func TestEvalRegistryHelpers(t *testing.T) {
	reg := NewRegistry()
	reg.Compile("cost.move", "Age + 5")

	eval := NewEvaluator(16)
	eval.SetInt("Age", 10)

	result, err := EvalRegistryInt(reg, eval, "cost.move")
	if err != nil {
		t.Fatalf("EvalRegistryInt: %v", err)
	}
	if result != 15 {
		t.Fatalf("expected 15, got %d", result)
	}

	_, err = EvalRegistryInt(reg, eval, "nonexistent.key")
	if err == nil {
		t.Fatal("expected error for nonexistent key")
	}
}

func TestEnvBuilderSetAgentVars(t *testing.T) {
	cfg := world.Config{
		NumNutrients:     2,
		NumLoci:          2,
		NumStages:        1,
		NumPrototypesM:   1,
		NumPrototypesF:   1,
		NumPrototypes:    3,
		NumResourceTypes: 1,
		NumSubstrates:    3,
		NumBehaviors:     12,
		NumDirections:    8,
		GridWidth:        10,
		GridHeight:       10,
		InitialCapacity:  8,
	}

	w := world.New(cfg)
	idx := w.AddAgent()
	w.Agents.Age[idx] = 42
	w.Agents.Sex[idx] = world.SexMale
	w.Agents.StageID[idx] = 0
	// Set reserves.
	w.Agents.Reserves[idx*2+0] = 80
	w.Agents.Reserves[idx*2+1] = 60
	// Set genotype.
	w.Agents.GenotypeCont[idx*4+0] = 1.5 // Locus1 pat
	w.Agents.GenotypeCont[idx*4+1] = 0.5 // Locus1 mat
	w.Agents.DominanceCont[idx*4+0] = 1  // pat dominant
	w.Agents.DominanceCont[idx*4+1] = 0  // mat recessive

	w.Tick = 100

	eval := NewEvaluator(64)
	builder := NewEnvBuilder(eval, cfg)
	builder.SetWorldVars(w)
	builder.SetAgentVars(w, idx)

	// Verify variables are set correctly.
	env := eval.Env()

	if env["Age"] != 42 {
		t.Fatalf("Age: expected 42, got %v", env["Age"])
	}
	if env["Cycles"] != 100 {
		t.Fatalf("Cycles: expected 100, got %v", env["Cycles"])
	}
	if env["IsMale"] != true {
		t.Fatalf("IsMale: expected true, got %v", env["IsMale"])
	}
	if env["Reserve1"] != 80 {
		t.Fatalf("Reserve1: expected 80, got %v", env["Reserve1"])
	}
	if env["Reserve2"] != 60 {
		t.Fatalf("Reserve2: expected 60, got %v", env["Reserve2"])
	}
	// CL1 should be paternal value (dominant), so 1.5.
	if env["CL1"] != 1.5 {
		t.Fatalf("CL1: expected 1.5, got %v", env["CL1"])
	}

	// Now use the env to evaluate a formula.
	reg := NewRegistry()
	reg.Compile("test.cost", "Reserve1 + Age * 2")
	result, err := eval.RunProgramInt(reg.Get("test.cost"))
	if err != nil {
		t.Fatalf("eval with agent vars: %v", err)
	}
	if result != 164 { // 80 + 42*2
		t.Fatalf("expected 164, got %d", result)
	}
}

func TestPerformance(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping performance test in short mode")
	}

	reg := NewRegistry()
	reg.Compile("perf.formula", "(Reserve1 + Reserve2) * Age / (CL1 + 1)")

	eval := NewEvaluator(64)
	eval.SetInt("Reserve1", 80)
	eval.SetInt("Reserve2", 60)
	eval.SetInt("Age", 100)
	eval.SetFloat("CL1", 1.5)

	// Warm up.
	for i := 0; i < 100; i++ {
		eval.RunProgramInt(reg.Get("perf.formula"))
	}

	start := testing.Benchmark(func(b *testing.B) {
		for i := 0; i < b.N; i++ {
			eval.RunProgramInt(reg.Get("perf.formula"))
		}
	})

	nsPerOp := float64(start.T.Nanoseconds()) / float64(start.N)
	opsPerSec := 1e9 / nsPerOp

	t.Logf("Formula eval: %.0f ns/op (%.0f ops/sec)", nsPerOp, opsPerSec)

	// Target: at least 1M evals/sec (should be much faster).
	if opsPerSec < 1_000_000 {
		t.Logf("WARNING: performance below 1M ops/sec: %.0f", opsPerSec)
	}
}
