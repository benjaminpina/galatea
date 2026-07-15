import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../database/database.dart';
import '../database/daos.dart';
import 'models.dart';

/// Import result with counts of what was imported.
class ImportResult {
  final int imported;
  final int skipped;
  final List<String> errors;

  ImportResult({this.imported = 0, this.skipped = 0, this.errors = const []});

  @override
  String toString() => 'Imported: $imported, Skipped: $skipped'
      '${errors.isNotEmpty ? ", Errors: ${errors.join(", ")}" : ""}';
}

/// Imports simulation components from JSON files into the database.
/// Name conflicts are resolved by skipping duplicates.
class JsonImporter {
  final AppDatabase db;

  JsonImporter(this.db);

  /// Import substrates from a JSON file.
  Future<ImportResult> importSubstrates(String filePath) async {
    final json = await _readJson(filePath);
    if (json['type'] != 'substrate_set') {
      return ImportResult(errors: ['Invalid file type: expected substrate_set']);
    }

    final data = SubstrateSetExport.fromJson(json);
    final dao = SubstrateDao(db);
    final existing = await dao.getAll();
    final existingNames = existing.map((s) => s.name).toSet();

    var imported = 0;
    var skipped = 0;

    for (final sub in data.substrates) {
      if (existingNames.contains(sub.name)) {
        skipped++;
        continue;
      }
      await dao.add(sub.name, sub.color, sub.isMixed, sub.sortOrder);
      imported++;
    }

    // Import compositions (resolve by name).
    if (data.compositions.isNotEmpty) {
      final allSubs = await dao.getAll();
      final nameToId = {for (final s in allSubs) s.name: s.id};

      for (final comp in data.compositions) {
        final mixedId = nameToId[comp.mixedName];
        final simpleId = nameToId[comp.simpleName];
        if (mixedId != null && simpleId != null) {
          await dao.addComposition(mixedId, simpleId, comp.percentage);
        }
      }
    }

    return ImportResult(imported: imported, skipped: skipped);
  }

  /// Import loci from a JSON file.
  Future<ImportResult> importLoci(String filePath) async {
    final json = await _readJson(filePath);
    if (json['type'] != 'loci_set') {
      return ImportResult(errors: ['Invalid file type: expected loci_set']);
    }

    final data = LociSetExport.fromJson(json);
    final dao = LocusDao(db);
    final existing = await dao.getAll();
    final existingNames = existing.map((l) => l.name).toSet();

    var imported = 0;
    var skipped = 0;

    for (final locus in data.loci) {
      if (existingNames.contains(locus.name)) {
        skipped++;
        continue;
      }
      await dao.add(LociCompanion.insert(
        name: locus.name,
        isContinuous: Value(locus.isContinuous),
        dominantValue: Value(locus.dominantValue),
        recessiveValue: Value(locus.recessiveValue),
        mutationRateDom: Value(locus.mutationRateDom),
        mutationRateRec: Value(locus.mutationRateRec),
        mutationRangeDom: Value(locus.mutationRangeDom),
        mutationRangeRec: Value(locus.mutationRangeRec),
        defaultExpression: Value(locus.defaultExpression),
        sortOrder: Value(locus.sortOrder),
      ));
      imported++;
    }

    return ImportResult(imported: imported, skipped: skipped);
  }

  /// Import prototypes from a JSON file.
  Future<ImportResult> importPrototypes(String filePath) async {
    final json = await _readJson(filePath);
    if (json['type'] != 'prototype_set') {
      return ImportResult(errors: ['Invalid file type: expected prototype_set']);
    }

    final data = PrototypeSetExport.fromJson(json);
    final dao = PrototypeDao(db);
    final existing = await dao.getAll();
    final existingNames = existing.map((p) => p.name).toSet();

    var imported = 0;
    var skipped = 0;

    for (final proto in data.prototypes) {
      if (existingNames.contains(proto.name)) {
        skipped++;
        continue;
      }
      await dao.add(PrototypesCompanion.insert(
        name: proto.name,
        sex: proto.sex,
        color: Value(proto.color),
        longevityFormula: Value(proto.longevityFormula),
        refractoryCombatFormula: Value(proto.refractoryCombatFormula),
        refractoryCourtshipFormula: Value(proto.refractoryCourtshipFormula),
        sexRatioMalesFormula: Value(proto.sexRatioMalesFormula),
        sexRatioFemalesFormula: Value(proto.sexRatioFemalesFormula),
        sortOrder: Value(proto.sortOrder),
      ));
      imported++;
    }

    return ImportResult(imported: imported, skipped: skipped);
  }

  Future<Map<String, dynamic>> _readJson(String filePath) async {
    final content = await File(filePath).readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }
}
