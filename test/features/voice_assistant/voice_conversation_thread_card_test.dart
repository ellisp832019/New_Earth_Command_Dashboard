import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/widgets/voice_conversation_thread_card.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';

void main() {
  testWidgets('voice conversation thread card shows resume details', (
    WidgetTester tester,
  ) async {
    var resumed = false;
    var startedFresh = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VoiceConversationThreadCard(
            conversationContext: const VoiceConversationContext(
              label: 'Project',
              summary: 'Continuing the dashboard voice workflow thread.',
              type: VoiceCommandType.project,
              projectName: 'MicroGrow',
              title: 'Dashboard voice workflow',
              transcript: 'Project: Create a project for the dashboard voice workflow',
              entryCount: 2,
            ),
            onResumeThread: () {
              resumed = true;
            },
            onStartFresh: () {
              startedFresh = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Remembered thread'), findsOneWidget);
    expect(find.text('Saved entries: 2'), findsOneWidget);
    expect(find.text('Latest capture'), findsOneWidget);
    expect(find.text('Dashboard voice workflow'), findsOneWidget);
    expect(find.text('Type: Project'), findsOneWidget);
    expect(find.text('Project: MicroGrow'), findsOneWidget);
    expect(find.text('Resume thread'), findsOneWidget);
    expect(find.text('Start fresh'), findsOneWidget);

    await tester.tap(find.text('Resume thread'));
    await tester.pumpAndSettle();
    expect(resumed, isTrue);

    await tester.tap(find.text('Start fresh'));
    await tester.pumpAndSettle();
    expect(startedFresh, isTrue);
  });
}
