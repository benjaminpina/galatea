package storage

import (
	"database/sql"
	"fmt"
)

// ProjectInfoRepo provides operations for the project_info singleton.
type ProjectInfoRepo struct {
	db *DB
}

// NewProjectInfoRepo creates a new ProjectInfoRepo.
func NewProjectInfoRepo(db *DB) *ProjectInfoRepo {
	return &ProjectInfoRepo{db: db}
}

// Init creates the project info record. Call once when creating a new workspace.
func (r *ProjectInfoRepo) Init(name, description string) error {
	_, err := r.db.Conn.Exec(
		"INSERT INTO project_info (id, name, description) VALUES (1, ?, ?)",
		name, description,
	)
	if err != nil {
		return fmt.Errorf("project_info init: %w", err)
	}
	return nil
}

// Get retrieves the project info.
func (r *ProjectInfoRepo) Get() (*ProjectInfo, error) {
	p := &ProjectInfo{}
	err := r.db.Conn.QueryRow(
		"SELECT name, description, created_at, updated_at FROM project_info WHERE id = 1",
	).Scan(&p.Name, &p.Description, &p.CreatedAt, &p.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("project_info get: %w", err)
	}
	return p, nil
}

// Update modifies the project info.
func (r *ProjectInfoRepo) Update(name, description string) error {
	_, err := r.db.Conn.Exec(
		"UPDATE project_info SET name = ?, description = ?, updated_at = datetime('now') WHERE id = 1",
		name, description,
	)
	if err != nil {
		return fmt.Errorf("project_info update: %w", err)
	}
	return nil
}
