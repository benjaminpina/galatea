package wire

import (
	filesubstrate "github.com/benjaminpina/galatea/internal/adapters/files/substrate"
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

// GUIApp represents the GUI application with its adapters
type GUIApp struct {
	Config                   *config.Config
	Database                 *sqlite.Database
	SubstrateAdapter         *guisubstrate.SubstrateAdapter
	MixedSubstrateAdapter    *guisubstrate.MixedSubstrateAdapter
	SubstrateSetAdapter      *guisubstrate.SubstrateSetAdapter
	SubstrateFileService     substratePort.SubstrateFileService
	MixedSubstrateFileService substratePort.MixedSubstrateFileService
	SubstrateSetFileService  substratePort.SubstrateSetFileService
}

// InitializeGUI initializes the GUI application with dependency injection
func InitializeGUI() (*GUIApp, error) {
	// Load the configuration
	config, err := config.LoadConfig()
	if err != nil {
		return nil, err
	}

	// Initialize the database
	db, err := initDatabase(config)
	if err != nil {
		return nil, err
	}

	// Initialize repositories
	substrateRepo := provideSubstrateRepository(db)
	mixedSubstrateRepo := provideMixedSubstrateRepository(db)
	substrateSetRepo := provideSubstrateSetRepository(db)

	// Inicializar servicios
	substrateService := provideSubstrateService(substrateRepo)
	mixedSubstrateService := provideMixedSubstrateService(mixedSubstrateRepo, substrateService)
	substrateSetService := provideSubstrateSetService(substrateSetRepo)
	
	// Initialize file services
	substrateFileService := provideSubstrateFileService(substrateService)
	mixedSubstrateFileService := provideMixedSubstrateFileService(mixedSubstrateService)
	substrateSetFileService := provideSubstrateSetFileService(substrateSetService)

	// Initialize adapters for the GUI
	substrateAdapter := guisubstrate.NewSubstrateAdapter(substrateService)
	mixedSubstrateAdapter := guisubstrate.NewMixedSubstrateAdapter(mixedSubstrateService)
	substrateSetAdapter := guisubstrate.NewSubstrateSetAdapter(substrateSetService)

	// Create the GUI application
	app := &GUIApp{
		Config:                   config,
		Database:                 db,
		SubstrateAdapter:         substrateAdapter,
		MixedSubstrateAdapter:    mixedSubstrateAdapter,
		SubstrateSetAdapter:      substrateSetAdapter,
		SubstrateFileService:     substrateFileService,
		MixedSubstrateFileService: mixedSubstrateFileService,
		SubstrateSetFileService:  substrateSetFileService,
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

// provideSubstrateRepository provides the substrate repository
func provideSubstrateRepository(db *sqlite.Database) *sqlite.SubstrateRepository {
	return sqlite.NewSubstrateRepository(db)
}

// provideMixedSubstrateRepository provides the mixed substrate repository
func provideMixedSubstrateRepository(db *sqlite.Database) *sqlite.MixedSubstrateRepository {
	return sqlite.NewMixedSubstrateRepository(db)
}

// provideSubstrateSetRepository provides the substrate set repository
func provideSubstrateSetRepository(db *sqlite.Database) *sqlite.SubstrateSetRepository {
	return sqlite.NewSubstrateSetRepository(db)
}

// provideSubstrateService provides the substrate service
func provideSubstrateService(repo substratePort.SubstrateRepository) *substrateService.SubstrateServiceImpl {
	return substrateService.NewSubstrateService(repo)
}

// provideMixedSubstrateService provides the mixed substrate service
func provideMixedSubstrateService(repo substratePort.MixedSubstrateRepository, substrateSvc substratePort.SubstrateService) *substrateService.MixedSubstrateServiceImpl {
	return substrateService.NewMixedSubstrateService(repo, substrateSvc)
}

// provideSubstrateSetService provides the substrate set service
func provideSubstrateSetService(repo substratePort.SubstrateSetRepository) *substrateService.SubstrateSetService {
	return substrateService.NewSubstrateSetService(repo)
}

// provideSubstrateFileService provides the file service for substrates
func provideSubstrateFileService(substrateSvc substratePort.SubstrateService) substratePort.SubstrateFileService {
	return filesubstrate.NewFileService(substrateSvc)
}

// provideMixedSubstrateFileService provides the file service for mixed substrates
func provideMixedSubstrateFileService(mixedSubstrateSvc substratePort.MixedSubstrateService) substratePort.MixedSubstrateFileService {
	return filesubstrate.NewMixedFileService(mixedSubstrateSvc)
}

// provideSubstrateSetFileService provides the file service for substrate sets
func provideSubstrateSetFileService(substrateSetSvc substratePort.SubstrateSetService) substratePort.SubstrateSetFileService {
	return filesubstrate.NewSetFileService(substrateSetSvc)
}
