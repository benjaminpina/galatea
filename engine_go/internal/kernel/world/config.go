// Package world defines the Data-Oriented Design (DOD) structures for the
// Galatea simulation kernel. All mutable state is stored in contiguous parallel
// slices (Struct of Arrays) for optimal CPU cache utilization.
package world

// Config holds the dimensional parameters of a simulation project.
// These values are determined once during the Cold Path (loading from DB)
// and remain immutable during the simulation Hot Path.
type Config struct {
	// ProjectName is the human-readable name of this project.
	ProjectName string

	// NumNutrients is the number of nutrient types defined (0..N).
	NumNutrients int

	// NumLoci is the number of genetic loci defined (0..N).
	NumLoci int

	// NumStages is the number of immature life stages (0..N).
	NumStages int

	// NumPrototypesM is the number of male adult prototypes (0..N).
	NumPrototypesM int

	// NumPrototypesF is the number of female adult prototypes (0..N).
	NumPrototypesF int

	// NumPrototypes is the total prototype count (stages + males + females).
	// Used for interaction matrix dimensions.
	NumPrototypes int

	// NumResourceTypes is the number of resource/dynamic element types (0..N).
	NumResourceTypes int

	// NumSubstrates is the total number of substrate types (simple + mixed).
	NumSubstrates int

	// NumBehaviors is the number of possible behavioral decisions.
	// Base behaviors: move, rest, feed×NumResourceTypes, fight×2, court×2, oviposit, die.
	NumBehaviors int

	// NumDirections is always 8 (the 8 cardinal/intercardinal directions).
	NumDirections int

	// GridWidth is the width of the simulation environment in cells.
	GridWidth int

	// GridHeight is the height of the simulation environment in cells.
	GridHeight int

	// InitialCapacity is the pre-allocated capacity for agent/egg slices.
	InitialCapacity int
}

// DefaultConfig returns a Config with sensible defaults for unset fields.
func DefaultConfig() Config {
	return Config{
		NumDirections:   8,
		InitialCapacity: 1024,
	}
}
