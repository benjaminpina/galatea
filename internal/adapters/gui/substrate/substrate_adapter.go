package substrate

import (
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateResponse representa la respuesta de un sustrato para la GUI
type SubstrateResponse struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
}

// SubstrateRequest representa una solicitud para crear o actualizar un sustrato desde la GUI
type SubstrateRequest struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
}

// SubstrateAdapter es un adaptador para exponer operaciones de sustratos a la GUI
type SubstrateAdapter struct {
	service ports.SubstrateService
}

// NewSubstrateAdapter crea un nuevo adaptador de sustratos
func NewSubstrateAdapter(service ports.SubstrateService) *SubstrateAdapter {
	return &SubstrateAdapter{
		service: service,
	}
}

// CreateSubstrate crea un nuevo sustrato
func (a *SubstrateAdapter) CreateSubstrate(req SubstrateRequest) (*SubstrateResponse, error) {
	// Crear el sustrato usando el servicio
	sub, err := a.service.CreateSubstrate(req.ID, req.Name, req.Color)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := &SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}

	return resp, nil
}

// GetSubstrate obtiene un sustrato por ID
func (a *SubstrateAdapter) GetSubstrate(id string) (*SubstrateResponse, error) {
	// Obtener el sustrato usando el servicio
	sub, err := a.service.GetSubstrate(id)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := &SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}

	return resp, nil
}

// UpdateSubstrate actualiza un sustrato existente
func (a *SubstrateAdapter) UpdateSubstrate(id string, req SubstrateRequest) (*SubstrateResponse, error) {
	// Actualizar el sustrato usando el servicio
	sub, err := a.service.UpdateSubstrate(id, req.Name, req.Color)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := &SubstrateResponse{
		ID:    sub.ID,
		Name:  sub.Name,
		Color: sub.Color,
	}

	return resp, nil
}

// DeleteSubstrate elimina un sustrato por ID
func (a *SubstrateAdapter) DeleteSubstrate(id string) error {
	// Eliminar el sustrato usando el servicio
	return a.service.DeleteSubstrate(id)
}

// ListSubstrates obtiene todos los sustratos
func (a *SubstrateAdapter) ListSubstrates() ([]SubstrateResponse, error) {
	// Obtener todos los sustratos usando el servicio
	subs, err := a.service.ListSubstrates()
	if err != nil {
		return nil, err
	}

	// Convertir a respuestas
	resp := make([]SubstrateResponse, len(subs))
	for i, sub := range subs {
		resp[i] = SubstrateResponse{
			ID:    sub.ID,
			Name:  sub.Name,
			Color: sub.Color,
		}
	}

	return resp, nil
}
