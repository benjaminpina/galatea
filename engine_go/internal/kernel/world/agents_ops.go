package world

// AddAgent appends a new agent at index Count and increments Count.
// If capacity is exceeded, all slices are grown (doubling).
// Returns the index of the new agent.
func (w *World) AddAgent() int {
	a := w.Agents
	if a.Count >= a.Cap {
		w.growAgents()
	}
	idx := a.Count
	a.Count++

	// Initialize defaults for the new slot.
	a.InteractantIdx[idx] = -1
	a.StageID[idx] = -1
	a.PrototypeID[idx] = -1
	a.State[idx] = StateUndecided
	a.Situation[idx] = SituationImmature
	a.Direction[idx] = 1
	a.Speed[idx] = 1
	a.MorphologyFixed[idx] = false

	return idx
}

// RemoveAgent removes the agent at the given index using swap-and-pop.
// The last active agent is moved to the vacated slot to maintain contiguity.
// Returns the index of the agent that was swapped in (or -1 if it was the last).
func (w *World) RemoveAgent(idx int) int {
	a := w.Agents
	last := a.Count - 1
	if idx < 0 || idx > last {
		return -1
	}

	if idx != last {
		w.swapAgents(idx, last)
	}

	a.Count--
	return last
}

// swapAgents swaps all SoA data between indices i and j.
func (w *World) swapAgents(i, j int) {
	a := w.Agents
	cfg := w.Config
	numNutrients := cfg.NumNutrients
	numLoci := cfg.NumLoci
	numBehaviors := cfg.NumBehaviors
	memPerceptionSlots := cfg.NumSubstrates + cfg.NumResourceTypes + cfg.NumPrototypes
	memBehaviorSlots := numBehaviors

	// Scalar fields
	a.PosX[i], a.PosX[j] = a.PosX[j], a.PosX[i]
	a.PosY[i], a.PosY[j] = a.PosY[j], a.PosY[i]
	a.Direction[i], a.Direction[j] = a.Direction[j], a.Direction[i]
	a.Speed[i], a.Speed[j] = a.Speed[j], a.Speed[i]
	a.Sex[i], a.Sex[j] = a.Sex[j], a.Sex[i]
	a.StageID[i], a.StageID[j] = a.StageID[j], a.StageID[i]
	a.PrototypeID[i], a.PrototypeID[j] = a.PrototypeID[j], a.PrototypeID[i]
	a.Age[i], a.Age[j] = a.Age[j], a.Age[i]
	a.State[i], a.State[j] = a.State[j], a.State[i]
	a.Situation[i], a.Situation[j] = a.Situation[j], a.Situation[i]
	a.Decision[i], a.Decision[j] = a.Decision[j], a.Decision[i]
	a.InteractantIdx[i], a.InteractantIdx[j] = a.InteractantIdx[j], a.InteractantIdx[i]
	a.GametesCount[i], a.GametesCount[j] = a.GametesCount[j], a.GametesCount[i]
	a.FertilizedCount[i], a.FertilizedCount[j] = a.FertilizedCount[j], a.FertilizedCount[i]
	a.SpermPacksCount[i], a.SpermPacksCount[j] = a.SpermPacksCount[j], a.SpermPacksCount[i]
	a.CarriedEggs[i], a.CarriedEggs[j] = a.CarriedEggs[j], a.CarriedEggs[i]
	a.TimeInStage[i], a.TimeInStage[j] = a.TimeInStage[j], a.TimeInStage[i]
	a.TimeOnSubstrate[i], a.TimeOnSubstrate[j] = a.TimeOnSubstrate[j], a.TimeOnSubstrate[i]
	a.TimeInInteraction[i], a.TimeInInteraction[j] = a.TimeInInteraction[j], a.TimeInInteraction[i]
	a.LastOpponentAction[i], a.LastOpponentAction[j] = a.LastOpponentAction[j], a.LastOpponentAction[i]
	a.MorphologyFixed[i], a.MorphologyFixed[j] = a.MorphologyFixed[j], a.MorphologyFixed[i]

	// Reserves: numNutrients elements per agent.
	swapSlice(a.Reserves, i*numNutrients, j*numNutrients, numNutrients)

	// Genotype: numLoci*2 elements per agent.
	locusStride := numLoci * 2
	swapSliceF64(a.GenotypeCont, i*locusStride, j*locusStride, locusStride)
	swapSlice(a.GenotypeDisc, i*locusStride, j*locusStride, locusStride)
	swapSliceU8(a.DominanceCont, i*locusStride, j*locusStride, locusStride)
	swapSliceU8(a.DominanceDisc, i*locusStride, j*locusStride, locusStride)

	// Memory
	swapSlice(a.MemoryLastPerceived, i*memPerceptionSlots, j*memPerceptionSlots, memPerceptionSlots)
	swapSlice(a.MemoryNumPerceived, i*memPerceptionSlots, j*memPerceptionSlots, memPerceptionSlots)
	swapSlice(a.MemoryLastInteracted, i*memPerceptionSlots, j*memPerceptionSlots, memPerceptionSlots)
	swapSlice(a.MemoryNumInteracted, i*memPerceptionSlots, j*memPerceptionSlots, memPerceptionSlots)
	swapSlice(a.MemoryLastBehavior, i*memBehaviorSlots, j*memBehaviorSlots, memBehaviorSlots)
	swapSlice(a.MemoryNumBehavior, i*memBehaviorSlots, j*memBehaviorSlots, memBehaviorSlots)

	// Tendencies and VDecision
	swapSlice(a.Tendencies, i*8, j*8, 8)
	swapSlice(a.VDecision, i*numBehaviors, j*numBehaviors, numBehaviors)

	// Morphology
	swapSliceF64(a.MorphologyCont, i*numLoci, j*numLoci, numLoci)
	swapSlice(a.MorphologyDisc, i*numLoci, j*numLoci, numLoci)
}

