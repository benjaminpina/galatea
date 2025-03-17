package substrate

import (
	"fmt"
	"math"

	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
	"github.com/google/uuid"
)

// SubstrateSetService implements the SubstrateSetService interface
type SubstrateSetService struct {
	repo ports.SubstrateSetRepository
}

// NewSubstrateSetService creates a new SubstrateSetService
func NewSubstrateSetService(repo ports.SubstrateSetRepository) *SubstrateSetService {
	return &SubstrateSetService{
		repo: repo,
	}
}

// CreateSubstrateSet creates a new substrate set
func (s *SubstrateSetService) CreateSubstrateSet(id, name string) (*substrate.SubstrateSet, error) {
	// If ID is empty, generate a new UUID
	if id == "" {
		id = uuid.New().String()
	}

	// Create a new substrate set
	set := substrate.NewSubstrateSet(id, name)

	// Save to repository
	err := s.repo.Create(*set)
	if err != nil {
		return nil, fmt.Errorf("failed to create substrate set: %w", err)
	}

	return set, nil
}

// GetSubstrateSet retrieves a substrate set by ID
func (s *SubstrateSetService) GetSubstrateSet(id string) (*substrate.SubstrateSet, error) {
	// Get from repository
	set, err := s.repo.GetByID(id)
	if err != nil {
		return nil, fmt.Errorf("failed to get substrate set: %w", err)
	}

	return set, nil
}

// UpdateSubstrateSet updates a substrate set
func (s *SubstrateSetService) UpdateSubstrateSet(id, name string) (*substrate.SubstrateSet, error) {
	// Check if the substrate set exists
	set, err := s.repo.GetByID(id)
	if err != nil {
		return nil, fmt.Errorf("failed to get substrate set for update: %w", err)
	}

	// Update the name
	set.Name = name

	// Save to repository
	err = s.repo.Update(*set)
	if err != nil {
		return nil, fmt.Errorf("failed to update substrate set: %w", err)
	}

	return set, nil
}

// DeleteSubstrateSet deletes a substrate set
func (s *SubstrateSetService) DeleteSubstrateSet(id string) error {
	// Check if the substrate set exists
	exists, err := s.repo.Exists(id)
	if err != nil {
		return fmt.Errorf("failed to check if substrate set exists: %w", err)
	}
	if !exists {
		return fmt.Errorf("substrate set not found with id %s", id)
	}

	// Delete from repository
	err = s.repo.Delete(id)
	if err != nil {
		return fmt.Errorf("failed to delete substrate set: %w", err)
	}

	return nil
}

// List returns a paginated list of substrate sets
func (s *SubstrateSetService) List(page, pageSize int) ([]substrate.SubstrateSet, *common.PaginatedResult, error) {
	// Validate pagination parameters
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}

	// Create pagination parameters
	params := common.PaginationParams{
		Page:     page,
		PageSize: pageSize,
	}

	// Get substrate sets from repository
	sets, totalCount, err := s.repo.List(params)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to list substrate sets: %w", err)
	}

	// Calculate total pages
	totalPages := int(math.Ceil(float64(totalCount) / float64(pageSize)))

	// Create paginated result
	paginatedResult := &common.PaginatedResult{
		Page:       page,
		PageSize:   pageSize,
		TotalCount: totalCount,
		TotalPages: totalPages,
	}

	return sets, paginatedResult, nil
}

// AddSubstrateToSet adds a substrate to a substrate set
func (s *SubstrateSetService) AddSubstrateToSet(setID string, substrateID string) error {
	// Get the substrate
	substrateSets, err := s.repo.GetByID(setID)
	if err != nil {
		return fmt.Errorf("failed to get substrate set: %w", err)
	}

	// Find the substrate in the list
	for _, sub := range substrateSets.Substrates {
		if sub.ID == substrateID {
			// Substrate already in set
			return nil
		}
	}

	// Create a new substrate with just the ID
	newSubstrate := substrate.Substrate{
		ID: substrateID,
	}

	return s.repo.AddSubstrate(setID, newSubstrate)
}

// RemoveSubstrateFromSet removes a substrate from a substrate set
func (s *SubstrateSetService) RemoveSubstrateFromSet(setID, substrateID string) error {
	return s.repo.RemoveSubstrate(setID, substrateID)
}

// AddMixedSubstrateToSet adds a mixed substrate to a substrate set
func (s *SubstrateSetService) AddMixedSubstrateToSet(setID string, mixedSubstrateID string) error {
	// Get the substrate set
	substrateSets, err := s.repo.GetByID(setID)
	if err != nil {
		return fmt.Errorf("failed to get substrate set: %w", err)
	}

	// Find the mixed substrate in the list
	for _, mixedSub := range substrateSets.MixedSubstrates {
		if mixedSub.ID == mixedSubstrateID {
			// Mixed substrate already in set
			return nil
		}
	}

	// Create a new mixed substrate with just the ID
	newMixedSubstrate := substrate.MixedSubstrate{
		ID: mixedSubstrateID,
	}

	return s.repo.AddMixedSubstrate(setID, newMixedSubstrate)
}

// RemoveMixedSubstrateFromSet removes a mixed substrate from a substrate set
func (s *SubstrateSetService) RemoveMixedSubstrateFromSet(setID, mixedSubstrateID string) error {
	return s.repo.RemoveMixedSubstrate(setID, mixedSubstrateID)
}
