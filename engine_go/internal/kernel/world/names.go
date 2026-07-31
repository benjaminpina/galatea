package world

// Names holds user-defined names for all configurable entities.
// These are loaded from the DB during the Cold Path and used by the
// EnvBuilder to construct formula variable names that match what the
// user wrote in their formulas.
//
// All slices are indexed from 0, corresponding to the entity's position
// in its respective array. For example, NutrientNames[0] is the name of
// the first nutrient, which maps to Reserve index 0 in AgentArrays.
type Names struct {
	// NutrientNames: user-defined names for each nutrient (e.g., "Water", "Sugar").
	// Used for variables like "ReserveWater", "MemoryLastPerWater", etc.
	NutrientNames []string

	// LocusNames: user-defined names for genetic loci.
	// Used for variables like "CL_LocusName" (genetic expression).
	LocusNames []string

	// CharacterNames: user-defined names for morphological characters.
	// Used for variables like "BodySize" (morphological value).
	CharacterNames []string

	// SubstrateNames: user-defined names for substrate types.
	// Used for memory variables like "MemoryLastPerGrass".
	SubstrateNames []string

	// StageNames: user-defined names for life stages.
	// Used for memory variables like "MemoryLastIntEgg".
	StageNames []string

	// PrototypeMNames: user-defined names for male prototypes.
	PrototypeMNames []string

	// PrototypeFNames: user-defined names for female prototypes.
	PrototypeFNames []string

	// BehaviorNames: canonical names for each behavior slot.
	// These are partially built-in (Move, Rest, Feed_X) and partially derived
	// from nutrient names.
	BehaviorNames []string
}

// BuildBehaviorNames constructs the canonical behavior names from nutrient names.
// The behavior order is: Move, Rest, Feed_<nutrient1>, Feed_<nutrient2>, ...,
// Fight_Attack, Fight_Defend, Fight_Retreat,
// Court_Display, Court_Accept, Court_Reject,
// Oviposit.
func BuildBehaviorNames(nutrientNames []string) []string {
	names := []string{"Move", "Rest"}
	for _, n := range nutrientNames {
		names = append(names, "Feed_"+n)
	}
	names = append(names, "Fight_Attack", "Fight_Defend", "Fight_Retreat")
	names = append(names, "Court_Display", "Court_Accept", "Court_Reject")
	names = append(names, "Oviposit")
	return names
}
