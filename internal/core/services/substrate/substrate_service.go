package substrate

import (
	"errors"
	"fmt"

	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	substratePort "github.com/benjaminpina/galatea/internal/core/ports/substrate"
	"github.com/google/uuid"
)

// SubstrateServiceImpl implements the SubstrateService interface
type SubstrateServiceImpl struct {
	repository substratePort.SubstrateRepository
}

// NewSubstrateService creates a new instance of SubstrateServiceImpl
func NewSubstrateService(repo substratePort.SubstrateRepository) *SubstrateServiceImpl {
	return &SubstrateServiceImpl{
		repository: repo,
	}
}

// CreateSubstrate creates a new substrate
func (s *SubstrateServiceImpl) CreateSubstrate(id, name, color string) (*substrate.Substrate, error) {
	// Generate ID if not provided
	if id == "" {
		id = uuid.New().String()
	}
	
	// Check if substrate already exists
	exists, err := s.repository.Exists(id)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.New("substrate already exists")
	}
	
	// Create new substrate
	sub := substrate.Substrate{
		ID:    id,
		Name:  name,
		Color: color,
	}
	
	// Save to repository
	err = s.repository.Create(sub)
	if err != nil {
		return nil, fmt.Errorf("error creating substrate: %w", err)
	}
	
	return &sub, nil
}

// GetSubstrate retrieves a substrate by ID
func (s *SubstrateServiceImpl) GetSubstrate(id string) (*substrate.Substrate, error) {
	sub, err := s.repository.GetByID(id)
	if err != nil {
		return nil, fmt.Errorf("error retrieving substrate: %w", err)
	}
	
	if sub == nil {
		return nil, errors.New("substrate not found")
	}
	
	return sub, nil
}

// UpdateSubstrate updates an existing substrate
func (s *SubstrateServiceImpl) UpdateSubstrate(id, name, color string) (*substrate.Substrate, error) {
	// Check if substrate exists
	exists, err := s.repository.Exists(id)
	if err != nil {
		return nil, fmt.Errorf("error checking substrate existence: %w", err)
	}
	
	if !exists {
		return nil, errors.New("substrate not found")
	}
	
	// Update substrate
	sub := substrate.Substrate{
		ID:    id,
		Name:  name,
		Color: color,
	}
	
	err = s.repository.Update(sub)
	if err != nil {
		return nil, fmt.Errorf("error updating substrate: %w", err)
	}
	
	return &sub, nil
}

// DeleteSubstrate deletes a substrate by ID
func (s *SubstrateServiceImpl) DeleteSubstrate(id string) error {
	// Check if substrate exists
	exists, err := s.repository.Exists(id)
	if err != nil {
		return fmt.Errorf("error checking substrate existence: %w", err)
	}
	
	if !exists {
		return errors.New("substrate not found")
	}
	
	// Delete substrate
	err = s.repository.Delete(id)
	if err != nil {
		return fmt.Errorf("error deleting substrate: %w", err)
	}
	
	return nil
}

// List retrieves all substrates with pagination
func (s *SubstrateServiceImpl) List(page, pageSize int) ([]substrate.Substrate, *common.PaginatedResult, error) {
	// Validate pagination parameters
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}
	
	params := common.PaginationParams{
		Page:     page,
		PageSize: pageSize,
	}
	
	substrates, total, err := s.repository.List(params)
	if err != nil {
		return nil, nil, fmt.Errorf("error retrieving substrates: %w", err)
	}
	
	result := &common.PaginatedResult{
		Page:       page,
		PageSize:   pageSize,
		TotalCount: total,
		TotalPages: (total + pageSize - 1) / pageSize,
	}
	
	return substrates, result, nil
}