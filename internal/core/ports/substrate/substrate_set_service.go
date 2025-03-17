package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// SubstrateSetService defines the interface for substrate set-related operations
type SubstrateSetService interface {
	// Substrate set operations
	CreateSubstrateSet(id, name string) (*substrate.SubstrateSet, error)
	GetSubstrateSet(id string) (*substrate.SubstrateSet, error)
	UpdateSubstrateSet(id, name string) (*substrate.SubstrateSet, error)
	DeleteSubstrateSet(id string) error
	List(page, pageSize int) ([]substrate.SubstrateSet, *common.PaginatedResult, error)
	
	// Substrate operations within sets
	AddSubstrateToSet(setID, substrateID string) error
	RemoveSubstrateFromSet(setID, substrateID string) error
	
	// Mixed substrate operations within sets
	AddMixedSubstrateToSet(setID, mixedSubstrateID string) error
	RemoveMixedSubstrateFromSet(setID, mixedSubstrateID string) error
}
