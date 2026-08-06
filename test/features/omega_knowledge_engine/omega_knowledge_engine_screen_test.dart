import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/omega_knowledge_engine/data/omega_knowledge_engine_service.dart';
import 'package:new_earth_command_dashboard/features/omega_knowledge_engine/presentation/omega_knowledge_engine_screen.dart';

void main() {
  testWidgets(
    'omega knowledge engine overview keeps the terminal dock visible',
    (tester) async {
      final service = _FakeOmegaKnowledgeEngineService(
        snapshot: _snapshot(),
        result: _result(),
        scanDelay: const Duration(milliseconds: 80),
      );

      final router = GoRouter(
        initialLocation: RouteNames.omegaKnowledgeEngine,
        routes: [
          GoRoute(
            path: RouteNames.omegaKnowledgeEngine,
            builder: (context, state) =>
                OmegaKnowledgeEngineScreen(service: service),
          ),
        ],
      );

      tester.view.physicalSize = const Size(1600, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Terminal'), findsWidgets);
      expect(find.textContaining('idle and stable'), findsWidgets);
      expect(
        find.byKey(const Key('omegaTerminalRunScanButton')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('omegaTerminalRunScanButton')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Scanning'), findsWidgets);
      expect(find.text('Scan starting...'), findsWidgets);

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

OmegaKnowledgeEngineSnapshot _snapshot() {
  final tempRoot = Directory.systemTemp.path;
  final settings = OmegaKnowledgeEngineSettings.defaults(
    moduleRootPath: tempRoot,
  );

  return OmegaKnowledgeEngineSnapshot(
    settings: settings,
    repositoryIndexText: '# Repository Index\n',
    repositoryIndexJson: const {
      'generated_at': '2026-07-03T14:54:26',
      'repository_count': 5,
      'files_scanned': 763,
    },
    learningNotesText: '# Learning Notes\n',
    commentSuggestionsText: '# Comment Suggestions\n',
    architectureMapText: '# Architecture Map\n',
    projectMemoryText: '# Project Memory\n',
    obsidianExportFiles: const ['alpha.md', 'beta.md'],
    generatedAt: '2026-07-03T14:54:26',
    repositoryCount: 5,
    filesScanned: 763,
    scanCommand:
        'python scripts/omega_scan.py --config config/engine_config.yaml',
  );
}

OmegaKnowledgeEngineRunResult _result() {
  final startedAt = DateTime(2026, 7, 3, 14, 54, 26);
  return OmegaKnowledgeEngineRunResult(
    exitCode: 0,
    command: 'python scripts/omega_scan.py --config config/engine_config.yaml',
    stdout: 'Scanning repository index...\nScan complete.\n',
    stderr: '',
    startedAt: startedAt,
    finishedAt: startedAt.add(const Duration(seconds: 3)),
  );
}

class _FakeOmegaKnowledgeEngineService extends OmegaKnowledgeEngineService {
  _FakeOmegaKnowledgeEngineService({
    required this.snapshot,
    required this.result,
    this.scanDelay = Duration.zero,
  }) : super(moduleRootPath: Directory.systemTemp.path);

  final OmegaKnowledgeEngineSnapshot snapshot;
  final OmegaKnowledgeEngineRunResult result;
  final Duration scanDelay;

  @override
  Future<OmegaKnowledgeEngineSnapshot> loadSnapshot() async {
    return snapshot;
  }

  @override
  Future<OmegaKnowledgeEngineRunResult> runScan({
    OmegaKnowledgeEngineSettings? settings,
    void Function(String line)? onOutputLine,
  }) async {
    onOutputLine?.call('Scanning repository index...');
    await Future<void>.delayed(scanDelay);
    onOutputLine?.call('Scan complete.');
    return result;
  }
}
