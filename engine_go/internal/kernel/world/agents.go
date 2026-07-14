package world

// Agent states.
const (
	StateUndecided uint8 = iota
	StateDecided
	StateActing
)

// Agent situations.
const (
	SituationImmature uint8 = iota
	SituationRegular
	SituationCombat
	SituationCourtship
	SituationDead
)

// Agent sex.
const (
	SexUndefined uint8 = iota
	SexMale
	SexFemale
)

// AgentArrays holds all mutable agent state in parallel slices (SoA layout).
// An agent is identified solely by its index i into these slices.
// Count tracks the number of active agents; indices >= Count are inactive.
type AgentArrays struct {
	Count int // Number of active agents.
	Cap   int // Allocated capacity of all slices.

	// Spatial
	PosX      []float64 // X position in world coordinates.
	PosY      []float64 // Y position in world coordinates.
	Direction []uint8   // Facing direction (1-8, mapping to NW,N,NE,W,E,SW,S,SE).
	Speed     []int32   // Movement speed (cells per tick).

	// Identity
	Sex         []uint8 // SexUndefined, SexMale, SexFemale.
	StageID     []int32 // Current stage index (0-based), -1 if adult.
	PrototypeID []int32 // Prototype index (0-based), -1 if immature.
	Age         []int32 // Age in ticks.

	// Behavioral state
	State         []uint8 // StateUndecided, StateDecided, StateActing.
	Situation     []uint8 // SituationImmature, Regular, Combat, Courtship, Dead.
	Decision      []uint8 // Decided behavior index.
	InteractantIdx []int32 // Index of the agent/resource being interacted with (-1 = none).

	// Physiology: Reserves[i*NumNutrients + n] = reserve of nutrient n for agent i.
	Reserves []int32

	// Genetics: flat arrays indexed [i*NumLoci*2 + locus*2 + allele].
	// Each locus has 2 alleles (paternal=0, maternal=1).
	// For continuous loci: values stored as float64 bits cast to int64 in GenotypeCont.
	// For discrete loci: values stored directly in GenotypeDisc.
	GenotypeCont []float64 // [i * NumLoci * 2 + locus*2 + allele]
	GenotypeDisc []int32   // [i * NumLoci * 2 + locus*2 + allele]

	// Dominance: 0=recessive, 1=dominant. Same indexing as genotype.
	DominanceCont []uint8
	DominanceDisc []uint8

	// Memory: tracks perception and interaction history.
	// Flat: [i * memorySlots + slot]
	// Slots are organized as pairs (last_tick, count) for each trackable element.
	MemoryLastPerceived []int32 // Last tick each element was perceived.
	MemoryNumPerceived  []int32 // Number of times perceived.
	MemoryLastInteracted []int32 // Last tick each element was interacted with.
	MemoryNumInteracted  []int32 // Number of times interacted.
	MemoryLastBehavior  []int32 // Last tick each behavior was performed.
	MemoryNumBehavior   []int32 // Number of times each behavior performed.
	LastOpponentAction  []uint8 // Last action by opponent in combat/courtship.

	// Decision vectors: computed per tick by the perception system.
	// Tendencies[i*8 + dir] = movement tendency in direction dir.
	Tendencies []int32
	// VDecision[i*NumBehaviors + b] = probability weight for behavior b.
	VDecision []int32

	// Reproduction
	GametesCount       []int32 // Number of gametes in gonad.
	FertilizedCount    []int32 // Number of fertilized eggs carried.
	SpermPacksCount    []int32 // Number of sperm packs stored (females).
	CarriedEggs        []int32 // Number of eggs being carried.

	// Time counters
	TimeInStage       []int32 // Ticks spent in current stage.
	TimeOnSubstrate   []int32 // Ticks on current substrate.
	TimeInInteraction []int32 // Ticks in current interaction.

	// Fixed morphology (set when becoming adult, then constant)
	MorphologyCont []float64 // [i * NumLoci + locus]
	MorphologyDisc []int32   // [i * NumLoci + locus]
	MorphologyFixed []bool   // Whether morphology has been fixed for this agent.
}

// NewAgentArrays allocates all slices with the given capacity and dimensional parameters.
func NewAgentArrays(cap int, cfg Config) *AgentArrays {
	numLoci := cfg.NumLoci
	numNutrients := cfg.NumNutrients
	numBehaviors := cfg.NumBehaviors
	// Memory slots: substrates + resource_types + prototypes_total (for perception/interaction)
	memPerceptionSlots := cfg.NumSubstrates + cfg.NumResourceTypes + cfg.NumPrototypes
	memBehaviorSlots := numBehaviors

	a := &AgentArrays{
		Count: 0,
		Cap:   cap,

		PosX:      make([]float64, cap),
		PosY:      make([]float64, cap),
		Direction: make([]uint8, cap),
		Speed:     make([]int32, cap),

		Sex:         make([]uint8, cap),
		StageID:     make([]int32, cap),
		PrototypeID: make([]int32, cap),
		Age:         make([]int32, cap),

		State:          make([]uint8, cap),
		Situation:      make([]uint8, cap),
		Decision:       make([]uint8, cap),
		InteractantIdx: make([]int32, cap),

		Reserves: make([]int32, cap*numNutrients),

		GenotypeCont:  make([]float64, cap*numLoci*2),
		GenotypeDisc:  make([]int32, cap*numLoci*2),
		DominanceCont: make([]uint8, cap*numLoci*2),
		DominanceDisc: make([]uint8, cap*numLoci*2),

		MemoryLastPerceived:  make([]int32, cap*memPerceptionSlots),
		MemoryNumPerceived:   make([]int32, cap*memPerceptionSlots),
		MemoryLastInteracted: make([]int32, cap*memPerceptionSlots),
		MemoryNumInteracted:  make([]int32, cap*memPerceptionSlots),
		MemoryLastBehavior:   make([]int32, cap*memBehaviorSlots),
		MemoryNumBehavior:    make([]int32, cap*memBehaviorSlots),
		LastOpponentAction:   make([]uint8, cap),

		Tendencies: make([]int32, cap*8),
		VDecision:  make([]int32, cap*numBehaviors),

		GametesCount:    make([]int32, cap),
		FertilizedCount: make([]int32, cap),
		SpermPacksCount: make([]int32, cap),
		CarriedEggs:     make([]int32, cap),

		TimeInStage:       make([]int32, cap),
		TimeOnSubstrate:   make([]int32, cap),
		TimeInInteraction: make([]int32, cap),

		MorphologyCont:  make([]float64, cap*numLoci),
		MorphologyDisc:  make([]int32, cap*numLoci),
		MorphologyFixed: make([]bool, cap),
	}

	// Initialize interactant indices to -1 (no interaction).
	for i := range a.InteractantIdx {
		a.InteractantIdx[i] = -1
	}
	// Initialize stage/prototype to -1 (unset).
	for i := range a.StageID {
		a.StageID[i] = -1
	}
	for i := range a.PrototypeID {
		a.PrototypeID[i] = -1
	}
	// Initialize memory "last" values to -1 (never perceived/interacted).
	for i := range a.MemoryLastPerceived {
		a.MemoryLastPerceived[i] = -1
	}
	for i := range a.MemoryLastInteracted {
		a.MemoryLastInteracted[i] = -1
	}
	for i := range a.MemoryLastBehavior {
		a.MemoryLastBehavior[i] = -1
	}

	return a
}
