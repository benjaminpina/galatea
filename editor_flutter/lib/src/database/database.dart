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

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 5) {
        // v4 → v5: Add new columns to environment_agents + new tables.
        await customStatement(
          'ALTER TABLE environment_agents ADD COLUMN orientation INTEGER NOT NULL DEFAULT 1',
        );
        await customStatement(
          'ALTER TABLE environment_agents ADD COLUMN cycles_in_stage INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement(
          'ALTER TABLE environment_agents ADD COLUMN gametes INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement(
          'ALTER TABLE environment_agents ADD COLUMN fertilized_eggs INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement(
          'ALTER TABLE environment_agents ADD COLUMN stored_sperm_packs INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement(
          'ALTER TABLE environment_agents ADD COLUMN virgin INTEGER NOT NULL DEFAULT 1',
        );
        // Create new tables.
        await m.createTable(environmentAgentReserves);
        await m.createTable(environmentAgentMemory);
      }
    },
    beforeOpen: (details) async {
      // Enable foreign keys and WAL mode.
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
