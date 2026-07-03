import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_knowledge_engine/data/omega_knowledge_engine_service.dart';
import 'package:new_earth_command_dashboard/features/omega_knowledge_engine/presentation/omega_knowledge_engine_terminal_dialog.dart';

void main() {
  testWidgets(
    'omega knowledge engine terminal opens in idle and stable state',
    (tester) async {
      final service = _FakeOmegaKnowledgeEngineService(
        snapshot: _snapshot(),
        result: _result(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    showOmegaKnowledgeEngineTerminalDialog(
                      context: context,
                      service: service,
                      snapshot: service.snapshot,
                    );
                  },
                  child: const Text('Open terminal'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open terminal'));
      await tester.pumpAndSettle();

      expect(find.text('Idle and stable'), findsWidgets);
      expect(find.text('Run scan'), findsOneWidget);
      expect(find.text('Copy terminal output'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('omega knowledge engine terminal shows live scan output', (
    tester,
  ) async {
    final service = _FakeOmegaKnowledgeEngineService(
      snapshot: _snapshot(),
      result: _result(),
      scanDelay: const Duration(milliseconds: 80),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  showOmegaKnowledgeEngineTerminalDialog(
                    context: context,
                    service: service,
                    snapshot: service.snapshot,
                    autoStartScan: true,
                  );
                },
                child: const Text('Open terminal'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open terminal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Scanning'), findsWidgets);
    expect(find.text('Scan starting...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpAndSettle();

    expect(find.textContaining('Scan complete.'), findsWidgets);
    expect(find.text('Idle and stable.'), findsWidgets);
    expect(find.text('Run again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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
    onOutputLine?.call('> ${snapshot.scanCommand}');
    onOutputLine?.call('Scanning repository index...');
    await Future<void>.delayed(scanDelay);
    onOutputLine?.call('Scan complete.');
    return result;
  }
}
