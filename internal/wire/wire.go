// +build wireinject

package wire

import (
	"fmt"
	"log"

	"github.com/google/wire"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"

	"github.com/benjaminpina/galatea/internal/adapters/handlers/fiber/substrate"
	"github.com/benjaminpina/galatea/internal/adapters/repositories/sqlite"
	"github.com/benjaminpina/galatea/internal/config"
	substratePort "github.com/benjaminpina/galatea/internal/core/ports/substrate"
	substrateService "github.com/benjaminpina/galatea/internal/core/services/substrate"
)

// DatabaseSet is the provider set for database connections
var DatabaseSet = wire.NewSet(
	ProvideDatabase,
)

// RepositorySet is the provider set for repositories
var RepositorySet = wire.NewSet(
	ProvideSubstrateRepository,
	wire.Bind(new(substratePort.SubstrateRepository), new(*sqlite.SubstrateRepository)),
	ProvideMixedSubstrateRepository,
	wire.Bind(new(substratePort.MixedSubstrateRepository), new(*sqlite.MixedSubstrateRepository)),
)

// ServiceSet is the provider set for services
var ServiceSet = wire.NewSet(
	ProvideSubstrateService,
	wire.Bind(new(substratePort.SubstrateService), new(*substrateService.SubstrateServiceImpl)),
	ProvideMixedSubstrateService,
	wire.Bind(new(substratePort.MixedSubstrateService), new(*substrateService.MixedSubstrateServiceImpl)),
)

// HandlerSet is the provider set for handlers
var HandlerSet = wire.NewSet(
	ProvideSubstrateHandler,
	ProvideMixedSubstrateHandler,
)

// AppSet is the provider set for the Fiber application
var AppSet = wire.NewSet(
	ProvideFiberApp,
)

// Application represents the complete application with all its dependencies
type Application struct {
	App                *fiber.App
	Config             *config.Config
	Database           *sqlite.Database
	SubstrateRepo      substratePort.SubstrateRepository
	SubstrateSvc       substratePort.SubstrateService
	SubstrateHdlr      *substrate.SubstrateHandler
	MixedSubstrateRepo substratePort.MixedSubstrateRepository
	MixedSubstrateSvc  substratePort.MixedSubstrateService
	MixedSubstrateHdlr *substrate.MixedSubstrateHandler
}

// ProvideConfig provides the application configuration
func ProvideConfig() (*config.Config, error) {
	return config.LoadConfig()
}

// ProvideDatabase provides the database connection based on the configuration
func ProvideDatabase(cfg *config.Config) (*sqlite.Database, error) {
	switch cfg.DatabaseType {
	case "sqlite":
		return sqlite.InitializeDatabase()
	// In the future, we can add more database types here
	// case "postgres":
	//     return postgres.InitializeDatabase(cfg.PostgresURL)
	default:
		return nil, fmt.Errorf("unsupported database type: %s", cfg.DatabaseType)
	}
}

// ProvideSubstrateRepository provides the substrate repository
func ProvideSubstrateRepository(db *sqlite.Database) *sqlite.SubstrateRepository {
	return sqlite.NewSubstrateRepository(db)
}

// ProvideMixedSubstrateRepository provides the mixed substrate repository
func ProvideMixedSubstrateRepository(db *sqlite.Database) *sqlite.MixedSubstrateRepository {
	return sqlite.NewMixedSubstrateRepository(db)
}

// ProvideSubstrateService provides the substrate service
func ProvideSubstrateService(repo substratePort.SubstrateRepository) *substrateService.SubstrateServiceImpl {
	return substrateService.NewSubstrateService(repo)
}

// ProvideMixedSubstrateService provides the mixed substrate service
func ProvideMixedSubstrateService(repo substratePort.MixedSubstrateRepository, substrateSvc substratePort.SubstrateService) *substrateService.MixedSubstrateServiceImpl {
	return substrateService.NewMixedSubstrateService(repo, substrateSvc)
}

// ProvideSubstrateHandler provides the substrate handler
func ProvideSubstrateHandler(svc substratePort.SubstrateService) *substrate.SubstrateHandler {
	return substrate.NewSubstrateHandler(svc)
}

// ProvideMixedSubstrateHandler provides the mixed substrate handler
func ProvideMixedSubstrateHandler(svc substratePort.MixedSubstrateService) *substrate.MixedSubstrateHandler {
	return substrate.NewMixedSubstrateHandler(svc)
}

// ProvideFiberApp provides the Fiber application
func ProvideFiberApp() *fiber.App {
	return fiber.New(fiber.Config{
		AppName: "Galatea API",
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			// Return standardized error response
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}
			return c.Status(code).JSON(fiber.Map{
				"error": err.Error(),
			})
		},
	})
}

// InitializeAPI initializes the API application with all its dependencies
func InitializeAPI() (*Application, error) {
	wire.Build(
		ProvideConfig,
		DatabaseSet,
		RepositorySet,
		ServiceSet,
		HandlerSet,
		AppSet,
		wire.Struct(new(Application), "*"),
	)
	return nil, nil
}

// SetupAPI configures the API application after initialization
func SetupAPI(app *Application) error {
	// Configure middleware
	app.App.Use(logger.New())
	app.App.Use(recover.New())
	app.App.Use(cors.New())

	// Register routes
	app.SubstrateHdlr.RegisterRoutes(app.App)
	app.MixedSubstrateHdlr.RegisterRoutes(app.App)

	// Add health check route
	app.App.Get("/health", func(c *fiber.Ctx) error {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status": "ok",
			"database": app.Config.DatabaseType,
		})
	})

	log.Printf("API configured with database type: %s", app.Config.DatabaseType)
	return nil
}