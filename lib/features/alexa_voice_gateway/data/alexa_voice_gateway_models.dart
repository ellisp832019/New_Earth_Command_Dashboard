class AlexaVoiceGatewayCommandItem {
  const AlexaVoiceGatewayCommandItem({
    required this.title,
    required this.command,
    required this.intent,
    required this.permissionLevel,
    required this.description,
    required this.status,
  });

  final String title;
  final String command;
  final String intent;
  final int permissionLevel;
  final String description;
  final String status;
}

class AlexaVoiceGatewayAuditEntry {
  const AlexaVoiceGatewayAuditEntry({
    required this.timestamp,
    required this.command,
    required this.source,
    required this.permissionResult,
    required this.actionTaken,
    this.blockedReason,
  });

  final String timestamp;
  final String command;
  final String source;
  final String permissionResult;
  final String actionTaken;
  final String? blockedReason;
}

class AlexaVoiceGatewayStatusSnapshot {
  const AlexaVoiceGatewayStatusSnapshot({
    required this.gatewayRunning,
    required this.skillConfigured,
    required this.killSwitchEnabled,
    required this.lastCommandReceived,
    required this.lastCommandStatus,
    required this.allowedCommands,
    required this.blockedCommands,
    required this.auditLogEntries,
    required this.modulePath,
    required this.localModeSummary,
  });

  final bool gatewayRunning;
  final bool skillConfigured;
  final bool killSwitchEnabled;
  final String lastCommandReceived;
  final String lastCommandStatus;
  final List<AlexaVoiceGatewayCommandItem> allowedCommands;
  final List<AlexaVoiceGatewayCommandItem> blockedCommands;
  final List<AlexaVoiceGatewayAuditEntry> auditLogEntries;
  final String modulePath;
  final String localModeSummary;
}
