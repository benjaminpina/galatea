/// JSON exchange models for sharing simulation components between projects.
/// All models include a schema_version field for forward compatibility.
library;

const int currentSchemaVersion = 1;

/// Exported substrate set (simple + mixed).
class SubstrateSetExport {
  final int schemaVersion;
  final List<SubstrateExport> substrates;
  final List<MixedCompositionExport> compositions;

  SubstrateSetExport({
    this.schemaVersion = currentSchemaVersion,
    required this.substrates,
    this.compositions = const [],
  });

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'type': 'substrate_set',
        'substrates': substrates.map((s) => s.toJson()).toList(),
        'compositions': compositions.map((c) => c.toJson()).toList(),
      };

  factory SubstrateSetExport.fromJson(Map<String, dynamic> json) {
    return SubstrateSetExport(
      schemaVersion: json['schema_version'] as int? ?? 1,
      substrates: (json['substrates'] as List)
          .map((s) => SubstrateExport.fromJson(s as Map<String, dynamic>))
          .toList(),
      compositions: (json['compositions'] as List?)
              ?.map((c) => MixedCompositionExport.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SubstrateExport {
  final String name;
  final int color;
  final bool isMixed;
  final int sortOrder;

  SubstrateExport({required this.name, required this.color, this.isMixed = false, this.sortOrder = 0});

  Map<String, dynamic> toJson() => {'name': name, 'color': color, 'is_mixed': isMixed, 'sort_order': sortOrder};

  factory SubstrateExport.fromJson(Map<String, dynamic> json) => SubstrateExport(
        name: json['name'] as String,
        color: json['color'] as int,
        isMixed: json['is_mixed'] as bool? ?? false,
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}

class MixedCompositionExport {
  final String mixedName;
  final String simpleName;
  final int percentage;

  MixedCompositionExport({required this.mixedName, required this.simpleName, required this.percentage});

  Map<String, dynamic> toJson() => {'mixed_name': mixedName, 'simple_name': simpleName, 'percentage': percentage};

  factory MixedCompositionExport.fromJson(Map<String, dynamic> json) => MixedCompositionExport(
        mixedName: json['mixed_name'] as String,
        simpleName: json['simple_name'] as String,
        percentage: json['percentage'] as int,
      );
}

/// Exported loci set.
class LociSetExport {
  final int schemaVersion;
  final List<LocusExport> loci;

  LociSetExport({this.schemaVersion = currentSchemaVersion, required this.loci});

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'type': 'loci_set',
        'loci': loci.map((l) => l.toJson()).toList(),
      };

  factory LociSetExport.fromJson(Map<String, dynamic> json) => LociSetExport(
        schemaVersion: json['schema_version'] as int? ?? 1,
        loci: (json['loci'] as List).map((l) => LocusExport.fromJson(l as Map<String, dynamic>)).toList(),
      );
}

class LocusExport {
  final String name;
  final bool isContinuous;
  final double dominantValue;
  final double recessiveValue;
  final double mutationRateDom;
  final double mutationRateRec;
  final double mutationRangeDom;
  final double mutationRangeRec;
  final String defaultExpression;
  final int sortOrder;

  LocusExport({
    required this.name,
    this.isContinuous = true,
    this.dominantValue = 1.0,
    this.recessiveValue = 0.5,
    this.mutationRateDom = 0.01,
    this.mutationRateRec = 0.01,
    this.mutationRangeDom = 0.1,
    this.mutationRangeRec = 0.1,
    this.defaultExpression = '0',
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'is_continuous': isContinuous,
        'dominant_value': dominantValue,
        'recessive_value': recessiveValue,
        'mutation_rate_dom': mutationRateDom,
        'mutation_rate_rec': mutationRateRec,
        'mutation_range_dom': mutationRangeDom,
        'mutation_range_rec': mutationRangeRec,
        'default_expression': defaultExpression,
        'sort_order': sortOrder,
      };

  factory LocusExport.fromJson(Map<String, dynamic> json) => LocusExport(
        name: json['name'] as String,
        isContinuous: json['is_continuous'] as bool? ?? true,
        dominantValue: (json['dominant_value'] as num?)?.toDouble() ?? 1.0,
        recessiveValue: (json['recessive_value'] as num?)?.toDouble() ?? 0.5,
        mutationRateDom: (json['mutation_rate_dom'] as num?)?.toDouble() ?? 0.01,
        mutationRateRec: (json['mutation_rate_rec'] as num?)?.toDouble() ?? 0.01,
        mutationRangeDom: (json['mutation_range_dom'] as num?)?.toDouble() ?? 0.1,
        mutationRangeRec: (json['mutation_range_rec'] as num?)?.toDouble() ?? 0.1,
        defaultExpression: json['default_expression'] as String? ?? '0',
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}

/// Exported prototype set.
class PrototypeSetExport {
  final int schemaVersion;
  final List<PrototypeExport> prototypes;

  PrototypeSetExport({this.schemaVersion = currentSchemaVersion, required this.prototypes});

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'type': 'prototype_set',
        'prototypes': prototypes.map((p) => p.toJson()).toList(),
      };

  factory PrototypeSetExport.fromJson(Map<String, dynamic> json) => PrototypeSetExport(
        schemaVersion: json['schema_version'] as int? ?? 1,
        prototypes:
            (json['prototypes'] as List).map((p) => PrototypeExport.fromJson(p as Map<String, dynamic>)).toList(),
      );
}

class PrototypeExport {
  final String name;
  final String sex;
  final int color;
  final String longevityFormula;
  final String refractoryCombatFormula;
  final String refractoryCourtshipFormula;
  final String sexRatioMalesFormula;
  final String sexRatioFemalesFormula;
  final int sortOrder;

  PrototypeExport({
    required this.name,
    required this.sex,
    this.color = 0,
    this.longevityFormula = '1000',
    this.refractoryCombatFormula = '10',
    this.refractoryCourtshipFormula = '10',
    this.sexRatioMalesFormula = '50',
    this.sexRatioFemalesFormula = '50',
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sex': sex,
        'color': color,
        'longevity_formula': longevityFormula,
        'refractory_combat_formula': refractoryCombatFormula,
        'refractory_courtship_formula': refractoryCourtshipFormula,
        'sex_ratio_males_formula': sexRatioMalesFormula,
        'sex_ratio_females_formula': sexRatioFemalesFormula,
        'sort_order': sortOrder,
      };

  factory PrototypeExport.fromJson(Map<String, dynamic> json) => PrototypeExport(
        name: json['name'] as String,
        sex: json['sex'] as String,
        color: json['color'] as int? ?? 0,
        longevityFormula: json['longevity_formula'] as String? ?? '1000',
        refractoryCombatFormula: json['refractory_combat_formula'] as String? ?? '10',
        refractoryCourtshipFormula: json['refractory_courtship_formula'] as String? ?? '10',
        sexRatioMalesFormula: json['sex_ratio_males_formula'] as String? ?? '50',
        sexRatioFemalesFormula: json['sex_ratio_females_formula'] as String? ?? '50',
        sortOrder: json['sort_order'] as int? ?? 0,
      );
}
