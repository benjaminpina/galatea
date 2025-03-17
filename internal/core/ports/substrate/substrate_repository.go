package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// SubstrateRepository defines the interface for substrate data access operations
type SubstrateRepository interface {
	// Create a new substrate
	Create(sub substrate.Substrate) error
	
	// Get a substrate by ID
	GetByID(id string) (*substrate.Substrate, error)
	
	// Update an existing substrate
	Update(sub substrate.Substrate) error
	
	// Delete a substrate by ID
	Delete(id string) error
	
	// List substrates with pagination
	List(params common.PaginationParams) ([]substrate.Substrate, int, error)
	
	// Check if a substrate exists by ID
	Exists(id string) (bool, error)
}
