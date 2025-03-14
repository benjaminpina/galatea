package substrate

import (
	"testing"
)

func TestMixedSubstrate_AddSubstrate(t *testing.T) {
	tests := []struct {
		name        string
		ms          *MixedSubstrate
		substrate   Substrate
		percentage  float64
		expectError bool
		errorType   error
	}{
		{
			name: "add substrate to empty mix",
			ms: &MixedSubstrate{
				ID:         "mix1",
				Name:       "Empty Mix",
				Color:      "brown",
				Substrates: []SubstratePercentage{},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Substrate 1",
				Color: "red",
			},
			percentage:  50,
			expectError: false,
		},
		{
			name: "add substrate to non-empty mix",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Half-filled Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 50,
					},
				},
			},
			substrate: Substrate{
				ID:    "sub2",
				Name:  "Substrate 2",
				Color: "blue",
			},
			percentage:  50,
			expectError: false,
		},
		{
			name: "add substrate that already exists",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Half-filled Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 50,
					},
				},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Different Name",
				Color: "different color",
			},
			percentage:  30,
			expectError: true,
			errorType:   ErrSubstrateExists,
		},
		{
			name: "add substrate with percentage that exceeds 100",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Almost Full Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 80,
					},
				},
			},
			substrate: Substrate{
				ID:    "sub2",
				Name:  "Substrate 2",
				Color: "blue",
			},
			percentage:  30,
			expectError: true,
			errorType:   ErrExceedsMaxPercentage,
		},
		{
			name: "add substrate with negative percentage",
			ms: &MixedSubstrate{
				ID:         "mix1",
				Name:       "Empty Mix",
				Color:      "brown",
				Substrates: []SubstratePercentage{},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Substrate 1",
				Color: "red",
			},
			percentage:  -10,
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.ms.AddSubstrate(tt.substrate, tt.percentage)
			
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
				
				// Check if substrate was added
				found := false
				for _, sp := range tt.ms.Substrates {
					if sp.Substrate.ID == tt.substrate.ID {
						found = true
						if sp.Percentage != tt.percentage {
							t.Errorf("expected percentage %v but got %v", tt.percentage, sp.Percentage)
						}
						break
					}
				}
				
				if !found {
					t.Errorf("substrate was not added to the mix")
				}
			}
		})
	}
}

func TestMixedSubstrate_RemoveSubstrate(t *testing.T) {
	tests := []struct {
		name        string
		ms          *MixedSubstrate
		substrate   Substrate
		expectError bool
		errorType   error
	}{
		{
			name: "remove existing substrate",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Full Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 50,
					},
					{
						Substrate: Substrate{
							ID:    "sub2",
							Name:  "Substrate 2",
							Color: "blue",
						},
						Percentage: 50,
					},
				},
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
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Full Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 100,
					},
				},
			},
			substrate: Substrate{
				ID:    "sub2",
				Name:  "Substrate 2",
				Color: "blue",
			},
			expectError: true,
			errorType:   ErrSubstrateNotFound,
		},
		{
			name: "remove from empty mix",
			ms: &MixedSubstrate{
				ID:         "mix1",
				Name:       "Empty Mix",
				Color:      "brown",
				Substrates: []SubstratePercentage{},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Substrate 1",
				Color: "red",
			},
			expectError: true,
			errorType:   ErrSubstrateNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			initialLength := len(tt.ms.Substrates)
			err := tt.ms.RemoveSubstrate(tt.substrate)
			
			if tt.expectError {
				if err == nil {
					t.Errorf("expected error but got nil")
					return
				}
				if tt.errorType != nil && err != tt.errorType {
					t.Errorf("expected error %v but got %v", tt.errorType, err)
				}
				if len(tt.ms.Substrates) != initialLength {
					t.Errorf("substrate list length changed despite error")
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				
				if len(tt.ms.Substrates) != initialLength-1 {
					t.Errorf("expected substrate list length to decrease by 1")
				}
				
				// Check if substrate was removed
				for _, sp := range tt.ms.Substrates {
					if sp.Substrate.ID == tt.substrate.ID {
						t.Errorf("substrate was not removed from the mix")
						break
					}
				}
			}
		})
	}
}

func TestMixedSubstrate_UpdatePercentage(t *testing.T) {
	tests := []struct {
		name          string
		ms            *MixedSubstrate
		substrate     Substrate
		newPercentage float64
		expectError   bool
		errorType     error
	}{
		{
			name: "update percentage of existing substrate",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Partial Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 50,
					},
					{
						Substrate: Substrate{
							ID:    "sub2",
							Name:  "Substrate 2",
							Color: "blue",
						},
						Percentage: 30,
					},
				},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Different Name", // Name should be ignored
				Color: "different color", // Color should be ignored
			},
			newPercentage: 60,
			expectError:   false,
		},
		{
			name: "update percentage of non-existing substrate",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Full Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 100,
					},
				},
			},
			substrate: Substrate{
				ID:    "sub2",
				Name:  "Substrate 2",
				Color: "blue",
			},
			newPercentage: 50,
			expectError:   true,
			errorType:     ErrSubstrateNotFound,
		},
		{
			name: "update percentage exceeding 100",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Full Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 50,
					},
					{
						Substrate: Substrate{
							ID:    "sub2",
							Name:  "Substrate 2",
							Color: "blue",
						},
						Percentage: 50,
					},
				},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Substrate 1",
				Color: "red",
			},
			newPercentage: 80,
			expectError:   true,
			errorType:     ErrExceedsMaxPercentage,
		},
		{
			name: "update with negative percentage",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Full Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 100,
					},
				},
			},
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Substrate 1",
				Color: "red",
			},
			newPercentage: -10,
			expectError:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.ms.UpdatePercentage(tt.substrate, tt.newPercentage)
			
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
				
				// Check if percentage was updated
				found := false
				for _, sp := range tt.ms.Substrates {
					if sp.Substrate.ID == tt.substrate.ID {
						found = true
						if sp.Percentage != tt.newPercentage {
							t.Errorf("expected percentage %v but got %v", tt.newPercentage, sp.Percentage)
						}
						break
					}
				}
				
				if !found {
					t.Errorf("substrate not found in the mix")
				}
			}
		})
	}
}

