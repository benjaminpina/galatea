import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../database/database.dart';
import '../database/daos.dart';
import '../providers/database_provider.dart';
import '../services/recent_projects.dart';

/// Home screen shown when no workspace is open.
/// Shows recent projects and allows creating/opening projects.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentProjects = ref.watch(recentProjectsProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.science,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Galatea Studio',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Simulation Scenario Editor',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => _createNewProject(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('New Project'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => _openExistingProject(context, ref),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Open Project'),
                  ),
                ],
              ),
              if (recentProjects.isNotEmpty) ...[
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Projects',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: recentProjects.length,
                    itemBuilder: (context, index) {
                      final project = recentProjects[index];
                      return ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(project.name),
                        subtitle: Text(
                          project.path,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Remove from list',
                          onPressed: () =>
                              _removeFromRecents(ref, project.path),
                        ),
                        onTap: () => _openProject(ref, project.path),
                      );
                    },
                  ),
                ),
              ] else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _openProject(WidgetRef ref, String dbPath) {
    final service = ref.read(recentProjectsServiceProvider);
    service.addRecentProject(dbPath);
    service.setLastDirectory(p.dirname(dbPath));
    ref.read(recentProjectsProvider.notifier).state = service
        .getRecentProjects();
    ref.read(workspacePathProvider.notifier).state = dbPath;
  }

  void _removeFromRecents(WidgetRef ref, String path) {
    final service = ref.read(recentProjectsServiceProvider);
    service.removeRecentProject(path);
    ref.read(recentProjectsProvider.notifier).state = service
        .getRecentProjects();
  }

  Future<void> _createNewProject(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: 'New Simulation');
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
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
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;

    final service = ref.read(recentProjectsServiceProvider);
    final lastDir = service.getLastDirectory();

    final dirPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select directory to save project',
      initialDirectory: lastDir,
    );
    if (dirPath == null) return;

    final projectName = nameController.text.trim().isEmpty
        ? 'Untitled'
        : nameController.text.trim();
    final fileName = projectName.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    final dbPath = p.join(dirPath, '$fileName.db');

    // Initialize database.
    final db = AppDatabase(dbPath);
    final dao = ProjectInfoDao(db);
    await dao.init(projectName, descController.text.trim());
    await db.close();

    // Remember directory and add to recents.
    await service.setLastDirectory(dirPath);
    await service.addRecentProject(dbPath);
    ref.read(recentProjectsProvider.notifier).state = service
        .getRecentProjects();

    // Open the workspace.
    if (context.mounted) {
      ref.read(workspacePathProvider.notifier).state = dbPath;
    }
  }

  Future<void> _openExistingProject(BuildContext context, WidgetRef ref) async {
    final service = ref.read(recentProjectsServiceProvider);
    final lastDir = service.getLastDirectory();

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open project database',
      type: FileType.custom,
      allowedExtensions: ['db'],
      initialDirectory: lastDir,
    );

    if (result == null || result.files.isEmpty) return;
    final dbPath = result.files.single.path;
    if (dbPath == null) return;

    // Remember directory and add to recents.
    await service.setLastDirectory(p.dirname(dbPath));
    await service.addRecentProject(dbPath);
    ref.read(recentProjectsProvider.notifier).state = service
        .getRecentProjects();

    ref.read(workspacePathProvider.notifier).state = dbPath;
  }
}
