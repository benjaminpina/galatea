package sqlite

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/benjaminpina/galatea/internal/core/domain/common"
	"github.com/benjaminpina/galatea/internal/core/domain/substrate"
)

// SubstrateSetRepository implements the SubstrateSetRepository interface for SQLite
type SubstrateSetRepository struct {
	db *Database
}

// NewSubstrateSetRepository creates a new SubstrateSetRepository
func NewSubstrateSetRepository(db *Database) *SubstrateSetRepository {
	return &SubstrateSetRepository{
		db: db,
	}
}

// Initialize creates the substrate_sets table if it doesn't exist
func (r *SubstrateSetRepository) Initialize() error {
	query := `
	CREATE TABLE IF NOT EXISTS substrate_sets (
		id TEXT PRIMARY KEY,
		name TEXT NOT NULL,
		substrates TEXT NOT NULL,
		mixed_substrates TEXT NOT NULL
	);
	`
	_, err := r.db.Exec(query)
	return err
}

// Create adds a new substrate set to the database
func (r *SubstrateSetRepository) Create(set substrate.SubstrateSet) error {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize substrate_sets table: %w", err)
	}

	// Serialize the substrates to JSON
	substratesJSON, err := json.Marshal(set.Substrates)
	if err != nil {
		return fmt.Errorf("failed to marshal substrates: %w", err)
	}

	// Serialize the mixed substrates to JSON
	mixedSubstratesJSON, err := json.Marshal(set.MixedSubstrates)
	if err != nil {
		return fmt.Errorf("failed to marshal mixed substrates: %w", err)
	}

	// Insert the substrate set
	query := `INSERT INTO substrate_sets (id, name, substrates, mixed_substrates) VALUES (?, ?, ?, ?)`
	_, err = r.db.Exec(query, set.ID, set.Name, substratesJSON, mixedSubstratesJSON)
	if err != nil {
		return fmt.Errorf("failed to create substrate set: %w", err)
	}
	return nil
}

// GetByID retrieves a substrate set by ID
func (r *SubstrateSetRepository) GetByID(id string) (*substrate.SubstrateSet, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return nil, fmt.Errorf("failed to initialize substrate_sets table: %w", err)
	}

	query := `SELECT id, name, substrates, mixed_substrates FROM substrate_sets WHERE id = ?`
	row := r.db.QueryRow(query, id)

	var set substrate.SubstrateSet
	var substratesJSON, mixedSubstratesJSON string

	err := row.Scan(&set.ID, &set.Name, &substratesJSON, &mixedSubstratesJSON)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("substrate set not found with id %s", id)
		}
		return nil, fmt.Errorf("failed to get substrate set: %w", err)
	}

	// Deserialize the substrates from JSON
	var substrates []substrate.Substrate
	if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
		return nil, fmt.Errorf("failed to unmarshal substrates: %w", err)
	}
	set.Substrates = substrates

	// Deserialize the mixed substrates from JSON
	var mixedSubstrates []substrate.MixedSubstrate
	if err := json.Unmarshal([]byte(mixedSubstratesJSON), &mixedSubstrates); err != nil {
		return nil, fmt.Errorf("failed to unmarshal mixed substrates: %w", err)
	}
	set.MixedSubstrates = mixedSubstrates

	return &set, nil
}

// Update updates an existing substrate set
func (r *SubstrateSetRepository) Update(set substrate.SubstrateSet) error {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize substrate_sets table: %w", err)
	}

	// Serialize the substrates to JSON
	substratesJSON, err := json.Marshal(set.Substrates)
	if err != nil {
		return fmt.Errorf("failed to marshal substrates: %w", err)
	}

	// Serialize the mixed substrates to JSON
	mixedSubstratesJSON, err := json.Marshal(set.MixedSubstrates)
	if err != nil {
		return fmt.Errorf("failed to marshal mixed substrates: %w", err)
	}

	// Update the substrate set
	query := `UPDATE substrate_sets SET name = ?, substrates = ?, mixed_substrates = ? WHERE id = ?`
	result, err := r.db.Exec(query, set.Name, substratesJSON, mixedSubstratesJSON, set.ID)
	if err != nil {
		return fmt.Errorf("failed to update substrate set: %w", err)
	}

	// Check if the substrate set exists
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("substrate set not found with id %s", set.ID)
	}

	return nil
}

