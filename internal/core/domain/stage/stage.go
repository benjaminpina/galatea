package stage

import (
	"errors"
	"fmt"

	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// Cell represents the content of a cell in the Stage grid
type Cell struct {
	Substrate      *substrate.Substrate
	MixedSubstrate *substrate.MixedSubstrate
}

// Stage represents a two-dimensional grid where each cell can contain a Substrate or MixedSubstrate
type Stage struct {
	ID           string
	Name         string
	Comment      string
	SubstrateSet *substrate.SubstrateSet
	Width        int
	Height       int
	Grid         [][]*Cell
}

// Common errors
var (
	ErrInvalidPosition        = errors.New("invalid position")
	ErrSubstrateNotInSet      = errors.New("substrate not in set")
	ErrMixedSubstrateNotInSet = errors.New("mixed substrate not in set")
	ErrCellAlreadyHasContent  = errors.New("cell already has content")
	ErrCellHasNoContent       = errors.New("cell has no content")
	ErrInvalidDimensions      = errors.New("invalid dimensions")
)

// NewStage creates a new Stage with the specified dimensions and substrate set
func NewStage(id, name string, width, height int, substrateSet *substrate.SubstrateSet) (*Stage, error) {
	if width <= 0 || height <= 0 {
		return nil, ErrInvalidDimensions
	}

	// Create the grid
	grid := make([][]*Cell, height)
	for i := range grid {
		grid[i] = make([]*Cell, width)
		// Initialize with empty cells
		for j := range grid[i] {
			grid[i][j] = nil
		}
	}

	return &Stage{
		ID:           id,
		Name:         name,
		Comment:      "",
		SubstrateSet: substrateSet,
		Width:        width,
		Height:       height,
		Grid:         grid,
	}, nil
}

// Resize changes the dimensions of the Stage
func (s *Stage) Resize(newWidth, newHeight int) error {
	if newWidth <= 0 || newHeight <= 0 {
		return ErrInvalidDimensions
	}

	// Create a new grid with the new dimensions
	newGrid := make([][]*Cell, newHeight)
	for i := range newGrid {
		newGrid[i] = make([]*Cell, newWidth)
		// Copy existing content where possible
		for j := range newGrid[i] {
			if i < s.Height && j < s.Width {
				newGrid[i][j] = s.Grid[i][j]
			} else {
				newGrid[i][j] = nil
			}
		}
	}

	// Update the Stage
	s.Width = newWidth
	s.Height = newHeight
	s.Grid = newGrid
	return nil
}

// IsValidPosition checks if a position is within the grid boundaries
func (s *Stage) IsValidPosition(x, y int) bool {
	return x >= 0 && x < s.Width && y >= 0 && y < s.Height
}

// PlaceSubstrate places a substrate at the specified position
func (s *Stage) PlaceSubstrate(x, y int, subID string) error {
	// Check if position is valid
	if !s.IsValidPosition(x, y) {
		return ErrInvalidPosition
	}

	// Check if the substrate exists in the set
	subs := s.SubstrateSet.GetSubstrates()
	var sub *substrate.Substrate
	for i := range subs {
		if subs[i].ID == subID {
			sub = &subs[i]
			break
		}
	}
	if sub == nil {
		return ErrSubstrateNotInSet
	}

	// Check if the cell is empty
	if s.Grid[y][x] != nil {
		return ErrCellAlreadyHasContent
	}

	// Place the substrate
	s.Grid[y][x] = &Cell{
		Substrate:      sub,
		MixedSubstrate: nil,
	}
	return nil
}

// PlaceMixedSubstrate places a mixed substrate at the specified position
func (s *Stage) PlaceMixedSubstrate(x, y int, mixedSubID string) error {
	// Check if position is valid
	if !s.IsValidPosition(x, y) {
		return ErrInvalidPosition
	}

	// Check if the mixed substrate exists in the set
	mixedSubs := s.SubstrateSet.GetMixedSubstrates()
	var mixedSub *substrate.MixedSubstrate
	for i := range mixedSubs {
		if mixedSubs[i].ID == mixedSubID {
			mixedSub = &mixedSubs[i]
			break
		}
	}
	if mixedSub == nil {
		return ErrMixedSubstrateNotInSet
	}

	// Check if the cell is empty
	if s.Grid[y][x] != nil {
		return ErrCellAlreadyHasContent
	}

	// Place the mixed substrate
	s.Grid[y][x] = &Cell{
		Substrate:      nil,
		MixedSubstrate: mixedSub,
	}
	return nil
}

// ClearCell removes any content from the specified cell
func (s *Stage) ClearCell(x, y int) error {
	// Check if position is valid
	if !s.IsValidPosition(x, y) {
		return ErrInvalidPosition
	}

	// Check if the cell has content
	if s.Grid[y][x] == nil {
		return ErrCellHasNoContent
	}

	// Clear the cell
	s.Grid[y][x] = nil
	return nil
}

// GetCell returns the content of a cell
func (s *Stage) GetCell(x, y int) (*Cell, error) {
	// Check if position is valid
	if !s.IsValidPosition(x, y) {
		return nil, ErrInvalidPosition
	}

	return s.Grid[y][x], nil
}

// String returns a string representation of the Stage
func (s *Stage) String() string {
	result := fmt.Sprintf("Stage %s (%s) - %dx%d\n", s.ID, s.Name, s.Width, s.Height)
	for y := 0; y < s.Height; y++ {
		for x := 0; x < s.Width; x++ {
			cell := s.Grid[y][x]
			if cell == nil {
				result += "[ ]"
			} else if cell.Substrate != nil {
				result += fmt.Sprintf("[S:%s]", cell.Substrate.ID)
			} else if cell.MixedSubstrate != nil {
				result += fmt.Sprintf("[M:%s]", cell.MixedSubstrate.ID)
			}
		}
		result += "\n"
	}
	return result
}
