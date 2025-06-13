package substrate

import (
	guiCommon "github.com/benjaminpina/galatea/internal/adapters/gui/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// MixedSubstrateResponse represents a mixed substrate response for the GUI
type MixedSubstrateResponse struct {
	ID         string                       `json:"id"`
	Name       string                       `json:"name"`
	Color      string                       `json:"color"`
	Substrates []SubstratePercentageResponse `json:"substrates"`
}

// MixedSubstrateRequest represents a request to create or update a mixed substrate from the GUI
type MixedSubstrateRequest struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
}

// SubstratePercentageResponse represents a substrate with percentage response for the GUI
type SubstratePercentageResponse struct {
	SubstrateID   string  `json:"substrate_id"`
	SubstrateName string  `json:"substrate_name"`
	Color         string  `json:"color"`
	Percentage    float64 `json:"percentage"`
}

// SubstratePercentageRequest represents a request to add or update a substrate with percentage from the GUI
type SubstratePercentageRequest struct {
	SubstrateID string  `json:"substrate_id"`
	Percentage  float64 `json:"percentage"`
}

// MixedSubstratePaginatedResponse represents a paginated response of mixed substrates for the GUI
type MixedSubstratePaginatedResponse struct {
	Data       []MixedSubstrateResponse      `json:"data"`
	Pagination guiCommon.PaginationResponse  `json:"pagination"`
}

// MixedSubstrateAdapter is an adapter to expose mixed substrate operations to the GUI
type MixedSubstrateAdapter struct {
	service ports.MixedSubstrateService
}

// NewMixedSubstrateAdapter creates a new mixed substrate adapter
func NewMixedSubstrateAdapter(service ports.MixedSubstrateService) *MixedSubstrateAdapter {
	return &MixedSubstrateAdapter{
		service: service,
	}
}

// GetService returns the underlying mixed substrate service
func (a *MixedSubstrateAdapter) GetService() ports.MixedSubstrateService {
	return a.service
}

// CreateMixedSubstrate creates a new mixed substrate
func (a *MixedSubstrateAdapter) CreateMixedSubstrate(req MixedSubstrateRequest) (*MixedSubstrateResponse, error) {
	// Create the mixed substrate using the service
	mixedSub, err := a.service.CreateMixedSubstrate(req.ID, req.Name, req.Color)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// GetMixedSubstrate gets a mixed substrate by ID
func (a *MixedSubstrateAdapter) GetMixedSubstrate(id string) (*MixedSubstrateResponse, error) {
	// Get the mixed substrate using the service
	mixedSub, err := a.service.GetMixedSubstrate(id)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// UpdateMixedSubstrate updates an existing mixed substrate
func (a *MixedSubstrateAdapter) UpdateMixedSubstrate(id string, req MixedSubstrateRequest) (*MixedSubstrateResponse, error) {
	// Update the mixed substrate using the service
	mixedSub, err := a.service.UpdateMixedSubstrate(id, req.Name, req.Color)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// DeleteMixedSubstrate deletes a mixed substrate by ID
func (a *MixedSubstrateAdapter) DeleteMixedSubstrate(id string) error {
	// Delete the mixed substrate using the service
	return a.service.DeleteMixedSubstrate(id)
}

// List gets a paginated list of mixed substrates
func (a *MixedSubstrateAdapter) List(page, pageSize int) (*MixedSubstratePaginatedResponse, error) {
	// Get paginated mixed substrates using the service
	mixedSubs, pagination, err := a.service.List(page, pageSize)
	if err != nil {
		return nil, err
	}

	// Convert to responses
	resp := make([]MixedSubstrateResponse, len(mixedSubs))
	for i, mixedSub := range mixedSubs {
		resp[i] = mapMixedSubstrateToResponse(mixedSub)
	}

	// Create paginated response
	paginatedResp := &MixedSubstratePaginatedResponse{
		Data:       resp,
		Pagination: guiCommon.MapPaginationInfo(pagination),
	}

	return paginatedResp, nil
}

// FindBySubstrateID gets a paginated list of mixed substrates that contain a specific substrate
func (a *MixedSubstrateAdapter) FindBySubstrateID(substrateID string, page, pageSize int) (*MixedSubstratePaginatedResponse, error) {
	// Get paginated mixed substrates using the service
	mixedSubs, pagination, err := a.service.FindBySubstrateID(substrateID, page, pageSize)
	if err != nil {
		return nil, err
	}

	// Convert to responses
	resp := make([]MixedSubstrateResponse, len(mixedSubs))
	for i, mixedSub := range mixedSubs {
		resp[i] = mapMixedSubstrateToResponse(mixedSub)
	}

	// Create paginated response
	paginatedResp := &MixedSubstratePaginatedResponse{
		Data:       resp,
		Pagination: guiCommon.MapPaginationInfo(pagination),
	}

	return paginatedResp, nil
}

// AddSubstrateToMix adds a substrate to a mixed substrate
func (a *MixedSubstrateAdapter) AddSubstrateToMix(mixedSubstrateID string, req SubstratePercentageRequest) (*MixedSubstrateResponse, error) {
	// Add the substrate to the mixed substrate using the service
	err := a.service.AddSubstrateToMix(mixedSubstrateID, req.SubstrateID, req.Percentage)
	if err != nil {
		return nil, err
	}

	// Get the updated mixed substrate
	mixedSub, err := a.service.GetMixedSubstrate(mixedSubstrateID)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// RemoveSubstrateFromMix removes a substrate from a mixed substrate
func (a *MixedSubstrateAdapter) RemoveSubstrateFromMix(mixedSubstrateID string, substrateID string) (*MixedSubstrateResponse, error) {
	// Remove the substrate from the mixed substrate using the service
	err := a.service.RemoveSubstrateFromMix(mixedSubstrateID, substrateID)
	if err != nil {
		return nil, err
	}

	// Get the updated mixed substrate
	mixedSub, err := a.service.GetMixedSubstrate(mixedSubstrateID)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// UpdateSubstratePercentage updates the percentage of a substrate in a mixed substrate
func (a *MixedSubstrateAdapter) UpdateSubstratePercentage(mixedSubstrateID string, req SubstratePercentageRequest) (*MixedSubstrateResponse, error) {
	// Update the percentage of the substrate in the mixed substrate using the service
	err := a.service.UpdateSubstratePercentage(mixedSubstrateID, req.SubstrateID, req.Percentage)
	if err != nil {
		return nil, err
	}

	// Get the updated mixed substrate
	mixedSub, err := a.service.GetMixedSubstrate(mixedSubstrateID)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// mapMixedSubstrateToResponse converts a MixedSubstrate to a response
func mapMixedSubstrateToResponse(mixedSub substrate.MixedSubstrate) MixedSubstrateResponse {
	resp := MixedSubstrateResponse{
		ID:         mixedSub.ID,
		Name:       mixedSub.Name,
		Color:      mixedSub.Color,
		Substrates: make([]SubstratePercentageResponse, len(mixedSub.Substrates)),
	}

	// Map substrates in the mixed substrate
	for i, subPercentage := range mixedSub.Substrates {
		resp.Substrates[i] = SubstratePercentageResponse{
			SubstrateID:   subPercentage.Substrate.ID,
			SubstrateName: subPercentage.Substrate.Name,
			Color:         subPercentage.Substrate.Color,
			Percentage:    subPercentage.Percentage,
		}
	}

	return resp
}
