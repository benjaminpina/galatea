package formulas

import (
	"galatea/engine/internal/kernel/world"
)

// EnvBuilder populates an Evaluator's environment map with variables from
// the current agent state. Variable names are derived from user-defined names
// stored in Config.Names, making formulas use the exact identifiers the user
// chose when designing the project (e.g., "ReserveWater" instead of "Reserve1").
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
func (b *EnvBuilder) SetAgentVars(w *world.World, idx int) {
	a := w.Agents
	cfg := b.cfg
	names := cfg.Names

	// --- Time variables ---
	b.eval.SetInt("Age", int(a.Age[idx]))
	b.eval.SetInt("CyclesInCurrentLifeStage", int(a.TimeInStage[idx]))
	b.eval.SetInt("CyclesOnSubstrate", int(a.TimeOnSubstrate[idx]))
	b.eval.SetInt("CyclesInCurrentInteraction", int(a.TimeInInteraction[idx]))

	// --- Identity ---
	b.eval.SetInt("NumLifeStage", int(a.StageID[idx]+1))
	b.eval.Set("IsAdult", a.StageID[idx] == -1)
	b.eval.Set("IsMale", a.Sex[idx] == world.SexMale)
	b.eval.Set("IsFemale", a.Sex[idx] == world.SexFemale)

	// --- Physiology: reserves (named by nutrient) ---
	for n := 0; n < cfg.NumNutrients; n++ {
		reserveIdx := idx*cfg.NumNutrients + n
		name := nutrientVarName("Reserve", n, names.NutrientNames)
		b.eval.SetInt(name, int(a.Reserves[reserveIdx]))
	}

	// --- Genetics: loci (named by locus) ---
	for l := 0; l < cfg.NumLoci; l++ {
		locusBase := idx*cfg.NumLoci*2 + l*2

		expressed := expressLocusCont(
			a.GenotypeCont[locusBase], a.GenotypeCont[locusBase+1],
			a.DominanceCont[locusBase], a.DominanceCont[locusBase+1],
		)
		clName := locusVarName("CL", l, names.LocusNames)
		b.eval.SetFloat(clName, expressed)

		expressedDisc := expressLocusDisc(
			a.GenotypeDisc[locusBase], a.GenotypeDisc[locusBase+1],
			a.DominanceDisc[locusBase], a.DominanceDisc[locusBase+1],
		)
		dlName := locusVarName("DL", l, names.LocusNames)
		b.eval.SetInt(dlName, expressedDisc)
	}

	// --- Morphology (fixed adult traits, named by character) ---
	if a.MorphologyFixed[idx] {
		for c := 0; c < cfg.NumCharacters; c++ {
			morphBase := idx*cfg.NumCharacters + c
			name := characterVarName(c, names.CharacterNames)
			b.eval.SetFloat(name, a.MorphologyCont[morphBase])
			b.eval.SetInt(name+"Disc", int(a.MorphologyDisc[morphBase]))
		}
	}

	// --- Reproduction ---
	b.eval.SetInt("QuantityGametes", int(a.GametesCount[idx]))
	b.eval.SetInt("QuantityFertilizedEggs", int(a.FertilizedCount[idx]))
	b.eval.SetInt("QuantitySpermPacksStored", int(a.SpermPacksCount[idx]))
	b.eval.SetInt("QuantityCarriedEggs", int(a.CarriedEggs[idx]))
	b.eval.Set("Virginity", a.SpermPacksCount[idx] == 0 && a.Sex[idx] == world.SexFemale)

	// --- Memory: perception/interaction (named by element) ---
	// Element order: substrates, then nutrients (=resource types), then prototypes.
	slotIdx := 0

	// Substrates
	for s := 0; s < cfg.NumSubstrates; s++ {
		memIdx := idx*(cfg.NumSubstrates+cfg.NumResourceTypes+cfg.NumPrototypes) + slotIdx
		name := elementVarName(s, names.SubstrateNames)
		b.eval.SetInt("MemoryLastPer"+name, int(a.MemoryLastPerceived[memIdx]))
		b.eval.SetInt("MemoryNumPer"+name, int(a.MemoryNumPerceived[memIdx]))
		b.eval.SetInt("MemoryLastInt"+name, int(a.MemoryLastInteracted[memIdx]))
		b.eval.SetInt("MemoryNumInt"+name, int(a.MemoryNumInteracted[memIdx]))
		slotIdx++
	}

	// Nutrient sources (resource types)
	for n := 0; n < cfg.NumResourceTypes; n++ {
		memIdx := idx*(cfg.NumSubstrates+cfg.NumResourceTypes+cfg.NumPrototypes) + slotIdx
		name := nutrientVarName("Source", n, names.NutrientNames)
		b.eval.SetInt("MemoryLastPer"+name, int(a.MemoryLastPerceived[memIdx]))
		b.eval.SetInt("MemoryNumPer"+name, int(a.MemoryNumPerceived[memIdx]))
		b.eval.SetInt("MemoryLastInt"+name, int(a.MemoryLastInteracted[memIdx]))
		b.eval.SetInt("MemoryNumInt"+name, int(a.MemoryNumInteracted[memIdx]))
		slotIdx++
	}

	// Prototypes (stages + males + females)
	allProtoNames := buildAllProtoNames(names)
	for p := 0; p < cfg.NumPrototypes; p++ {
		memIdx := idx*(cfg.NumSubstrates+cfg.NumResourceTypes+cfg.NumPrototypes) + slotIdx
		name := protoVarName(p, allProtoNames)
		b.eval.SetInt("MemoryLastPer"+name, int(a.MemoryLastPerceived[memIdx]))
		b.eval.SetInt("MemoryNumPer"+name, int(a.MemoryNumPerceived[memIdx]))
		b.eval.SetInt("MemoryLastInt"+name, int(a.MemoryLastInteracted[memIdx]))
		b.eval.SetInt("MemoryNumInt"+name, int(a.MemoryNumInteracted[memIdx]))
		slotIdx++
	}

	// --- Memory: behaviors (named) ---
	memBehaviorBase := idx * cfg.NumBehaviors
	for bh := 0; bh < cfg.NumBehaviors; bh++ {
		name := behaviorVarName(bh, names.BehaviorNames)
		b.eval.SetInt("MemoryLast"+name, int(a.MemoryLastBehavior[memBehaviorBase+bh]))
		b.eval.SetInt("MemoryNum"+name, int(a.MemoryNumBehavior[memBehaviorBase+bh]))
	}
}

