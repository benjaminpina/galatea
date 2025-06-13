package substrate

import (
	domainSubstrate "github.com/benjaminpina/galatea/internal/core/domain/substrate"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// MixedSubstrateFileAdapter is an adapter to expose mixed substrate file operations to the GUI
type MixedSubstrateFileAdapter struct {
	fileService ports.MixedSubstrateFileService
}

// NewMixedSubstrateFileAdapter creates a new mixed substrate file adapter
func NewMixedSubstrateFileAdapter(fileService ports.MixedSubstrateFileService) *MixedSubstrateFileAdapter {
	return &MixedSubstrateFileAdapter{
		fileService: fileService,
	}
}

// ExportMixedSubstrate exports a mixed substrate to a file
func (a *MixedSubstrateFileAdapter) ExportMixedSubstrate(mixedSubID string, filePath string, service ports.MixedSubstrateService) error {
	// Get the mixed substrate from the service
	mixedSub, err := service.GetMixedSubstrate(mixedSubID)
	if err != nil {
		return err
	}

	// Export the mixed substrate
	return a.fileService.ExportMixedSubstrate(mixedSub, filePath)
}

// ImportMixedSubstrate imports a mixed substrate from a file
func (a *MixedSubstrateFileAdapter) ImportMixedSubstrate(filePath string) (*MixedSubstrateResponse, error) {
	// Import the mixed substrate
	mixedSub, err := a.fileService.ImportMixedSubstrate(filePath)
	if err != nil {
		return nil, err
	}

	// Convert to response
	return convertMixedSubstrateToResponse(*mixedSub), nil
}

// convertMixedSubstrateToResponse converts a domain MixedSubstrate to a GUI response
func convertMixedSubstrateToResponse(mixedSub domainSubstrate.MixedSubstrate) *MixedSubstrateResponse {
	// Map substrates with percentages
	substrates := make([]SubstratePercentageResponse, len(mixedSub.Substrates))
	for i, sp := range mixedSub.Substrates {
		substrates[i] = SubstratePercentageResponse{
			SubstrateID:   sp.Substrate.ID,
			SubstrateName: sp.Substrate.Name,
			Color:         sp.Substrate.Color,
			Percentage:    sp.Percentage,
		}
	}

	return &MixedSubstrateResponse{
		ID:         mixedSub.ID,
		Name:       mixedSub.Name,
		Color:      mixedSub.Color,
		Substrates: substrates,
	}
}
