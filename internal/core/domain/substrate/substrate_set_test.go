package substrate

import (
	"testing"
)

func TestNewSubstrateSet(t *testing.T) {
	ss := NewSubstrateSet("set1", "Test Set")
	
	if ss.ID != "set1" {
		t.Errorf("expected ID 'set1' but got '%s'", ss.ID)
	}
	
	if ss.Name != "Test Set" {
		t.Errorf("expected Name 'Test Set' but got '%s'", ss.Name)
	}
	
	if len(ss.Substrates) != 0 {
		t.Errorf("expected empty Substrates but got %d items", len(ss.Substrates))
	}
	
	if len(ss.MixedSubstrates) != 0 {
		t.Errorf("expected empty MixedSubstrates but got %d items", len(ss.MixedSubstrates))
	}
}

func TestSubstrateSet_AddSubstrate(t *testing.T) {
	tests := []struct {
		name        string
		ss          *SubstrateSet
		substrate   Substrate
		expectError bool
		errorType   error
	}{
		{
			name: "add substrate to empty set",
			ss: &SubstrateSet{
				ID:              "set1",
				Name:            "Empty Set",
				Substrates:      []Substrate{},
				MixedSubstrates: []MixedSubstrate{},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Substrate 1",
				Color: "red",
			},
			expectError: false,
		},
		{
			name: "add substrate to non-empty set",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Non-Empty Set",
				Substrates: []Substrate{
					{
						ID:    "sub1",
						Name:  "Substrate 1",
						Color: "red",
					},
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			substrate: Substrate{
				ID:    "sub2",
				Name:  "Substrate 2",
				Color: "blue",
			},
			expectError: false,
		},
		{
			name: "add substrate that already exists",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Non-Empty Set",
				Substrates: []Substrate{
					{
						ID:    "sub1",
						Name:  "Substrate 1",
						Color: "red",
					},
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Different Name",
				Color: "different color",
			},
			expectError: true,
			errorType:   ErrSubstrateExistsInSet,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			initialLength := len(tt.ss.Substrates)
			err := tt.ss.AddSubstrate(tt.substrate)
			
			if tt.expectError {
				if err == nil {
					t.Errorf("expected error but got nil")
					return
				}
				if tt.errorType != nil && err != tt.errorType {
					t.Errorf("expected error %v but got %v", tt.errorType, err)
				}
				if len(tt.ss.Substrates) != initialLength {
					t.Errorf("substrate list length changed despite error")
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				
				if len(tt.ss.Substrates) != initialLength+1 {
					t.Errorf("expected substrate list length to increase by 1")
				}
				
				// Check if substrate was added
				found := false
				for _, s := range tt.ss.Substrates {
					if s.ID == tt.substrate.ID {
						found = true
						break
					}
				}
				
				if !found {
					t.Errorf("substrate was not added to the set")
				}
			}
		})
	}
}

func TestSubstrateSet_RemoveSubstrate(t *testing.T) {
	tests := []struct {
		name        string
		ss          *SubstrateSet
		substrate   Substrate
		expectError bool
		errorType   error
	}{
		{
			name: "remove existing substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Non-Empty Set",
				Substrates: []Substrate{
					{
						ID:    "sub1",
						Name:  "Substrate 1",
						Color: "red",
					},
					{
						ID:    "sub2",
						Name:  "Substrate 2",
						Color: "blue",
					},
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Different Name", // Name should be ignored
				Color: "different color", // Color should be ignored
			},
			expectError: false,
		},
		{
			name: "remove non-existing substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Non-Empty Set",
				Substrates: []Substrate{
					{
						ID:    "sub1",
						Name:  "Substrate 1",
						Color: "red",
					},
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			substrate: Substrate{
				ID:    "sub2",
				Name:  "Substrate 2",
				Color: "blue",
			},
			expectError: true,
			errorType:   ErrSubstrateNotFoundInSet,
		},
		{
			name: "remove from empty set",
			ss: &SubstrateSet{
				ID:              "set1",
				Name:            "Empty Set",
				Substrates:      []Substrate{},
				MixedSubstrates: []MixedSubstrate{},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Substrate 1",
				Color: "red",
			},
			expectError: true,
			errorType:   ErrSubstrateNotFoundInSet,
		},
		{
			name: "remove substrate in use",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrate",
				Substrates: []Substrate{
					{
						ID:    "sub1",
						Name:  "Substrate 1",
						Color: "red",
					},
					{
						ID:    "sub2",
						Name:  "Substrate 2",
						Color: "blue",
					},
				},
				MixedSubstrates: []MixedSubstrate{
					{
						ID:    "mix1",
						Name:  "Mixed Substrate 1",
						Color: "brown",
						Substrates: []SubstratePercentage{
							{
								Substrate: Substrate{
									ID:    "sub1",
									Name:  "Substrate 1",
									Color: "red",
								},
								Percentage: 60,
							},
							{
								Substrate: Substrate{
									ID:    "sub2",
									Name:  "Substrate 2",
									Color: "blue",
								},
								Percentage: 40,
							},
						},
					},
				},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Substrate 1",
				Color: "red",
			},
			expectError: true,
			errorType:   ErrSubstrateInUse,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			initialLength := len(tt.ss.Substrates)
			err := tt.ss.RemoveSubstrate(tt.substrate)
			
			if tt.expectError {
				if err == nil {
					t.Errorf("expected error but got nil")
					return
				}
				if tt.errorType != nil && err != tt.errorType {
					t.Errorf("expected error %v but got %v", tt.errorType, err)
				}
				if len(tt.ss.Substrates) != initialLength {
					t.Errorf("substrate list length changed despite error")
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				
				if len(tt.ss.Substrates) != initialLength-1 {
					t.Errorf("expected substrate list length to decrease by 1")
				}
				
				// Check if substrate was removed
				for _, s := range tt.ss.Substrates {
					if s.ID == tt.substrate.ID {
						t.Errorf("substrate was not removed from the set")
						break
					}
				}
			}
		})
	}
}

func TestSubstrateSet_AddMixedSubstrate(t *testing.T) {
	// Create common substrates for tests
	sub1 := Substrate{ID: "sub1", Name: "Substrate 1", Color: "red"}
	sub2 := Substrate{ID: "sub2", Name: "Substrate 2", Color: "blue"}
	sub3 := Substrate{ID: "sub3", Name: "Substrate 3", Color: "green"}
	
	// Create valid mixed substrate
	validMix := MixedSubstrate{
		ID:    "mix1",
		Name:  "Valid Mix",
		Color: "brown",
		Substrates: []SubstratePercentage{
			{Substrate: sub1, Percentage: 60},
			{Substrate: sub2, Percentage: 40},
		},
	}
	
	// Create invalid mixed substrate (percentages don't add up to 100)
	invalidMix := MixedSubstrate{
		ID:    "mix2",
		Name:  "Invalid Mix",
		Color: "brown",
		Substrates: []SubstratePercentage{
			{Substrate: sub1, Percentage: 60},
			{Substrate: sub2, Percentage: 30},
		},
	}
	
	// Create mixed substrate with unknown substrate
	mixWithUnknownSub := MixedSubstrate{
		ID:    "mix3",
		Name:  "Mix with Unknown",
		Color: "brown",
		Substrates: []SubstratePercentage{
			{Substrate: sub1, Percentage: 50},
			{Substrate: sub3, Percentage: 50}, // sub3 is not in the set
		},
	}

	tests := []struct {
		name        string
		ss          *SubstrateSet
		mixedSub    MixedSubstrate
		expectError bool
		errorType   error
	}{
		{
			name: "add valid mixed substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Substrates",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			mixedSub:    validMix,
			expectError: false,
		},
		{
			name: "add mixed substrate that already exists",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrate",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{
					validMix,
				},
			},
			mixedSub: MixedSubstrate{
				ID:    "mix1", // Same ID as existing mixed substrate
				Name:  "Different Name",
				Color: "different color",
				Substrates: []SubstratePercentage{
					{Substrate: sub1, Percentage: 70},
					{Substrate: sub2, Percentage: 30},
				},
			},
			expectError: true,
			errorType:   ErrMixedSubstrateExistsInSet,
		},
		{
			name: "add invalid mixed substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Substrates",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			mixedSub:    invalidMix,
			expectError: true,
			errorType:   ErrMixedSubstrateInvalid,
		},
		{
			name: "add mixed substrate with unknown substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Substrates",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			mixedSub:    mixWithUnknownSub,
			expectError: true,
			errorType:   ErrMixedSubstrateContainsUnknownSubstrates,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			initialLength := len(tt.ss.MixedSubstrates)
			err := tt.ss.AddMixedSubstrate(tt.mixedSub)
			
			if tt.expectError {
				if err == nil {
					t.Errorf("expected error but got nil")
					return
				}
				if tt.errorType != nil && err != tt.errorType {
					t.Errorf("expected error %v but got %v", tt.errorType, err)
				}
				if len(tt.ss.MixedSubstrates) != initialLength {
					t.Errorf("mixed substrate list length changed despite error")
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				
				if len(tt.ss.MixedSubstrates) != initialLength+1 {
					t.Errorf("expected mixed substrate list length to increase by 1")
				}
				
				// Check if mixed substrate was added
				found := false
				for _, ms := range tt.ss.MixedSubstrates {
					if ms.ID == tt.mixedSub.ID {
						found = true
						break
					}
				}
				
				if !found {
					t.Errorf("mixed substrate was not added to the set")
				}
			}
		})
	}
}

