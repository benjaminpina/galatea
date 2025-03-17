package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// SubstrateSetRepository defines the interface for substrate set data access operations
type SubstrateSetRepository interface {
	// Create a new substrate set
	Create(set substrate.SubstrateSet) error
	
	// Get a substrate set by ID
	GetByID(id string) (*substrate.SubstrateSet, error)
	
	// Update an existing substrate set
	Update(set substrate.SubstrateSet) error
	
	// Delete a substrate set by ID
	Delete(id string) error
	
	// List substrate sets with pagination
	List(params common.PaginationParams) ([]substrate.SubstrateSet, int, error)
	
	// Check if a substrate set exists by ID
	Exists(id string) (bool, error)
	
	// Add a substrate to a substrate set
	AddSubstrate(setID string, sub substrate.Substrate) error
	
	// Remove a substrate from a substrate set
	RemoveSubstrate(setID string, substrateID string) error
	
	// Add a mixed substrate to a substrate set
	AddMixedSubstrate(setID string, mixedSub substrate.MixedSubstrate) error
	
	// Remove a mixed substrate from a substrate set
	RemoveMixedSubstrate(setID string, mixedSubstrateID string) error
}
