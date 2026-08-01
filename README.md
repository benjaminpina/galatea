# Galatea Simulation Suite

A high-performance 2D biological and ethological simulation ecosystem. Galatea simulates autonomous agents interacting within complex environments using ecological, metabolic, genetic, and spatial mechanics.

This repository is the complete architectural re-engineering of the legacy Galatea platform (FreePascal/Lazarus), migrated to a Data-Oriented Design (DOD) architecture in Go with a Flutter desktop editor.

## Repository Structure

```
Galatea/
├── docs/                    # Architecture docs, thesis PDFs
├── legacy_pascal/           # Historical FreePascal code (read-only reference)
├── engine_go/               # Go simulation engine + 2D visualizer
│   ├── cmd/cli/             # galateac — headless simulation runner
│   ├── cmd/gui/             # galatea — Ebitengine 2D visualizer
│   ├── internal/
│   │   ├── adapters/
│   │   │   ├── storage/     # SQLite persistence (CRUD + buffered writes)
│   │   │   └── jsonexchange/# JSON import/export for components
│   │   └── kernel/
│   │       ├── engine.go    # Main engine: Build() + Tick() + Run()
│   │       ├── formulas/    # expr-lang bytecode formula compiler + user custom functions
│   │       ├── spatial/     # Spatial hash grid (O(N) proximity)
│   │       ├── systems/     # Perception, Decision, Action, Physiology, Genetics, Ontogeny, Reproduction
│   │       ├── util/        # Shared utilities
│   │       └── world/       # SoA data structures + DB loader
│   └── bin/                 # Compiled binaries (gitignored)
└── editor_flutter/          # Flutter desktop scenario editor (Galatea Studio)
    └── lib/src/
        ├── database/        # drift SQLite schema + DAOs (34 tables)
        ├── exchange/        # JSON export/import models
        ├── providers/       # Riverpod state management
        └── ui/              # Editor screens (environment canvas, agents, formulas)
```

## Components

### galateac (Headless Engine)

The simulation kernel. Loads a project from a `.db` file, runs the tick pipeline, records results back to the database. No GUI required.

```
galateac --file project.db [--env NAME] [--cycles N] [--report-interval N] [--quiet]
galateac --help
galateac --version
```

### galatea (2D Visualizer)

Real-time visualization of running simulations using Ebitengine. Renders substrate grids (with user-defined colors from DB), nutrient sources, and agents (colored by sex/prototype). Supports start/pause/stop, variable speed, max-speed mode, zoom, and pan.

```
galatea --file project.db [--env NAME] [--speed N] [--width W] [--height H]
galatea --help
galatea --version
```

**Controls:**
| Key | Action |
|-----|--------|
| Space | Start / Pause simulation |
| Escape | Quit |
| Up / Down | Double / halve tick speed |
| M | Toggle max-speed mode |
| Scroll wheel | Zoom in/out |
| Left-click drag | Pan viewport |

### Galatea Studio (Flutter Editor)

Desktop application for designing simulation scenarios. Features a unified PaintBrush-style environment editor as the main workspace.

**Editor Layout:**
- Top toolbar: Save, project section buttons (Substrates, Nutrients, Agents), environment selector
- Left sidebar: Drawing tools (Pointer, Terrain Brush, Source, Oviposition, Agent) + contextual options (substrate palette with brush shapes/sizes, nutrient selector, agent prototype/sex chooser)
- Center: Canvas with real-time rendering (substrates, sources, oviposition sites, agents)
- Right panel (togglable): Project configuration editors (embedded list screens)
- Status bar: Coordinates, active tool, element count

**Key Features:**
- PaintBrush-style terrain painting with 5 brush shapes (square, circle, diamond, h-line, v-line) and configurable size (1–15 cells)
- Place nutrient sources, oviposition sites, and agents by clicking on the map
- Formula editor dialog with tabbed variable browser, function list, operator buttons, and real-time syntax validation
- Agents panel: Morphology (characters), Genetics (loci), Life Stages, Prototypes (M/F), Physiology, Interaction Matrices (placeholder)
- Dedicated edit screens for prototypes (5 tabs: General, Morphology, Fighting, Courtship, Movement) and life stages
- Default substrate enforcement (no empty cells allowed)
- Environment management (create, rename, resize with shrink warning, switch between environments)
- Cascade deletes for referential integrity (deleting a prototype removes its placed agents, etc.)

## Prerequisites

### Go Engine

- **Go** 1.22+ (or latest stable)
- **Linux X11 dev libraries** (for the visualizer):
  ```bash
  sudo apt-get install -y libx11-dev libxrandr-dev libxxf86vm-dev libxi-dev libxcursor-dev libxinerama-dev libgl-dev
  ```

### Flutter Editor

- **Flutter** 3.40+ (stable channel)
- Linux desktop development enabled:
  ```bash
  flutter config --enable-linux-desktop
  ```

## Build & Run

### Using the Makefile

```bash
# Build everything
make all

# Individual components
make cli      # → engine_go/bin/galateac
make gui      # → engine_go/bin/galatea
make editor   # → editor_flutter/build/linux/x64/release/bundle/

# Clean
make clean
```

### Running

```bash
# Run headless simulation
cd engine_go
./bin/galateac --file /path/to/project.db --cycles 5000 --report-interval 500

# Launch the visualizer
cd engine_go
./bin/galatea --file /path/to/project.db

# Launch the editor
cd editor_flutter
flutter run -d linux
```

### Running Tests

```bash
# Go tests (all packages)
cd engine_go
go test ./... -count=1

# Flutter analysis
cd editor_flutter
flutter analyze
```

## Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Kernel | Go (pure, no CGO for core) | DOD/SoA simulation engine |
| Visualizer | Go + Ebitengine 2.9 | GPU-accelerated 2D rendering |
| Editor | Flutter 3.44 + Dart | Desktop UI for scenario design |
| Database | SQLite (WAL mode) | Per-project persistence (34 tables) |
| Go SQLite driver | modernc.org/sqlite | Pure Go, no CGO |
| Dart SQLite | drift | Reactive ORM with code generation |
| Formulas | expr-lang/expr | Bytecode-compiled + user custom functions |
| State management | Riverpod | Reactive providers for Flutter |
| Exchange format | JSON | Versioned component sharing |

## Formula System

The formula engine supports:

- **22 built-in functions**: Random, RandG, Dice, RandInt, Bernoulli, Max, Min, Abs, Sqrt, Pow, Log, Log10, Round, Floor, Ceil, Clamp, Lerp, Sigmoid, Step, If, and more
- **User-defined custom functions**: stored in the DB, compiled via macro-expansion at runtime (no recursion, stateless, numeric parameters only)
- **User-defined variable names**: nutrients, characters, substrates, stages, prototypes — all referenced by their user-given names in formulas (e.g., `ReserveWater`, `CL_BodySize`)
- **Full operator support**: arithmetic (+, -, *, /, %, **), comparison (==, !=, >, <, >=, <=), logical (&&, ||, !), ternary (? :)
- **Formula editor UI**: modal dialog with tabbed variable browser (Time, Physiology, Genetics, Morphology, Reproduction, Memory, Contender, Resource, Functions), operator buttons, and real-time validation

## Architecture Highlights

- **Data-Oriented Design**: Agents are integer indices into parallel slices. No objects, no methods on agents, no dynamic dispatch in the hot path.
- **Spatial Hash Grid**: Perception queries reduced from O(N²) to O(N) with zero-allocation result buffers.
- **Formula Bytecode**: All behavioral parameters are user-defined formulas compiled once (Cold Path) and evaluated at nanosecond speed (Hot Path). Custom user functions are expanded via macro substitution.
- **Dynamic Reference Values**: Longevity, metabolic costs, refractories, gamete costs, substrate velocity — all evaluated per-agent per-tick from formulas (matching legacy behavior).
- **Independent Genetics & Morphology**: Genetic loci (hereditary units with dominance/mutation) are fully separate from morphological characters (phenotypic traits defined by formula). Morphology CAN reference loci but doesn't have to.
- **One DB per Project**: Complete isolation. Copy a folder = share a project.
- **Swap-and-Pop Deletion**: O(1) agent removal maintaining slice contiguity.
- **17-Step Tick Pipeline**: Perceive → Decide → Establish Interactions → Act → Charge Nutrients → Physiology → Gametogenesis → Sperm Consumption → Combat/Courtship Dynamics → Ontogeny → Remove Dead → Regenerate Resources → Reset → Record.
- **Perception Filters**: Refractory periods, max reserve caps, critical reserve detection — all evaluated dynamically from formulas.
- **Buffered DB Writes**: Simulation results batched in memory, flushed every N ticks to avoid I/O bottlenecks.

## Database Schema (34 tables)

The SQLite schema covers:

- **Core**: project_info, environments, substrate_map_rows
- **Terrain**: substrates, substrate_compositions
- **Biology**: nutrients, loci (genetics), morphological_characters, stages, stage_nutrient_requirements, stage_tendencies, prototypes, prototype_morphology, prototype_tendencies, prototype_combat, prototype_courtship, prototype_assignment_criteria
- **Physiology**: metabolism, behavior_costs, feeding_gains, substrate_velocities, reproduction, gamete_costs
- **Interactions**: interaction_substrates, attractiveness_substrates, interaction_sources, attractiveness_sources, interaction_agents, attractiveness_agents, memory_influence
- **Environment**: environment_sources, environment_oviposition_sites, environment_agents, oviposition_site_config
- **Custom**: custom_functions
- **Results**: sim_runs, sim_tick_counts, sim_events, sim_snapshots

## Performance

Measured on AMD Ryzen 7 5700U (16 threads):

| Metric | Value |
|--------|-------|
| Formula evaluation | 2.5M evals/sec |
| Spatial hash queries (10K agents) | 2.0M queries/sec |
| Full engine TPS (100 agents) | ~1,000 TPS |
| Full engine TPS (50 agents) | ~3,000 TPS |
| Write buffer throughput | 170K records/sec |
| World load time | < 1ms |
| Visualizer | 60 FPS (stable) |

## Project Status

The simulation engine, visualizer, and editor are functionally complete. The system can:

- Define arbitrary numbers of nutrients, substrates, loci, morphological characters, stages, and prototypes
- Design environments with visual substrate map painting (5 brush shapes, configurable size)
- Define user custom functions for formula reuse
- Run headless simulations with full tick pipeline and formula-driven dynamics
- Visualize simulations in real-time with interactive controls
- Record population dynamics and events to the database
- Export/import components as JSON between projects
- Validate substrate maps (no empty cells) and cascade-delete dependent entities

## Critical Contribution Directive

> **DO NOT USE OBJECT-ORIENTED PROGRAMMING WITHIN THE KERNEL.**
>
> Any code for `internal/kernel/` must strictly adhere to DOD/SoA principles.
> Do not encapsulate data into objects, do not attach methods to agents, and do not introduce interface-driven dynamic dispatch into the Hot Path.
> See `docs/ARCHITECTURE.md` for detailed design guidelines.

## License

All rights reserved. See LICENSE file for details.
