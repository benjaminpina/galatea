package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/benjaminpina/galatea/internal/wire"
)

func main() {
	// Initialize application with dependency injection
	app, err := wire.InitializeAPI()
	if err != nil {
		log.Fatalf("Failed to initialize application: %v", err)
	}
	defer app.Database.Close()

	// Setup API routes and middleware
	if err := wire.SetupAPI(app); err != nil {
		log.Fatalf("Failed to setup API: %v", err)
	}

	// Start server in a goroutine
	go func() {
		port := app.Config.ServerPort
		if err := app.App.Listen(":" + port); err != nil {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	log.Printf("Server started on http://localhost:%s", app.Config.ServerPort)

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")
	if err := app.App.Shutdown(); err != nil {
		log.Fatalf("Server shutdown failed: %v", err)
	}
	log.Println("Server gracefully stopped")
}
