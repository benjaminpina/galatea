package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// MixedSubstrateService defines the interface for mixed substrate-related operations
type MixedSubstrateService interface {
	// Mixed substrate operations
	CreateMixedSubstrate(id string, name string, color string) (*substrate.MixedSubstrate, error)
	GetMixedSubstrate(id string) (*substrate.MixedSubstrate, error)
	UpdateMixedSubstrate(id string, name string, color string) (*substrate.MixedSubstrate, error)
	DeleteMixedSubstrate(id string) error
	List(page, pageSize int) ([]substrate.MixedSubstrate, *common.PaginatedResult, error)
	FindBySubstrateID(substrateID string, page, pageSize int) ([]substrate.MixedSubstrate, *common.PaginatedResult, error)

	// Substrate percentage operations
	AddSubstrateToMix(mixID, substrateID string, percentage float64) error
	RemoveSubstrateFromMix(mixID, substrateID string) error
	UpdateSubstratePercentage(mixID, substrateID string, percentage float64) error
}
