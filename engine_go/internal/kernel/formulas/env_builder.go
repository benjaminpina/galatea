package formulas

import (
	"galatea/engine/internal/kernel/world"
)

// EnvBuilder populates an Evaluator's environment map with variables from
// the current agent state. This is called once per agent per formula evaluation
// cycle, updating values in-place to avoid map allocations.
type EnvBuilder struct {
	eval *Evaluator
	cfg  world.Config
}

// NewEnvBuilder creates an EnvBuilder tied to an evaluator and world config.
func NewEnvBuilder(eval *Evaluator, cfg world.Config) *EnvBuilder {
	return &EnvBuilder{eval: eval, cfg: cfg}
}

// SetWorldVars sets global simulation variables (tick, etc).
func (b *EnvBuilder) SetWorldVars(w *world.World) {
	b.eval.Set("Cycles", int(w.Tick))
}

// SetAgentVars populates the env with all variables for agent at index idx.
// This corresponds to the legacy TMediador.ObtenNombreVariable functionality.
func (b *EnvBuilder) SetAgentVars(w *world.World, idx int) {
	a := w.Agents
	cfg := b.cfg

	// Time variables
	b.eval.Set("Age", int(a.Age[idx]))
	b.eval.Set("CyclesInCurrentLifeStage", int(a.TimeInStage[idx]))
	b.eval.Set("CyclesOnSubstrate", int(a.TimeOnSubstrate[idx]))
	b.eval.Set("CyclesInCurrentInteraction", int(a.TimeInInteraction[idx]))

	// Stage/prototype identity
	b.eval.Set("NumLifeStage", int(a.StageID[idx]+1)) // 1-based for formulas
	b.eval.Set("IsAdult", a.StageID[idx] == -1)
	b.eval.Set("IsMale", a.Sex[idx] == world.SexMale)
	b.eval.Set("IsFemale", a.Sex[idx] == world.SexFemale)

	// Physiology: reserves
	for n := 0; n < cfg.NumNutrients; n++ {
		reserveIdx := idx*cfg.NumNutrients + n
		b.eval.SetInt("Reserve"+itoa(n+1), int(a.Reserves[reserveIdx]))
	}

	// Genetics: loci (expressed values = phenotype)
	for l := 0; l < cfg.NumLoci; l++ {
		locusBase := idx*cfg.NumLoci*2 + l*2
		// Continuous loci expression (codominance/dominance)
		expressed := expressLocusCont(
			a.GenotypeCont[locusBase], a.GenotypeCont[locusBase+1],
			a.DominanceCont[locusBase], a.DominanceCont[locusBase+1],
		)
		b.eval.SetFloat("CL"+itoa(l+1), expressed)

		// Discrete loci expression
		expressedDisc := expressLocusDisc(
			a.GenotypeDisc[locusBase], a.GenotypeDisc[locusBase+1],
			a.DominanceDisc[locusBase], a.DominanceDisc[locusBase+1],
		)
		b.eval.SetInt("DL"+itoa(l+1), expressedDisc)
	}

	// Reproduction
	b.eval.SetInt("QuantityGametes", int(a.GametesCount[idx]))
	b.eval.SetInt("QuantityFertilizedEggs", int(a.FertilizedCount[idx]))
	b.eval.SetInt("QuantitySpermPacksStored", int(a.SpermPacksCount[idx]))
	b.eval.SetInt("QuantityCarriedEggs", int(a.CarriedEggs[idx]))
	b.eval.Set("Virginity", a.SpermPacksCount[idx] == 0 && a.Sex[idx] == world.SexFemale)

	// Memory: last perceived/interacted for each perceivable element
	memPerceptionSlots := cfg.NumSubstrates + cfg.NumResourceTypes + cfg.NumPrototypes
	memBase := idx * memPerceptionSlots
	for s := 0; s < memPerceptionSlots; s++ {
		b.eval.SetInt("MemoryLastPer"+itoa(s+1), int(a.MemoryLastPerceived[memBase+s]))
		b.eval.SetInt("MemoryNumPer"+itoa(s+1), int(a.MemoryNumPerceived[memBase+s]))
		b.eval.SetInt("MemoryLastInt"+itoa(s+1), int(a.MemoryLastInteracted[memBase+s]))
		b.eval.SetInt("MemoryNumInt"+itoa(s+1), int(a.MemoryNumInteracted[memBase+s]))
	}

	// Memory: last behavior
	memBehaviorBase := idx * cfg.NumBehaviors
	for bh := 0; bh < cfg.NumBehaviors; bh++ {
		b.eval.SetInt("MemoryLastBehavior"+itoa(bh+1), int(a.MemoryLastBehavior[memBehaviorBase+bh]))
		b.eval.SetInt("MemoryNumBehavior"+itoa(bh+1), int(a.MemoryNumBehavior[memBehaviorBase+bh]))
	}

	// Morphology (fixed adult traits)
	if a.MorphologyFixed[idx] {
		for l := 0; l < cfg.NumLoci; l++ {
			morphBase := idx*cfg.NumLoci + l
			b.eval.SetFloat("Morphology"+itoa(l+1), a.MorphologyCont[morphBase])
			b.eval.SetInt("MorphologyDisc"+itoa(l+1), int(a.MorphologyDisc[morphBase]))
		}
	}
}

