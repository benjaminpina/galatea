import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/daos.dart';

// Re-export data classes for convenient use in UI layer.
export '../database/database.dart'
    show
        Nutrient,
        Substrate,
        LociData,
        Stage,
        Prototype,
        ResourceType,
        Environment;

/// The workspace database path. Must be set before accessing the database.
final workspacePathProvider = StateProvider<String?>((ref) => null);

/// The main database instance. Only available when a workspace is open.
final databaseProvider = Provider<AppDatabase?>((ref) {
  final path = ref.watch(workspacePathProvider);
  if (path == null) return null;
  final db = AppDatabase(path);
  ref.onDispose(() => db.close());
  return db;
});

/// DAO providers — only accessible when database is open.
final projectInfoDaoProvider = Provider<ProjectInfoDao?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return ProjectInfoDao(db);
});

final nutrientDaoProvider = Provider<NutrientDao?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return NutrientDao(db);
});

final substrateDaoProvider = Provider<SubstrateDao?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return SubstrateDao(db);
});

final locusDaoProvider = Provider<LocusDao?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return LocusDao(db);
});

final stageDaoProvider = Provider<StageDao?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return StageDao(db);
});

final prototypeDaoProvider = Provider<PrototypeDao?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return PrototypeDao(db);
});

final resourceTypeDaoProvider = Provider<ResourceTypeDao?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return ResourceTypeDao(db);
});

final environmentDaoProvider = Provider<EnvironmentDao?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return EnvironmentDao(db);
});

/// Stream providers for reactive UI updates.
final nutrientsProvider = StreamProvider<List<Nutrient>>((ref) {
  final dao = ref.watch(nutrientDaoProvider);
  if (dao == null) return const Stream.empty();
  return dao.watchAll();
});

final substratesProvider = StreamProvider<List<Substrate>>((ref) {
  final dao = ref.watch(substrateDaoProvider);
  if (dao == null) return const Stream.empty();
  return dao.watchAll();
});

final lociProvider = StreamProvider<List<LociData>>((ref) {
  final dao = ref.watch(locusDaoProvider);
  if (dao == null) return const Stream.empty();
  return dao.watchAll();
});

final stagesProvider = StreamProvider<List<Stage>>((ref) {
  final dao = ref.watch(stageDaoProvider);
  if (dao == null) return const Stream.empty();
  return dao.watchAll();
});

final prototypesProvider = StreamProvider<List<Prototype>>((ref) {
  final dao = ref.watch(prototypeDaoProvider);
  if (dao == null) return const Stream.empty();
  return dao.watchAll();
});

final resourceTypesProvider = StreamProvider<List<ResourceType>>((ref) {
  final dao = ref.watch(resourceTypeDaoProvider);
  if (dao == null) return const Stream.empty();
  return dao.watchAll();
});

final environmentsProvider = StreamProvider<List<Environment>>((ref) {
  final dao = ref.watch(environmentDaoProvider);
  if (dao == null) return const Stream.empty();
  return dao.watchAll();
});
