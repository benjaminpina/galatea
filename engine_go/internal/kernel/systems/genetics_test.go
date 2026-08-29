package systems

import (
	"testing"

	"galatea/engine/internal/kernel/world"
)

func TestExpressLocusCont_Codominance(t *testing.T) {
	// Both dominant → average.
	genotype := []float64{2.0, 4.0}
	dominance := []uint8{1, 1}
	result := ExpressLocusCont(genotype, dominance, 0, 0, 1)
	if result != 3.0 {
		t.Fatalf("expected 3.0 (codominance), got %f", result)
	}
}

func TestExpressLocusCont_PaternalDominance(t *testing.T) {
	genotype := []float64{2.0, 4.0}
	dominance := []uint8{1, 0} // Pat dominant, mat recessive.
	result := ExpressLocusCont(genotype, dominance, 0, 0, 1)
	if result != 2.0 {
		t.Fatalf("expected 2.0 (paternal), got %f", result)
	}
}

func TestExpressLocusCont_MaternalDominance(t *testing.T) {
	genotype := []float64{2.0, 4.0}
	dominance := []uint8{0, 1} // Pat recessive, mat dominant.
	result := ExpressLocusCont(genotype, dominance, 0, 0, 1)
	if result != 4.0 {
		t.Fatalf("expected 4.0 (maternal), got %f", result)
	}
}

func TestExpressLocusDisc(t *testing.T) {
	genotype := []int32{10, 20}
	dominance := []uint8{1, 1} // Both dominant → average.
	result := ExpressLocusDisc(genotype, dominance, 0, 0, 1)
	if result != 15 {
		t.Fatalf("expected 15, got %d", result)
	}
}

func TestCrossoverCont(t *testing.T) {
	numLoci := 3
	size := numLoci * 2

	parentA := []float64{1, 2, 3, 4, 5, 6}
	parentB := []float64{10, 20, 30, 40, 50, 60}
	domA := []uint8{1, 0, 1, 0, 1, 0}
	domB := []uint8{0, 1, 0, 1, 0, 1}

	child := make([]float64, size)
	childDom := make([]uint8, size)

	CrossoverCont(parentA, parentB, domA, domB, child, childDom, numLoci)

	// Each locus: allele 0 comes from A, allele 1 comes from B.
	for locus := 0; locus < numLoci; locus++ {
		base := locus * 2
		// Allele 0 must be from parent A.
		if child[base] != parentA[base] && child[base] != parentA[base+1] {
			t.Errorf("locus %d allele 0: %f not from parent A", locus, child[base])
		}
		// Allele 1 must be from parent B.
		if child[base+1] != parentB[base] && child[base+1] != parentB[base+1] {
			t.Errorf("locus %d allele 1: %f not from parent B", locus, child[base+1])
		}
	}
}

func TestCrossoverDisc(t *testing.T) {
	numLoci := 2
	size := numLoci * 2

	parentA := []int32{100, 200, 300, 400}
	parentB := []int32{1000, 2000, 3000, 4000}
	domA := []uint8{1, 0, 1, 0}
	domB := []uint8{0, 1, 0, 1}

	child := make([]int32, size)
	childDom := make([]uint8, size)

	CrossoverDisc(parentA, parentB, domA, domB, child, childDom, numLoci)

	for locus := 0; locus < numLoci; locus++ {
		base := locus * 2
		if child[base] != parentA[base] && child[base] != parentA[base+1] {
			t.Errorf("locus %d allele 0: %d not from parent A", locus, child[base])
		}
		if child[base+1] != parentB[base] && child[base+1] != parentB[base+1] {
			t.Errorf("locus %d allele 1: %d not from parent B", locus, child[base+1])
		}
	}
}

func TestMutateCont_HighRate(t *testing.T) {
	numLoci := 2
	genotype := []float64{1.0, 1.0, 2.0, 2.0}
	dominance := []uint8{1, 0, 1, 0}
	cfg := []LocusConfig{
		{MutationRateDom: 1.0, MutationRateRec: 1.0, MutationRangeDom: 0.5, MutationRangeRec: 0.5},
		{MutationRateDom: 1.0, MutationRateRec: 1.0, MutationRangeDom: 0.5, MutationRangeRec: 0.5},
	}

	original := make([]float64, len(genotype))
	copy(original, genotype)

	MutateCont(genotype, dominance, numLoci, cfg)

	// With rate=1.0, all should mutate.
	mutated := 0
	for i := range genotype {
		if genotype[i] != original[i] {
			mutated++
		}
	}
	if mutated == 0 {
		t.Fatal("expected at least some mutations with rate=1.0")
	}
}

