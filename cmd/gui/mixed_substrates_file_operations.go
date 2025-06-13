package main

import (
	guiadapters "github.com/benjaminpina/galatea/internal/adapters/gui/substrate"
	"github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// MixedSubstrateFileOperations expone las operaciones de archivo de sustratos mixtos a la GUI de Wails
type MixedSubstrateFileOperations struct {
	fileAdapter *guiadapters.MixedSubstrateFileAdapter
	service     substrate.MixedSubstrateService
}

// NewMixedSubstrateFileOperations crea una nueva instancia de MixedSubstrateFileOperations
func NewMixedSubstrateFileOperations(fileAdapter *guiadapters.MixedSubstrateFileAdapter, service substrate.MixedSubstrateService) *MixedSubstrateFileOperations {
	return &MixedSubstrateFileOperations{
		fileAdapter: fileAdapter,
		service:     service,
	}
}

// ExportMixedSubstrate exporta un sustrato mixto a un archivo JSON
func (s *MixedSubstrateFileOperations) ExportMixedSubstrate(mixedSubstrateID string, filePath string) error {
	return s.fileAdapter.ExportMixedSubstrate(mixedSubstrateID, filePath, s.service)
}

// ImportMixedSubstrate importa un sustrato mixto desde un archivo JSON
func (s *MixedSubstrateFileOperations) ImportMixedSubstrate(filePath string) (*guiadapters.MixedSubstrateResponse, error) {
	return s.fileAdapter.ImportMixedSubstrate(filePath)
}
