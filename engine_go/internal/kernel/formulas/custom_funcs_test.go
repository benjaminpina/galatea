package formulas

import (
	"testing"
)

func TestCustomFuncExpansionBasic(t *testing.T) {
	cfr := NewCustomFuncRegistry()
	if err := cfr.Register("Double", []string{"x"}, "x * 2"); err != nil {
		t.Fatal(err)
	}

	result, err := cfr.Expand("Double(5)")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	expected := "((5) * 2)"
	if result != expected {
		t.Errorf("expected %q, got %q", expected, result)
	}
}

func TestCustomFuncExpansionMultipleParams(t *testing.T) {
	cfr := NewCustomFuncRegistry()
	if err := cfr.Register("Sigmoid", []string{"x", "k", "x0"}, "1 / (1 + exp(-k * (x - x0)))"); err != nil {
		t.Fatal(err)
	}

	result, err := cfr.Expand("Sigmoid(Age, 0.1, 250)")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	expected := "(1 / (1 + exp(-(0.1) * ((Age) - (250)))))"
	if result != expected {
		t.Errorf("expected %q, got %q", expected, result)
	}
}

func TestCustomFuncExpansionNested(t *testing.T) {
	cfr := NewCustomFuncRegistry()
	if err := cfr.Register("Square", []string{"x"}, "x * x"); err != nil {
		t.Fatal(err)
	}
	if err := cfr.Register("SquarePlus1", []string{"n"}, "Square(n) + 1"); err != nil {
		t.Fatal(err)
	}

	result, err := cfr.Expand("SquarePlus1(3)")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result == "SquarePlus1(3)" {
		t.Errorf("expansion did not occur: %q", result)
	}
	t.Logf("Nested expansion result: %s", result)
}

func TestCustomFuncExpansionWrongArity(t *testing.T) {
	cfr := NewCustomFuncRegistry()
	if err := cfr.Register("Add", []string{"a", "b"}, "a + b"); err != nil {
		t.Fatal(err)
	}

	_, err := cfr.Expand("Add(1)")
	if err == nil {
		t.Fatal("expected error for wrong arity, got nil")
	}
}

func TestCustomFuncExpansionNoRecursion(t *testing.T) {
	cfr := NewCustomFuncRegistry()
	err := cfr.Register("Inf", []string{"x"}, "Inf(x + 1)")
	if err == nil {
		t.Fatal("expected error for self-referencing function, got nil")
	}
	t.Logf("Got expected error: %v", err)
}

func TestCustomFuncWithRegistry(t *testing.T) {
	reg := NewRegistry()
	if err := reg.CustomFuncs().Register("Triple", []string{"x"}, "x * 3"); err != nil {
		t.Fatal(err)
	}

	err := reg.Compile("test.triple", "Triple(Age) + 1")
	if err != nil {
		t.Fatalf("compile error: %v", err)
	}

	eval := NewEvaluator(16)
	eval.Set("Age", 10)
	p := reg.MustGet("test.triple")
	result, err := eval.RunProgram(p)
	if err != nil {
		t.Fatalf("eval error: %v", err)
	}
	if toInt(result) != 31 {
		t.Errorf("expected 31, got %v", result)
	}
}

func TestSplitArgs(t *testing.T) {
	tests := []struct {
		input    string
		expected []string
	}{
		{"1, 2, 3", []string{"1", "2", "3"}},
		{"Age, Max(1, 2), 5", []string{"Age", "Max(1, 2)", "5"}},
		{"", nil},
		{"x", []string{"x"}},
	}

	for _, tc := range tests {
		result := splitArgs(tc.input)
		if len(result) != len(tc.expected) {
			t.Errorf("splitArgs(%q): got %v, expected %v", tc.input, result, tc.expected)
			continue
		}
		for i := range result {
			if result[i] != tc.expected[i] {
				t.Errorf("splitArgs(%q)[%d]: got %q, expected %q", tc.input, i, result[i], tc.expected[i])
			}
		}
	}
}
