package substrate

import (
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
	ports "github.com/benjaminpina/galatea/internal/core/ports/substrate"
)

// SubstrateSetResponse representa la respuesta de un conjunto de sustratos para la GUI
type SubstrateSetResponse struct {
	ID              string                  `json:"id"`
	Name            string                  `json:"name"`
	Substrates      []SubstrateResponse     `json:"substrates"`
	MixedSubstrates []MixedSubstrateResponse `json:"mixed_substrates"`
}

// SubstrateSetRequest representa una solicitud para crear o actualizar un conjunto de sustratos desde la GUI
type SubstrateSetRequest struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// SubstrateSetAdapter es un adaptador para exponer operaciones de conjuntos de sustratos a la GUI
type SubstrateSetAdapter struct {
	service ports.SubstrateSetService
}

// NewSubstrateSetAdapter crea un nuevo adaptador de conjuntos de sustratos
func NewSubstrateSetAdapter(service ports.SubstrateSetService) *SubstrateSetAdapter {
	return &SubstrateSetAdapter{
		service: service,
	}
}

// CreateSubstrateSet crea un nuevo conjunto de sustratos
func (a *SubstrateSetAdapter) CreateSubstrateSet(req SubstrateSetRequest) (*SubstrateSetResponse, error) {
	// Crear el conjunto de sustratos usando el servicio
	set, err := a.service.CreateSubstrateSet(req.ID, req.Name)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapSubstrateSetToResponse(*set)
	return &resp, nil
}

// GetSubstrateSet obtiene un conjunto de sustratos por ID
func (a *SubstrateSetAdapter) GetSubstrateSet(id string) (*SubstrateSetResponse, error) {
	// Obtener el conjunto de sustratos usando el servicio
	set, err := a.service.GetSubstrateSet(id)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapSubstrateSetToResponse(*set)
	return &resp, nil
}

// UpdateSubstrateSet actualiza un conjunto de sustratos existente
func (a *SubstrateSetAdapter) UpdateSubstrateSet(id string, req SubstrateSetRequest) (*SubstrateSetResponse, error) {
	// Actualizar el conjunto de sustratos usando el servicio
	set, err := a.service.UpdateSubstrateSet(id, req.Name)
	if err != nil {
		return nil, err
	}

	// Convertir a respuesta
	resp := mapSubstrateSetToResponse(*set)
	return &resp, nil
}

// DeleteSubstrateSet elimina un conjunto de sustratos por ID
func (a *SubstrateSetAdapter) DeleteSubstrateSet(id string) error {
	// Eliminar el conjunto de sustratos usando el servicio
	return a.service.DeleteSubstrateSet(id)
}

// ListSubstrateSets obtiene todos los conjuntos de sustratos
func (a *SubstrateSetAdapter) ListSubstrateSets() ([]SubstrateSetResponse, error) {
	// Obtener todos los conjuntos de sustratos usando el servicio
	sets, err := a.service.ListSubstrateSets()
	if err != nil {
		return nil, err
	}

	// Convertir a respuestas
	resp := make([]SubstrateSetResponse, len(sets))
	for i, set := range sets {
		resp[i] = mapSubstrateSetToResponse(set)
	}

	return resp, nil
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
