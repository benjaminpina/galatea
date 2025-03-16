package sqlite

import (
	"log"
	"path/filepath"

	"github.com/benjaminpina/galatea/internal/config"
)

// InitializeDatabase sets up the database connection and schema
func InitializeDatabase() (*Database, error) {
	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		return nil, err
	}

	// Determine database path
	dbPath := cfg.SQLiteFile
	if !filepath.IsAbs(dbPath) {
		// If relative path, make it absolute from current directory
		dbPath, err = filepath.Abs(dbPath)
		if err != nil {
			return nil, err
		}
	}

	// Initialize database
	db, err := InitDatabase(dbPath)
	if err != nil {
		return nil, err
	}

	// Initialize schema
	if err := db.InitSchema(); err != nil {
		return nil, err
	}

	log.Printf("Database initialized successfully at %s", dbPath)
	return db, nil
}
