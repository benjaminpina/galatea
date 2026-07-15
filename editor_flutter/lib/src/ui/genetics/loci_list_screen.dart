import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Screen for managing genetic loci definitions.
class LociListScreen extends ConsumerWidget {
  const LociListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loci = ref.watch(lociProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genetic Loci'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add locus',
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: loci.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No loci defined. Tap + to add one.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) => _LocusTile(locus: list[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    var isContinuous = true;
    final domValCtrl = TextEditingController(text: '1.0');
    final recValCtrl = TextEditingController(text: '0.5');
    final mutRateDomCtrl = TextEditingController(text: '0.01');
    final mutRateRecCtrl = TextEditingController(text: '0.01');
    final mutRangeDomCtrl = TextEditingController(text: '0.1');
    final mutRangeRecCtrl = TextEditingController(text: '0.1');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Locus'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(isContinuous ? 'Continuous (float)' : 'Discrete (int)'),
                  value: isContinuous,
                  onChanged: (v) => setState(() => isContinuous = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: domValCtrl, decoration: const InputDecoration(labelText: 'Dominant value'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: recValCtrl, decoration: const InputDecoration(labelText: 'Recessive value'), keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: mutRateDomCtrl, decoration: const InputDecoration(labelText: 'Mut. rate dom'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: mutRateRecCtrl, decoration: const InputDecoration(labelText: 'Mut. rate rec'), keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: mutRangeDomCtrl, decoration: const InputDecoration(labelText: 'Mut. range dom'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: mutRangeRecCtrl, decoration: const InputDecoration(labelText: 'Mut. range rec'), keyboardType: TextInputType.number)),
                ]),
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

    final dao = ref.read(locusDaoProvider);
    if (dao == null) return;

    final existing = await dao.getAll();
    await dao.add(LociCompanion.insert(
      name: name,
      isContinuous: Value(isContinuous),
      dominantValue: Value(double.tryParse(domValCtrl.text) ?? 1.0),
      recessiveValue: Value(double.tryParse(recValCtrl.text) ?? 0.5),
      mutationRateDom: Value(double.tryParse(mutRateDomCtrl.text) ?? 0.01),
      mutationRateRec: Value(double.tryParse(mutRateRecCtrl.text) ?? 0.01),
      mutationRangeDom: Value(double.tryParse(mutRangeDomCtrl.text) ?? 0.1),
      mutationRangeRec: Value(double.tryParse(mutRangeRecCtrl.text) ?? 0.1),
      sortOrder: Value(existing.length + 1),
    ));
  }
}

class _LocusTile extends ConsumerWidget {
  const _LocusTile({required this.locus});

  final LociData locus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Icon(
          locus.isContinuous ? Icons.show_chart : Icons.bar_chart,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(locus.name),
        subtitle: Text(
          '${locus.isContinuous ? "Continuous" : "Discrete"} | '
          'Dom: ${locus.dominantValue} Rec: ${locus.recessiveValue} | '
          'Mut: ${locus.mutationRateDom}/${locus.mutationRateRec}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: () async {
            final dao = ref.read(locusDaoProvider);
            await dao?.remove(locus.id);
          },
        ),
      ),
    );
  }
}
