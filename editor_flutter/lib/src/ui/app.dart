import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import 'home_screen.dart';
import 'workspace_screen.dart';

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

/// Routes between the home screen (no workspace) and workspace screen.
class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspacePath = ref.watch(workspacePathProvider);
    if (workspacePath == null) {
      return const HomeScreen();
    }
    return const WorkspaceScreen();
  }
}
