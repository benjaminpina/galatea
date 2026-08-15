import 'package:drift/drift.dart';

/// Project metadata (singleton — one row per workspace database).
class ProjectInfo extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get createdAt =>
      text().withDefault(Constant(DateTime.now().toIso8601String()))();
  TextColumn get updatedAt =>
      text().withDefault(Constant(DateTime.now().toIso8601String()))();

  @override
  Set<Column> get primaryKey => {id};
}

/// User-defined nutrient types (0..N).
/// Each nutrient implicitly defines its corresponding resource source.
class Nutrients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get color => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Substrate types (simple or mixed).
class Substrates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get color => integer().withDefault(const Constant(0))();
  BoolColumn get isMixed => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Mixed substrate compositions.
class SubstrateCompositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  @ReferenceName('mixedSubstrateCompositions')
  IntColumn get mixedSubstrateId => integer().references(Substrates, #id)();
  @ReferenceName('simpleSubstrateCompositions')
  IntColumn get simpleSubstrateId => integer().references(Substrates, #id)();
  IntColumn get percentage => integer().withDefault(const Constant(0))();
}

/// Genetic loci definitions (0..N). Pure hereditary units.
class Loci extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isContinuous => boolean().withDefault(const Constant(true))();
  RealColumn get dominantValue => real().withDefault(const Constant(0.0))();
  RealColumn get recessiveValue => real().withDefault(const Constant(0.0))();
  RealColumn get mutationRateDom => real().withDefault(const Constant(0.0))();
  RealColumn get mutationRateRec => real().withDefault(const Constant(0.0))();
  RealColumn get mutationRangeDom => real().withDefault(const Constant(0.0))();
  RealColumn get mutationRangeRec => real().withDefault(const Constant(0.0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Morphological characters (0..N). Phenotypic traits independent from loci.
class MorphologicalCharacters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isContinuous => boolean().withDefault(const Constant(true))();
  TextColumn get defaultExpression => text().withDefault(const Constant('0'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Immature life stages (0..N).
class Stages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get cyclesFormula => text().withDefault(const Constant('100'))();
  TextColumn get condition1Formula => text().withDefault(const Constant('0'))();
  TextColumn get condition1Op => text().withDefault(const Constant('>'))();
  RealColumn get condition1Value => real().withDefault(const Constant(0.0))();
  TextColumn get condition2Formula => text().withDefault(const Constant('0'))();
  TextColumn get condition2Op => text().withDefault(const Constant('>'))();
  RealColumn get condition2Value => real().withDefault(const Constant(0.0))();
  TextColumn get logicCyclesReqs => text().withDefault(const Constant('AND'))();
  TextColumn get logicReqsConds => text().withDefault(const Constant('AND'))();
  TextColumn get logicCond1Cond2 => text().withDefault(const Constant('AND'))();
  IntColumn get linkedPrototypeId => integer().nullable()();
  IntColumn get color => integer().withDefault(const Constant(0))();
}

/// Adult agent prototypes (0..N per sex).
class Prototypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get sex => text()();
  IntColumn get color => integer().withDefault(const Constant(0))();
  TextColumn get longevityFormula =>
      text().withDefault(const Constant('1000'))();
  TextColumn get refractoryCombatFormula =>
      text().withDefault(const Constant('10'))();
  TextColumn get refractoryCourtshipFormula =>
      text().withDefault(const Constant('10'))();
  TextColumn get sexRatioMalesFormula =>
      text().withDefault(const Constant('50'))();
  TextColumn get sexRatioFemalesFormula =>
      text().withDefault(const Constant('50'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Simulation environments.
class Environments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get createdAt =>
      text().withDefault(Constant(DateTime.now().toIso8601String()))();
  TextColumn get updatedAt =>
      text().withDefault(Constant(DateTime.now().toIso8601String()))();
}

/// Substrate map rows.
class SubstrateMapRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get environmentId => integer().references(Environments, #id)();
  IntColumn get yCoord => integer()();
  TextColumn get mapData => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {environmentId, yCoord},
  ];
}

/// Nutrient source instances placed in an environment.
/// Each source provides exactly one nutrient.
class EnvironmentSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get environmentId => integer().references(Environments, #id)();
  IntColumn get nutrientId => integer().references(Nutrients, #id)();
  TextColumn get name => text()();
  IntColumn get posX => integer()();
  IntColumn get posY => integer()();
  IntColumn get quality => integer().withDefault(const Constant(10))();
  IntColumn get level => integer().withDefault(const Constant(50))();
  IntColumn get maxLevel => integer().withDefault(const Constant(100))();
  RealColumn get regenRate => real().withDefault(const Constant(1.1))();
}

/// Oviposition site instances placed in an environment.
class EnvironmentOvipositionSites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get environmentId => integer().references(Environments, #id)();
  TextColumn get name => text()();
  IntColumn get posX => integer()();
  IntColumn get posY => integer()();
  IntColumn get quality => integer().withDefault(const Constant(10))();
  IntColumn get capacity => integer().withDefault(const Constant(50))();
}

/// Initial agent population in an environment.
class EnvironmentAgents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get environmentId => integer().references(Environments, #id)();
  TextColumn get name => text()();
  IntColumn get posX => integer()();
  IntColumn get posY => integer()();
  IntColumn get stageId => integer().nullable().references(Stages, #id)();
  IntColumn get prototypeId =>
      integer().nullable().references(Prototypes, #id)();
  TextColumn get sex => text()();
  IntColumn get age => integer().withDefault(const Constant(0))();
  IntColumn get orientation =>
      integer().withDefault(const Constant(1))(); // 1..8 (N,NE,E,SE,S,SW,W,NW)
  IntColumn get cyclesInStage =>
      integer().withDefault(const Constant(0))(); // ticks in current stage
  IntColumn get gametes =>
      integer().withDefault(const Constant(0))(); // available gametes
  IntColumn get fertilizedEggs =>
      integer().withDefault(const Constant(0))(); // fertilized eggs
  IntColumn get storedSpermPacks =>
      integer().withDefault(const Constant(0))(); // stored sperm packs
  BoolColumn get virgin =>
      boolean().withDefault(const Constant(true))(); // mating status
}

/// Per-agent initial memory entries.
/// Stores initial memory values (e.g., last perception tick, interaction count).
class EnvironmentAgentMemory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get agentId => integer().references(EnvironmentAgents, #id)();
  TextColumn get memoryKey => text()(); // e.g. 'lastPerGrass', 'numMove'
  RealColumn get value => real().withDefault(const Constant(0.0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {agentId, memoryKey},
  ];
}

/// Per-agent initial nutrient reserve levels.
/// Allows overriding the global metabolism defaults for specific placed agents.
class EnvironmentAgentReserves extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get agentId => integer().references(EnvironmentAgents, #id)();
  IntColumn get nutrientId => integer().references(Nutrients, #id)();
  RealColumn get initialLevel => real().withDefault(const Constant(50.0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {agentId, nutrientId},
  ];
}

/// Metabolism configuration per nutrient.
class Metabolism extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get nutrientId => integer().unique().references(Nutrients, #id)();
  TextColumn get minFormula => text().withDefault(const Constant('0'))();
  TextColumn get criticalFormula => text().withDefault(const Constant('10'))();
  TextColumn get optimalFormula => text().withDefault(const Constant('50'))();
  TextColumn get initialFormula => text().withDefault(const Constant('50'))();
  TextColumn get maxFormula => text().withDefault(const Constant('100'))();
}

/// Reproduction configuration (singleton).
class Reproduction extends Table {
  IntColumn get id => integer()();
  TextColumn get maxEggsFormula => text().withDefault(const Constant('10'))();
  TextColumn get maxSpermPacksFormula =>
      text().withDefault(const Constant('10'))();
  TextColumn get packsTransferredFormula =>
      text().withDefault(const Constant('1'))();
  TextColumn get fractionFertilizedFormula =>
      text().withDefault(const Constant('0.5'))();
  TextColumn get paternityFormula =>
      text().withDefault(const Constant('100'))();
  TextColumn get maxStoredPacksFormula =>
      text().withDefault(const Constant('5'))();
  TextColumn get consumptionRateFormula =>
      text().withDefault(const Constant('0.1'))();
  TextColumn get eggsPerCycleFormula =>
      text().withDefault(const Constant('1'))();
  TextColumn get eggFractionFormula =>
      text().withDefault(const Constant('0.5'))();
  TextColumn get packFractionFormula =>
      text().withDefault(const Constant('0.5'))();
  TextColumn get spermDegradationFormula =>
      text().withDefault(const Constant('0.05'))();

  @override
  Set<Column> get primaryKey => {id};
}

// =============================================================================
// STAGE DETAIL TABLES
// =============================================================================

/// Nutrient requirements and metabolic costs per stage.
class StageNutrientRequirements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get stageId => integer().references(Stages, #id)();
  IntColumn get nutrientId => integer().references(Nutrients, #id)();
  TextColumn get requirementFormula =>
      text().withDefault(const Constant('0'))();
  TextColumn get costFormula => text().withDefault(const Constant('0'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {stageId, nutrientId},
  ];
}

/// Movement tendencies per stage (8 directions).
class StageTendencies extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get stageId => integer().references(Stages, #id)();
  IntColumn get direction => integer()(); // 1..8
  TextColumn get formula => text().withDefault(const Constant('1'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {stageId, direction},
  ];
}

// =============================================================================
// PROTOTYPE DETAIL TABLES
// =============================================================================

/// Morphological character values (genetic + environmental formula) per character per prototype.
class PrototypeMorphology extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prototypeId => integer().references(Prototypes, #id)();
  IntColumn get characterId =>
      integer().references(MorphologicalCharacters, #id)();
  TextColumn get geneticFormula => text().withDefault(const Constant('0'))();
  TextColumn get environmentalFormula =>
      text().withDefault(const Constant('0'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {prototypeId, characterId},
  ];
}

/// Movement tendencies per prototype (8 directions).
class PrototypeTendencies extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prototypeId => integer().references(Prototypes, #id)();
  IntColumn get direction => integer()(); // 1..8
  TextColumn get formula => text().withDefault(const Constant('1'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {prototypeId, direction},
  ];
}

/// Combat strategy matrix per prototype: action × opponent_action → formula.
class PrototypeCombat extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prototypeId => integer().references(Prototypes, #id)();
  IntColumn get action => integer()();
  IntColumn get opponentAction => integer()();
  TextColumn get formula => text().withDefault(const Constant('1'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {prototypeId, action, opponentAction},
  ];
}

/// Courtship strategy matrix per prototype: action × opponent_action → formula.
class PrototypeCourtship extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prototypeId => integer().references(Prototypes, #id)();
  IntColumn get action => integer()();
  IntColumn get opponentAction => integer()();
  TextColumn get formula => text().withDefault(const Constant('1'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {prototypeId, action, opponentAction},
  ];
}

/// Criteria for assigning a prototype to an agent upon eclosion.
class PrototypeAssignmentCriteria extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prototypeId => integer().references(Prototypes, #id)();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get formula => text().withDefault(const Constant('0'))();
  TextColumn get operator => text().withDefault(const Constant('>'))();
  RealColumn get threshold => real().withDefault(const Constant(0.0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {prototypeId, priority},
  ];
}

// =============================================================================
// PHYSIOLOGY / BEHAVIOR TABLES
// =============================================================================

/// Behavioral costs per nutrient (movement, feeding, combat, courtship, oviposition).
class BehaviorCosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get behavior =>
      text()(); // e.g. 'move_active', 'feed', 'combat_attack'
  IntColumn get nutrientId => integer().references(Nutrients, #id)();
  TextColumn get costFormula => text().withDefault(const Constant('0'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {behavior, nutrientId},
  ];
}

/// Feeding gains per nutrient source.
class FeedingGains extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get nutrientId => integer().unique().references(Nutrients, #id)();
  TextColumn get gainFormula => text().withDefault(const Constant('10'))();
}

/// Velocity formula per substrate type.
class SubstrateVelocities extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get substrateId => integer().unique().references(Substrates, #id)();
  TextColumn get velocityFormula => text().withDefault(const Constant('1'))();
}

/// Gamete production costs per nutrient (separate for M and F).
class GameteCosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sex => text()(); // 'M' or 'F'
  IntColumn get nutrientId => integer().references(Nutrients, #id)();
  TextColumn get costFormula => text().withDefault(const Constant('5'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {sex, nutrientId},
  ];
}

// =============================================================================
// INTERACTION MATRICES
// =============================================================================

/// Substrate perception/decision matrix: how a perceiver reacts to a substrate.
class InteractionSubstrates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get substrateId => integer().references(Substrates, #id)();
  IntColumn get perceiverStageId =>
      integer().nullable().references(Stages, #id)();
  IntColumn get perceiverPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  IntColumn get behaviorIndex => integer()();
  TextColumn get formula => text().withDefault(const Constant('0'))();
}

/// Substrate attractiveness.
class AttractivenessSubstrates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get substrateId => integer().references(Substrates, #id)();
  IntColumn get perceiverStageId =>
      integer().nullable().references(Stages, #id)();
  IntColumn get perceiverPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  TextColumn get attractivenessFormula =>
      text().withDefault(const Constant('0'))();
  TextColumn get radiusFormula => text().withDefault(const Constant('5'))();
}

/// Nutrient source perception/decision matrix.
class InteractionSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get nutrientId => integer().references(Nutrients, #id)();
  IntColumn get perceiverStageId =>
      integer().nullable().references(Stages, #id)();
  IntColumn get perceiverPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  IntColumn get behaviorIndex => integer()();
  TextColumn get formula => text().withDefault(const Constant('0'))();
}

/// Nutrient source attractiveness.
class AttractivenessSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get nutrientId => integer().references(Nutrients, #id)();
  IntColumn get perceiverStageId =>
      integer().nullable().references(Stages, #id)();
  IntColumn get perceiverPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  TextColumn get attractivenessFormula =>
      text().withDefault(const Constant('0'))();
  TextColumn get radiusFormula => text().withDefault(const Constant('5'))();
}

/// Agent-to-agent perception/decision matrix.
class InteractionAgents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get observedStageId =>
      integer().nullable().references(Stages, #id)();
  IntColumn get observedPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  @ReferenceName('perceiverStageInteractionAgents')
  IntColumn get perceiverStageId =>
      integer().nullable().references(Stages, #id)();
  @ReferenceName('perceiverPrototypeInteractionAgents')
  IntColumn get perceiverPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  IntColumn get behaviorIndex => integer()();
  TextColumn get formula => text().withDefault(const Constant('0'))();
}

/// Agent-to-agent attractiveness.
class AttractivenessAgents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get observedStageId =>
      integer().nullable().references(Stages, #id)();
  IntColumn get observedPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  @ReferenceName('perceiverStageAttractivenessAgents')
  IntColumn get perceiverStageId =>
      integer().nullable().references(Stages, #id)();
  @ReferenceName('perceiverPrototypeAttractivenessAgents')
  IntColumn get perceiverPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  TextColumn get attractivenessFormula =>
      text().withDefault(const Constant('0'))();
  TextColumn get radiusFormula => text().withDefault(const Constant('5'))();
}

/// Memory influence matrix: how past interactions affect current behavior.
class MemoryInfluence extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get memoryType =>
      text()(); // e.g. 'last_perception', 'num_interactions'
  IntColumn get elementIndex => integer()();
  IntColumn get perceiverStageId =>
      integer().nullable().references(Stages, #id)();
  IntColumn get perceiverPrototypeId =>
      integer().nullable().references(Prototypes, #id)();
  TextColumn get formula => text().withDefault(const Constant('0'))();
}

/// Oviposition site global configuration (singleton).
class OvipositionSiteConfig extends Table {
  IntColumn get id => integer()();
  IntColumn get color => integer().withDefault(const Constant(0x00FF00))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// User-defined custom functions.
/// Generic mathematical functions with named numeric parameters.
/// The body is a formula that uses the parameter names.
/// At runtime, calls are expanded by substituting params into the body (macro-expansion).
class CustomFunctions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get params =>
      text().withDefault(const Constant(''))(); // comma-separated
  TextColumn get body => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
