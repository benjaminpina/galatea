// @title Galatea API
// @version 1.0
// @description API REST para la gestión de sustratos y mezclas para cultivos
// @termsOfService http://swagger.io/terms/
// @contact.name API Support
// @contact.email support@galatea.com
// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html
// @host localhost:2000
// @BasePath /
package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/gofiber/swagger"

	_ "github.com/benjaminpina/galatea/docs" // Import generated Swagger docs
	"github.com/benjaminpina/galatea/internal/wire"
)

// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization

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

	// Remove Swagger configuration from wire.go and add it directly here
	// Use a simple configuration without redirects
	app.App.Get("/swagger/*", swagger.New(swagger.Config{
		URL:         "/swagger/doc.json",
		DeepLinking: true,
	}))

	// Start server in a goroutine
	go func() {
		port := app.Config.ServerPort
		if err := app.App.Listen(":" + port); err != nil {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	log.Printf("Server started on http://localhost:%s", app.Config.ServerPort)
	log.Printf("Swagger documentation available at http://localhost:%s/swagger/index.html", app.Config.ServerPort)

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
