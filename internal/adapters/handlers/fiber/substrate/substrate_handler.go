package substrate

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"

	handlerCommon "github.com/benjaminpina/galatea/internal/adapters/handlers/fiber/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	substratePort "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateHandler handles HTTP requests for substrates
type SubstrateHandler struct {
	substrateSvc substratePort.SubstrateService
}

// SubstrateRequest represents the request body for substrate operations
// @Description Request model for creating or updating a substrate
type SubstrateRequest struct {
	Name  string `json:"name" validate:"required" example:"Arena" description:"Name of the substrate"`
	Color string `json:"color" validate:"required" example:"#F5DEB3" description:"Color of the substrate in hex format"`
}

// SubstrateResponse represents the response body for substrate operations
// @Description Response model for substrate operations
type SubstrateResponse struct {
	ID    string `json:"id" example:"3fa85f64-5717-4562-b3fc-2c963f66afa6" description:"Unique identifier of the substrate"`
	Name  string `json:"name" example:"Arena" description:"Name of the substrate"`
	Color string `json:"color" example:"#F5DEB3" description:"Color of the substrate in hex format"`
}

// ErrorResponse represents an error response
// @Description Standard error response format
type ErrorResponse struct {
	Error string `json:"error" example:"substrate not found" description:"Error message"`
}

// PaginatedResponse represents a paginated response
// @Description Paginated list of substrates
type PaginatedResponse struct {
	Data       []SubstrateResponse               `json:"data" description:"List of substrates"`
	Pagination handlerCommon.SwaggerPaginationInfo  `json:"pagination" description:"Pagination information"`
}

// NewSubstrateHandler creates a new substrate handler
func NewSubstrateHandler(substrateSvc substratePort.SubstrateService) *SubstrateHandler {
	return &SubstrateHandler{
		substrateSvc: substrateSvc,
	}
}

// RegisterRoutes registers the substrate routes
func (h *SubstrateHandler) RegisterRoutes(app *fiber.App) {
	api := app.Group("/api/v1")
	
	substrates := api.Group("/substrates")
	substrates.Post("/", h.CreateSubstrate)
	substrates.Get("/", h.ListSubstrates)
	substrates.Get("/:id", h.GetSubstrate)
	substrates.Put("/:id", h.UpdateSubstrate)
	substrates.Delete("/:id", h.DeleteSubstrate)
}

// CreateSubstrate handles the creation of a new substrate
// @Summary Create a new substrate
// @Description Create a new substrate with the provided information
// @Tags substrates
// @Accept json
// @Produce json
// @Param substrate body SubstrateRequest true "Substrate information"
// @Success 201 {object} SubstrateResponse
// @Failure 400 {object} ErrorResponse "Invalid request body"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/substrates [post]
func (h *SubstrateHandler) CreateSubstrate(c *fiber.Ctx) error {
	var req SubstrateRequest
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Invalid request body"})
	}
	
	// Generate UUID automatically
	id := uuid.New().String()
	
	// Call service
	sub, err := h.substrateSvc.CreateSubstrate(id, req.Name, req.Color)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	// Map to response
	resp := mapSubstrateToResponse(sub)
	
	return c.Status(fiber.StatusCreated).JSON(resp)
}

// GetSubstrate handles retrieving a substrate by ID
// @Summary Get a substrate by ID
// @Description Get a substrate by its ID
// @Tags substrates
// @Accept json
// @Produce json
// @Param id path string true "Substrate ID"
// @Success 200 {object} SubstrateResponse
// @Failure 404 {object} ErrorResponse "Substrate not found"
// @Router /api/v1/substrates/{id} [get]
func (h *SubstrateHandler) GetSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	sub, err := h.substrateSvc.GetSubstrate(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
	}
	
	resp := mapSubstrateToResponse(sub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// UpdateSubstrate handles updating an existing substrate
// @Summary Update a substrate
// @Description Update a substrate with the provided information
// @Tags substrates
// @Accept json
// @Produce json
// @Param id path string true "Substrate ID"
// @Param substrate body SubstrateRequest true "Updated substrate information"
// @Success 200 {object} SubstrateResponse
// @Failure 400 {object} ErrorResponse "Invalid request body"
// @Failure 404 {object} ErrorResponse "Substrate not found"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/substrates/{id} [put]
func (h *SubstrateHandler) UpdateSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var req SubstrateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Invalid request body"})
	}
	
	sub, err := h.substrateSvc.UpdateSubstrate(id, req.Name, req.Color)
	if err != nil {
		// Check if the error is because the substrate was not found
		if err.Error() == "substrate not found" {
			return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	resp := mapSubstrateToResponse(sub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// DeleteSubstrate handles deleting a substrate
// @Summary Delete a substrate
// @Description Delete a substrate by its ID
// @Tags substrates
// @Accept json
// @Produce json
// @Param id path string true "Substrate ID"
// @Success 204 "No Content"
// @Failure 404 {object} ErrorResponse "Substrate not found"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/substrates/{id} [delete]
func (h *SubstrateHandler) DeleteSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	if err := h.substrateSvc.DeleteSubstrate(id); err != nil {
		// Check if the error is because the substrate was not found
		if err.Error() == "substrate not found" {
			return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	return c.Status(fiber.StatusNoContent).Send(nil)
}

// ListSubstrates handles retrieving all substrates with pagination
// @Summary List all substrates
// @Description Get a paginated list of all substrates
// @Tags substrates
// @Accept json
// @Produce json
// @Param page query int false "Page number (default: 1, values less than 1 will be set to 1)"
// @Param page_size query int false "Page size (default: 10, values less than 1 will be set to 10)"
// @Success 200 {object} PaginatedResponse
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Router /api/v1/substrates [get]
func (h *SubstrateHandler) ListSubstrates(c *fiber.Ctx) error {
	page, pageSize := handlerCommon.GetPaginationParams(c)
	
	subs, pagination, err := h.substrateSvc.List(page, pageSize)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}
	
	resp := make([]SubstrateResponse, len(subs))
	for i, sub := range subs {
		resp[i] = mapSubstrateToResponse(&sub)
	}
	
	return c.Status(fiber.StatusOK).JSON(PaginatedResponse{
		Data: resp,
		Pagination: handlerCommon.SwaggerPaginationInfo{
			Page:       pagination.Page,
			PageSize:   pagination.PageSize,
			TotalCount: pagination.TotalCount,
			TotalPages: pagination.TotalPages,
		},
	})
}

// Helper function to map domain model to response
func mapSubstrateToResponse(sub *substrate.Substrate) SubstrateResponse {
	return SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}
}