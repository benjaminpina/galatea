package substrate

import (
	"github.com/benjaminpina/galatea/internal/adapters/handlers/fiber/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// SubstrateSetRequest representa una solicitud para crear o actualizar un conjunto de sustratos
// @Description Modelo de solicitud para crear o actualizar un conjunto de sustratos
type SubstrateSetRequest struct {
	ID   string `json:"id" example:"3fa85f64-5717-4562-b3fc-2c963f66afa6" description:"Identificador único del conjunto de sustratos (opcional para creación)"`
	Name string `json:"name" example:"Arena y Tierra" description:"Nombre del conjunto de sustratos"`
}

// SubstrateSetResponse representa la respuesta de un conjunto de sustratos
// @Description Modelo de respuesta para operaciones con conjuntos de sustratos
type SubstrateSetResponse struct {
	ID              string                  `json:"id" example:"3fa85f64-5717-4562-b3fc-2c963f66afa6" description:"Identificador único del conjunto de sustratos"`
	Name            string                  `json:"name" example:"Arena y Tierra" description:"Nombre del conjunto de sustratos"`
	Substrates      []SubstrateResponse     `json:"substrates" description:"Lista de sustratos en el conjunto"`
	MixedSubstrates []MixedSubstrateResponse `json:"mixed_substrates" description:"Lista de sustratos mezclados en el conjunto"`
}

// SubstrateSetPaginatedResponse represents a paginated response for substrate sets
// @Description Respuesta paginada de conjuntos de sustratos
type SubstrateSetPaginatedResponse struct {
	Data       []SubstrateSetResponse     `json:"data" description:"Lista de conjuntos de sustratos"`
	Pagination common.PaginationResponse  `json:"pagination" description:"Información de paginación"`
}

// SubstrateSetHandler maneja las solicitudes relacionadas con conjuntos de sustratos
type SubstrateSetHandler struct {
	service ports.SubstrateSetService
}

// NewSubstrateSetHandler crea un nuevo manejador de conjuntos de sustratos
func NewSubstrateSetHandler(service ports.SubstrateSetService) *SubstrateSetHandler {
	return &SubstrateSetHandler{
		service: service,
	}
}

// RegisterRoutes registra las rutas del manejador en la aplicación Fiber
func (h *SubstrateSetHandler) RegisterRoutes(app *fiber.App) {
	api := app.Group("/api/v1/substrate-sets")

	api.Post("/", h.CreateSubstrateSet)
	api.Get("/:id", h.GetSubstrateSet)
	api.Put("/:id", h.UpdateSubstrateSet)
	api.Delete("/:id", h.DeleteSubstrateSet)
	api.Get("/", h.ListSubstrateSets)
}

// CreateSubstrateSet godoc
// @Summary Crear un nuevo conjunto de sustratos
// @Description Crea un nuevo conjunto de sustratos con los datos proporcionados
// @Tags substrate-sets
// @Accept json
// @Produce json
// @Param substrate body SubstrateSetRequest true "Datos del conjunto de sustratos"
// @Success 201 {object} SubstrateSetResponse
// @Failure 400 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /api/v1/substrate-sets [post]
func (h *SubstrateSetHandler) CreateSubstrateSet(c *fiber.Ctx) error {
	var req SubstrateSetRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Invalid request body"})
	}

	// Si no se proporciona un ID, generamos uno nuevo
	if req.ID == "" {
		req.ID = uuid.New().String()
	}

	// Crear el conjunto de sustratos
	set, err := h.service.CreateSubstrateSet(req.ID, req.Name)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}

	// Convertir a respuesta
	resp := mapSubstrateSetToResponse(*set)

	return c.Status(fiber.StatusCreated).JSON(resp)
}

// GetSubstrateSet godoc
// @Summary Obtener un conjunto de sustratos por ID
// @Description Obtiene un conjunto de sustratos por su ID
// @Tags substrate-sets
// @Accept json
// @Produce json
// @Param id path string true "ID del conjunto de sustratos"
// @Success 200 {object} SubstrateSetResponse
// @Failure 404 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /api/v1/substrate-sets/{id} [get]
func (h *SubstrateSetHandler) GetSubstrateSet(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "ID is required"})
	}

	// Obtener el conjunto de sustratos
	set, err := h.service.GetSubstrateSet(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
	}

	// Convertir a respuesta
	resp := mapSubstrateSetToResponse(*set)

	return c.Status(fiber.StatusOK).JSON(resp)
}

