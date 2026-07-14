package storage

import (
	"database/sql"
	"fmt"
)

// LocusRepo provides CRUD operations for genetic loci.
type LocusRepo struct {
	db *DB
}

// NewLocusRepo creates a new LocusRepo.
func NewLocusRepo(db *DB) *LocusRepo {
	return &LocusRepo{db: db}
}

// Create inserts a new locus and returns its ID.
func (r *LocusRepo) Create(l *Locus) (int64, error) {
	continuous := 0
	if l.IsContinuous {
		continuous = 1
	}
	res, err := r.db.Conn.Exec(
		`INSERT INTO loci (name, is_continuous, dominant_value, recessive_value,
		 mutation_rate_dom, mutation_rate_rec, mutation_range_dom, mutation_range_rec,
		 default_expression, sort_order)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		l.Name, continuous, l.DominantValue, l.RecessiveValue,
		l.MutationRateDom, l.MutationRateRec, l.MutationRangeDom, l.MutationRangeRec,
		l.DefaultExpression, l.SortOrder,
	)
	if err != nil {
		return 0, fmt.Errorf("locus create: %w", err)
	}
	return res.LastInsertId()
}

// GetByID retrieves a locus by its ID.
func (r *LocusRepo) GetByID(id int64) (*Locus, error) {
	l := &Locus{}
	var continuous int
	err := r.db.Conn.QueryRow(
		`SELECT id, name, is_continuous, dominant_value, recessive_value,
		 mutation_rate_dom, mutation_rate_rec, mutation_range_dom, mutation_range_rec,
		 default_expression, sort_order
		 FROM loci WHERE id = ?`, id,
	).Scan(&l.ID, &l.Name, &continuous, &l.DominantValue, &l.RecessiveValue,
		&l.MutationRateDom, &l.MutationRateRec, &l.MutationRangeDom, &l.MutationRangeRec,
		&l.DefaultExpression, &l.SortOrder)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("locus get: %w", err)
	}
	l.IsContinuous = continuous == 1
	return l, nil
}

// List returns all loci ordered by sort_order.
func (r *LocusRepo) List() ([]Locus, error) {
	rows, err := r.db.Conn.Query(
		`SELECT id, name, is_continuous, dominant_value, recessive_value,
		 mutation_rate_dom, mutation_rate_rec, mutation_range_dom, mutation_range_rec,
		 default_expression, sort_order
		 FROM loci ORDER BY sort_order`,
	)
	if err != nil {
		return nil, fmt.Errorf("locus list: %w", err)
	}
	defer rows.Close()

	var loci []Locus
	for rows.Next() {
		var l Locus
		var continuous int
		if err := rows.Scan(&l.ID, &l.Name, &continuous, &l.DominantValue, &l.RecessiveValue,
			&l.MutationRateDom, &l.MutationRateRec, &l.MutationRangeDom, &l.MutationRangeRec,
			&l.DefaultExpression, &l.SortOrder); err != nil {
			return nil, fmt.Errorf("locus scan: %w", err)
		}
		l.IsContinuous = continuous == 1
		loci = append(loci, l)
	}
	return loci, rows.Err()
}

// Delete removes a locus.
func (r *LocusRepo) Delete(id int64) error {
	_, err := r.db.Conn.Exec("DELETE FROM loci WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("locus delete: %w", err)
	}
	return nil
}
