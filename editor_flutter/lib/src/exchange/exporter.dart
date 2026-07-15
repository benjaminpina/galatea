import 'dart:convert';
import 'dart:io';

import '../database/database.dart';
import '../database/daos.dart';
import 'models.dart';

/// Exports simulation components from the database to JSON files.
class JsonExporter {
  final AppDatabase db;

  JsonExporter(this.db);

  /// Export all substrates to a JSON file.
  Future<void> exportSubstrates(String filePath) async {
    final dao = SubstrateDao(db);
    final substrates = await dao.getAll();

    final exports = <SubstrateExport>[];
    final compositions = <MixedCompositionExport>[];

    for (final sub in substrates) {
      exports.add(SubstrateExport(
        name: sub.name,
        color: sub.color,
        isMixed: sub.isMixed,
        sortOrder: sub.sortOrder,
      ));

      if (sub.isMixed) {
        final comps = await dao.getCompositions(sub.id);
        for (final comp in comps) {
          final simple = substrates.where((s) => s.id == comp.simpleSubstrateId).firstOrNull;
          if (simple != null) {
            compositions.add(MixedCompositionExport(
              mixedName: sub.name,
              simpleName: simple.name,
              percentage: comp.percentage,
            ));
          }
        }
      }
    }

    final export = SubstrateSetExport(substrates: exports, compositions: compositions);
    await _writeJson(filePath, export.toJson());
  }

  /// Export all loci to a JSON file.
  Future<void> exportLoci(String filePath) async {
    final dao = LocusDao(db);
    final loci = await dao.getAll();

    final exports = loci
        .map((l) => LocusExport(
              name: l.name,
              isContinuous: l.isContinuous,
              dominantValue: l.dominantValue,
              recessiveValue: l.recessiveValue,
              mutationRateDom: l.mutationRateDom,
              mutationRateRec: l.mutationRateRec,
              mutationRangeDom: l.mutationRangeDom,
              mutationRangeRec: l.mutationRangeRec,
              defaultExpression: l.defaultExpression,
              sortOrder: l.sortOrder,
            ))
        .toList();

    final export = LociSetExport(loci: exports);
    await _writeJson(filePath, export.toJson());
  }

  /// Export all prototypes to a JSON file.
  Future<void> exportPrototypes(String filePath) async {
    final dao = PrototypeDao(db);
    final prototypes = await dao.getAll();

    final exports = prototypes
        .map((p) => PrototypeExport(
              name: p.name,
              sex: p.sex,
              color: p.color,
              longevityFormula: p.longevityFormula,
              refractoryCombatFormula: p.refractoryCombatFormula,
              refractoryCourtshipFormula: p.refractoryCourtshipFormula,
              sexRatioMalesFormula: p.sexRatioMalesFormula,
              sexRatioFemalesFormula: p.sexRatioFemalesFormula,
              sortOrder: p.sortOrder,
            ))
        .toList();

    final export = PrototypeSetExport(prototypes: exports);
    await _writeJson(filePath, export.toJson());
  }

  Future<void> _writeJson(String filePath, Map<String, dynamic> data) async {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    await File(filePath).writeAsString(jsonStr);
  }
}
