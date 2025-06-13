package substrate

import (
	domainSubstrate "github.com/benjaminpina/galatea/internal/core/domain/substrate"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateSetFileAdapter is an adapter to expose substrate set file operations to the GUI
type SubstrateSetFileAdapter struct {
	fileService ports.SubstrateSetFileService
}

// NewSubstrateSetFileAdapter creates a new substrate set file adapter
func NewSubstrateSetFileAdapter(fileService ports.SubstrateSetFileService) *SubstrateSetFileAdapter {
	return &SubstrateSetFileAdapter{
		fileService: fileService,
	}
}

// ExportSubstrateSet exports a substrate set to a file
func (a *SubstrateSetFileAdapter) ExportSubstrateSet(setID string, filePath string, service ports.SubstrateSetService) error {
	// Get the substrate set from the service
	set, err := service.GetSubstrateSet(setID)
	if err != nil {
		return err
	}

	// Export the substrate set
	return a.fileService.ExportSubstrateSet(set, filePath)
}

// ImportSubstrateSet imports a substrate set from a file
func (a *SubstrateSetFileAdapter) ImportSubstrateSet(filePath string) (*SubstrateSetResponse, error) {
	// Import the substrate set
	set, err := a.fileService.ImportSubstrateSet(filePath)
	if err != nil {
		return nil, err
	}

	// Convert to response
	return convertSubstrateSetToResponse(*set), nil
}

// convertSubstrateSetToResponse converts a domain SubstrateSet to a GUI response
func convertSubstrateSetToResponse(set domainSubstrate.SubstrateSet) *SubstrateSetResponse {
	// Map substrates
	substrates := make([]SubstrateResponse, len(set.Substrates))
	for i, sub := range set.Substrates {
		substrates[i] = SubstrateResponse{
			ID:    sub.ID,
			Name:  sub.Name,
			Color: sub.Color,
		}
	}

	// Map mixed substrates
	mixedSubstrates := make([]MixedSubstrateResponse, len(set.MixedSubstrates))
	for i, mixedSub := range set.MixedSubstrates {
		// Map substrates with percentages for this mixed substrate
		subPercentages := make([]SubstratePercentageResponse, len(mixedSub.Substrates))
		for j, sp := range mixedSub.Substrates {
			subPercentages[j] = SubstratePercentageResponse{
				SubstrateID:   sp.Substrate.ID,
				SubstrateName: sp.Substrate.Name,
				Color:         sp.Substrate.Color,
				Percentage:    sp.Percentage,
			}
		}

		mixedSubstrates[i] = MixedSubstrateResponse{
			ID:         mixedSub.ID,
			Name:       mixedSub.Name,
			Color:      mixedSub.Color,
			Substrates: subPercentages,
		}
	}

	return &SubstrateSetResponse{
		ID:              set.ID,
		Name:            set.Name,
		Substrates:      substrates,
		MixedSubstrates: mixedSubstrates,
	}
}
