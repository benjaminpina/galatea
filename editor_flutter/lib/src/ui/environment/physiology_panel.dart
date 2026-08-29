import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';
import '../formula/formula_field.dart';

/// Right panel for Physiology configuration:
/// - Metabolism (levels per nutrient)
/// - Behavior costs
/// - Feeding gains
/// - Substrate velocities
class PhysiologyPanel extends ConsumerWidget {
  const PhysiologyPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final substrates = ref.watch(substratesProvider).valueOrNull ?? [];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // --- Metabolism ---
        _SectionTitle(title: 'Metabolism', icon: Icons.monitor_heart_outlined),
        const SizedBox(height: 4),
        if (nutrients.isEmpty)
          _hint('Define nutrients first to configure metabolism.')
        else
          ...nutrients.map((n) => _MetabolismTile(nutrient: n)),
        const SizedBox(height: 16),

        // --- Feeding Gains ---
        _SectionTitle(title: 'Feeding Gains', icon: Icons.restaurant),
        const SizedBox(height: 4),
        if (nutrients.isEmpty)
          _hint('Define nutrients first.')
        else
          ...nutrients.map((n) => _FeedingGainTile(nutrient: n)),
        const SizedBox(height: 16),

        // --- Substrate Velocities ---
        _SectionTitle(title: 'Substrate Velocities', icon: Icons.speed),
        const SizedBox(height: 4),
        if (substrates.isEmpty)
          _hint('Define substrates first.')
        else
          ...substrates.map((s) => _VelocityTile(substrate: s)),
        const SizedBox(height: 16),

        // --- Behavior Costs ---
        _SectionTitle(title: 'Behavior Costs', icon: Icons.fitness_center),
        const SizedBox(height: 4),
        const _BehaviorCostsEditor(),
        const SizedBox(height: 16),

        // --- Gamete Costs ---
        _SectionTitle(title: 'Gamete Costs', icon: Icons.egg),
        const SizedBox(height: 4),
        const _GameteCostsEditor(),
        const SizedBox(height: 16),

        // --- Reproduction ---
        _SectionTitle(title: 'Reproduction', icon: Icons.child_care),
        const SizedBox(height: 4),
        const _ReproductionEditor(),
        const SizedBox(height: 16),

        // --- Oviposition Site Config ---
        _SectionTitle(title: 'Oviposition Sites', icon: Icons.egg_alt),
        const SizedBox(height: 4),
        const _OvipositionConfigEditor(),
      ],
    );
  }

  Widget _hint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Editable metabolism levels for a nutrient.
class _MetabolismTile extends ConsumerStatefulWidget {
  const _MetabolismTile({required this.nutrient});
  final Nutrient nutrient;

  @override
  ConsumerState<_MetabolismTile> createState() => _MetabolismTileState();
}

