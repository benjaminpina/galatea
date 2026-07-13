# `ARCHITECTURE.md` - Galatea Simulation Engine

## ⚠️ SECTION 0: CRITICAL DIRECTIVE FOR AI AGENTS & CONTRIBUTORS
**THIS PROJECT DOES NOT USE OBJECT-ORIENTED PROGRAMMING (OOP) IN THE COMPUTATION KERNEL.**

Any code generated for or contributed to the `internal/kernel/` directory must strictly adhere to Data-Oriented Design (DOD) and Struct of Arrays (SoA) architecture. 

**Strictly Forbidden Actions within the Kernel:**
1. **Zero Objects:** You must never create an `Agent` or `Entity` struct that encapsulates multiple logical properties. An agent is exclusively an integer index (`i`).
2. **Zero Dynamic Dispatch:** Do not use `interface{}` or virtual methods to solve ethological interactions. 
3. **Zero Method Attachment:** Do not attach methods (`func (a *Agent)`) that operate on individual entities. All functions must operate on arrays/slices as a whole.
4. **Zero Overhead in the Hot Path:** Do not use boolean checks (e.g., `if usesEnergy`) inside the main simulation loop (`Tick`). All branching must be resolved during the initialization phase (Cold Path).
5. **No Nested Loops for Proximity:** Do not create $O(N^2)$ loops to compare agents. All spatial interactions must use the Spatial Hashing grid (Broad Phase).

---

## 1. Engine Philosophy (The Hot Path)

The Galatea engine is a massive, in-memory processing machine. The absolute priority—above readability or standard software conventions—is **CPU L1/L2 Cache Locality** and mechanical sympathy.

* **The Entity Does Not Exist:** An "Agent" is not an object. It is merely an index used to fetch data across multiple parallel memory slices.
* **Batch Processing:** Engine functions do not process "one agent". They process "all elements in a slice". Updates are performed by transforming entire arrays sequentially.
* **Strict Allocation:** Memory (`make`) and CPU cycles are allocated exclusively for the rules active in the current scenario. 

## 2. Data Structure (Struct of Arrays - SoA)

All mutable state resides in the `SimulationState`. This struct contains flat slices. The memory for these slices is pre-allocated in the Cold Path when a scenario is loaded.

```go
// internal/kernel/state.go
type SimulationState struct {
    ActiveCount int // Total number of active agents in the current tick

    // KINEMATICS (High-frequency access)
    PosX []float64
    PosY []float64
    VelX []float64
    VelY []float64

    // GENETICS (Static size arrays per agent)
    // Flattened 1D arrays simulating 2D for CPU cache locality (e.g., ActiveCount * 15)
    ContinuousLoci []float64 
    DiscreteLoci   []int     

    // MORPHOLOGY
    BodyLength       []float64
    AbdomenThickness []float64

    // PHYSIOLOGY (Discrete nutrient tracking)
    Water         []int
    Carbohydrates []int
    Lipids        []int
    Proteins      []int

    // SPATIAL ACCELERATION (Grid Hashing)
    Grid [][]int
}

```

## 3. Dynamic Orchestration (The Pipeline)

The simulation lifecycle (`Tick`) is not a monolithic block of code. It is a dynamic collection of static function pointers (`UpdateStrategy`) assembled during the `Setup` phase.

1. The configuration module reads the scenario requirements.
2. If the scenario dictates foraging and physiological limits, the `UpdateMetabolism` and `ProcessNutrientIntake` strategies are appended to the Pipeline.
3. If the scenario dictates collision avoidance, `BuildSpatialGrid` and `ResolveProximity` are appended.
4. The `Tick()` function iterates blindly over the active Pipeline and executes it in order at maximum speed.

## 4. Spatial Resolution & Perception

Any interaction depending on the distance between agents or the environment must utilize a **Broad Phase** (Grid/Spatial Hashing) followed by a **Narrow Phase** (Exact calculation).

* **Broad Phase:** Agents register their presence (inserting their index `i`) into the `Grid` based on their maximum interaction radius.
* **Narrow Phase:** When agent `A` seeks to interact, it only reads the `Grid` cells adjacent to its current position, retrieves the list of candidate indices, and applies the Euclidean distance formula **only** to those candidates, achieving $O(N)$ complexity.

## 5. Macro Hexagonal Architecture

The computation kernel (`internal/kernel`) is strictly agnostic to the outside world. Dependencies flow inward.

* **Storage Boundary:** The kernel does not know about ObjectBox, SQLite, or JSON. The storage adapter (`internal/adapters/storage`) reads the external database and produces a pure Go `Config` object, which the kernel uses for the initial SoA `Setup`.
* **Visualization Boundary:** The kernel does not know about Ebitengine, screen resolutions, or rendering pipelines. It provides thread-safe access (via `sync.RWMutex`) to its positional slices so the graphics adapter (`internal/adapters/gui`) can render them asynchronously.
* **Deployment Isolation:** Any code with graphical or heavy I/O dependencies must reside in `cmd/`. The logical engine must compile cleanly in headless environments (e.g., `cmd/sim_cli`).

## 6. Licensing & Compliance

Galatea is licensed under the **GNU AGPLv3**. Any modifications or optimizations made to this computation kernel, even if deployed purely as a backend cloud service (SaaS) or distributed cluster, must be open-sourced and shared back with the scientific community.
