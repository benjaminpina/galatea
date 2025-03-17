package sqlite

import (
	"database/sql"
	"errors"
	"fmt"

	"github.com/benjaminpina/galatea/internal/core/domain/common"
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
	_, err := r.db.Exec(query, sub.ID, sub.Name, sub.Color)
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
	row := r.db.QueryRow(query, id)

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
	result, err := r.db.Exec(query, sub.Name, sub.Color, sub.ID)
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
	
	result, err := r.db.Exec(query, id)
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

// List returns a paginated list of substrates
func (r *SubstrateRepository) List(params common.PaginationParams) ([]substrate.Substrate, int, error) {
	// Get total count
	var totalCount int
	countQuery := `SELECT COUNT(*) FROM substrates`
	err := r.db.QueryRow(countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count substrates: %w", err)
	}

	// Get paginated data
	query := `
		SELECT id, name, color
		FROM substrates
		ORDER BY name
		LIMIT ? OFFSET ?
	`
	offset := (params.Page - 1) * params.PageSize
	rows, err := r.db.Query(query, params.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list substrates: %w", err)
	}
	defer rows.Close()

	var substrates []substrate.Substrate
	for rows.Next() {
		var sub substrate.Substrate
		err := rows.Scan(&sub.ID, &sub.Name, &sub.Color)
		if err != nil {
			return nil, 0, fmt.Errorf("failed to scan substrate: %w", err)
		}
		substrates = append(substrates, sub)
	}

	if err = rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating substrate rows: %w", err)
	}

	return substrates, totalCount, nil
}

// ListPaginated returns a paginated list of substrates
func (r *SubstrateRepository) ListPaginated(params common.PaginationParams) ([]substrate.Substrate, int, error) {
	// Get total count
	countQuery := `SELECT COUNT(*) FROM substrates`
	var totalCount int
	err := r.db.QueryRow(countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count substrates: %w", err)
	}

	// Calculate offset
	offset := (params.Page - 1) * params.PageSize
	if offset < 0 {
		offset = 0
	}

	// Get paginated data
	query := `
		SELECT id, name, color
		FROM substrates
		ORDER BY name
		LIMIT ? OFFSET ?
	`
	rows, err := r.db.Query(query, params.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list substrates: %w", err)
	}
	defer rows.Close()

	var substrates []substrate.Substrate
	for rows.Next() {
		var sub substrate.Substrate
		if err := rows.Scan(&sub.ID, &sub.Name, &sub.Color); err != nil {
			return nil, 0, fmt.Errorf("failed to scan substrate: %w", err)
		}
		substrates = append(substrates, sub)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating substrate rows: %w", err)
	}

	return substrates, totalCount, nil
}

// Exists checks if a substrate exists by ID
func (r *SubstrateRepository) Exists(id string) (bool, error) {
	query := `SELECT 1 FROM substrates WHERE id = ? LIMIT 1`
	
	var exists int
	err := r.db.QueryRow(query, id).Scan(&exists)
	
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return false, nil
		}
		return false, fmt.Errorf("failed to check if substrate exists: %w", err)
	}
	
	return true, nil
}