func TestSubstrateSet_RemoveMixedSubstrate(t *testing.T) {
	// Create common substrates for tests
	sub1 := Substrate{ID: "sub1", Name: "Substrate 1", Color: "red"}
	sub2 := Substrate{ID: "sub2", Name: "Substrate 2", Color: "blue"}
	
	// Create mixed substrates for tests
	mix1 := MixedSubstrate{
		ID:    "mix1",
		Name:  "Mix 1",
		Color: "brown",
		Substrates: []SubstratePercentage{
			{Substrate: sub1, Percentage: 60},
			{Substrate: sub2, Percentage: 40},
		},
	}
	
	mix2 := MixedSubstrate{
		ID:    "mix2",
		Name:  "Mix 2",
		Color: "dark brown",
		Substrates: []SubstratePercentage{
			{Substrate: sub1, Percentage: 30},
			{Substrate: sub2, Percentage: 70},
		},
	}

	tests := []struct {
		name        string
		ss          *SubstrateSet
		mixedSub    MixedSubstrate
		expectError bool
		errorType   error
	}{
		{
			name: "remove existing mixed substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrates",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{
					mix1,
					mix2,
				},
			},
			mixedSub: MixedSubstrate{
				ID:    "mix1",
				Name:  "Different Name", // Name should be ignored
				Color: "different color", // Color should be ignored
			},
			expectError: false,
		},
		{
			name: "remove non-existing mixed substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrate",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{
					mix1,
				},
			},
			mixedSub: MixedSubstrate{
				ID:    "mix3", // Non-existing ID
				Name:  "Non-existing Mix",
				Color: "purple",
			},
			expectError: true,
			errorType:   ErrMixedSubstrateNotFoundInSet,
		},
		{
			name: "remove from empty mixed substrates",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set without Mixed Substrates",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			mixedSub: MixedSubstrate{
				ID:    "mix1",
				Name:  "Mix 1",
				Color: "brown",
			},
			expectError: true,
			errorType:   ErrMixedSubstrateNotFoundInSet,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			initialLength := len(tt.ss.MixedSubstrates)
			err := tt.ss.RemoveMixedSubstrate(tt.mixedSub)
			
			if tt.expectError {
				if err == nil {
					t.Errorf("expected error but got nil")
					return
				}
				if tt.errorType != nil && err != tt.errorType {
					t.Errorf("expected error %v but got %v", tt.errorType, err)
				}
				if len(tt.ss.MixedSubstrates) != initialLength {
					t.Errorf("mixed substrate list length changed despite error")
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				
				if len(tt.ss.MixedSubstrates) != initialLength-1 {
					t.Errorf("expected mixed substrate list length to decrease by 1")
				}
				
				// Check if mixed substrate was removed
				for _, ms := range tt.ss.MixedSubstrates {
					if ms.ID == tt.mixedSub.ID {
						t.Errorf("mixed substrate was not removed from the set")
						break
					}
				}
			}
		})
	}
}

