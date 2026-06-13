enum ModuleCategory {
  aiAutomation,
  voiceHardware,
  knowledgeResearch,
  projectManagement,
  grantsFunding,
  backupRecovery,
  microGrow,
  xrVisualSystems,
  financeTreasury,
  systemCore,
  security,
  communityOutreach,
}

extension ModuleCategoryLabel on ModuleCategory {
  String get label {
    switch (this) {
      case ModuleCategory.aiAutomation:
        return 'AI Automation';
      case ModuleCategory.voiceHardware:
        return 'Voice Hardware';
      case ModuleCategory.knowledgeResearch:
        return 'Knowledge Research';
      case ModuleCategory.projectManagement:
        return 'Project Management';
      case ModuleCategory.grantsFunding:
        return 'Grants Funding';
      case ModuleCategory.backupRecovery:
        return 'Backup Recovery';
      case ModuleCategory.microGrow:
        return 'MicroGrow';
      case ModuleCategory.xrVisualSystems:
        return 'XR Visual Systems';
      case ModuleCategory.financeTreasury:
        return 'Finance Treasury';
      case ModuleCategory.systemCore:
        return 'System Core';
      case ModuleCategory.security:
        return 'Security';
      case ModuleCategory.communityOutreach:
        return 'Community Outreach';
    }
  }
}
