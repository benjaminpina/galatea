package systems

import (
	"math/rand/v2"

	"galatea/engine/internal/kernel/world"
)

// LocusConfig holds mutation parameters for a single locus.
type LocusConfig struct {
	MutationRateDom  float64
	MutationRateRec  float64
	MutationRangeDom float64
	MutationRangeRec float64
}

// GeneticsConfig holds the per-locus configuration needed for crossover and mutation.
type GeneticsConfig struct {
	NumLoci    int
	LociCont   []LocusConfig // len = NumLoci
	LociDisc   []LocusConfig // len = NumLoci
}

// ExpressLocusCont calculates the expressed continuous phenotype for an agent at a specific locus.
// Dominance rules: both dominant or both recessive = codominance (average).
// Heterozygous = dominant allele expressed.
func ExpressLocusCont(genotype []float64, dominance []uint8, agentIdx, locus, numLoci int) float64 {
	base := agentIdx*numLoci*2 + locus*2
	patVal := genotype[base]
	matVal := genotype[base+1]
	patDom := dominance[base]
	matDom := dominance[base+1]

	if patDom == matDom {
		return (patVal + matVal) / 2.0 // Codominance.
	}
	if patDom == 1 {
		return patVal
	}
	return matVal
}

// ExpressLocusDisc calculates the expressed discrete phenotype for an agent at a specific locus.
func ExpressLocusDisc(genotype []int32, dominance []uint8, agentIdx, locus, numLoci int) int32 {
	base := agentIdx*numLoci*2 + locus*2
	patVal := genotype[base]
	matVal := genotype[base+1]
	patDom := dominance[base]
	matDom := dominance[base+1]

	if patDom == matDom {
		return (patVal + matVal) / 2
	}
	if patDom == 1 {
		return patVal
	}
	return matVal
}

// Crossover performs meiotic recombination between two parent genotypes, producing
// a child genotype. Each locus independently selects one allele from each parent.
// The child receives one allele from parent A and one from parent B.
//
// parentA/parentB are flat genotype arrays: [locus*2 + allele]
// childOut must be pre-allocated with the same length.
func CrossoverCont(
	parentAGeno, parentBGeno []float64,
	parentADom, parentBDom []uint8,
	childGenoOut []float64, childDomOut []uint8,
	numLoci int,
) {
	for locus := 0; locus < numLoci; locus++ {
		base := locus * 2

		// From parent A: randomly select paternal (0) or maternal (1) allele.
		alleleA := rand.IntN(2)
		childGenoOut[base] = parentAGeno[base+alleleA]
		childDomOut[base] = parentADom[base+alleleA]

		// From parent B: randomly select paternal (0) or maternal (1) allele.
		alleleB := rand.IntN(2)
		childGenoOut[base+1] = parentBGeno[base+alleleB]
		childDomOut[base+1] = parentBDom[base+alleleB]
	}
}

// CrossoverDisc performs meiotic recombination for discrete loci.
func CrossoverDisc(
	parentAGeno, parentBGeno []int32,
	parentADom, parentBDom []uint8,
	childGenoOut []int32, childDomOut []uint8,
	numLoci int,
) {
	for locus := 0; locus < numLoci; locus++ {
		base := locus * 2

		alleleA := rand.IntN(2)
		childGenoOut[base] = parentAGeno[base+alleleA]
		childDomOut[base] = parentADom[base+alleleA]

		alleleB := rand.IntN(2)
		childGenoOut[base+1] = parentBGeno[base+alleleB]
		childDomOut[base+1] = parentBDom[base+alleleB]
	}
}

// MutateCont applies mutations to a continuous genotype in-place.
// Each allele has an independent chance of mutating based on its dominance.
func MutateCont(genotype []float64, dominance []uint8, numLoci int, lociCfg []LocusConfig) {
	for locus := 0; locus < numLoci; locus++ {
		cfg := lociCfg[locus]
		base := locus * 2

		for allele := 0; allele < 2; allele++ {
			idx := base + allele
			var rate, rng float64
			if dominance[idx] == 1 {
				rate = cfg.MutationRateDom
				rng = cfg.MutationRangeDom
			} else {
				rate = cfg.MutationRateRec
				rng = cfg.MutationRangeRec
			}

			if rate > 0 && rand.Float64() < rate {
				// Apply mutation: value ± random within range.
				delta := (rand.Float64()*2 - 1) * rng
				genotype[idx] += delta
			}
		}
	}
}

// MutateDisc applies mutations to a discrete genotype in-place.
func MutateDisc(genotype []int32, dominance []uint8, numLoci int, lociCfg []LocusConfig) {
	for locus := 0; locus < numLoci; locus++ {
		cfg := lociCfg[locus]
		base := locus * 2

		for allele := 0; allele < 2; allele++ {
			idx := base + allele
			var rate float64
			var rng float64
			if dominance[idx] == 1 {
				rate = cfg.MutationRateDom
				rng = cfg.MutationRangeDom
			} else {
				rate = cfg.MutationRateRec
				rng = cfg.MutationRangeRec
			}

			if rate > 0 && rand.Float64() < rate {
				// Apply discrete mutation: ± random int within range.
				delta := rand.IntN(int(rng)*2+1) - int(rng)
				genotype[idx] += int32(delta)
			}
		}
	}
}

// CopyGenotype copies genotype data from one agent index to a flat output slice.
// Used to extract a parent's genotype before crossover.
func CopyGenotypeCont(src []float64, agentIdx, numLoci int) []float64 {
	size := numLoci * 2
	base := agentIdx * size
	out := make([]float64, size)
	copy(out, src[base:base+size])
	return out
}

// CopyGenotypeDisc copies discrete genotype data.
func CopyGenotypeDisc(src []int32, agentIdx, numLoci int) []int32 {
	size := numLoci * 2
	base := agentIdx * size
	out := make([]int32, size)
	copy(out, src[base:base+size])
	return out
}

// CopyDominance copies dominance data for an agent.
func CopyDominance(src []uint8, agentIdx, numLoci int) []uint8 {
	size := numLoci * 2
	base := agentIdx * size
	out := make([]uint8, size)
	copy(out, src[base:base+size])
	return out
}

// WriteGenotypeCont writes a flat genotype slice into the agent arrays at the given index.
func WriteGenotypeCont(dst []float64, agentIdx, numLoci int, src []float64) {
	size := numLoci * 2
	base := agentIdx * size
	copy(dst[base:base+size], src)
}

// WriteGenotypeDisc writes discrete genotype into agent arrays.
func WriteGenotypeDisc(dst []int32, agentIdx, numLoci int, src []int32) {
	size := numLoci * 2
	base := agentIdx * size
	copy(dst[base:base+size], src)
}

// WriteDominance writes dominance data into agent arrays.
func WriteDominance(dst []uint8, agentIdx, numLoci int, src []uint8) {
	size := numLoci * 2
	base := agentIdx * size
	copy(dst[base:base+size], src)
}

// DetermineSex returns SexMale or SexFemale based on proportional probability.
func DetermineSex(maleRatio, femaleRatio int) uint8 {
	total := maleRatio + femaleRatio
	if total <= 0 {
		if rand.IntN(2) == 0 {
			return world.SexMale
		}
		return world.SexFemale
	}
	if rand.IntN(total) < maleRatio {
		return world.SexMale
	}
	return world.SexFemale
}