// growAgents doubles the capacity of all agent slices.
func (w *World) growAgents() {
	a := w.Agents
	cfg := w.Config
	newCap := a.Cap * 2
	if newCap == 0 {
		newCap = 64
	}

	numNutrients := cfg.NumNutrients
	numLoci := cfg.NumLoci
	numBehaviors := cfg.NumBehaviors
	memPerceptionSlots := cfg.NumSubstrates + cfg.NumResourceTypes + cfg.NumPrototypes
	memBehaviorSlots := numBehaviors

	a.PosX = growF64(a.PosX, newCap)
	a.PosY = growF64(a.PosY, newCap)
	a.Direction = growU8(a.Direction, newCap)
	a.Speed = growI32(a.Speed, newCap)
	a.Sex = growU8(a.Sex, newCap)
	a.StageID = growI32(a.StageID, newCap)
	a.PrototypeID = growI32(a.PrototypeID, newCap)
	a.Age = growI32(a.Age, newCap)
	a.State = growU8(a.State, newCap)
	a.Situation = growU8(a.Situation, newCap)
	a.Decision = growU8(a.Decision, newCap)
	a.InteractantIdx = growI32(a.InteractantIdx, newCap)
	a.Reserves = growI32(a.Reserves, newCap*numNutrients)
	a.GenotypeCont = growF64(a.GenotypeCont, newCap*numLoci*2)
	a.GenotypeDisc = growI32(a.GenotypeDisc, newCap*numLoci*2)
	a.DominanceCont = growU8(a.DominanceCont, newCap*numLoci*2)
	a.DominanceDisc = growU8(a.DominanceDisc, newCap*numLoci*2)
	a.MemoryLastPerceived = growI32(a.MemoryLastPerceived, newCap*memPerceptionSlots)
	a.MemoryNumPerceived = growI32(a.MemoryNumPerceived, newCap*memPerceptionSlots)
	a.MemoryLastInteracted = growI32(a.MemoryLastInteracted, newCap*memPerceptionSlots)
	a.MemoryNumInteracted = growI32(a.MemoryNumInteracted, newCap*memPerceptionSlots)
	a.MemoryLastBehavior = growI32(a.MemoryLastBehavior, newCap*memBehaviorSlots)
	a.MemoryNumBehavior = growI32(a.MemoryNumBehavior, newCap*memBehaviorSlots)
	a.LastOpponentAction = growU8(a.LastOpponentAction, newCap)
	a.Tendencies = growI32(a.Tendencies, newCap*8)
	a.VDecision = growI32(a.VDecision, newCap*numBehaviors)
	a.GametesCount = growI32(a.GametesCount, newCap)
	a.FertilizedCount = growI32(a.FertilizedCount, newCap)
	a.SpermPacksCount = growI32(a.SpermPacksCount, newCap)
	a.CarriedEggs = growI32(a.CarriedEggs, newCap)
	a.TimeInStage = growI32(a.TimeInStage, newCap)
	a.TimeOnSubstrate = growI32(a.TimeOnSubstrate, newCap)
	a.TimeInInteraction = growI32(a.TimeInInteraction, newCap)
	a.MorphologyCont = growF64(a.MorphologyCont, newCap*numLoci)
	a.MorphologyDisc = growI32(a.MorphologyDisc, newCap*numLoci)
	a.MorphologyFixed = growBool(a.MorphologyFixed, newCap)

	// Initialize new slots for sentinel values.
	for i := a.Cap; i < newCap; i++ {
		a.InteractantIdx[i] = -1
		a.StageID[i] = -1
		a.PrototypeID[i] = -1
	}
	for i := a.Cap * memPerceptionSlots; i < newCap*memPerceptionSlots; i++ {
		a.MemoryLastPerceived[i] = -1
		a.MemoryLastInteracted[i] = -1
	}
	for i := a.Cap * memBehaviorSlots; i < newCap*memBehaviorSlots; i++ {
		a.MemoryLastBehavior[i] = -1
	}

	a.Cap = newCap
}

// --- helper functions for swap and grow ---

func swapSlice(s []int32, offI, offJ, count int) {
	for k := 0; k < count; k++ {
		s[offI+k], s[offJ+k] = s[offJ+k], s[offI+k]
	}
}

func swapSliceF64(s []float64, offI, offJ, count int) {
	for k := 0; k < count; k++ {
		s[offI+k], s[offJ+k] = s[offJ+k], s[offI+k]
	}
}

func swapSliceU8(s []uint8, offI, offJ, count int) {
	for k := 0; k < count; k++ {
		s[offI+k], s[offJ+k] = s[offJ+k], s[offI+k]
	}
}

func growI32(old []int32, newLen int) []int32 {
	s := make([]int32, newLen)
	copy(s, old)
	return s
}

func growF64(old []float64, newLen int) []float64 {
	s := make([]float64, newLen)
	copy(s, old)
	return s
}

func growU8(old []uint8, newLen int) []uint8 {
	s := make([]uint8, newLen)
	copy(s, old)
	return s
}

func growBool(old []bool, newLen int) []bool {
	s := make([]bool, newLen)
	copy(s, old)
	return s
}
