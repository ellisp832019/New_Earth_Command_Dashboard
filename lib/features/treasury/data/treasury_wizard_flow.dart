enum TreasuryWizardFlow {
  weeklyRitual,
  receipts,
  decisions,
  projectSpend,
  subscriptions,
}

TreasuryWizardFlow resolveTreasuryWizardFlow(String? value) {
  switch (value) {
    case 'receipts':
      return TreasuryWizardFlow.receipts;
    case 'decisions':
      return TreasuryWizardFlow.decisions;
    case 'project_spend':
      return TreasuryWizardFlow.projectSpend;
    case 'subscriptions':
      return TreasuryWizardFlow.subscriptions;
    case 'weekly':
    default:
      return TreasuryWizardFlow.weeklyRitual;
  }
}

extension TreasuryWizardFlowUi on TreasuryWizardFlow {
  String get routeValue {
    switch (this) {
      case TreasuryWizardFlow.weeklyRitual:
        return 'weekly';
      case TreasuryWizardFlow.receipts:
        return 'receipts';
      case TreasuryWizardFlow.decisions:
        return 'decisions';
      case TreasuryWizardFlow.projectSpend:
        return 'project_spend';
      case TreasuryWizardFlow.subscriptions:
        return 'subscriptions';
    }
  }

  String get title {
    switch (this) {
      case TreasuryWizardFlow.weeklyRitual:
        return 'Weekly Ritual';
      case TreasuryWizardFlow.receipts:
        return 'Receipts';
      case TreasuryWizardFlow.decisions:
        return 'Decisions';
      case TreasuryWizardFlow.projectSpend:
        return 'Project Spend';
      case TreasuryWizardFlow.subscriptions:
        return 'Subscriptions';
    }
  }

  String get subtitle {
    switch (this) {
      case TreasuryWizardFlow.weeklyRitual:
        return 'A calm weekly review with Safe / Watch / Pause / Decision.';
      case TreasuryWizardFlow.receipts:
        return 'Capture a receipt or invoice without leaving the dashboard.';
      case TreasuryWizardFlow.decisions:
        return 'Collect the one choice Hayley and Peter need to make together.';
      case TreasuryWizardFlow.projectSpend:
        return 'Log project spending in a guided, low-pressure flow.';
      case TreasuryWizardFlow.subscriptions:
        return 'Review recurring costs one service at a time.';
    }
  }
}