// SetContenderVars sets variables for the interacting opponent agent.
func (b *EnvBuilder) SetContenderVars(w *world.World, contenderIdx int) {
	a := w.Agents
	cfg := b.cfg
	names := cfg.Names

	b.eval.SetInt("ContenderAge", int(a.Age[contenderIdx]))
	b.eval.Set("ContenderIsMale", a.Sex[contenderIdx] == world.SexMale)
	b.eval.Set("ContenderIsFemale", a.Sex[contenderIdx] == world.SexFemale)

	// Contender morphology (uses characters, not loci)
	if a.MorphologyFixed[contenderIdx] {
		for c := 0; c < cfg.NumCharacters; c++ {
			morphBase := contenderIdx*cfg.NumCharacters + c
			name := characterVarName(c, names.CharacterNames)
			b.eval.SetFloat("Contender_"+name, a.MorphologyCont[morphBase])
			b.eval.SetInt("Contender_"+name+"Disc", int(a.MorphologyDisc[morphBase]))
		}
	}

	// Contender loci (genetics)
	for l := 0; l < cfg.NumLoci; l++ {
		locusBase := contenderIdx*cfg.NumLoci*2 + l*2
		expressed := expressLocusCont(
			a.GenotypeCont[locusBase], a.GenotypeCont[locusBase+1],
			a.DominanceCont[locusBase], a.DominanceCont[locusBase+1],
		)
		name := locusVarName("ContenderCL", l, names.LocusNames)
		b.eval.SetFloat(name, expressed)
	}
}

// SetResourceVars sets variables for the resource being interacted with.
func (b *EnvBuilder) SetResourceVars(w *world.World, resourceIdx int) {
	r := w.Resources
	b.eval.SetInt("DynamicElementLevel", int(r.Level[resourceIdx]))
	b.eval.SetInt("DynamicElementQuality", int(r.Quality[resourceIdx]))
}

// --- Variable name helpers ---

// characterVarName returns the character name or fallback "Char" + index.
func characterVarName(idx int, charNames []string) string {
	if idx < len(charNames) && charNames[idx] != "" {
		return charNames[idx]
	}
	return "Char" + itoa(idx+1)
}

// nutrientVarName returns "prefix + NutrientName" or "prefix + (index+1)" as fallback.
func nutrientVarName(prefix string, idx int, nutrientNames []string) string {
	if idx < len(nutrientNames) && nutrientNames[idx] != "" {
		return prefix + nutrientNames[idx]
	}
	return prefix + itoa(idx+1)
}

// locusVarName returns "prefix + LocusName" (with separator) or "prefix + (index+1)" as fallback (no separator).
func locusVarName(prefix string, idx int, locusNames []string) string {
	if idx < len(locusNames) && locusNames[idx] != "" {
		return prefix + "_" + locusNames[idx]
	}
	return prefix + itoa(idx+1)
}

// elementVarName returns the substrate/element name or fallback index.
func elementVarName(idx int, elementNames []string) string {
	if idx < len(elementNames) && elementNames[idx] != "" {
		return elementNames[idx]
	}
	return itoa(idx + 1)
}

// protoVarName returns the prototype name from the combined list.
func protoVarName(idx int, allNames []string) string {
	if idx < len(allNames) && allNames[idx] != "" {
		return allNames[idx]
	}
	return itoa(idx + 1)
}

// behaviorVarName returns the behavior name or fallback index.
func behaviorVarName(idx int, behaviorNames []string) string {
	if idx < len(behaviorNames) && behaviorNames[idx] != "" {
		return behaviorNames[idx]
	}
	return "Behavior" + itoa(idx+1)
}

// buildAllProtoNames concatenates stage + male + female prototype names.
func buildAllProtoNames(names world.Names) []string {
	all := make([]string, 0, len(names.StageNames)+len(names.PrototypeMNames)+len(names.PrototypeFNames))
	all = append(all, names.StageNames...)
	all = append(all, names.PrototypeMNames...)
	all = append(all, names.PrototypeFNames...)
	return all
}

// itoa is a minimal int-to-string helper (avoids importing strconv for hot path).
func itoa(n int) string {
	if n < 10 {
		return string(rune('0' + n))
	}
	return string(rune('0'+n/10)) + string(rune('0'+n%10))
}

// --- Genetic expression helpers ---

func expressLocusCont(patVal, matVal float64, patDom, matDom uint8) float64 {
	bothDom := patDom == 1 && matDom == 1
	bothRec := patDom == 0 && matDom == 0
	if bothDom || bothRec {
		return (patVal + matVal) / 2.0
	}
	if patDom == 1 {
		return patVal
	}
	return matVal
}

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
