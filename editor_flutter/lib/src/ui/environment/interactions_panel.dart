import 'package:drift/drift.dart' hide Column, Table;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../formula/formula_field.dart';

/// Right panel for the "Interactions" config section.
/// Editors for the 6 interaction matrices + memory influence:
///   1. InteractionSubstrates (perceiver × substrate × behavior → formula)
///   2. AttractivenessSubstrates (perceiver × substrate → attractiveness + radius)
///   3. InteractionSources (perceiver × nutrient source × behavior → formula)
///   4. AttractivenessSources (perceiver × nutrient source → attractiveness + radius)
///   5. InteractionAgents (perceiver × observed agent × behavior → formula)
///   6. AttractivenessAgents (perceiver × observed agent → attractiveness + radius)
///   7. MemoryInfluence (perceiver × memoryType × element → formula)
class InteractionsPanel extends ConsumerWidget {
  const InteractionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Interaction Matrices',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Define how prototypes/stages perceive and respond to '
          'substrates, nutrient sources, and other agents.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        const _InteractionSubstratesEditor(),
        const Divider(height: 32),
        const _AttractivenessSubstratesEditor(),
        const Divider(height: 32),
        const _InteractionSourcesEditor(),
        const Divider(height: 32),
        const _AttractivenessSourcesEditor(),
        const Divider(height: 32),
        const _InteractionAgentsEditor(),
        const Divider(height: 32),
        const _AttractivenessAgentsEditor(),
        const Divider(height: 32),
        const _MemoryInfluenceEditor(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// =============================================================================
// HELPERS
// =============================================================================

/// Human-readable behavior labels indexed by behaviorIndex.
const _behaviorLabels = [
  'Ignore', // 0
  'Approach', // 1
  'Avoid', // 2
  'Attack', // 3
  'Court', // 4
  'Feed', // 5
];

String _behaviorLabel(int index) {
  if (index >= 0 && index < _behaviorLabels.length) {
    return _behaviorLabels[index];
  }
  return 'Behavior $index';
}

/// Builds a perceiver label from nullable stage/prototype IDs.
String _perceiverLabel(
  int? stageId,
  int? prototypeId,
  List<Stage> stages,
  List<Prototype> prototypes,
) {
  final parts = <String>[];
  if (prototypeId != null) {
    final p = prototypes.where((p) => p.id == prototypeId).firstOrNull;
    parts.add(p?.name ?? 'Proto#$prototypeId');
  }
  if (stageId != null) {
    final s = stages.where((s) => s.id == stageId).firstOrNull;
    parts.add(s?.name ?? 'Stage#$stageId');
  }
  if (parts.isEmpty) return 'Any (default)';
  return parts.join(' / ');
}

/// A dropdown for selecting a perceiver (prototype + stage combo, or "Any").
class _PerceiverSelector extends StatelessWidget {
  const _PerceiverSelector({
    required this.stages,
    required this.prototypes,
    required this.selectedStageId,
    required this.selectedPrototypeId,
    required this.onChanged,
  });

  final List<Stage> stages;
  final List<Prototype> prototypes;
  final int? selectedStageId;
  final int? selectedPrototypeId;
  final void Function(int? stageId, int? prototypeId) onChanged;

  @override
  Widget build(BuildContext context) {
    // Build a list of unique perceiver combos.
    final options = <({int? stageId, int? protoId})>[
      (stageId: null, protoId: null), // Default / any
    ];
    for (final p in prototypes) {
      options.add((stageId: null, protoId: p.id));
    }
    for (final s in stages) {
      options.add((stageId: s.id, protoId: null));
    }
    // Prototype × stage combos.
    for (final p in prototypes) {
      for (final s in stages) {
        options.add((stageId: s.id, protoId: p.id));
      }
    }

    final currentKey = (stageId: selectedStageId, protoId: selectedPrototypeId);

    return DropdownButton<({int? stageId, int? protoId})>(
      value: options.contains(currentKey) ? currentKey : options.first,
      isExpanded: true,
      isDense: true,
      style: const TextStyle(fontSize: 11),
      items: options.map((opt) {
        return DropdownMenuItem(
          value: opt,
          child: Text(
            _perceiverLabel(opt.stageId, opt.protoId, stages, prototypes),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          onChanged(val.stageId, val.protoId);
        }
      },
    );
  }
}

// =============================================================================
// 1. INTERACTION SUBSTRATES
// =============================================================================

class _InteractionSubstratesEditor extends ConsumerStatefulWidget {
  const _InteractionSubstratesEditor();

  @override
  ConsumerState<_InteractionSubstratesEditor> createState() =>
      _InteractionSubstratesEditorState();
}

class _InteractionSubstratesEditorState
    extends ConsumerState<_InteractionSubstratesEditor> {
  int? _filterStageId;
  int? _filterPrototypeId;

  @override
  Widget build(BuildContext context) {
    final substrates = ref.watch(substratesProvider).valueOrNull ?? [];
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);

    if (db == null || substrates.isEmpty) {
      return _sectionShell(
        'Substrate Interactions',
        Icons.terrain,
        child: const Text(
          'Define substrates first.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    return _sectionShell(
      'Substrate Interactions',
      Icons.terrain,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perceiver:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _filterStageId,
            selectedPrototypeId: _filterPrototypeId,
            onChanged: (s, p) => setState(() {
              _filterStageId = s;
              _filterPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          _InteractionSubstrateGrid(
            db: db,
            substrates: substrates,
            perceiverStageId: _filterStageId,
            perceiverPrototypeId: _filterPrototypeId,
          ),
        ],
      ),
    );
  }
}

class _InteractionSubstrateGrid extends StatefulWidget {
  const _InteractionSubstrateGrid({
    required this.db,
    required this.substrates,
    required this.perceiverStageId,
    required this.perceiverPrototypeId,
  });

  final AppDatabase db;
  final List<Substrate> substrates;
  final int? perceiverStageId;
  final int? perceiverPrototypeId;

  @override
  State<_InteractionSubstrateGrid> createState() =>
      _InteractionSubstrateGridState();
}

class _InteractionSubstrateGridState extends State<_InteractionSubstrateGrid> {
  Map<String, String> _values = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _InteractionSubstrateGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perceiverStageId != widget.perceiverStageId ||
        oldWidget.perceiverPrototypeId != widget.perceiverPrototypeId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    var query = widget.db.select(widget.db.interactionSubstrates)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final rows = await query.get();
    final map = <String, String>{};
    for (final row in rows) {
      map['${row.substrateId}.${row.behaviorIndex}'] = row.formula;
    }
    if (mounted) {
      setState(() {
        _values = map;
        _loading = false;
      });
    }
  }

  Future<void> _save(int substrateId, int behaviorIndex, String formula) async {
    // Upsert
    var query = widget.db.select(widget.db.interactionSubstrates)
      ..where((t) {
        Expression<bool> cond =
            t.substrateId.equals(substrateId) &
            t.behaviorIndex.equals(behaviorIndex);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      await widget.db
          .into(widget.db.interactionSubstrates)
          .insert(
            InteractionSubstratesCompanion.insert(
              substrateId: substrateId,
              perceiverStageId: Value(widget.perceiverStageId),
              perceiverPrototypeId: Value(widget.perceiverPrototypeId),
              behaviorIndex: behaviorIndex,
              formula: Value(formula),
            ),
          );
    } else {
      await (widget.db.update(widget.db.interactionSubstrates)
            ..where((t) => t.id.equals(existing.id)))
          .write(InteractionSubstratesCompanion(formula: Value(formula)));
    }
    setState(() => _values['$substrateId.$behaviorIndex'] = formula);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();

    return Table(
      columnWidths: const {0: FixedColumnWidth(70)},
      defaultColumnWidth: const FlexColumnWidth(),
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 0.5,
      ),
      children: [
        // Header row
        TableRow(
          children: [
            _headerCell('Substrate'),
            for (var b = 0; b < _behaviorLabels.length; b++)
              _headerCell(_behaviorLabel(b)),
          ],
        ),
        // Data rows
        ...widget.substrates.map((sub) {
          return TableRow(
            children: [
              _labelCell(sub.name),
              for (var b = 0; b < _behaviorLabels.length; b++)
                _formulaCell(
                  _values['${sub.id}.$b'] ?? '0',
                  (v) => _save(sub.id, b, v),
                  '${sub.name} — ${_behaviorLabel(b)}',
                ),
            ],
          );
        }),
      ],
    );
  }
}

// =============================================================================
// 2. ATTRACTIVENESS SUBSTRATES
// =============================================================================

class _AttractivenessSubstratesEditor extends ConsumerStatefulWidget {
  const _AttractivenessSubstratesEditor();

  @override
  ConsumerState<_AttractivenessSubstratesEditor> createState() =>
      _AttractivenessSubstratesEditorState();
}

class _AttractivenessSubstratesEditorState
    extends ConsumerState<_AttractivenessSubstratesEditor> {
  int? _filterStageId;
  int? _filterPrototypeId;

  @override
  Widget build(BuildContext context) {
    final substrates = ref.watch(substratesProvider).valueOrNull ?? [];
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);

    if (db == null || substrates.isEmpty) {
      return _sectionShell(
        'Substrate Attractiveness',
        Icons.auto_awesome,
        child: const Text(
          'Define substrates first.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    return _sectionShell(
      'Substrate Attractiveness',
      Icons.auto_awesome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perceiver:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _filterStageId,
            selectedPrototypeId: _filterPrototypeId,
            onChanged: (s, p) => setState(() {
              _filterStageId = s;
              _filterPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          _AttractivenessSubstrateGrid(
            db: db,
            substrates: substrates,
            perceiverStageId: _filterStageId,
            perceiverPrototypeId: _filterPrototypeId,
          ),
        ],
      ),
    );
  }
}

class _AttractivenessSubstrateGrid extends StatefulWidget {
  const _AttractivenessSubstrateGrid({
    required this.db,
    required this.substrates,
    required this.perceiverStageId,
    required this.perceiverPrototypeId,
  });

  final AppDatabase db;
  final List<Substrate> substrates;
  final int? perceiverStageId;
  final int? perceiverPrototypeId;

  @override
  State<_AttractivenessSubstrateGrid> createState() =>
      _AttractivenessSubstrateGridState();
}

class _AttractivenessSubstrateGridState
    extends State<_AttractivenessSubstrateGrid> {
  Map<int, (String attractiveness, String radius)> _values = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AttractivenessSubstrateGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perceiverStageId != widget.perceiverStageId ||
        oldWidget.perceiverPrototypeId != widget.perceiverPrototypeId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    var query = widget.db.select(widget.db.attractivenessSubstrates)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final rows = await query.get();
    final map = <int, (String, String)>{};
    for (final row in rows) {
      map[row.substrateId] = (row.attractivenessFormula, row.radiusFormula);
    }
    if (mounted) {
      setState(() {
        _values = map;
        _loading = false;
      });
    }
  }

  Future<void> _save(
    int substrateId, {
    String? attractiveness,
    String? radius,
  }) async {
    var query = widget.db.select(widget.db.attractivenessSubstrates)
      ..where((t) {
        Expression<bool> cond = t.substrateId.equals(substrateId);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      await widget.db
          .into(widget.db.attractivenessSubstrates)
          .insert(
            AttractivenessSubstratesCompanion.insert(
              substrateId: substrateId,
              perceiverStageId: Value(widget.perceiverStageId),
              perceiverPrototypeId: Value(widget.perceiverPrototypeId),
              attractivenessFormula: Value(attractiveness ?? '0'),
              radiusFormula: Value(radius ?? '5'),
            ),
          );
    } else {
      final companion = AttractivenessSubstratesCompanion(
        attractivenessFormula: attractiveness != null
            ? Value(attractiveness)
            : const Value.absent(),
        radiusFormula: radius != null ? Value(radius) : const Value.absent(),
      );
      await (widget.db.update(
        widget.db.attractivenessSubstrates,
      )..where((t) => t.id.equals(existing.id))).write(companion);
    }
    final prev = _values[substrateId] ?? ('0', '5');
    setState(() {
      _values[substrateId] = (attractiveness ?? prev.$1, radius ?? prev.$2);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(70),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 0.5,
      ),
      children: [
        TableRow(
          children: [
            _headerCell('Substrate'),
            _headerCell('Attractiveness'),
            _headerCell('Radius'),
          ],
        ),
        ...widget.substrates.map((sub) {
          final vals = _values[sub.id] ?? ('0', '5');
          return TableRow(
            children: [
              _labelCell(sub.name),
              _formulaCell(
                vals.$1,
                (v) => _save(sub.id, attractiveness: v),
                '${sub.name} — Attractiveness',
              ),
              _formulaCell(
                vals.$2,
                (v) => _save(sub.id, radius: v),
                '${sub.name} — Perception Radius',
              ),
            ],
          );
        }),
      ],
    );
  }
}

// =============================================================================
// 3. INTERACTION SOURCES
// =============================================================================

class _InteractionSourcesEditor extends ConsumerStatefulWidget {
  const _InteractionSourcesEditor();

  @override
  ConsumerState<_InteractionSourcesEditor> createState() =>
      _InteractionSourcesEditorState();
}

class _InteractionSourcesEditorState
    extends ConsumerState<_InteractionSourcesEditor> {
  int? _filterStageId;
  int? _filterPrototypeId;

  @override
  Widget build(BuildContext context) {
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);

    if (db == null || nutrients.isEmpty) {
      return _sectionShell(
        'Source Interactions',
        Icons.water_drop,
        child: const Text(
          'Define nutrients first.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    return _sectionShell(
      'Source Interactions',
      Icons.water_drop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perceiver:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _filterStageId,
            selectedPrototypeId: _filterPrototypeId,
            onChanged: (s, p) => setState(() {
              _filterStageId = s;
              _filterPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          _InteractionSourceGrid(
            db: db,
            nutrients: nutrients,
            perceiverStageId: _filterStageId,
            perceiverPrototypeId: _filterPrototypeId,
          ),
        ],
      ),
    );
  }
}

class _InteractionSourceGrid extends StatefulWidget {
  const _InteractionSourceGrid({
    required this.db,
    required this.nutrients,
    required this.perceiverStageId,
    required this.perceiverPrototypeId,
  });

  final AppDatabase db;
  final List<Nutrient> nutrients;
  final int? perceiverStageId;
  final int? perceiverPrototypeId;

  @override
  State<_InteractionSourceGrid> createState() => _InteractionSourceGridState();
}

class _InteractionSourceGridState extends State<_InteractionSourceGrid> {
  Map<String, String> _values = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _InteractionSourceGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perceiverStageId != widget.perceiverStageId ||
        oldWidget.perceiverPrototypeId != widget.perceiverPrototypeId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    var query = widget.db.select(widget.db.interactionSources)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final rows = await query.get();
    final map = <String, String>{};
    for (final row in rows) {
      map['${row.nutrientId}.${row.behaviorIndex}'] = row.formula;
    }
    if (mounted) {
      setState(() {
        _values = map;
        _loading = false;
      });
    }
  }

  Future<void> _save(int nutrientId, int behaviorIndex, String formula) async {
    var query = widget.db.select(widget.db.interactionSources)
      ..where((t) {
        Expression<bool> cond =
            t.nutrientId.equals(nutrientId) &
            t.behaviorIndex.equals(behaviorIndex);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      await widget.db
          .into(widget.db.interactionSources)
          .insert(
            InteractionSourcesCompanion.insert(
              nutrientId: nutrientId,
              perceiverStageId: Value(widget.perceiverStageId),
              perceiverPrototypeId: Value(widget.perceiverPrototypeId),
              behaviorIndex: behaviorIndex,
              formula: Value(formula),
            ),
          );
    } else {
      await (widget.db.update(widget.db.interactionSources)
            ..where((t) => t.id.equals(existing.id)))
          .write(InteractionSourcesCompanion(formula: Value(formula)));
    }
    setState(() => _values['$nutrientId.$behaviorIndex'] = formula);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();

    return Table(
      columnWidths: const {0: FixedColumnWidth(70)},
      defaultColumnWidth: const FlexColumnWidth(),
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 0.5,
      ),
      children: [
        TableRow(
          children: [
            _headerCell('Source'),
            for (var b = 0; b < _behaviorLabels.length; b++)
              _headerCell(_behaviorLabel(b)),
          ],
        ),
        ...widget.nutrients.map((nut) {
          return TableRow(
            children: [
              _labelCell(nut.name),
              for (var b = 0; b < _behaviorLabels.length; b++)
                _formulaCell(
                  _values['${nut.id}.$b'] ?? '0',
                  (v) => _save(nut.id, b, v),
                  '${nut.name} — ${_behaviorLabel(b)}',
                ),
            ],
          );
        }),
      ],
    );
  }
}

// =============================================================================
// 4. ATTRACTIVENESS SOURCES
// =============================================================================

class _AttractivenessSourcesEditor extends ConsumerStatefulWidget {
  const _AttractivenessSourcesEditor();

  @override
  ConsumerState<_AttractivenessSourcesEditor> createState() =>
      _AttractivenessSourcesEditorState();
}

class _AttractivenessSourcesEditorState
    extends ConsumerState<_AttractivenessSourcesEditor> {
  int? _filterStageId;
  int? _filterPrototypeId;

  @override
  Widget build(BuildContext context) {
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);

    if (db == null || nutrients.isEmpty) {
      return _sectionShell(
        'Source Attractiveness',
        Icons.auto_awesome,
        child: const Text(
          'Define nutrients first.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    return _sectionShell(
      'Source Attractiveness',
      Icons.auto_awesome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perceiver:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _filterStageId,
            selectedPrototypeId: _filterPrototypeId,
            onChanged: (s, p) => setState(() {
              _filterStageId = s;
              _filterPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          _AttractivenessSourceGrid(
            db: db,
            nutrients: nutrients,
            perceiverStageId: _filterStageId,
            perceiverPrototypeId: _filterPrototypeId,
          ),
        ],
      ),
    );
  }
}

class _AttractivenessSourceGrid extends StatefulWidget {
  const _AttractivenessSourceGrid({
    required this.db,
    required this.nutrients,
    required this.perceiverStageId,
    required this.perceiverPrototypeId,
  });

  final AppDatabase db;
  final List<Nutrient> nutrients;
  final int? perceiverStageId;
  final int? perceiverPrototypeId;

  @override
  State<_AttractivenessSourceGrid> createState() =>
      _AttractivenessSourceGridState();
}

class _AttractivenessSourceGridState extends State<_AttractivenessSourceGrid> {
  Map<int, (String attractiveness, String radius)> _values = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AttractivenessSourceGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perceiverStageId != widget.perceiverStageId ||
        oldWidget.perceiverPrototypeId != widget.perceiverPrototypeId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    var query = widget.db.select(widget.db.attractivenessSources)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final rows = await query.get();
    final map = <int, (String, String)>{};
    for (final row in rows) {
      map[row.nutrientId] = (row.attractivenessFormula, row.radiusFormula);
    }
    if (mounted) {
      setState(() {
        _values = map;
        _loading = false;
      });
    }
  }

  Future<void> _save(
    int nutrientId, {
    String? attractiveness,
    String? radius,
  }) async {
    var query = widget.db.select(widget.db.attractivenessSources)
      ..where((t) {
        Expression<bool> cond = t.nutrientId.equals(nutrientId);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      await widget.db
          .into(widget.db.attractivenessSources)
          .insert(
            AttractivenessSourcesCompanion.insert(
              nutrientId: nutrientId,
              perceiverStageId: Value(widget.perceiverStageId),
              perceiverPrototypeId: Value(widget.perceiverPrototypeId),
              attractivenessFormula: Value(attractiveness ?? '0'),
              radiusFormula: Value(radius ?? '5'),
            ),
          );
    } else {
      final companion = AttractivenessSourcesCompanion(
        attractivenessFormula: attractiveness != null
            ? Value(attractiveness)
            : const Value.absent(),
        radiusFormula: radius != null ? Value(radius) : const Value.absent(),
      );
      await (widget.db.update(
        widget.db.attractivenessSources,
      )..where((t) => t.id.equals(existing.id))).write(companion);
    }
    final prev = _values[nutrientId] ?? ('0', '5');
    setState(() {
      _values[nutrientId] = (attractiveness ?? prev.$1, radius ?? prev.$2);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(70),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 0.5,
      ),
      children: [
        TableRow(
          children: [
            _headerCell('Source'),
            _headerCell('Attractiveness'),
            _headerCell('Radius'),
          ],
        ),
        ...widget.nutrients.map((nut) {
          final vals = _values[nut.id] ?? ('0', '5');
          return TableRow(
            children: [
              _labelCell(nut.name),
              _formulaCell(
                vals.$1,
                (v) => _save(nut.id, attractiveness: v),
                '${nut.name} — Attractiveness',
              ),
              _formulaCell(
                vals.$2,
                (v) => _save(nut.id, radius: v),
                '${nut.name} — Perception Radius',
              ),
            ],
          );
        }),
      ],
    );
  }
}

// =============================================================================
// 5. INTERACTION AGENTS
// =============================================================================

class _InteractionAgentsEditor extends ConsumerStatefulWidget {
  const _InteractionAgentsEditor();

  @override
  ConsumerState<_InteractionAgentsEditor> createState() =>
      _InteractionAgentsEditorState();
}

class _InteractionAgentsEditorState
    extends ConsumerState<_InteractionAgentsEditor> {
  int? _perceiverStageId;
  int? _perceiverPrototypeId;
  int? _observedStageId;
  int? _observedPrototypeId;

  @override
  Widget build(BuildContext context) {
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);

    if (db == null || prototypes.isEmpty) {
      return _sectionShell(
        'Agent Interactions',
        Icons.people,
        child: const Text(
          'Define prototypes first.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    return _sectionShell(
      'Agent Interactions',
      Icons.people,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perceiver:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _perceiverStageId,
            selectedPrototypeId: _perceiverPrototypeId,
            onChanged: (s, p) => setState(() {
              _perceiverStageId = s;
              _perceiverPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          const Text(
            'Observed:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _observedStageId,
            selectedPrototypeId: _observedPrototypeId,
            onChanged: (s, p) => setState(() {
              _observedStageId = s;
              _observedPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          _InteractionAgentGrid(
            db: db,
            perceiverStageId: _perceiverStageId,
            perceiverPrototypeId: _perceiverPrototypeId,
            observedStageId: _observedStageId,
            observedPrototypeId: _observedPrototypeId,
          ),
        ],
      ),
    );
  }
}

class _InteractionAgentGrid extends StatefulWidget {
  const _InteractionAgentGrid({
    required this.db,
    required this.perceiverStageId,
    required this.perceiverPrototypeId,
    required this.observedStageId,
    required this.observedPrototypeId,
  });

  final AppDatabase db;
  final int? perceiverStageId;
  final int? perceiverPrototypeId;
  final int? observedStageId;
  final int? observedPrototypeId;

  @override
  State<_InteractionAgentGrid> createState() => _InteractionAgentGridState();
}

class _InteractionAgentGridState extends State<_InteractionAgentGrid> {
  Map<int, String> _values = {}; // behaviorIndex → formula
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _InteractionAgentGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perceiverStageId != widget.perceiverStageId ||
        oldWidget.perceiverPrototypeId != widget.perceiverPrototypeId ||
        oldWidget.observedStageId != widget.observedStageId ||
        oldWidget.observedPrototypeId != widget.observedPrototypeId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    var query = widget.db.select(widget.db.interactionAgents)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        if (widget.observedStageId != null) {
          cond = cond & t.observedStageId.equals(widget.observedStageId!);
        } else {
          cond = cond & t.observedStageId.isNull();
        }
        if (widget.observedPrototypeId != null) {
          cond =
              cond & t.observedPrototypeId.equals(widget.observedPrototypeId!);
        } else {
          cond = cond & t.observedPrototypeId.isNull();
        }
        return cond;
      });
    final rows = await query.get();
    final map = <int, String>{};
    for (final row in rows) {
      map[row.behaviorIndex] = row.formula;
    }
    if (mounted) {
      setState(() {
        _values = map;
        _loading = false;
      });
    }
  }

  Future<void> _save(int behaviorIndex, String formula) async {
    var query = widget.db.select(widget.db.interactionAgents)
      ..where((t) {
        Expression<bool> cond = t.behaviorIndex.equals(behaviorIndex);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        if (widget.observedStageId != null) {
          cond = cond & t.observedStageId.equals(widget.observedStageId!);
        } else {
          cond = cond & t.observedStageId.isNull();
        }
        if (widget.observedPrototypeId != null) {
          cond =
              cond & t.observedPrototypeId.equals(widget.observedPrototypeId!);
        } else {
          cond = cond & t.observedPrototypeId.isNull();
        }
        return cond;
      });
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      await widget.db
          .into(widget.db.interactionAgents)
          .insert(
            InteractionAgentsCompanion.insert(
              observedStageId: Value(widget.observedStageId),
              observedPrototypeId: Value(widget.observedPrototypeId),
              perceiverStageId: Value(widget.perceiverStageId),
              perceiverPrototypeId: Value(widget.perceiverPrototypeId),
              behaviorIndex: behaviorIndex,
              formula: Value(formula),
            ),
          );
    } else {
      await (widget.db.update(widget.db.interactionAgents)
            ..where((t) => t.id.equals(existing.id)))
          .write(InteractionAgentsCompanion(formula: Value(formula)));
    }
    setState(() => _values[behaviorIndex] = formula);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var b = 0; b < _behaviorLabels.length; b++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    _behaviorLabel(b),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                Expanded(
                  child: FormulaField(
                    label: _behaviorLabel(b),
                    title: 'Agent interaction — ${_behaviorLabel(b)}',
                    value: _values[b] ?? '0',
                    onChanged: (v) => _save(b, v),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// 6. ATTRACTIVENESS AGENTS
// =============================================================================

class _AttractivenessAgentsEditor extends ConsumerStatefulWidget {
  const _AttractivenessAgentsEditor();

  @override
  ConsumerState<_AttractivenessAgentsEditor> createState() =>
      _AttractivenessAgentsEditorState();
}

class _AttractivenessAgentsEditorState
    extends ConsumerState<_AttractivenessAgentsEditor> {
  int? _perceiverStageId;
  int? _perceiverPrototypeId;
  int? _observedStageId;
  int? _observedPrototypeId;

  @override
  Widget build(BuildContext context) {
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);

    if (db == null || prototypes.isEmpty) {
      return _sectionShell(
        'Agent Attractiveness',
        Icons.favorite,
        child: const Text(
          'Define prototypes first.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    return _sectionShell(
      'Agent Attractiveness',
      Icons.favorite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perceiver:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _perceiverStageId,
            selectedPrototypeId: _perceiverPrototypeId,
            onChanged: (s, p) => setState(() {
              _perceiverStageId = s;
              _perceiverPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          const Text(
            'Observed:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _observedStageId,
            selectedPrototypeId: _observedPrototypeId,
            onChanged: (s, p) => setState(() {
              _observedStageId = s;
              _observedPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          _AttractivenessAgentGrid(
            db: db,
            perceiverStageId: _perceiverStageId,
            perceiverPrototypeId: _perceiverPrototypeId,
            observedStageId: _observedStageId,
            observedPrototypeId: _observedPrototypeId,
          ),
        ],
      ),
    );
  }
}

class _AttractivenessAgentGrid extends StatefulWidget {
  const _AttractivenessAgentGrid({
    required this.db,
    required this.perceiverStageId,
    required this.perceiverPrototypeId,
    required this.observedStageId,
    required this.observedPrototypeId,
  });

  final AppDatabase db;
  final int? perceiverStageId;
  final int? perceiverPrototypeId;
  final int? observedStageId;
  final int? observedPrototypeId;

  @override
  State<_AttractivenessAgentGrid> createState() =>
      _AttractivenessAgentGridState();
}

class _AttractivenessAgentGridState extends State<_AttractivenessAgentGrid> {
  String _attractiveness = '0';
  String _radius = '5';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AttractivenessAgentGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perceiverStageId != widget.perceiverStageId ||
        oldWidget.perceiverPrototypeId != widget.perceiverPrototypeId ||
        oldWidget.observedStageId != widget.observedStageId ||
        oldWidget.observedPrototypeId != widget.observedPrototypeId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    var query = widget.db.select(widget.db.attractivenessAgents)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        if (widget.observedStageId != null) {
          cond = cond & t.observedStageId.equals(widget.observedStageId!);
        } else {
          cond = cond & t.observedStageId.isNull();
        }
        if (widget.observedPrototypeId != null) {
          cond =
              cond & t.observedPrototypeId.equals(widget.observedPrototypeId!);
        } else {
          cond = cond & t.observedPrototypeId.isNull();
        }
        return cond;
      });
    final existing = await query.getSingleOrNull();
    if (mounted) {
      setState(() {
        _attractiveness = existing?.attractivenessFormula ?? '0';
        _radius = existing?.radiusFormula ?? '5';
        _loading = false;
      });
    }
  }

  Future<void> _save({String? attractiveness, String? radius}) async {
    var query = widget.db.select(widget.db.attractivenessAgents)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        if (widget.observedStageId != null) {
          cond = cond & t.observedStageId.equals(widget.observedStageId!);
        } else {
          cond = cond & t.observedStageId.isNull();
        }
        if (widget.observedPrototypeId != null) {
          cond =
              cond & t.observedPrototypeId.equals(widget.observedPrototypeId!);
        } else {
          cond = cond & t.observedPrototypeId.isNull();
        }
        return cond;
      });
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      await widget.db
          .into(widget.db.attractivenessAgents)
          .insert(
            AttractivenessAgentsCompanion.insert(
              observedStageId: Value(widget.observedStageId),
              observedPrototypeId: Value(widget.observedPrototypeId),
              perceiverStageId: Value(widget.perceiverStageId),
              perceiverPrototypeId: Value(widget.perceiverPrototypeId),
              attractivenessFormula: Value(attractiveness ?? '0'),
              radiusFormula: Value(radius ?? '5'),
            ),
          );
    } else {
      final companion = AttractivenessAgentsCompanion(
        attractivenessFormula: attractiveness != null
            ? Value(attractiveness)
            : const Value.absent(),
        radiusFormula: radius != null ? Value(radius) : const Value.absent(),
      );
      await (widget.db.update(
        widget.db.attractivenessAgents,
      )..where((t) => t.id.equals(existing.id))).write(companion);
    }
    setState(() {
      if (attractiveness != null) _attractiveness = attractiveness;
      if (radius != null) _radius = radius;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: FormulaField(
            label: 'Attractiveness',
            title: 'Agent attractiveness formula',
            value: _attractiveness,
            onChanged: (v) => _save(attractiveness: v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: FormulaField(
            label: 'Perception Radius',
            title: 'Agent perception radius formula',
            value: _radius,
            onChanged: (v) => _save(radius: v),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 7. MEMORY INFLUENCE
// =============================================================================

class _MemoryInfluenceEditor extends ConsumerStatefulWidget {
  const _MemoryInfluenceEditor();

  @override
  ConsumerState<_MemoryInfluenceEditor> createState() =>
      _MemoryInfluenceEditorState();
}

class _MemoryInfluenceEditorState
    extends ConsumerState<_MemoryInfluenceEditor> {
  int? _filterStageId;
  int? _filterPrototypeId;

  static const _memoryTypes = [
    'last_perception',
    'num_interactions',
    'last_outcome',
  ];

  static const _maxElementIndex = 4;

  @override
  Widget build(BuildContext context) {
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);

    if (db == null) {
      return _sectionShell(
        'Memory Influence',
        Icons.memory,
        child: const Text(
          'Open a project first.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      );
    }

    return _sectionShell(
      'Memory Influence',
      Icons.memory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perceiver:',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          _PerceiverSelector(
            stages: stages,
            prototypes: prototypes,
            selectedStageId: _filterStageId,
            selectedPrototypeId: _filterPrototypeId,
            onChanged: (s, p) => setState(() {
              _filterStageId = s;
              _filterPrototypeId = p;
            }),
          ),
          const SizedBox(height: 8),
          _MemoryInfluenceGrid(
            db: db,
            memoryTypes: _memoryTypes,
            maxElementIndex: _maxElementIndex,
            perceiverStageId: _filterStageId,
            perceiverPrototypeId: _filterPrototypeId,
          ),
        ],
      ),
    );
  }
}

class _MemoryInfluenceGrid extends StatefulWidget {
  const _MemoryInfluenceGrid({
    required this.db,
    required this.memoryTypes,
    required this.maxElementIndex,
    required this.perceiverStageId,
    required this.perceiverPrototypeId,
  });

  final AppDatabase db;
  final List<String> memoryTypes;
  final int maxElementIndex;
  final int? perceiverStageId;
  final int? perceiverPrototypeId;

  @override
  State<_MemoryInfluenceGrid> createState() => _MemoryInfluenceGridState();
}

class _MemoryInfluenceGridState extends State<_MemoryInfluenceGrid> {
  Map<String, String> _values = {}; // 'memType.elemIdx' → formula
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _MemoryInfluenceGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perceiverStageId != widget.perceiverStageId ||
        oldWidget.perceiverPrototypeId != widget.perceiverPrototypeId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    var query = widget.db.select(widget.db.memoryInfluence)
      ..where((t) {
        Expression<bool> cond = const Constant(true);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final rows = await query.get();
    final map = <String, String>{};
    for (final row in rows) {
      map['${row.memoryType}.${row.elementIndex}'] = row.formula;
    }
    if (mounted) {
      setState(() {
        _values = map;
        _loading = false;
      });
    }
  }

  Future<void> _save(
    String memoryType,
    int elementIndex,
    String formula,
  ) async {
    var query = widget.db.select(widget.db.memoryInfluence)
      ..where((t) {
        Expression<bool> cond =
            t.memoryType.equals(memoryType) &
            t.elementIndex.equals(elementIndex);
        if (widget.perceiverStageId != null) {
          cond = cond & t.perceiverStageId.equals(widget.perceiverStageId!);
        } else {
          cond = cond & t.perceiverStageId.isNull();
        }
        if (widget.perceiverPrototypeId != null) {
          cond =
              cond &
              t.perceiverPrototypeId.equals(widget.perceiverPrototypeId!);
        } else {
          cond = cond & t.perceiverPrototypeId.isNull();
        }
        return cond;
      });
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      await widget.db
          .into(widget.db.memoryInfluence)
          .insert(
            MemoryInfluenceCompanion.insert(
              memoryType: memoryType,
              elementIndex: elementIndex,
              perceiverStageId: Value(widget.perceiverStageId),
              perceiverPrototypeId: Value(widget.perceiverPrototypeId),
              formula: Value(formula),
            ),
          );
    } else {
      await (widget.db.update(widget.db.memoryInfluence)
            ..where((t) => t.id.equals(existing.id)))
          .write(MemoryInfluenceCompanion(formula: Value(formula)));
    }
    setState(() => _values['$memoryType.$elementIndex'] = formula);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();

    return Table(
      columnWidths: const {0: FixedColumnWidth(90)},
      defaultColumnWidth: const FlexColumnWidth(),
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 0.5,
      ),
      children: [
        TableRow(
          children: [
            _headerCell('Memory Type'),
            for (var i = 0; i < widget.maxElementIndex; i++)
              _headerCell('Elem $i'),
          ],
        ),
        ...widget.memoryTypes.map((mt) {
          return TableRow(
            children: [
              _labelCell(mt.replaceAll('_', ' ')),
              for (var i = 0; i < widget.maxElementIndex; i++)
                _formulaCell(
                  _values['$mt.$i'] ?? '0',
                  (v) => _save(mt, i, v),
                  '${mt.replaceAll('_', ' ')} [$i]',
                ),
            ],
          );
        }),
      ],
    );
  }
}

// =============================================================================
// SHARED UI WIDGETS
// =============================================================================

Widget _sectionShell(String title, IconData icon, {required Widget child}) {
  return Builder(
    builder: (context) {
      return ExpansionTile(
        leading: Icon(icon, size: 18),
        title: Text(title, style: const TextStyle(fontSize: 12)),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
        initiallyExpanded: false,
        children: [child],
      );
    },
  );
}

Widget _headerCell(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _labelCell(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 10),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget _formulaCell(
  String value,
  ValueChanged<String> onChanged,
  String title,
) {
  return Padding(
    padding: const EdgeInsets.all(2),
    child: FormulaField(value: value, onChanged: onChanged, title: title),
  );
}
