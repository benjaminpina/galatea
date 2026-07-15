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
class Nutrients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
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

/// Genetic loci definitions (0..N).
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
  TextColumn get sex => text()(); // 'M' or 'F'
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

/// Resource/dynamic element types (0..N).
class ResourceTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get nutrientId => integer().nullable().references(Nutrients, #id)();
  BoolColumn get isOviposition =>
      boolean().withDefault(const Constant(false))();
  IntColumn get color => integer().withDefault(const Constant(0))();
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

/// Substrate map rows (one per Y coordinate in an environment).
class SubstrateMapRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get environmentId => integer().references(Environments, #id)();
  IntColumn get yCoord => integer()();
  TextColumn get mapData => text()(); // Comma-separated substrate IDs.

  @override
  List<Set<Column>> get uniqueKeys => [
    {environmentId, yCoord},
  ];
}

/// Resource instances placed in an environment.
class EnvironmentResources extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get environmentId => integer().references(Environments, #id)();
  IntColumn get resourceTypeId => integer().references(ResourceTypes, #id)();
  TextColumn get name => text()();
  IntColumn get posX => integer()();
  IntColumn get posY => integer()();
  IntColumn get quality => integer().withDefault(const Constant(10))();
  IntColumn get level => integer().withDefault(const Constant(50))();
  IntColumn get maxLevel => integer().withDefault(const Constant(100))();
  RealColumn get regenRate => real().withDefault(const Constant(1.1))();
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
  TextColumn get sex => text()(); // 'M', 'F', 'U'
  IntColumn get age => integer().withDefault(const Constant(0))();
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
