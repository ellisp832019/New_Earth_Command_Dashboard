import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/treasury/data/treasury_wizard_draft.dart';
import 'package:new_earth_command_dashboard/features/treasury/data/treasury_wizard_flow.dart';

void main() {
  test('TreasuryWizardDraft tracks filled and remaining steps', () {
    final draft = TreasuryWizardDraft(
      flow: TreasuryWizardFlow.weeklyRitual,
      values: const ['Rent', '', 'Pause', '', ''],
      updatedAt: DateTime(2026, 5, 28),
    );

    expect(draft.hasContent, isTrue);
    expect(draft.filledStepCount, 2);
    expect(draft.totalStepCount, 5);
    expect(draft.remainingStepCount, 3);
    expect(draft.nextStepIndex, 1);
    expect(draft.firstSummary, 'Rent');
  });
}
