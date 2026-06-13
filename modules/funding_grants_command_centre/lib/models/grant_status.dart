enum GrantStatus {
  idea,
  researching,
  eligible,
  drafting,
  needsEvidence,
  needsBudget,
  needsPartner,
  readyToSubmit,
  submitted,
  underReview,
  approved,
  rejected,
  paused,
  reportingPhase,
  closed,
}

extension GrantStatusLabel on GrantStatus {
  String get label {
    switch (this) {
      case GrantStatus.idea:
        return 'Idea';
      case GrantStatus.researching:
        return 'Researching';
      case GrantStatus.eligible:
        return 'Eligible';
      case GrantStatus.drafting:
        return 'Drafting';
      case GrantStatus.needsEvidence:
        return 'Needs Evidence';
      case GrantStatus.needsBudget:
        return 'Needs Budget';
      case GrantStatus.needsPartner:
        return 'Needs Partner';
      case GrantStatus.readyToSubmit:
        return 'Ready to Submit';
      case GrantStatus.submitted:
        return 'Submitted';
      case GrantStatus.underReview:
        return 'Under Review';
      case GrantStatus.approved:
        return 'Approved';
      case GrantStatus.rejected:
        return 'Rejected';
      case GrantStatus.paused:
        return 'Paused';
      case GrantStatus.reportingPhase:
        return 'Reporting Phase';
      case GrantStatus.closed:
        return 'Closed';
    }
  }

  static GrantStatus fromLabel(String value) {
    return GrantStatus.values.firstWhere(
      (status) => status.label == value,
      orElse: () => GrantStatus.idea,
    );
  }
}
