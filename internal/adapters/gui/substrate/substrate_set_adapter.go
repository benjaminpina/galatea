package substrate

import (
	guiCommon "github.com/benjaminpina/galatea/internal/adapters/gui/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateSetResponse represents a substrate set response for the GUI
type SubstrateSetResponse struct {
	ID              string                  `json:"id"`
	Name            string                  `json:"name"`
	Substrates      []SubstrateResponse     `json:"substrates"`
	MixedSubstrates []MixedSubstrateResponse `json:"mixed_substrates"`
}

// SubstrateSetRequest represents a request to create or update a substrate set from the GUI
type SubstrateSetRequest struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// SubstrateSetPaginatedResponse represents a paginated response of substrate sets for the GUI
type SubstrateSetPaginatedResponse struct {
	Data       []SubstrateSetResponse      `json:"data"`
	Pagination guiCommon.PaginationResponse `json:"pagination"`
}

// SubstrateSetAdapter is an adapter to expose substrate set operations to the GUI
type SubstrateSetAdapter struct {
	service ports.SubstrateSetService
}

// NewSubstrateSetAdapter creates a new substrate set adapter
func NewSubstrateSetAdapter(service ports.SubstrateSetService) *SubstrateSetAdapter {
	return &SubstrateSetAdapter{
		service: service,
	}
}

// CreateSubstrateSet creates a new substrate set
func (a *SubstrateSetAdapter) CreateSubstrateSet(req SubstrateSetRequest) (*SubstrateSetResponse, error) {
	// Create the substrate set using the service
	set, err := a.service.CreateSubstrateSet(req.ID, req.Name)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapSubstrateSetToResponse(*set)
	return &resp, nil
}

// GetSubstrateSet gets a substrate set by ID
func (a *SubstrateSetAdapter) GetSubstrateSet(id string) (*SubstrateSetResponse, error) {
	// Get the substrate set using the service
	set, err := a.service.GetSubstrateSet(id)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapSubstrateSetToResponse(*set)
	return &resp, nil
}

// UpdateSubstrateSet updates an existing substrate set
func (a *SubstrateSetAdapter) UpdateSubstrateSet(id string, req SubstrateSetRequest) (*SubstrateSetResponse, error) {
	// Update the substrate set using the service
	set, err := a.service.UpdateSubstrateSet(id, req.Name)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapSubstrateSetToResponse(*set)
	return &resp, nil
}

// DeleteSubstrateSet deletes a substrate set by ID
func (a *SubstrateSetAdapter) DeleteSubstrateSet(id string) error {
	// Delete the substrate set using the service
	return a.service.DeleteSubstrateSet(id)
}

// List gets a paginated list of substrate sets
func (a *SubstrateSetAdapter) List(page, pageSize int) (*SubstrateSetPaginatedResponse, error) {
	// Get paginated substrate sets using the service
	sets, pagination, err := a.service.List(page, pageSize)
	if err != nil {
		return nil, err
	}

	// Convert to responses
	resp := make([]SubstrateSetResponse, len(sets))
	for i, set := range sets {
		resp[i] = mapSubstrateSetToResponse(set)
	}

	// Create paginated response
	paginatedResp := &SubstrateSetPaginatedResponse{
		Data:       resp,
		Pagination: guiCommon.MapPaginationInfo(pagination),
	}

	return paginatedResp, nil
}

// mapSubstrateSetToResponse converts a SubstrateSet to a response
func mapSubstrateSetToResponse(set substrate.SubstrateSet) SubstrateSetResponse {
	resp := SubstrateSetResponse{
		ID:              set.ID,
		Name:            set.Name,
		Substrates:      make([]SubstrateResponse, len(set.Substrates)),
		MixedSubstrates: make([]MixedSubstrateResponse, len(set.MixedSubstrates)),
	}

	// Map substrates
	for i, sub := range set.Substrates {
		resp.Substrates[i] = SubstrateResponse{
			ID:    sub.ID,
			Name:  sub.Name,
			Color: sub.Color,
		}
	}

	// Map mixed substrates
	for i, mixedSub := range set.MixedSubstrates {
		mixedResp := MixedSubstrateResponse{
			ID:         mixedSub.ID,
			Name:       mixedSub.Name,
			Color:      mixedSub.Color,
			Substrates: make([]SubstratePercentageResponse, len(mixedSub.Substrates)),
		}

		// Map substrates in the mixed substrate
		for j, subPercentage := range mixedSub.Substrates {
			mixedResp.Substrates[j] = SubstratePercentageResponse{
				SubstrateID:   subPercentage.Substrate.ID,
				SubstrateName: subPercentage.Substrate.Name,
				Color:         subPercentage.Substrate.Color,
				Percentage:    subPercentage.Percentage,
			}
		}

		resp.MixedSubstrates[i] = mixedResp
	}

	return resp
}
