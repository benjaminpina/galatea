package substrate

import (
	"errors"
)

var (
	// ErrSubstrateExistsInSet is returned when attempting to add a substrate that already exists in the set
	ErrSubstrateExistsInSet = errors.New("substrate already exists in the set")
	// ErrMixedSubstrateExistsInSet is returned when attempting to add a mixed substrate that already exists in the set
	ErrMixedSubstrateExistsInSet = errors.New("mixed substrate already exists in the set")
	// ErrSubstrateNotFoundInSet is returned when a substrate is not found in the set
	ErrSubstrateNotFoundInSet = errors.New("substrate not found in the set")
	// ErrMixedSubstrateNotFoundInSet is returned when a mixed substrate is not found in the set
	ErrMixedSubstrateNotFoundInSet = errors.New("mixed substrate not found in the set")
	// ErrSubstrateInUse is returned when attempting to remove a substrate that is used in a mixed substrate
	ErrSubstrateInUse = errors.New("substrate is used in a mixed substrate and cannot be removed")
	// ErrMixedSubstrateInvalid is returned when a mixed substrate is invalid
	ErrMixedSubstrateInvalid = errors.New("mixed substrate is invalid")
	// ErrMixedSubstrateContainsUnknownSubstrates is returned when a mixed substrate contains substrates not in the set
	ErrMixedSubstrateContainsUnknownSubstrates = errors.New("mixed substrate contains substrates not in the set")
)

type SubstrateSet struct {
	ID              string
	Name            string
	Substrates      []Substrate
	MixedSubstrates []MixedSubstrate
}

// NewSubstrateSet creates a new empty substrate set
func NewSubstrateSet(id, name string) *SubstrateSet {
	return &SubstrateSet{
		ID:              id,
		Name:            name,
		Substrates:      []Substrate{},
		MixedSubstrates: []MixedSubstrate{},
	}
}

// FindSubstrateIndex finds the index of a substrate in the set by comparing IDs
func (ss *SubstrateSet) FindSubstrateIndex(s Substrate) int {
	for i, substrate := range ss.Substrates {
		if substrate.ID == s.ID {
			return i
		}
	}
	return -1
}

// FindMixedSubstrateIndex finds the index of a mixed substrate in the set by comparing IDs
func (ss *SubstrateSet) FindMixedSubstrateIndex(ms MixedSubstrate) int {
	for i, mixedSubstrate := range ss.MixedSubstrates {
		if mixedSubstrate.ID == ms.ID {
			return i
		}
	}
	return -1
}

// ContainsSubstrate checks if a substrate exists in the set by ID
func (ss *SubstrateSet) ContainsSubstrate(s Substrate) bool {
	return ss.FindSubstrateIndex(s) != -1
}

// ContainsMixedSubstrate checks if a mixed substrate exists in the set by ID
func (ss *SubstrateSet) ContainsMixedSubstrate(ms MixedSubstrate) bool {
	return ss.FindMixedSubstrateIndex(ms) != -1
}

// IsSubstrateInUse checks if a substrate is used in any mixed substrate
func (ss *SubstrateSet) IsSubstrateInUse(s Substrate) bool {
	for _, ms := range ss.MixedSubstrates {
		for _, sp := range ms.Substrates {
			if sp.Substrate.ID == s.ID {
				return true
			}
		}
	}
	return false
}

// AddSubstrate adds a new substrate to the set
// It returns an error if the substrate already exists in the set
func (ss *SubstrateSet) AddSubstrate(s Substrate) error {
	if ss.ContainsSubstrate(s) {
		return ErrSubstrateExistsInSet
	}
	ss.Substrates = append(ss.Substrates, s)
	return nil
}

// RemoveSubstrate removes a substrate from the set
// It returns an error if the substrate does not exist in the set or if it is used in a mixed substrate
func (ss *SubstrateSet) RemoveSubstrate(s Substrate) error {
	index := ss.FindSubstrateIndex(s)
	if index == -1 {
		return ErrSubstrateNotFoundInSet
	}

	// Check if the substrate is used in any mixed substrate
	if ss.IsSubstrateInUse(s) {
		return ErrSubstrateInUse
	}

	// Remove the substrate
	last := len(ss.Substrates) - 1
	ss.Substrates[index] = ss.Substrates[last]
	ss.Substrates = ss.Substrates[:last]

	return nil
}

