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

  Future<int> add(String name, int color, int sortOrder) =>
      into(nutrients).insert(
        NutrientsCompanion.insert(
          name: name,
          color: Value(color),
          sortOrder: Value(sortOrder),
        ),
      );

  Future<List<Nutrient>> getAll() => (select(
    nutrients,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Stream<List<Nutrient>> watchAll() => (select(
    nutrients,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  Future<void> updateNutrient(int id, String name, int color) =>
      (update(nutrients)..where((t) => t.id.equals(id))).write(
        NutrientsCompanion(name: Value(name), color: Value(color)),
      );

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

  Future<void> updateSubstrate(int id, String name, int color) =>
      (update(substrates)..where((t) => t.id.equals(id))).write(
        SubstratesCompanion(name: Value(name), color: Value(color)),
      );

  Future<void> remove(int id) =>
      (delete(substrates)..where((t) => t.id.equals(id))).go();

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

  /// Deletes all existing compositions for a mixed substrate and inserts new ones.
  Future<void> replaceCompositions(
    int mixedId,
    Map<int, int> percentages,
  ) async {
    await (delete(
      substrateCompositions,
    )..where((t) => t.mixedSubstrateId.equals(mixedId))).go();
    for (final entry in percentages.entries) {
      if (entry.value > 0) {
        await addComposition(mixedId, entry.key, entry.value);
      }
    }
  }
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

@DriftAccessor(
  tables: [
    Environments,
    EnvironmentSources,
    EnvironmentOvipositionSites,
    EnvironmentAgents,
  ],
)
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

  Future<int> placeSource(EnvironmentSourcesCompanion entry) =>
      into(environmentSources).insert(entry);

  Future<List<EnvironmentSource>> getSources(int envId) => (select(
    environmentSources,
  )..where((t) => t.environmentId.equals(envId))).get();

  Future<int> placeOvipositionSite(
    EnvironmentOvipositionSitesCompanion entry,
  ) => into(environmentOvipositionSites).insert(entry);

  Future<List<EnvironmentOvipositionSite>> getOvipositionSites(int envId) =>
      (select(
        environmentOvipositionSites,
      )..where((t) => t.environmentId.equals(envId))).get();

  Future<int> placeAgent(EnvironmentAgentsCompanion entry) =>
      into(environmentAgents).insert(entry);

  Future<List<EnvironmentAgent>> getAgents(int envId) => (select(
    environmentAgents,
  )..where((t) => t.environmentId.equals(envId))).get();
}
