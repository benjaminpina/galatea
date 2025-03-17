package mocks

import (
	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	"github.com/stretchr/testify/mock"
)

// MockSubstrateSetService es un mock del servicio de conjuntos de sustratos
type MockSubstrateSetService struct {
	mock.Mock
}

// CreateSubstrateSet es un mock del método CreateSubstrateSet
func (m *MockSubstrateSetService) CreateSubstrateSet(id, name string) (*substrate.SubstrateSet, error) {
	args := m.Called(id, name)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.SubstrateSet), args.Error(1)
}

// GetSubstrateSet es un mock del método GetSubstrateSet
func (m *MockSubstrateSetService) GetSubstrateSet(id string) (*substrate.SubstrateSet, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.SubstrateSet), args.Error(1)
}

// UpdateSubstrateSet es un mock del método UpdateSubstrateSet
func (m *MockSubstrateSetService) UpdateSubstrateSet(id, name string) (*substrate.SubstrateSet, error) {
	args := m.Called(id, name)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.SubstrateSet), args.Error(1)
}

// DeleteSubstrateSet es un mock del método DeleteSubstrateSet
func (m *MockSubstrateSetService) DeleteSubstrateSet(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

// List es un mock del método List
func (m *MockSubstrateSetService) List(page, pageSize int) ([]substrate.SubstrateSet, *common.PaginatedResult, error) {
	args := m.Called(page, pageSize)
	if args.Get(0) == nil {
		return nil, nil, args.Error(2)
	}
	return args.Get(0).([]substrate.SubstrateSet), args.Get(1).(*common.PaginatedResult), args.Error(2)
}

// AddSubstrateToSet es un mock del método AddSubstrateToSet
func (m *MockSubstrateSetService) AddSubstrateToSet(setID, substrateID string) error {
	args := m.Called(setID, substrateID)
	return args.Error(0)
}

// RemoveSubstrateFromSet es un mock del método RemoveSubstrateFromSet
func (m *MockSubstrateSetService) RemoveSubstrateFromSet(setID, substrateID string) error {
	args := m.Called(setID, substrateID)
	return args.Error(0)
}

// AddMixedSubstrateToSet es un mock del método AddMixedSubstrateToSet
func (m *MockSubstrateSetService) AddMixedSubstrateToSet(setID, mixedSubstrateID string) error {
	args := m.Called(setID, mixedSubstrateID)
	return args.Error(0)
}

// RemoveMixedSubstrateFromSet es un mock del método RemoveMixedSubstrateFromSet
func (m *MockSubstrateSetService) RemoveMixedSubstrateFromSet(setID, mixedSubstrateID string) error {
	args := m.Called(setID, mixedSubstrateID)
	return args.Error(0)
}