class _MetabolismTileState extends ConsumerState<_MetabolismTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(widget.nutrient.color),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              widget.nutrient.name,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) _buildFields(),
        ],
      ),
    );
  }

  Widget _buildFields() {
    // Read current metabolism from DB (or show defaults).
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();

    return FutureBuilder<MetabolismData?>(
      future:
          (db.select(db.metabolism)
                ..where((t) => t.nutrientId.equals(widget.nutrient.id)))
              .getSingleOrNull(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              _FormulaField(
                label: 'Min',
                initial: data?.minFormula ?? '0',
                onSaved: (v) => _save(db, min: v),
              ),
              _FormulaField(
                label: 'Critical',
                initial: data?.criticalFormula ?? '10',
                onSaved: (v) => _save(db, critical: v),
              ),
              _FormulaField(
                label: 'Optimal',
                initial: data?.optimalFormula ?? '50',
                onSaved: (v) => _save(db, optimal: v),
              ),
              _FormulaField(
                label: 'Initial',
                initial: data?.initialFormula ?? '50',
                onSaved: (v) => _save(db, initial: v),
              ),
              _FormulaField(
                label: 'Max',
                initial: data?.maxFormula ?? '100',
                onSaved: (v) => _save(db, max: v),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(
    AppDatabase db, {
    String? min,
    String? critical,
    String? optimal,
    String? initial,
    String? max,
  }) async {
    final existing = await (db.select(
      db.metabolism,
    )..where((t) => t.nutrientId.equals(widget.nutrient.id))).getSingleOrNull();

    if (existing == null) {
      await db
          .into(db.metabolism)
          .insert(
            MetabolismCompanion.insert(
              nutrientId: widget.nutrient.id,
              minFormula: Value(min ?? '0'),
              criticalFormula: Value(critical ?? '10'),
              optimalFormula: Value(optimal ?? '50'),
              initialFormula: Value(initial ?? '50'),
              maxFormula: Value(max ?? '100'),
            ),
          );
    } else {
      await (db.update(
        db.metabolism,
      )..where((t) => t.nutrientId.equals(widget.nutrient.id))).write(
        MetabolismCompanion(
          minFormula: min != null ? Value(min) : const Value.absent(),
          criticalFormula: critical != null
              ? Value(critical)
              : const Value.absent(),
          optimalFormula: optimal != null
              ? Value(optimal)
              : const Value.absent(),
          initialFormula: initial != null
              ? Value(initial)
              : const Value.absent(),
          maxFormula: max != null ? Value(max) : const Value.absent(),
        ),
      );
    }
  }
}

/// Editable feeding gain for a nutrient.
class _FeedingGainTile extends ConsumerWidget {
  const _FeedingGainTile({required this.nutrient});
  final Nutrient nutrient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();

    return FutureBuilder<FeedingGain?>(
      future: (db.select(
        db.feedingGains,
      )..where((t) => t.nutrientId.equals(nutrient.id))).getSingleOrNull(),
      builder: (context, snapshot) {
        final gain = snapshot.data?.gainFormula ?? '10';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(nutrient.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  nutrient.name,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              Expanded(
                child: _InlineFormulaField(
                  initial: gain,
                  onSubmitted: (v) async {
                    final existing =
                        await (db.select(db.feedingGains)
                              ..where((t) => t.nutrientId.equals(nutrient.id)))
                            .getSingleOrNull();
                    if (existing == null) {
                      await db
                          .into(db.feedingGains)
                          .insert(
                            FeedingGainsCompanion.insert(
                              nutrientId: nutrient.id,
                              gainFormula: Value(v),
                            ),
                          );
                    } else {
                      await (db.update(db.feedingGains)
                            ..where((t) => t.nutrientId.equals(nutrient.id)))
                          .write(FeedingGainsCompanion(gainFormula: Value(v)));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Editable velocity for a substrate.
class _VelocityTile extends ConsumerWidget {
  const _VelocityTile({required this.substrate});
  final Substrate substrate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    if (db == null) return const SizedBox.shrink();

    return FutureBuilder<SubstrateVelocity?>(
      future: (db.select(
        db.substrateVelocities,
      )..where((t) => t.substrateId.equals(substrate.id))).getSingleOrNull(),
      builder: (context, snapshot) {
        final vel = snapshot.data?.velocityFormula ?? '1';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(substrate.color),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  substrate.name,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: _InlineFormulaField(
                  initial: vel,
                  onSubmitted: (v) async {
                    final existing =
                        await (db.select(
                              db.substrateVelocities,
                            )..where((t) => t.substrateId.equals(substrate.id)))
                            .getSingleOrNull();
                    if (existing == null) {
                      await db
                          .into(db.substrateVelocities)
                          .insert(
                            SubstrateVelocitiesCompanion.insert(
                              substrateId: substrate.id,
                              velocityFormula: Value(v),
                            ),
                          );
                    } else {
                      await (db.update(db.substrateVelocities)
                            ..where((t) => t.substrateId.equals(substrate.id)))
                          .write(
                            SubstrateVelocitiesCompanion(
                              velocityFormula: Value(v),
                            ),
                          );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Helper widgets ---

class _FormulaField extends StatefulWidget {
  const _FormulaField({
    required this.label,
    required this.initial,
    required this.onSaved,
  });
  final String label;
  final String initial;
  final ValueChanged<String> onSaved;

  @override
  State<_FormulaField> createState() => _FormulaFieldState();
}

class _FormulaFieldState extends State<_FormulaField> {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(widget.label, style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: widget.onSaved,
              onEditingComplete: () => widget.onSaved(_ctrl.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineFormulaField extends StatefulWidget {
  const _InlineFormulaField({required this.initial, required this.onSubmitted});
  final String initial;
  final ValueChanged<String> onSubmitted;

  @override
  State<_InlineFormulaField> createState() => _InlineFormulaFieldState();
}

class _InlineFormulaFieldState extends State<_InlineFormulaField> {
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
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: OutlineInputBorder(),
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}

/// Editor for the reproduction singleton table (11 formula fields).
class _ReproductionEditor extends ConsumerStatefulWidget {
  const _ReproductionEditor();

  @override
  ConsumerState<_ReproductionEditor> createState() =>
      _ReproductionEditorState();
}

class _ReproductionEditorState extends ConsumerState<_ReproductionEditor> {
  ReproductionData? _data;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    var data = await (db.select(
      db.reproduction,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (data == null) {
      // Create default singleton row.
      await db
          .into(db.reproduction)
          .insert(ReproductionCompanion.insert(id: const Value(1)));
      data = await (db.select(
        db.reproduction,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
    }
    if (mounted) {
      setState(() {
        _data = data;
        _loaded = true;
      });
    }
  }

  Future<void> _save(ReproductionCompanion companion) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await (db.update(
      db.reproduction,
    )..where((t) => t.id.equals(1))).write(companion);
    _load(); // Refresh.
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _data == null) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final d = _data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _reproField(
          'Max eggs',
          d.maxEggsFormula,
          (v) => _save(ReproductionCompanion(maxEggsFormula: Value(v))),
        ),
        _reproField(
          'Max sperm packs',
          d.maxSpermPacksFormula,
          (v) => _save(ReproductionCompanion(maxSpermPacksFormula: Value(v))),
        ),
        _reproField(
          'Packs transferred',
          d.packsTransferredFormula,
          (v) =>
              _save(ReproductionCompanion(packsTransferredFormula: Value(v))),
        ),
        _reproField(
          'Fraction fertilized',
          d.fractionFertilizedFormula,
          (v) =>
              _save(ReproductionCompanion(fractionFertilizedFormula: Value(v))),
        ),
        _reproField(
          'Paternity',
          d.paternityFormula,
          (v) => _save(ReproductionCompanion(paternityFormula: Value(v))),
        ),
        _reproField(
          'Max stored packs',
          d.maxStoredPacksFormula,
          (v) => _save(ReproductionCompanion(maxStoredPacksFormula: Value(v))),
        ),
        _reproField(
          'Consumption rate',
          d.consumptionRateFormula,
          (v) => _save(ReproductionCompanion(consumptionRateFormula: Value(v))),
        ),
        _reproField(
          'Eggs per cycle',
          d.eggsPerCycleFormula,
          (v) => _save(ReproductionCompanion(eggsPerCycleFormula: Value(v))),
        ),
        _reproField(
          'Egg fraction',
          d.eggFractionFormula,
          (v) => _save(ReproductionCompanion(eggFractionFormula: Value(v))),
        ),
        _reproField(
          'Pack fraction',
          d.packFractionFormula,
          (v) => _save(ReproductionCompanion(packFractionFormula: Value(v))),
        ),
        _reproField(
          'Sperm degradation',
          d.spermDegradationFormula,
          (v) =>
              _save(ReproductionCompanion(spermDegradationFormula: Value(v))),
        ),
      ],
    );
  }

  Widget _reproField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: FormulaField(
        label: label,
        title: 'Reproduction — $label',
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// Editor for behavior costs: each behavior × each nutrient = one formula.
class _BehaviorCostsEditor extends ConsumerWidget {
  const _BehaviorCostsEditor();

  // Canonical behavior names shared with the Go engine
  // (see world.BuildBehaviorNames). The stored value is the canonical name;
  // the label is shown to the user. "Feed" is generic per-nutrient.
  static const _behaviors = <({String name, String label})>[
    (name: 'Move', label: 'Move'),
    (name: 'Rest', label: 'Rest'),
    (name: 'Feed', label: 'Feed'),
    (name: 'Fight_Attack', label: 'Fight — Attack'),
    (name: 'Fight_Defend', label: 'Fight — Defend'),
    (name: 'Fight_Retreat', label: 'Fight — Retreat'),
    (name: 'Court_Display', label: 'Court — Display'),
    (name: 'Court_Accept', label: 'Court — Accept'),
    (name: 'Court_Reject', label: 'Court — Reject'),
    (name: 'Oviposit', label: 'Oviposit'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);
    if (db == null || nutrients.isEmpty) {
      return const Text(
        'Define nutrients first.',
        style: TextStyle(fontSize: 11, color: Colors.grey),
      );
    }

    return FutureBuilder<List<BehaviorCost>>(
      future: db.select(db.behaviorCosts).get(),
      builder: (context, snapshot) {
        final existing = <String, String>{};
        for (final row in snapshot.data ?? []) {
          existing['${row.behavior}.${row.nutrientId}'] = row.costFormula;
        }

        return ExpansionTile(
          title: const Text('Edit costs', style: TextStyle(fontSize: 12)),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 8),
          children: _behaviors.map((behavior) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    behavior.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ...nutrients.map((n) {
                    final key = '${behavior.name}.${n.id}';
                    final value = existing[key] ?? '1';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              n.name,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          Expanded(
                            child: FormulaField(
                              label: n.name,
                              title: '${behavior.label} — ${n.name} cost',
                              value: value,
                              onChanged: (v) =>
                                  _saveCost(db, behavior.name, n.id, v),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _saveCost(
    AppDatabase db,
    String behavior,
    int nutrientId,
    String formula,
  ) async {
    final existing =
        await (db.select(db.behaviorCosts)..where(
              (t) =>
                  t.behavior.equals(behavior) & t.nutrientId.equals(nutrientId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.behaviorCosts)
          .insert(
            BehaviorCostsCompanion.insert(
              behavior: behavior,
              nutrientId: nutrientId,
              costFormula: Value(formula),
            ),
          );
    } else {
      await (db.update(db.behaviorCosts)
            ..where((t) => t.id.equals(existing.id)))
          .write(BehaviorCostsCompanion(costFormula: Value(formula)));
    }
  }
}

/// Editor for gamete costs: sex × nutrient = one formula.
class _GameteCostsEditor extends ConsumerWidget {
  const _GameteCostsEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final db = ref.read(databaseProvider);
    if (db == null || nutrients.isEmpty) {
      return const Text(
        'Define nutrients first.',
        style: TextStyle(fontSize: 11, color: Colors.grey),
      );
    }

    return FutureBuilder<List<GameteCost>>(
      future: db.select(db.gameteCosts).get(),
      builder: (context, snapshot) {
        final existing = <String, String>{};
        for (final row in snapshot.data ?? []) {
          existing['${row.sex}.${row.nutrientId}'] = row.costFormula;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Male gamete costs:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            ...nutrients.map((n) {
              final value = existing['M.${n.id}'] ?? '5';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(n.name, style: const TextStyle(fontSize: 10)),
                    ),
                    Expanded(
                      child: FormulaField(
                        label: n.name,
                        title: 'Male gamete — ${n.name} cost',
                        value: value,
                        onChanged: (v) => _saveCost(db, 'M', n.id, v),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text(
              'Female gamete costs:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            ...nutrients.map((n) {
              final value = existing['F.${n.id}'] ?? '5';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(n.name, style: const TextStyle(fontSize: 10)),
                    ),
                    Expanded(
                      child: FormulaField(
                        label: n.name,
                        title: 'Female gamete — ${n.name} cost',
                        value: value,
                        onChanged: (v) => _saveCost(db, 'F', n.id, v),
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

  Future<void> _saveCost(
    AppDatabase db,
    String sex,
    int nutrientId,
    String formula,
  ) async {
    final existing =
        await (db.select(db.gameteCosts)..where(
              (t) => t.sex.equals(sex) & t.nutrientId.equals(nutrientId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.gameteCosts)
          .insert(
            GameteCostsCompanion.insert(
              sex: sex,
              nutrientId: nutrientId,
              costFormula: Value(formula),
            ),
          );
    } else {
      await (db.update(db.gameteCosts)..where((t) => t.id.equals(existing.id)))
          .write(GameteCostsCompanion(costFormula: Value(formula)));
    }
  }
}

/// Editor for the oviposition site global configuration singleton.
/// Controls the default color and enabled/disabled state of oviposition sites.
class _OvipositionConfigEditor extends ConsumerStatefulWidget {
  const _OvipositionConfigEditor();

  @override
  ConsumerState<_OvipositionConfigEditor> createState() =>
      _OvipositionConfigEditorState();
}

class _OvipositionConfigEditorState
    extends ConsumerState<_OvipositionConfigEditor> {
  OvipositionSiteConfigData? _data;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    var data = await (db.select(
      db.ovipositionSiteConfig,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (data == null) {
      // Create default singleton row.
      await db
          .into(db.ovipositionSiteConfig)
          .insert(OvipositionSiteConfigCompanion.insert(id: const Value(1)));
      data = await (db.select(
        db.ovipositionSiteConfig,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
    }
    if (mounted) {
      setState(() {
        _data = data;
        _loaded = true;
      });
    }
  }

  Future<void> _save(OvipositionSiteConfigCompanion companion) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await (db.update(
      db.ovipositionSiteConfig,
    )..where((t) => t.id.equals(1))).write(companion);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _data == null) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final d = _data!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enabled toggle
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Oviposition sites enabled',
            style: TextStyle(fontSize: 12),
          ),
          subtitle: const Text(
            'When disabled, agents cannot oviposit.',
            style: TextStyle(fontSize: 10),
          ),
          value: d.enabled,
          onChanged: (val) =>
              _save(OvipositionSiteConfigCompanion(enabled: Value(val))),
        ),
        const SizedBox(height: 8),
        // Color picker
        Row(
          children: [
            const Text('Site color:', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _pickColor(context, d.color),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(d.color | 0xFF000000),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '#${(d.color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Oviposition sites are placed on the map using the drawing tools.\n'
          'Quality and capacity are configured per site instance.',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _pickColor(BuildContext context, int currentColor) async {
    final controller = TextEditingController(
      text: (currentColor & 0xFFFFFF).toRadixString(16).padLeft(6, '0'),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Oviposition Site Color'),
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
            // Preview
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
              if (parsed != null) {
                Navigator.pop(ctx, parsed);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (result != null) {
      _save(OvipositionSiteConfigCompanion(color: Value(result)));
    }
  }
}
