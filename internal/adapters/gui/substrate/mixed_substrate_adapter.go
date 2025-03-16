package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// MixedSubstrateResponse representa la respuesta de un sustrato mixto para la GUI
type MixedSubstrateResponse struct {
	ID         string                       `json:"id"`
	Name       string                       `json:"name"`
	Color      string                       `json:"color"`
	Substrates []SubstratePercentageResponse `json:"substrates"`
}

// MixedSubstrateRequest representa una solicitud para crear o actualizar un sustrato mixto desde la GUI
type MixedSubstrateRequest struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
}

// SubstratePercentageResponse representa la respuesta de un sustrato con porcentaje para la GUI
type SubstratePercentageResponse struct {
	SubstrateID   string  `json:"substrate_id"`
	SubstrateName string  `json:"substrate_name"`
	Color         string  `json:"color"`
	Percentage    float64 `json:"percentage"`
}

// SubstratePercentageRequest representa una solicitud para agregar o actualizar un sustrato con porcentaje desde la GUI
type SubstratePercentageRequest struct {
	SubstrateID string  `json:"substrate_id"`
	Percentage  float64 `json:"percentage"`
}

// MixedSubstrateAdapter es un adaptador para exponer operaciones de sustratos mixtos a la GUI
type MixedSubstrateAdapter struct {
	service ports.MixedSubstrateService
}

// NewMixedSubstrateAdapter crea un nuevo adaptador de sustratos mixtos
func NewMixedSubstrateAdapter(service ports.MixedSubstrateService) *MixedSubstrateAdapter {
	return &MixedSubstrateAdapter{
		service: service,
	}
}

// CreateMixedSubstrate crea un nuevo sustrato mixto
func (a *MixedSubstrateAdapter) CreateMixedSubstrate(req MixedSubstrateRequest) (*MixedSubstrateResponse, error) {
	// Crear el sustrato mixto usando el servicio
	mixedSub, err := a.service.CreateMixedSubstrate(req.ID, req.Name, req.Color)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// GetMixedSubstrate obtiene un sustrato mixto por ID
func (a *MixedSubstrateAdapter) GetMixedSubstrate(id string) (*MixedSubstrateResponse, error) {
	// Obtener el sustrato mixto usando el servicio
	mixedSub, err := a.service.GetMixedSubstrate(id)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// UpdateMixedSubstrate actualiza un sustrato mixto existente
func (a *MixedSubstrateAdapter) UpdateMixedSubstrate(id string, req MixedSubstrateRequest) (*MixedSubstrateResponse, error) {
	// Actualizar el sustrato mixto usando el servicio
	mixedSub, err := a.service.UpdateMixedSubstrate(id, req.Name, req.Color)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// DeleteMixedSubstrate elimina un sustrato mixto por ID
func (a *MixedSubstrateAdapter) DeleteMixedSubstrate(id string) error {
	// Eliminar el sustrato mixto usando el servicio
	return a.service.DeleteMixedSubstrate(id)
}

// ListMixedSubstrates obtiene todos los sustratos mixtos
func (a *MixedSubstrateAdapter) ListMixedSubstrates() ([]MixedSubstrateResponse, error) {
	// Obtener todos los sustratos mixtos usando el servicio
	mixedSubs, err := a.service.ListMixedSubstrates()
	if err != nil {
		return nil, err
	}

	// Convertir a respuestas
	resp := make([]MixedSubstrateResponse, len(mixedSubs))
	for i, mixedSub := range mixedSubs {
		resp[i] = mapMixedSubstrateToResponse(mixedSub)
	}

	return resp, nil
}

// AddSubstrateToMix agrega un sustrato a un sustrato mixto
func (a *MixedSubstrateAdapter) AddSubstrateToMix(mixedSubstrateID string, req SubstratePercentageRequest) (*MixedSubstrateResponse, error) {
	// Agregar el sustrato al sustrato mixto usando el servicio
	err := a.service.AddSubstrateToMix(mixedSubstrateID, req.SubstrateID, req.Percentage)
	if err != nil {
		return nil, err
	}

	// Obtener el sustrato mixto actualizado
	mixedSub, err := a.service.GetMixedSubstrate(mixedSubstrateID)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// RemoveSubstrateFromMix elimina un sustrato de un sustrato mixto
func (a *MixedSubstrateAdapter) RemoveSubstrateFromMix(mixedSubstrateID string, substrateID string) (*MixedSubstrateResponse, error) {
	// Eliminar el sustrato del sustrato mixto usando el servicio
	err := a.service.RemoveSubstrateFromMix(mixedSubstrateID, substrateID)
	if err != nil {
		return nil, err
	}

	// Obtener el sustrato mixto actualizado
	mixedSub, err := a.service.GetMixedSubstrate(mixedSubstrateID)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// UpdateSubstratePercentage actualiza el porcentaje de un sustrato en un sustrato mixto
func (a *MixedSubstrateAdapter) UpdateSubstratePercentage(mixedSubstrateID string, req SubstratePercentageRequest) (*MixedSubstrateResponse, error) {
	// Actualizar el porcentaje del sustrato en el sustrato mixto usando el servicio
	err := a.service.UpdateSubstratePercentage(mixedSubstrateID, req.SubstrateID, req.Percentage)
	if err != nil {
		return nil, err
	}

	// Obtener el sustrato mixto actualizado
	mixedSub, err := a.service.GetMixedSubstrate(mixedSubstrateID)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapMixedSubstrateToResponse(*mixedSub)
	return &resp, nil
}

// mapMixedSubstrateToResponse convierte un MixedSubstrate a una respuesta
func mapMixedSubstrateToResponse(mixedSub substrate.MixedSubstrate) MixedSubstrateResponse {
	resp := MixedSubstrateResponse{
		ID:         mixedSub.ID,
		Name:       mixedSub.Name,
		Color:      mixedSub.Color,
		Substrates: make([]SubstratePercentageResponse, len(mixedSub.Substrates)),
	}

	// Mapear sustratos en el sustrato mixto
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
