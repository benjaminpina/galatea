# Galatea Simulation Suite

A massive, ultra-high-performance 2D biological and ethological simulation ecosystem. Galatea simulates autonomous agents interacting within complex environments using advanced ecological, metabolic, and spatial mechanics. 

This repository represents the complete architectural re-engineering of the legacy Galatea platform, moving away from classic Object-Oriented bottlenecks towards a highly optimized Data-Oriented Design (DOD) capable of simulating over 50,000 active agents at a stable 60 TPS (Ticks Per Second).

## 🏛️ Repository Architecture & Ecosystem

This project is structured as a single monorepo containing three distinct architectural components isolated by clean boundaries (Macro Hexagonal Architecture):

```text
/Galatea_Suite/
├── 📁 docs/                           # Global technical and scientific specifications
├── 📁 galatea_legacy_pascal/          # Historical FreePascal/Lazarus reference code (Read-Only)
├── 📁 workspaces/                     # Isolated local simulation project directories
├── 📁 sim_editor_flutter/             # Component A: Desktop Scenario Editor (Flutter)
└── 📁 sim_engine_go/                  # Components B & C: Calculation Engine & GUI Monitor (Go)

```

### The Three Core Components

1. **The Architect (`sim_editor_flutter`):** A cross-platform desktop application built in Flutter. It provides a visual interface for researchers to design environments, manage substrate maps, configure metabolic parameters, and construct dynamic behavioral equations.
2. **The Factory (`sim_engine_go/cmd/sim_cli`):** The heavy-duty calculation core built in Go. It operates completely headless, loading configurations from a workspace, pre-allocating memory, and executing pure mathematical simulation cycles at hardware speed.
3. **The Monitor (`sim_engine_go/cmd/sim_gui`):** An accelerated 2D visualization overlay built with Ebitengine inside the Go project. It safely hooks into the engine's memory space to render massive state arrays in real-time.

---

## ⚡ High-Performance Paradigms (The Engine Core)

To break the hardware utilization limits of the legacy version, the simulation kernel (`internal/kernel/`) operates under strict mechanical sympathy rules:

* **Data-Oriented Design (DOD) & Struct of Arrays (SoA):** Entities (Agents) do not exist as objects or structs. An agent is exclusively a primitive integer index (`i`). All mutable state fields are stored in contiguous parallel slices (e.g., `PosX []float64`, `VelX []float64`, `Age []int`). This guarantees optimal CPU L1/L2 cache locality.
* **Zero-Overhead Dynamic Pipeline:** The critical simulation loop (`Tick`) contains no feature-flag conditionals or branching checks. During the simulation setup (Cold Path), a specialized builder evaluates the scenario configuration and constructs an array of pure static function pointers. The `Tick` function merely runs through this pre-compiled pipeline.
* **Spatial Hashing Acceleration:** Proximity checks and neighbor perception are reduced from $O(N^2)$ to $O(N)$ through a dynamic multi-layered spatial grid, preventing execution collapse as density increases.

---

## 💾 Storage & Data Exchange Model

Galatea uses a decentralized, document-style project configuration:

* **Local Isolated Databases:** Every simulation project lives in its own dedicated workspace folder containing its own embedded **ObjectBox** database binary (`.objectbox/`). There is no centralized global database. Projects are self-contained and completely portable.
* **JSON Exchange Serialization:** Universal textual format (JSON) is used to export, share, and version control standalone components such as specific substrate matrices, environmental templates, or custom behavioral packages.

---

## 🛠️ Technology Stack

* **Go (Golang):** Selected for the simulation kernel due to its direct memory control (slices), highly optimized garbage collection, native concurrency primitives, and raw speed.
* **Flutter Desktop (Dart):** Selected for the designer interface to leverage its robust state management, rapid UI prototyping, and excellent hardware acceleration for complex forms.
* **Ebitengine:** A dead-simple, ultra-fast 2D game engine for Go, used to dispatch render calls directly to the GPU via vector batches.
* **ObjectBox:** A high-speed NoSQL embedded database utilized through native CGO bindings in both Dart and Go, ensuring instantaneous local storage synchronization.
* **Expr:** A lightweight, high-performance bytecode virtual machine in Go used to safely compile and evaluate user-defined formulas at runtime without crippling CPU performance.

---

## ⚠️ Critical Contribution Directive

This project enforces an absolute restriction on its computing kernel.

> **DO NOT USE OBJECT-ORIENTED PROGRAMMING WITHIN THE KERNEL.**
> Any contribution or AI-generated code for `internal/kernel/` must strictly adhere to the DOD/SoA principles laid out in `docs/ARCHITECTURE.md`.
> Do not encapsulate data into heavy objects, do not attach logical methods to individual agents, and do not introduce interface-driven dynamic dispatch into the Hot Path.