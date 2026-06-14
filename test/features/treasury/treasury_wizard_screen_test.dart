import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/treasury/presentation/treasury_wizard_screen.dart';

void main() {
  testWidgets('weekly ritual wizard shows the guided flow banner', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TreasuryWizardScreen(
            initialFlow: 'weekly',
            initialStepIndex: 0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Weekly Ritual'), findsWidgets);
    expect(find.text('Weekly ritual'), findsWidgets);
    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('Current: Safe'), findsOneWidget);
    expect(find.text('What feels safe to spend or continue?'), findsOneWidget);
  });

  testWidgets('weekly ritual wizard review highlights the calm summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TreasuryWizardScreen(
            initialFlow: 'weekly',
            initialStepIndex: 5,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Weekly review summary'), findsOneWidget);
    expect(
      find.textContaining(
        'Safe / Watch / Pause / Decision stays easy to scan here before the review is saved.',
      ),
      findsOneWidget,
    );
    expect(find.text('Local-first save'), findsWidgets);
    expect(find.text('Save review'), findsWidgets);
    expect(find.text('Return to Treasury'), findsWidgets);
  });
}
