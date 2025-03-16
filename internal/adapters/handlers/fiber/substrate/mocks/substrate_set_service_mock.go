package mocks

import (
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

// ListSubstrateSets es un mock del método ListSubstrateSets
func (m *MockSubstrateSetService) ListSubstrateSets() ([]substrate.SubstrateSet, error) {
	args := m.Called()
	return args.Get(0).([]substrate.SubstrateSet), args.Error(1)
}
