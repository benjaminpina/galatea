// +build wireinject

package wire

import (
	"fmt"

	"github.com/google/wire"
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
	ProvideSubstrateSetRepository,
	wire.Bind(new(substratePort.SubstrateSetRepository), new(*sqlite.SubstrateSetRepository)),
)

// ServiceSet is the provider set for services
var ServiceSet = wire.NewSet(
	ProvideSubstrateService,
	wire.Bind(new(substratePort.SubstrateService), new(*substrateService.SubstrateServiceImpl)),
	ProvideMixedSubstrateService,
	wire.Bind(new(substratePort.MixedSubstrateService), new(*substrateService.MixedSubstrateServiceImpl)),
	ProvideSubstrateSetService,
	wire.Bind(new(substratePort.SubstrateSetService), new(*substrateService.SubstrateSetService)),
)

// CoreSet is the provider set for core components
var CoreSet = wire.NewSet(
	DatabaseSet,
	RepositorySet,
	ServiceSet,
)

// CoreApplication represents the core application with all its dependencies
type CoreApplication struct {
	Config             *config.Config
	Database           *sqlite.Database
	SubstrateRepo      substratePort.SubstrateRepository
	SubstrateSvc       substratePort.SubstrateService
	MixedSubstrateRepo substratePort.MixedSubstrateRepository
	MixedSubstrateSvc  substratePort.MixedSubstrateService
	SubstrateSetRepo   substratePort.SubstrateSetRepository
	SubstrateSetSvc    substratePort.SubstrateSetService
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

// ProvideSubstrateSetRepository provides the substrate set repository
func ProvideSubstrateSetRepository(db *sqlite.Database) *sqlite.SubstrateSetRepository {
	return sqlite.NewSubstrateSetRepository(db)
}

// ProvideSubstrateService provides the substrate service
func ProvideSubstrateService(repo substratePort.SubstrateRepository) *substrateService.SubstrateServiceImpl {
	return substrateService.NewSubstrateService(repo)
}

// ProvideMixedSubstrateService provides the mixed substrate service
func ProvideMixedSubstrateService(repo substratePort.MixedSubstrateRepository, substrateSvc substratePort.SubstrateService) *substrateService.MixedSubstrateServiceImpl {
	return substrateService.NewMixedSubstrateService(repo, substrateSvc)
}

// ProvideSubstrateSetService provides the substrate set service
func ProvideSubstrateSetService(repo substratePort.SubstrateSetRepository) *substrateService.SubstrateSetService {
	return substrateService.NewSubstrateSetService(repo)
}

// InitializeCore initializes the core application with all its dependencies
func InitializeCore() (*CoreApplication, error) {
	wire.Build(
		ProvideConfig,
		DatabaseSet,
		RepositorySet,
		ServiceSet,
		wire.Struct(new(CoreApplication), "*"),
	)
	return nil, nil
}