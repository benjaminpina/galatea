package sqlite

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// MixedSubstrateRepository implements the MixedSubstrateRepository interface for SQLite
type MixedSubstrateRepository struct {
	db *Database
}

// NewMixedSubstrateRepository creates a new MixedSubstrateRepository
func NewMixedSubstrateRepository(db *Database) *MixedSubstrateRepository {
	return &MixedSubstrateRepository{
		db: db,
	}
}

// Initialize creates the mixed_substrates table if it doesn't exist
func (r *MixedSubstrateRepository) Initialize() error {
	query := `
	CREATE TABLE IF NOT EXISTS mixed_substrates (
		id TEXT PRIMARY KEY,
		name TEXT NOT NULL,
		color TEXT NOT NULL,
		substrates TEXT NOT NULL
	);
	`
	_, err := r.db.Exec(query)
	return err
}

// Create adds a new mixed substrate to the database
func (r *MixedSubstrateRepository) Create(mixedSub substrate.MixedSubstrate) error {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	// Serialize the substrates to JSON
	substratesJSON, err := json.Marshal(mixedSub.Substrates)
	if err != nil {
		return fmt.Errorf("failed to marshal substrates: %w", err)
	}

	// Insert the mixed substrate
	query := `INSERT INTO mixed_substrates (id, name, color, substrates) VALUES (?, ?, ?, ?)`
	_, err = r.db.Exec(query, mixedSub.ID, mixedSub.Name, mixedSub.Color, substratesJSON)
	if err != nil {
		return fmt.Errorf("failed to create mixed substrate: %w", err)
	}
	return nil
}

// GetByID retrieves a mixed substrate by ID
func (r *MixedSubstrateRepository) GetByID(id string) (*substrate.MixedSubstrate, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return nil, fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	query := `SELECT id, name, color, substrates FROM mixed_substrates WHERE id = ?`
	row := r.db.QueryRow(query, id)

	var mixedSub substrate.MixedSubstrate
	var substratesJSON string

	err := row.Scan(&mixedSub.ID, &mixedSub.Name, &mixedSub.Color, &substratesJSON)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("mixed substrate not found with id %s", id)
		}
		return nil, fmt.Errorf("failed to get mixed substrate: %w", err)
	}

	// Deserialize the substrates from JSON
	var substrates []substrate.SubstratePercentage
	if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
		return nil, fmt.Errorf("failed to unmarshal substrates: %w", err)
	}

	mixedSub.Substrates = substrates
	return &mixedSub, nil
}

// Update updates an existing mixed substrate
func (r *MixedSubstrateRepository) Update(mixedSub substrate.MixedSubstrate) error {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	// Serialize the substrates to JSON
	substratesJSON, err := json.Marshal(mixedSub.Substrates)
	if err != nil {
		return fmt.Errorf("failed to marshal substrates: %w", err)
	}

	// Update the mixed substrate
	query := `UPDATE mixed_substrates SET name = ?, color = ?, substrates = ? WHERE id = ?`
	result, err := r.db.Exec(query, mixedSub.Name, mixedSub.Color, substratesJSON, mixedSub.ID)
	if err != nil {
		return fmt.Errorf("failed to update mixed substrate: %w", err)
	}

	// Check if the mixed substrate exists
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("mixed substrate not found with id %s", mixedSub.ID)
	}

	return nil
}

// Delete removes a mixed substrate by ID
func (r *MixedSubstrateRepository) Delete(id string) error {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	query := `DELETE FROM mixed_substrates WHERE id = ?`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete mixed substrate: %w", err)
	}

	// Check if the mixed substrate exists
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("mixed substrate not found with id %s", id)
	}

	return nil
}

// List returns a paginated list of mixed substrates
func (r *MixedSubstrateRepository) List(params common.PaginationParams) ([]substrate.MixedSubstrate, int, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return nil, 0, fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	// Get total count
	var totalCount int
	countQuery := `SELECT COUNT(*) FROM mixed_substrates`
	err := r.db.QueryRow(countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count mixed substrates: %w", err)
	}

	// Get paginated data
	query := `
		SELECT id, name, color, substrates
		FROM mixed_substrates
		ORDER BY name
		LIMIT ? OFFSET ?
	`
	offset := (params.Page - 1) * params.PageSize
	rows, err := r.db.Query(query, params.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list mixed substrates: %w", err)
	}
	defer rows.Close()

	var mixedSubstrates []substrate.MixedSubstrate
	for rows.Next() {
		var mixedSub substrate.MixedSubstrate
		var substratesJSON string

		err := rows.Scan(&mixedSub.ID, &mixedSub.Name, &mixedSub.Color, &substratesJSON)
		if err != nil {
			return nil, 0, fmt.Errorf("failed to scan mixed substrate: %w", err)
		}

		// Deserialize the substrates from JSON
		var substrates []substrate.SubstratePercentage
		if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal substrates: %w", err)
		}

		mixedSub.Substrates = substrates
		mixedSubstrates = append(mixedSubstrates, mixedSub)
	}

	if err = rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating mixed substrate rows: %w", err)
	}

	return mixedSubstrates, totalCount, nil
}

