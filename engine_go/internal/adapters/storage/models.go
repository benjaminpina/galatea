package storage

// ProjectInfo holds the metadata for this workspace's project (singleton).
type ProjectInfo struct {
	Name        string
	Description string
	CreatedAt   string
	UpdatedAt   string
}

// Nutrient represents a user-defined nutrient type (e.g., Water, Sugar, Fat).
type Nutrient struct {
	ID        int64
	Name      string
	SortOrder int
}

// Substrate represents a terrain type (simple or mixed).
type Substrate struct {
	ID        int64
	Name      string
	Color     int
	IsMixed   bool
	SortOrder int
}

// SubstrateComposition represents the percentage of a simple substrate within a mixed one.
type SubstrateComposition struct {
	ID                int64
	MixedSubstrateID  int64
	SimpleSubstrateID int64
	Percentage        int
}

// Locus represents a genetic locus definition.
type Locus struct {
	ID                int64
	Name              string
	IsContinuous      bool
	DominantValue     float64
	RecessiveValue    float64
	MutationRateDom   float64
	MutationRateRec   float64
	MutationRangeDom  float64
	MutationRangeRec  float64
	DefaultExpression string
	SortOrder         int
}

// Stage represents an immature life stage.
type Stage struct {
	ID                int64
	Name              string
	SortOrder         int
	CyclesFormula     string
	Condition1Formula string
	Condition1Op      string
	Condition1Value   float64
	Condition2Formula string
	Condition2Op      string
	Condition2Value   float64
	LogicCyclesReqs   string
	LogicReqsConds    string
	LogicCond1Cond2   string
	LinkedPrototypeID *int64
	Color             int
}

// Prototype represents an adult agent archetype.
type Prototype struct {
	ID                         int64
	Name                       string
	Sex                        string
	Color                      int
	LongevityFormula           string
	RefractoryCombatFormula    string
	RefractoryCourtshipFormula string
	SexRatioMalesFormula       string
	SexRatioFemalesFormula     string
	SortOrder                  int
}

// ResourceType represents a type of dynamic element in the environment.
type ResourceType struct {
	ID            int64
	Name          string
	NutrientID    *int64
	IsOviposition bool
	Color         int
	SortOrder     int
}

// Environment represents a configured simulation environment.
type Environment struct {
	ID          int64
	Name        string
	Width       int
	Height      int
	Description string
	CreatedAt   string
	UpdatedAt   string
}

// EnvironmentResource represents a resource instance placed in the environment.
type EnvironmentResource struct {
	ID             int64
	EnvironmentID  int64
	ResourceTypeID int64
	Name           string
	PosX           int
	PosY           int
	Quality        int
	Level          int
	MaxLevel       int
	RegenRate      float64
}

// EnvironmentAgent represents an initial agent in the environment.
type EnvironmentAgent struct {
	ID            int64
	EnvironmentID int64
	Name          string
	PosX          int
	PosY          int
	StageID       *int64
	PrototypeID   *int64
	Sex           string
	Age           int
}

// SimRun represents a simulation execution record.
type SimRun struct {
	ID            int64
	EnvironmentID int64
	StartedAt     string
	EndedAt       *string
	TotalTicks    int
	Status        string
}
