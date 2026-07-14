package storage

import (
	"database/sql"
	"fmt"
)

// StageRepo provides CRUD operations for life stages.
type StageRepo struct {
	db *DB
}

// NewStageRepo creates a new StageRepo.
func NewStageRepo(db *DB) *StageRepo {
	return &StageRepo{db: db}
}

// Create inserts a new stage and returns its ID.
func (r *StageRepo) Create(s *Stage) (int64, error) {
	res, err := r.db.Conn.Exec(
		`INSERT INTO stages (name, sort_order, cycles_formula,
		 condition1_formula, condition1_op, condition1_value,
		 condition2_formula, condition2_op, condition2_value,
		 logic_cycles_reqs, logic_reqs_conds, logic_cond1_cond2,
		 linked_prototype_id, color)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		s.Name, s.SortOrder, s.CyclesFormula,
		s.Condition1Formula, s.Condition1Op, s.Condition1Value,
		s.Condition2Formula, s.Condition2Op, s.Condition2Value,
		s.LogicCyclesReqs, s.LogicReqsConds, s.LogicCond1Cond2,
		s.LinkedPrototypeID, s.Color,
	)
	if err != nil {
		return 0, fmt.Errorf("stage create: %w", err)
	}
	return res.LastInsertId()
}

// GetByID retrieves a stage by its ID.
func (r *StageRepo) GetByID(id int64) (*Stage, error) {
	s := &Stage{}
	err := r.db.Conn.QueryRow(
		`SELECT id, name, sort_order, cycles_formula,
		 condition1_formula, condition1_op, condition1_value,
		 condition2_formula, condition2_op, condition2_value,
		 logic_cycles_reqs, logic_reqs_conds, logic_cond1_cond2,
		 linked_prototype_id, color
		 FROM stages WHERE id = ?`, id,
	).Scan(&s.ID, &s.Name, &s.SortOrder, &s.CyclesFormula,
		&s.Condition1Formula, &s.Condition1Op, &s.Condition1Value,
		&s.Condition2Formula, &s.Condition2Op, &s.Condition2Value,
		&s.LogicCyclesReqs, &s.LogicReqsConds, &s.LogicCond1Cond2,
		&s.LinkedPrototypeID, &s.Color)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("stage get: %w", err)
	}
	return s, nil
}

// List returns all stages ordered by sort_order.
func (r *StageRepo) List() ([]Stage, error) {
	rows, err := r.db.Conn.Query(
		`SELECT id, name, sort_order, cycles_formula,
		 condition1_formula, condition1_op, condition1_value,
		 condition2_formula, condition2_op, condition2_value,
		 logic_cycles_reqs, logic_reqs_conds, logic_cond1_cond2,
		 linked_prototype_id, color
		 FROM stages ORDER BY sort_order`,
	)
	if err != nil {
		return nil, fmt.Errorf("stage list: %w", err)
	}
	defer rows.Close()

	var stages []Stage
	for rows.Next() {
		var s Stage
		if err := rows.Scan(&s.ID, &s.Name, &s.SortOrder, &s.CyclesFormula,
			&s.Condition1Formula, &s.Condition1Op, &s.Condition1Value,
			&s.Condition2Formula, &s.Condition2Op, &s.Condition2Value,
			&s.LogicCyclesReqs, &s.LogicReqsConds, &s.LogicCond1Cond2,
			&s.LinkedPrototypeID, &s.Color); err != nil {
			return nil, fmt.Errorf("stage scan: %w", err)
		}
		stages = append(stages, s)
	}
	return stages, rows.Err()
}

// Delete removes a stage.
func (r *StageRepo) Delete(id int64) error {
	_, err := r.db.Conn.Exec("DELETE FROM stages WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("stage delete: %w", err)
	}
	return nil
}
