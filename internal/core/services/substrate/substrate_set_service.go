package substrate

import (
	"fmt"

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

// ListSubstrateSets returns all substrate sets
func (s *SubstrateSetService) ListSubstrateSets() ([]substrate.SubstrateSet, error) {
	// Get from repository
	sets, err := s.repo.List()
	if err != nil {
		return nil, fmt.Errorf("failed to list substrate sets: %w", err)
	}

	return sets, nil
}