func TestSubstrateSet_UpdateSubstrate(t *testing.T) {
	// Create common substrates for tests
	sub1 := Substrate{ID: "sub1", Name: "Substrate 1", Color: "red"}
	sub2 := Substrate{ID: "sub2", Name: "Substrate 2", Color: "blue"}
	
	// Create mixed substrate that uses sub1
	mix1 := MixedSubstrate{
		ID:    "mix1",
		Name:  "Mix 1",
		Color: "brown",
		Substrates: []SubstratePercentage{
			{Substrate: sub1, Percentage: 60},
			{Substrate: sub2, Percentage: 40},
		},
	}

	tests := []struct {
		name        string
		ss          *SubstrateSet
		updateSubstrate Substrate
		expectError bool
		errorType   error
	}{
		{
			name: "update existing substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Substrates",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			updateSubstrate: Substrate{
				ID:    "sub1", // Same ID
				Name:  "Updated Substrate 1",
				Color: "dark red",
			},
			expectError: false,
		},
		{
			name: "update non-existing substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Substrates",
				Substrates: []Substrate{
					sub1,
				},
				MixedSubstrates: []MixedSubstrate{},
			},
			updateSubstrate: Substrate{
				ID:    "sub3", // Non-existing ID
				Name:  "Substrate 3",
				Color: "green",
			},
			expectError: true,
			errorType:   ErrSubstrateNotFoundInSet,
		},
		{
			name: "update substrate used in mixed substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrate",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{
					mix1,
				},
			},
			updateSubstrate: Substrate{
				ID:    "sub1",
				Name:  "Updated Substrate 1",
				Color: "dark red",
			},
			expectError: false, // Should be able to update properties
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.ss.UpdateSubstrate(tt.updateSubstrate)
			
			if tt.expectError {
				if err == nil {
					t.Errorf("expected error but got nil")
					return
				}
				if tt.errorType != nil && err != tt.errorType {
					t.Errorf("expected error %v but got %v", tt.errorType, err)
				}
				
				// Verify substrate was not updated
				for _, s := range tt.ss.Substrates {
					if s.ID == tt.updateSubstrate.ID {
						if s.Name == tt.updateSubstrate.Name || s.Color == tt.updateSubstrate.Color {
							t.Errorf("substrate was updated despite error")
						}
						break
					}
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				
				// Verify substrate was updated
				found := false
				for _, s := range tt.ss.Substrates {
					if s.ID == tt.updateSubstrate.ID {
						found = true
						if s.Name != tt.updateSubstrate.Name {
							t.Errorf("substrate name was not updated, expected '%s' but got '%s'", 
								tt.updateSubstrate.Name, s.Name)
						}
						if s.Color != tt.updateSubstrate.Color {
							t.Errorf("substrate color was not updated, expected '%s' but got '%s'", 
								tt.updateSubstrate.Color, s.Color)
						}
						break
					}
				}
				
				if !found {
					t.Errorf("updated substrate not found in set")
				}
				
				// If this substrate is used in mixed substrates, verify those were updated too
				if tt.ss.MixedSubstrates != nil && len(tt.ss.MixedSubstrates) > 0 {
					for _, ms := range tt.ss.MixedSubstrates {
						for _, sp := range ms.Substrates {
							if sp.Substrate.ID == tt.updateSubstrate.ID {
								if sp.Substrate.Name != tt.updateSubstrate.Name {
									t.Errorf("substrate name in mixed substrate was not updated")
								}
								if sp.Substrate.Color != tt.updateSubstrate.Color {
									t.Errorf("substrate color in mixed substrate was not updated")
								}
							}
						}
					}
				}
			}
		})
	}
}

