import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _recentProjectsKey = 'recent_projects';
const _lastDirectoryKey = 'last_directory';
const _maxRecentProjects = 10;

/// Represents a recent project entry.
class RecentProject {
  final String path;
  final String name;

  RecentProject({required this.path, required this.name});
}

/// Service for persisting recent projects and last-used directory.
class RecentProjectsService {
  final SharedPreferences _prefs;

  RecentProjectsService(this._prefs);

  /// Get the list of recent projects (most recent first).
  /// Filters out projects whose files no longer exist.
  List<RecentProject> getRecentProjects() {
    final paths = _prefs.getStringList(_recentProjectsKey) ?? [];
    final result = <RecentProject>[];

    for (final path in paths) {
      if (File(path).existsSync()) {
        // Extract project name from file name (without .db extension).
        final fileName = path.split(Platform.pathSeparator).last;
        final name = fileName.endsWith('.db')
            ? fileName.substring(0, fileName.length - 3)
            : fileName;
        result.add(RecentProject(path: path, name: name));
      }
    }

    return result;
  }

  /// Add a project path to the recent list (moves to top if already present).
  Future<void> addRecentProject(String path) async {
    final paths = _prefs.getStringList(_recentProjectsKey) ?? [];

    // Remove if already in list (will be re-added at top).
    paths.remove(path);

    // Add at the beginning.
    paths.insert(0, path);

    // Trim to max size.
    if (paths.length > _maxRecentProjects) {
      paths.removeRange(_maxRecentProjects, paths.length);
    }

    await _prefs.setStringList(_recentProjectsKey, paths);
  }

  /// Remove a project from the recent list.
  Future<void> removeRecentProject(String path) async {
    final paths = _prefs.getStringList(_recentProjectsKey) ?? [];
    paths.remove(path);
    await _prefs.setStringList(_recentProjectsKey, paths);
  }

  /// Get the last directory used for opening/saving projects.
  String? getLastDirectory() {
    return _prefs.getString(_lastDirectoryKey);
  }

  /// Save the last directory used.
  Future<void> setLastDirectory(String dir) async {
    await _prefs.setString(_lastDirectoryKey, dir);
  }
}

/// Provider for SharedPreferences (must be initialized before app starts).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden with actual SharedPreferences');
});

/// Provider for the RecentProjectsService.
final recentProjectsServiceProvider = Provider<RecentProjectsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RecentProjectsService(prefs);
});

/// Provider that exposes the current list of recent projects (reactive).
final recentProjectsProvider = StateProvider<List<RecentProject>>((ref) {
  final service = ref.watch(recentProjectsServiceProvider);
  return service.getRecentProjects();
});
