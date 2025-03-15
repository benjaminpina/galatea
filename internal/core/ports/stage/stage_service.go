package stage

import (
	"github.com/benjaminpina/galatea/internal/core/domain/stage"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// StageService defines the interface for stage-related operations
type StageService interface {
	// Stage CRUD operations
	CreateStage(id, name string, width, height int, substrateSetID string) (*stage.Stage, error)
	GetStage(id string) (*stage.Stage, error)
	UpdateStage(id, name, comment string) (*stage.Stage, error)
	DeleteStage(id string) error
	ListStages() ([]stage.Stage, error)
	
	// Stage content operations
	ResizeStage(id string, newWidth, newHeight int) error
	PlaceSubstrate(stageID string, x, y int, substrateID string) error
	PlaceMixedSubstrate(stageID string, x, y int, mixedSubstrateID string) error
	ClearCell(stageID string, x, y int) error
	GetCell(stageID string, x, y int) (*stage.Cell, error)
	
	// Stage substrate set operations
	GetStageSubstrateSet(stageID string) (*substrate.SubstrateSet, error)
	ChangeStageSubstrateSet(stageID, substrateSetID string) error
}