// Package util provides small shared utilities for the kernel.
package util

// Itoa converts a non-negative integer to its string representation.
// It avoids importing strconv for this minimal use case in the hot path.
func Itoa(n int) string {
	if n < 0 {
		return "-" + Itoa(-n)
	}
	if n < 10 {
		return string(rune('0' + n))
	}
	return Itoa(n/10) + string(rune('0'+n%10))
}
