package main

import (
	guiadapters "github.com/benjaminpina/galatea/internal/adapters/gui/substrate"
)

type SubstrateSetCRUD struct {
	substrateSetAdapter *guiadapters.SubstrateSetAdapter
}

// NewSubstrateSetCRUD crea un nuevo SubstrateSetCRUD
func NewSubstrateSetCRUD(substrateSetAdapter *guiadapters.SubstrateSetAdapter) *SubstrateSetCRUD {
	return &SubstrateSetCRUD{
		substrateSetAdapter: substrateSetAdapter,
	}
}

// CreateSubstrateSet crea un nuevo conjunto de sustratos
func (s *SubstrateSetCRUD) CreateSubstrateSet(req guiadapters.SubstrateSetRequest) (*guiadapters.SubstrateSetResponse, error) {
	return s.substrateSetAdapter.CreateSubstrateSet(req)
}

// GetSubstrateSet obtiene un conjunto de sustratos por ID
func (s *SubstrateSetCRUD) GetSubstrateSet(id string) (*guiadapters.SubstrateSetResponse, error) {
	return s.substrateSetAdapter.GetSubstrateSet(id)
}

// UpdateSubstrateSet actualiza un conjunto de sustratos existente
func (s *SubstrateSetCRUD) UpdateSubstrateSet(id string, req guiadapters.SubstrateSetRequest) (*guiadapters.SubstrateSetResponse, error) {
	return s.substrateSetAdapter.UpdateSubstrateSet(id, req)
}

// DeleteSubstrateSet elimina un conjunto de sustratos por ID
func (s *SubstrateSetCRUD) DeleteSubstrateSet(id string) error {
	return s.substrateSetAdapter.DeleteSubstrateSet(id)
}

// ListSubstrateSets obtiene una lista paginada de conjuntos de sustratos
func (s *SubstrateSetCRUD) ListSubstrateSets(page, pageSize int) (*guiadapters.SubstrateSetPaginatedResponse, error) {
	return s.substrateSetAdapter.List(page, pageSize)
}
