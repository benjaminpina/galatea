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
    Stages,
    Prototypes,
    ResourceTypes,
    Environments,
    SubstrateMapRows,
    EnvironmentResources,
    EnvironmentAgents,
    Metabolism,
    Reproduction,
  ],
  daos: [
    ProjectInfoDao,
    NutrientDao,
    SubstrateDao,
    LocusDao,
    StageDao,
    PrototypeDao,
    ResourceTypeDao,
    EnvironmentDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(String dbPath) : super(_openConnection(dbPath));

  // For testing with in-memory database.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
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
