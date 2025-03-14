package stage

import (
	"testing"

	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	"github.com/stretchr/testify/assert"
)

func createTestSubstrateSet() *substrate.SubstrateSet {
	set := substrate.NewSubstrateSet("test-set", "Test Set")
	
	// Add some substrates
	set.AddSubstrate(substrate.Substrate{ID: "sub1", Name: "Substrate 1", Color: "#FF0000"})
	set.AddSubstrate(substrate.Substrate{ID: "sub2", Name: "Substrate 2", Color: "#00FF00"})
	set.AddSubstrate(substrate.Substrate{ID: "sub3", Name: "Substrate 3", Color: "#0000FF"})
	
	// Create and add a mixed substrate
	mixed := substrate.MixedSubstrate{
		ID:    "mix1",
		Name:  "Mixed 1",
		Color: "#FFFF00",
	}
	
	// Get the substrates to add to the mixed substrate
	subs := set.GetSubstrates()
	mixed.AddSubstrate(subs[0], 50)
	mixed.AddSubstrate(subs[1], 50)
	
	set.AddMixedSubstrate(mixed)
	
	return set
}

func TestNewStage(t *testing.T) {
	tests := []struct {
		name          string
		id            string
		stageName     string
		width         int
		height        int
		substrateSet  *substrate.SubstrateSet
		expectedError error
	}{
		{
			name:          "Valid stage",
			id:            "stage1",
			stageName:     "Test Stage",
			width:         10,
			height:        10,
			substrateSet:  createTestSubstrateSet(),
			expectedError: nil,
		},
		{
			name:          "Invalid width",
			id:            "stage2",
			stageName:     "Test Stage",
			width:         0,
			height:        10,
			substrateSet:  createTestSubstrateSet(),
			expectedError: ErrInvalidDimensions,
		},
		{
			name:          "Invalid height",
			id:            "stage3",
			stageName:     "Test Stage",
			width:         10,
			height:        0,
			substrateSet:  createTestSubstrateSet(),
			expectedError: ErrInvalidDimensions,
		},
		{
			name:          "Negative dimensions",
			id:            "stage4",
			stageName:     "Test Stage",
			width:         -5,
			height:        -5,
			substrateSet:  createTestSubstrateSet(),
			expectedError: ErrInvalidDimensions,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			stage, err := NewStage(tt.id, tt.stageName, tt.width, tt.height, tt.substrateSet)
			
			if tt.expectedError != nil {
				assert.Equal(t, tt.expectedError, err)
				assert.Nil(t, stage)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, stage)
				assert.Equal(t, tt.id, stage.ID)
				assert.Equal(t, tt.stageName, stage.Name)
				assert.Equal(t, tt.width, stage.Width)
				assert.Equal(t, tt.height, stage.Height)
				assert.Equal(t, tt.substrateSet, stage.SubstrateSet)
				assert.Len(t, stage.Grid, tt.height)
				
				// Check that all cells are initialized to nil
				for i := 0; i < tt.height; i++ {
					assert.Len(t, stage.Grid[i], tt.width)
					for j := 0; j < tt.width; j++ {
						assert.Nil(t, stage.Grid[i][j])
					}
				}
			}
		})
	}
}

func TestStageResize(t *testing.T) {
	// Create a stage with some content
	set := createTestSubstrateSet()
	stage, _ := NewStage("stage1", "Test Stage", 3, 3, set)
	
	// Place some substrates
	stage.PlaceSubstrate(0, 0, "sub1")
	stage.PlaceSubstrate(1, 1, "sub2")
	stage.PlaceMixedSubstrate(2, 2, "mix1")
	
	tests := []struct {
		name          string
		newWidth      int
		newHeight     int
		expectedError error
		checkContent  bool
	}{
		{
			name:          "Increase size",
			newWidth:      5,
			newHeight:     5,
			expectedError: nil,
			checkContent:  true,
		},
		{
			name:          "Decrease size but keep content",
			newWidth:      2,
			newHeight:     2,
			expectedError: nil,
			checkContent:  true,
		},
		{
			name:          "Invalid width",
			newWidth:      0,
			newHeight:     5,
			expectedError: ErrInvalidDimensions,
			checkContent:  false,
		},
		{
			name:          "Invalid height",
			newWidth:      5,
			newHeight:     0,
			expectedError: ErrInvalidDimensions,
			checkContent:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create a copy of the original grid to compare after resize
			originalWidth := stage.Width
			originalHeight := stage.Height
			originalGrid := make([][]*Cell, originalHeight)
			for i := range originalGrid {
				originalGrid[i] = make([]*Cell, originalWidth)
				copy(originalGrid[i], stage.Grid[i])
			}
			
			err := stage.Resize(tt.newWidth, tt.newHeight)
			
			if tt.expectedError != nil {
				assert.Equal(t, tt.expectedError, err)
				// Dimensions should remain unchanged
				assert.Equal(t, originalWidth, stage.Width)
				assert.Equal(t, originalHeight, stage.Height)
			} else {
				assert.NoError(t, err)
				assert.Equal(t, tt.newWidth, stage.Width)
				assert.Equal(t, tt.newHeight, stage.Height)
				assert.Len(t, stage.Grid, tt.newHeight)
				
				for i := 0; i < tt.newHeight; i++ {
					assert.Len(t, stage.Grid[i], tt.newWidth)
				}
				
				if tt.checkContent {
					// Check that content is preserved where applicable
					for i := 0; i < min(originalHeight, tt.newHeight); i++ {
						for j := 0; j < min(originalWidth, tt.newWidth); j++ {
							assert.Equal(t, originalGrid[i][j], stage.Grid[i][j])
						}
					}
				}
			}
		})
	}
}