func TestMutateCont_ZeroRate(t *testing.T) {
	numLoci := 2
	genotype := []float64{1.0, 1.0, 2.0, 2.0}
	dominance := []uint8{1, 0, 1, 0}
	cfg := []LocusConfig{
		{MutationRateDom: 0, MutationRateRec: 0},
		{MutationRateDom: 0, MutationRateRec: 0},
	}

	original := make([]float64, len(genotype))
	copy(original, genotype)

	MutateCont(genotype, dominance, numLoci, cfg)

	// No mutations.
	for i := range genotype {
		if genotype[i] != original[i] {
			t.Fatalf("unexpected mutation at index %d", i)
		}
	}
}

func TestDetermineSex(t *testing.T) {
	maleCount := 0
	const iterations = 10000
	for i := 0; i < iterations; i++ {
		if DetermineSex(50, 50) == world.SexMale {
			maleCount++
		}
	}
	ratio := float64(maleCount) / float64(iterations)
	if ratio < 0.45 || ratio > 0.55 {
		t.Fatalf("expected ~50%% males, got %.1f%%", ratio*100)
	}
}

func TestDetermineSex_Biased(t *testing.T) {
	maleCount := 0
	const iterations = 10000
	for i := 0; i < iterations; i++ {
		if DetermineSex(80, 20) == world.SexMale {
			maleCount++
		}
	}
	ratio := float64(maleCount) / float64(iterations)
	if ratio < 0.75 || ratio > 0.85 {
		t.Fatalf("expected ~80%% males, got %.1f%%", ratio*100)
	}
}

func TestGametogenesis(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 100
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 100
	w.Agents.GametesCount[idx] = 0

	reproCfg := ReproductionConfig{
		MaxGametes:  10,
		GameteCosts: []int32{5, 5}, // 5 of each nutrient per gamete.
	}

	Gametogenesis(w, idx, reproCfg)

	// With 100 of each nutrient and cost 5 each, can produce 100/5 = 20, capped at 10.
	if w.Agents.GametesCount[idx] != 10 {
		t.Fatalf("expected 10 gametes, got %d", w.Agents.GametesCount[idx])
	}
	// Reserves should be depleted by 10 * 5 = 50 each.
	if w.Agents.Reserves[idx*cfg.NumNutrients+0] != 50 {
		t.Fatalf("expected reserve0=50, got %d", w.Agents.Reserves[idx*cfg.NumNutrients+0])
	}
}

func TestGametogenesis_LimitedByReserves(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	idx := w.AddAgent()
	w.Agents.Reserves[idx*cfg.NumNutrients+0] = 12 // Can only afford 2 gametes.
	w.Agents.Reserves[idx*cfg.NumNutrients+1] = 100

	reproCfg := ReproductionConfig{
		MaxGametes:  100,
		GameteCosts: []int32{5, 5},
	}

	Gametogenesis(w, idx, reproCfg)

	if w.Agents.GametesCount[idx] != 2 {
		t.Fatalf("expected 2 gametes (limited by reserve0), got %d", w.Agents.GametesCount[idx])
	}
}

