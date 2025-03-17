package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// SubstrateService defines the interface for substrate-related operations
type SubstrateService interface {
	// Substrate operations
	CreateSubstrate(id, name, color string) (*substrate.Substrate, error)
	GetSubstrate(id string) (*substrate.Substrate, error)
	UpdateSubstrate(id, name, color string) (*substrate.Substrate, error)
	DeleteSubstrate(id string) error
	List(page, pageSize int) ([]substrate.Substrate, *common.PaginatedResult, error)
}
