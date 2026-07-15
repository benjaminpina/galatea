# Galatea Simulation Suite — Architecture Document

## Overview

Galatea is a high-performance 2D biological simulation engine for modeling autonomous agent reproductive strategies. The system is split into three isolated components communicating through a shared SQLite database per project workspace.

## Component Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GALATEA SIMULATION SUITE                          │
├─────────────────┬──────────────────────┬────────────────────────────┤
│  Galatea Studio │   galateac (CLI)     │    galatea (Visualizer)    │
│  (Flutter)      │   (Go, headless)     │    (Go + Ebitengine)       │
│                 │                      │                            │
│  Design UI      │   Simulation Engine  │    2D Real-time Renderer   │
│  CRUD Editors   │   Tick Pipeline      │    Start/Pause/Stop        │
│  Export/Import  │   Result Recording   │    Zoom/Pan                │
└────────┬────────┴──────────┬───────────┴─────────────┬──────────────┘
         │                   │                         │
         └───────────────────┼─────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   galatea.db    │
                    │   (SQLite)      │
                    │   per project   │
                    └─────────────────┘
```

## Directory Structure

```
/Galatea/
├── docs/                    # Documentation and thesis PDFs
├── legacy_pascal/           # Reference legacy code (read-only)
├── workspaces/              # Project databases (one folder per project)
│   └── <project>/galatea.db
├── engine_go/               # Go simulation engine + visualizer
│   ├── cmd/cli/             # galateac - headless simulation runner
│   ├── cmd/gui/             # galatea - Ebitengine 2D visualizer
│   ├── internal/
│   │   ├── adapters/
│   │   │   ├── storage/     # SQLite persistence layer (CRUD + write buffer)
│   │   │   └── jsonexchange/# JSON import/export for components
│   │   └── kernel/
│   │       ├── engine.go    # Main engine: Build (Cold Path) + Tick (Hot Path)
│   │       ├── formulas/    # expr-lang/expr bytecode compiler + evaluator
│   │       ├── spatial/     # Spatial hash grid for O(N) proximity queries
│   │       ├── systems/     # Simulation systems (perception, decision, action, etc.)
│   │       ├── util/        # Shared utilities
│   │       └── world/       # SoA data structures + DB loader
│   └── bin/                 # Compiled binaries (gitignored)
└── editor_flutter/          # Flutter desktop scenario editor
    └── lib/src/
        ├── database/        # drift SQLite schema + DAOs
        ├── exchange/        # JSON export/import models
        ├── providers/       # Riverpod state management
        └── ui/              # Screen widgets (home, workspace, editors)