func TestCopulate(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	male := w.AddAgent()
	w.Agents.Sex[male] = world.SexMale
	w.Agents.GametesCount[male] = 5
	w.Agents.Situation[male] = world.SituationCourtship

	female := w.AddAgent()
	w.Agents.Sex[female] = world.SexFemale
	w.Agents.GametesCount[female] = 8
	w.Agents.Situation[female] = world.SituationCourtship
	w.Agents.InteractantIdx[male] = int32(female)
	w.Agents.InteractantIdx[female] = int32(male)

	reproCfg := ReproductionConfig{
		PacksTransferred:   3,
		MaxStoredPacks:     10,
		FractionFertilized: 0.5,
	}
	genCfg := GeneticsConfig{NumLoci: cfg.NumLoci}

	Copulate(w, male, female, reproCfg, genCfg)

	// Male: 5 - 3 = 2 gametes remaining.
	if w.Agents.GametesCount[male] != 2 {
		t.Fatalf("male gametes: expected 2, got %d", w.Agents.GametesCount[male])
	}
	// Copulate transfers 3 packs, then fertilizes: target = 8 gametes * 0.5 = 4,
	// but capped by the 3 available packs, so 3 gametes get fertilized and all
	// 3 packs are consumed (each fertilization uses one pack).
	if w.Agents.SpermPackCount(female) != 0 {
		t.Fatalf("expected 0 packs after copulate+fertilize, got %d", w.Agents.SpermPackCount(female))
	}
	// 3 retained fertilized eggs, each carrying a crossed genotype from the
	// donor male, with a sex and a recorded sire.
	if w.Agents.FertilizedCount(female) != 3 {
		t.Fatalf("female fertilized: expected 3, got %d", w.Agents.FertilizedCount(female))
	}
	for i, egg := range w.Agents.FertilizedEggs[female] {
		if len(egg.GenotypeCont) != cfg.NumLoci*2 {
			t.Fatalf("fertilized egg %d: expected genotype len %d, got %d", i, cfg.NumLoci*2, len(egg.GenotypeCont))
		}
		if egg.Sex != world.SexMale && egg.Sex != world.SexFemale {
			t.Fatalf("fertilized egg %d: invalid sex %d", i, egg.Sex)
		}
		if egg.Donor != donorID(male) {
			t.Fatalf("fertilized egg %d: expected sire %q, got %q", i, donorID(male), egg.Donor)
		}
	}
	// Female: 8 - 3 fertilized = 5 unfertilized gametes remaining.
	if w.Agents.GametesCount[female] != 5 {
		t.Fatalf("female gametes: expected 5, got %d", w.Agents.GametesCount[female])
	}
	// Both back to regular.
	if w.Agents.Situation[male] != world.SituationRegular {
		t.Fatalf("male should be regular, got %d", w.Agents.Situation[male])
	}
	if w.Agents.Situation[female] != world.SituationRegular {
		t.Fatalf("female should be regular, got %d", w.Agents.Situation[female])
	}
}

