import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Screen for managing adult agent prototypes.
class PrototypeListScreen extends ConsumerWidget {
  const PrototypeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prototypes = ref.watch(prototypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prototypes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add prototype',
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: prototypes.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No prototypes defined. Tap + to add one.'));
          }
          final males = list.where((p) => p.sex == 'M').toList();
          final females = list.where((p) => p.sex == 'F').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (males.isNotEmpty) ...[
                Text('Males', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...males.map((p) => _PrototypeTile(prototype: p)),
                const SizedBox(height: 16),
              ],
              if (females.isNotEmpty) ...[
                Text('Females', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...females.map((p) => _PrototypeTile(prototype: p)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final longevityCtrl = TextEditingController(text: '1000');
    final refCombatCtrl = TextEditingController(text: '10');
    final refCourtCtrl = TextEditingController(text: '15');
    var sex = 'M';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Prototype'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: sex,
                  decoration: const InputDecoration(labelText: 'Sex'),
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Male')),
                    DropdownMenuItem(value: 'F', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => sex = v ?? 'M'),
                ),
                const SizedBox(height: 12),
                TextField(controller: longevityCtrl, decoration: const InputDecoration(labelText: 'Longevity formula')),
                const SizedBox(height: 8),
                TextField(controller: refCombatCtrl, decoration: const InputDecoration(labelText: 'Refractory combat formula')),
                const SizedBox(height: 8),
                TextField(controller: refCourtCtrl, decoration: const InputDecoration(labelText: 'Refractory courtship formula')),
              ],
            ),
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

    final dao = ref.read(prototypeDaoProvider);
    if (dao == null) return;

    final existing = await dao.getAll();
    await dao.add(PrototypesCompanion.insert(
      name: name,
      sex: sex,
      longevityFormula: Value(longevityCtrl.text.trim()),
      refractoryCombatFormula: Value(refCombatCtrl.text.trim()),
      refractoryCourtshipFormula: Value(refCourtCtrl.text.trim()),
      sortOrder: Value(existing.length + 1),
    ));
  }
}

class _PrototypeTile extends ConsumerWidget {
  const _PrototypeTile({required this.prototype});

  final Prototype prototype;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMale = prototype.sex == 'M';
    return Card(
      child: ListTile(
        leading: Icon(
          isMale ? Icons.male : Icons.female,
          color: isMale ? Colors.blue : Colors.pink,
          size: 32,
        ),
        title: Text(prototype.name),
        subtitle: Text(
          'Longevity: ${prototype.longevityFormula} | '
          'Combat ref: ${prototype.refractoryCombatFormula} | '
          'Court ref: ${prototype.refractoryCourtshipFormula}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: () async {
            final dao = ref.read(prototypeDaoProvider);
            await dao?.remove(prototype.id);
          },
        ),
      ),
    );
  }
}
