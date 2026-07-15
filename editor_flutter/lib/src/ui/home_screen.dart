import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../database/database.dart';
import '../database/daos.dart';
import '../providers/database_provider.dart';

/// Home screen shown when no workspace is open.
/// Allows creating a new project or opening an existing one.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 80, color: Theme.of(context).colorScheme.primary),
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
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () => _createNewProject(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openExistingProject(context, ref),
              icon: const Icon(Icons.folder_open),
              label: const Text('Open Project'),
            ),
          ],
        ),
      ),
    );
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );

    if (result != true || !context.mounted) return;

    // Let user pick a directory for the workspace.
    final dirPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select workspace directory',
    );
    if (dirPath == null) return;

    final projectName = nameController.text.trim().isEmpty
        ? 'Untitled'
        : nameController.text.trim();
    final folderName = projectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final wsDir = p.join(dirPath, folderName);
    final dbPath = p.join(wsDir, 'galatea.db');

    // Create directory.
    await Directory(wsDir).create(recursive: true);

    // Initialize database.
    final db = AppDatabase(dbPath);
    final dao = ProjectInfoDao(db);
    await dao.init(projectName, descController.text.trim());
    await db.close();

    // Open the workspace.
    ref.read(workspacePathProvider.notifier).state = dbPath;
  }

  Future<void> _openExistingProject(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open galatea.db',
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result == null || result.files.isEmpty) return;
    final dbPath = result.files.single.path;
    if (dbPath == null) return;

    ref.read(workspacePathProvider.notifier).state = dbPath;
  }
}
