import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/native.dart';

import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/application/voice_module_providers.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/meeting_summary_service.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/microgrow_voice_status_service.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/safety_command_gateway.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/voice_assistant_service.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/voice_models.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/voice_module_preferences_repository.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/data/voice_transcription_service.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/presentation/voice_conversation_screen.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/presentation/voice_module_screen.dart';

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
  test('safety gateway blocks hardware writes and allows read-only status', () {
    const gateway = SafetyCommandGateway();

    final blocked = gateway.evaluate(
      const SafetyCommandRequest(
        rawText: 'Turn relay one on',
        intent: 'microgrow.relay.set',
      ),
    );
    final allowed = gateway.evaluate(
      const SafetyCommandRequest(
        rawText: 'What is the temperature?',
        intent: 'microgrow.status.read',
      ),
    );

    expect(blocked.allowed, isFalse);
    expect(blocked.reason, contains('disabled in V1'));
    expect(allowed.allowed, isTrue);
  });

  test('mock transcription and meeting summary return readable output', () async {
    const transcriptionService = VoiceTranscriptionService();
    const summaryService = MeetingSummaryService();

    final transcription = await transcriptionService.transcribeMock(
      mode: VoiceSessionMode.voiceNote,
      prompt: 'I reviewed the voice module and confirmed the next step.',
      config: const VoiceRuntimeConfig(
        providerMode: VoiceProviderMode.mock,
        apiKey: null,
        transcriptionModel: 'mock',
        realtimeModel: 'mock',
        ttsModel: 'mock',
      ),
    );

    final summary = await summaryService.createMockSummary(
      transcript:
          'We agreed to keep MicroGrow read-only. Peter will review the audit log next. There is no blocker.',
      meetingTitle: 'MicroGrow planning',
    );

    expect(transcription.transcript, contains('Voice note:'));
    expect(summary.summary, contains('MicroGrow planning'));
    expect(summary.actions, isNotEmpty);
    expect(summary.risks, isNotEmpty);
  });

  test(
    'mock assistant blocks relay commands and drafts safe intents',
    () async {
      const assistant = VoiceAssistantService(
        safetyGateway: SafetyCommandGateway(),
      );

      final blocked = await assistant.createMockResponse(
        message: 'Turn the relay on',
      );
      final safe = await assistant.createMockResponse(
        message: 'Create a task for tomorrow',
      );

      expect(blocked.safetyDecision.allowed, isFalse);
      expect(safe.safetyDecision.allowed, isTrue);
      expect(safe.actions, isNotEmpty);
    },
  );

  test('mock MicroGrow status returns read-only data', () async {
    const statusService = MicroGrowVoiceStatusService();

    final status = await statusService.readMockStatus(
      query: 'What are the relays currently doing?',
    );

    expect(status.nodeOnline, isTrue);
    expect(status.relays, isNotEmpty);
    expect(status.querySummary, contains('read-only'));
  });

  testWidgets('voice module routes open the new home page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    container.read(voiceConversationThreadProvider.notifier).rememberThread(
          threadTitle: 'Dashboard Assistant',
          summary: 'We are continuing the shared voice thread.',
          nextStep: 'Resume the latest saved step.',
          resumeRoute: RouteNames.voiceConversation,
          latestCaptureLabel: 'Assistant request',
          latestCapturePreview: 'What is the safest next move?',
          lastThingYouSaid: 'What is the safest next move?',
        );

    final router = GoRouter(
      initialLocation: RouteNames.voice,
      routes: [
        GoRoute(
          path: RouteNames.voice,
          redirect: (context, state) {
            if (state.uri.queryParameters['view'] == 'home') {
              return null;
            }

            return RouteNames.voiceConversation;
          },
          builder: (context, state) =>
              const VoiceModuleScreen(section: VoiceModuleSection.home),
        ),
        GoRoute(
          path: RouteNames.voiceConversation,
          builder: (context, state) => const VoiceConversationScreen(),
        ),
        GoRoute(
          path: RouteNames.voiceNotes,
          builder: (context, state) =>
              const VoiceModuleScreen(section: VoiceModuleSection.notes),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(VoiceConversationScreen), findsOneWidget);
    expect(find.byKey(const Key('voiceConversationReplyBox')), findsOneWidget);

    router.go(RouteNames.voiceHome());
    await tester.pumpAndSettle();

    expect(find.text('Voice Home'), findsAtLeastNWidgets(1));
    expect(find.text('Shared voice session idle'), findsOneWidget);
    expect(find.text('Voice Notes'), findsWidgets);
    expect(find.byTooltip('Back'), findsOneWidget);

    router.go(RouteNames.voiceConversation);
    await tester.pumpAndSettle();

    expect(find.byType(VoiceConversationScreen), findsOneWidget);
    expect(find.byKey(const Key('voiceConversationReplyBox')), findsOneWidget);

    router.go(RouteNames.voiceNotes);
    await tester.pumpAndSettle();

    expect(find.text('Voice Notes'), findsWidgets);
    expect(find.text('Start Recording'), findsOneWidget);
  });

  testWidgets('voice audit entries can jump back to the matching route', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: RouteNames.voiceAudit,
      routes: [
        GoRoute(
          path: RouteNames.voice,
          redirect: (context, state) {
            if (state.uri.queryParameters['view'] == 'home') {
              return null;
            }

            return RouteNames.voiceConversation;
          },
          builder: (context, state) =>
              const VoiceModuleScreen(section: VoiceModuleSection.home),
        ),
        GoRoute(
          path: RouteNames.voiceConversation,
          builder: (context, state) => const VoiceConversationScreen(),
        ),
        GoRoute(
          path: RouteNames.voiceAudit,
          builder: (context, state) =>
              const VoiceModuleScreen(section: VoiceModuleSection.audit),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    container.read(voiceAuditLoggerProvider.notifier).record(
      VoiceAuditEntry(
        id: 'audit-1',
        timestamp: DateTime(2026, 6, 10, 12),
        section: 'Voice Conversation',
        userText: 'What should I do next?',
        intent: 'dashboard.assistant.reply',
        safetyDecision: const SafetyDecision(
          allowed: true,
          riskLevel: VoiceRiskLevel.low,
          requiresConfirmation: false,
          reason: 'Mock assistant reply is safe.',
        ),
        resultSummary: 'Continue the calm thread.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search and filters'), findsOneWidget);
    expect(
      find.byKey(const Key('voiceAuditJumpBackLatestButton')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('voiceAuditJumpBackLatestButton')));
    await tester.pumpAndSettle();

    expect(find.byType(VoiceConversationScreen), findsOneWidget);
  });

  test('voice provider mode and feature flags persist locally', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final firstContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(firstContainer.dispose);

    firstContainer.read(voiceProviderModeProvider.notifier).setMode(
          VoiceProviderMode.openAi,
        );
    firstContainer.read(voiceFeatureFlagsProvider.notifier).update(
          const VoiceFeatureFlags(
            voiceNotesEnabled: false,
            meetingTranscriberEnabled: true,
            dashboardAssistantEnabled: true,
            microgrowReadOnlyEnabled: true,
            microgrowVoiceControlEnabled: false,
            alwaysOnWakeWordEnabled: true,
            cloudSyncVoiceLogsEnabled: false,
          ),
        );

    final repository = VoiceModulePreferencesRepository(database);
    await _waitForCondition(
      () async => await repository.loadPreferences() != null,
    );

    final secondContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(secondContainer.dispose);

    await _waitForCondition(() async {
      final currentMode = secondContainer.read(voiceProviderModeProvider);
      final currentFlags = secondContainer.read(voiceFeatureFlagsProvider);
      return currentMode == VoiceProviderMode.openAi &&
          currentFlags.voiceNotesEnabled == false &&
          currentFlags.alwaysOnWakeWordEnabled == true;
    });

    expect(secondContainer.read(voiceProviderModeProvider), VoiceProviderMode.openAi);
    expect(secondContainer.read(voiceFeatureFlagsProvider).voiceNotesEnabled, isFalse);
    expect(
      secondContainer.read(voiceFeatureFlagsProvider).alwaysOnWakeWordEnabled,
      isTrue,
    );
  });
}