```

## Technology Stack

| Component        | Technology          | Purpose                                    |
|------------------|---------------------|--------------------------------------------|
| Kernel           | Go 1.26             | Simulation engine, DOD/SoA, zero-alloc hot path |
| Visualizer       | Go + Ebitengine 2.9 | GPU-accelerated 2D rendering               |
| Editor           | Flutter 3.44 + Dart | Desktop UI for scenario design             |
| Database         | SQLite (WAL mode)   | Shared persistence (Go: modernc.org/sqlite, Dart: drift) |
| Formulas         | expr-lang/expr      | Bytecode-compiled expression evaluation    |
| Spatial          | Custom hash grid    | O(N) proximity queries replacing legacy O(N²) |
| State mgmt       | Riverpod            | Reactive UI state in Flutter               |
| Exchange         | JSON                | Portable component sharing between projects |

## Data-Oriented Design (DOD) — Kernel Architecture

The simulation kernel strictly avoids Object-Oriented patterns. Agents are NOT objects; an agent is an integer index `i` into parallel contiguous slices:

```go
type AgentArrays struct {
    Count int
    PosX      []float64   // Agent i position: PosX[i]
    PosY      []float64
    Reserves  []int32     // Agent i nutrient n: Reserves[i*NumNutrients + n]
    Genotype  []float64   // Agent i locus l allele a: Genotype[i*NumLoci*2 + l*2 + a]
    // ... 30+ parallel slices
}
```

This guarantees CPU cache locality for hot-loop iterations and enables swap-and-pop O(1) deletion.

## Tick Pipeline (17 steps)

Each simulation tick executes these systems in sequence:

1. Build perception context
2. Shuffle agent processing order (Fisher-Yates)
3. Perceive (spatial hash → tendencies + VDecision)
4. Decide (roulette selection per situation)
5. Establish interactions (find contiguous targets)
6. Act (execute behaviors: move, feed, signal, oviposit)
7. Charge nutrient costs
8. Physiological update (age, starvation, old-age death)
9. Gametogenesis (adults at optimal reserves)
10. Sperm consumption (females)
11. Resolve combat dynamics (timeout → retreat)
12. Resolve courtship dynamics (mutual accept → copulation)
13. Ontogeny: evaluate eggs + stage transitions
14. Remove dead agents (swap-and-pop + grid rebuild)
15. Regenerate resources
16. Reset agent states for next tick
17. Record results to write buffer

## Database Schema (per project)

One SQLite file per project containing:
- **project_info** (singleton metadata)
- **nutrients** (0..N user-defined resource types)
- **substrates** + **substrate_compositions** (terrain types)
- **loci** (genetic loci with mutation parameters)
- **stages** (immature life stages with transition conditions)
- **prototypes** (adult archetypes with behavioral formulas)
- **resource_types** (dynamic element definitions)
- **environments** (scenario dimensions + placed elements)
- **substrate_map_rows** (terrain grid data)
- **sim_runs** + **sim_tick_counts** + **sim_events** (results)

All entity counts are dynamic (0..N). No hardcoded limits.

## Performance Characteristics

| Metric                        | Measured Value         |
|-------------------------------|------------------------|
| Formula evaluation            | 2.5M evals/sec         |
| Spatial hash query (10K)      | 2.0M queries/sec       |
| Full engine TPS (100 agents)  | ~1,000 TPS             |
| Full engine TPS (50 agents)   | ~3,000 TPS             |
| Write buffer throughput       | 170K records/sec       |
| World load time               | < 1ms                  |
| Visualizer FPS                | 60 FPS (stable)        |

## JSON Exchange Format

Components are shared between projects via versioned JSON files:

```json
{
  "schema_version": 1,
  "type": "loci_set",
  "loci": [
    {
      "name": "BodySize",
      "is_continuous": true,
      "dominant_value": 1.0,
      "mutation_rate_dom": 0.01,
      ...
    }
  ]
}
```

Supported types: `substrate_set`, `loci_set`, `prototype_set`.
Import resolves name conflicts by skipping duplicates.

## Build Commands

```bash
# Engine (headless CLI)
make cli          # → engine_go/bin/galateac

# Visualizer (2D GUI)
make gui          # → engine_go/bin/galatea

# Editor (Flutter desktop)
make editor       # → editor_flutter/build/linux/x64/release/bundle/

# All
make all

# Tests
cd engine_go && go test ./... -count=1
cd editor_flutter && flutter analyze
```

## Design Decisions

1. **One DB per project** — Complete isolation, portable, no shared-state conflicts.
2. **SQLite WAL mode** — Concurrent read (visualizer) while single writer (engine).
3. **expr-lang/expr** — Bytecode VM compiles formulas once (Cold Path), evaluates in nanoseconds (Hot Path).
4. **Spatial hash** — Cell size = max perception radius. Queries O(1) per cell, O(neighbors) total.
5. **Swap-and-pop removal** — Maintains slice contiguity without gaps or compaction.
6. **Write buffer** — Batches DB inserts (flush every 100 ticks or 10K records).
7. **Fisher-Yates shuffle** — Random agent order per tick prevents positional bias.
8. **Riverpod + drift** — Reactive streams for automatic UI refresh on data changes.
