package storage

import (
	"database/sql"
	"fmt"
)

// SimRunRepo provides CRUD operations for simulation runs.
type SimRunRepo struct {
	db *DB
}

// NewSimRunRepo creates a new SimRunRepo.
func NewSimRunRepo(db *DB) *SimRunRepo {
	return &SimRunRepo{db: db}
}

// Create inserts a new simulation run and returns its ID.
func (r *SimRunRepo) Create(environmentID int64) (int64, error) {
	res, err := r.db.Conn.Exec(
		"INSERT INTO sim_runs (environment_id) VALUES (?)", environmentID,
	)
	if err != nil {
		return 0, fmt.Errorf("sim_run create: %w", err)
	}
	return res.LastInsertId()
}

// GetByID retrieves a simulation run by its ID.
func (r *SimRunRepo) GetByID(id int64) (*SimRun, error) {
	sr := &SimRun{}
	err := r.db.Conn.QueryRow(
		`SELECT id, environment_id, started_at, ended_at, total_ticks, status
		 FROM sim_runs WHERE id = ?`, id,
	).Scan(&sr.ID, &sr.EnvironmentID, &sr.StartedAt, &sr.EndedAt, &sr.TotalTicks, &sr.Status)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("sim_run get: %w", err)
	}
	return sr, nil
}

// Finish marks a simulation run as finished with the given tick count.
func (r *SimRunRepo) Finish(id int64, totalTicks int, status string) error {
	_, err := r.db.Conn.Exec(
		"UPDATE sim_runs SET ended_at = datetime('now'), total_ticks = ?, status = ? WHERE id = ?",
		totalTicks, status, id,
	)
	if err != nil {
		return fmt.Errorf("sim_run finish: %w", err)
	}
	return nil
}

// ListByEnvironment returns all simulation runs for an environment.
func (r *SimRunRepo) ListByEnvironment(environmentID int64) ([]SimRun, error) {
	rows, err := r.db.Conn.Query(
		`SELECT id, environment_id, started_at, ended_at, total_ticks, status
		 FROM sim_runs WHERE environment_id = ? ORDER BY id`, environmentID,
	)
	if err != nil {
		return nil, fmt.Errorf("sim_run list: %w", err)
	}
	defer rows.Close()

	var runs []SimRun
	for rows.Next() {
		var sr SimRun
		if err := rows.Scan(&sr.ID, &sr.EnvironmentID, &sr.StartedAt, &sr.EndedAt, &sr.TotalTicks, &sr.Status); err != nil {
			return nil, fmt.Errorf("sim_run scan: %w", err)
		}
		runs = append(runs, sr)
	}
	return runs, rows.Err()
}