func TestOviposit(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	female := w.AddAgent()
	w.Agents.Sex[female] = world.SexFemale
	w.Agents.PosX[female] = 30
	w.Agents.PosY[female] = 40
	w.Agents.Reserves[female*cfg.NumNutrients+0] = 100
	w.Agents.Reserves[female*cfg.NumNutrients+1] = 100

	// Place a contiguous oviposition site (the carrier) with ample capacity,
	// and make it the female's interactant.
	site := w.Resources.Count
	w.Resources.PosX[site] = 30
	w.Resources.PosY[site] = 40
	w.Resources.TypeID[site] = world.ResourceTypeOvipositionSite
	w.Resources.Level[site] = 0
	w.Resources.MaxLevel[site] = 10
	w.Resources.Count++
	w.Agents.InteractantIdx[female] = int32(site)

	// Seed 5 retained fertilized eggs, each carrying a distinct genotype and a
	// known donor, so we can verify the deposited egg keeps its genotype.
	genoSize := cfg.NumLoci * 2
	for e := 0; e < 5; e++ {
		egg := world.FertilizedEgg{
			GenotypeCont:  make([]float64, genoSize),
			GenotypeDisc:  make([]int32, genoSize),
			DominanceCont: make([]uint8, genoSize),
			DominanceDisc: make([]uint8, genoSize),
			Sex:           world.SexMale,
			Donor:         "M7",
		}
		for i := 0; i < genoSize; i++ {
			egg.GenotypeCont[i] = float64(e*100 + i + 1)
			egg.GenotypeDisc[i] = int32(e*100 + i + 10)
		}
		w.Agents.AddFertilizedEgg(female, egg)
	}

	reproCfg := ReproductionConfig{
		EggsPerCycle: 3,
		EggFraction:  0.1,
		MaleRatio:    50,
		FemaleRatio:  50,
	}
	genCfg := GeneticsConfig{
		NumLoci:  cfg.NumLoci,
		LociCont: make([]LocusConfig, cfg.NumLoci),
		LociDisc: make([]LocusConfig, cfg.NumLoci),
	}

	laid := Oviposit(w, female, reproCfg, genCfg)

	if laid != 3 {
		t.Fatalf("expected 3 eggs laid, got %d", laid)
	}
	if w.Eggs.Count != 3 {
		t.Fatalf("expected 3 eggs in world, got %d", w.Eggs.Count)
	}
	if w.Agents.FertilizedCount(female) != 2 {
		t.Fatalf("expected 2 fertilized remaining, got %d", w.Agents.FertilizedCount(female))
	}
	// The first laid egg must keep the genotype of the first retained egg
	// (FIFO): GenotypeCont[0] was 0*100 + 0 + 1 = 1, and parentage recorded.
	if w.Eggs.GenotypeCont[0] != 1 {
		t.Fatalf("egg 0 genotype not preserved: expected 1, got %f", w.Eggs.GenotypeCont[0])
	}
	if w.Eggs.ParentMale[0] != "M7" {
		t.Fatalf("egg 0 sire not recorded: expected M7, got %q", w.Eggs.ParentMale[0])
	}
	// The oviposition site must hold the 3 deposited eggs.
	if w.Resources.Level[site] != 3 {
		t.Fatalf("expected site egg count 3, got %d", w.Resources.Level[site])
	}
	// Each egg must reference the site as its carrier (not the mother).
	for i := 0; i < 3; i++ {
		if w.Eggs.CarrierResourceIdx[i] != int32(site) {
			t.Fatalf("egg %d carrier: expected site %d, got %d", i, site, w.Eggs.CarrierResourceIdx[i])
		}
		if w.Eggs.CarrierAgentIdx[i] != -1 {
			t.Fatalf("egg %d should not be carried by the mother, got agent %d", i, w.Eggs.CarrierAgentIdx[i])
		}
	}

	// Check egg position matches the site.
	if w.Eggs.PosX[0] != 30 || w.Eggs.PosY[0] != 40 {
		t.Fatalf("egg 0 position: expected (30,40), got (%f,%f)", w.Eggs.PosX[0], w.Eggs.PosY[0])
	}
	// Check egg has a sex assigned.
	for i := 0; i < 3; i++ {
		if w.Eggs.Sex[i] != world.SexMale && w.Eggs.Sex[i] != world.SexFemale {
			t.Fatalf("egg %d has invalid sex: %d", i, w.Eggs.Sex[i])
		}
	}
}

// TestOvipositTriggeredByDecision is the point-3 guarantee: the engine's
// oviposition phase must fire only when the agent decided to oviposit, and it
// must actually deposit the retained fertilized eggs into the world.
func TestOvipositTriggeredByDecision(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	genoSize := cfg.NumLoci * 2
	ovipositIdx := behaviorOffsetFeed + cfg.NumResourceTypes + 4 // = 8 here

	female := w.AddAgent()
	w.Agents.Sex[female] = world.SexFemale
	w.Agents.PosX[female] = 10
	w.Agents.PosY[female] = 10
	for n := 0; n < cfg.NumNutrients; n++ {
		w.Agents.Reserves[female*cfg.NumNutrients+n] = 100
	}
	// Contiguous oviposition site as the female's interactant.
	site := w.Resources.Count
	w.Resources.PosX[site] = 10
	w.Resources.PosY[site] = 10
	w.Resources.TypeID[site] = world.ResourceTypeOvipositionSite
	w.Resources.MaxLevel[site] = 10
	w.Resources.Count++
	w.Agents.InteractantIdx[female] = int32(site)
	// Retain 3 fertilized eggs.
	for e := 0; e < 3; e++ {
		w.Agents.AddFertilizedEgg(female, world.FertilizedEgg{
			GenotypeCont:  make([]float64, genoSize),
			GenotypeDisc:  make([]int32, genoSize),
			DominanceCont: make([]uint8, genoSize),
			DominanceDisc: make([]uint8, genoSize),
			Sex:           world.SexFemale,
			Donor:         "M3",
		})
	}

	reproCfg := ReproductionConfig{EggsPerCycle: 2, EggFraction: 0.1, MaleRatio: 50, FemaleRatio: 50}
	genCfg := GeneticsConfig{
		NumLoci:  cfg.NumLoci,
		LociCont: make([]LocusConfig, cfg.NumLoci),
		LociDisc: make([]LocusConfig, cfg.NumLoci),
	}

	// Not deciding to oviposit: the phase must NOT fire.
	w.Agents.Decision[female] = uint8(behaviorRest)
	if IsOvipositDecision(w, female) {
		t.Fatal("rest decision should not be an oviposit decision")
	}

	// Deciding to oviposit: the phase fires and lays EggsPerCycle eggs.
	w.Agents.Decision[female] = uint8(ovipositIdx)
	if !IsOvipositDecision(w, female) {
		t.Fatal("oviposit decision not recognized")
	}
	laid := Oviposit(w, female, reproCfg, genCfg)
	if laid != 2 {
		t.Fatalf("expected 2 eggs laid, got %d", laid)
	}
	if w.Eggs.Count != 2 {
		t.Fatalf("expected 2 eggs deposited in world, got %d", w.Eggs.Count)
	}
	// 3 retained - 2 laid = 1 remaining.
	if w.Agents.FertilizedCount(female) != 1 {
		t.Fatalf("expected 1 fertilized egg remaining, got %d", w.Agents.FertilizedCount(female))
	}
}

