import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../exchange/exporter.dart';
import '../exchange/importer.dart';
import '../providers/database_provider.dart';
import 'genetics/loci_list_screen.dart';
import 'ontogeny/stage_list_screen.dart';
import 'prototypes/prototype_list_screen.dart';
import 'substrates/substrate_list_screen.dart';
import 'substrates/map_editor_screen.dart';

/// Main workspace screen shown when a project is open.
class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrients = ref.watch(nutrientsProvider);
    final substrates = ref.watch(substratesProvider);
    final loci = ref.watch(lociProvider);
    final stages = ref.watch(stagesProvider);
    final prototypes = ref.watch(prototypesProvider);
    final resourceTypes = ref.watch(resourceTypesProvider);
    final environments = ref.watch(environmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galatea Studio'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Export',
            onSelected: (value) => _export(context, ref, value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'substrates',
                child: Text('Export Substrates'),
              ),
              PopupMenuItem(value: 'loci', child: Text('Export Loci')),
              PopupMenuItem(
                value: 'prototypes',
                child: Text('Export Prototypes'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Import',
            onSelected: (value) => _import(context, ref, value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'substrates',
                child: Text('Import Substrates'),
              ),
              PopupMenuItem(value: 'loci', child: Text('Import Loci')),
              PopupMenuItem(
                value: 'prototypes',
                child: Text('Import Prototypes'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close project',
            onPressed: () {
              ref.read(workspacePathProvider.notifier).state = null;
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _SummaryCard(
                    icon: Icons.water_drop,
                    label: 'Nutrients',
                    count: nutrients.valueOrNull?.length ?? 0,
                  ),
                  _SummaryCard(
                    icon: Icons.terrain,
                    label: 'Substrates',
                    count: substrates.valueOrNull?.length ?? 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SubstrateListScreen(),
                      ),
                    ),
                  ),
                  _SummaryCard(
                    icon: Icons.biotech,
                    label: 'Loci',
                    count: loci.valueOrNull?.length ?? 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LociListScreen()),
                    ),
                  ),
                  _SummaryCard(
                    icon: Icons.timeline,
                    label: 'Stages',
                    count: stages.valueOrNull?.length ?? 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StageListScreen(),
                      ),
                    ),
                  ),
                  _SummaryCard(
                    icon: Icons.person,
                    label: 'Prototypes',
                    count: prototypes.valueOrNull?.length ?? 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrototypeListScreen(),
                      ),
                    ),
                  ),
                  _SummaryCard(
                    icon: Icons.park,
                    label: 'Resource Types',
                    count: resourceTypes.valueOrNull?.length ?? 0,
                  ),
                  _SummaryCard(
                    icon: Icons.map,
                    label: 'Environments',
                    count: environments.valueOrNull?.length ?? 0,
                    onTap: () => _openMapEditor(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _export(BuildContext context, WidgetRef ref, String type) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export $type',
      fileName: '${type}_export.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (outputPath == null) return;

    final exporter = JsonExporter(db);
    switch (type) {
      case 'substrates':
        await exporter.exportSubstrates(outputPath);
      case 'loci':
        await exporter.exportLoci(outputPath);
      case 'prototypes':
        await exporter.exportPrototypes(outputPath);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported $type to $outputPath')));
    }
  }

  void _import(BuildContext context, WidgetRef ref, String type) async {
    final db = ref.read(databaseProvider);
    if (db == null) return;

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import $type',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path;
    if (filePath == null) return;

    final importer = JsonImporter(db);
    ImportResult importResult;
    switch (type) {
      case 'substrates':
        importResult = await importer.importSubstrates(filePath);
      case 'loci':
        importResult = await importer.importLoci(filePath);
      case 'prototypes':
        importResult = await importer.importPrototypes(filePath);
      default:
        return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import: $importResult')));
    }
  }

  void _openMapEditor(BuildContext context, WidgetRef ref) {
    final envs = ref.read(environmentsProvider).valueOrNull;
    if (envs == null || envs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create an environment first.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapEditorScreen(environmentId: envs.first.id),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    '$count defined',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
