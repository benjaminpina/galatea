package substrate

import (
	"errors"
)

var (
	// ErrSubstrateExists is returned when attempting to add a substrate that already exists
	ErrSubstrateExists = errors.New("substrate already exists in the mix")
	// ErrExceedsMaxPercentage is returned when the total percentage exceeds 100%
	ErrExceedsMaxPercentage = errors.New("total percentage exceeds 100%")
	// ErrSubstrateNotFound is returned when a substrate is not found in the mix
	ErrSubstrateNotFound = errors.New("substrate not found in the mix")
	// ErrInvalidPercentage is returned when the total percentage is not exactly 100%
	ErrInvalidPercentage = errors.New("total percentage is not exactly 100%")
)

// SubstratePercentage represents a substrate with its percentage in a mix
type SubstratePercentage struct {
	Substrate  Substrate
	Percentage float64
}

// MixedSubstrate represents a mixture of different substrates with their percentages
type MixedSubstrate struct {
	ID         string
	Name       string
	Color      string
	Substrates []SubstratePercentage
}

// TotalPercentage calculates the sum of all substrate percentages
func (ms *MixedSubstrate) TotalPercentage() float64 {
	var total float64
	for _, sp := range ms.Substrates {
		total += sp.Percentage
	}
	return total
}

// FindSubstrateIndex finds the index of a substrate in the mix by comparing IDs
func (ms *MixedSubstrate) FindSubstrateIndex(s Substrate) int {
	for i, sp := range ms.Substrates {
		if sp.Substrate.ID == s.ID {
			return i
		}
	}
	return -1
}

// AddSubstrate adds a new substrate to the mixed substrate.
// It returns an error if the total percentage exceeds 100 or if the substrate already exists.
func (ms *MixedSubstrate) AddSubstrate(s Substrate, percentage float64) error {
	if percentage <= 0 {
		return errors.New("percentage must be positive")
	}

	// Check if substrate already exists by comparing IDs
	for _, sp := range ms.Substrates {
		if sp.Substrate.ID == s.ID {
			return ErrSubstrateExists
		}
	}

	// Check if adding this substrate would exceed 100%
	if ms.TotalPercentage()+percentage > 100 {
		return ErrExceedsMaxPercentage
	}

	ms.Substrates = append(ms.Substrates, SubstratePercentage{
		Substrate:  s,
		Percentage: percentage,
	})
	return nil
}

// RemoveSubstrate removes a substrate from the mixed substrate.
// It returns an error if the substrate does not exist.
func (ms *MixedSubstrate) RemoveSubstrate(s Substrate) error {
	index := ms.FindSubstrateIndex(s)
	if index == -1 {
		return ErrSubstrateNotFound
	}

	// More efficient slice manipulation
	last := len(ms.Substrates) - 1
	ms.Substrates[index] = ms.Substrates[last]
	ms.Substrates = ms.Substrates[:last]

	return nil
}

// UpdatePercentage updates the percentage of an existing substrate
func (ms *MixedSubstrate) UpdatePercentage(s Substrate, newPercentage float64) error {
	if newPercentage <= 0 {
		return errors.New("percentage must be positive")
	}

	index := ms.FindSubstrateIndex(s)
	if index == -1 {
		return ErrSubstrateNotFound
	}

	// Calculate what the total would be with the new percentage
	currentPercentage := ms.Substrates[index].Percentage
	totalPercentage := ms.TotalPercentage() - currentPercentage + newPercentage

	if totalPercentage > 100 {
		return ErrExceedsMaxPercentage
	}

	ms.Substrates[index].Percentage = newPercentage
	return nil
}

// Validate checks if the total percentage of all substrates is exactly 100.
// An empty substrate list is valid.
func (ms *MixedSubstrate) Validate() error {
	// Empty substrate list is valid
	if len(ms.Substrates) == 0 {
		return nil
	}

	total := ms.TotalPercentage()

	// Using a small epsilon for floating point comparison
	const epsilon = 0.0001
	if total < 100-epsilon || total > 100+epsilon {
		return ErrInvalidPercentage
	}

	return nil
}

// GetSubstrates returns a copy of the substrates list
func (ms *MixedSubstrate) GetSubstrates() []SubstratePercentage {
	result := make([]SubstratePercentage, len(ms.Substrates))
	copy(result, ms.Substrates)
	return result
}