func TestIsValidPosition(t *testing.T) {
	stage, _ := NewStage("stage1", "Test Stage", 5, 5, createTestSubstrateSet())
	
	tests := []struct {
		name     string
		x        int
		y        int
		expected bool
	}{
		{
			name:     "Valid position - corner",
			x:        0,
			y:        0,
			expected: true,
		},
		{
			name:     "Valid position - edge",
			x:        4,
			y:        4,
			expected: true,
		},
		{
			name:     "Valid position - middle",
			x:        2,
			y:        2,
			expected: true,
		},
		{
			name:     "Invalid position - negative x",
			x:        -1,
			y:        2,
			expected: false,
		},
		{
			name:     "Invalid position - negative y",
			x:        2,
			y:        -1,
			expected: false,
		},
		{
			name:     "Invalid position - x too large",
			x:        5,
			y:        2,
			expected: false,
		},
		{
			name:     "Invalid position - y too large",
			x:        2,
			y:        5,
			expected: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := stage.IsValidPosition(tt.x, tt.y)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestPlaceSubstrate(t *testing.T) {
	set := createTestSubstrateSet()
	stage, _ := NewStage("stage1", "Test Stage", 5, 5, set)
	
	tests := []struct {
		name          string
		x             int
		y             int
		substrateID   string
		expectedError error
	}{
		{
			name:          "Valid placement",
			x:             2,
			y:             2,
			substrateID:   "sub1",
			expectedError: nil,
		},
		{
			name:          "Invalid position",
			x:             -1,
			y:             2,
			substrateID:   "sub1",
			expectedError: ErrInvalidPosition,
		},
		{
			name:          "Substrate not in set",
			x:             3,
			y:             3,
			substrateID:   "unknown",
			expectedError: ErrSubstrateNotInSet,
		},
		{
			name:          "Cell already has content",
			x:             2,
			y:             2,
			substrateID:   "sub2",
			expectedError: ErrCellAlreadyHasContent,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := stage.PlaceSubstrate(tt.x, tt.y, tt.substrateID)
			assert.Equal(t, tt.expectedError, err)
			
			if err == nil {
				// Verify the substrate was placed correctly
				cell, _ := stage.GetCell(tt.x, tt.y)
				assert.NotNil(t, cell)
				assert.NotNil(t, cell.Substrate)
				assert.Nil(t, cell.MixedSubstrate)
				assert.Equal(t, tt.substrateID, cell.Substrate.ID)
			}
		})
	}
}

func TestPlaceMixedSubstrate(t *testing.T) {
	set := createTestSubstrateSet()
	stage, _ := NewStage("stage1", "Test Stage", 5, 5, set)
	
	tests := []struct {
		name          string
		x             int
		y             int
		mixedSubID    string
		expectedError error
	}{
		{
			name:          "Valid placement",
			x:             2,
			y:             2,
			mixedSubID:    "mix1",
			expectedError: nil,
		},
		{
			name:          "Invalid position",
			x:             -1,
			y:             2,
			mixedSubID:    "mix1",
			expectedError: ErrInvalidPosition,
		},
		{
			name:          "Mixed substrate not in set",
			x:             3,
			y:             3,
			mixedSubID:    "unknown",
			expectedError: ErrMixedSubstrateNotInSet,
		},
		{
			name:          "Cell already has content",
			x:             2,
			y:             2,
			mixedSubID:    "mix1",
			expectedError: ErrCellAlreadyHasContent,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := stage.PlaceMixedSubstrate(tt.x, tt.y, tt.mixedSubID)
			assert.Equal(t, tt.expectedError, err)
			
			if err == nil {
				// Verify the mixed substrate was placed correctly
				cell, _ := stage.GetCell(tt.x, tt.y)
				assert.NotNil(t, cell)
				assert.Nil(t, cell.Substrate)
				assert.NotNil(t, cell.MixedSubstrate)
				assert.Equal(t, tt.mixedSubID, cell.MixedSubstrate.ID)
			}
		})
	}
}

func TestClearCell(t *testing.T) {
	set := createTestSubstrateSet()
	stage, _ := NewStage("stage1", "Test Stage", 5, 5, set)
	
	// Place some content
	stage.PlaceSubstrate(1, 1, "sub1")
	stage.PlaceMixedSubstrate(2, 2, "mix1")
	
	tests := []struct {
		name          string
		x             int
		y             int
		expectedError error
	}{
		{
			name:          "Clear cell with substrate",
			x:             1,
			y:             1,
			expectedError: nil,
		},
		{
			name:          "Clear cell with mixed substrate",
			x:             2,
			y:             2,
			expectedError: nil,
		},
		{
			name:          "Invalid position",
			x:             -1,
			y:             2,
			expectedError: ErrInvalidPosition,
		},
		{
			name:          "Cell has no content",
			x:             3,
			y:             3,
			expectedError: ErrCellHasNoContent,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := stage.ClearCell(tt.x, tt.y)
			assert.Equal(t, tt.expectedError, err)
			
			if err == nil {
				// Verify the cell was cleared
				cell, _ := stage.GetCell(tt.x, tt.y)
				assert.Nil(t, cell)
			}
		})
	}
}

