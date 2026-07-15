import 'package:flutter/material.dart';
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
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add substrate',
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: substrates.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No substrates defined. Tap + to add one.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final sub = list[index];
              return _SubstrateTile(substrate: sub);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    var selectedColor = Colors.green.toARGB32();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Substrate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Color: '),
                  const SizedBox(width: 8),
                  _ColorChip(
                    color: Color(selectedColor),
                    onTap: () async {
                      final picked = await _pickColor(ctx, Color(selectedColor));
                      if (picked != null) {
                        setState(() => selectedColor = picked.toARGB32());
                      }
                    },
                  ),
                ],
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
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(substrateDaoProvider);
    if (dao == null) return;

    final existing = await dao.getAll();
    await dao.add(name, selectedColor, false, existing.length + 1);
  }

  static Future<Color?> _pickColor(BuildContext context, Color current) async {
    final colors = [
      Colors.green, Colors.lightGreen, Colors.teal,
      Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.amber, Colors.orange, Colors.brown,
      Colors.red, Colors.pink, Colors.purple,
      Colors.grey, Colors.blueGrey, Colors.lime,
      const Color(0xFF228B22), const Color(0xFFC2B280), const Color(0xFF1E90FF),
      const Color(0xFF696969), const Color(0xFF006400), const Color(0xFFDEB887),
    ];

    return showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) {
            return GestureDetector(
              onTap: () => Navigator.pop(ctx, c),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: c == current ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
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
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Color(substrate.color),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(substrate.name),
        subtitle: Text(substrate.isMixed ? 'Mixed' : 'Simple'),
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
              Row(
                children: [
                  const Text('Color: '),
                  const SizedBox(width: 8),
                  _ColorChip(
                    color: Color(selectedColor),
                    onTap: () async {
                      final picked = await SubstrateListScreen._pickColor(ctx, Color(selectedColor));
                      if (picked != null) {
                        setState(() => selectedColor = picked.toARGB32());
                      }
                    },
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
      final dao = ref.read(substrateDaoProvider);
      await dao?.remove(substrate.id);
    }
  }
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
        width: 48, height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
      ),
    );
  }
}
