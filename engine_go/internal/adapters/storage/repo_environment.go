package storage

import (
	"database/sql"
	"fmt"
)

// EnvironmentRepo provides CRUD operations for environments and their placed elements.
type EnvironmentRepo struct {
	db *DB
}

// NewEnvironmentRepo creates a new EnvironmentRepo.
func NewEnvironmentRepo(db *DB) *EnvironmentRepo {
	return &EnvironmentRepo{db: db}
}

// Create inserts a new environment and returns its ID.
func (r *EnvironmentRepo) Create(name string, width, height int, description string) (int64, error) {
	res, err := r.db.Conn.Exec(
		`INSERT INTO environments (name, width, height, description) VALUES (?, ?, ?, ?)`,
		name, width, height, description,
	)
	if err != nil {
		return 0, fmt.Errorf("environment create: %w", err)
	}
	return res.LastInsertId()
}

// GetByID retrieves an environment by its ID.
func (r *EnvironmentRepo) GetByID(id int64) (*Environment, error) {
	e := &Environment{}
	err := r.db.Conn.QueryRow(
		`SELECT id, name, width, height, description, created_at, updated_at
		 FROM environments WHERE id = ?`, id,
	).Scan(&e.ID, &e.Name, &e.Width, &e.Height, &e.Description, &e.CreatedAt, &e.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("environment get: %w", err)
	}
	return e, nil
}

// List returns all environments.
func (r *EnvironmentRepo) List() ([]Environment, error) {
	rows, err := r.db.Conn.Query(
		`SELECT id, name, width, height, description, created_at, updated_at
		 FROM environments ORDER BY id`,
	)
	if err != nil {
		return nil, fmt.Errorf("environment list: %w", err)
	}
	defer rows.Close()

	var envs []Environment
	for rows.Next() {
		var e Environment
		if err := rows.Scan(&e.ID, &e.Name, &e.Width, &e.Height, &e.Description, &e.CreatedAt, &e.UpdatedAt); err != nil {
			return nil, fmt.Errorf("environment scan: %w", err)
		}
		envs = append(envs, e)
	}
	return envs, rows.Err()
}

// Delete removes an environment and all its placed elements (cascade).
func (r *EnvironmentRepo) Delete(id int64) error {
	_, err := r.db.Conn.Exec("DELETE FROM environments WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("environment delete: %w", err)
	}
	return nil
}

// PlaceResource adds a resource instance to an environment.
func (r *EnvironmentRepo) PlaceResource(er *EnvironmentResource) (int64, error) {
	res, err := r.db.Conn.Exec(
		`INSERT INTO environment_resources (environment_id, resource_type_id, name, pos_x, pos_y, quality, level, max_level, regen_rate)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		er.EnvironmentID, er.ResourceTypeID, er.Name, er.PosX, er.PosY, er.Quality, er.Level, er.MaxLevel, er.RegenRate,
	)
	if err != nil {
		return 0, fmt.Errorf("environment resource place: %w", err)
	}
	return res.LastInsertId()
}

// ListResources returns all resource instances in an environment.
func (r *EnvironmentRepo) ListResources(environmentID int64) ([]EnvironmentResource, error) {
	rows, err := r.db.Conn.Query(
		`SELECT id, environment_id, resource_type_id, name, pos_x, pos_y, quality, level, max_level, regen_rate
		 FROM environment_resources WHERE environment_id = ? ORDER BY id`, environmentID,
	)
	if err != nil {
		return nil, fmt.Errorf("environment resources list: %w", err)
	}
	defer rows.Close()

	var resources []EnvironmentResource
	for rows.Next() {
		var er EnvironmentResource
		if err := rows.Scan(&er.ID, &er.EnvironmentID, &er.ResourceTypeID, &er.Name,
			&er.PosX, &er.PosY, &er.Quality, &er.Level, &er.MaxLevel, &er.RegenRate); err != nil {
			return nil, fmt.Errorf("environment resource scan: %w", err)
		}
		resources = append(resources, er)
	}
	return resources, rows.Err()
}

// PlaceAgent adds an initial agent to an environment.
func (r *EnvironmentRepo) PlaceAgent(ea *EnvironmentAgent) (int64, error) {
	res, err := r.db.Conn.Exec(
		`INSERT INTO environment_agents (environment_id, name, pos_x, pos_y, stage_id, prototype_id, sex, age)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
		ea.EnvironmentID, ea.Name, ea.PosX, ea.PosY, ea.StageID, ea.PrototypeID, ea.Sex, ea.Age,
	)
	if err != nil {
		return 0, fmt.Errorf("environment agent place: %w", err)
	}
	return res.LastInsertId()
}

// ListAgents returns all initial agents in an environment.
func (r *EnvironmentRepo) ListAgents(environmentID int64) ([]EnvironmentAgent, error) {
	rows, err := r.db.Conn.Query(
		`SELECT id, environment_id, name, pos_x, pos_y, stage_id, prototype_id, sex, age
		 FROM environment_agents WHERE environment_id = ? ORDER BY id`, environmentID,
	)
	if err != nil {
		return nil, fmt.Errorf("environment agents list: %w", err)
	}
	defer rows.Close()

	var agents []EnvironmentAgent
	for rows.Next() {
		var ea EnvironmentAgent
		if err := rows.Scan(&ea.ID, &ea.EnvironmentID, &ea.Name, &ea.PosX, &ea.PosY,
			&ea.StageID, &ea.PrototypeID, &ea.Sex, &ea.Age); err != nil {
			return nil, fmt.Errorf("environment agent scan: %w", err)
		}
		agents = append(agents, ea)
	}
	return agents, rows.Err()
}
