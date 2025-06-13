package main

import (
	guiadapters "github.com/benjaminpina/galatea/internal/adapters/gui/substrate"
	"github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateFileOperations expone las operaciones de archivo de sustratos a la GUI de Wails
type SubstrateFileOperations struct {
	fileAdapter *guiadapters.SubstrateFileAdapter
	service     substrate.SubstrateService
}

// NewSubstrateFileOperations crea una nueva instancia de SubstrateFileOperations
func NewSubstrateFileOperations(fileAdapter *guiadapters.SubstrateFileAdapter, service substrate.SubstrateService) *SubstrateFileOperations {
	return &SubstrateFileOperations{
		fileAdapter: fileAdapter,
		service:     service,
	}
}

// ExportSubstrate exporta un sustrato a un archivo JSON
func (s *SubstrateFileOperations) ExportSubstrate(substrateID string, filePath string) error {
	return s.fileAdapter.ExportSubstrate(substrateID, filePath, s.service)
}

// ImportSubstrate importa un sustrato desde un archivo JSON
func (s *SubstrateFileOperations) ImportSubstrate(filePath string) (*guiadapters.SubstrateResponse, error) {
	return s.fileAdapter.ImportSubstrate(filePath)
}
