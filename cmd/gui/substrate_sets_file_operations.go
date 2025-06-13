package main

import (
	guiadapters "github.com/benjaminpina/galatea/internal/adapters/gui/substrate"
	"github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateSetFileOperations expone las operaciones de archivo de conjuntos de sustratos a la GUI de Wails
type SubstrateSetFileOperations struct {
	fileAdapter *guiadapters.SubstrateSetFileAdapter
	service     substrate.SubstrateSetService
}

// NewSubstrateSetFileOperations crea una nueva instancia de SubstrateSetFileOperations
func NewSubstrateSetFileOperations(fileAdapter *guiadapters.SubstrateSetFileAdapter, service substrate.SubstrateSetService) *SubstrateSetFileOperations {
	return &SubstrateSetFileOperations{
		fileAdapter: fileAdapter,
		service:     service,
	}
}

// ExportSubstrateSet exporta un conjunto de sustratos a un archivo JSON
func (s *SubstrateSetFileOperations) ExportSubstrateSet(substrateSetID string, filePath string) error {
	return s.fileAdapter.ExportSubstrateSet(substrateSetID, filePath, s.service)
}

// ImportSubstrateSet importa un conjunto de sustratos desde un archivo JSON
func (s *SubstrateSetFileOperations) ImportSubstrateSet(filePath string) (*guiadapters.SubstrateSetResponse, error) {
	return s.fileAdapter.ImportSubstrateSet(filePath)
}
