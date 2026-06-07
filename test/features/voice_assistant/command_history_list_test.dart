import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/widgets/command_history_list.dart';

void main() {
  testWidgets('command history list filters by phrase and type', (
    WidgetTester tester,
  ) async {
    VoiceCommand? reusedCommand;
    final commands = [
      VoiceCommand(
        id: '1',
        transcript: 'Journal: reflect on the calm build day',
        type: VoiceCommandType.journalEntry,
        createdAt: DateTime(2026, 5, 29, 9, 5),
      ),
      VoiceCommand(
        id: '2',
        transcript: 'Create a task to review the dashboard cards',
        type: VoiceCommandType.task,
        createdAt: DateTime(2026, 5, 29, 9, 0),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommandHistoryList(
            commands: commands,
            onCommandSelected: (command) {
              reusedCommand = command;
            },
          ),
        ),
      ),
    );

    expect(find.text('Latest capture'), findsOneWidget);
    expect(find.text('Reuse latest'), findsOneWidget);
    expect(find.text('Copy latest'), findsOneWidget);
    expect(
      find.text('Journal: reflect on the calm build day'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.text('Create a task to review the dashboard cards'),
      findsOneWidget,
    );
    expect(
      find.text('Journal: reflect on the calm build day'),
      findsAtLeastNWidgets(1),
    );

    await tester.tap(find.text('Reuse latest'));
    await tester.pumpAndSettle();
    expect(reusedCommand?.id, '1');

    await tester.enterText(
      find.byKey(const Key('voiceHistorySearchField')),
      'journal',
    );
    await tester.pump();

    expect(
      find.text('Create a task to review the dashboard cards'),
      findsNothing,
    );
    expect(
      find.text('Journal: reflect on the calm build day'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.byKey(const Key('voiceHistorySearchClearButton')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('voiceHistorySearchClearButton')));
    await tester.pump();

    expect(
      find.text('Create a task to review the dashboard cards'),
      findsOneWidget,
    );
    expect(
      find.text('Journal: reflect on the calm build day'),
      findsAtLeastNWidgets(1),
    );
  });
}
