package systems

import (
	"galatea/engine/internal/kernel/world"
)

// ReproductionConfig holds the parameters for reproduction mechanics.
type ReproductionConfig struct {
	MaxGametes         int32   // Maximum gametes an agent can produce.
	GameteCosts        []int32 // Cost per gamete per nutrient: [nutrient] = cost.
	PacksTransferred   int32   // Sperm packs transferred per copulation.
	MaxStoredPacks     int32   // Max sperm packs a female can store.
	FractionFertilized float64 // Fraction of eggs fertilized after copulation.
	PackFraction       float64 // Fraction of gamete reserves in each sperm pack.
	EggFraction        float64 // Fraction of gamete reserves allocated to egg.
	EggsPerCycle       int32   // Eggs oviposited per cycle.
	Paternity          int32   // Initial paternity weight for sperm packs.
	ConsumptionRate    float64 // Rate at which females consume stored sperm packs.
	SpermDegradation   float64 // Rate of paternity degradation per tick.
	MaleRatio          int     // Proportion for sex determination.
	FemaleRatio        int     // Proportion for sex determination.
}

// Gametogenesis produces gametes when the agent has optimal reserves.
// Each gamete costs a fixed amount of nutrients. Production continues until
// max gametes reached or reserves drop below cost.
func Gametogenesis(w *world.World, idx int, cfg ReproductionConfig) {
	a := w.Agents
	wcfg := w.Config
	numNut := wcfg.NumNutrients

	if len(cfg.GameteCosts) < numNut {
		return
	}

	reserveBase := idx * numNut
	currentGametes := a.GametesCount[idx] + a.FertilizedCount(idx)
	maxProducible := cfg.MaxGametes - currentGametes
	if maxProducible <= 0 {
		return
	}

	// Determine how many gametes can be afforded.
	produced := int32(0)
	for produced < maxProducible {
		canAfford := true
		for n := 0; n < numNut; n++ {
			if a.Reserves[reserveBase+n] < cfg.GameteCosts[n]*(produced+1) {
				canAfford = false
				break
			}
		}
		if !canAfford {
			break
		}
		produced++
	}

	if produced <= 0 {
		return
	}

	// Deduct costs.
	for n := 0; n < numNut; n++ {
		a.Reserves[reserveBase+n] -= cfg.GameteCosts[n] * produced
	}
	a.GametesCount[idx] += produced
}

// Copulate transfers sperm packs from male to female and triggers fertilization.
// maleIdx and femaleIdx must be valid agents in courtship that have both accepted.
//
// Each transferred pack carries a deep copy of the male's genotype plus a
// paternity weight, so the stored spermatheca preserves the paternal lineage
// (mirrors the legacy TPaqEspermatico). This enables real sexual inheritance
// at fertilization/oviposition time.
func Copulate(w *world.World, maleIdx, femaleIdx int, cfg ReproductionConfig, genCfg GeneticsConfig) {
	a := w.Agents
	wcfg := w.Config
	numLoci := wcfg.NumLoci
	numNut := wcfg.NumNutrients

	// Determine number of packs to transfer.
	available := a.GametesCount[maleIdx]
	transfer := cfg.PacksTransferred
	if transfer > available {
		transfer = available
	}

	// Cap by female storage capacity.
	freeSlots := cfg.MaxStoredPacks - a.SpermPackCount(femaleIdx)
	if transfer > freeSlots {
		transfer = freeSlots
	}

	if transfer <= 0 {
		return
	}

	// Package reserves per pack: a fraction of the male's current reserves.
	// The engine models the gonad as a count (GametesCount) rather than
	// per-gamete reserves, so we approximate the packaged reserves as a
	// fraction of the donor's reserves (legacy scales gonad reserves by
	// FraccPaquete). This keeps a meaningful nutrient payload on each pack.
	packReserves := make([]int32, numNut)
	maleResBase := maleIdx * numNut
	for n := 0; n < numNut; n++ {
		packReserves[n] = int32(float64(a.Reserves[maleResBase+n]) * cfg.PackFraction)
	}

	donor := donorID(maleIdx)

	// Transfer packs: deduct from male gametes, add genotype-carrying packs to
	// the female's spermatheca.
	a.GametesCount[maleIdx] -= transfer
	for t := int32(0); t < transfer; t++ {
		pack := world.NewSpermPackFromAgent(a, maleIdx, numLoci, numNut, packReserves, cfg.Paternity, donor)
		a.AddSpermPack(femaleIdx, pack)
	}

	// Fertilize a fraction of the female's unfertilized gametes, crossing each
	// with a sperm pack chosen by paternity-weighted roulette.
	fertilizeCount := int32(float64(a.GametesCount[femaleIdx]) * cfg.FractionFertilized)
	if fertilizeCount > a.GametesCount[femaleIdx] {
		fertilizeCount = a.GametesCount[femaleIdx]
	}
	FertilizeGametes(w, femaleIdx, fertilizeCount, cfg, genCfg)

	// Return both to regular state.
	a.Situation[maleIdx] = world.SituationRegular
	a.Situation[femaleIdx] = world.SituationRegular
	a.InteractantIdx[maleIdx] = -1
	a.InteractantIdx[femaleIdx] = -1
	a.TimeInInteraction[maleIdx] = 0
	a.TimeInInteraction[femaleIdx] = 0
}

