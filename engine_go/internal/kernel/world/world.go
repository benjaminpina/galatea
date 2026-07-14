package world

// World is the top-level container for all simulation state.
// It is constructed once during the Cold Path and mutated in-place during ticks.
type World struct {
	Config    Config
	Agents    *AgentArrays
	Eggs      *EggArrays
	Resources *ResourceArrays
	Substrates *SubstrateMap
	Tick      int64
}

// New creates a fully allocated World based on the given configuration.
func New(cfg Config) *World {
	agentCap := cfg.InitialCapacity
	eggCap := cfg.InitialCapacity / 2
	if eggCap < 64 {
		eggCap = 64
	}
	resCap := 256 // Reasonable default for resource instances.

	return &World{
		Config:     cfg,
		Agents:     NewAgentArrays(agentCap, cfg),
		Eggs:       NewEggArrays(eggCap, cfg),
		Resources:  NewResourceArrays(resCap),
		Substrates: NewSubstrateMap(cfg.GridWidth, cfg.GridHeight),
		Tick:       0,
	}
}
