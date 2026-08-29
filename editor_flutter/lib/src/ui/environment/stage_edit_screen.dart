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
  String _cond1Formula = '0';
  final _cond1OpCtrl = TextEditingController();
  final _cond1ValueCtrl = TextEditingController();
  String _cond2Formula = '0';
  final _cond2OpCtrl = TextEditingController();
  final _cond2ValueCtrl = TextEditingController();
  String _logicCyclesReqs = 'AND';
  String _logicReqsConds = 'AND';
  String _logicCond1Cond2 = 'AND';
  int _color = 0;
  int? _linkedPrototypeId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cyclesCtrl.dispose();
    _cond1OpCtrl.dispose();
    _cond1ValueCtrl.dispose();
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
      _cond1Formula = stage.condition1Formula;
      _cond1OpCtrl.text = stage.condition1Op;
      _cond1ValueCtrl.text = stage.condition1Value.toString();
      _cond2Formula = stage.condition2Formula;
      _cond2OpCtrl.text = stage.condition2Op;
      _cond2ValueCtrl.text = stage.condition2Value.toString();
      _logicCyclesReqs = stage.logicCyclesReqs;
      _logicReqsConds = stage.logicReqsConds;
      _logicCond1Cond2 = stage.logicCond1Cond2;
      _color = stage.color;
      _linkedPrototypeId = stage.linkedPrototypeId;
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
        condition1Formula: Value(_cond1Formula),
        condition1Op: Value(_cond1OpCtrl.text.trim()),
        condition1Value: Value(
          double.tryParse(_cond1ValueCtrl.text.trim()) ?? 0,
        ),
        condition2Formula: Value(_cond2Formula),
        condition2Op: Value(_cond2OpCtrl.text.trim()),
        condition2Value: Value(
          double.tryParse(_cond2ValueCtrl.text.trim()) ?? 0,
        ),
        logicCyclesReqs: Value(_logicCyclesReqs),
        logicReqsConds: Value(_logicReqsConds),
        logicCond1Cond2: Value(_logicCond1Cond2),
        color: Value(_color),
        linkedPrototypeId: Value(_linkedPrototypeId),
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

  Future<void> _pickColor() async {
    final controller = TextEditingController(
      text: _color != 0
          ? (_color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')
          : '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stage Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Hex color (RRGGBB)',
                prefixText: '#',
              ),
              maxLength: 6,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, val, _) {
                final parsed = int.tryParse(val.text, radix: 16);
                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: parsed != null
                        ? Color(parsed | 0xFF000000)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text, radix: 16);
              Navigator.pop(ctx, parsed ?? 0);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => _color = result);
    }
  }

  Widget _buildLinkedPrototypeDropdown() {
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    return DropdownButtonFormField<int?>(
      initialValue: prototypes.any((p) => p.id == _linkedPrototypeId)
          ? _linkedPrototypeId
          : null,
      isDense: true,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Linked Prototype (on eclosion)',
        helperText: 'Prototype assigned when agent exits this stage',
        helperMaxLines: 2,
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('None')),
        ...prototypes.map(
          (p) => DropdownMenuItem(
            value: p.id,
            child: Text('${p.name} (${p.sex})'),
          ),
        ),
      ],
      onChanged: (v) => setState(() => _linkedPrototypeId = v),
    );
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
          const SizedBox(height: 12),

          // Color picker
          Row(
            children: [
              const Text('Color:', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _pickColor,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _color != 0
                        ? Color(_color | 0xFF000000)
                        : Colors.grey.shade400,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _color != 0
                    ? '#${(_color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}'
                    : 'None',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linked prototype dropdown
          _buildLinkedPrototypeDropdown(),
          const SizedBox(height: 24),

          // --- Transition conditions ---
          Text(
            'Transition Conditions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text('Condition 1:', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: FormulaField(
                  label: 'Formula',
                  title: 'Condition 1 formula',
                  value: _cond1Formula,
                  onChanged: (v) => setState(() => _cond1Formula = v),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: DropdownButtonFormField<String>(
                  initialValue: _cond1OpCtrl.text.isEmpty
                      ? '>'
                      : _cond1OpCtrl.text,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Op',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '>', child: Text('>')),
                    DropdownMenuItem(value: '>=', child: Text('>=')),
                    DropdownMenuItem(value: '<', child: Text('<')),
                    DropdownMenuItem(value: '<=', child: Text('<=')),
                    DropdownMenuItem(value: '==', child: Text('==')),
                    DropdownMenuItem(value: '!=', child: Text('!=')),
                  ],
                  onChanged: (v) {
                    if (v != null) _cond1OpCtrl.text = v;
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _cond1ValueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Condition 2:', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: FormulaField(
                  label: 'Formula',
                  title: 'Condition 2 formula',
                  value: _cond2Formula,
                  onChanged: (v) => setState(() => _cond2Formula = v),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: DropdownButtonFormField<String>(
                  initialValue: _cond2OpCtrl.text.isEmpty
                      ? '>'
                      : _cond2OpCtrl.text,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Op',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '>', child: Text('>')),
                    DropdownMenuItem(value: '>=', child: Text('>=')),
                    DropdownMenuItem(value: '<', child: Text('<')),
                    DropdownMenuItem(value: '<=', child: Text('<=')),
                    DropdownMenuItem(value: '==', child: Text('==')),
                    DropdownMenuItem(value: '!=', child: Text('!=')),
                  ],
                  onChanged: (v) {
                    if (v != null) _cond2OpCtrl.text = v;
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _cond2ValueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
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

class _NutrientRequirementsSection extends ConsumerStatefulWidget {
  const _NutrientRequirementsSection({required this.stageId});
  final int stageId;

  @override
  ConsumerState<_NutrientRequirementsSection> createState() =>
      _NutrientRequirementsSectionState();
}

class _NutrientRequirementsSectionState
    extends ConsumerState<_NutrientRequirementsSection> {
  // nutrientId → (requirement, cost)
  final Map<int, (String, String)> _values = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    if (db == null) {
      setState(() => _loaded = true);
      return;
    }
    final rows = await (db.select(
      db.stageNutrientRequirements,
    )..where((t) => t.stageId.equals(widget.stageId))).get();
    for (final r in rows) {
      _values[r.nutrientId] = (r.requirementFormula, r.costFormula);
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);
    if (db == null || nutrients.isEmpty) {
      return const Text(
        'Define nutrients first.',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
    if (!_loaded) return const LinearProgressIndicator();

    return Column(
      children: nutrients.map((n) {
        final vals = _values[n.id] ?? ('0', '0');
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
                  value: vals.$1,
                  onChanged: (v) => _save(db, n.id, requirement: v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FormulaField(
                  label: 'Cost',
                  title: '${n.name} — Cost',
                  value: vals.$2,
                  onChanged: (v) => _save(db, n.id, cost: v),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
                  t.stageId.equals(widget.stageId) &
                  t.nutrientId.equals(nutrientId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.stageNutrientRequirements)
          .insert(
            StageNutrientRequirementsCompanion.insert(
              stageId: widget.stageId,
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
    // Update local state so the UI reflects the change immediately.
    final prev = _values[nutrientId] ?? ('0', '0');
    setState(() {
      _values[nutrientId] = (requirement ?? prev.$1, cost ?? prev.$2);
    });
  }
}

// --- Movement tendencies per stage ---

class _TendenciesSection extends ConsumerStatefulWidget {
  const _TendenciesSection({required this.stageId});
  final int stageId;

  @override
  ConsumerState<_TendenciesSection> createState() => _TendenciesSectionState();
}

class _TendenciesSectionState extends ConsumerState<_TendenciesSection> {
  // Directions are RELATIVE to the agent's heading, in the engine's order
  // (index d = direction-1): [NW, N, NE, W, E, SW, S, SE].
  // Labels describe the relative turn: forward, diagonals, sides, back.
  static const _dirs = [
    '↖ Fwd-L',
    '↑ Forward',
    '↗ Fwd-R',
    '← Left',
    '→ Right',
    '↙ Back-L',
    '↓ Back',
    '↘ Back-R',
  ];

  // Legacy default weights (relative movement): strong forward bias,
  // occasional gentle turns, rare 90° turns, almost never backward.
  // Order matches _dirs: [NW, N, NE, W, E, SW, S, SE].
  static const _defaults = ['25', '50', '25', '10', '10', '1', '1', '1'];

  final Map<int, String> _values = {}; // direction → formula
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    if (db == null) {
      setState(() => _loaded = true);
      return;
    }
    final rows =
        await (db.select(db.stageTendencies)
              ..where((t) => t.stageId.equals(widget.stageId))
              ..orderBy([(t) => OrderingTerm.asc(t.direction)]))
            .get();
    for (final t in rows) {
      _values[t.direction] = t.formula;
    }
    // Seed defaults for any missing directions so they persist to the DB.
    for (var i = 0; i < 8; i++) {
      final dir = i + 1;
      if (!_values.containsKey(dir)) {
        await db
            .into(db.stageTendencies)
            .insert(
              StageTendenciesCompanion.insert(
                stageId: widget.stageId,
                direction: dir,
                formula: Value(_defaults[i]),
              ),
            );
        _values[dir] = _defaults[i];
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();
    if (!_loaded) return const LinearProgressIndicator();

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
                  value: _values[dir] ?? _defaults[i],
                  onChanged: (v) => _save(db, dir, v),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _save(AppDatabase db, int direction, String formula) async {
    final existing =
        await (db.select(db.stageTendencies)..where(
              (t) =>
                  t.stageId.equals(widget.stageId) &
                  t.direction.equals(direction),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.stageTendencies)
          .insert(
            StageTendenciesCompanion.insert(
              stageId: widget.stageId,
              direction: direction,
              formula: Value(formula),
            ),
          );
    } else {
      await (db.update(db.stageTendencies)
            ..where((t) => t.id.equals(existing.id)))
          .write(StageTendenciesCompanion(formula: Value(formula)));
    }
    setState(() => _values[direction] = formula);
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