// donorID builds a stable identifier for a donor male from its agent index.
// The engine identifies agents by index rather than name, so this provides
// lineage traceability on stored packs (mirrors the legacy Donador string).
func donorID(maleIdx int) string {
	return "M" + itoa(maleIdx)
}

// FertilizeGametes fertilizes up to `count` of the female's unfertilized
// gametes. For each gamete it selects a stored sperm pack by paternity-weighted
// roulette, crosses the mother's genotype with that pack's (paternal) genotype,
// applies mutations, and retains the resulting FertilizedEgg on the female
// (mirrors the legacy FertilizaFraccion/FertilizaCantidad). Gametes are only
// fertilized while packs are available and the female has unfertilized gametes.
//
// The sex of each fertilized egg is drawn from the offspring sex ratio.
// Returns the number of eggs actually fertilized.
func FertilizeGametes(w *world.World, femaleIdx int, count int32, cfg ReproductionConfig, genCfg GeneticsConfig) int32 {
	a := w.Agents
	numLoci := w.Config.NumLoci

	packs := a.SpermPacks[femaleIdx]
	if count <= 0 || len(packs) == 0 || a.GametesCount[femaleIdx] <= 0 {
		return 0
	}
	if count > a.GametesCount[femaleIdx] {
		count = a.GametesCount[femaleIdx]
	}

	// Mother's genotype (constant across this batch).
	motherContGeno := CopyGenotypeCont(a.GenotypeCont, femaleIdx, numLoci)
	motherDiscGeno := CopyGenotypeDisc(a.GenotypeDisc, femaleIdx, numLoci)
	motherContDom := CopyDominance(a.DominanceCont, femaleIdx, numLoci)
	motherDiscDom := CopyDominance(a.DominanceDisc, femaleIdx, numLoci)

	genoSize := numLoci * 2
	fertilized := int32(0)

	for fertilized < count {
		packs = a.SpermPacks[femaleIdx]
		if len(packs) == 0 {
			break // No more sperm to fertilize with.
		}

		// Choose a pack by paternity-weighted roulette.
		weights := make([]int32, len(packs))
		for i := range packs {
			weights[i] = packs[i].Paternity
		}
		p := Roulette(weights)
		pack := packs[p]

		// Cross mother × pack (father). The child receives one allele from each.
		childCont := make([]float64, genoSize)
		childContDom := make([]uint8, genoSize)
		CrossoverCont(pack.GenotypeCont, motherContGeno, pack.DominanceCont, motherContDom, childCont, childContDom, numLoci)

		childDisc := make([]int32, genoSize)
		childDiscDom := make([]uint8, genoSize)
		CrossoverDisc(pack.GenotypeDisc, motherDiscGeno, pack.DominanceDisc, motherDiscDom, childDisc, childDiscDom, numLoci)

		// Apply mutations.
		if len(genCfg.LociCont) >= numLoci {
			MutateCont(childCont, childContDom, numLoci, genCfg.LociCont)
		}
		if len(genCfg.LociDisc) >= numLoci {
			MutateDisc(childDisc, childDiscDom, numLoci, genCfg.LociDisc)
		}

		egg := world.FertilizedEgg{
			GenotypeCont:  childCont,
			GenotypeDisc:  childDisc,
			DominanceCont: childContDom,
			DominanceDisc: childDiscDom,
			Sex:           DetermineSex(cfg.MaleRatio, cfg.FemaleRatio),
			Donor:         pack.Donor,
		}
		a.AddFertilizedEgg(femaleIdx, egg)

		// Consume one gamete and one sperm pack (mirrors the legacy, where each
		// fertilization retires a gamete from the gonad and uses up a pack).
		a.GametesCount[femaleIdx]--
		a.RemoveSpermPack(femaleIdx, p)

		fertilized++
	}

	return fertilized
}

