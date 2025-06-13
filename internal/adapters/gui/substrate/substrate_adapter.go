package substrate

import (
	guiCommon "github.com/benjaminpina/galatea/internal/adapters/gui/common"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateResponse represents a substrate response for the GUI
type SubstrateResponse struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
}

// SubstrateRequest represents a request to create or update a substrate from the GUI
type SubstrateRequest struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
}

// PaginatedResponse represents a paginated response for the GUI
type PaginatedResponse struct {
	Data       []SubstrateResponse      `json:"data"`
	Pagination guiCommon.PaginationResponse `json:"pagination"`
}

// SubstrateAdapter is an adapter to expose substrate operations to the GUI
type SubstrateAdapter struct {
	service ports.SubstrateService
}

// NewSubstrateAdapter creates a new substrate adapter
func NewSubstrateAdapter(service ports.SubstrateService) *SubstrateAdapter {
	return &SubstrateAdapter{
		service: service,
	}
}

// GetService returns the underlying substrate service
func (a *SubstrateAdapter) GetService() ports.SubstrateService {
	return a.service
}

// CreateSubstrate creates a new substrate
func (a *SubstrateAdapter) CreateSubstrate(req SubstrateRequest) (*SubstrateResponse, error) {
	// Create the substrate using the service
	sub, err := a.service.CreateSubstrate(req.ID, req.Name, req.Color)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := &SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}

	return resp, nil
}

// GetSubstrate gets a substrate by ID
func (a *SubstrateAdapter) GetSubstrate(id string) (*SubstrateResponse, error) {
	// Get the substrate using the service
	sub, err := a.service.GetSubstrate(id)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := &SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}

	return resp, nil
}

// UpdateSubstrate updates an existing substrate
func (a *SubstrateAdapter) UpdateSubstrate(id string, req SubstrateRequest) (*SubstrateResponse, error) {
	// Update the substrate using the service
	sub, err := a.service.UpdateSubstrate(id, req.Name, req.Color)
	if err != nil {
		return nil, err
	}

	// Convert to response
	resp := &SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}

	return resp, nil
}

// DeleteSubstrate deletes a substrate by ID
func (a *SubstrateAdapter) DeleteSubstrate(id string) error {
	// Delete the substrate using the service
	return a.service.DeleteSubstrate(id)
}

// List gets a paginated list of substrates
func (a *SubstrateAdapter) List(page, pageSize int) (*PaginatedResponse, error) {
	// Get the substrates using the service
	subs, pagination, err := a.service.List(page, pageSize)
	if err != nil {
		return nil, err
	}

	// Convert to response
	data := make([]SubstrateResponse, len(subs))
	for i, sub := range subs {
		data[i] = SubstrateResponse{
			ID:    sub.ID,
			Name:  sub.Name,
			Color: sub.Color,
		}
	}

	return &PaginatedResponse{
		Data: data,
		Pagination: guiCommon.MapPaginationInfo(pagination),
	}, nil
}


