# `GLOSSARY.md` - Standardized Nomenclature

## ⚠️ DIRECTIVE FOR AI AGENTS AND CONTRIBUTORS
To maintain strict consistency across the Flutter UI, the Go computation kernel, and the JSON export formats, **all code generation and documentation must use the exact terms defined in this glossary.** Do not invent synonyms, interpolate unverified biological metrics, or translate these terms back into other languages within the source code. 

When generating Go code for the `SimulationState`, these terms refer strictly to **contiguous parallel slices (arrays)**, not object properties.

---

## 1. Core Architectural Terms

* **Agent Index (`i`):** The integer representing an individual organism in the simulation. Agents are not objects; they are just this index used to look up values across multiple data slices.
* **Cold Path:** The initialization phase of the simulation. Memory is allocated (`make`), configurations are loaded from ObjectBox/JSON, and the Pipeline is assembled.
* **Hot Path:** The main execution loop where the simulation runs. No memory allocation or branching conditional logic (`if rule_is_active`) occurs here.
* **Tick / Cycle:** A single, complete iteration of the Hot Path. Age and time are measured strictly in Cycles.
* **Pipeline:** The array of pre-determined, static function pointers assembled during the Cold Path.
* **DOD (Data-Oriented Design) & SoA (Struct of Arrays):** The paradigm focused on CPU cache optimization where properties are stored in parallel arrays.

---

## 2. Genetics & Inheritance

The genetic base for morphological calculation and inheritance. Values mutate based on `MutationRate` and `MutationInterval`.
* **`ContinuousLocus` (`CL1` to `CL15`):** Array of 15 floating-point values representing continuous genetic traits.
* **`DiscreteLocus` (`DL1` to `DL15`):** Array of 15 integer values representing discrete genetic traits.
* **`DominantValue` / `RecessiveValue`:** The allelic values competing during inheritance and morphological expression.

---

## 3. Morphology

Physical attributes calculated dynamically based on Genetics (Loci) and Age.
* **`BodyLength`:** (`[]float64`) Overall length of the organism.
* **`AbdomenThickness`:** (`[]float64`) Thickness of the abdomen, correlated with egg production capacity.
* **`PedipalpLength`:** (`[]float64`) Length of pedipalps, correlated with female copulation rejection rates.
* **`LegIILength`:** (`[]float64`) Length of the second pair of legs.
* **`LocomotorLegs`:** (`[]int`) Number of legs available for movement (decreases with age).
* **`SensoryLegs`:** (`[]int`) Number of legs available for environmental perception (decreases with age).

---

## 4. Physiology & Metabolism

Nutrient reserves are discrete variables (`[]int`). Every nutrient type is evaluated against four behavioral thresholds: `Minimum` (death), `Critical` (foraging prioritized over combat/courtship), `Optimum` (excess used for gametes), and `Maximum` (intake stops).
* **`Water`:** Internal water reserves.
* **`Carbohydrates`:** Internal carbohydrate reserves.
* **`Lipids`:** Internal lipid reserves.
* **`Proteins`:** Internal protein reserves.

---

## 5. Gametes & Reproduction

* **`Eggs`:** (`[]int`) Unfertilized and fertilized female gametes. Maximum capacity depends on `BodyLength` and `AbdomenThickness`.
* **`SpermPackages`:** (`[]int`) Spermatophores transferred from males to females.
* **`PaternityProbability`:** The weight assigned in a Monte Carlo draw to determine which stored sperm package fertilizes an egg.
* **`SpermDegradationRate`:** The rate at which stored `SpermPackages` lose their `PaternityProbability` over time.

---

## 6. Environment & Dynamic Elements

* **`Grid`:** (`[][]int`) The Spatial Hashing matrix (Broad Phase) for O(N) proximity checks.
* **`Substrate`:** The static background tiles modifying movement speed. Specifically: `Rock`, `MossyRock`, and `LeafLitter`.
* **`DynamicElement`:** Environmental items changing state over time. Specifically: `WaterSource`, `LipidSource`, `ProteinSource`, `CarbohydrateSource`, and `OvipositionSite`.
* **`Level`:** The current discrete amount of nutrients or eggs a `DynamicElement` contains.
* **`Attractiveness`:** An integer weight (positive or negative) influencing an agent's movement direction.
* **`PerceptionRadius`:** The minimum distance required for an agent to perceive an element or another agent.