// TestOvipositBoundedBySiteCapacity verifies eggs laid are capped by the
// oviposition site's free capacity, and the female keeps the eggs it couldn't
// deposit (mirrors the legacy Maximo-Nivel bound).
func TestOvipositBoundedBySiteCapacity(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	genoSize := cfg.NumLoci * 2

	female := w.AddAgent()
	w.Agents.Sex[female] = world.SexFemale
	w.Agents.PosX[female] = 5
	w.Agents.PosY[female] = 5

	// Site with only 1 free slot (capacity 2, already 1 egg deposited).
	site := w.Resources.Count
	w.Resources.PosX[site] = 5
	w.Resources.PosY[site] = 5
	w.Resources.TypeID[site] = world.ResourceTypeOvipositionSite
	w.Resources.Level[site] = 1
	w.Resources.MaxLevel[site] = 2
	w.Resources.Count++
	w.Agents.InteractantIdx[female] = int32(site)

	// Female wants to lay 3, but only 1 slot is free.
	for e := 0; e < 3; e++ {
		w.Agents.AddFertilizedEgg(female, world.FertilizedEgg{
			GenotypeCont:  make([]float64, genoSize),
			GenotypeDisc:  make([]int32, genoSize),
			DominanceCont: make([]uint8, genoSize),
			DominanceDisc: make([]uint8, genoSize),
			Sex:           world.SexFemale,
			Donor:         "M1",
		})
	}

	reproCfg := ReproductionConfig{EggsPerCycle: 3, EggFraction: 0.1, MaleRatio: 50, FemaleRatio: 50}
	genCfg := GeneticsConfig{NumLoci: cfg.NumLoci, LociCont: make([]LocusConfig, cfg.NumLoci), LociDisc: make([]LocusConfig, cfg.NumLoci)}

	laid := Oviposit(w, female, reproCfg, genCfg)
	if laid != 1 {
		t.Fatalf("expected 1 egg laid (capacity-bound), got %d", laid)
	}
	if w.Resources.Level[site] != 2 {
		t.Fatalf("expected site full (level 2), got %d", w.Resources.Level[site])
	}
	// 3 retained - 1 laid = 2 kept by the female.
	if w.Agents.FertilizedCount(female) != 2 {
		t.Fatalf("expected 2 eggs retained, got %d", w.Agents.FertilizedCount(female))
	}
}

