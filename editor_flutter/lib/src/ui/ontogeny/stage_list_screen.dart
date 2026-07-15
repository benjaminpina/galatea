import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Screen for managing immature life stages.
class StageListScreen extends ConsumerWidget {
  const StageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stages = ref.watch(stagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Stages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add stage',
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: stages.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No stages defined. Tap + to add one.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) => _StageTile(stage: list[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final cyclesCtrl = TextEditingController(text: '100');
    final cond1Ctrl = TextEditingController(text: '0');
    final cond1OpCtrl = TextEditingController(text: '>');
    final cond1ValCtrl = TextEditingController(text: '0');
    var logicCyclesReqs = 'AND';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Stage'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
                const SizedBox(height: 12),
                TextField(controller: cyclesCtrl, decoration: const InputDecoration(labelText: 'Cycles formula')),
                const SizedBox(height: 12),
                TextField(controller: cond1Ctrl, decoration: const InputDecoration(labelText: 'Condition 1 formula')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: cond1OpCtrl, decoration: const InputDecoration(labelText: 'Operator'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: cond1ValCtrl, decoration: const InputDecoration(labelText: 'Threshold'), keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: logicCyclesReqs,
                  decoration: const InputDecoration(labelText: 'Cycles ↔ Requirements logic'),
                  items: const [
                    DropdownMenuItem(value: 'AND', child: Text('AND')),
                    DropdownMenuItem(value: 'OR', child: Text('OR')),
                  ],
                  onChanged: (v) => setState(() => logicCyclesReqs = v ?? 'AND'),
                ),
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

    final dao = ref.read(stageDaoProvider);
    if (dao == null) return;

    final existing = await dao.getAll();
    await dao.add(StagesCompanion.insert(
      name: name,
      sortOrder: Value(existing.length + 1),
      cyclesFormula: Value(cyclesCtrl.text.trim()),
      condition1Formula: Value(cond1Ctrl.text.trim()),
      condition1Op: Value(cond1OpCtrl.text.trim()),
      condition1Value: Value(double.tryParse(cond1ValCtrl.text) ?? 0),
      logicCyclesReqs: Value(logicCyclesReqs),
    ));
  }
}

class _StageTile extends ConsumerWidget {
  const _StageTile({required this.stage});

  final Stage stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(stage.color),
          child: Text('${stage.sortOrder}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(stage.name),
        subtitle: Text(
          'Cycles: ${stage.cyclesFormula} | '
          'Logic: ${stage.logicCyclesReqs}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: () async {
            final dao = ref.read(stageDaoProvider);
            await dao?.remove(stage.id);
          },
        ),
      ),
    );
  }
}
