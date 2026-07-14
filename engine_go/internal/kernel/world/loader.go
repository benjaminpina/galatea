package world

import (
	"fmt"

	"galatea/engine/internal/adapters/storage"
)

// Load reads the project configuration and an environment from the database,
// constructs a fully allocated World, and populates it with initial agents
// and resources. This is the Cold Path entry point.
func Load(db *storage.DB, environmentID int64) (*World, error) {
	cfg, err := loadConfig(db, environmentID)
	if err != nil {
		return nil, fmt.Errorf("load config: %w", err)
	}

	w := New(cfg)

	if err := loadSubstrateMap(db, w, environmentID); err != nil {
		return nil, fmt.Errorf("load substrate map: %w", err)
	}

	if err := loadResources(db, w, environmentID); err != nil {
		return nil, fmt.Errorf("load resources: %w", err)
	}

	if err := loadAgents(db, w, environmentID); err != nil {
		return nil, fmt.Errorf("load agents: %w", err)
	}

	return w, nil
}

// loadConfig reads dimensional information from the database to build Config.
func loadConfig(db *storage.DB, environmentID int64) (Config, error) {
	cfg := DefaultConfig()

	// Project name.
	projRepo := storage.NewProjectInfoRepo(db)
	proj, err := projRepo.Get()
	if err != nil {
		return cfg, err
	}
	if proj != nil {
		cfg.ProjectName = proj.Name
	}

	// Nutrients.
	nutRepo := storage.NewNutrientRepo(db)
	nutrients, err := nutRepo.List()
	if err != nil {
		return cfg, err
	}
	cfg.NumNutrients = len(nutrients)

	// Loci.
	locRepo := storage.NewLocusRepo(db)
	loci, err := locRepo.List()
	if err != nil {
		return cfg, err
	}
	cfg.NumLoci = len(loci)

	// Stages.
	stageRepo := storage.NewStageRepo(db)
	stages, err := stageRepo.List()
	if err != nil {
		return cfg, err
	}
	cfg.NumStages = len(stages)

	// Prototypes.
	protoRepo := storage.NewPrototypeRepo(db)
	males, err := protoRepo.List("M")
	if err != nil {
		return cfg, err
	}
	females, err := protoRepo.List("F")
	if err != nil {
		return cfg, err
	}
	cfg.NumPrototypesM = len(males)
	cfg.NumPrototypesF = len(females)
	cfg.NumPrototypes = cfg.NumStages + cfg.NumPrototypesM + cfg.NumPrototypesF

	// Resource types.
	rtRepo := storage.NewResourceTypeRepo(db)
	resourceTypes, err := rtRepo.List()
	if err != nil {
		return cfg, err
	}
	cfg.NumResourceTypes = len(resourceTypes)

	// Substrates.
	subRepo := storage.NewSubstrateRepo(db)
	substrates, err := subRepo.List()
	if err != nil {
		return cfg, err
	}
	cfg.NumSubstrates = len(substrates)

	// Environment dimensions.
	envRepo := storage.NewEnvironmentRepo(db)
	env, err := envRepo.GetByID(environmentID)
	if err != nil {
		return cfg, err
	}
	if env == nil {
		return cfg, fmt.Errorf("environment %d not found", environmentID)
	}
	cfg.GridWidth = env.Width
	cfg.GridHeight = env.Height

	// Behaviors: move + rest + feed×NumResourceTypes + fight×2 + court×2 + oviposit + die
	cfg.NumBehaviors = 2 + cfg.NumResourceTypes + 2 + 2 + 1 + 1
	// Minimum of 12 for compatibility with the base behavioral model.
	if cfg.NumBehaviors < 12 {
		cfg.NumBehaviors = 12
	}

	return cfg, nil
}