// Delete removes a substrate set by ID
func (r *SubstrateSetRepository) Delete(id string) error {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return fmt.Errorf("failed to initialize substrate_sets table: %w", err)
	}

	query := `DELETE FROM substrate_sets WHERE id = ?`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete substrate set: %w", err)
	}

	// Check if the substrate set exists
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("substrate set not found with id %s", id)
	}

	return nil
}

// List returns a paginated list of substrate sets
func (r *SubstrateSetRepository) List(params common.PaginationParams) ([]substrate.SubstrateSet, int, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return nil, 0, fmt.Errorf("failed to initialize substrate_sets table: %w", err)
	}

	// Get total count
	var totalCount int
	countQuery := `SELECT COUNT(*) FROM substrate_sets`
	err := r.db.QueryRow(countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count substrate sets: %w", err)
	}

	// Get paginated data
	query := `
		SELECT id, name, substrates, mixed_substrates
		FROM substrate_sets
		ORDER BY name
		LIMIT ? OFFSET ?
	`
	offset := (params.Page - 1) * params.PageSize
	rows, err := r.db.Query(query, params.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list substrate sets: %w", err)
	}
	defer rows.Close()

	var substrateSets []substrate.SubstrateSet
	for rows.Next() {
		var set substrate.SubstrateSet
		var substratesJSON, mixedSubstratesJSON string

		err := rows.Scan(&set.ID, &set.Name, &substratesJSON, &mixedSubstratesJSON)
		if err != nil {
			return nil, 0, fmt.Errorf("failed to scan substrate set: %w", err)
		}

		// Deserialize the substrates from JSON
		var substrates []substrate.Substrate
		if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal substrates: %w", err)
		}
		set.Substrates = substrates

		// Deserialize the mixed substrates from JSON
		var mixedSubstrates []substrate.MixedSubstrate
		if err := json.Unmarshal([]byte(mixedSubstratesJSON), &mixedSubstrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal mixed substrates: %w", err)
		}
		set.MixedSubstrates = mixedSubstrates

		substrateSets = append(substrateSets, set)
	}

	if err = rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating substrate set rows: %w", err)
	}

	return substrateSets, totalCount, nil
}

