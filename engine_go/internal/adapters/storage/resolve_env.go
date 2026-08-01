package storage

import "fmt"

// ResolveEnvironment finds the environment to simulate.
// Priority: explicit ID > name match > auto-select if only one exists.
func ResolveEnvironment(db *DB, envName string, envID int64) (int64, string, error) {
	// If explicit ID given, use it.
	if envID > 0 {
		var name string
		err := db.Conn.QueryRow("SELECT name FROM environments WHERE id = ?", envID).Scan(&name)
		if err != nil {
			return 0, "", fmt.Errorf("environment with id %d not found", envID)
		}
		return envID, name, nil
	}

	// If name given, find by name.
	if envName != "" {
		var id int64
		err := db.Conn.QueryRow("SELECT id FROM environments WHERE name = ?", envName).Scan(&id)
		if err != nil {
			return 0, "", fmt.Errorf("environment %q not found", envName)
		}
		return id, envName, nil
	}

	// Auto-select: if exactly one environment exists, use it.
	rows, err := db.Conn.Query("SELECT id, name FROM environments ORDER BY id")
	if err != nil {
		return 0, "", fmt.Errorf("query environments: %w", err)
	}
	defer rows.Close()

	var envs []struct {
		id   int64
		name string
	}
	for rows.Next() {
		var e struct {
			id   int64
			name string
		}
		if err := rows.Scan(&e.id, &e.name); err != nil {
			return 0, "", err
		}
		envs = append(envs, e)
	}
	if err := rows.Err(); err != nil {
		return 0, "", err
	}

	switch len(envs) {
	case 0:
		return 0, "", fmt.Errorf("no environments defined in project")
	case 1:
		return envs[0].id, envs[0].name, nil
	default:
		names := ""
		for i, e := range envs {
			if i > 0 {
				names += ", "
			}
			names += fmt.Sprintf("%q (id=%d)", e.name, e.id)
		}
		return 0, "", fmt.Errorf("multiple environments found, specify one with --env or --env-id: %s", names)
	}
}
