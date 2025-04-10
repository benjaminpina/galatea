package main

import (
	"context"
	"log"

	"github.com/benjaminpina/galatea/internal/wire"
)

// App struct
type App struct {
	ctx context.Context
}

// NewApp creates a new App application struct
func NewApp() *App {
	// Inicializar la aplicación GUI con inyección de dependencias
	_, err := wire.InitializeGUI()
	if err != nil {
		log.Fatalf("Failed to initialize GUI application: %v", err)
	}

	return &App{
		ctx: context.Background(),
	}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}
