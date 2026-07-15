import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [ProjectInfo])
class ProjectInfoDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectInfoDaoMixin {
  ProjectInfoDao(super.db);

  Future<void> init(String name, String description) async {
    await into(projectInfo).insert(
      ProjectInfoCompanion.insert(
        id: const Value(1),
        name: name,
        description: Value(description),
      ),
    );
  }

  Future<ProjectInfoData?> get() =>
      (select(projectInfo)..where((t) => t.id.equals(1))).getSingleOrNull();

  Future<void> updateInfo(String name, String description) async {
    await (update(projectInfo)..where((t) => t.id.equals(1))).write(
      ProjectInfoCompanion(
        name: Value(name),
        description: Value(description),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }
}

@DriftAccessor(tables: [Nutrients])
class NutrientDao extends DatabaseAccessor<AppDatabase>
    with _$NutrientDaoMixin {
  NutrientDao(super.db);

  Future<int> add(String name, int sortOrder) => into(
    nutrients,
  ).insert(NutrientsCompanion.insert(name: name, sortOrder: Value(sortOrder)));

  Future<List<Nutrient>> getAll() => (select(
    nutrients,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Stream<List<Nutrient>> watchAll() => (select(
    nutrients,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  Future<void> remove(int id) =>
      (delete(nutrients)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Substrates, SubstrateCompositions])
class SubstrateDao extends DatabaseAccessor<AppDatabase>
    with _$SubstrateDaoMixin {
  SubstrateDao(super.db);

  Future<int> add(String name, int color, bool isMixed, int sortOrder) =>
      into(substrates).insert(
        SubstratesCompanion.insert(
          name: name,
          color: Value(color),
          isMixed: Value(isMixed),
          sortOrder: Value(sortOrder),
        ),
      );

  Future<List<Substrate>> getAll() => (select(
    substrates,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Stream<List<Substrate>> watchAll() => (select(
    substrates,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  Future<void> remove(int id) =>
      (delete(substrates)..where((t) => t.id.equals(id))).go();

  Future<void> updateSubstrate(int id, String name, int color) =>
      (update(substrates)..where((t) => t.id.equals(id))).write(
        SubstratesCompanion(name: Value(name), color: Value(color)),
      );

  Future<void> addComposition(int mixedId, int simpleId, int percentage) =>
      into(substrateCompositions).insert(
        SubstrateCompositionsCompanion.insert(
          mixedSubstrateId: mixedId,
          simpleSubstrateId: simpleId,
          percentage: Value(percentage),
        ),
      );

  Future<List<SubstrateComposition>> getCompositions(int mixedId) => (select(
    substrateCompositions,
  )..where((t) => t.mixedSubstrateId.equals(mixedId))).get();
}

@DriftAccessor(tables: [Loci])
class LocusDao extends DatabaseAccessor<AppDatabase> with _$LocusDaoMixin {
  LocusDao(super.db);

  Future<int> add(LociCompanion entry) => into(loci).insert(entry);

  Future<List<LociData>> getAll() =>
      (select(loci)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Stream<List<LociData>> watchAll() =>
      (select(loci)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  Future<void> remove(int id) =>
      (delete(loci)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Stages])
class StageDao extends DatabaseAccessor<AppDatabase> with _$StageDaoMixin {
  StageDao(super.db);

  Future<int> add(StagesCompanion entry) => into(stages).insert(entry);

  Future<List<Stage>> getAll() =>
      (select(stages)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Stream<List<Stage>> watchAll() =>
      (select(stages)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  Future<void> remove(int id) =>
      (delete(stages)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Prototypes])
class PrototypeDao extends DatabaseAccessor<AppDatabase>
    with _$PrototypeDaoMixin {
  PrototypeDao(super.db);

  Future<int> add(PrototypesCompanion entry) => into(prototypes).insert(entry);

  Future<List<Prototype>> getAll() =>
      (select(prototypes)..orderBy([
            (t) => OrderingTerm.asc(t.sex),
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
          .get();

  Future<List<Prototype>> getBySex(String sex) =>
      (select(prototypes)
            ..where((t) => t.sex.equals(sex))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Stream<List<Prototype>> watchAll() =>
      (select(prototypes)..orderBy([
            (t) => OrderingTerm.asc(t.sex),
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
          .watch();

  Future<void> remove(int id) =>
      (delete(prototypes)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [ResourceTypes])
class ResourceTypeDao extends DatabaseAccessor<AppDatabase>
    with _$ResourceTypeDaoMixin {
  ResourceTypeDao(super.db);

  Future<int> add(ResourceTypesCompanion entry) =>
      into(resourceTypes).insert(entry);

  Future<List<ResourceType>> getAll() => (select(
    resourceTypes,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Stream<List<ResourceType>> watchAll() => (select(
    resourceTypes,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  Future<void> remove(int id) =>
      (delete(resourceTypes)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Environments, EnvironmentResources, EnvironmentAgents])
class EnvironmentDao extends DatabaseAccessor<AppDatabase>
    with _$EnvironmentDaoMixin {
  EnvironmentDao(super.db);

  Future<int> add(String name, int width, int height, String description) =>
      into(environments).insert(
        EnvironmentsCompanion.insert(
          name: name,
          width: width,
          height: height,
          description: Value(description),
        ),
      );

  Future<List<Environment>> getAll() =>
      (select(environments)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Stream<List<Environment>> watchAll() =>
      (select(environments)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();

  Future<void> remove(int id) =>
      (delete(environments)..where((t) => t.id.equals(id))).go();

  Future<int> placeResource(EnvironmentResourcesCompanion entry) =>
      into(environmentResources).insert(entry);

  Future<List<EnvironmentResource>> getResources(int envId) => (select(
    environmentResources,
  )..where((t) => t.environmentId.equals(envId))).get();

  Future<int> placeAgent(EnvironmentAgentsCompanion entry) =>
      into(environmentAgents).insert(entry);

  Future<List<EnvironmentAgent>> getAgents(int envId) => (select(
    environmentAgents,
  )..where((t) => t.environmentId.equals(envId))).get();
}
