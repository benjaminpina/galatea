import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import 'home_screen.dart';
import 'environment/environment_editor_screen.dart';

class GalateaStudioApp extends StatelessWidget {
  const GalateaStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galatea Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _AppRouter(),
    );
  }
}

/// Routes between the home screen (no workspace) and the environment editor.
///
/// When a workspace is open, auto-creates a default environment if none exists,
/// then navigates directly to the editor canvas.
class _AppRouter extends ConsumerStatefulWidget {
  const _AppRouter();

  @override
  ConsumerState<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<_AppRouter> {
  int? _environmentId;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final workspacePath = ref.watch(workspacePathProvider);

    if (workspacePath == null) {
      // Reset when project is closed.
      _environmentId = null;
      return const HomeScreen();
    }

    // If we already resolved the environment, show the editor.
    if (_environmentId != null) {
      return EnvironmentEditorScreen(environmentId: _environmentId!);
    }

    // Otherwise, resolve (or create) the environment.
    if (!_loading) {
      _loading = true;
      _resolveEnvironment();
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Future<void> _resolveEnvironment() async {
    final envDao = ref.read(environmentDaoProvider);
    if (envDao == null) return;

    var envs = await envDao.getAll();

    if (envs.isEmpty) {
      // Auto-create a default environment for new projects.
      await envDao.add('Main', 50, 50, '');
      envs = await envDao.getAll();
    }

    if (mounted && envs.isNotEmpty) {
      setState(() {
        _environmentId = envs.first.id;
        _loading = false;
      });
    }
  }
}
