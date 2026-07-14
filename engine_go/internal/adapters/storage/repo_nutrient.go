package storage

import (
	"database/sql"
	"fmt"
)

// NutrientRepo provides CRUD operations for nutrients.
type NutrientRepo struct {
	db *DB
}

// NewNutrientRepo creates a new NutrientRepo.
func NewNutrientRepo(db *DB) *NutrientRepo {
	return &NutrientRepo{db: db}
}

// Create inserts a new nutrient and returns its ID.
func (r *NutrientRepo) Create(name string, sortOrder int) (int64, error) {
	res, err := r.db.Conn.Exec(
		"INSERT INTO nutrients (name, sort_order) VALUES (?, ?)",
		name, sortOrder,
	)
	if err != nil {
		return 0, fmt.Errorf("nutrient create: %w", err)
	}
	return res.LastInsertId()
}

// GetByID retrieves a nutrient by its ID.
func (r *NutrientRepo) GetByID(id int64) (*Nutrient, error) {
	n := &Nutrient{}
	err := r.db.Conn.QueryRow(
		"SELECT id, name, sort_order FROM nutrients WHERE id = ?", id,
	).Scan(&n.ID, &n.Name, &n.SortOrder)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("nutrient get: %w", err)
	}
	return n, nil
}

// List returns all nutrients ordered by sort_order.
func (r *NutrientRepo) List() ([]Nutrient, error) {
	rows, err := r.db.Conn.Query(
		"SELECT id, name, sort_order FROM nutrients ORDER BY sort_order",
	)
	if err != nil {
		return nil, fmt.Errorf("nutrient list: %w", err)
	}
	defer rows.Close()

	var nutrients []Nutrient
	for rows.Next() {
		var n Nutrient
		if err := rows.Scan(&n.ID, &n.Name, &n.SortOrder); err != nil {
			return nil, fmt.Errorf("nutrient scan: %w", err)
		}
		nutrients = append(nutrients, n)
	}
	return nutrients, rows.Err()
}

// Delete removes a nutrient.
func (r *NutrientRepo) Delete(id int64) error {
	_, err := r.db.Conn.Exec("DELETE FROM nutrients WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("nutrient delete: %w", err)
	}
	return nil
}
