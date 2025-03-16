package wire

import (
	guisubstrate "github.com/benjaminpina/galatea/internal/adapters/gui/substrate"
	"github.com/benjaminpina/galatea/internal/adapters/repositories/sqlite"
	"github.com/benjaminpina/galatea/internal/config"
	substratePort "github.com/benjaminpina/galatea/internal/core/ports/substrate"
	substrateService "github.com/benjaminpina/galatea/internal/core/services/substrate"
	"github.com/google/wire"
)

// GUIAdapterSet proporciona los adaptadores para la GUI
var GUIAdapterSet = wire.NewSet(
	guisubstrate.NewSubstrateAdapter,
	guisubstrate.NewMixedSubstrateAdapter,
	guisubstrate.NewSubstrateSetAdapter,
)

// GUIApp representa la aplicación GUI con sus adaptadores
type GUIApp struct {
	Config                *config.Config
	Database              *sqlite.Database
	SubstrateAdapter      *guisubstrate.SubstrateAdapter
	MixedSubstrateAdapter *guisubstrate.MixedSubstrateAdapter
	SubstrateSetAdapter   *guisubstrate.SubstrateSetAdapter
}

// InitializeGUI inicializa la aplicación GUI con inyección de dependencias
func InitializeGUI() (*GUIApp, error) {
	// Inicializar configuración
	config, err := config.LoadConfig()
	if err != nil {
		return nil, err
	}

	// Inicializar base de datos
	db, err := initDatabase(config)
	if err != nil {
		return nil, err
	}

	// Inicializar repositorios
	substrateRepo := provideSubstrateRepository(db)
	mixedSubstrateRepo := provideMixedSubstrateRepository(db)
	substrateSetRepo := provideSubstrateSetRepository(db)

	// Inicializar servicios
	substrateService := provideSubstrateService(substrateRepo)
	mixedSubstrateService := provideMixedSubstrateService(mixedSubstrateRepo, substrateService)
	substrateSetService := provideSubstrateSetService(substrateSetRepo)

	// Inicializar adaptadores para la GUI
	substrateAdapter := guisubstrate.NewSubstrateAdapter(substrateService)
	mixedSubstrateAdapter := guisubstrate.NewMixedSubstrateAdapter(mixedSubstrateService)
	substrateSetAdapter := guisubstrate.NewSubstrateSetAdapter(substrateSetService)

	// Crear la aplicación GUI
	app := &GUIApp{
		Config:                config,
		Database:              db,
		SubstrateAdapter:      substrateAdapter,
		MixedSubstrateAdapter: mixedSubstrateAdapter,
		SubstrateSetAdapter:   substrateSetAdapter,
	}

	return app, nil
}

// initDatabase inicializa la conexión a la base de datos
func initDatabase(cfg *config.Config) (*sqlite.Database, error) {
	// Por ahora solo soportamos SQLite
	if cfg.DatabaseType == "sqlite" {
		return sqlite.InitDatabase(cfg.SQLiteFile)
	}

	return nil, nil
}

// provideSubstrateRepository proporciona el repositorio de sustratos
func provideSubstrateRepository(db *sqlite.Database) *sqlite.SubstrateRepository {
	return sqlite.NewSubstrateRepository(db)
}

// provideMixedSubstrateRepository proporciona el repositorio de sustratos mixtos
func provideMixedSubstrateRepository(db *sqlite.Database) *sqlite.MixedSubstrateRepository {
	return sqlite.NewMixedSubstrateRepository(db)
}

// provideSubstrateSetRepository proporciona el repositorio de conjuntos de sustratos
func provideSubstrateSetRepository(db *sqlite.Database) *sqlite.SubstrateSetRepository {
	return sqlite.NewSubstrateSetRepository(db)
}

// provideSubstrateService proporciona el servicio de sustratos
func provideSubstrateService(repo substratePort.SubstrateRepository) *substrateService.SubstrateServiceImpl {
	return substrateService.NewSubstrateService(repo)
}

// provideMixedSubstrateService proporciona el servicio de sustratos mixtos
func provideMixedSubstrateService(repo substratePort.MixedSubstrateRepository, substrateSvc substratePort.SubstrateService) *substrateService.MixedSubstrateServiceImpl {
	return substrateService.NewMixedSubstrateService(repo, substrateSvc)
}

// provideSubstrateSetService proporciona el servicio de conjuntos de sustratos
func provideSubstrateSetService(repo substratePort.SubstrateSetRepository) *substrateService.SubstrateSetService {
	return substrateService.NewSubstrateSetService(repo)
}
