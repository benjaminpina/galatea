package mocks

import (
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	"github.com/stretchr/testify/mock"
)

// MockMixedSubstrateService es un mock del servicio de MixedSubstrate para pruebas
type MockMixedSubstrateService struct {
	mock.Mock
}

// CreateMixedSubstrate implementa la interfaz MixedSubstrateService
func (m *MockMixedSubstrateService) CreateMixedSubstrate(id, name, color string) (*substrate.MixedSubstrate, error) {
	args := m.Called(id, name, color)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.MixedSubstrate), args.Error(1)
}

// GetMixedSubstrate implementa la interfaz MixedSubstrateService
func (m *MockMixedSubstrateService) GetMixedSubstrate(id string) (*substrate.MixedSubstrate, error) {
	args := m.Called(id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.MixedSubstrate), args.Error(1)
}

// UpdateMixedSubstrate implementa la interfaz MixedSubstrateService
func (m *MockMixedSubstrateService) UpdateMixedSubstrate(id, name, color string) (*substrate.MixedSubstrate, error) {
	args := m.Called(id, name, color)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*substrate.MixedSubstrate), args.Error(1)
}

// DeleteMixedSubstrate implementa la interfaz MixedSubstrateService
func (m *MockMixedSubstrateService) DeleteMixedSubstrate(id string) error {
	args := m.Called(id)
	return args.Error(0)
}

// ListMixedSubstrates implementa la interfaz MixedSubstrateService
func (m *MockMixedSubstrateService) ListMixedSubstrates() ([]substrate.MixedSubstrate, error) {
	args := m.Called()
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]substrate.MixedSubstrate), args.Error(1)
}

// AddSubstrateToMix implementa la interfaz MixedSubstrateService
func (m *MockMixedSubstrateService) AddSubstrateToMix(mixID, substrateID string, percentage float64) error {
	args := m.Called(mixID, substrateID, percentage)
	return args.Error(0)
}

// RemoveSubstrateFromMix implementa la interfaz MixedSubstrateService
func (m *MockMixedSubstrateService) RemoveSubstrateFromMix(mixID, substrateID string) error {
	args := m.Called(mixID, substrateID)
	return args.Error(0)
}

// UpdateSubstratePercentage implementa la interfaz MixedSubstrateService
func (m *MockMixedSubstrateService) UpdateSubstratePercentage(mixID, substrateID string, percentage float64) error {
	args := m.Called(mixID, substrateID, percentage)
	return args.Error(0)
}
