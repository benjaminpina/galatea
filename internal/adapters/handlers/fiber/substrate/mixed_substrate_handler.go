package substrate

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	
	handlerCommon "github.com/benjaminpina/galatea/internal/adapters/handlers/fiber/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	substratePort "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// MixedSubstrateHandler handles HTTP requests for mixed substrates
type MixedSubstrateHandler struct {
	mixedSubstrateSvc substratePort.MixedSubstrateService
}

// SubstratePercentageRequest represents a substrate with its percentage in a request
type SubstratePercentageRequest struct {
	SubstrateID string  `json:"substrate_id" validate:"required"`
	Percentage  float64 `json:"percentage" validate:"required,gt=0,lte=100"`
}

// MixedSubstrateRequest represents the request body for mixed substrate operations
type MixedSubstrateRequest struct {
	Name  string `json:"name" validate:"required"`
	Color string `json:"color" validate:"required"`
}

// SubstratePercentageResponse represents a substrate with its percentage in a response
type SubstratePercentageResponse struct {
	SubstrateID   string  `json:"substrate_id"`
	SubstrateName string  `json:"substrate_name"`
	Color         string  `json:"color"`
	Percentage    float64 `json:"percentage"`
}

// MixedSubstrateResponse represents the response body for mixed substrate operations
type MixedSubstrateResponse struct {
	ID              string                       `json:"id"`
	Name            string                       `json:"name"`
	Color           string                       `json:"color"`
	Substrates      []SubstratePercentageResponse `json:"substrates"`
	TotalPercentage float64                      `json:"total_percentage"`
}

// PaginationInfo represents pagination information for Swagger documentation
type PaginationInfo struct {
	Page       int `json:"page" example:"1" description:"Current page number"`
	PageSize   int `json:"page_size" example:"10" description:"Number of items per page"`
	TotalCount int `json:"total_count" example:"100" description:"Total number of items"`
	TotalPages int `json:"total_pages" example:"10" description:"Total number of pages"`
}

// MixedSubstratePaginatedResponse represents a paginated response for mixed substrates
// @Description Paginated list of mixed substrates
type MixedSubstratePaginatedResponse struct {
	Data       []MixedSubstrateResponse `json:"data" description:"List of mixed substrates"`
	Pagination PaginationInfo `json:"pagination" description:"Pagination information"`
}

// NewMixedSubstrateHandler creates a new mixed substrate handler
func NewMixedSubstrateHandler(mixedSubstrateSvc substratePort.MixedSubstrateService) *MixedSubstrateHandler {
	return &MixedSubstrateHandler{
		mixedSubstrateSvc: mixedSubstrateSvc,
	}
}

// RegisterRoutes registers the mixed substrate routes
func (h *MixedSubstrateHandler) RegisterRoutes(app *fiber.App) {
	api := app.Group("/api/v1")
	
	mixedSubstrates := api.Group("/mixed-substrates")
	mixedSubstrates.Post("/", h.CreateMixedSubstrate)
	mixedSubstrates.Get("/", h.ListMixedSubstrates)
	mixedSubstrates.Get("/:id", h.GetMixedSubstrate)
	mixedSubstrates.Put("/:id", h.UpdateMixedSubstrate)
	mixedSubstrates.Delete("/:id", h.DeleteMixedSubstrate)
	
	// Substrate percentage operations
	mixedSubstrates.Post("/:id/substrates", h.AddSubstrateToMix)
	mixedSubstrates.Delete("/:id/substrates/:substrate_id", h.RemoveSubstrateFromMix)
	mixedSubstrates.Put("/:id/substrates/:substrate_id", h.UpdateSubstratePercentage)
}

// mapMixedSubstrateToResponse maps a domain mixed substrate to a response object
func mapMixedSubstrateToResponse(ms *substrate.MixedSubstrate) MixedSubstrateResponse {
	substrates := make([]SubstratePercentageResponse, len(ms.Substrates))
	for i, sp := range ms.Substrates {
		substrates[i] = SubstratePercentageResponse{
			SubstrateID:   sp.Substrate.ID,
			SubstrateName: sp.Substrate.Name,
			Color:         sp.Substrate.Color,
			Percentage:    sp.Percentage,
		}
	}
	
	return MixedSubstrateResponse{
		ID:              ms.ID,
		Name:            ms.Name,
		Color:           ms.Color,
		Substrates:      substrates,
		TotalPercentage: ms.TotalPercentage(),
	}
}

