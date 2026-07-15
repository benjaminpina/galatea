import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';

/// Screen for managing simple and mixed substrates.
class SubstrateListScreen extends ConsumerWidget {
  const SubstrateListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final substrates = ref.watch(substratesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Substrates'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            tooltip: 'Add substrate',
            onSelected: (value) {
              if (value == 'simple') {
                _showAddSimpleDialog(context, ref);
              } else {
                _showAddMixedDialog(context, ref);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'simple',
                child: Text('Add Simple Substrate'),
              ),
              PopupMenuItem(value: 'mixed', child: Text('Add Mixed Substrate')),
            ],
          ),
        ],
      ),
      body: substrates.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No substrates defined. Tap + to add one.'),
            );
          }
          final simple = list.where((s) => !s.isMixed).toList();
          final mixed = list.where((s) => s.isMixed).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (simple.isNotEmpty) ...[
                Text(
                  'Simple Substrates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...simple.map((s) => _SubstrateTile(substrate: s)),
              ],
              if (mixed.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Mixed Substrates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...mixed.map((s) => _MixedSubstrateTile(substrate: s)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddSimpleDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    var selectedColor = Colors.green.toARGB32();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Simple Substrate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              _colorRow(
                ctx,
                selectedColor,
                (c) => setState(() => selectedColor = c),
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

    if (result != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(substrateDaoProvider);
    if (dao == null) return;
    final existing = await dao.getAll();
    await dao.add(name, selectedColor, false, existing.length + 1);
  }

  Future<void> _showAddMixedDialog(BuildContext context, WidgetRef ref) async {
    final dao = ref.read(substrateDaoProvider);
    if (dao == null) return;

    final allSubstrates = await dao.getAll();
    final simpleSubstrates = allSubstrates.where((s) => !s.isMixed).toList();

    if (simpleSubstrates.length < 2) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Need at least 2 simple substrates to create a mix.'),
          ),
        );
      }
      return;
    }

    final nameController = TextEditingController();
    var selectedColor = 0xFF808080; // Will be auto-computed from composition.
    // Map of simple substrate ID → percentage.
    final percentages = <int, int>{};
    for (final s in simpleSubstrates) {
      percentages[s.id] = 0;
    }

    if (!context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final total = percentages.values.fold(0, (a, b) => a + b);
          return AlertDialog(
            title: const Text('New Mixed Substrate'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    _colorRow(
                      ctx,
                      selectedColor,
                      (c) => setState(() => selectedColor = c),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Composition (total: $total%)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: total == 100 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...simpleSubstrates.map((simple) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(simple.color),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: Text(
                                simple.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: 100,
                                divisions: 20,
                                value: percentages[simple.id]!.toDouble(),
                                onChanged: (v) => setState(() {
                                  percentages[simple.id] = v.round();
                                  selectedColor =
                                      SubstrateListScreen.blendColors(
                                        simpleSubstrates,
                                        percentages,
                                      );
                                }),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${percentages[simple.id]}%',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: total == 100 ? () => Navigator.pop(ctx, true) : null,
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );

    if (result != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final existing = await dao.getAll();
    final mixedId = await dao.add(
      name,
      selectedColor,
      true,
      existing.length + 1,
    );

    // Save compositions.
    for (final entry in percentages.entries) {
      if (entry.value > 0) {
        await dao.addComposition(mixedId, entry.key, entry.value);
      }
    }
  }

  static Widget _colorRow(
    BuildContext ctx,
    int colorValue,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      children: [
        const Text('Color: '),
        const SizedBox(width: 8),
        _ColorChip(
          color: Color(colorValue),
          onTap: () async {
            final picked = await pickColor(ctx, Color(colorValue));
            if (picked != null) {
              onChanged(picked.toARGB32());
            }
          },
        ),
        const SizedBox(width: 8),
        const Text(
          '(auto-blended from composition)',
          style: TextStyle(fontSize: 11, color: Colors.white38),
        ),
      ],
    );
  }

  /// Computes a blended color from simple substrates weighted by their percentages.
  static int blendColors(
    List<Substrate> simpleSubstrates,
    Map<int, int> percentages,
  ) {
    double r = 0, g = 0, b = 0;
    int totalPct = 0;
    for (final sub in simpleSubstrates) {
      final pct = percentages[sub.id] ?? 0;
      if (pct <= 0) continue;
      final c = Color(sub.color);
      r += ((c.r * 255.0).round()) * pct;
      g += ((c.g * 255.0).round()) * pct;
      b += ((c.b * 255.0).round()) * pct;
      totalPct += pct;
    }
    if (totalPct == 0) return 0xFF808080;
    return Color.fromARGB(
      255,
      (r / totalPct).round(),
      (g / totalPct).round(),
      (b / totalPct).round(),
    ).toARGB32();
  }

  static Future<Color?> pickColor(BuildContext context, Color current) async {
    Color pickedColor = current;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: current,
            onColorChanged: (color) => pickedColor = color,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Select'),
          ),
        ],
      ),
    );

    if (result == true) return pickedColor;
    return null;
  }
}

