package stage

import (
	"github.com/benjaminpina/galatea/internal/core/domain/stage"
)

// StageRepository defines the interface for stage data access operations
type StageRepository interface {
	// Create a new stage
	Create(stg stage.Stage) error
	
	// Get a stage by ID
	GetByID(id string) (*stage.Stage, error)
	
	// Update an existing stage
	Update(stg stage.Stage) error
	
	// Delete a stage by ID
	Delete(id string) error
	
	// List all stages
	List() ([]stage.Stage, error)
	
	// Check if a stage exists by ID
	Exists(id string) (bool, error)
	
	// Find stages that use a specific substrate set
	FindBySubstrateSetID(substrateSetID string) ([]stage.Stage, error)
	
	// Update the grid content of a stage
	UpdateGrid(id string, grid [][]*stage.Cell) error
	
	// Update a single cell in the stage grid
	UpdateCell(id string, x, y int, cell *stage.Cell) error
}
