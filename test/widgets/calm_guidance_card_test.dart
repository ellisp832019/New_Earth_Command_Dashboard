import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/widgets/calm_guidance_card.dart';

void main() {
  testWidgets('calm guidance card shows optional detail chips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CalmGuidanceCard(
            sectionLabel: 'Briefing',
            title: 'Remembered thread ready',
            summary: 'Continue from the latest voice capture.',
            reason: 'The thread context helps keep the next move focused.',
            details: ['Thread: MicroGrow Project', '2 saved entries'],
          ),
        ),
      ),
    );

    expect(find.text('Briefing'), findsOneWidget);
    expect(find.text('Remembered thread ready'), findsOneWidget);
    expect(
      find.text('Continue from the latest voice capture.'),
      findsOneWidget,
    );
    expect(find.text('Thread: MicroGrow Project'), findsOneWidget);
    expect(find.text('2 saved entries'), findsOneWidget);
  });
}
