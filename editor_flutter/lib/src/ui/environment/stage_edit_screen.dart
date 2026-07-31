import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../formula/formula_field.dart';

/// Dedicated edit screen for a single life stage.
/// Sections: General (cycles, conditions, logic, color, linked prototype),
/// Nutrient Requirements, Movement Tendencies.
class StageEditScreen extends ConsumerStatefulWidget {
  const StageEditScreen({super.key, required this.stageId});
  final int stageId;

  @override
  ConsumerState<StageEditScreen> createState() => _StageEditScreenState();
}

class _StageEditScreenState extends ConsumerState<StageEditScreen> {
  Stage? _stage;

  // General fields.
  final _nameCtrl = TextEditingController();
  final _cyclesCtrl = TextEditingController();
  final _cond1FormulaCtrl = TextEditingController();
  final _cond1OpCtrl = TextEditingController();
  final _cond1ValueCtrl = TextEditingController();
  final _cond2FormulaCtrl = TextEditingController();
  final _cond2OpCtrl = TextEditingController();
  final _cond2ValueCtrl = TextEditingController();
  String _logicCyclesReqs = 'AND';
  String _logicReqsConds = 'AND';
  String _logicCond1Cond2 = 'AND';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cyclesCtrl.dispose();
    _cond1FormulaCtrl.dispose();
    _cond1OpCtrl.dispose();
    _cond1ValueCtrl.dispose();
    _cond2FormulaCtrl.dispose();
    _cond2OpCtrl.dispose();
    _cond2ValueCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    final stage = await (db.select(
      db.stages,
    )..where((t) => t.id.equals(widget.stageId))).getSingleOrNull();
    if (stage == null) return;
    setState(() {
      _stage = stage;
      _nameCtrl.text = stage.name;
      _cyclesCtrl.text = stage.cyclesFormula;
      _cond1FormulaCtrl.text = stage.condition1Formula;
      _cond1OpCtrl.text = stage.condition1Op;
      _cond1ValueCtrl.text = stage.condition1Value.toString();
      _cond2FormulaCtrl.text = stage.condition2Formula;
      _cond2OpCtrl.text = stage.condition2Op;
      _cond2ValueCtrl.text = stage.condition2Value.toString();
      _logicCyclesReqs = stage.logicCyclesReqs;
      _logicReqsConds = stage.logicReqsConds;
      _logicCond1Cond2 = stage.logicCond1Cond2;
    });
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await (db.update(
      db.stages,
    )..where((t) => t.id.equals(widget.stageId))).write(
      StagesCompanion(
        name: Value(_nameCtrl.text.trim()),
        cyclesFormula: Value(_cyclesCtrl.text.trim()),
        condition1Formula: Value(_cond1FormulaCtrl.text.trim()),
        condition1Op: Value(_cond1OpCtrl.text.trim()),
        condition1Value: Value(
          double.tryParse(_cond1ValueCtrl.text.trim()) ?? 0,
        ),
        condition2Formula: Value(_cond2FormulaCtrl.text.trim()),
        condition2Op: Value(_cond2OpCtrl.text.trim()),
        condition2Value: Value(
          double.tryParse(_cond2ValueCtrl.text.trim()) ?? 0,
        ),
        logicCyclesReqs: Value(_logicCyclesReqs),
        logicReqsConds: Value(_logicReqsConds),
        logicCond1Cond2: Value(_logicCond1Cond2),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stage saved'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Stage: ${_stage!.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- General ---
          Text('General', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          FormulaField(
            label: 'Duration cycles',
            title: '${_nameCtrl.text} — Duration Cycles',
            value: _cyclesCtrl.text,
            onChanged: (v) => setState(() => _cyclesCtrl.text = v),
          ),
          const SizedBox(height: 24),

          // --- Transition conditions ---
          Text(
            'Transition Conditions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text('Condition 1:', style: Theme.of(context).textTheme.labelLarge),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cond1FormulaCtrl,
                  decoration: const InputDecoration(labelText: 'Formula'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _cond1OpCtrl,
                  decoration: const InputDecoration(labelText: 'Op'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _cond1ValueCtrl,
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Condition 2:', style: Theme.of(context).textTheme.labelLarge),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cond2FormulaCtrl,
                  decoration: const InputDecoration(labelText: 'Formula'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _cond2OpCtrl,
                  decoration: const InputDecoration(labelText: 'Op'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _cond2ValueCtrl,
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Logic operators.
          Row(
            children: [
              const Text('Cycles ↔ Reqs: '),
              _LogicToggle(
                value: _logicCyclesReqs,
                onChanged: (v) => setState(() => _logicCyclesReqs = v),
              ),
              const SizedBox(width: 16),
              const Text('Reqs ↔ Conds: '),
              _LogicToggle(
                value: _logicReqsConds,
                onChanged: (v) => setState(() => _logicReqsConds = v),
              ),
              const SizedBox(width: 16),
              const Text('C1 ↔ C2: '),
              _LogicToggle(
                value: _logicCond1Cond2,
                onChanged: (v) => setState(() => _logicCond1Cond2 = v),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Nutrient Requirements ---
          Text(
            'Nutrient Requirements & Costs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _NutrientRequirementsSection(stageId: widget.stageId),
          const SizedBox(height: 24),

          // --- Movement Tendencies ---
          Text(
            'Movement Tendencies',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _TendenciesSection(stageId: widget.stageId),
        ],
      ),
    );
  }
}

// --- Logic toggle ---

class _LogicToggle extends StatelessWidget {
  const _LogicToggle({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'AND', label: Text('AND')),
        ButtonSegment(value: 'OR', label: Text('OR')),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// --- Nutrient requirements per stage ---

class _NutrientRequirementsSection extends ConsumerWidget {
  const _NutrientRequirementsSection({required this.stageId});
  final int stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);
    if (db == null || nutrients.isEmpty) {
      return const Text(
        'Define nutrients first.',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    return FutureBuilder<List<StageNutrientRequirement>>(
      future: (db.select(
        db.stageNutrientRequirements,
      )..where((t) => t.stageId.equals(stageId))).get(),
      builder: (context, snapshot) {
        final reqMap = <int, StageNutrientRequirement>{};
        for (final r in snapshot.data ?? []) {
          reqMap[r.nutrientId] = r;
        }
        return Column(
          children: nutrients.map((n) {
            final req = reqMap[n.id];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(n.name, style: const TextStyle(fontSize: 12)),
                  ),
                  Expanded(
                    child: FormulaField(
                      label: 'Requirement',
                      title: '${n.name} — Requirement',
                      value: req?.requirementFormula ?? '0',
                      onChanged: (v) => _save(db, n.id, requirement: v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FormulaField(
                      label: 'Cost',
                      title: '${n.name} — Cost',
                      value: req?.costFormula ?? '0',
                      onChanged: (v) => _save(db, n.id, cost: v),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _save(
    AppDatabase db,
    int nutrientId, {
    String? requirement,
    String? cost,
  }) async {
    final existing =
        await (db.select(db.stageNutrientRequirements)..where(
              (t) =>
                  t.stageId.equals(stageId) & t.nutrientId.equals(nutrientId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.stageNutrientRequirements)
          .insert(
            StageNutrientRequirementsCompanion.insert(
              stageId: stageId,
              nutrientId: nutrientId,
              requirementFormula: Value(requirement ?? '0'),
              costFormula: Value(cost ?? '0'),
            ),
          );
    } else {
      await (db.update(
        db.stageNutrientRequirements,
      )..where((t) => t.id.equals(existing.id))).write(
        StageNutrientRequirementsCompanion(
          requirementFormula: requirement != null
              ? Value(requirement)
              : const Value.absent(),
          costFormula: cost != null ? Value(cost) : const Value.absent(),
        ),
      );
    }
  }
}

// --- Movement tendencies per stage ---

class _TendenciesSection extends ConsumerWidget {
  const _TendenciesSection({required this.stageId});
  final int stageId;

  static const _dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();

    return FutureBuilder<List<StageTendency>>(
      future:
          (db.select(db.stageTendencies)
                ..where((t) => t.stageId.equals(stageId))
                ..orderBy([(t) => OrderingTerm.asc(t.direction)]))
              .get(),
      builder: (context, snapshot) {
        final tendMap = <int, String>{};
        for (final t in snapshot.data ?? []) {
          tendMap[t.direction] = t.formula;
        }
        return Column(
          children: List.generate(8, (i) {
            final dir = i + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      _dirs[i],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FormulaField(
                      label: _dirs[i],
                      title: 'Tendency ${_dirs[i]}',
                      value: tendMap[dir] ?? '1',
                      onChanged: (v) => _save(db, dir, v),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _save(AppDatabase db, int direction, String formula) async {
    final existing =
        await (db.select(db.stageTendencies)..where(
              (t) => t.stageId.equals(stageId) & t.direction.equals(direction),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.stageTendencies)
          .insert(
            StageTendenciesCompanion.insert(
              stageId: stageId,
              direction: direction,
              formula: Value(formula),
            ),
          );
    } else {
      await (db.update(db.stageTendencies)
            ..where((t) => t.id.equals(existing.id)))
          .write(StageTendenciesCompanion(formula: Value(formula)));
    }
  }
}

// --- Small formula field ---

class _SmallField extends StatefulWidget {
  const _SmallField({
    required this.label,
    required this.initial,
    required this.onSubmitted,
  });
  final String label;
  final String initial;
  final ValueChanged<String> onSubmitted;

  @override
  State<_SmallField> createState() => _SmallFieldState();
}

class _SmallFieldState extends State<_SmallField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      style: const TextStyle(fontSize: 11),
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.label.isNotEmpty ? widget.label : null,
        labelStyle: const TextStyle(fontSize: 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}
