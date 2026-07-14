package storage

import (
	"database/sql"
	"fmt"
)

// ResourceTypeRepo provides CRUD operations for resource types.
type ResourceTypeRepo struct {
	db *DB
}

// NewResourceTypeRepo creates a new ResourceTypeRepo.
func NewResourceTypeRepo(db *DB) *ResourceTypeRepo {
	return &ResourceTypeRepo{db: db}
}

// Create inserts a new resource type and returns its ID.
func (r *ResourceTypeRepo) Create(rt *ResourceType) (int64, error) {
	oviposition := 0
	if rt.IsOviposition {
		oviposition = 1
	}
	res, err := r.db.Conn.Exec(
		`INSERT INTO resource_types (name, nutrient_id, is_oviposition, color, sort_order)
		 VALUES (?, ?, ?, ?, ?)`,
		rt.Name, rt.NutrientID, oviposition, rt.Color, rt.SortOrder,
	)
	if err != nil {
		return 0, fmt.Errorf("resource_type create: %w", err)
	}
	return res.LastInsertId()
}

// GetByID retrieves a resource type by its ID.
func (r *ResourceTypeRepo) GetByID(id int64) (*ResourceType, error) {
	rt := &ResourceType{}
	var oviposition int
	err := r.db.Conn.QueryRow(
		`SELECT id, name, nutrient_id, is_oviposition, color, sort_order
		 FROM resource_types WHERE id = ?`, id,
	).Scan(&rt.ID, &rt.Name, &rt.NutrientID, &oviposition, &rt.Color, &rt.SortOrder)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("resource_type get: %w", err)
	}
	rt.IsOviposition = oviposition == 1
	return rt, nil
}

// List returns all resource types ordered by sort_order.
func (r *ResourceTypeRepo) List() ([]ResourceType, error) {
	rows, err := r.db.Conn.Query(
		`SELECT id, name, nutrient_id, is_oviposition, color, sort_order
		 FROM resource_types ORDER BY sort_order`,
	)
	if err != nil {
		return nil, fmt.Errorf("resource_type list: %w", err)
	}
	defer rows.Close()

	var types []ResourceType
	for rows.Next() {
		var rt ResourceType
		var oviposition int
		if err := rows.Scan(&rt.ID, &rt.Name, &rt.NutrientID, &oviposition, &rt.Color, &rt.SortOrder); err != nil {
			return nil, fmt.Errorf("resource_type scan: %w", err)
		}
		rt.IsOviposition = oviposition == 1
		types = append(types, rt)
	}
	return types, rows.Err()
}

// Delete removes a resource type.
func (r *ResourceTypeRepo) Delete(id int64) error {
	_, err := r.db.Conn.Exec("DELETE FROM resource_types WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("resource_type delete: %w", err)
	}
	return nil
}
