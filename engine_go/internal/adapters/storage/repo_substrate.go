package storage

import (
	"database/sql"
	"fmt"
)

// SubstrateRepo provides CRUD operations for substrates.
type SubstrateRepo struct {
	db *DB
}

// NewSubstrateRepo creates a new SubstrateRepo.
func NewSubstrateRepo(db *DB) *SubstrateRepo {
	return &SubstrateRepo{db: db}
}

// Create inserts a new substrate and returns its ID.
func (r *SubstrateRepo) Create(name string, color int, isMixed bool, sortOrder int) (int64, error) {
	mixed := 0
	if isMixed {
		mixed = 1
	}
	res, err := r.db.Conn.Exec(
		"INSERT INTO substrates (name, color, is_mixed, sort_order) VALUES (?, ?, ?, ?)",
		name, color, mixed, sortOrder,
	)
	if err != nil {
		return 0, fmt.Errorf("substrate create: %w", err)
	}
	return res.LastInsertId()
}

// GetByID retrieves a substrate by its ID.
func (r *SubstrateRepo) GetByID(id int64) (*Substrate, error) {
	s := &Substrate{}
	var mixed int
	err := r.db.Conn.QueryRow(
		"SELECT id, name, color, is_mixed, sort_order FROM substrates WHERE id = ?", id,
	).Scan(&s.ID, &s.Name, &s.Color, &mixed, &s.SortOrder)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("substrate get: %w", err)
	}
	s.IsMixed = mixed == 1
	return s, nil
}

// List returns all substrates ordered by sort_order.
func (r *SubstrateRepo) List() ([]Substrate, error) {
	rows, err := r.db.Conn.Query(
		"SELECT id, name, color, is_mixed, sort_order FROM substrates ORDER BY sort_order",
	)
	if err != nil {
		return nil, fmt.Errorf("substrate list: %w", err)
	}
	defer rows.Close()

	var substrates []Substrate
	for rows.Next() {
		var s Substrate
		var mixed int
		if err := rows.Scan(&s.ID, &s.Name, &s.Color, &mixed, &s.SortOrder); err != nil {
			return nil, fmt.Errorf("substrate scan: %w", err)
		}
		s.IsMixed = mixed == 1
		substrates = append(substrates, s)
	}
	return substrates, rows.Err()
}

// Delete removes a substrate.
func (r *SubstrateRepo) Delete(id int64) error {
	_, err := r.db.Conn.Exec("DELETE FROM substrates WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("substrate delete: %w", err)
	}
	return nil
}

// AddComposition adds a simple substrate percentage to a mixed substrate.
func (r *SubstrateRepo) AddComposition(mixedID, simpleID int64, percentage int) (int64, error) {
	res, err := r.db.Conn.Exec(
		"INSERT INTO substrate_compositions (mixed_substrate_id, simple_substrate_id, percentage) VALUES (?, ?, ?)",
		mixedID, simpleID, percentage,
	)
	if err != nil {
		return 0, fmt.Errorf("substrate composition create: %w", err)
	}
	return res.LastInsertId()
}

// GetCompositions returns all compositions for a mixed substrate.
func (r *SubstrateRepo) GetCompositions(mixedID int64) ([]SubstrateComposition, error) {
	rows, err := r.db.Conn.Query(
		"SELECT id, mixed_substrate_id, simple_substrate_id, percentage FROM substrate_compositions WHERE mixed_substrate_id = ?",
		mixedID,
	)
	if err != nil {
		return nil, fmt.Errorf("substrate compositions list: %w", err)
	}
	defer rows.Close()

	var comps []SubstrateComposition
	for rows.Next() {
		var c SubstrateComposition
		if err := rows.Scan(&c.ID, &c.MixedSubstrateID, &c.SimpleSubstrateID, &c.Percentage); err != nil {
			return nil, fmt.Errorf("substrate composition scan: %w", err)
		}
		comps = append(comps, c)
	}
	return comps, rows.Err()
}
