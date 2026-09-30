package formulas

import "testing"

func TestIsConstantFormula(t *testing.T) {
	r := NewRegistry()
	cases := []struct {
		formula string
		want    bool
	}{
		{"", true},
		{"0", true},
		{"5", true},
		{"3 + 4 * 2", true},
		{"Max(3, 5)", true},          // pure function of constants
		{"Round(2.7)", true},         // deterministic function
		{"Age", false},               // variable
		{"Age > 100", false},         // variable
		{"ReserveWater * 2", false},  // variable
		{"Random()", false},          // stochastic
		{"Random() * 10", false},     // stochastic
		{"Dice(6)", false},           // stochastic
		{"Max(Age, 5)", false},       // variable inside function
		{"Max(3, Random())", false},  // stochastic inside function
		{"If(Age > 5, 1, 0)", false}, // variable
		{"If(1 > 0, 2, 3)", true},    // all-constant conditional
	}
	for _, c := range cases {
		if got := r.IsConstantFormula(c.formula); got != c.want {
			t.Errorf("IsConstantFormula(%q) = %v, want %v", c.formula, got, c.want)
		}
	}
}
