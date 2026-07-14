// Package storage provides the SQLite-based persistence layer for Galatea workspaces.
// It handles database initialization, migrations, and CRUD operations for all
// domain entities, as well as a buffered writer for high-throughput simulation results.
package storage

import (
	"database/sql"
	"embed"
	"fmt"
	"os"
	"path/filepath"

	_ "modernc.org/sqlite"
)

//go:embed migrations/*.sql
var migrationsFS embed.FS

// DB wraps a sql.DB connection with Galatea-specific configuration and helpers.
type DB struct {
	Conn *sql.DB
	Path string
}

// Open opens or creates a Galatea workspace database at the given path.
// It applies all pending migrations and configures SQLite for optimal performance.
func Open(dbPath string) (*DB, error) {
	// Ensure parent directory exists.
	dir := filepath.Dir(dbPath)
	if dir != "" && dir != "." {
		if err := os.MkdirAll(dir, 0o755); err != nil {
			return nil, fmt.Errorf("storage: create directory: %w", err)
		}
	}

	conn, err := sql.Open("sqlite", dbPath)
	if err != nil {
		return nil, fmt.Errorf("storage: open database: %w", err)
	}

	// Configure connection pool for single-writer usage.
	conn.SetMaxOpenConns(1)

	db := &DB{Conn: conn, Path: dbPath}

	if err := db.configure(); err != nil {
		conn.Close()
		return nil, err
	}

	if err := db.migrate(); err != nil {
		conn.Close()
		return nil, err
	}

	return db, nil
}

// OpenMemory creates an in-memory database useful for testing.
func OpenMemory() (*DB, error) {
	conn, err := sql.Open("sqlite", ":memory:")
	if err != nil {
		return nil, fmt.Errorf("storage: open memory database: %w", err)
	}

	conn.SetMaxOpenConns(1)

	db := &DB{Conn: conn, Path: ":memory:"}

	if err := db.configure(); err != nil {
		conn.Close()
		return nil, err
	}

	if err := db.migrate(); err != nil {
		conn.Close()
		return nil, err
	}

	return db, nil
}

// Close closes the database connection.
func (db *DB) Close() error {
	if db.Conn == nil {
		return nil
	}
	return db.Conn.Close()
}

// configure sets SQLite pragmas for performance and correctness.
func (db *DB) configure() error {
	pragmas := []string{
		"PRAGMA journal_mode = WAL",
		"PRAGMA synchronous = NORMAL",
		"PRAGMA foreign_keys = ON",
		"PRAGMA busy_timeout = 5000",
		"PRAGMA cache_size = -20000", // 20MB cache
		"PRAGMA temp_store = MEMORY",
	}

	for _, p := range pragmas {
		if _, err := db.Conn.Exec(p); err != nil {
			return fmt.Errorf("storage: configure pragma %q: %w", p, err)
		}
	}

	return nil
}

// migrate applies all embedded SQL migration files in order.
// It uses a simple schema_version table to track which migrations have been applied.
func (db *DB) migrate() error {
	// Create the migrations tracking table if it does not exist.
	_, err := db.Conn.Exec(`
		CREATE TABLE IF NOT EXISTS schema_migrations (
			version  INTEGER PRIMARY KEY,
			filename TEXT    NOT NULL,
			applied_at TEXT NOT NULL DEFAULT (datetime('now'))
		)
	`)
	if err != nil {
		return fmt.Errorf("storage: create migrations table: %w", err)
	}

	// Read available migration files.
	entries, err := migrationsFS.ReadDir("migrations")
	if err != nil {
		return fmt.Errorf("storage: read migrations dir: %w", err)
	}

	for i, entry := range entries {
		if entry.IsDir() {
			continue
		}

		version := i + 1
		filename := entry.Name()

		// Check if already applied.
		var count int
		err := db.Conn.QueryRow("SELECT COUNT(*) FROM schema_migrations WHERE version = ?", version).Scan(&count)
		if err != nil {
			return fmt.Errorf("storage: check migration %d: %w", version, err)
		}
		if count > 0 {
			continue // Already applied.
		}

		// Read and execute the migration.
		content, err := migrationsFS.ReadFile("migrations/" + filename)
		if err != nil {
			return fmt.Errorf("storage: read migration %s: %w", filename, err)
		}

		tx, err := db.Conn.Begin()
		if err != nil {
			return fmt.Errorf("storage: begin migration tx %d: %w", version, err)
		}

		if _, err := tx.Exec(string(content)); err != nil {
			tx.Rollback()
			return fmt.Errorf("storage: execute migration %s: %w", filename, err)
		}

		if _, err := tx.Exec("INSERT INTO schema_migrations (version, filename) VALUES (?, ?)", version, filename); err != nil {
			tx.Rollback()
			return fmt.Errorf("storage: record migration %s: %w", filename, err)
		}

		if err := tx.Commit(); err != nil {
			return fmt.Errorf("storage: commit migration %s: %w", filename, err)
		}
	}

	return nil
}

// SchemaVersion returns the current schema version (number of applied migrations).
func (db *DB) SchemaVersion() (int, error) {
	var version int
	err := db.Conn.QueryRow("SELECT COALESCE(MAX(version), 0) FROM schema_migrations").Scan(&version)
	if err != nil {
		return 0, fmt.Errorf("storage: get schema version: %w", err)
	}
	return version, nil
}
