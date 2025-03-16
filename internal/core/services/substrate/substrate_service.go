package substrate

import (
	"errors"

	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	substratePort "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateServiceImpl implements the SubstrateService interface
type SubstrateServiceImpl struct {
	repository substratePort.SubstrateRepository
}

// NewSubstrateService creates a new instance of SubstrateServiceImpl
func NewSubstrateService(repository substratePort.SubstrateRepository) *SubstrateServiceImpl {
	return &SubstrateServiceImpl{
		repository: repository,
	}
}

// CreateSubstrate creates a new substrate
func (s *SubstrateServiceImpl) CreateSubstrate(id, name, color string) (*substrate.Substrate, error) {
	// Check if substrate already exists
	exists, err := s.repository.Exists(id)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, errors.New("substrate already exists")
	}
	
	// Create new substrate
	newSubstrate := substrate.Substrate{
		ID:    id,
		Name:  name,
		Color: color,
	}
	
	// Save to repository
	if err := s.repository.Create(newSubstrate); err != nil {
		return nil, err
	}
	
	return &newSubstrate, nil
}

// GetSubstrate retrieves a substrate by ID
func (s *SubstrateServiceImpl) GetSubstrate(id string) (*substrate.Substrate, error) {
	return s.repository.GetByID(id)
}

// UpdateSubstrate updates an existing substrate
func (s *SubstrateServiceImpl) UpdateSubstrate(id, name, color string) (*substrate.Substrate, error) {
	// Check if substrate exists
	sub, err := s.repository.GetByID(id)
	if err != nil {
		return nil, err
	}
	
	// Update fields
	sub.Name = name
	sub.Color = color
	
	// Save to repository
	if err := s.repository.Update(*sub); err != nil {
		return nil, err
	}
	
	return sub, nil
}

// DeleteSubstrate removes a substrate by ID
func (s *SubstrateServiceImpl) DeleteSubstrate(id string) error {
	// Check if substrate exists
	exists, err := s.repository.Exists(id)
	if err != nil {
		return err
	}
	if !exists {
		return errors.New("substrate not found")
	}
	
	// Delete from repository
	return s.repository.Delete(id)
}

// ListSubstrates returns all substrates
func (s *SubstrateServiceImpl) ListSubstrates() ([]substrate.Substrate, error) {
	return s.repository.List()
}