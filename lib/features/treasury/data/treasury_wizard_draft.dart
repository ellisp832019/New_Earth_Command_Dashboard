import 'treasury_wizard_flow.dart';

class TreasuryWizardDraft {
  const TreasuryWizardDraft({
    required this.flow,
    required this.values,
    required this.updatedAt,
    this.savedAt,
  });

  final TreasuryWizardFlow flow;
  final List<String> values;
  final DateTime updatedAt;
  final DateTime? savedAt;

  TreasuryWizardDraft copyWith({
    TreasuryWizardFlow? flow,
    List<String>? values,
    DateTime? updatedAt,
    DateTime? savedAt,
  }) {
    return TreasuryWizardDraft(
      flow: flow ?? this.flow,
      values: values ?? this.values,
      updatedAt: updatedAt ?? this.updatedAt,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  bool get hasContent => values.any((value) => value.trim().isNotEmpty);

  int get nextStepIndex {
    for (var index = 0; index < values.length; index++) {
      if (values[index].trim().isEmpty) {
        return index;
      }
    }

    return values.length;
  }

  String get firstSummary {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return 'Nothing entered yet.';
  }
}
