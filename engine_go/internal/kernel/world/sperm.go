package world

// SpermPack represents a single spermatophore stored in a female's spermatheca
// after copulation. It mirrors the legacy TPaqEspermatico: it carries a full
// copy of the donor male's genotype (so paternal inheritance is possible), the
// nutrient reserves packaged with it, a paternity weight (used to bias which
// pack fertilizes an egg via weighted roulette), and the donor's identity for
// traceability.
//
// The genotype is stored as flat per-locus arrays using the same layout as
// AgentArrays: index [locus*2 + allele], allele 0 = paternal, 1 = maternal.
type SpermPack struct {
	// GenotypeCont holds the donor's continuous loci: [locus*2 + allele].
	GenotypeCont []float64
	// GenotypeDisc holds the donor's discrete loci: [locus*2 + allele].
	GenotypeDisc []int32
	// DominanceCont / DominanceDisc hold the dominance flags for each allele
	// (0 = recessive, 1 = dominant), same layout as the genotype arrays.
	DominanceCont []uint8
	DominanceDisc []uint8

	// Reserves packaged with the pack, per nutrient.
	Reserves []int32

	// Paternity is the weight used in the fertilization roulette. Higher
	// paternity means a greater chance this pack sires an egg. It degrades
	// over time (see SpermConsumption).
	Paternity int32

	// Donor is the name/identifier of the male that produced this pack, kept
	// for lineage traceability (mirrors the legacy Donador field).
	Donor string
}

// NewSpermPackFromAgent builds a SpermPack carrying a deep copy of the donor
// male's genotype at agentIdx, along with the given reserves and paternity.
// Copying is deep so later mutations to the male's genotype (or the male's
// death and slot reuse) never alias the stored pack.
func NewSpermPackFromAgent(a *AgentArrays, maleIdx, numLoci, numNutrients int, reserves []int32, paternity int32, donor string) SpermPack {
	genoSize := numLoci * 2
	genoBase := maleIdx * genoSize

	pack := SpermPack{
		GenotypeCont:  make([]float64, genoSize),
		GenotypeDisc:  make([]int32, genoSize),
		DominanceCont: make([]uint8, genoSize),
		DominanceDisc: make([]uint8, genoSize),
		Reserves:      make([]int32, numNutrients),
		Paternity:     paternity,
		Donor:         donor,
	}

	copy(pack.GenotypeCont, a.GenotypeCont[genoBase:genoBase+genoSize])
	copy(pack.GenotypeDisc, a.GenotypeDisc[genoBase:genoBase+genoSize])
	copy(pack.DominanceCont, a.DominanceCont[genoBase:genoBase+genoSize])
	copy(pack.DominanceDisc, a.DominanceDisc[genoBase:genoBase+genoSize])

	if len(reserves) > 0 {
		n := numNutrients
		if len(reserves) < n {
			n = len(reserves)
		}
		copy(pack.Reserves[:n], reserves[:n])
	}

	return pack
}
