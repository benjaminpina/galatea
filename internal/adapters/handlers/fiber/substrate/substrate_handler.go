package substrate

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	substratePort "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateHandler handles HTTP requests for substrates
type SubstrateHandler struct {
	substrateSvc substratePort.SubstrateService
}

// SubstrateRequest represents the request body for substrate operations
type SubstrateRequest struct {
	ID    string `json:"id,omitempty"`
	Name  string `json:"name" validate:"required"`
	Color string `json:"color" validate:"required"`
}

// SubstrateResponse represents the response body for substrate operations
type SubstrateResponse struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
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
func (h *SubstrateHandler) CreateSubstrate(c *fiber.Ctx) error {
	var req SubstrateRequest
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}
	
	// Generate UUID if not provided
	id := req.ID
	if id == "" {
		id = uuid.New().String()
	}
	
	// Call service
	sub, err := h.substrateSvc.CreateSubstrate(id, req.Name, req.Color)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	
	// Map to response
	resp := mapSubstrateToResponse(sub)
	
	return c.Status(fiber.StatusCreated).JSON(resp)
}

// GetSubstrate handles retrieving a substrate by ID
func (h *SubstrateHandler) GetSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	sub, err := h.substrateSvc.GetSubstrate(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	
	resp := mapSubstrateToResponse(sub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// UpdateSubstrate handles updating an existing substrate
func (h *SubstrateHandler) UpdateSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var req SubstrateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}
	
	sub, err := h.substrateSvc.UpdateSubstrate(id, req.Name, req.Color)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	
	resp := mapSubstrateToResponse(sub)
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// DeleteSubstrate handles deleting a substrate
func (h *SubstrateHandler) DeleteSubstrate(c *fiber.Ctx) error {
	id := c.Params("id")
	
	if err := h.substrateSvc.DeleteSubstrate(id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	
	return c.Status(fiber.StatusNoContent).Send(nil)
}

// ListSubstrates handles retrieving all substrates
func (h *SubstrateHandler) ListSubstrates(c *fiber.Ctx) error {
	subs, err := h.substrateSvc.ListSubstrates()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	
	resp := make([]SubstrateResponse, len(subs))
	for i, sub := range subs {
		resp[i] = SubstrateResponse{
			ID:    sub.ID,
			Name:  sub.Name,
			Color: sub.Color,
		}
	}
	
	return c.Status(fiber.StatusOK).JSON(resp)
}

// Helper function to map domain model to response
func mapSubstrateToResponse(sub *substrate.Substrate) SubstrateResponse {
	return SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}
}