// CreateMixedSubstrate handles the creation of a new mixed substrate
// @Summary Create a new mixed substrate
// @Description Create a new mixed substrate with the provided information
// @Tags mixed-substrates
// @Accept json
// @Produce json
// @Param mixed_substrate body MixedSubstrateRequest true "Mixed substrate information"
// @Success 201 {object} MixedSubstrateResponse
// @Failure 400 {object} ErrorResponse "Invalid request body"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/mixed-substrates [post]
func (h *MixedSubstrateHandler) CreateMixedSubstrate(c *fiber.Ctx) error {
	var req MixedSubstrateRequest
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Invalid request body"})
	}
	
	// Generate UUID automatically
	id := uuid.New().String()
	
	// Call service
	mixedSub, err := h.mixedSubstrateSvc.CreateMixedSubstrate(id, req.Name, req.Color)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	// Map to response
	resp := mapMixedSubstrateToResponse(mixedSub)
	
	return c.Status(fiber.StatusCreated).JSON(resp)
}

// GetMixedSubstrate handles retrieving a mixed substrate by ID
// @Summary Get a mixed substrate
// @Description Get a mixed substrate by its ID
// @Tags mixed-substrates
// @Accept json
// @Produce json
// @Param id path string true "Mixed substrate ID"
// @Success 200 {object} MixedSubstrateResponse
// @Failure 404 {object} ErrorResponse "Mixed substrate not found"
// @Router /api/v1/mixed-substrates/{id} [get]
func (h *MixedSubstrateHandler) GetMixedSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	mixedSub, err := h.mixedSubstrateSvc.GetMixedSubstrate(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
	}
	
	resp := mapMixedSubstrateToResponse(mixedSub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// UpdateMixedSubstrate handles updating an existing mixed substrate
// @Summary Update a mixed substrate
// @Description Update a mixed substrate with the provided information
// @Tags mixed-substrates
// @Accept json
// @Produce json
// @Param id path string true "Mixed substrate ID"
// @Param mixed_substrate body MixedSubstrateRequest true "Updated mixed substrate information"
// @Success 200 {object} MixedSubstrateResponse
// @Failure 400 {object} ErrorResponse "Invalid request body"
// @Failure 404 {object} ErrorResponse "Mixed substrate not found"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/mixed-substrates/{id} [put]
func (h *MixedSubstrateHandler) UpdateMixedSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var req MixedSubstrateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Invalid request body"})
	}
	
	mixedSub, err := h.mixedSubstrateSvc.UpdateMixedSubstrate(id, req.Name, req.Color)
	if err != nil {
		// Check if the error is because the mixed substrate was not found
		if err.Error() == "mixed substrate not found" {
			return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	resp := mapMixedSubstrateToResponse(mixedSub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// DeleteMixedSubstrate handles deleting a mixed substrate
// @Summary Delete a mixed substrate
// @Description Delete a mixed substrate by its ID
// @Tags mixed-substrates
// @Accept json
// @Produce json
// @Param id path string true "Mixed substrate ID"
// @Success 204 "No Content"
// @Failure 404 {object} ErrorResponse "Mixed substrate not found"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/mixed-substrates/{id} [delete]
func (h *MixedSubstrateHandler) DeleteMixedSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	if err := h.mixedSubstrateSvc.DeleteMixedSubstrate(id); err != nil {
		// Check if the error is because the mixed substrate was not found
		if err.Error() == "mixed substrate not found" {
			return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	return c.Status(fiber.StatusNoContent).Send(nil)
}

// ListMixedSubstrates handles listing all mixed substrates with pagination
// @Summary List all mixed substrates
// @Description Get a paginated list of all mixed substrates
// @Tags mixed-substrates
// @Accept json
// @Produce json
// @Param page query int false "Page number (default: 1, values less than 1 will be set to 1)"
// @Param page_size query int false "Page size (default: 10, values less than 1 will be set to 10)"
// @Success 200 {object} MixedSubstratePaginatedResponse
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/mixed-substrates [get]
func (h *MixedSubstrateHandler) ListMixedSubstrates(c *fiber.Ctx) error {
	page, pageSize := handlerCommon.GetPaginationParams(c)
	
	mixedSubs, pagination, err := h.mixedSubstrateSvc.List(page, pageSize)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	// Map to response
	resp := make([]MixedSubstrateResponse, len(mixedSubs))
	for i, ms := range mixedSubs {
		msCopy := ms // Create a copy to avoid issues with the pointer
		resp[i] = mapMixedSubstrateToResponse(&msCopy)
	}
	
	return c.JSON(MixedSubstratePaginatedResponse{
		Data: resp,
		Pagination: PaginationInfo{
			Page:       pagination.Page,
			PageSize:   pagination.PageSize,
			TotalCount: pagination.TotalCount,
			TotalPages: pagination.TotalPages,
		},
	})
}

// AddSubstrateToMix handles adding a substrate to a mixed substrate
// @Summary Add a substrate to a mixed substrate
// @Description Add a substrate with a percentage to a mixed substrate
// @Tags mixed-substrates
// @Accept json
// @Produce json
// @Param id path string true "Mixed substrate ID"
// @Param substrate body SubstratePercentageRequest true "Substrate and percentage information"
// @Success 200 {object} MixedSubstrateResponse
// @Failure 400 {object} ErrorResponse "Invalid request body"
// @Failure 404 {object} ErrorResponse "Mixed substrate or substrate not found"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/mixed-substrates/{id}/substrates [post]
func (h *MixedSubstrateHandler) AddSubstrateToMix(c *fiber.Ctx) error {
	mixID := c.Params("id")
	
	var req SubstratePercentageRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Invalid request body"})
	}
	
	if err := h.mixedSubstrateSvc.AddSubstrateToMix(mixID, req.SubstrateID, req.Percentage); err != nil {
		// Check if the error is because the mixed substrate or substrate was not found
		if err.Error() == "mixed substrate not found" || err.Error() == "substrate not found" {
			return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
		}
		// Check if the error is because the substrate already exists or exceeds max percentage
		if err.Error() == "substrate already exists in the mix" || err.Error() == "total percentage exceeds 100%" {
			return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: err.Error()})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	// Get the updated mixed substrate
	mixedSub, err := h.mixedSubstrateSvc.GetMixedSubstrate(mixID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	resp := mapMixedSubstrateToResponse(mixedSub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// RemoveSubstrateFromMix handles removing a substrate from a mixed substrate
// @Summary Remove a substrate from a mixed substrate
// @Description Remove a substrate from a mixed substrate
// @Tags mixed-substrates
// @Accept json
// @Produce json
// @Param id path string true "Mixed substrate ID"
// @Param substrate_id path string true "Substrate ID"
// @Success 200 {object} MixedSubstrateResponse
// @Failure 404 {object} ErrorResponse "Mixed substrate, substrate, or substrate not in mix not found"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/mixed-substrates/{id}/substrates/{substrate_id} [delete]
func (h *MixedSubstrateHandler) RemoveSubstrateFromMix(c *fiber.Ctx) error {
	mixID := c.Params("id")
	substrateID := c.Params("substrate_id")
	
	if err := h.mixedSubstrateSvc.RemoveSubstrateFromMix(mixID, substrateID); err != nil {
		// Check if the error is because the mixed substrate, substrate, or substrate not in mix was not found
		if err.Error() == "mixed substrate not found" || err.Error() == "substrate not found" || err.Error() == "substrate not found in the mix" {
			return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	// Get the updated mixed substrate
	mixedSub, err := h.mixedSubstrateSvc.GetMixedSubstrate(mixID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	resp := mapMixedSubstrateToResponse(mixedSub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// UpdateSubstratePercentage handles updating the percentage of a substrate in a mixed substrate
// @Summary Update substrate percentage
// @Description Update the percentage of a substrate in a mixed substrate
// @Tags mixed-substrates
// @Accept json
// @Produce json
// @Param id path string true "Mixed substrate ID"
// @Param substrate_id path string true "Substrate ID"
// @Param percentage body SubstratePercentageRequest true "New percentage information"
// @Success 200 {object} MixedSubstrateResponse
// @Failure 400 {object} ErrorResponse "Invalid request body or percentage"
// @Failure 404 {object} ErrorResponse "Mixed substrate, substrate, or substrate not in mix not found"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/mixed-substrates/{id}/substrates/{substrate_id} [put]
func (h *MixedSubstrateHandler) UpdateSubstratePercentage(c *fiber.Ctx) error {
	mixID := c.Params("id")
	substrateID := c.Params("substrate_id")
	
	var req SubstratePercentageRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Invalid request body"})
	}
	
	// Validate that the substrate ID in the path matches the one in the request
	if substrateID != req.SubstrateID {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Substrate ID in path must match substrate ID in request body"})
	}
	
	if err := h.mixedSubstrateSvc.UpdateSubstratePercentage(mixID, substrateID, req.Percentage); err != nil {
		// Check if the error is because the mixed substrate, substrate, or substrate not in mix was not found
		if err.Error() == "mixed substrate not found" || err.Error() == "substrate not found" || err.Error() == "substrate not found in the mix" {
			return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
		}
		// Check if the error is because the percentage is invalid
		if err.Error() == "total percentage exceeds 100%" || err.Error() == "percentage must be positive" {
			return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: err.Error()})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	// Get the updated mixed substrate
	mixedSub, err := h.mixedSubstrateSvc.GetMixedSubstrate(mixID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	resp := mapMixedSubstrateToResponse(mixedSub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}
