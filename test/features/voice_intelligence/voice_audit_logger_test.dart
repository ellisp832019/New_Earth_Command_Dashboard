import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/application/voice_module_providers.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/voice_audit_log_repository.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/voice_models.dart';

Future<void> _waitForCondition(
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final startedAt = DateTime.now();

  while (true) {
    if (await condition()) {
      return;
    }

    if (DateTime.now().difference(startedAt) > timeout) {
      throw TestFailure('Timed out waiting for condition.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  test('voice audit repository saves and loads a payload round trip', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = VoiceAuditLogRepository(database);
    await repository.savePersistedLogPayload(
      repository.encodePayload({
        'entries': [
          {
            'id': 'voice-audit-1',
            'timestamp': DateTime(2026, 6, 10, 10).toIso8601String(),
            'section': 'Voice Notes',
            'userText': 'Capture a calm note.',
            'intent': 'voice.note.create',
            'safetyDecision': {
              'allowed': true,
              'riskLevel': 'low',
              'requiresConfirmation': false,
              'reason': 'Safe local capture.',
            },
            'resultSummary': 'Saved the note locally.',
          },
        ],
      }),
    );

    final loaded = await repository.loadPersistedLogPayload();

    expect(loaded, isNotNull);
    expect(
      repository.decodePayload(loaded!),
      containsPair('entries', isNotEmpty),
    );
  });

  test('voice audit logger restores recorded entries from SQLite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final firstContainer = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(firstContainer.dispose);

    final logger = firstContainer.read(voiceAuditLoggerProvider.notifier);
    logger.record(
      VoiceAuditEntry(
        id: 'voice-audit-2',
        timestamp: DateTime(2026, 6, 10, 10, 30),
        section: 'Dashboard Assistant',
        userText: 'What is the safest next move?',
        intent: 'dashboard.assistant.reply',
        safetyDecision: const SafetyDecision(
          allowed: true,
          riskLevel: VoiceRiskLevel.low,
          requiresConfirmation: false,
          reason: 'Mock assistant reply is safe.',
        ),
        resultSummary: 'Use the next gentle step.',
      ),
    );

    final repository = VoiceAuditLogRepository(database);
    await _waitForCondition(
      () async => await repository.loadPersistedLogPayload() != null,
    );

    final secondContainer = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(secondContainer.dispose);

    await _waitForCondition(() async {
      final currentEntries = secondContainer.read(voiceAuditLoggerProvider);
      return currentEntries.isNotEmpty;
    });

    final restoredEntries = secondContainer.read(voiceAuditLoggerProvider);

    expect(restoredEntries, hasLength(1));
    expect(restoredEntries.single.id, 'voice-audit-2');
    expect(restoredEntries.single.section, 'Dashboard Assistant');
    expect(restoredEntries.single.resultSummary, 'Use the next gentle step.');
  });
}
