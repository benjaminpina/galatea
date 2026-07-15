import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';

/// Main workspace screen shown when a project is open.
/// Displays navigation to all editors (nutrients, substrates, prototypes, etc.).
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
                  ),
                  _SummaryCard(
                    icon: Icons.biotech,
                    label: 'Loci',
                    count: loci.valueOrNull?.length ?? 0,
                  ),
                  _SummaryCard(
                    icon: Icons.timeline,
                    label: 'Stages',
                    count: stages.valueOrNull?.length ?? 0,
                  ),
                  _SummaryCard(
                    icon: Icons.person,
                    label: 'Prototypes',
                    count: prototypes.valueOrNull?.length ?? 0,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to entity editor.
        },
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