// SetContenderVars sets variables for the interacting opponent agent.
func (b *EnvBuilder) SetContenderVars(w *world.World, contenderIdx int) {
	a := w.Agents
	cfg := b.cfg

	b.eval.SetInt("ContenderAge", int(a.Age[contenderIdx]))
	b.eval.Set("ContenderIsMale", a.Sex[contenderIdx] == world.SexMale)
	b.eval.Set("ContenderIsFemale", a.Sex[contenderIdx] == world.SexFemale)

	// Contender morphology
	if a.MorphologyFixed[contenderIdx] {
		for l := 0; l < cfg.NumLoci; l++ {
			morphBase := contenderIdx*cfg.NumLoci + l
			b.eval.SetFloat("ContenderMorphology"+itoa(l+1), a.MorphologyCont[morphBase])
			b.eval.SetInt("ContenderMorphologyDisc"+itoa(l+1), int(a.MorphologyDisc[morphBase]))
		}
	}

	// Contender loci
	for l := 0; l < cfg.NumLoci; l++ {
		locusBase := contenderIdx*cfg.NumLoci*2 + l*2
		expressed := expressLocusCont(
			a.GenotypeCont[locusBase], a.GenotypeCont[locusBase+1],
			a.DominanceCont[locusBase], a.DominanceCont[locusBase+1],
		)
		b.eval.SetFloat("ContenderCL"+itoa(l+1), expressed)
	}
}

// SetResourceVars sets variables for the resource being interacted with.
func (b *EnvBuilder) SetResourceVars(w *world.World, resourceIdx int) {
	r := w.Resources
	b.eval.SetInt("DynamicElementLevel", int(r.Level[resourceIdx]))
	b.eval.SetInt("DynamicElementQuality", int(r.Quality[resourceIdx]))
}

// --- Genetic expression helpers ---

// expressLocusCont calculates the expressed phenotype for a continuous locus.
// Dominance rules: both dominant = codominance (average), heterozygous = dominant wins.
func expressLocusCont(patVal, matVal float64, patDom, matDom uint8) float64 {
	bothDom := patDom == 1 && matDom == 1
	bothRec := patDom == 0 && matDom == 0
	if bothDom || bothRec {
		// Codominance: average.
		return (patVal + matVal) / 2.0
	}
	if patDom == 1 {
		return patVal // Paternal dominance.
	}
	return matVal // Maternal dominance.
}

// expressLocusDisc calculates the expressed phenotype for a discrete locus.
func expressLocusDisc(patVal, matVal int32, patDom, matDom uint8) int {
	bothDom := patDom == 1 && matDom == 1
	bothRec := patDom == 0 && matDom == 0
	if bothDom || bothRec {
		return int((patVal + matVal) / 2)
	}
	if patDom == 1 {
		return int(patVal)
	}
	return int(matVal)
}

// itoa is a minimal int-to-string for small positive numbers (avoids strconv import).
func itoa(n int) string {
	if n < 0 {
		return "-" + itoa(-n)
	}
	if n < 10 {
		return string(rune('0' + n))
	}
	return itoa(n/10) + string(rune('0'+n%10))
}
