package main

import (
	"context"
	"log"

	guiadapters "github.com/benjaminpina/galatea/internal/adapters/gui/substrate"
	"github.com/benjaminpina/galatea/internal/wire"
)

// App struct
type App struct {
	ctx                   context.Context
	substrateAdapter      *guiadapters.SubstrateAdapter
	mixedSubstrateAdapter *guiadapters.MixedSubstrateAdapter
	substrateSetAdapter   *guiadapters.SubstrateSetAdapter
}

// NewApp creates a new App application struct
func NewApp() *App {
	// Inicializar la aplicación GUI con inyección de dependencias
	guiApp, err := wire.InitializeGUI()
	if err != nil {
		log.Fatalf("Failed to initialize GUI application: %v", err)
	}

	return &App{
		substrateAdapter:      guiApp.SubstrateAdapter,
		mixedSubstrateAdapter: guiApp.MixedSubstrateAdapter,
		substrateSetAdapter:   guiApp.SubstrateSetAdapter,
	}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// Substrate CRUD Operations

// CreateSubstrate crea un nuevo sustrato
func (a *App) CreateSubstrate(req guiadapters.SubstrateRequest) (*guiadapters.SubstrateResponse, error) {
	return a.substrateAdapter.CreateSubstrate(req)
}

// GetSubstrate obtiene un sustrato por ID
func (a *App) GetSubstrate(id string) (*guiadapters.SubstrateResponse, error) {
	return a.substrateAdapter.GetSubstrate(id)
}

// UpdateSubstrate actualiza un sustrato existente
func (a *App) UpdateSubstrate(id string, req guiadapters.SubstrateRequest) (*guiadapters.SubstrateResponse, error) {
	return a.substrateAdapter.UpdateSubstrate(id, req)
}

// DeleteSubstrate elimina un sustrato por ID
func (a *App) DeleteSubstrate(id string) error {
	return a.substrateAdapter.DeleteSubstrate(id)
}

// ListSubstrates obtiene todos los sustratos
func (a *App) ListSubstrates() ([]guiadapters.SubstrateResponse, error) {
	return a.substrateAdapter.ListSubstrates()
}

// MixedSubstrate CRUD Operations

// CreateMixedSubstrate crea un nuevo sustrato mixto
func (a *App) CreateMixedSubstrate(req guiadapters.MixedSubstrateRequest) (*guiadapters.MixedSubstrateResponse, error) {
	return a.mixedSubstrateAdapter.CreateMixedSubstrate(req)
}

// GetMixedSubstrate obtiene un sustrato mixto por ID
func (a *App) GetMixedSubstrate(id string) (*guiadapters.MixedSubstrateResponse, error) {
	return a.mixedSubstrateAdapter.GetMixedSubstrate(id)
}

// UpdateMixedSubstrate actualiza un sustrato mixto existente
func (a *App) UpdateMixedSubstrate(id string, req guiadapters.MixedSubstrateRequest) (*guiadapters.MixedSubstrateResponse, error) {
	return a.mixedSubstrateAdapter.UpdateMixedSubstrate(id, req)
}

// DeleteMixedSubstrate elimina un sustrato mixto por ID
func (a *App) DeleteMixedSubstrate(id string) error {
	return a.mixedSubstrateAdapter.DeleteMixedSubstrate(id)
}

// ListMixedSubstrates obtiene todos los sustratos mixtos
func (a *App) ListMixedSubstrates() ([]guiadapters.MixedSubstrateResponse, error) {
	return a.mixedSubstrateAdapter.ListMixedSubstrates()
}

// AddSubstrateToMix agrega un sustrato a un sustrato mixto
func (a *App) AddSubstrateToMix(mixedSubstrateID string, req guiadapters.SubstratePercentageRequest) (*guiadapters.MixedSubstrateResponse, error) {
	return a.mixedSubstrateAdapter.AddSubstrateToMix(mixedSubstrateID, req)
}

// RemoveSubstrateFromMix elimina un sustrato de un sustrato mixto
func (a *App) RemoveSubstrateFromMix(mixedSubstrateID string, substrateID string) (*guiadapters.MixedSubstrateResponse, error) {
	return a.mixedSubstrateAdapter.RemoveSubstrateFromMix(mixedSubstrateID, substrateID)
}

// UpdateSubstratePercentage actualiza el porcentaje de un sustrato en un sustrato mixto
func (a *App) UpdateSubstratePercentage(mixedSubstrateID string, req guiadapters.SubstratePercentageRequest) (*guiadapters.MixedSubstrateResponse, error) {
	return a.mixedSubstrateAdapter.UpdateSubstratePercentage(mixedSubstrateID, req)
}

// SubstrateSet CRUD Operations

// CreateSubstrateSet crea un nuevo conjunto de sustratos
func (a *App) CreateSubstrateSet(req guiadapters.SubstrateSetRequest) (*guiadapters.SubstrateSetResponse, error) {
	return a.substrateSetAdapter.CreateSubstrateSet(req)
}

// GetSubstrateSet obtiene un conjunto de sustratos por ID
func (a *App) GetSubstrateSet(id string) (*guiadapters.SubstrateSetResponse, error) {
	return a.substrateSetAdapter.GetSubstrateSet(id)
}

// UpdateSubstrateSet actualiza un conjunto de sustratos existente
func (a *App) UpdateSubstrateSet(id string, req guiadapters.SubstrateSetRequest) (*guiadapters.SubstrateSetResponse, error) {
	return a.substrateSetAdapter.UpdateSubstrateSet(id, req)
}

// DeleteSubstrateSet elimina un conjunto de sustratos por ID
func (a *App) DeleteSubstrateSet(id string) error {
	return a.substrateSetAdapter.DeleteSubstrateSet(id)
}

// ListSubstrateSets obtiene todos los conjuntos de sustratos
func (a *App) ListSubstrateSets() ([]guiadapters.SubstrateSetResponse, error) {
	return a.substrateSetAdapter.ListSubstrateSets()
}
