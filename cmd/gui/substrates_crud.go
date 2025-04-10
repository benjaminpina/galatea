package main

import (
	guiadapters "github.com/benjaminpina/galatea/internal/adapters/gui/substrate"
)

type SubstrateCRUD struct {
	substrateAdapter *guiadapters.SubstrateAdapter
}

// NewSubstrateCRUD crea un nuevo SubstrateCRUD
func NewSubstrateCRUD(substrateAdapter *guiadapters.SubstrateAdapter) *SubstrateCRUD {
	return &SubstrateCRUD{
		substrateAdapter: substrateAdapter,
	}
}

// CreateSubstrate crea un nuevo sustrato
func (s *SubstrateCRUD) CreateSubstrate(req guiadapters.SubstrateRequest) (*guiadapters.SubstrateResponse, error) {
	return s.substrateAdapter.CreateSubstrate(req)
}

// GetSubstrate obtiene un sustrato por ID
func (s *SubstrateCRUD) GetSubstrate(id string) (*guiadapters.SubstrateResponse, error) {
	return s.substrateAdapter.GetSubstrate(id)
}

// UpdateSubstrate actualiza un sustrato existente
func (s *SubstrateCRUD) UpdateSubstrate(id string, req guiadapters.SubstrateRequest) (*guiadapters.SubstrateResponse, error) {
	return s.substrateAdapter.UpdateSubstrate(id, req)
}

// DeleteSubstrate elimina un sustrato por ID
func (s *SubstrateCRUD) DeleteSubstrate(id string) error {
	return s.substrateAdapter.DeleteSubstrate(id)
}

// ListSubstrates obtiene una lista paginada de sustratos
func (s *SubstrateCRUD) ListSubstrates(page, pageSize int) (*guiadapters.PaginatedResponse, error) {
	return s.substrateAdapter.List(page, pageSize)
}