// TestOvipositWithoutSiteLaysNothing verifies that without a valid oviposition
// site as interactant, no eggs are deposited (mirrors the legacy VDecision[11]
// veto when no contiguous site exists).
func TestOvipositWithoutSiteLaysNothing(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	genoSize := cfg.NumLoci * 2

	female := w.AddAgent()
	w.Agents.Sex[female] = world.SexFemale
	w.Agents.InteractantIdx[female] = -1 // No site.
	w.Agents.AddFertilizedEgg(female, world.FertilizedEgg{
		GenotypeCont:  make([]float64, genoSize),
		GenotypeDisc:  make([]int32, genoSize),
		DominanceCont: make([]uint8, genoSize),
		DominanceDisc: make([]uint8, genoSize),
		Sex:           world.SexFemale,
	})

	reproCfg := ReproductionConfig{EggsPerCycle: 3, EggFraction: 0.1, MaleRatio: 50, FemaleRatio: 50}
	genCfg := GeneticsConfig{NumLoci: cfg.NumLoci, LociCont: make([]LocusConfig, cfg.NumLoci), LociDisc: make([]LocusConfig, cfg.NumLoci)}

	laid := Oviposit(w, female, reproCfg, genCfg)
	if laid != 0 {
		t.Fatalf("expected 0 eggs laid without a site, got %d", laid)
	}
	if w.Eggs.Count != 0 {
		t.Fatalf("expected no eggs in world, got %d", w.Eggs.Count)
	}
	// The female keeps its fertilized egg.
	if w.Agents.FertilizedCount(female) != 1 {
		t.Fatalf("expected the egg retained, got %d", w.Agents.FertilizedCount(female))
	}
}

// TestPaternalInheritance is the end-to-end guarantee for point 2: after a real
// copulation + oviposition, offspring genotypes must carry alleles from the
// FATHER, not just the mother. We give the male a distinctive allele value the
// mother can never have, then verify every laid egg has at least one paternal
// allele at each locus (crossover takes one allele from each parent).
func TestPaternalInheritance(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	genoSize := cfg.NumLoci * 2

	const paternalMark = 1000.0 // Impossible for the mother.
	const maternalMark = 1.0

	male := w.AddAgent()
	w.Agents.Sex[male] = world.SexMale
	w.Agents.GametesCount[male] = 10
	w.Agents.Situation[male] = world.SituationCourtship
	maleGenoBase := male * genoSize
	for i := 0; i < genoSize; i++ {
		w.Agents.GenotypeCont[maleGenoBase+i] = paternalMark
	}

	female := w.AddAgent()
	w.Agents.Sex[female] = world.SexFemale
	w.Agents.GametesCount[female] = 10
	w.Agents.Situation[female] = world.SituationCourtship
	w.Agents.InteractantIdx[male] = int32(female)
	w.Agents.InteractantIdx[female] = int32(male)
	femaleGenoBase := female * genoSize
	for i := 0; i < genoSize; i++ {
		w.Agents.GenotypeCont[femaleGenoBase+i] = maternalMark
	}
	for n := 0; n < cfg.NumNutrients; n++ {
		w.Agents.Reserves[female*cfg.NumNutrients+n] = 100
	}

	// Oviposition site colocated with the female, used at laying time.
	site := w.Resources.Count
	w.Resources.PosX[site] = w.Agents.PosX[female]
	w.Resources.PosY[site] = w.Agents.PosY[female]
	w.Resources.TypeID[site] = world.ResourceTypeOvipositionSite
	w.Resources.MaxLevel[site] = 20
	w.Resources.Count++

	reproCfg := ReproductionConfig{
		PacksTransferred:   6,
		MaxStoredPacks:     10,
		FractionFertilized: 1.0, // Fertilize all available gametes.
		EggsPerCycle:       6,
		EggFraction:        0.1,
		MaleRatio:          50,
		FemaleRatio:        50,
	}
	// No mutation, so allele values stay exactly paternal or maternal.
	genCfg := GeneticsConfig{
		NumLoci:  cfg.NumLoci,
		LociCont: make([]LocusConfig, cfg.NumLoci),
		LociDisc: make([]LocusConfig, cfg.NumLoci),
	}

	Copulate(w, male, female, reproCfg, genCfg)

	if w.Agents.FertilizedCount(female) == 0 {
		t.Fatal("expected the female to have fertilized eggs after copulation")
	}

	// EstablishInteraction would set the oviposition site as interactant when
	// the female decides to lay; set it directly here for the unit test.
	w.Agents.InteractantIdx[female] = int32(site)
	laid := Oviposit(w, female, reproCfg, genCfg)
	if laid == 0 {
		t.Fatal("expected at least one egg laid")
	}

	// Every egg, at every locus, must have exactly one paternal and one
	// maternal allele (crossover picks one allele from each parent).
	for e := 0; e < laid; e++ {
		base := e * genoSize
		for locus := 0; locus < cfg.NumLoci; locus++ {
			a0 := w.Eggs.GenotypeCont[base+locus*2]
			a1 := w.Eggs.GenotypeCont[base+locus*2+1]
			hasPaternal := a0 == paternalMark || a1 == paternalMark
			hasMaternal := a0 == maternalMark || a1 == maternalMark
			if !hasPaternal {
				t.Fatalf("egg %d locus %d: no paternal allele (got %v, %v)", e, locus, a0, a1)
			}
			if !hasMaternal {
				t.Fatalf("egg %d locus %d: no maternal allele (got %v, %v)", e, locus, a0, a1)
			}
		}
		// Sire must be recorded.
		if w.Eggs.ParentMale[e] != donorID(male) {
			t.Fatalf("egg %d: expected sire %q, got %q", e, donorID(male), w.Eggs.ParentMale[e])
		}
	}
}

