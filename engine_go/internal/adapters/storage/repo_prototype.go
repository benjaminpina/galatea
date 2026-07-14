package storage

import (
	"database/sql"
	"fmt"
)

// PrototypeRepo provides CRUD operations for prototypes.
type PrototypeRepo struct {
	db *DB
}

// NewPrototypeRepo creates a new PrototypeRepo.
func NewPrototypeRepo(db *DB) *PrototypeRepo {
	return &PrototypeRepo{db: db}
}

// Create inserts a new prototype and returns its ID.
func (r *PrototypeRepo) Create(p *Prototype) (int64, error) {
	res, err := r.db.Conn.Exec(
		`INSERT INTO prototypes (name, sex, color, longevity_formula,
		 refractory_combat_formula, refractory_courtship_formula,
		 sex_ratio_males_formula, sex_ratio_females_formula, sort_order)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		p.Name, p.Sex, p.Color, p.LongevityFormula,
		p.RefractoryCombatFormula, p.RefractoryCourtshipFormula,
		p.SexRatioMalesFormula, p.SexRatioFemalesFormula, p.SortOrder,
	)
	if err != nil {
		return 0, fmt.Errorf("prototype create: %w", err)
	}
	return res.LastInsertId()
}

// GetByID retrieves a prototype by its ID.
func (r *PrototypeRepo) GetByID(id int64) (*Prototype, error) {
	p := &Prototype{}
	err := r.db.Conn.QueryRow(
		`SELECT id, name, sex, color, longevity_formula,
		 refractory_combat_formula, refractory_courtship_formula,
		 sex_ratio_males_formula, sex_ratio_females_formula, sort_order
		 FROM prototypes WHERE id = ?`, id,
	).Scan(&p.ID, &p.Name, &p.Sex, &p.Color, &p.LongevityFormula,
		&p.RefractoryCombatFormula, &p.RefractoryCourtshipFormula,
		&p.SexRatioMalesFormula, &p.SexRatioFemalesFormula, &p.SortOrder)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("prototype get: %w", err)
	}
	return p, nil
}

// List returns all prototypes, optionally filtered by sex.
// Pass "" for sex to get all.
func (r *PrototypeRepo) List(sex string) ([]Prototype, error) {
	var query string
	var args []any

	if sex == "" {
		query = `SELECT id, name, sex, color, longevity_formula,
			refractory_combat_formula, refractory_courtship_formula,
			sex_ratio_males_formula, sex_ratio_females_formula, sort_order
			FROM prototypes ORDER BY sex, sort_order`
		args = nil
	} else {
		query = `SELECT id, name, sex, color, longevity_formula,
			refractory_combat_formula, refractory_courtship_formula,
			sex_ratio_males_formula, sex_ratio_females_formula, sort_order
			FROM prototypes WHERE sex = ? ORDER BY sort_order`
		args = []any{sex}
	}

	rows, err := r.db.Conn.Query(query, args...)
	if err != nil {
		return nil, fmt.Errorf("prototype list: %w", err)
	}
	defer rows.Close()

	var prototypes []Prototype
	for rows.Next() {
		var p Prototype
		if err := rows.Scan(&p.ID, &p.Name, &p.Sex, &p.Color, &p.LongevityFormula,
			&p.RefractoryCombatFormula, &p.RefractoryCourtshipFormula,
			&p.SexRatioMalesFormula, &p.SexRatioFemalesFormula, &p.SortOrder); err != nil {
			return nil, fmt.Errorf("prototype scan: %w", err)
		}
		prototypes = append(prototypes, p)
	}
	return prototypes, rows.Err()
}

// Delete removes a prototype.
func (r *PrototypeRepo) Delete(id int64) error {
	_, err := r.db.Conn.Exec("DELETE FROM prototypes WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("prototype delete: %w", err)
	}
	return nil
}
