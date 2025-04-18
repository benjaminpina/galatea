package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// MixedSubstrateRepository defines the interface for mixed substrate data access operations
type MixedSubstrateRepository interface {
	// Create a new mixed substrate
	Create(mixedSub substrate.MixedSubstrate) error
	
	// Get a mixed substrate by ID
	GetByID(id string) (*substrate.MixedSubstrate, error)
	
	// Update an existing mixed substrate
	Update(mixedSub substrate.MixedSubstrate) error
	
	// Delete a mixed substrate by ID
	Delete(id string) error
	
	// List mixed substrates with pagination
	List(params common.PaginationParams) ([]substrate.MixedSubstrate, int, error)
	
	// Check if a mixed substrate exists by ID
	Exists(id string) (bool, error)
	
	// Find mixed substrates that contain a specific substrate with pagination
	FindBySubstrateID(substrateID string, params common.PaginationParams) ([]substrate.MixedSubstrate, int, error)
}