func TestMixedSubstrate_Validate(t *testing.T) {
	tests := []struct {
		name        string
		ms          *MixedSubstrate
		expectError bool
		errorType   error
	}{
		{
			name: "empty mix is valid",
			ms: &MixedSubstrate{
				ID:         "mix1",
				Name:       "Empty Mix",
				Color:      "brown",
				Substrates: []SubstratePercentage{},
			},
			expectError: false,
		},
		{
			name: "mix with total 100% is valid",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Full Mix",
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
			expectError: false,
		},
		{
			name: "mix with total less than 100% is invalid",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Partial Mix",
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
						Percentage: 30,
					},
				},
			},
			expectError: true,
			errorType:   ErrInvalidPercentage,
		},
		{
			name: "mix with total more than 100% is invalid",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Overfilled Mix",
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
						Percentage: 50,
					},
				},
			},
			expectError: true,
			errorType:   ErrInvalidPercentage,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.ms.Validate()
			
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
			}
		})
	}
}

func TestMixedSubstrate_GetSubstrates(t *testing.T) {
	ms := &MixedSubstrate{
		ID:    "mix1",
		Name:  "Test Mix",
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
	}
	
	// Get a copy of the substrates
	substrates := ms.GetSubstrates()
	
	// Check if the copy has the same length
	if len(substrates) != len(ms.Substrates) {
		t.Errorf("expected %d substrates but got %d", len(ms.Substrates), len(substrates))
	}
	
	// Modify the copy and check if the original is unchanged
	if len(substrates) > 0 {
		substrates[0].Percentage = 99
		
		if ms.Substrates[0].Percentage == 99 {
			t.Errorf("modifying the copy should not affect the original")
		}
	}
}

func TestMixedSubstrate_TotalPercentage(t *testing.T) {
	tests := []struct {
		name     string
		ms       *MixedSubstrate
		expected float64
	}{
		{
			name: "empty mix has 0% total",
			ms: &MixedSubstrate{
				ID:         "mix1",
				Name:       "Empty Mix",
				Color:      "brown",
				Substrates: []SubstratePercentage{},
			},
			expected: 0,
		},
		{
			name: "mix with one substrate",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Single Substrate Mix",
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
				},
			},
			expected: 60,
		},
		{
			name: "mix with multiple substrates",
			ms: &MixedSubstrate{
				ID:    "mix1",
				Name:  "Multi Substrate Mix",
				Color: "brown",
				Substrates: []SubstratePercentage{
					{
						Substrate: Substrate{
							ID:    "sub1",
							Name:  "Substrate 1",
							Color: "red",
						},
						Percentage: 30,
					},
					{
						Substrate: Substrate{
							ID:    "sub2",
							Name:  "Substrate 2",
							Color: "blue",
						},
						Percentage: 20,
					},
					{
						Substrate: Substrate{
							ID:    "sub3",
							Name:  "Substrate 3",
							Color: "green",
						},
						Percentage: 50,
					},
				},
			},
			expected: 100,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			total := tt.ms.TotalPercentage()
			
			if total != tt.expected {
				t.Errorf("expected total percentage %v but got %v", tt.expected, total)
			}
		})
	}
}

func TestMixedSubstrate_FindSubstrateIndex(t *testing.T) {
	ms := &MixedSubstrate{
		ID:    "mix1",
		Name:  "Test Mix",
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
	}
	
	tests := []struct {
		name     string
		substrate Substrate
		expected int
	}{
		{
			name: "find existing substrate",
			substrate: Substrate{
				ID:    "sub1",
				Name:  "Different Name", // Name should be ignored
				Color: "different color", // Color should be ignored
			},
			expected: 0,
		},
		{
			name: "find second substrate",
			substrate: Substrate{
				ID:    "sub2",
				Name:  "Different Name", // Name should be ignored
				Color: "different color", // Color should be ignored
			},
			expected: 1,
		},
		{
			name: "substrate not found",
			substrate: Substrate{
				ID:    "sub3",
				Name:  "Substrate 3",
				Color: "green",
			},
			expected: -1,
		},
	}
	
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			index := ms.FindSubstrateIndex(tt.substrate)
			
			if index != tt.expected {
				t.Errorf("expected index %v but got %v", tt.expected, index)
			}
		})
	}
}