// loadSubstrateMap reads the substrate map rows from the DB and fills the grid.
func loadSubstrateMap(db *storage.DB, w *World, environmentID int64) error {
	rows, err := db.Conn.Query(
		"SELECT y_coord, map_data FROM substrate_map_rows WHERE environment_id = ? ORDER BY y_coord",
		environmentID,
	)
	if err != nil {
		return err
	}
	defer rows.Close()

	for rows.Next() {
		var y int
		var data string
		if err := rows.Scan(&y, &data); err != nil {
			return err
		}
		// Parse comma-separated substrate IDs.
		x := 0
		num := int32(0)
		for _, ch := range data {
			if ch == ',' {
				if x < w.Substrates.Width {
					w.Substrates.Set(x, y, num)
				}
				x++
				num = 0
			} else if ch >= '0' && ch <= '9' {
				num = num*10 + int32(ch-'0')
			}
		}
		// Handle last value (no trailing comma).
		if x < w.Substrates.Width {
			w.Substrates.Set(x, y, num)
		}
	}
	return rows.Err()
}

// loadResources reads environment_resources and populates ResourceArrays.
func loadResources(db *storage.DB, w *World, environmentID int64) error {
	envRepo := storage.NewEnvironmentRepo(db)
	resources, err := envRepo.ListResources(environmentID)
	if err != nil {
		return err
	}

	for _, r := range resources {
		idx := w.Resources.Count
		if idx >= w.Resources.Cap {
			// Grow resource arrays.
			newCap := w.Resources.Cap * 2
			if newCap == 0 {
				newCap = 64
			}
			w.Resources.PosX = growF64(w.Resources.PosX, newCap)
			w.Resources.PosY = growF64(w.Resources.PosY, newCap)
			w.Resources.TypeID = growI32(w.Resources.TypeID, newCap)
			w.Resources.Level = growI32(w.Resources.Level, newCap)
			w.Resources.MaxLevel = growI32(w.Resources.MaxLevel, newCap)
			w.Resources.Quality = growI32(w.Resources.Quality, newCap)
			w.Resources.RegenRate = growF64(w.Resources.RegenRate, newCap)
			w.Resources.Cap = newCap
		}

		w.Resources.PosX[idx] = float64(r.PosX)
		w.Resources.PosY[idx] = float64(r.PosY)
		w.Resources.TypeID[idx] = int32(r.ResourceTypeID - 1) // Convert 1-based DB ID to 0-based index.
		w.Resources.Level[idx] = int32(r.Level)
		w.Resources.MaxLevel[idx] = int32(r.MaxLevel)
		w.Resources.Quality[idx] = int32(r.Quality)
		w.Resources.RegenRate[idx] = r.RegenRate
		w.Resources.Count++
	}

	return nil
}

// loadAgents reads environment_agents and populates AgentArrays.
func loadAgents(db *storage.DB, w *World, environmentID int64) error {
	envRepo := storage.NewEnvironmentRepo(db)
	agents, err := envRepo.ListAgents(environmentID)
	if err != nil {
		return err
	}

	for _, a := range agents {
		idx := w.AddAgent()

		w.Agents.PosX[idx] = float64(a.PosX)
		w.Agents.PosY[idx] = float64(a.PosY)
		w.Agents.Age[idx] = int32(a.Age)

		switch a.Sex {
		case "M":
			w.Agents.Sex[idx] = SexMale
		case "F":
			w.Agents.Sex[idx] = SexFemale
		default:
			w.Agents.Sex[idx] = SexUndefined
		}

		if a.StageID != nil {
			w.Agents.StageID[idx] = int32(*a.StageID - 1) // 1-based to 0-based.
			w.Agents.Situation[idx] = SituationImmature
		}
		if a.PrototypeID != nil {
			w.Agents.PrototypeID[idx] = int32(*a.PrototypeID - 1)
			w.Agents.Situation[idx] = SituationRegular
		}

		// Initialize reserves to 0 (will be set by formula evaluation in the engine setup).
	}

	return nil
}
