import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../substrates/substrate_list_screen.dart'; // Reuse _pickColor.

/// Screen for managing nutrients (and implicitly their resource sources).
class NutrientListScreen extends ConsumerWidget {
  const NutrientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrients = ref.watch(nutrientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add nutrient',
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: nutrients.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No nutrients defined.\n\n'
                  'Each nutrient you define automatically becomes a resource source '
                  'that can be placed in environments. For example, defining "Water" '
                  'means you can place water sources on the map.\n\n'
                  'Tap + to add one.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) => _NutrientTile(nutrient: list[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    var selectedColor = Colors.cyan.toARGB32();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Nutrient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Water, Sugar, Protein',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Source color: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await SubstrateListScreen.pickColor(ctx, Color(selectedColor));
                      if (picked != null) {
                        setState(() => selectedColor = picked.toARGB32());
                      }
                    },
                    child: Container(
                      width: 48, height: 32,
                      decoration: BoxDecoration(
                        color: Color(selectedColor),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This color will be used to render sources of this nutrient in the visualizer.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
          ],
        ),
      ),
    );

    if (result != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(nutrientDaoProvider);
    if (dao == null) return;

    final existing = await dao.getAll();
    await dao.add(name, selectedColor, existing.length + 1);
  }
}

class _NutrientTile extends ConsumerWidget {
  const _NutrientTile({required this.nutrient});

  final Nutrient nutrient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Color(nutrient.color),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.water_drop, size: 20, color: Colors.white),
        ),
        title: Text(nutrient.name),
        subtitle: const Text('Nutrient + Source'),
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
    final nameCtrl = TextEditingController(text: nutrient.name);
    var selectedColor = nutrient.color;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Nutrient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Source color: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await SubstrateListScreen.pickColor(ctx, Color(selectedColor));
                      if (picked != null) {
                        setState(() => selectedColor = picked.toARGB32());
                      }
                    },
                    child: Container(
                      width: 48, height: 32,
                      decoration: BoxDecoration(
                        color: Color(selectedColor),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (result != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(nutrientDaoProvider);
    await dao?.updateNutrient(nutrient.id, name, selectedColor);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Nutrient'),
        content: Text('Delete "${nutrient.name}"? This will also remove all its sources from environments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dao = ref.read(nutrientDaoProvider);
      await dao?.remove(nutrient.id);
    }
  }
}