// ValidateMixedSubstrate checks if a mixed substrate is valid and all its substrates exist in the set
func (ss *SubstrateSet) ValidateMixedSubstrate(ms MixedSubstrate) error {
	// Validate the mixed substrate itself
	if err := ms.Validate(); err != nil {
		return ErrMixedSubstrateInvalid
	}

	// Check if all substrates in the mixed substrate exist in the set
	for _, sp := range ms.Substrates {
		if !ss.ContainsSubstrate(sp.Substrate) {
			return ErrMixedSubstrateContainsUnknownSubstrates
		}
	}

	return nil
}

// AddMixedSubstrate adds a new mixed substrate to the set
// It returns an error if the mixed substrate already exists, is invalid, or contains substrates not in the set
func (ss *SubstrateSet) AddMixedSubstrate(ms MixedSubstrate) error {
	if ss.ContainsMixedSubstrate(ms) {
		return ErrMixedSubstrateExistsInSet
	}

	// Validate the mixed substrate
	if err := ss.ValidateMixedSubstrate(ms); err != nil {
		return err
	}

	ss.MixedSubstrates = append(ss.MixedSubstrates, ms)
	return nil
}

// RemoveMixedSubstrate removes a mixed substrate from the set
// It returns an error if the mixed substrate does not exist in the set
func (ss *SubstrateSet) RemoveMixedSubstrate(ms MixedSubstrate) error {
	index := ss.FindMixedSubstrateIndex(ms)
	if index == -1 {
		return ErrMixedSubstrateNotFoundInSet
	}

	// Remove the mixed substrate
	last := len(ss.MixedSubstrates) - 1
	ss.MixedSubstrates[index] = ss.MixedSubstrates[last]
	ss.MixedSubstrates = ss.MixedSubstrates[:last]

	return nil
}

// GetSubstrates returns a copy of the substrates list
func (ss *SubstrateSet) GetSubstrates() []Substrate {
	result := make([]Substrate, len(ss.Substrates))
	copy(result, ss.Substrates)
	return result
}

// GetMixedSubstrates returns a copy of the mixed substrates list
func (ss *SubstrateSet) GetMixedSubstrates() []MixedSubstrate {
	result := make([]MixedSubstrate, len(ss.MixedSubstrates))
	copy(result, ss.MixedSubstrates)
	return result
}

// UpdateSubstrate updates a substrate in the set
// It returns an error if the substrate does not exist in the set
func (ss *SubstrateSet) UpdateSubstrate(s Substrate) error {
	index := ss.FindSubstrateIndex(s)
	if index == -1 {
		return ErrSubstrateNotFoundInSet
	}

	// Update the substrate
	ss.Substrates[index] = s
	
	// Also update the substrate in all mixed substrates that use it
	for i, ms := range ss.MixedSubstrates {
		for j, sp := range ms.Substrates {
			if sp.Substrate.ID == s.ID {
				// Update the substrate but keep the percentage
				ss.MixedSubstrates[i].Substrates[j].Substrate = s
			}
		}
	}
	
	return nil
}

// UpdateMixedSubstrate updates a mixed substrate in the set
// It returns an error if the mixed substrate does not exist in the set, is invalid, or contains substrates not in the set
func (ss *SubstrateSet) UpdateMixedSubstrate(ms MixedSubstrate) error {
	index := ss.FindMixedSubstrateIndex(ms)
	if index == -1 {
		return ErrMixedSubstrateNotFoundInSet
	}

	// Validate the mixed substrate
	if err := ss.ValidateMixedSubstrate(ms); err != nil {
		return err
	}

	// Update the mixed substrate
	ss.MixedSubstrates[index] = ms
	return nil
}