// ListPaginated returns a paginated list of mixed substrates
func (r *MixedSubstrateRepository) ListPaginated(params common.PaginationParams) ([]substrate.MixedSubstrate, int, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return nil, 0, fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM mixed_substrates`
	var totalCount int
	err := r.db.QueryRow(countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count mixed substrates: %w", err)
	}

	// Calculate offset
	offset := (params.Page - 1) * params.PageSize
	if offset < 0 {
		offset = 0
	}

	// Get paginated data
	query := `
		SELECT id, name, color, substrates 
		FROM mixed_substrates
		ORDER BY name
		LIMIT ? OFFSET ?
	`
	rows, err := r.db.Query(query, params.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to query mixed substrates: %w", err)
	}
	defer rows.Close()

	var mixedSubstrates []substrate.MixedSubstrate
	for rows.Next() {
		var mixedSub substrate.MixedSubstrate
		var substratesJSON string

		err := rows.Scan(&mixedSub.ID, &mixedSub.Name, &mixedSub.Color, &substratesJSON)
		if err != nil {
			return nil, 0, fmt.Errorf("failed to scan mixed substrate: %w", err)
		}

		// Deserialize the substrates from JSON
		var substrates []substrate.SubstratePercentage
		if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal substrates: %w", err)
		}

		mixedSub.Substrates = substrates
		mixedSubstrates = append(mixedSubstrates, mixedSub)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating mixed substrates rows: %w", err)
	}

	return mixedSubstrates, totalCount, nil
}

// Exists checks if a mixed substrate exists by ID
func (r *MixedSubstrateRepository) Exists(id string) (bool, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return false, fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	query := `SELECT COUNT(*) FROM mixed_substrates WHERE id = ?`
	var count int
	err := r.db.QueryRow(query, id).Scan(&count)
	if err != nil {
		return false, fmt.Errorf("failed to check if mixed substrate exists: %w", err)
	}

	return count > 0, nil
}

// FindBySubstrateID finds mixed substrates that contain a specific substrate with pagination
func (r *MixedSubstrateRepository) FindBySubstrateID(substrateID string, params common.PaginationParams) ([]substrate.MixedSubstrate, int, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return nil, 0, fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	// Get all mixed substrates
	query := `
		SELECT id, name, color, substrates
		FROM mixed_substrates
		ORDER BY name
		LIMIT ? OFFSET ?
	`
	offset := (params.Page - 1) * params.PageSize
	rows, err := r.db.Query(query, params.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to query mixed substrates: %w", err)
	}
	defer rows.Close()

	var matchingMixedSubstrates []substrate.MixedSubstrate
	for rows.Next() {
		var mixedSub substrate.MixedSubstrate
		var substratesJSON string

		err := rows.Scan(&mixedSub.ID, &mixedSub.Name, &mixedSub.Color, &substratesJSON)
		if err != nil {
			return nil, 0, fmt.Errorf("failed to scan mixed substrate: %w", err)
		}

		// Deserialize the substrates from JSON
		var substrates []substrate.SubstratePercentage
		if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal substrates: %w", err)
		}

		// Check if the mixed substrate contains the specified substrate
		for _, sub := range substrates {
			if sub.Substrate.ID == substrateID {
				mixedSub.Substrates = substrates
				matchingMixedSubstrates = append(matchingMixedSubstrates, mixedSub)
				break
			}
		}
	}

	if err = rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating mixed substrate rows: %w", err)
	}

	// Count total matching mixed substrates
	var totalCount int
	countQuery := `SELECT COUNT(*) FROM mixed_substrates`
	err = r.db.QueryRow(countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count mixed substrates: %w", err)
	}

	// Filter count based on substrate ID
	// Note: This is not efficient for large datasets, but works for this implementation
	// A more efficient approach would be to use a JOIN or a subquery
	var filteredCount int
	allRows, err := r.db.Query(`SELECT id, substrates FROM mixed_substrates`)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to query all mixed substrates for counting: %w", err)
	}
	defer allRows.Close()

	for allRows.Next() {
		var id, substratesJSON string
		if err := allRows.Scan(&id, &substratesJSON); err != nil {
			return nil, 0, fmt.Errorf("failed to scan mixed substrate for counting: %w", err)
		}

		var substrates []substrate.SubstratePercentage
		if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal substrates for counting: %w", err)
		}

		for _, sub := range substrates {
			if sub.Substrate.ID == substrateID {
				filteredCount++
				break
			}
		}
	}

	if err = allRows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating mixed substrate rows for counting: %w", err)
	}

	return matchingMixedSubstrates, filteredCount, nil
}

// FindBySubstrateIDPaginated finds mixed substrates that contain a specific substrate with pagination
func (r *MixedSubstrateRepository) FindBySubstrateIDPaginated(substrateID string, params common.PaginationParams) ([]substrate.MixedSubstrate, int, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return nil, 0, fmt.Errorf("failed to initialize mixed_substrates table: %w", err)
	}

	// Get paginated mixed substrates
	mixedSubstrates, _, err := r.List(params)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list mixed substrates: %w", err)
	}

	// Filter mixed substrates that contain the specified substrate
	var filteredResults []substrate.MixedSubstrate
	for _, ms := range mixedSubstrates {
		for _, sp := range ms.Substrates {
			if sp.Substrate.ID == substrateID {
				filteredResults = append(filteredResults, ms)
				break
			}
		}
	}

	// Count total matching mixed substrates
	var filteredCount int
	allRows, err := r.db.Query(`SELECT id, substrates FROM mixed_substrates`)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to query all mixed substrates for counting: %w", err)
	}
	defer allRows.Close()

	for allRows.Next() {
		var id, substratesJSON string
		if err := allRows.Scan(&id, &substratesJSON); err != nil {
			return nil, 0, fmt.Errorf("failed to scan mixed substrate for counting: %w", err)
		}

		var substrates []substrate.SubstratePercentage
		if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal substrates for counting: %w", err)
		}

		for _, sub := range substrates {
			if sub.Substrate.ID == substrateID {
				filteredCount++
				break
			}
		}
	}

	if err = allRows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating mixed substrate rows for counting: %w", err)
	}

	return filteredResults, filteredCount, nil
}