// Oviposit deposits the female's retained fertilized eggs into a contiguous
// oviposition site (the female's current interactant, set by
// EstablishInteraction). Each deposited egg keeps the genotype produced at
// fertilization (mother × sperm pack), so paternal inheritance flows through —
// no crossover is redone here (mirrors the legacy Oviposita, which moves eggs
// from Fertilizados into the site).
//
// The number laid is bounded by EggsPerCycle, the female's retained eggs, and
// the site's free capacity (MaxLevel - Level). Deposited eggs are positioned at
// the site and reference it as their carrier; the site's Level (egg count) is
// incremented. Returns the number laid. If the female has no valid oviposition
// site as interactant, nothing is laid.
func Oviposit(w *world.World, femaleIdx int, cfg ReproductionConfig, genCfg GeneticsConfig) int {
	a := w.Agents
	r := w.Resources
	wcfg := w.Config
	numLoci := wcfg.NumLoci
	numNut := wcfg.NumNutrients

	// Require a valid, contiguous oviposition site as the interactant.
	siteIdx := a.InteractantIdx[femaleIdx]
	if siteIdx < 0 || int(siteIdx) >= r.Count ||
		r.TypeID[siteIdx] != world.ResourceTypeOvipositionSite {
		return 0
	}

	eggsToLay := cfg.EggsPerCycle
	if available := a.FertilizedCount(femaleIdx); eggsToLay > available {
		eggsToLay = available
	}
	// Bound by the site's free capacity.
	if freeCap := r.MaxLevel[siteIdx] - r.Level[siteIdx]; eggsToLay > freeCap {
		eggsToLay = freeCap
	}
	if eggsToLay <= 0 {
		return 0
	}

	genoSize := numLoci * 2
	laid := 0
	for i := int32(0); i < eggsToLay; i++ {
		fEgg, ok := a.PopFertilizedEgg(femaleIdx)
		if !ok {
			break
		}

		eggIdx := addEgg(w)
		if eggIdx < 0 {
			// Could not allocate; put the egg back to avoid losing it.
			a.AddFertilizedEgg(femaleIdx, fEgg)
			break
		}

		eggs := w.Eggs

		// Position at the oviposition site (the egg's carrier).
		eggs.PosX[eggIdx] = r.PosX[siteIdx]
		eggs.PosY[eggIdx] = r.PosY[siteIdx]
		eggs.Age[eggIdx] = 0

		// Sex and genotype come from the retained fertilized egg.
		eggs.Sex[eggIdx] = fEgg.Sex

		eggContBase := eggIdx * genoSize
		eggDiscBase := eggIdx * genoSize
		copy(eggs.GenotypeCont[eggContBase:eggContBase+genoSize], fEgg.GenotypeCont)
		copy(eggs.DominanceCont[eggContBase:eggContBase+genoSize], fEgg.DominanceCont)
		copy(eggs.GenotypeDisc[eggDiscBase:eggDiscBase+genoSize], fEgg.GenotypeDisc)
		copy(eggs.DominanceDisc[eggDiscBase:eggDiscBase+genoSize], fEgg.DominanceDisc)

		// Allocate fraction of mother's reserves to egg.
		eggResBase := eggIdx * numNut
		motherResBase := femaleIdx * numNut
		for n := 0; n < numNut; n++ {
			eggReserve := int32(float64(a.Reserves[motherResBase+n]) * cfg.EggFraction / float64(eggsToLay))
			eggs.Reserves[eggResBase+n] = eggReserve
		}

		// Carrier is the oviposition site (not the mother); record parentage.
		eggs.CarrierAgentIdx[eggIdx] = -1
		eggs.CarrierResourceIdx[eggIdx] = siteIdx
		eggs.ParentMale[eggIdx] = fEgg.Donor
		eggs.ParentFemale[eggIdx] = "F" + itoa(femaleIdx)

		// Increment the site's egg count.
		r.Level[siteIdx]++

		laid++
	}

	return laid
}

