import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'daos.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    ProjectInfo,
    Nutrients,
    Substrates,
    SubstrateCompositions,
    Loci,
    MorphologicalCharacters,
    Stages,
    StageNutrientRequirements,
    StageTendencies,
    Prototypes,
    PrototypeMorphology,
    PrototypeTendencies,
    PrototypeCombat,
    PrototypeCourtship,
    PrototypeAssignmentCriteria,
    Environments,
    SubstrateMapRows,
    EnvironmentSources,
    EnvironmentOvipositionSites,
    EnvironmentAgents,
    EnvironmentAgentReserves,
    EnvironmentAgentMemory,
    Metabolism,
    BehaviorCosts,
    FeedingGains,
    SubstrateVelocities,
    Reproduction,
    GameteCosts,
    InteractionSubstrates,
    AttractivenessSubstrates,
    InteractionSources,
    AttractivenessSources,
    InteractionAgents,
    AttractivenessAgents,
    MemoryInfluence,
    OvipositionSiteConfig,
    CustomFunctions,
  ],
  daos: [
    ProjectInfoDao,
    NutrientDao,
    SubstrateDao,
    LocusDao,
    CharacterDao,
    StageDao,
    PrototypeDao,
    EnvironmentDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(String dbPath) : super(_openConnection(dbPath));

  // For testing with in-memory database.
  AppDatabase.memory() : super(NativeDatabase.memory());

  // DEVELOPMENT POLICY: the schema is NOT versioned during development.
  // It stays at version 1 and every structural change is treated as a brand
  // new initial schema. There are no migrations. When the schema changes,
  // simply delete the old project files and create new ones. Proper version
  // control and migrations will be added once the schema stabilizes for release.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
    },
  );
}

LazyDatabase _openConnection(String dbPath) {
  return LazyDatabase(() async {
    final dir = Directory(p.dirname(dbPath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(dbPath);
    return NativeDatabase.createInBackground(file);
  });
}
