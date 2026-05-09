import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_conversation_dock_controller.dart';
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
          title: 'Gaia',
          summary: 'I am here and ready to help.',
          nextStep:
              'Say create a task, create a project, or ask what I can do.',
          transcript: 'Hey Gaia create a project for the dashboard',
          isWake: true,
          projectContext: 'MicroGrow',
          threadContext: 'MicroGrow · Project · Dashboard voice workflow',
        );
    await tester.pumpAndSettle();

    expect(find.text('Gaia'), findsOneWidget);
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
          title: 'Gaia',
          summary:
              'This sounds like a project. I can open Projects or preload a project template.',
          nextStep:
              'Use a quick follow-up chip to keep going without leaving the dashboard.',
          transcript:
              'Project: Create a project for the dashboard voice workflow',
          isWake: true,
          projectContext: 'Dashboard voice workflow',
          threadContext: 'Dashboard voice workflow · Project · Draft',
        );
    await tester.pumpAndSettle();

    expect(find.text('Quick follow-up'), findsOneWidget);
    expect(find.text('Load Project'), findsOneWidget);
    expect(find.text('Open Projects'), findsOneWidget);
    expect(find.text('Continue Thread'), findsOneWidget);
    expect(find.text('Open Assistant'), findsOneWidget);
  });
}