// SpermConsumption metabolizes the stored sperm packs of a female agent each
// tick, mirroring the legacy ConsumoPaquetesEspermaticos: it draws a fraction
// (ConsumptionRate) of each pack's nutrient reserves into the female's own
// reserves, degrades each pack's paternity weight by SpermDegradation, and
// removes packs that are exhausted (no paternity and no reserves left).
func SpermConsumption(w *world.World, femaleIdx int, cfg ReproductionConfig) {
	a := w.Agents
	wcfg := w.Config
	if a.Sex[femaleIdx] != world.SexFemale {
		return
	}
	packs := a.SpermPacks[femaleIdx]
	if len(packs) == 0 {
		return
	}

	numNut := wcfg.NumNutrients
	femResBase := femaleIdx * numNut

	// Iterate in reverse so swap-and-pop removals are safe.
	for p := len(packs) - 1; p >= 0; p-- {
		pack := &packs[p]

		// Metabolize a fraction of the pack's reserves into the female.
		if cfg.ConsumptionRate > 0 {
			for n := 0; n < numNut && n < len(pack.Reserves); n++ {
				take := int32(float64(pack.Reserves[n]) * cfg.ConsumptionRate)
				if take <= 0 && pack.Reserves[n] > 0 {
					take = 1 // Ensure progress so packs eventually deplete.
				}
				if take > pack.Reserves[n] {
					take = pack.Reserves[n]
				}
				pack.Reserves[n] -= take
				a.Reserves[femResBase+n] += take
			}
		}

		// Degrade paternity weight.
		if cfg.SpermDegradation > 0 && pack.Paternity > 0 {
			deg := int32(float64(pack.Paternity) * cfg.SpermDegradation)
			if deg <= 0 {
				deg = 1 // Ensure eventual degradation.
			}
			pack.Paternity -= deg
			if pack.Paternity < 0 {
				pack.Paternity = 0
			}
		}

		// Remove packs that are fully exhausted.
		if pack.Paternity <= 0 && packReservesEmpty(pack) {
			a.RemoveSpermPack(femaleIdx, p)
		}
	}
}

// packReservesEmpty reports whether a sperm pack has no remaining reserves.
func packReservesEmpty(pack *world.SpermPack) bool {
	for _, r := range pack.Reserves {
		if r > 0 {
			return false
		}
	}
	return true
}

// IsOptimalForReproduction returns true if all reserves are at or above optimal level.
func IsOptimalForReproduction(a *world.AgentArrays, idx int, numNutrients int, optimalLevels []int32) bool {
	if len(optimalLevels) < numNutrients {
		return false
	}
	base := idx * numNutrients
	for n := 0; n < numNutrients; n++ {
		if a.Reserves[base+n] < optimalLevels[n] {
			return false
		}
	}
	return true
}

// --- Helpers ---

// addEgg appends a new egg to EggArrays, growing if necessary. Returns the index.
func addEgg(w *world.World) int {
	eggs := w.Eggs
	if eggs.Count >= eggs.Cap {
		growEggs(w)
	}
	idx := eggs.Count
	eggs.Count++

	// Initialize defaults.
	eggs.CarrierAgentIdx[idx] = -1
	eggs.CarrierResourceIdx[idx] = -1
	eggs.Age[idx] = 0

	return idx
}

// growEggs doubles the egg array capacity.
func growEggs(w *world.World) {
	e := w.Eggs
	cfg := w.Config
	newCap := e.Cap * 2
	if newCap == 0 {
		newCap = 64
	}

	numLoci := cfg.NumLoci
	numNut := cfg.NumNutrients

	e.PosX = growF64Slice(e.PosX, newCap)
	e.PosY = growF64Slice(e.PosY, newCap)
	e.Age = growI32Slice(e.Age, newCap)
	e.Sex = growU8Slice(e.Sex, newCap)
	e.Reserves = growI32Slice(e.Reserves, newCap*numNut)
	e.GenotypeCont = growF64Slice(e.GenotypeCont, newCap*numLoci*2)
	e.GenotypeDisc = growI32Slice(e.GenotypeDisc, newCap*numLoci*2)
	e.DominanceCont = growU8Slice(e.DominanceCont, newCap*numLoci*2)
	e.DominanceDisc = growU8Slice(e.DominanceDisc, newCap*numLoci*2)
	e.CarrierAgentIdx = growI32Slice(e.CarrierAgentIdx, newCap)
	e.CarrierResourceIdx = growI32Slice(e.CarrierResourceIdx, newCap)
	e.VDecision = growI32Slice(e.VDecision, newCap*2)
	e.ParentMale = growStringSlice(e.ParentMale, newCap)
	e.ParentFemale = growStringSlice(e.ParentFemale, newCap)

	// Initialize new carrier slots.
	for i := e.Cap; i < newCap; i++ {
		e.CarrierAgentIdx[i] = -1
		e.CarrierResourceIdx[i] = -1
	}

	e.Cap = newCap
}

func growF64Slice(old []float64, newLen int) []float64 {
	s := make([]float64, newLen)
	copy(s, old)
	return s
}

func growI32Slice(old []int32, newLen int) []int32 {
	s := make([]int32, newLen)
	copy(s, old)
	return s
}

func growU8Slice(old []uint8, newLen int) []uint8 {
	s := make([]uint8, newLen)
	copy(s, old)
	return s
}

func growStringSlice(old []string, newLen int) []string {
	s := make([]string, newLen)
	copy(s, old)
	return s
}