func TestSubstrateSet_UpdateMixedSubstrate(t *testing.T) {
	// Create common substrates for tests
	sub1 := Substrate{ID: "sub1", Name: "Substrate 1", Color: "red"}
	sub2 := Substrate{ID: "sub2", Name: "Substrate 2", Color: "blue"}
	sub3 := Substrate{ID: "sub3", Name: "Substrate 3", Color: "green"}
	
	// Create mixed substrates for tests
	mix1 := MixedSubstrate{
		ID:    "mix1",
		Name:  "Mix 1",
		Color: "brown",
		Substrates: []SubstratePercentage{
			{Substrate: sub1, Percentage: 60},
			{Substrate: sub2, Percentage: 40},
		},
	}
	
	mix2 := MixedSubstrate{
		ID:    "mix2",
		Name:  "Mix 2",
		Color: "dark brown",
		Substrates: []SubstratePercentage{
			{Substrate: sub1, Percentage: 30},
			{Substrate: sub2, Percentage: 70},
		},
	}

	tests := []struct {
		name        string
		ss          *SubstrateSet
		updateMixedSub MixedSubstrate
		expectError bool
		errorType   error
	}{
		{
			name: "update existing mixed substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrates",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{
					mix1,
					mix2,
				},
			},
			updateMixedSub: MixedSubstrate{
				ID:    "mix1",
				Name:  "Updated Mix 1",
				Color: "dark brown",
				Substrates: []SubstratePercentage{
					{Substrate: sub1, Percentage: 50},
					{Substrate: sub2, Percentage: 50},
				},
			},
			expectError: false,
		},
		{
			name: "update non-existing mixed substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrate",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{
					mix1,
				},
			},
			updateMixedSub: MixedSubstrate{
				ID:    "mix3", // Non-existing ID
				Name:  "Non-existing Mix",
				Color: "purple",
				Substrates: []SubstratePercentage{
					{Substrate: sub1, Percentage: 50},
					{Substrate: sub2, Percentage: 50},
				},
			},
			expectError: true,
			errorType:   ErrMixedSubstrateNotFoundInSet,
		},
		{
			name: "update with invalid mixed substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrate",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{
					mix1,
				},
			},
			updateMixedSub: MixedSubstrate{
				ID:    "mix1",
				Name:  "Invalid Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{Substrate: sub1, Percentage: 60},
					{Substrate: sub2, Percentage: 30},
				}, // Only adds up to 90%
			},
			expectError: true,
			errorType:   ErrMixedSubstrateInvalid,
		},
		{
			name: "update with unknown substrate",
			ss: &SubstrateSet{
				ID:   "set1",
				Name: "Set with Mixed Substrate",
				Substrates: []Substrate{
					sub1,
					sub2,
				},
				MixedSubstrates: []MixedSubstrate{
					mix1,
				},
			},
			updateMixedSub: MixedSubstrate{
				ID:    "mix1",
				Name:  "Mix with Unknown",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{Substrate: sub1, Percentage: 50},
					{Substrate: sub3, Percentage: 50}, // sub3 is not in the set
				},
			},
			expectError: true,
			errorType:   ErrMixedSubstrateContainsUnknownSubstrates,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.ss.UpdateMixedSubstrate(tt.updateMixedSub)
			
			if tt.expectError {
				if err == nil {
					t.Errorf("expected error but got nil")
					return
				}
				if tt.errorType != nil && err != tt.errorType {
					t.Errorf("expected error %v but got %v", tt.errorType, err)
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				
				// Verify mixed substrate was updated
				found := false
				for _, ms := range tt.ss.MixedSubstrates {
					if ms.ID == tt.updateMixedSub.ID {
						found = true
						if ms.Name != tt.updateMixedSub.Name {
							t.Errorf("mixed substrate name was not updated, expected '%s' but got '%s'", 
								tt.updateMixedSub.Name, ms.Name)
						}
						if ms.Color != tt.updateMixedSub.Color {
							t.Errorf("mixed substrate color was not updated, expected '%s' but got '%s'", 
								tt.updateMixedSub.Color, ms.Color)
						}
						
						// Check substrates and percentages
						if len(ms.Substrates) != len(tt.updateMixedSub.Substrates) {
							t.Errorf("mixed substrate substrates count mismatch, expected %d but got %d",
								len(tt.updateMixedSub.Substrates), len(ms.Substrates))
						} else {
							// Create a map of substrate ID to percentage for easy comparison
							expectedPercentages := make(map[string]float64)
							for _, sp := range tt.updateMixedSub.Substrates {
								expectedPercentages[sp.Substrate.ID] = sp.Percentage
							}
							
							for _, sp := range ms.Substrates {
								expectedPercentage, ok := expectedPercentages[sp.Substrate.ID]
								if !ok {
									t.Errorf("unexpected substrate %s in updated mixed substrate", sp.Substrate.ID)
								} else if sp.Percentage != expectedPercentage {
									t.Errorf("substrate percentage mismatch for %s, expected %.2f but got %.2f",
										sp.Substrate.ID, expectedPercentage, sp.Percentage)
								}
							}
						}
						break
					}
				}
				
				if !found {
					t.Errorf("updated mixed substrate not found in set")
				}
			}
		})
	}
}
