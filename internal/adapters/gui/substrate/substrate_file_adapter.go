package substrate

import (
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateFileAdapter is an adapter to expose substrate file operations to the GUI
type SubstrateFileAdapter struct {
	fileService ports.SubstrateFileService
}

// NewSubstrateFileAdapter creates a new substrate file adapter
func NewSubstrateFileAdapter(fileService ports.SubstrateFileService) *SubstrateFileAdapter {
	return &SubstrateFileAdapter{
		fileService: fileService,
	}
}

// ExportSubstrate exports a substrate to a file
func (a *SubstrateFileAdapter) ExportSubstrate(substrateID string, filePath string, service ports.SubstrateService) error {
	// Get the substrate from the service
	sub, err := service.GetSubstrate(substrateID)
	if err != nil {
		return err
	}

	// Export the substrate
	return a.fileService.ExportSubstrate(sub, filePath)
}

// ImportSubstrate imports a substrate from a file
func (a *SubstrateFileAdapter) ImportSubstrate(filePath string) (*SubstrateResponse, error) {
	// Import the substrate
	sub, err := a.fileService.ImportSubstrate(filePath)
	if err != nil {
		return nil, err
	}

	// Convert to response
	return &SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}, nil
}
