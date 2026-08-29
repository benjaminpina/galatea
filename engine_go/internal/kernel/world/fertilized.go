package world

// FertilizedEgg is an internally-fertilized egg retained by a female until
// oviposition. It mirrors the legacy Fertilizados list: at fertilization time
// the mother's genotype is crossed with a chosen sperm pack's (paternal)
// genotype, and the resulting child genotype is stored here. At oviposition
// the retained egg is deposited into EggArrays with this exact genotype, so
// paternal inheritance is preserved end to end.
//
// Genotype arrays use the same flat layout as AgentArrays/SpermPack:
// index [locus*2 + allele], allele 0 = paternal, 1 = maternal.
type FertilizedEgg struct {
	GenotypeCont  []float64
	GenotypeDisc  []int32
	DominanceCont []uint8
	DominanceDisc []uint8

	// Sex determined at fertilization (via the offspring sex ratio).
	Sex uint8

	// Donor is the identifier of the sire (the sperm pack's donor), kept for
	// lineage traceability.
	Donor string
}

// FertilizedCount returns the number of retained fertilized eggs for agent idx.
// (Kept as the canonical name used across the engine for oviposition gating.)
func (a *AgentArrays) FertilizedCount(idx int) int32 {
	return int32(len(a.FertilizedEggs[idx]))
}

// AddFertilizedEgg appends a fertilized egg to the female's retained list.
func (a *AgentArrays) AddFertilizedEgg(idx int, egg FertilizedEgg) {
	a.FertilizedEggs[idx] = append(a.FertilizedEggs[idx], egg)
}

// PopFertilizedEgg removes and returns the oldest retained fertilized egg for
// agent idx (FIFO, so the first fertilized is the first laid). Returns ok=false
// if the list is empty.
func (a *AgentArrays) PopFertilizedEgg(idx int) (FertilizedEgg, bool) {
	eggs := a.FertilizedEggs[idx]
	if len(eggs) == 0 {
		return FertilizedEgg{}, false
	}
	egg := eggs[0]
	// Shift remaining down (lists are small; FIFO order matches the legacy).
	copy(eggs, eggs[1:])
	eggs[len(eggs)-1] = FertilizedEgg{} // Release references for GC.
	a.FertilizedEggs[idx] = eggs[:len(eggs)-1]
	return egg, true
}

// ClearFertilizedEggs empties the agent's retained fertilized eggs.
func (a *AgentArrays) ClearFertilizedEggs(idx int) {
	a.FertilizedEggs[idx] = nil
}