class _SubstrateTile extends ConsumerWidget {
  const _SubstrateTile({required this.substrate});

  final Substrate substrate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color(substrate.color),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(substrate.name),
        subtitle: const Text('Simple'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: substrate.name);
    var selectedColor = substrate.color;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Substrate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              SubstrateListScreen._colorRow(
                ctx,
                selectedColor,
                (c) => setState(() => selectedColor = c),
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

    if (result != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    final dao = ref.read(substrateDaoProvider);
    await dao?.updateSubstrate(substrate.id, name, selectedColor);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Substrate'),
        content: Text('Delete "${substrate.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final dao = ref.read(substrateDaoProvider);
      await dao?.remove(substrate.id);
    }
  }
}

/// Tile for mixed substrates with edit support.
class _MixedSubstrateTile extends ConsumerWidget {
  const _MixedSubstrateTile({required this.substrate});

  final Substrate substrate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color(substrate.color),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.layers, size: 18, color: Colors.white70),
        ),
        title: Text(substrate.name),
        subtitle: const Text('Mixed'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
        children: [_CompositionDetails(mixedId: substrate.id)],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final dao = ref.read(substrateDaoProvider);
    if (dao == null) return;

    final allSubstrates = await dao.getAll();
    final simpleSubstrates = allSubstrates.where((s) => !s.isMixed).toList();
    final existingComps = await dao.getCompositions(substrate.id);

    final nameController = TextEditingController(text: substrate.name);
    var selectedColor = substrate.color;

    final percentages = <int, int>{};
    for (final s in simpleSubstrates) {
      percentages[s.id] = 0;
    }
    for (final comp in existingComps) {
      if (percentages.containsKey(comp.simpleSubstrateId)) {
        percentages[comp.simpleSubstrateId] = comp.percentage;
      }
    }

    if (!context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final total = percentages.values.fold(0, (a, b) => a + b);
          return AlertDialog(
            title: const Text('Edit Mixed Substrate'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 16),
                    SubstrateListScreen._colorRow(
                      ctx,
                      selectedColor,
                      (c) => setState(() => selectedColor = c),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Composition (total: $total%)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: total == 100 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...simpleSubstrates.map(
                      (simple) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(simple.color),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: Text(
                                simple.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: 100,
                                divisions: 20,
                                value: percentages[simple.id]!.toDouble(),
                                onChanged: (v) => setState(() {
                                  percentages[simple.id] = v.round();
                                  selectedColor =
                                      SubstrateListScreen.blendColors(
                                        simpleSubstrates,
                                        percentages,
                                      );
                                }),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${percentages[simple.id]}%',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: total == 100 ? () => Navigator.pop(ctx, true) : null,
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (result != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    await dao.updateSubstrate(substrate.id, name, selectedColor);
    await dao.replaceCompositions(substrate.id, percentages);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mixed Substrate'),
        content: Text('Delete "${substrate.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final dao = ref.read(substrateDaoProvider);
      await dao?.remove(substrate.id);
    }
  }
}

class _CompositionDetails extends ConsumerWidget {
  const _CompositionDetails({required this.mixedId});

  final int mixedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(substrateDaoProvider);
    if (dao == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: _loadComposition(dao, ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        final entries = snapshot.data!;
        if (entries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No composition data.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: e.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.name)),
                    Text(
                      '${e.percentage}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<List<_CompositionEntry>> _loadComposition(
    dynamic dao,
    WidgetRef ref,
  ) async {
    final compositions = await dao.getCompositions(mixedId);
    final allSubstrates = await dao.getAll();
    final substMap = {for (final s in allSubstrates) s.id: s};

    return compositions.map((c) {
      final simple = substMap[c.simpleSubstrateId];
      return _CompositionEntry(
        name: simple?.name ?? '?',
        color: Color(simple?.color ?? 0),
        percentage: c.percentage,
      );
    }).toList();
  }
}

class _CompositionEntry {
  final String name;
  final Color color;
  final int percentage;

  _CompositionEntry({
    required this.name,
    required this.color,
    required this.percentage,
  });
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
      ),
    );
  }
}
