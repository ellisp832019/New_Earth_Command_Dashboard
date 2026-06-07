import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../../../core/database/app_database.dart';
import '../../command_deck/data/command_deck_service.dart';
import '../data/dashboard_repository.dart';

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((
  ref,
) async {
  await ref.watch(databaseReadyProvider.future);
  final database = ref.watch(appDatabaseProvider);

  return DashboardRepository(database).loadTodaySnapshot();
});

final commandPaletteRecentActionsProvider =
    Provider<List<CommandDeckActionLogEntry>>((ref) {
      final moduleRoot = _commandDeckModuleRoot(Directory.current);
      final logFile = File(
        path.join(
          moduleRoot.path,
          'dashboard_module',
          'data',
          'runtime',
          'command_deck_action_log.jsonl',
        ),
      );

      if (!logFile.existsSync()) {
        return const [];
      }

      final lines = logFile.readAsLinesSync();
      final entries = <CommandDeckActionLogEntry>[];
      for (final line in lines.reversed) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          continue;
        }

        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map<String, dynamic>) {
            entries.add(CommandDeckActionLogEntry.fromJson(decoded));
          }
        } catch (_) {
          // Keep the recent actions panel usable if one line is malformed.
        }

        if (entries.length == 6) {
          break;
        }
      }

      return entries;
    });

Directory _commandDeckModuleRoot(Directory workingDirectory) {
  var current = workingDirectory;
  while (true) {
    final candidate = Directory(
      path.join(current.path, 'modules', 'new_earth_command_deck'),
    );
    if (candidate.existsSync()) {
      return candidate;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      break;
    }
    current = parent;
  }

  return Directory(
    path.join(workingDirectory.path, 'modules', 'new_earth_command_deck'),
  );
}
