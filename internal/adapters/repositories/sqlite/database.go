package sqlite

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sync"

	_ "modernc.org/sqlite"
)

// Database represents a SQLite database connection
type Database struct {
	db   *sql.DB
	path string
}

var (
	instance *Database
	once     sync.Once
)

// InitDatabase initializes the SQLite database
func InitDatabase(dbPath string) (*Database, error) {
	var err error
	
	once.Do(func() {
		// Ensure directory exists
		dir := filepath.Dir(dbPath)
		if err = os.MkdirAll(dir, 0755); err != nil {
			err = fmt.Errorf("failed to create database directory: %w", err)
			return
		}

		// Open database connection
		var db *sql.DB
		db, err = sql.Open("sqlite", dbPath)
		if err != nil {
			err = fmt.Errorf("failed to open database: %w", err)
			return
		}

		// Test connection
		if err = db.Ping(); err != nil {
			err = fmt.Errorf("failed to ping database: %w", err)
			return
		}

		// Set connection parameters
		db.SetMaxOpenConns(1) // SQLite supports only one writer at a time
		db.SetMaxIdleConns(1)
		
		instance = &Database{
			db:   db,
			path: dbPath,
		}
		
		log.Printf("SQLite database initialized at %s", dbPath)
	})

	if err != nil {
		return nil, err
	}

	return instance, nil
}

// GetInstance returns the singleton database instance
func GetInstance() (*Database, error) {
	if instance == nil {
		return nil, fmt.Errorf("database not initialized, call InitDatabase first")
	}
	return instance, nil
}

// Exec executes a query without returning any rows
func (d *Database) Exec(query string, args ...interface{}) (sql.Result, error) {
	return d.db.Exec(query, args...)
}

// Query executes a query that returns rows
func (d *Database) Query(query string, args ...interface{}) (*sql.Rows, error) {
	return d.db.Query(query, args...)
}

// QueryRow executes a query that is expected to return at most one row
func (d *Database) QueryRow(query string, args ...interface{}) *sql.Row {
	return d.db.QueryRow(query, args...)
}

// Close closes the database connection
func (d *Database) Close() error {
	if d.db != nil {
		return d.db.Close()
	}
	return nil
}

// InitSchema initializes the database schema
func (d *Database) InitSchema() error {
	// Create tables if they don't exist
	schemas := []string{
		`CREATE TABLE IF NOT EXISTS substrates (
			id TEXT PRIMARY KEY,
			name TEXT NOT NULL,
			color TEXT NOT NULL,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		`CREATE TABLE IF NOT EXISTS substrate_sets (
			id TEXT PRIMARY KEY,
			name TEXT NOT NULL,
			description TEXT,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		`CREATE TABLE IF NOT EXISTS substrate_set_items (
			set_id TEXT,
			substrate_id TEXT,
			PRIMARY KEY (set_id, substrate_id),
			FOREIGN KEY (set_id) REFERENCES substrate_sets(id) ON DELETE CASCADE,
			FOREIGN KEY (substrate_id) REFERENCES substrates(id) ON DELETE CASCADE
		)`,
		`CREATE TABLE IF NOT EXISTS mixed_substrates (
			id TEXT PRIMARY KEY,
			name TEXT NOT NULL,
			description TEXT,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		`CREATE TABLE IF NOT EXISTS mixed_substrate_components (
			mixed_id TEXT,
			substrate_id TEXT,
			percentage REAL NOT NULL,
			PRIMARY KEY (mixed_id, substrate_id),
			FOREIGN KEY (mixed_id) REFERENCES mixed_substrates(id) ON DELETE CASCADE,
			FOREIGN KEY (substrate_id) REFERENCES substrates(id) ON DELETE CASCADE
		)`,
	}

	for _, schema := range schemas {
		_, err := d.db.Exec(schema)
		if err != nil {
			return fmt.Errorf("failed to create schema: %w", err)
		}
	}

	log.Println("Database schema initialized successfully")
	return nil
}

// Transaction executes a function within a transaction
func (d *Database) Transaction(fn func(*sql.Tx) error) error {
	tx, err := d.db.Begin()
	if err != nil {
		return err
	}

	defer func() {
		if p := recover(); p != nil {
			tx.Rollback()
			panic(p) // re-throw panic after rollback
		}
	}()

	if err := fn(tx); err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit()
}
