package sqlite

import (
	"database/sql"
	"errors"
	"fmt"

	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// SubstrateRepository implements the substrate repository interface for SQLite
type SubstrateRepository struct {
	db *Database
}

// NewSubstrateRepository creates a new SQLite substrate repository
func NewSubstrateRepository(db *Database) *SubstrateRepository {
	return &SubstrateRepository{
		db: db,
	}
}

// Create adds a new substrate to the database
func (r *SubstrateRepository) Create(sub substrate.Substrate) error {
	query := `
		INSERT INTO substrates (id, name, color)
		VALUES (?, ?, ?)
	`
	_, err := r.db.GetDB().Exec(query, sub.ID, sub.Name, sub.Color)
	if err != nil {
		return fmt.Errorf("failed to create substrate: %w", err)
	}
	return nil
}

// GetByID retrieves a substrate by its ID
func (r *SubstrateRepository) GetByID(id string) (*substrate.Substrate, error) {
	query := `
		SELECT id, name, color
		FROM substrates
		WHERE id = ?
	`
	row := r.db.GetDB().QueryRow(query, id)

	var sub substrate.Substrate
	err := row.Scan(&sub.ID, &sub.Name, &sub.Color)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("substrate not found with id %s", id)
		}
		return nil, fmt.Errorf("failed to get substrate: %w", err)
	}

	return &sub, nil
}

// Update modifies an existing substrate
func (r *SubstrateRepository) Update(sub substrate.Substrate) error {
	query := `
		UPDATE substrates
		SET name = ?, color = ?, updated_at = CURRENT_TIMESTAMP
		WHERE id = ?
	`
	result, err := r.db.GetDB().Exec(query, sub.Name, sub.Color, sub.ID)
	if err != nil {
		return fmt.Errorf("failed to update substrate: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("substrate not found with id %s", sub.ID)
	}

	return nil
}

// Delete removes a substrate by its ID
func (r *SubstrateRepository) Delete(id string) error {
	query := `DELETE FROM substrates WHERE id = ?`
	
	result, err := r.db.GetDB().Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete substrate: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("substrate not found with id %s", id)
	}

	return nil
}

// List returns all substrates
func (r *SubstrateRepository) List() ([]substrate.Substrate, error) {
	query := `
		SELECT id, name, color
		FROM substrates
		ORDER BY name
	`
	rows, err := r.db.GetDB().Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to list substrates: %w", err)
	}
	defer rows.Close()

	var substrates []substrate.Substrate
	for rows.Next() {
		var sub substrate.Substrate
		if err := rows.Scan(&sub.ID, &sub.Name, &sub.Color); err != nil {
			return nil, fmt.Errorf("failed to scan substrate: %w", err)
		}
		substrates = append(substrates, sub)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating substrate rows: %w", err)
	}

	return substrates, nil
}

// Exists checks if a substrate exists by ID
func (r *SubstrateRepository) Exists(id string) (bool, error) {
	query := `SELECT 1 FROM substrates WHERE id = ? LIMIT 1`
	
	var exists int
	err := r.db.GetDB().QueryRow(query, id).Scan(&exists)
	
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return false, nil
		}
		return false, fmt.Errorf("failed to check if substrate exists: %w", err)
	}
	
	return true, nil
}
