package substrate

import (
	"errors"
	"math"

	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	substratePort "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// MixedSubstrateServiceImpl implements the MixedSubstrateService interface
type MixedSubstrateServiceImpl struct {
	mixedRepository substratePort.MixedSubstrateRepository
	substrateService substratePort.SubstrateService
}

// NewMixedSubstrateService creates a new instance of MixedSubstrateServiceImpl
func NewMixedSubstrateService(
	mixedRepository substratePort.MixedSubstrateRepository,
	substrateService substratePort.SubstrateService,
) *MixedSubstrateServiceImpl {
	return &MixedSubstrateServiceImpl{
		mixedRepository: mixedRepository,
		substrateService: substrateService,
	}
}

// CreateMixedSubstrate creates a new mixed substrate
func (s *MixedSubstrateServiceImpl) CreateMixedSubstrate(id, name, color string) (*substrate.MixedSubstrate, error) {
	// Check if mixed substrate already exists
	exists, err := s.mixedRepository.Exists(id)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.New("mixed substrate already exists")
	}
	
	// Create new mixed substrate
	newMixedSubstrate := substrate.MixedSubstrate{
		ID:    id,
		Name:  name,
		Color: color,
		Substrates: []substrate.SubstratePercentage{},
	}
	
	// Save to repository
	if err := s.mixedRepository.Create(newMixedSubstrate); err != nil {
		return nil, err
	}
	
	return &newMixedSubstrate, nil
}

// GetMixedSubstrate retrieves a mixed substrate by ID
func (s *MixedSubstrateServiceImpl) GetMixedSubstrate(id string) (*substrate.MixedSubstrate, error) {
	return s.mixedRepository.GetByID(id)
}

// UpdateMixedSubstrate updates an existing mixed substrate
func (s *MixedSubstrateServiceImpl) UpdateMixedSubstrate(id, name, color string) (*substrate.MixedSubstrate, error) {
	// Check if mixed substrate exists
	mixedSub, err := s.mixedRepository.GetByID(id)
	if err != nil {
		return nil, err
	}
	
	// Update fields
	mixedSub.Name = name
	mixedSub.Color = color
	
	// Save to repository
	if err := s.mixedRepository.Update(*mixedSub); err != nil {
		return nil, err
	}
	
	return mixedSub, nil
}

// DeleteMixedSubstrate removes a mixed substrate by ID
func (s *MixedSubstrateServiceImpl) DeleteMixedSubstrate(id string) error {
	// Check if mixed substrate exists
	exists, err := s.mixedRepository.Exists(id)
	if err != nil {
		return err
	}
	if !exists {
		return errors.New("mixed substrate not found")
	}
	
	// Delete from repository
	return s.mixedRepository.Delete(id)
}

// List returns a paginated list of mixed substrates
func (s *MixedSubstrateServiceImpl) List(page, pageSize int) ([]substrate.MixedSubstrate, *common.PaginatedResult, error) {
	// Validate pagination parameters
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}

	// Create pagination params
	params := common.PaginationParams{
		Page:     page,
		PageSize: pageSize,
	}

	// Get paginated mixed substrates
	mixedSubstrates, totalCount, err := s.mixedRepository.List(params)
	if err != nil {
		return nil, nil, err
	}

	// Calculate total pages
	totalPages := int(math.Ceil(float64(totalCount) / float64(pageSize)))

	// Create paginated result
	paginatedResult := &common.PaginatedResult{
		TotalCount: totalCount,
		TotalPages: totalPages,
		Page:       page,
		PageSize:   pageSize,
	}

	return mixedSubstrates, paginatedResult, nil
}

// FindBySubstrateID returns a paginated list of mixed substrates that contain a specific substrate
func (s *MixedSubstrateServiceImpl) FindBySubstrateID(substrateID string, page, pageSize int) ([]substrate.MixedSubstrate, *common.PaginatedResult, error) {
	// Validate pagination parameters
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}

	// Create pagination params
	params := common.PaginationParams{
		Page:     page,
		PageSize: pageSize,
	}

	// Get paginated mixed substrates containing the specified substrate
	mixedSubstrates, totalCount, err := s.mixedRepository.FindBySubstrateID(substrateID, params)
	if err != nil {
		return nil, nil, err
	}

	// Calculate total pages
	totalPages := int(math.Ceil(float64(totalCount) / float64(pageSize)))

	// Create paginated result
	paginatedResult := &common.PaginatedResult{
		TotalCount: totalCount,
		TotalPages: totalPages,
		Page:       page,
		PageSize:   pageSize,
	}

	return mixedSubstrates, paginatedResult, nil
}

// AddSubstrateToMix adds a substrate to a mixed substrate
func (s *MixedSubstrateServiceImpl) AddSubstrateToMix(mixID, substrateID string, percentage float64) error {
	// Get the mixed substrate
	mixedSub, err := s.mixedRepository.GetByID(mixID)
	if err != nil {
		return err
	}
	
	// Get the substrate
	sub, err := s.substrateService.GetSubstrate(substrateID)
	if err != nil {
		return err
	}
	
	// Add substrate to mix
	if err := mixedSub.AddSubstrate(*sub, percentage); err != nil {
		return err
	}
	
	// Save changes
	return s.mixedRepository.Update(*mixedSub)
}

// RemoveSubstrateFromMix removes a substrate from a mixed substrate
func (s *MixedSubstrateServiceImpl) RemoveSubstrateFromMix(mixID, substrateID string) error {
	// Get the mixed substrate
	mixedSub, err := s.mixedRepository.GetByID(mixID)
	if err != nil {
		return err
	}
	
	// Get the substrate
	sub, err := s.substrateService.GetSubstrate(substrateID)
	if err != nil {
		return err
	}
	
	// Remove substrate from mix
	if err := mixedSub.RemoveSubstrate(*sub); err != nil {
		return err
	}
	
	// Save changes
	return s.mixedRepository.Update(*mixedSub)
}

// UpdateSubstratePercentage updates the percentage of a substrate in a mixed substrate
func (s *MixedSubstrateServiceImpl) UpdateSubstratePercentage(mixID, substrateID string, percentage float64) error {
	// Get the mixed substrate
	mixedSub, err := s.mixedRepository.GetByID(mixID)
	if err != nil {
		return err
	}
	
	// Get the substrate
	sub, err := s.substrateService.GetSubstrate(substrateID)
	if err != nil {
		return err
	}
	
	// Update substrate percentage
	if err := mixedSub.UpdatePercentage(*sub, percentage); err != nil {
		return err
	}
	
	// Save changes
	return s.mixedRepository.Update(*mixedSub)
}
