import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/treasury_wizard_draft.dart';
import '../data/treasury_wizard_flow.dart';

final treasuryWizardDraftsProvider =
    NotifierProvider<
      TreasuryWizardDraftsNotifier,
      Map<TreasuryWizardFlow, TreasuryWizardDraft>
    >(TreasuryWizardDraftsNotifier.new);

class TreasuryWizardDraftsNotifier
    extends Notifier<Map<TreasuryWizardFlow, TreasuryWizardDraft>> {
  @override
  Map<TreasuryWizardFlow, TreasuryWizardDraft> build() => {};

  TreasuryWizardDraft? draftFor(TreasuryWizardFlow flow) => state[flow];

  void ensureLength(TreasuryWizardFlow flow, int length) {
    final current = state[flow];
    final values = List<String>.filled(length, '');
    if (current != null) {
      for (var i = 0; i < current.values.length && i < length; i++) {
        values[i] = current.values[i];
      }
    }

    state = {
      ...state,
      flow: TreasuryWizardDraft(
        flow: flow,
        values: values,
        updatedAt: DateTime.now(),
        savedAt: current?.savedAt,
      ),
    };
  }

  void setField(TreasuryWizardFlow flow, int index, String value) {
    final current = state[flow];
    if (current == null || index >= current.values.length) {
      return;
    }

    final values = List<String>.from(current.values);
    values[index] = value;
    state = {
      ...state,
      flow: current.copyWith(values: values, updatedAt: DateTime.now()),
    };
  }

  void markSaved(TreasuryWizardFlow flow) {
    final current = state[flow];
    if (current == null) {
      return;
    }

    state = {
      ...state,
      flow: current.copyWith(
        savedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    };
  }

  void clear(TreasuryWizardFlow flow) {
    state = {...state}..remove(flow);
  }
}
