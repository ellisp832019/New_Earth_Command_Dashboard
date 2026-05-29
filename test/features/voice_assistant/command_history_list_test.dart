import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/widgets/command_history_list.dart';

void main() {
  testWidgets('command history list filters by phrase and type', (
    WidgetTester tester,
  ) async {
    final commands = [
      VoiceCommand(
        id: '1',
        transcript: 'Create a task to review the dashboard cards',
        type: VoiceCommandType.task,
        createdAt: DateTime(2026, 5, 29, 9, 0),
      ),
      VoiceCommand(
        id: '2',
        transcript: 'Journal: reflect on the calm build day',
        type: VoiceCommandType.journalEntry,
        createdAt: DateTime(2026, 5, 29, 9, 5),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CommandHistoryList(commands: commands)),
      ),
    );

    expect(
      find.text('Create a task to review the dashboard cards'),
      findsOneWidget,
    );
    expect(find.text('Journal: reflect on the calm build day'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('voiceHistorySearchField')),
      'journal',
    );
    await tester.pump();

    expect(
      find.text('Create a task to review the dashboard cards'),
      findsNothing,
    );
    expect(find.text('Journal: reflect on the calm build day'), findsOneWidget);
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
    expect(find.text('Journal: reflect on the calm build day'), findsOneWidget);
  });
}