func TestSpermConsumption(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)
	numNut := cfg.NumNutrients

	female := w.AddAgent()
	w.Agents.Sex[female] = world.SexFemale

	// Give the female two packs: one with reserves + paternity, one exhausted.
	fullPack := world.SpermPack{
		GenotypeCont:  make([]float64, cfg.NumLoci*2),
		GenotypeDisc:  make([]int32, cfg.NumLoci*2),
		DominanceCont: make([]uint8, cfg.NumLoci*2),
		DominanceDisc: make([]uint8, cfg.NumLoci*2),
		Reserves:      make([]int32, numNut),
		Paternity:     100,
		Donor:         "M0",
	}
	for n := 0; n < numNut; n++ {
		fullPack.Reserves[n] = 100
	}
	emptyPack := world.SpermPack{
		Reserves:  make([]int32, numNut), // all zero
		Paternity: 0,
	}
	w.Agents.AddSpermPack(female, fullPack)
	w.Agents.AddSpermPack(female, emptyPack)

	femResBefore := make([]int32, numNut)
	copy(femResBefore, w.Agents.Reserves[female*numNut:female*numNut+numNut])

	reproCfg := ReproductionConfig{
		ConsumptionRate:  0.5,
		SpermDegradation: 0.5,
	}

	SpermConsumption(w, female, reproCfg)

	// The exhausted pack (paternity 0, no reserves) must be removed.
	if w.Agents.SpermPackCount(female) != 1 {
		t.Fatalf("expected 1 pack remaining (exhausted removed), got %d", w.Agents.SpermPackCount(female))
	}

	// The full pack must have degraded paternity (100 * 0.5 = 50).
	remaining := w.Agents.SpermPacks[female][0]
	if remaining.Paternity != 50 {
		t.Fatalf("expected paternity 50 after degradation, got %d", remaining.Paternity)
	}

	// The female must have gained reserves from the metabolized pack.
	for n := 0; n < numNut; n++ {
		gained := w.Agents.Reserves[female*numNut+n] - femResBefore[n]
		if gained <= 0 {
			t.Fatalf("nutrient %d: expected female to gain reserves, gained %d", n, gained)
		}
	}
}

func TestCopyAndWriteGenotype(t *testing.T) {
	numLoci := 3
	src := make([]float64, 10*numLoci*2) // 10 agents.
	// Agent 2.
	base := 2 * numLoci * 2
	for i := 0; i < numLoci*2; i++ {
		src[base+i] = float64(i + 100)
	}

	copied := CopyGenotypeCont(src, 2, numLoci)
	if len(copied) != numLoci*2 {
		t.Fatalf("expected len=%d, got %d", numLoci*2, len(copied))
	}
	if copied[0] != 100 || copied[5] != 105 {
		t.Fatalf("copy incorrect: %v", copied)
	}

	// Write to agent 5.
	dst := make([]float64, 10*numLoci*2)
	WriteGenotypeCont(dst, 5, numLoci, copied)

	dstBase := 5 * numLoci * 2
	if dst[dstBase] != 100 || dst[dstBase+5] != 105 {
		t.Fatalf("write incorrect at agent 5")
	}
}
