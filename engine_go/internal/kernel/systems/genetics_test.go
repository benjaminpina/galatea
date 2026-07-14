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
	w.Agents.SpermPacksCount[female] = 0
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
	// Female: received 3 sperm packs.
	if w.Agents.SpermPacksCount[female] != 3 {
		t.Fatalf("female sperm packs: expected 3, got %d", w.Agents.SpermPacksCount[female])
	}
	// Female: 8 gametes * 0.5 = 4 fertilized.
	if w.Agents.FertilizedCount[female] != 4 {
		t.Fatalf("female fertilized: expected 4, got %d", w.Agents.FertilizedCount[female])
	}
	// Female: 8 - 4 = 4 unfertilized gametes remaining.
	if w.Agents.GametesCount[female] != 4 {
		t.Fatalf("female gametes: expected 4, got %d", w.Agents.GametesCount[female])
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
	w.Agents.FertilizedCount[female] = 5
	w.Agents.Reserves[female*cfg.NumNutrients+0] = 100
	w.Agents.Reserves[female*cfg.NumNutrients+1] = 100
	// Set genotype so crossover has something to work with.
	genoBase := female * cfg.NumLoci * 2
	for i := 0; i < cfg.NumLoci*2; i++ {
		w.Agents.GenotypeCont[genoBase+i] = float64(i + 1)
		w.Agents.GenotypeDisc[genoBase+i] = int32(i + 10)
		w.Agents.DominanceCont[genoBase+i] = uint8(i % 2)
		w.Agents.DominanceDisc[genoBase+i] = uint8((i + 1) % 2)
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
	if w.Agents.FertilizedCount[female] != 2 {
		t.Fatalf("expected 2 fertilized remaining, got %d", w.Agents.FertilizedCount[female])
	}
	if w.Agents.CarriedEggs[female] != 3 {
		t.Fatalf("expected 3 carried eggs, got %d", w.Agents.CarriedEggs[female])
	}

	// Check egg position.
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

func TestSpermConsumption(t *testing.T) {
	cfg := testCfg()
	w := world.New(cfg)

	female := w.AddAgent()
	w.Agents.Sex[female] = world.SexFemale
	w.Agents.SpermPacksCount[female] = 100

	reproCfg := ReproductionConfig{
		ConsumptionRate: 0.5, // 50% chance per pack per tick.
	}

	SpermConsumption(w, female, reproCfg)

	// With 100 packs and 50% rate, expect ~50 consumed (±15 tolerance).
	remaining := w.Agents.SpermPacksCount[female]
	if remaining < 30 || remaining > 70 {
		t.Fatalf("expected ~50 remaining packs, got %d", remaining)
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
