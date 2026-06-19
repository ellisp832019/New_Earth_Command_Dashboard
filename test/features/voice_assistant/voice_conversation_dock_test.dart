import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/settings/application/settings_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_conversation_dock_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/widgets/voice_conversation_dock.dart';

void main() {
  testWidgets('voice conversation dock shows conversation state', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: VoiceConversationDock())),
      ),
    );

    container
        .read(voiceConversationDockProvider.notifier)
        .show(
          title: 'Assistant',
          summary: 'I am here and ready to help.',
          nextStep:
              'Say create a task, create a project, or ask what I can do.',
          transcript: 'Hey Gaia create a project for the dashboard',
          isWake: true,
          projectContext: 'MicroGrow',
          threadContext: 'MicroGrow · Project · Dashboard voice workflow',
          conversationContext: const VoiceConversationContext(
            label: 'Project',
            summary: 'Dashboard voice workflow',
            type: VoiceCommandType.project,
            projectName: 'MicroGrow',
            title: 'Dashboard voice workflow',
            transcript: 'Hey Gaia create a project for the dashboard',
            entryCount: 2,
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('Assistant'), findsOneWidget);
    expect(find.text('I am here and ready to help.'), findsOneWidget);
    expect(find.text('Project context'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('Thread context'), findsOneWidget);
    expect(
      find.text('Hey Gaia create a project for the dashboard'),
      findsOneWidget,
    );
    expect(
      find.text('Say create a task, create a project, or ask what I can do.'),
      findsOneWidget,
    );
    expect(find.text('Open shared conversation'), findsOneWidget);
  });

  testWidgets('voice conversation dock shows quick follow-up actions', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: VoiceConversationDock())),
      ),
    );

    container
        .read(voiceConversationDockProvider.notifier)
        .show(
          title: 'Assistant',
          summary:
              'This sounds like a project. I can open Projects or preload a project template.',
          nextStep:
              'Use a quick follow-up chip to keep going without leaving the dashboard.',
          transcript:
              'Project: Create a project for the dashboard voice workflow',
          isWake: true,
          projectContext: 'Dashboard voice workflow',
          threadContext: 'Dashboard voice workflow · Project · Draft',
          conversationContext: const VoiceConversationContext(
            label: 'Project',
            summary: 'Dashboard voice workflow',
            type: VoiceCommandType.project,
            projectName: 'Dashboard voice workflow',
            title: 'Draft',
            transcript:
                'Project: Create a project for the dashboard voice workflow',
            entryCount: 1,
          ),
        );
    await tester.pumpAndSettle();

    expect(find.text('Quick follow-up chips'), findsOneWidget);
    expect(find.text('Project Draft'), findsOneWidget);
    expect(find.text('Plan Day'), findsWidgets);
    expect(find.text('Recall Memory'), findsWidgets);
    expect(find.text('Continue Thread'), findsOneWidget);
    expect(find.text('Open shared conversation'), findsOneWidget);
    expect(find.text('Open Assistant'), findsOneWidget);
  });

  testWidgets('voice conversation dock accepts a short follow-up reply', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        settingsSnapshotProvider.overrideWith(
          (ref) async => SettingsSnapshot(
            settings: AppSetting(
              settingsId: 'settings-test',
              themeMode: 'Dark',
              defaultDashboardView: null,
              showWellbeingCard: true,
              showBusinessCard: true,
              showLearningCard: true,
              showContentCard: true,
              showProjectsWorkspaceSnapshot: true,
              showDockOverlays: true,
              showBackupGuardianDock: true,
              showTreasuryDock: true,
              showKnowledgeLibraryDock: true,
              showVoiceConversationDock: true,
              showVoicePresenceChip: true,
              dailyTopTaskLimit: 3,
              voiceRepliesEnabled: false,
              voiceAssistantEnabled: true,
              preferredTtsVoiceName: null,
              preferredTtsVoiceLocale: null,
              preferredTtsVoiceGender: null,
              preferredTtsVoiceIdentifier: null,
              preferredTtsVoiceRate: 0.5,
              preferredTtsVoicePitch: 1.0,
              createdAt: DateTime(2026, 5, 9),
              updatedAt: DateTime(2026, 5, 9),
            ),
            appVersion: 'test',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: VoiceConversationDock())),
      ),
    );

    container
        .read(voiceConversationDockProvider.notifier)
        .show(
          title: 'Assistant',
          summary: 'I am here and ready to help.',
          nextStep:
              'Ask a short follow-up right here without opening the full screen.',
          transcript: 'Hey Gaia',
          isWake: true,
          projectContext: 'Dashboard voice workflow',
          threadContext: 'Dashboard voice workflow · Wake · Greeting',
        );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('voiceConversationFollowUpField')),
      'What can you do?',
    );
    await tester.tap(
      find.byKey(const Key('voiceConversationFollowUpSendButton')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'I can help with tasks, projects, journal entries, content ideas, business opportunities, inbox items, and more.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Try create a task, create a project, summarize today, continue the thread, or ask for the next move.',
      ),
      findsOneWidget,
    );
    expect(find.text('What can you do?'), findsOneWidget);
    expect(find.text('Open shared conversation'), findsOneWidget);
  });
}
