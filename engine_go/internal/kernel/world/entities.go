package world

// EggArrays holds mutable state for eggs (fertilized, pre-hatching) in SoA layout.
type EggArrays struct {
	Count int
	Cap   int

	PosX []float64 // Position (inherited from carrier or oviposition site).
	PosY []float64

	Age []int32 // Age in ticks since oviposition.
	Sex []uint8 // Sex determined at fertilization.

	// Reserves: [i * NumNutrients + n]
	Reserves []int32

	// Genotype (same layout as agents): [i * NumLoci * 2 + locus*2 + allele]
	GenotypeCont  []float64
	GenotypeDisc  []int32
	DominanceCont []uint8
	DominanceDisc []uint8

	// Carrier: index into agents (-1 if in oviposition site).
	CarrierAgentIdx []int32
	// Carrier: index into resources (-1 if carried by agent).
	CarrierResourceIdx []int32

	// Decision for egg viability (survive=1, die=2).
	VDecision []int32 // [i*2 + 0]=survive weight, [i*2 + 1]=die weight

	// Parentage (stored as string names for traceability).
	ParentMale   []string
	ParentFemale []string
}

// NewEggArrays allocates egg slices with the given capacity.
func NewEggArrays(cap int, cfg Config) *EggArrays {
	numLoci := cfg.NumLoci
	numNutrients := cfg.NumNutrients

	e := &EggArrays{
		Count: 0,
		Cap:   cap,

		PosX: make([]float64, cap),
		PosY: make([]float64, cap),
		Age:  make([]int32, cap),
		Sex:  make([]uint8, cap),

		Reserves: make([]int32, cap*numNutrients),

		GenotypeCont:  make([]float64, cap*numLoci*2),
		GenotypeDisc:  make([]int32, cap*numLoci*2),
		DominanceCont: make([]uint8, cap*numLoci*2),
		DominanceDisc: make([]uint8, cap*numLoci*2),

		CarrierAgentIdx:    make([]int32, cap),
		CarrierResourceIdx: make([]int32, cap),

		VDecision: make([]int32, cap*2),

		ParentMale:   make([]string, cap),
		ParentFemale: make([]string, cap),
	}

	for i := range e.CarrierAgentIdx {
		e.CarrierAgentIdx[i] = -1
	}
	for i := range e.CarrierResourceIdx {
		e.CarrierResourceIdx[i] = -1
	}

	return e
}

// ResourceArrays holds mutable state for placed resource instances in SoA layout.
type ResourceArrays struct {
	Count int
	Cap   int

	PosX []float64
	PosY []float64

	TypeID   []int32   // Index into the resource type definitions.
	Level    []int32   // Current resource level.
	MaxLevel []int32   // Maximum capacity.
	Quality  []int32   // Quality metric.
	RegenRate []float64 // Multiplicative regeneration rate per tick.
}

// NewResourceArrays allocates resource slices with the given capacity.
func NewResourceArrays(cap int) *ResourceArrays {
	return &ResourceArrays{
		Count:     0,
		Cap:       cap,
		PosX:      make([]float64, cap),
		PosY:      make([]float64, cap),
		TypeID:    make([]int32, cap),
		Level:     make([]int32, cap),
		MaxLevel:  make([]int32, cap),
		Quality:   make([]int32, cap),
		RegenRate: make([]float64, cap),
	}
}

// SubstrateMap holds the 2D grid of substrate IDs for the environment.
// Indexed as Grid[y*Width + x] to maintain row-major cache-friendly access.
type SubstrateMap struct {
	Width  int
	Height int
	Grid   []int32 // Flat 2D array: Grid[y*Width + x] = substrate type index.
}

// NewSubstrateMap allocates a substrate grid of the given dimensions.
func NewSubstrateMap(width, height int) *SubstrateMap {
	return &SubstrateMap{
		Width:  width,
		Height: height,
		Grid:   make([]int32, width*height),
	}
}

// Get returns the substrate ID at position (x, y).
func (m *SubstrateMap) Get(x, y int) int32 {
	return m.Grid[y*m.Width+x]
}

// Set assigns a substrate ID at position (x, y).
func (m *SubstrateMap) Set(x, y int, substrateID int32) {
	m.Grid[y*m.Width+x] = substrateID
}