func TestGetCell(t *testing.T) {
	set := createTestSubstrateSet()
	stage, _ := NewStage("stage1", "Test Stage", 5, 5, set)
	
	// Place some content
	stage.PlaceSubstrate(1, 1, "sub1")
	stage.PlaceMixedSubstrate(2, 2, "mix1")
	
	tests := []struct {
		name          string
		x             int
		y             int
		expectedError error
		expectedCell  bool
		isSubstrate   bool
		isMixed       bool
		expectedID    string
	}{
		{
			name:          "Get cell with substrate",
			x:             1,
			y:             1,
			expectedError: nil,
			expectedCell:  true,
			isSubstrate:   true,
			isMixed:       false,
			expectedID:    "sub1",
		},
		{
			name:          "Get cell with mixed substrate",
			x:             2,
			y:             2,
			expectedError: nil,
			expectedCell:  true,
			isSubstrate:   false,
			isMixed:       true,
			expectedID:    "mix1",
		},
		{
			name:          "Get empty cell",
			x:             3,
			y:             3,
			expectedError: nil,
			expectedCell:  false,
		},
		{
			name:          "Invalid position",
			x:             -1,
			y:             2,
			expectedError: ErrInvalidPosition,
			expectedCell:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			cell, err := stage.GetCell(tt.x, tt.y)
			assert.Equal(t, tt.expectedError, err)
			
			if tt.expectedCell {
				assert.NotNil(t, cell)
				if tt.isSubstrate {
					assert.NotNil(t, cell.Substrate)
					assert.Nil(t, cell.MixedSubstrate)
					assert.Equal(t, tt.expectedID, cell.Substrate.ID)
				}
				if tt.isMixed {
					assert.Nil(t, cell.Substrate)
					assert.NotNil(t, cell.MixedSubstrate)
					assert.Equal(t, tt.expectedID, cell.MixedSubstrate.ID)
				}
			} else if err == nil {
				assert.Nil(t, cell)
			}
		})
	}
}

func TestString(t *testing.T) {
	set := createTestSubstrateSet()
	stage, _ := NewStage("stage1", "Test Stage", 3, 3, set)
	
	// Empty stage
	emptyStageStr := stage.String()
	assert.Contains(t, emptyStageStr, "Stage stage1 (Test Stage) - 3x3")
	assert.Contains(t, emptyStageStr, "[ ]")
	
	// Place some content
	stage.PlaceSubstrate(0, 0, "sub1")
	stage.PlaceSubstrate(1, 1, "sub2")
	stage.PlaceMixedSubstrate(2, 2, "mix1")
	
	// Stage with content
	stageWithContentStr := stage.String()
	assert.Contains(t, stageWithContentStr, "Stage stage1 (Test Stage) - 3x3")
	assert.Contains(t, stageWithContentStr, "[S:sub1]")
	assert.Contains(t, stageWithContentStr, "[S:sub2]")
	assert.Contains(t, stageWithContentStr, "[M:mix1]")
}

// Helper function for min value (Go 1.21+ has this in the standard library)
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