// ListPaginated returns a paginated list of substrate sets
func (r *SubstrateSetRepository) ListPaginated(params common.PaginationParams) ([]substrate.SubstrateSet, int, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return nil, 0, fmt.Errorf("failed to initialize substrate_sets table: %w", err)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM substrate_sets`
	var totalCount int
	err := r.db.QueryRow(countQuery).Scan(&totalCount)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to count substrate sets: %w", err)
	}

	// Calculate offset
	offset := (params.Page - 1) * params.PageSize
	if offset < 0 {
		offset = 0
	}

	// Get paginated data
	query := `
		SELECT id, name, substrates, mixed_substrates 
		FROM substrate_sets
		ORDER BY name
		LIMIT ? OFFSET ?
	`
	rows, err := r.db.Query(query, params.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to query substrate sets: %w", err)
	}
	defer rows.Close()

	var substrateSets []substrate.SubstrateSet
	for rows.Next() {
		var set substrate.SubstrateSet
		var substratesJSON, mixedSubstratesJSON string

		err := rows.Scan(&set.ID, &set.Name, &substratesJSON, &mixedSubstratesJSON)
		if err != nil {
			return nil, 0, fmt.Errorf("failed to scan substrate set: %w", err)
		}

		// Deserialize the substrates from JSON
		var substrates []substrate.Substrate
		if err := json.Unmarshal([]byte(substratesJSON), &substrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal substrates: %w", err)
		}
		set.Substrates = substrates

		// Deserialize the mixed substrates from JSON
		var mixedSubstrates []substrate.MixedSubstrate
		if err := json.Unmarshal([]byte(mixedSubstratesJSON), &mixedSubstrates); err != nil {
			return nil, 0, fmt.Errorf("failed to unmarshal mixed substrates: %w", err)
		}
		set.MixedSubstrates = mixedSubstrates

		substrateSets = append(substrateSets, set)
	}

	if err := rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("error iterating substrate sets rows: %w", err)
	}

	return substrateSets, totalCount, nil
}

// Exists checks if a substrate set exists by ID
func (r *SubstrateSetRepository) Exists(id string) (bool, error) {
	// Initialize the table if it doesn't exist
	if err := r.Initialize(); err != nil {
		return false, fmt.Errorf("failed to initialize substrate_sets table: %w", err)
	}

	query := `SELECT COUNT(*) FROM substrate_sets WHERE id = ?`
	var count int
	err := r.db.QueryRow(query, id).Scan(&count)
	if err != nil {
		return false, fmt.Errorf("failed to check if substrate set exists: %w", err)
	}

	return count > 0, nil
}

// AddSubstrate adds a substrate to a substrate set
func (r *SubstrateSetRepository) AddSubstrate(setID string, sub substrate.Substrate) error {
	// Get the substrate set
	set, err := r.GetByID(setID)
	if err != nil {
		return fmt.Errorf("failed to get substrate set: %w", err)
	}

	// Check if the substrate already exists in the set
	for _, s := range set.Substrates {
		if s.ID == sub.ID {
			return fmt.Errorf("substrate already exists in set")
		}
	}

	// Add the substrate to the set
	set.Substrates = append(set.Substrates, sub)

	// Update the substrate set
	return r.Update(*set)
}

// RemoveSubstrate removes a substrate from a substrate set
func (r *SubstrateSetRepository) RemoveSubstrate(setID string, substrateID string) error {
	// Get the substrate set
	set, err := r.GetByID(setID)
	if err != nil {
		return fmt.Errorf("failed to get substrate set: %w", err)
	}

	// Find and remove the substrate
	found := false
	for i, s := range set.Substrates {
		if s.ID == substrateID {
			// Remove the substrate from the slice
			set.Substrates = append(set.Substrates[:i], set.Substrates[i+1:]...)
			found = true
			break
		}
	}

	if !found {
		return fmt.Errorf("substrate not found in set")
	}

	// Update the substrate set
	return r.Update(*set)
}

// AddMixedSubstrate adds a mixed substrate to a substrate set
func (r *SubstrateSetRepository) AddMixedSubstrate(setID string, mixedSub substrate.MixedSubstrate) error {
	// Get the substrate set
	set, err := r.GetByID(setID)
	if err != nil {
		return fmt.Errorf("failed to get substrate set: %w", err)
	}

	// Check if the mixed substrate already exists in the set
	for _, ms := range set.MixedSubstrates {
		if ms.ID == mixedSub.ID {
			return fmt.Errorf("mixed substrate already exists in set")
		}
	}

	// Add the mixed substrate to the set
	set.MixedSubstrates = append(set.MixedSubstrates, mixedSub)

	// Update the substrate set
	return r.Update(*set)
}

// RemoveMixedSubstrate removes a mixed substrate from a substrate set
func (r *SubstrateSetRepository) RemoveMixedSubstrate(setID string, mixedSubstrateID string) error {
	// Get the substrate set
	set, err := r.GetByID(setID)
	if err != nil {
		return fmt.Errorf("failed to get substrate set: %w", err)
	}

	// Find and remove the mixed substrate
	found := false
	for i, ms := range set.MixedSubstrates {
		if ms.ID == mixedSubstrateID {
			// Remove the mixed substrate from the slice
			set.MixedSubstrates = append(set.MixedSubstrates[:i], set.MixedSubstrates[i+1:]...)
			found = true
			break
		}
	}

	if !found {
		return fmt.Errorf("mixed substrate not found in set")
	}

	// Update the substrate set
	return r.Update(*set)
}
