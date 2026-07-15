# Galatea Simulation Suite

A high-performance 2D biological and ethological simulation ecosystem. Galatea simulates autonomous agents interacting within complex environments using ecological, metabolic, genetic, and spatial mechanics.

This repository is the complete architectural re-engineering of the legacy Galatea platform (FreePascal/Lazarus), migrated to a Data-Oriented Design (DOD) architecture in Go with a Flutter desktop editor.

## Repository Structure

```
Galatea/
├── docs/                    # Architecture docs, thesis PDFs
├── legacy_pascal/           # Historical FreePascal code (read-only reference)
├── workspaces/              # Simulation project databases (one .db file per project)
│   ├── aedes_aegypti.db
│   └── drosophila_model.db
├── engine_go/               # Go simulation engine + 2D visualizer
│   ├── cmd/cli/             # galateac — headless simulation runner
│   ├── cmd/gui/             # galatea — Ebitengine 2D visualizer
│   ├── internal/
│   │   ├── adapters/
│   │   │   ├── storage/     # SQLite persistence (CRUD + buffered writes)
│   │   │   └── jsonexchange/# JSON import/export for components
│   │   └── kernel/
│   │       ├── engine.go    # Main engine: Build() + Tick() + Run()
│   │       ├── formulas/    # expr-lang bytecode formula compiler
│   │       ├── spatial/     # Spatial hash grid (O(N) proximity)
│   │       ├── systems/     # Perception, Decision, Action, Physiology, Genetics, Ontogeny
│   │       ├── util/        # Shared utilities
│   │       └── world/       # SoA data structures + DB loader
│   └── bin/                 # Compiled binaries (gitignored)
└── editor_flutter/          # Flutter desktop scenario editor (Galatea Studio)
    └── lib/src/
        ├── database/        # drift SQLite schema + DAOs
        ├── exchange/        # JSON export/import models
        ├── providers/       # Riverpod state management
        └── ui/              # Screens: home, workspace, substrates, genetics, prototypes
```

## Components

### galateac (Headless Engine)

The simulation kernel. Loads a project from a `.db` file, executes the tick pipeline, records results back to the database. No GUI required.

### galatea (2D Visualizer)

Real-time visualization of running simulations using Ebitengine. Renders substrate grids, agents (colored by sex/prototype), and resources. Supports start/pause/stop, variable speed, max-speed mode, zoom, and pan.

### Galatea Studio (Flutter Editor)

Desktop application for designing simulation scenarios: nutrients, substrates, genetic loci, life stages, adult prototypes, environments, and substrate maps. Supports JSON export/import for sharing components between projects.

## Prerequisites

### Go Engine

- **Go** 1.26+ (or latest stable)
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

### Manual Build

```bash
# Engine CLI
cd engine_go
go build -o bin/galateac ./cmd/cli/main.go

# Visualizer
cd engine_go
go build -o bin/galatea ./cmd/gui/main.go

# Flutter Editor
cd editor_flutter
flutter pub get
dart run build_runner build
flutter build linux --release
```

### Running

```bash
# Run the integration demo (creates a temp workspace, runs all subsystems, reports metrics)
cd engine_go
./bin/galateac

# Launch the visualizer in demo mode (self-contained, no DB required)
cd engine_go
./bin/galatea

# Launch the visualizer with an existing project
cd engine_go
./bin/galatea /path/to/project/galatea.db

# Launch the editor
cd editor_flutter
flutter run -d linux
# Or run the release build:
./build/linux/x64/release/bundle/editor_flutter
```

### Visualizer Controls

| Key | Action |
|-----|--------|
| Space | Start / Pause simulation |
| Escape | Quit |
| Up / Down | Double / halve tick speed |
| M | Toggle max-speed mode (fill frame budget) |
| Scroll wheel | Zoom in/out |
| Left-click drag | Pan viewport |

## Running Tests

```bash
# Go tests (all packages)
cd engine_go
go test ./... -count=1

# Static analysis
cd engine_go
go vet ./...
staticcheck ./...

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
| Database | SQLite (WAL mode) | Per-project persistence |
| Go SQLite driver | modernc.org/sqlite | Pure Go, no CGO, cross-compilable |
| Dart SQLite | drift | Reactive ORM with code generation |
| Formulas | expr-lang/expr | Bytecode-compiled expression engine |
| State management | Riverpod | Reactive providers for Flutter |
| Exchange format | JSON | Versioned component sharing |

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

## Architecture Highlights

- **Data-Oriented Design**: Agents are integer indices into parallel slices. No objects, no methods on agents, no dynamic dispatch in the hot path.
- **Spatial Hash Grid**: Perception queries reduced from O(N²) to O(N) with zero-allocation result buffers.
- **Formula Bytecode**: All behavioral parameters are user-defined formulas compiled once (Cold Path) and evaluated at nanosecond speed (Hot Path).
- **One DB per Project**: Complete isolation. Copy a folder = share a project.
- **Swap-and-Pop Deletion**: O(1) agent removal maintaining slice contiguity.
- **17-Step Tick Pipeline**: Perception → Decision → Action → Physiology → Genetics → Ontogeny → Cleanup.
- **Buffered DB Writes**: Simulation results batched in memory, flushed every N ticks to avoid I/O bottlenecks.

## Project Status

The core simulation engine, visualizer, and editor are functionally complete. The system can:

- Define arbitrary numbers of nutrients, substrates, loci, stages, and prototypes
- Design environments with visual substrate map painting
- Run headless simulations with full tick pipeline
- Visualize simulations in real-time with interactive controls
- Record population dynamics and events to the database
- Export/import components as JSON between projects

## Critical Contribution Directive

> **DO NOT USE OBJECT-ORIENTED PROGRAMMING WITHIN THE KERNEL.**
>
> Any code for `internal/kernel/` must strictly adhere to DOD/SoA principles.
> Do not encapsulate data into objects, do not attach methods to agents, and do not introduce interface-driven dynamic dispatch into the Hot Path.
> See `docs/ARCHITECTURE.md` for detailed design guidelines.

## License

All rights reserved. See LICENSE file for details.
