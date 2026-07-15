-- Galatea Simulation Suite - Initial Database Schema
-- This schema defines a single project workspace database.
-- Each project lives in its own .db file under workspaces/<project_name>/galatea.db
-- Note: PRAGMAs are set at connection time by the application, not here.
--
-- Design: Each NUTRIENT implicitly defines its corresponding resource source.
-- Oviposition sites are a separate concept (they receive, not provide).

-- =============================================================================
-- PROJECT METADATA (singleton — one row per database)
-- =============================================================================

CREATE TABLE IF NOT EXISTS project_info (
    id          INTEGER PRIMARY KEY CHECK(id = 1),
    name        TEXT    NOT NULL,
    description TEXT    NOT NULL DEFAULT '',
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- =============================================================================
-- NUTRIENTS (dynamic: 0..N)
-- Each nutrient IS also the definition of its resource source type.
-- When you define "Water", you implicitly define "Water sources" in the environment.
-- =============================================================================

CREATE TABLE IF NOT EXISTS nutrients (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT    NOT NULL UNIQUE,
    color      INTEGER NOT NULL DEFAULT 0,       -- Color for rendering sources in visualizer.
    sort_order INTEGER NOT NULL DEFAULT 0
);

-- =============================================================================
-- OVIPOSITION SITES (separate concept — receives eggs, does NOT provide nutrients)
-- =============================================================================

CREATE TABLE IF NOT EXISTS oviposition_site_config (
    id    INTEGER PRIMARY KEY CHECK(id = 1),  -- singleton config
    color INTEGER NOT NULL DEFAULT 0x00FF00,  -- Render color for sites.
    enabled INTEGER NOT NULL DEFAULT 1        -- Whether oviposition is available.
);

-- =============================================================================
-- SUBSTRATES
-- =============================================================================

CREATE TABLE IF NOT EXISTS substrates (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT    NOT NULL UNIQUE,
    color      INTEGER NOT NULL DEFAULT 0,
    is_mixed   INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS substrate_compositions (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    mixed_substrate_id   INTEGER NOT NULL REFERENCES substrates(id) ON DELETE CASCADE,
    simple_substrate_id  INTEGER NOT NULL REFERENCES substrates(id) ON DELETE CASCADE,
    percentage           INTEGER NOT NULL DEFAULT 0 CHECK(percentage >= 0 AND percentage <= 100)
);

-- =============================================================================
-- ENVIRONMENTS (scenario grid)
-- =============================================================================

CREATE TABLE IF NOT EXISTS environments (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL UNIQUE,
    width       INTEGER NOT NULL CHECK(width > 0),
    height      INTEGER NOT NULL CHECK(height > 0),
    description TEXT    NOT NULL DEFAULT '',
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS substrate_map_rows (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    y_coord        INTEGER NOT NULL,
    map_data       TEXT    NOT NULL,
    UNIQUE(environment_id, y_coord)
);

-- =============================================================================
-- GENETIC LOCI (dynamic: 0..N)
-- =============================================================================

CREATE TABLE IF NOT EXISTS loci (
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    name                  TEXT    NOT NULL UNIQUE,
    is_continuous         INTEGER NOT NULL DEFAULT 1,
    dominant_value        REAL    NOT NULL DEFAULT 0,
    recessive_value       REAL    NOT NULL DEFAULT 0,
    mutation_rate_dom     REAL    NOT NULL DEFAULT 0,
    mutation_rate_rec     REAL    NOT NULL DEFAULT 0,
    mutation_range_dom    REAL    NOT NULL DEFAULT 0,
    mutation_range_rec    REAL    NOT NULL DEFAULT 0,
    default_expression    TEXT    NOT NULL DEFAULT '0',
    sort_order            INTEGER NOT NULL DEFAULT 0
);

-- =============================================================================
-- LIFE STAGES (dynamic: 0..N)
-- =============================================================================

CREATE TABLE IF NOT EXISTS stages (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    name               TEXT    NOT NULL UNIQUE,
    sort_order         INTEGER NOT NULL DEFAULT 0,
    cycles_formula     TEXT    NOT NULL DEFAULT '100',
    condition1_formula TEXT    NOT NULL DEFAULT '0',
    condition1_op      TEXT    NOT NULL DEFAULT '>',
    condition1_value   REAL    NOT NULL DEFAULT 0,
    condition2_formula TEXT    NOT NULL DEFAULT '0',
    condition2_op      TEXT    NOT NULL DEFAULT '>',
    condition2_value   REAL    NOT NULL DEFAULT 0,
    logic_cycles_reqs  TEXT    NOT NULL DEFAULT 'AND',
    logic_reqs_conds   TEXT    NOT NULL DEFAULT 'AND',
    logic_cond1_cond2  TEXT    NOT NULL DEFAULT 'AND',
    linked_prototype_id INTEGER DEFAULT NULL,
    color              INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS stage_nutrient_requirements (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    stage_id     INTEGER NOT NULL REFERENCES stages(id) ON DELETE CASCADE,
    nutrient_id  INTEGER NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
    requirement_formula TEXT NOT NULL DEFAULT '0',
    cost_formula        TEXT NOT NULL DEFAULT '0',
    UNIQUE(stage_id, nutrient_id)
);

CREATE TABLE IF NOT EXISTS stage_tendencies (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    stage_id  INTEGER NOT NULL REFERENCES stages(id) ON DELETE CASCADE,
    direction INTEGER NOT NULL CHECK(direction >= 1 AND direction <= 8),
    formula   TEXT    NOT NULL DEFAULT '1',
    UNIQUE(stage_id, direction)
);

-- =============================================================================
-- PROTOTYPES (adult archetypes, dynamic: 0..N per sex)
-- =============================================================================

CREATE TABLE IF NOT EXISTS prototypes (
    id                       INTEGER PRIMARY KEY AUTOINCREMENT,
    name                     TEXT    NOT NULL UNIQUE,
    sex                      TEXT    NOT NULL CHECK(sex IN ('M', 'F')),
    color                    INTEGER NOT NULL DEFAULT 0,
    longevity_formula        TEXT    NOT NULL DEFAULT '1000',
    refractory_combat_formula  TEXT  NOT NULL DEFAULT '10',
    refractory_courtship_formula TEXT NOT NULL DEFAULT '10',
    sex_ratio_males_formula  TEXT    NOT NULL DEFAULT '50',
    sex_ratio_females_formula TEXT   NOT NULL DEFAULT '50',
    sort_order               INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS prototype_morphology (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    prototype_id        INTEGER NOT NULL REFERENCES prototypes(id) ON DELETE CASCADE,
    locus_id            INTEGER NOT NULL REFERENCES loci(id) ON DELETE CASCADE,
    genetic_formula     TEXT    NOT NULL DEFAULT '0',
    environmental_formula TEXT  NOT NULL DEFAULT '0',
    UNIQUE(prototype_id, locus_id)
);

CREATE TABLE IF NOT EXISTS prototype_tendencies (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    prototype_id INTEGER NOT NULL REFERENCES prototypes(id) ON DELETE CASCADE,
    direction    INTEGER NOT NULL CHECK(direction >= 1 AND direction <= 8),
    formula      TEXT    NOT NULL DEFAULT '1',
    UNIQUE(prototype_id, direction)
);

CREATE TABLE IF NOT EXISTS prototype_combat (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    prototype_id    INTEGER NOT NULL REFERENCES prototypes(id) ON DELETE CASCADE,
    action          INTEGER NOT NULL,
    opponent_action INTEGER NOT NULL,
    formula         TEXT    NOT NULL DEFAULT '1',
    UNIQUE(prototype_id, action, opponent_action)
);

CREATE TABLE IF NOT EXISTS prototype_courtship (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    prototype_id    INTEGER NOT NULL REFERENCES prototypes(id) ON DELETE CASCADE,
    action          INTEGER NOT NULL,
    opponent_action INTEGER NOT NULL,
    formula         TEXT    NOT NULL DEFAULT '1',
    UNIQUE(prototype_id, action, opponent_action)
);

CREATE TABLE IF NOT EXISTS prototype_assignment_criteria (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    prototype_id    INTEGER NOT NULL REFERENCES prototypes(id) ON DELETE CASCADE,
    priority        INTEGER NOT NULL DEFAULT 0,
    formula         TEXT    NOT NULL DEFAULT '0',
    operator        TEXT    NOT NULL DEFAULT '>',
    threshold       REAL    NOT NULL DEFAULT 0,
    UNIQUE(prototype_id, priority)
);

-- =============================================================================
-- METABOLISM CONFIGURATION
-- =============================================================================

-- Metabolic levels per nutrient.
CREATE TABLE IF NOT EXISTS metabolism (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    nutrient_id  INTEGER NOT NULL UNIQUE REFERENCES nutrients(id) ON DELETE CASCADE,
    min_formula      TEXT NOT NULL DEFAULT '0',
    critical_formula TEXT NOT NULL DEFAULT '10',
    optimal_formula  TEXT NOT NULL DEFAULT '50',
    initial_formula  TEXT NOT NULL DEFAULT '50',
    max_formula      TEXT NOT NULL DEFAULT '100'
);

-- Behavior costs per nutrient.
CREATE TABLE IF NOT EXISTS behavior_costs (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    behavior      TEXT    NOT NULL,
    nutrient_id   INTEGER NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
    cost_formula  TEXT    NOT NULL DEFAULT '0',
    UNIQUE(behavior, nutrient_id)
);

-- Feeding gains: how much nutrient is gained when feeding from its source.
-- Each nutrient has exactly one gain formula (the source IS the nutrient).
CREATE TABLE IF NOT EXISTS feeding_gains (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    nutrient_id  INTEGER NOT NULL UNIQUE REFERENCES nutrients(id) ON DELETE CASCADE,
    gain_formula TEXT    NOT NULL DEFAULT '10'
);

-- Substrate velocities.
CREATE TABLE IF NOT EXISTS substrate_velocities (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    substrate_id  INTEGER NOT NULL UNIQUE REFERENCES substrates(id) ON DELETE CASCADE,
    velocity_formula TEXT NOT NULL DEFAULT '1'
);

-- =============================================================================
-- REPRODUCTION CONFIGURATION (singleton)
-- =============================================================================

CREATE TABLE IF NOT EXISTS reproduction (
    id                          INTEGER PRIMARY KEY CHECK(id = 1),
    max_eggs_formula            TEXT NOT NULL DEFAULT '10',
    max_sperm_packs_formula     TEXT NOT NULL DEFAULT '10',
    packs_transferred_formula   TEXT NOT NULL DEFAULT '1',
    fraction_fertilized_formula TEXT NOT NULL DEFAULT '0.5',
    paternity_formula           TEXT NOT NULL DEFAULT '100',
    max_stored_packs_formula    TEXT NOT NULL DEFAULT '5',
    consumption_rate_formula    TEXT NOT NULL DEFAULT '0.1',
    eggs_per_cycle_formula      TEXT NOT NULL DEFAULT '1',
    egg_fraction_formula        TEXT NOT NULL DEFAULT '0.5',
    pack_fraction_formula       TEXT NOT NULL DEFAULT '0.5',
    sperm_degradation_formula   TEXT NOT NULL DEFAULT '0.05'
);

-- Gamete costs per nutrient.
CREATE TABLE IF NOT EXISTS gamete_costs (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    sex          TEXT    NOT NULL CHECK(sex IN ('M', 'F')),
    nutrient_id  INTEGER NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
    cost_formula TEXT    NOT NULL DEFAULT '5',
    UNIQUE(sex, nutrient_id)
);

-- =============================================================================
-- INTERACTION MATRICES
-- =============================================================================

-- Substrate interaction.
CREATE TABLE IF NOT EXISTS interaction_substrates (
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id         INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    substrate_id           INTEGER NOT NULL REFERENCES substrates(id) ON DELETE CASCADE,
    perceiver_stage_id     INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    perceiver_prototype_id INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    behavior_index         INTEGER NOT NULL,
    formula                TEXT    NOT NULL DEFAULT '0'
);

-- Substrate attractiveness.
CREATE TABLE IF NOT EXISTS attractiveness_substrates (
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id         INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    substrate_id           INTEGER NOT NULL REFERENCES substrates(id) ON DELETE CASCADE,
    perceiver_stage_id     INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    perceiver_prototype_id INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    attractiveness_formula TEXT NOT NULL DEFAULT '0',
    radius_formula         TEXT NOT NULL DEFAULT '5'
);

-- Nutrient source interaction (replaces resource_type interaction).
CREATE TABLE IF NOT EXISTS interaction_sources (
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id         INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    nutrient_id            INTEGER NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
    perceiver_stage_id     INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    perceiver_prototype_id INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    behavior_index         INTEGER NOT NULL,
    formula                TEXT    NOT NULL DEFAULT '0'
);

-- Nutrient source attractiveness.
CREATE TABLE IF NOT EXISTS attractiveness_sources (
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id         INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    nutrient_id            INTEGER NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
    perceiver_stage_id     INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    perceiver_prototype_id INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    attractiveness_formula TEXT NOT NULL DEFAULT '0',
    radius_formula         TEXT NOT NULL DEFAULT '5'
);

-- Agent interaction.
CREATE TABLE IF NOT EXISTS interaction_agents (
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id         INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    observed_stage_id      INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    observed_prototype_id  INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    perceiver_stage_id     INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    perceiver_prototype_id INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    behavior_index         INTEGER NOT NULL,
    formula                TEXT    NOT NULL DEFAULT '0'
);

-- Agent attractiveness.
CREATE TABLE IF NOT EXISTS attractiveness_agents (
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id         INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    observed_stage_id      INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    observed_prototype_id  INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    perceiver_stage_id     INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    perceiver_prototype_id INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    attractiveness_formula TEXT NOT NULL DEFAULT '0',
    radius_formula         TEXT NOT NULL DEFAULT '5'
);

-- Memory influence matrices.
CREATE TABLE IF NOT EXISTS memory_influence (
    id                     INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id         INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    memory_type            TEXT    NOT NULL,
    element_index          INTEGER NOT NULL,
    perceiver_stage_id     INTEGER REFERENCES stages(id) ON DELETE CASCADE,
    perceiver_prototype_id INTEGER REFERENCES prototypes(id) ON DELETE CASCADE,
    formula                TEXT    NOT NULL DEFAULT '0'
);

-- =============================================================================
-- ENVIRONMENT INSTANCES (placed elements)
-- =============================================================================

-- Nutrient source instances placed in the environment.
-- Each source provides a specific nutrient (the FK directly to nutrients).
CREATE TABLE IF NOT EXISTS environment_sources (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id   INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    nutrient_id      INTEGER NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
    name             TEXT    NOT NULL,
    pos_x            INTEGER NOT NULL,
    pos_y            INTEGER NOT NULL,
    quality          INTEGER NOT NULL DEFAULT 10,
    level            INTEGER NOT NULL DEFAULT 50,
    max_level        INTEGER NOT NULL DEFAULT 100,
    regen_rate       REAL    NOT NULL DEFAULT 1.1
);

-- Oviposition site instances placed in the environment.
CREATE TABLE IF NOT EXISTS environment_oviposition_sites (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id   INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    name             TEXT    NOT NULL,
    pos_x            INTEGER NOT NULL,
    pos_y            INTEGER NOT NULL,
    quality          INTEGER NOT NULL DEFAULT 10,
    capacity         INTEGER NOT NULL DEFAULT 50
);

-- Initial agent population.
CREATE TABLE IF NOT EXISTS environment_agents (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id  INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    name            TEXT    NOT NULL,
    pos_x           INTEGER NOT NULL,
    pos_y           INTEGER NOT NULL,
    stage_id        INTEGER REFERENCES stages(id),
    prototype_id    INTEGER REFERENCES prototypes(id),
    sex             TEXT    NOT NULL CHECK(sex IN ('M', 'F', 'U')),
    age             INTEGER NOT NULL DEFAULT 0
);

-- =============================================================================
-- SIMULATION RUNS AND RESULTS
-- =============================================================================

CREATE TABLE IF NOT EXISTS sim_runs (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    environment_id  INTEGER NOT NULL REFERENCES environments(id) ON DELETE CASCADE,
    started_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    ended_at        TEXT,
    total_ticks     INTEGER NOT NULL DEFAULT 0,
    status          TEXT    NOT NULL DEFAULT 'running' CHECK(status IN ('running', 'paused', 'finished', 'aborted'))
);

CREATE TABLE IF NOT EXISTS sim_tick_counts (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id       INTEGER NOT NULL REFERENCES sim_runs(id) ON DELETE CASCADE,
    tick         INTEGER NOT NULL,
    stage_id     INTEGER REFERENCES stages(id),
    prototype_id INTEGER REFERENCES prototypes(id),
    count        INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS sim_events (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id      INTEGER NOT NULL REFERENCES sim_runs(id) ON DELETE CASCADE,
    tick        INTEGER NOT NULL,
    event_type  TEXT    NOT NULL,
    agent_name  TEXT,
    details     TEXT
);

CREATE TABLE IF NOT EXISTS sim_snapshots (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id      INTEGER NOT NULL REFERENCES sim_runs(id) ON DELETE CASCADE,
    tick        INTEGER NOT NULL,
    state_data  BLOB    NOT NULL,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- =============================================================================
-- INDEXES
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_nutrients_sort ON nutrients(sort_order);
CREATE INDEX IF NOT EXISTS idx_substrates_sort ON substrates(sort_order);
CREATE INDEX IF NOT EXISTS idx_loci_sort ON loci(sort_order);
CREATE INDEX IF NOT EXISTS idx_stages_sort ON stages(sort_order);
CREATE INDEX IF NOT EXISTS idx_prototypes_sex_sort ON prototypes(sex, sort_order);
CREATE INDEX IF NOT EXISTS idx_sim_runs_environment ON sim_runs(environment_id);
CREATE INDEX IF NOT EXISTS idx_sim_tick_counts_run_tick ON sim_tick_counts(run_id, tick);
CREATE INDEX IF NOT EXISTS idx_sim_events_run_tick ON sim_events(run_id, tick);
CREATE INDEX IF NOT EXISTS idx_sim_snapshots_run_tick ON sim_snapshots(run_id, tick);
