import 'package:drift/drift.dart' hide Column, Table;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../formula/formula_field.dart';
import '../substrates/substrate_list_screen.dart';

/// Dedicated edit screen for a single prototype.
/// Tabs: General, Morphology, Fighting, Courtship, Movement.
class PrototypeEditScreen extends ConsumerStatefulWidget {
  const PrototypeEditScreen({super.key, required this.prototypeId});
  final int prototypeId;

  @override
  ConsumerState<PrototypeEditScreen> createState() =>
      _PrototypeEditScreenState();
}

class _PrototypeEditScreenState extends ConsumerState<PrototypeEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  Prototype? _prototype;

  // General fields.
  final _nameCtrl = TextEditingController();
  final _longevityCtrl = TextEditingController();
  final _refCombatCtrl = TextEditingController();
  final _refCourtshipCtrl = TextEditingController();
  final _ratioMalesCtrl = TextEditingController();
  final _ratioFemalesCtrl = TextEditingController();
  int _color = 0;

  // Movement tendencies cache: direction → formula.
  final Map<int, String> _tendencyValues = {};
  bool _tendenciesLoaded = false;

  // Legacy default weights (relative movement), order = direction 1..8:
  // [Fwd-L, Forward, Fwd-R, Left, Right, Back-L, Back, Back-R].
  static const _tendencyDefaults = [
    '25',
    '50',
    '25',
    '10',
    '10',
    '1',
    '1',
    '1',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _longevityCtrl.dispose();
    _refCombatCtrl.dispose();
    _refCourtshipCtrl.dispose();
    _ratioMalesCtrl.dispose();
    _ratioFemalesCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    final proto = await (db.select(
      db.prototypes,
    )..where((t) => t.id.equals(widget.prototypeId))).getSingleOrNull();
    if (proto == null) return;
    setState(() {
      _prototype = proto;
      _nameCtrl.text = proto.name;
      _longevityCtrl.text = proto.longevityFormula;
      _refCombatCtrl.text = proto.refractoryCombatFormula;
      _refCourtshipCtrl.text = proto.refractoryCourtshipFormula;
      _ratioMalesCtrl.text = proto.sexRatioMalesFormula;
      _ratioFemalesCtrl.text = proto.sexRatioFemalesFormula;
      _color = proto.color;
    });
    // Load movement tendencies into local cache.
    final tendencies = await (db.select(
      db.prototypeTendencies,
    )..where((t) => t.prototypeId.equals(widget.prototypeId))).get();
    for (final t in tendencies) {
      _tendencyValues[t.direction] = t.formula;
    }
    // Seed legacy defaults for missing directions (relative movement weights).
    for (var i = 0; i < 8; i++) {
      final dir = i + 1;
      if (!_tendencyValues.containsKey(dir)) {
        await db
            .into(db.prototypeTendencies)
            .insert(
              PrototypeTendenciesCompanion.insert(
                prototypeId: widget.prototypeId,
                direction: dir,
                formula: Value(_tendencyDefaults[i]),
              ),
            );
        _tendencyValues[dir] = _tendencyDefaults[i];
      }
    }
    if (mounted) setState(() => _tendenciesLoaded = true);
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await (db.update(
      db.prototypes,
    )..where((t) => t.id.equals(widget.prototypeId))).write(
      PrototypesCompanion(
        name: Value(_nameCtrl.text.trim()),
        longevityFormula: Value(_longevityCtrl.text.trim()),
        refractoryCombatFormula: Value(_refCombatCtrl.text.trim()),
        refractoryCourtshipFormula: Value(_refCourtshipCtrl.text.trim()),
        sexRatioMalesFormula: Value(_ratioMalesCtrl.text.trim()),
        sexRatioFemalesFormula: Value(_ratioFemalesCtrl.text.trim()),
        color: Value(_color),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prototype saved'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _pickColor() async {
    final current = _color != 0 ? Color(_color | 0xFF000000) : Colors.grey;
    final picked = await SubstrateListScreen.pickColor(context, current);
    if (picked != null) {
      setState(() => _color = picked.toARGB32() & 0x00FFFFFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prototype == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isFemale = _prototype!.sex == 'F';

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Prototype: ${_prototype!.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Morphology'),
            Tab(text: 'Fighting'),
            Tab(text: 'Courtship'),
            Tab(text: 'Movement'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildGeneralTab(isFemale),
          _buildMorphologyTab(),
          _buildCombatTab(),
          _buildCourtshipTab(),
          _buildMovementTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(bool isFemale) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 12),
        // Color picker
        Row(
          children: [
            const Text('Body color:', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _pickColor,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _color != 0
                      ? Color(_color | 0xFF000000)
                      : Colors.grey.shade600,
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
                  : 'Not set',
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FormulaField(
          label: 'Longevity',
          title: '${_nameCtrl.text} — Longevity',
          value: _longevityCtrl.text,
          onChanged: (v) => setState(() => _longevityCtrl.text = v),
        ),
        const SizedBox(height: 12),
        FormulaField(
          label: 'Refractory combat',
          title: '${_nameCtrl.text} — Refractory Combat',
          value: _refCombatCtrl.text,
          onChanged: (v) => setState(() => _refCombatCtrl.text = v),
        ),
        const SizedBox(height: 12),
        FormulaField(
          label: 'Refractory courtship',
          title: '${_nameCtrl.text} — Refractory Courtship',
          value: _refCourtshipCtrl.text,
          onChanged: (v) => setState(() => _refCourtshipCtrl.text = v),
        ),
        if (isFemale) ...[
          const SizedBox(height: 24),
          Text(
            'Sex ratio of offspring',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          FormulaField(
            label: 'Males proportion',
            title: '${_nameCtrl.text} — Males Proportion',
            value: _ratioMalesCtrl.text,
            onChanged: (v) => setState(() => _ratioMalesCtrl.text = v),
          ),
          const SizedBox(height: 12),
          FormulaField(
            label: 'Females proportion',
            title: '${_nameCtrl.text} — Females Proportion',
            value: _ratioFemalesCtrl.text,
            onChanged: (v) => setState(() => _ratioFemalesCtrl.text = v),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Assignment Criteria',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Rules for assigning new agents to this prototype. '
          'Evaluated in priority order; first match wins.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        _AssignmentCriteriaList(prototypeId: widget.prototypeId),
      ],
    );
  }

  Widget _buildMorphologyTab() {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();

    return FutureBuilder<List<MorphologicalCharacter>>(
      future: (db.select(
        db.morphologicalCharacters,
      )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get(),
      builder: (context, snapshot) {
        final chars = snapshot.data ?? [];
        if (chars.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No morphological characters defined yet.\n\n'
                    'Each character\'s value for this prototype is defined by a formula '
                    '(can be a constant, reference genetic loci, or any variable).',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Character'),
                    onPressed: () => _showAddCharacterDialog(context),
                  ),
                ],
              ),
            ),
          );
        }
        return FutureBuilder<List<PrototypeMorphologyData>>(
          future: (db.select(
            db.prototypeMorphology,
          )..where((t) => t.prototypeId.equals(widget.prototypeId))).get(),
          builder: (context, morphSnap) {
            final morphMap = <int, PrototypeMorphologyData>{};
            for (final m in morphSnap.data ?? []) {
              morphMap[m.characterId] = m;
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Value formulas per character (can be constants, loci references, or expressions):',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ...chars.map((c) {
                  final m = morphMap[c.id];
                  return _MorphologyLocusRow(
                    locusName: c.name,
                    isContinuous: c.isContinuous,
                    geneticFormula: m?.geneticFormula ?? c.defaultExpression,
                    environmentalFormula: m?.environmentalFormula ?? '0',
                    onGeneticChanged: (v) =>
                        _saveMorphology(db, c.id, genetic: v),
                    onEnvironmentalChanged: (v) =>
                        _saveMorphology(db, c.id, environmental: v),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddCharacterDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final defaultCtrl = TextEditingController(text: '0');
    var isContinuous = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Morphological Character'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., BodySize, WingLength',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: defaultCtrl,
                decoration: const InputDecoration(
                  labelText: 'Default expression',
                  hintText: 'e.g., 2.5 or a formula',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Continuous'),
                subtitle: Text(isContinuous ? 'Real-valued' : 'Integer-valued'),
                value: isContinuous,
                onChanged: (v) => setDialogState(() => isContinuous = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (result != true || !mounted) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    if (db == null) return;
    final existing = await (db.select(db.morphologicalCharacters)).get();
    await db
        .into(db.morphologicalCharacters)
        .insert(
          MorphologicalCharactersCompanion.insert(
            name: name,
            isContinuous: Value(isContinuous),
            defaultExpression: Value(
              defaultCtrl.text.trim().isEmpty ? '0' : defaultCtrl.text.trim(),
            ),
            sortOrder: Value(existing.length + 1),
          ),
        );
    // Refresh the morphology tab.
    setState(() {});
  }

  Future<void> _saveMorphology(
    AppDatabase db,
    int locusId, {
    String? genetic,
    String? environmental,
  }) async {
    final existing =
        await (db.select(db.prototypeMorphology)..where(
              (t) =>
                  t.prototypeId.equals(widget.prototypeId) &
                  t.characterId.equals(locusId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.prototypeMorphology)
          .insert(
            PrototypeMorphologyCompanion.insert(
              prototypeId: widget.prototypeId,
              characterId: locusId,
              geneticFormula: Value(genetic ?? '0'),
              environmentalFormula: Value(environmental ?? '0'),
            ),
          );
    } else {
      await (db.update(
        db.prototypeMorphology,
      )..where((t) => t.id.equals(existing.id))).write(
        PrototypeMorphologyCompanion(
          geneticFormula: genetic != null
              ? Value(genetic)
              : const Value.absent(),
          environmentalFormula: environmental != null
              ? Value(environmental)
              : const Value.absent(),
        ),
      );
    }
  }

  Widget _buildCombatTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Combat Strategy Matrix',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Defines how this prototype responds in combat.\n'
            'Rows = this agent\'s action, Columns = opponent\'s action.\n'
            'Each cell is a formula (probability weight).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _StrategyMatrixEditor(
            prototypeId: widget.prototypeId,
            tableName: 'combat',
            rowLabels: const ['Attack', 'Defend', 'Retreat'],
            colLabels: const ['Attack', 'Defend'],
          ),
        ],
      ),
    );
  }

  Widget _buildCourtshipTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Courtship Strategy Matrix',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Defines courtship interaction strategy.\n'
            'Rows = this agent\'s action, Columns = mate\'s action.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _StrategyMatrixEditor(
            prototypeId: widget.prototypeId,
            tableName: 'courtship',
            rowLabels: const ['Court', 'Accept', 'Reject', 'Ignore'],
            colLabels: const ['Court', 'Accept', 'Reject'],
          ),
        ],
      ),
    );
  }

  Widget _buildMovementTab() {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();
    if (!_tendenciesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // Directions RELATIVE to the agent's heading, in engine order
    // (index d = direction-1): [NW, N, NE, W, E, SW, S, SE].
    final directions = [
      '↖ Fwd-L',
      '↑ Forward',
      '↗ Fwd-R',
      '← Left',
      '→ Right',
      '↙ Back-L',
      '↓ Back',
      '↘ Back-R',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Movement Tendencies',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Relative probability weights per direction, relative to where the '
          'agent is facing. Higher = more likely to move that way.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        ...List.generate(8, (i) {
          final dir = i + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    directions[i],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: FormulaField(
                    label: directions[i],
                    title: '${_nameCtrl.text} — Tendency ${directions[i]}',
                    value: _tendencyValues[dir] ?? _tendencyDefaults[i],
                    onChanged: (v) => _saveTendency(db, dir, v),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _saveTendency(
    AppDatabase db,
    int direction,
    String formula,
  ) async {
    final existing =
        await (db.select(db.prototypeTendencies)..where(
              (t) =>
                  t.prototypeId.equals(widget.prototypeId) &
                  t.direction.equals(direction),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.prototypeTendencies)
          .insert(
            PrototypeTendenciesCompanion.insert(
              prototypeId: widget.prototypeId,
              direction: direction,
              formula: Value(formula),
            ),
          );
    } else {
      await (db.update(db.prototypeTendencies)
            ..where((t) => t.id.equals(existing.id)))
          .write(PrototypeTendenciesCompanion(formula: Value(formula)));
    }
    setState(() => _tendencyValues[direction] = formula);
  }
}

// --- Helper widgets ---

class _MorphologyLocusRow extends StatelessWidget {
  const _MorphologyLocusRow({
    required this.locusName,
    required this.isContinuous,
    required this.geneticFormula,
    required this.environmentalFormula,
    required this.onGeneticChanged,
    required this.onEnvironmentalChanged,
  });
  final String locusName;
  final bool isContinuous;
  final String geneticFormula;
  final String environmentalFormula;
  final ValueChanged<String> onGeneticChanged;
  final ValueChanged<String> onEnvironmentalChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$locusName (${isContinuous ? 'cont.' : 'disc.'})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          FormulaField(
            label: 'Genetic',
            title: '$locusName — Genetic Expression',
            value: geneticFormula,
            onChanged: onGeneticChanged,
          ),
          const SizedBox(height: 4),
          FormulaField(
            label: 'Environmental',
            title: '$locusName — Environmental Expression',
            value: environmentalFormula,
            onChanged: onEnvironmentalChanged,
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }
}

class _StrategyMatrixEditor extends ConsumerStatefulWidget {
  const _StrategyMatrixEditor({
    required this.prototypeId,
    required this.tableName,
    required this.rowLabels,
    required this.colLabels,
  });
  final int prototypeId;
  final String tableName;
  final List<String> rowLabels;
  final List<String> colLabels;

  @override
  ConsumerState<_StrategyMatrixEditor> createState() =>
      _StrategyMatrixEditorState();
}

class _StrategyMatrixEditorState extends ConsumerState<_StrategyMatrixEditor> {
  Map<String, String> _values = {}; // 'action.opponentAction' → formula
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    final map = <String, String>{};
    if (widget.tableName == 'combat') {
      final rows = await (db.select(
        db.prototypeCombat,
      )..where((t) => t.prototypeId.equals(widget.prototypeId))).get();
      for (final row in rows) {
        map['${row.action}.${row.opponentAction}'] = row.formula;
      }
    } else {
      final rows = await (db.select(
        db.prototypeCourtship,
      )..where((t) => t.prototypeId.equals(widget.prototypeId))).get();
      for (final row in rows) {
        map['${row.action}.${row.opponentAction}'] = row.formula;
      }
    }
    if (mounted) {
      setState(() {
        _values = map;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();
    if (_loading) return const LinearProgressIndicator();

    // Build a grid of formula fields.
    return Table(
      columnWidths: {
        0: const FixedColumnWidth(60),
        for (var i = 1; i <= widget.colLabels.length; i++)
          i: const FlexColumnWidth(),
      },
      children: [
        // Header row.
        TableRow(
          children: [
            const SizedBox.shrink(),
            ...widget.colLabels.map(
              (l) => Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  l,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        // Data rows.
        ...List.generate(widget.rowLabels.length, (row) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  widget.rowLabels[row],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...List.generate(widget.colLabels.length, (col) {
                final action = row + 1;
                final opponentAction = col + 1;
                final key = '$action.$opponentAction';
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: _InlineFormula(
                    initial: _values[key] ?? '0',
                    onSubmitted: (v) {
                      _saveCell(db, action, opponentAction, v);
                      setState(() => _values[key] = v);
                    },
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _saveCell(
    AppDatabase db,
    int action,
    int opponentAction,
    String formula,
  ) async {
    if (widget.tableName == 'combat') {
      final existing =
          await (db.select(db.prototypeCombat)..where(
                (t) =>
                    t.prototypeId.equals(widget.prototypeId) &
                    t.action.equals(action) &
                    t.opponentAction.equals(opponentAction),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await db
            .into(db.prototypeCombat)
            .insert(
              PrototypeCombatCompanion.insert(
                prototypeId: widget.prototypeId,
                action: action,
                opponentAction: opponentAction,
                formula: Value(formula),
              ),
            );
      } else {
        await (db.update(db.prototypeCombat)
              ..where((t) => t.id.equals(existing.id)))
            .write(PrototypeCombatCompanion(formula: Value(formula)));
      }
    } else {
      final existing =
          await (db.select(db.prototypeCourtship)..where(
                (t) =>
                    t.prototypeId.equals(widget.prototypeId) &
                    t.action.equals(action) &
                    t.opponentAction.equals(opponentAction),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await db
            .into(db.prototypeCourtship)
            .insert(
              PrototypeCourtshipCompanion.insert(
                prototypeId: widget.prototypeId,
                action: action,
                opponentAction: opponentAction,
                formula: Value(formula),
              ),
            );
      } else {
        await (db.update(db.prototypeCourtship)
              ..where((t) => t.id.equals(existing.id)))
            .write(PrototypeCourtshipCompanion(formula: Value(formula)));
      }
    }
  }
}

class _InlineFormula extends StatefulWidget {
  const _InlineFormula({required this.initial, required this.onSubmitted});
  final String initial;
  final ValueChanged<String> onSubmitted;

  @override
  State<_InlineFormula> createState() => _InlineFormulaState();
}

class _InlineFormulaState extends State<_InlineFormula> {
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
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        border: OutlineInputBorder(),
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}

/// Lists assignment criteria for a prototype, with add/edit/delete.
class _AssignmentCriteriaList extends ConsumerStatefulWidget {
  const _AssignmentCriteriaList({required this.prototypeId});
  final int prototypeId;

  @override
  ConsumerState<_AssignmentCriteriaList> createState() =>
      _AssignmentCriteriaListState();
}

class _AssignmentCriteriaListState
    extends ConsumerState<_AssignmentCriteriaList> {
  List<PrototypeAssignmentCriteriaData> _criteria = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    final rows =
        await (db.select(db.prototypeAssignmentCriteria)
              ..where((t) => t.prototypeId.equals(widget.prototypeId))
              ..orderBy([(t) => OrderingTerm.asc(t.priority)]))
            .get();
    if (mounted) setState(() => _criteria = rows);
  }

  Future<void> _add() async {
    final result = await _showCriterionDialog(context);
    if (result == null) return;
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await db
        .into(db.prototypeAssignmentCriteria)
        .insert(
          PrototypeAssignmentCriteriaCompanion.insert(
            prototypeId: widget.prototypeId,
            priority: Value(result.priority),
            formula: Value(result.formula),
            operator: Value(result.operator),
            threshold: Value(result.threshold),
          ),
        );
    _load();
  }

  Future<void> _edit(PrototypeAssignmentCriteriaData existing) async {
    final result = await _showCriterionDialog(context, initial: existing);
    if (result == null) return;
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await (db.update(
      db.prototypeAssignmentCriteria,
    )..where((t) => t.id.equals(existing.id))).write(
      PrototypeAssignmentCriteriaCompanion(
        priority: Value(result.priority),
        formula: Value(result.formula),
        operator: Value(result.operator),
        threshold: Value(result.threshold),
      ),
    );
    _load();
  }

  Future<void> _delete(int id) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await (db.delete(
      db.prototypeAssignmentCriteria,
    )..where((t) => t.id.equals(id))).go();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._criteria.map(
          (c) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              dense: true,
              title: Text(
                '${c.formula} ${c.operator} ${c.threshold}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              subtitle: Text('Priority: ${c.priority}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _edit(c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _delete(c.id),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add criterion'),
          onPressed: _add,
        ),
      ],
    );
  }

  Future<_CriterionResult?> _showCriterionDialog(
    BuildContext context, {
    PrototypeAssignmentCriteriaData? initial,
  }) async {
    final priorityCtrl = TextEditingController(
      text: '${initial?.priority ?? (_criteria.length + 1)}',
    );
    final formulaCtrl = TextEditingController(text: initial?.formula ?? 'Age');
    final thresholdCtrl = TextEditingController(
      text: '${initial?.threshold ?? 0.0}',
    );
    String selectedOp = initial?.operator ?? '>=';

    const operators = ['>', '>=', '<', '<=', '==', '!='];

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            initial == null ? 'New Assignment Criterion' : 'Edit Criterion',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priorityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Priority (lower = first)',
                ),
              ),
              const SizedBox(height: 12),
              FormulaField(
                label: 'Formula',
                title: 'Assignment criterion formula',
                value: formulaCtrl.text,
                onChanged: (v) => formulaCtrl.text = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedOp,
                decoration: const InputDecoration(labelText: 'Operator'),
                items: operators
                    .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedOp = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: thresholdCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Threshold'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result != true) return null;

    return _CriterionResult(
      priority: int.tryParse(priorityCtrl.text.trim()) ?? 1,
      formula: formulaCtrl.text.trim(),
      operator: selectedOp,
      threshold: double.tryParse(thresholdCtrl.text.trim()) ?? 0.0,
    );
  }
}

class _CriterionResult {
  final int priority;
  final String formula;
  final String operator;
  final double threshold;
  const _CriterionResult({
    required this.priority,
    required this.formula,
    required this.operator,
    required this.threshold,
  });
}
