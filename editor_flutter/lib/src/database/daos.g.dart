// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$ProjectInfoDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProjectInfoTable get projectInfo => attachedDatabase.projectInfo;
  ProjectInfoDaoManager get managers => ProjectInfoDaoManager(this);
}

class ProjectInfoDaoManager {
  final _$ProjectInfoDaoMixin _db;
  ProjectInfoDaoManager(this._db);
  $$ProjectInfoTableTableManager get projectInfo =>
      $$ProjectInfoTableTableManager(_db.attachedDatabase, _db.projectInfo);
}

mixin _$NutrientDaoMixin on DatabaseAccessor<AppDatabase> {
  $NutrientsTable get nutrients => attachedDatabase.nutrients;
  NutrientDaoManager get managers => NutrientDaoManager(this);
}

class NutrientDaoManager {
  final _$NutrientDaoMixin _db;
  NutrientDaoManager(this._db);
  $$NutrientsTableTableManager get nutrients =>
      $$NutrientsTableTableManager(_db.attachedDatabase, _db.nutrients);
}

mixin _$SubstrateDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubstratesTable get substrates => attachedDatabase.substrates;
  $SubstrateCompositionsTable get substrateCompositions =>
      attachedDatabase.substrateCompositions;
  SubstrateDaoManager get managers => SubstrateDaoManager(this);
}

class SubstrateDaoManager {
  final _$SubstrateDaoMixin _db;
  SubstrateDaoManager(this._db);
  $$SubstratesTableTableManager get substrates =>
      $$SubstratesTableTableManager(_db.attachedDatabase, _db.substrates);
  $$SubstrateCompositionsTableTableManager get substrateCompositions =>
      $$SubstrateCompositionsTableTableManager(
        _db.attachedDatabase,
        _db.substrateCompositions,
      );
}

mixin _$LocusDaoMixin on DatabaseAccessor<AppDatabase> {
  $LociTable get loci => attachedDatabase.loci;
  LocusDaoManager get managers => LocusDaoManager(this);
}

class LocusDaoManager {
  final _$LocusDaoMixin _db;
  LocusDaoManager(this._db);
  $$LociTableTableManager get loci =>
      $$LociTableTableManager(_db.attachedDatabase, _db.loci);
}

mixin _$StageDaoMixin on DatabaseAccessor<AppDatabase> {
  $StagesTable get stages => attachedDatabase.stages;
  StageDaoManager get managers => StageDaoManager(this);
}

class StageDaoManager {
  final _$StageDaoMixin _db;
  StageDaoManager(this._db);
  $$StagesTableTableManager get stages =>
      $$StagesTableTableManager(_db.attachedDatabase, _db.stages);
}

mixin _$PrototypeDaoMixin on DatabaseAccessor<AppDatabase> {
  $PrototypesTable get prototypes => attachedDatabase.prototypes;
  PrototypeDaoManager get managers => PrototypeDaoManager(this);
}

class PrototypeDaoManager {
  final _$PrototypeDaoMixin _db;
  PrototypeDaoManager(this._db);
  $$PrototypesTableTableManager get prototypes =>
      $$PrototypesTableTableManager(_db.attachedDatabase, _db.prototypes);
}

mixin _$ResourceTypeDaoMixin on DatabaseAccessor<AppDatabase> {
  $NutrientsTable get nutrients => attachedDatabase.nutrients;
  $ResourceTypesTable get resourceTypes => attachedDatabase.resourceTypes;
  ResourceTypeDaoManager get managers => ResourceTypeDaoManager(this);
}

class ResourceTypeDaoManager {
  final _$ResourceTypeDaoMixin _db;
  ResourceTypeDaoManager(this._db);
  $$NutrientsTableTableManager get nutrients =>
      $$NutrientsTableTableManager(_db.attachedDatabase, _db.nutrients);
  $$ResourceTypesTableTableManager get resourceTypes =>
      $$ResourceTypesTableTableManager(_db.attachedDatabase, _db.resourceTypes);
}

mixin _$EnvironmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $EnvironmentsTable get environments => attachedDatabase.environments;
  $NutrientsTable get nutrients => attachedDatabase.nutrients;
  $ResourceTypesTable get resourceTypes => attachedDatabase.resourceTypes;
  $EnvironmentResourcesTable get environmentResources =>
      attachedDatabase.environmentResources;
  $StagesTable get stages => attachedDatabase.stages;
  $PrototypesTable get prototypes => attachedDatabase.prototypes;
  $EnvironmentAgentsTable get environmentAgents =>
      attachedDatabase.environmentAgents;
  EnvironmentDaoManager get managers => EnvironmentDaoManager(this);
}

class EnvironmentDaoManager {
  final _$EnvironmentDaoMixin _db;
  EnvironmentDaoManager(this._db);
  $$EnvironmentsTableTableManager get environments =>
      $$EnvironmentsTableTableManager(_db.attachedDatabase, _db.environments);
  $$NutrientsTableTableManager get nutrients =>
      $$NutrientsTableTableManager(_db.attachedDatabase, _db.nutrients);
  $$ResourceTypesTableTableManager get resourceTypes =>
      $$ResourceTypesTableTableManager(_db.attachedDatabase, _db.resourceTypes);
  $$EnvironmentResourcesTableTableManager get environmentResources =>
      $$EnvironmentResourcesTableTableManager(
        _db.attachedDatabase,
        _db.environmentResources,
      );
  $$StagesTableTableManager get stages =>
      $$StagesTableTableManager(_db.attachedDatabase, _db.stages);
  $$PrototypesTableTableManager get prototypes =>
      $$PrototypesTableTableManager(_db.attachedDatabase, _db.prototypes);
  $$EnvironmentAgentsTableTableManager get environmentAgents =>
      $$EnvironmentAgentsTableTableManager(
        _db.attachedDatabase,
        _db.environmentAgents,
      );
}
