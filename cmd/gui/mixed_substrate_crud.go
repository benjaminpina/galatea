package main

import (
	guiadapters "github.com/benjaminpina/galatea/internal/adapters/gui/substrate"
)

type MixedSubstrateCRUD struct {
	mixedSubstrateAdapter *guiadapters.MixedSubstrateAdapter
}

// NewMixedSubstrateCRUD crea un nuevo MixedSubstrateCRUD
func NewMixedSubstrateCRUD(mixedSubstrateAdapter *guiadapters.MixedSubstrateAdapter) *MixedSubstrateCRUD {
	return &MixedSubstrateCRUD{
		mixedSubstrateAdapter: mixedSubstrateAdapter,
	}
}

// CreateMixedSubstrate crea un nuevo sustrato mixto
func (m *MixedSubstrateCRUD) CreateMixedSubstrate(req guiadapters.MixedSubstrateRequest) (*guiadapters.MixedSubstrateResponse, error) {
	return m.mixedSubstrateAdapter.CreateMixedSubstrate(req)
}

// GetMixedSubstrate obtiene un sustrato mixto por ID
func (m *MixedSubstrateCRUD) GetMixedSubstrate(id string) (*guiadapters.MixedSubstrateResponse, error) {
	return m.mixedSubstrateAdapter.GetMixedSubstrate(id)
}

// UpdateMixedSubstrate actualiza un sustrato mixto existente
func (m *MixedSubstrateCRUD) UpdateMixedSubstrate(id string, req guiadapters.MixedSubstrateRequest) (*guiadapters.MixedSubstrateResponse, error) {
	return m.mixedSubstrateAdapter.UpdateMixedSubstrate(id, req)
}

// DeleteMixedSubstrate elimina un sustrato mixto por ID
func (m *MixedSubstrateCRUD) DeleteMixedSubstrate(id string) error {
	return m.mixedSubstrateAdapter.DeleteMixedSubstrate(id)
}

// ListMixedSubstrates obtiene una lista paginada de sustratos mixtos
func (m *MixedSubstrateCRUD) ListMixedSubstrates(page, pageSize int) (*guiadapters.MixedSubstratePaginatedResponse, error) {
	return m.mixedSubstrateAdapter.List(page, pageSize)
}

// FindMixedSubstratesBySubstrateID obtiene una lista paginada de sustratos mixtos que contienen un sustrato específico
func (m *MixedSubstrateCRUD) FindMixedSubstratesBySubstrateID(substrateID string, page, pageSize int) (*guiadapters.MixedSubstratePaginatedResponse, error) {
	return m.mixedSubstrateAdapter.FindBySubstrateID(substrateID, page, pageSize)
}

// AddSubstrateToMix agrega un sustrato a un sustrato mixto
func (m *MixedSubstrateCRUD) AddSubstrateToMix(mixedSubstrateID string, req guiadapters.SubstratePercentageRequest) (*guiadapters.MixedSubstrateResponse, error) {
	return m.mixedSubstrateAdapter.AddSubstrateToMix(mixedSubstrateID, req)
}

// RemoveSubstrateFromMix elimina un sustrato de un sustrato mixto
func (m *MixedSubstrateCRUD) RemoveSubstrateFromMix(mixedSubstrateID string, substrateID string) (*guiadapters.MixedSubstrateResponse, error) {
	return m.mixedSubstrateAdapter.RemoveSubstrateFromMix(mixedSubstrateID, substrateID)
}

// UpdateSubstratePercentage actualiza el porcentaje de un sustrato en un sustrato mixto
func (m *MixedSubstrateCRUD) UpdateSubstratePercentage(mixedSubstrateID string, req guiadapters.SubstratePercentageRequest) (*guiadapters.MixedSubstrateResponse, error) {
	return m.mixedSubstrateAdapter.UpdateSubstratePercentage(mixedSubstrateID, req)
}
