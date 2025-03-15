package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// SubstrateSetService defines the interface for substrate set-related operations
type SubstrateSetService interface {
	// Substrate set operations
	CreateSubstrateSet(id, name string) (*substrate.SubstrateSet, error)
	GetSubstrateSet(id string) (*substrate.SubstrateSet, error)
	UpdateSubstrateSet(id, name string) (*substrate.SubstrateSet, error)
	DeleteSubstrateSet(id string) error
	ListSubstrateSets() ([]substrate.SubstrateSet, error)
}
