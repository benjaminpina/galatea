import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';
import 'prototype_edit_screen.dart';
import 'stage_edit_screen.dart';

/// Right panel for the "Agents" config section.
/// Shows: Genetics (loci), Life Stages, Prototypes (M/F), and a
/// placeholder for interaction matrices.
class AgentsPanel extends ConsumerWidget {
  const AgentsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loci = ref.watch(lociProvider).valueOrNull ?? [];
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final males = prototypes.where((p) => p.sex == 'M').toList();
    final females = prototypes.where((p) => p.sex == 'F').toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // --- Genetics (Loci) ---
        _SectionHeader(
          title: 'Genetics (Loci)',
          icon: Icons.biotech,
          count: loci.length,
          onAdd: () => _addLocus(context, ref),
        ),
        if (loci.isEmpty)
          _emptyHint('No loci defined.')
        else
          ...loci.map((l) => _LocusTile(locus: l)),
        const SizedBox(height: 16),

        // --- Life Stages ---
        _SectionHeader(
          title: 'Life Stages',
          icon: Icons.timeline,
          count: stages.length,
          onAdd: () => _addStage(context, ref),
        ),
        if (stages.isEmpty)
          _emptyHint('No stages defined.')
        else
          ...stages.map((s) => _StageTile(stage: s)),
        const SizedBox(height: 16),

        // --- Prototypes: Males ---
        _SectionHeader(
          title: 'Prototypes (Male)',
          icon: Icons.male,
          count: males.length,
          onAdd: () => _addPrototype(context, ref, 'M'),
        ),
        if (males.isEmpty)
          _emptyHint('No male prototypes.')
        else
          ...males.map((p) => _PrototypeTile(prototype: p)),
        const SizedBox(height: 12),

        // --- Prototypes: Females ---
        _SectionHeader(
          title: 'Prototypes (Female)',
          icon: Icons.female,
          count: females.length,
          onAdd: () => _addPrototype(context, ref, 'F'),
        ),
        if (females.isEmpty)
          _emptyHint('No female prototypes.')
        else
          ...females.map((p) => _PrototypeTile(prototype: p)),
        const SizedBox(height: 16),

        // --- Interaction Matrices (placeholder) ---
        const _InteractionMatricesPlaceholder(),
      ],
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  // --- Creation dialogs ---

  Future<void> _addLocus(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    var isContinuous = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Locus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Continuous'),
                subtitle: Text(isContinuous ? 'Real-valued' : 'Integer-valued'),
                value: isContinuous,
                onChanged: (v) => setState(() => isContinuous = v),
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
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(locusDaoProvider);
    if (dao == null) return;
    final existing = await dao.getAll();
    await dao.add(
      LociCompanion.insert(
        name: name,
        isContinuous: Value(isContinuous),
        sortOrder: Value(existing.length + 1),
      ),
    );
  }

  Future<void> _addStage(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Life Stage'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
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
    );
    if (result != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(stageDaoProvider);
    if (dao == null) return;
    final existing = await dao.getAll();
    await dao.add(
      StagesCompanion.insert(name: name, sortOrder: Value(existing.length + 1)),
    );
  }

  Future<void> _addPrototype(
    BuildContext context,
    WidgetRef ref,
    String sex,
  ) async {
    final nameCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New ${sex == 'M' ? 'Male' : 'Female'} Prototype'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
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
    );
    if (result != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(prototypeDaoProvider);
    if (dao == null) return;
    final existing = await dao.getAll();
    await dao.add(
      PrototypesCompanion.insert(
        name: name,
        sex: sex,
        longevityFormula: const Value('200'),
        refractoryCombatFormula: const Value('20'),
        refractoryCourtshipFormula: const Value('20'),
        sexRatioMalesFormula: const Value('1'),
        sexRatioFemalesFormula: const Value('1'),
        sortOrder: Value(existing.length + 1),
      ),
    );
  }
}

// --- Section header ---

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.onAdd,
  });
  final String title;
  final IconData icon;
  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$title ($count)',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: onAdd,
          visualDensity: VisualDensity.compact,
          tooltip: 'Add',
        ),
      ],
    );
  }
}

// --- Locus tile ---

class _LocusTile extends ConsumerWidget {
  const _LocusTile({required this.locus});
  final LociData locus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(locus.name, style: const TextStyle(fontSize: 12)),
      subtitle: Text(
        locus.isContinuous ? 'Continuous' : 'Discrete',
        style: const TextStyle(fontSize: 10),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 16),
        onPressed: () async {
          final dao = ref.read(locusDaoProvider);
          await dao?.remove(locus.id);
        },
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// --- Stage tile ---

class _StageTile extends ConsumerWidget {
  const _StageTile({required this.stage});
  final Stage stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(stage.name, style: const TextStyle(fontSize: 12)),
      subtitle: Text(
        'Cycles: ${stage.cyclesFormula}',
        style: const TextStyle(fontSize: 10),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StageEditScreen(stageId: stage.id),
              ),
            ),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            onPressed: () => _confirmDelete(context, ref),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Stage'),
        content: Text('Delete "${stage.name}"?'),
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
      final dao = ref.read(stageDaoProvider);
      await dao?.remove(stage.id);
    }
  }
}

// --- Prototype tile ---

class _PrototypeTile extends ConsumerWidget {
  const _PrototypeTile({required this.prototype});
  final Prototype prototype;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Color(prototype.color),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
      ),
      title: Text(prototype.name, style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrototypeEditScreen(prototypeId: prototype.id),
              ),
            ),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            onPressed: () => _confirmDelete(context, ref),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Prototype'),
        content: Text(
          'Delete "${prototype.name}"?\n\nAll agents using this prototype will also be removed from environments.',
        ),
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
    if (confirmed != true) return;
    final envDao = ref.read(environmentDaoProvider);
    await envDao?.deleteAgentsByPrototype(prototype.id);
    final dao = ref.read(prototypeDaoProvider);
    await dao?.remove(prototype.id);
  }
}

// --- Interaction Matrices Placeholder ---

class _InteractionMatricesPlaceholder extends StatelessWidget {
  const _InteractionMatricesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.withValues(alpha: 0.08),
      ),
      child: Column(
        children: [
          Icon(Icons.grid_on, size: 32, color: Colors.orange.shade300),
          const SizedBox(height: 8),
          Text(
            'Interaction Matrices',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Substrate, Source, and Agent interaction matrices will be editable here in a future update.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.orange.shade200),
          ),
        ],
      ),
    );
  }
}
