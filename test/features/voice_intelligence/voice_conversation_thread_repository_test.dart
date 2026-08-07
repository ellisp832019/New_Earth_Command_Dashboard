import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/application/voice_module_providers.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/application/voice_thread_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/voice_conversation_thread_repository.dart';

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
  test(
    'voice thread repository saves and loads a payload round trip',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = VoiceConversationThreadRepository(database);
      final payload = repository.encodePayload({
        'threadTitle': 'Voice Conversation',
        'summary': 'A calm, shared thread.',
        'conversationEntries': [
          {
            'id': 'message-1',
            'kind': 'assistant',
            'body': 'Ready when you are.',
            'timestamp': DateTime(2026, 6, 10, 9, 15).toIso8601String(),
          },
        ],
      });

      await repository.savePersistedThreadPayload(payload);

      final loaded = await repository.loadPersistedThreadPayload();

      expect(loaded, isNotNull);
      expect(
        repository.decodePayload(loaded!),
        containsPair('threadTitle', 'Voice Conversation'),
      );
      expect(
        repository.decodePayload(loaded)['summary'],
        'A calm, shared thread.',
      );
    },
  );

  test(
    'voice thread controller restores the shared thread from SQLite',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final firstContainer = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(firstContainer.dispose);

      final controller = firstContainer.read(
        voiceConversationThreadProvider.notifier,
      );
      controller.rememberThread(
        threadTitle: 'Dashboard Assistant',
        summary: 'We are continuing the dashboard conversation.',
        nextStep: 'Keep the thread calm and review-first.',
        resumeRoute: RouteNames.voiceConversation,
        latestCaptureLabel: 'Assistant request',
        latestCapturePreview: 'What is the safest next move?',
        lastThingYouSaid: 'What is the safest next move?',
        prompts: const [
          VoiceConversationPrompt(
            label: 'Continue',
            description: 'Keep the conversation flowing.',
            route: RouteNames.voiceConversation,
          ),
        ],
      );
      controller.appendAssistantMessage(
        'Use the next gentle step and keep hardware writes blocked.',
        title: 'Dashboard reply',
        intent: 'dashboard.assistant.reply',
      );

      final writerRepository = VoiceConversationThreadRepository(database);
      await _waitForCondition(
        () async => await writerRepository.loadPersistedThreadPayload() != null,
      );

      final secondContainer = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(secondContainer.dispose);

      await _waitForCondition(() async {
        final currentState = secondContainer.read(
          voiceConversationThreadProvider,
        );
        return currentState.threadTitle == 'Dashboard Assistant' &&
            currentState.conversationEntries.isNotEmpty;
      });

      final hydratedState = secondContainer.read(
        voiceConversationThreadProvider,
      );

      expect(hydratedState.threadTitle, 'Dashboard Assistant');
      expect(
        hydratedState.summary,
        'We are continuing the dashboard conversation.',
      );
      expect(hydratedState.resumeRoute, RouteNames.voiceConversation);
      expect(hydratedState.lastThingYouSaid, 'What is the safest next move?');
      expect(hydratedState.prompts, hasLength(1));
      expect(hydratedState.conversationEntries, isNotEmpty);
      expect(
        hydratedState.conversationEntries.last.body,
        'Use the next gentle step and keep hardware writes blocked.',
      );
      expect(hydratedState.pinnedTurnTitle, isNull);
    },
  );
}