// UpdateSubstrateSet godoc
// @Summary Actualizar un conjunto de sustratos
// @Description Actualiza un conjunto de sustratos existente con los datos proporcionados
// @Tags substrate-sets
// @Accept json
// @Produce json
// @Param id path string true "ID del conjunto de sustratos"
// @Param substrate body SubstrateSetRequest true "Datos actualizados del conjunto de sustratos"
// @Success 200 {object} SubstrateSetResponse
// @Failure 400 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /api/v1/substrate-sets/{id} [put]
func (h *SubstrateSetHandler) UpdateSubstrateSet(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "ID is required"})
	}

	var req SubstrateSetRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "Invalid request body"})
	}

	// Actualizar el conjunto de sustratos
	set, err := h.service.UpdateSubstrateSet(id, req.Name)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
	}

	// Convertir a respuesta
	resp := mapSubstrateSetToResponse(*set)

	return c.Status(fiber.StatusOK).JSON(resp)
}

// DeleteSubstrateSet godoc
// @Summary Eliminar un conjunto de sustratos
// @Description Elimina un conjunto de sustratos por su ID
// @Tags substrate-sets
// @Accept json
// @Produce json
// @Param id path string true "ID del conjunto de sustratos"
// @Success 204 "No Content"
// @Failure 404 {object} ErrorResponse
// @Failure 500 {object} ErrorResponse
// @Router /api/v1/substrate-sets/{id} [delete]
func (h *SubstrateSetHandler) DeleteSubstrateSet(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(ErrorResponse{Error: "ID is required"})
	}

	// Eliminar el conjunto de sustratos
	err := h.service.DeleteSubstrateSet(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(ErrorResponse{Error: err.Error()})
	}

	return c.SendStatus(fiber.StatusNoContent)
}

// ListSubstrateSets godoc
// @Summary Listar todos los conjuntos de sustratos
// @Description Obtiene una lista paginada de todos los conjuntos de sustratos
// @Tags substrate-sets
// @Accept json
// @Produce json
// @Param page query int false "Número de página (default: 1, valores menores a 1 se establecerán a 1)"
// @Param page_size query int false "Tamaño de página (default: 10, valores menores a 1 se establecerán a 10)"
// @Success 200 {object} SubstrateSetPaginatedResponse
// @Failure 500 {object} ErrorResponse
// @Router /api/v1/substrate-sets [get]
func (h *SubstrateSetHandler) ListSubstrateSets(c *fiber.Ctx) error {
	// Get pagination parameters
	page, pageSize := common.GetPaginationParams(c)
	
	// Get paginated substrate sets
	sets, pagination, err := h.service.List(page, pageSize)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(ErrorResponse{Error: err.Error()})
	}

	// Map to response
	resp := make([]SubstrateSetResponse, len(sets))
	for i, set := range sets {
		resp[i] = mapSubstrateSetToResponse(set)
	}

	return c.JSON(SubstrateSetPaginatedResponse{
		Data:       resp,
		Pagination: common.MapPaginationToResponse(pagination),
	})
}

// mapSubstrateSetToResponse convierte un SubstrateSet a una respuesta
func mapSubstrateSetToResponse(set substrate.SubstrateSet) SubstrateSetResponse {
	resp := SubstrateSetResponse{
		ID:              set.ID,
		Name:            set.Name,
		Substrates:      make([]SubstrateResponse, len(set.Substrates)),
		MixedSubstrates: make([]MixedSubstrateResponse, len(set.MixedSubstrates)),
	}

	// Mapear sustratos
	for i, sub := range set.Substrates {
		resp.Substrates[i] = SubstrateResponse{
			ID:    sub.ID,
			Name:  sub.Name,
			Color: sub.Color,
		}
	}

	// Mapear sustratos mixtos
	for i, mixedSub := range set.MixedSubstrates {
		mixedResp := MixedSubstrateResponse{
			ID:         mixedSub.ID,
			Name:       mixedSub.Name,
			Color:      mixedSub.Color,
			Substrates: make([]SubstratePercentageResponse, len(mixedSub.Substrates)),
		}

		// Mapear sustratos en el sustrato mixto
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
