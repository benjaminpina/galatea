import 'package:drift/drift.dart' hide Column, Table;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';

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
    });
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
        TextField(
          controller: _longevityCtrl,
          decoration: const InputDecoration(labelText: 'Longevity (formula)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _refCombatCtrl,
          decoration: const InputDecoration(
            labelText: 'Refractory combat (formula)',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _refCourtshipCtrl,
          decoration: const InputDecoration(
            labelText: 'Refractory courtship (formula)',
          ),
        ),
        if (isFemale) ...[
          const SizedBox(height: 24),
          Text(
            'Sex ratio of offspring',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ratioMalesCtrl,
            decoration: const InputDecoration(
              labelText: 'Males proportion (formula)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ratioFemalesCtrl,
            decoration: const InputDecoration(
              labelText: 'Females proportion (formula)',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMorphologyTab() {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();

    return FutureBuilder<List<LociData>>(
      future: (db.select(
        db.loci,
      )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get(),
      builder: (context, snapshot) {
        final loci = snapshot.data ?? [];
        if (loci.isEmpty) {
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
              morphMap[m.locusId] = m;
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Value formulas per character (can be constants, loci references, or expressions):',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ...loci.map((l) {
                  final m = morphMap[l.id];
                  return _MorphologyLocusRow(
                    locusName: l.name,
                    isContinuous: l.isContinuous,
                    geneticFormula: m?.geneticFormula ?? l.defaultExpression,
                    environmentalFormula: m?.environmentalFormula ?? '0',
                    onGeneticChanged: (v) =>
                        _saveMorphology(db, l.id, genetic: v),
                    onEnvironmentalChanged: (v) =>
                        _saveMorphology(db, l.id, environmental: v),
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
    final existing = await (db.select(db.loci)).get();
    await db
        .into(db.loci)
        .insert(
          LociCompanion.insert(
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
                  t.locusId.equals(locusId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.prototypeMorphology)
          .insert(
            PrototypeMorphologyCompanion.insert(
              prototypeId: widget.prototypeId,
              locusId: locusId,
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

    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

    return FutureBuilder<List<PrototypeTendency>>(
      future:
          (db.select(db.prototypeTendencies)
                ..where((t) => t.prototypeId.equals(widget.prototypeId))
                ..orderBy([(t) => OrderingTerm.asc(t.direction)]))
              .get(),
      builder: (context, snapshot) {
        final tendencies = <int, String>{};
        for (final t in snapshot.data ?? []) {
          tendencies[t.direction] = t.formula;
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Movement Tendencies',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Relative probability weights for each direction.\n'
              'Higher = more likely to move that way.',
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
                      child: _InlineFormula(
                        initial: tendencies[dir] ?? '1',
                        onSubmitted: (v) => _saveTendency(db, dir, v),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
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
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text('Genetic:', style: TextStyle(fontSize: 11)),
              ),
              Expanded(
                child: _InlineFormula(
                  initial: geneticFormula,
                  onSubmitted: onGeneticChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text('Environ:', style: TextStyle(fontSize: 11)),
              ),
              Expanded(
                child: _InlineFormula(
                  initial: environmentalFormula,
                  onSubmitted: onEnvironmentalChanged,
                ),
              ),
            ],
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }
}

class _StrategyMatrixEditor extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();

    // Build a grid of formula fields.
    return Table(
      columnWidths: {
        0: const FixedColumnWidth(60),
        for (var i = 1; i <= colLabels.length; i++) i: const FlexColumnWidth(),
      },
      children: [
        // Header row.
        TableRow(
          children: [
            const SizedBox.shrink(),
            ...colLabels.map(
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
        ...List.generate(rowLabels.length, (row) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  rowLabels[row],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...List.generate(colLabels.length, (col) {
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: _InlineFormula(
                    initial: '0',
                    onSubmitted: (v) => _saveCell(db, row + 1, col + 1, v),
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
    if (tableName == 'combat') {
      final existing =
          await (db.select(db.prototypeCombat)..where(
                (t) =>
                    t.prototypeId.equals(prototypeId) &
                    t.action.equals(action) &
                    t.opponentAction.equals(opponentAction),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await db
            .into(db.prototypeCombat)
            .insert(
              PrototypeCombatCompanion.insert(
                prototypeId: prototypeId,
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
                    t.prototypeId.equals(prototypeId) &
                    t.action.equals(action) &
                    t.opponentAction.equals(opponentAction),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await db
            .into(db.prototypeCourtship)
            .insert(
              PrototypeCourtshipCompanion.insert(
                prototypeId: prototypeId,
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
