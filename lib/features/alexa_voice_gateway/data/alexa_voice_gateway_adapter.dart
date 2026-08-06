import 'alexa_voice_gateway_models.dart';

abstract class AlexaVoiceGatewayAdapter {
  AlexaVoiceGatewayStatusSnapshot loadStatus();
}

class MockAlexaVoiceGatewayAdapter implements AlexaVoiceGatewayAdapter {
  const MockAlexaVoiceGatewayAdapter();

  @override
  AlexaVoiceGatewayStatusSnapshot loadStatus() {
    return const AlexaVoiceGatewayStatusSnapshot(
      gatewayRunning: false,
      skillConfigured: false,
      killSwitchEnabled: true,
      lastCommandReceived: 'No Alexa requests yet',
      lastCommandStatus: 'Idle',
      modulePath: 'modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE',
      localModeSummary:
          'Read-only local mock mode is available before Alexa linking is enabled.',
      allowedCommands: [
        AlexaVoiceGatewayCommandItem(
          title: 'Get today summary',
          command: 'dashboard.summary.today',
          intent: 'GetTodaySummaryIntent',
          permissionLevel: 1,
          description: 'Read the calm dashboard overview for today.',
          status: 'Allowed',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Get project status',
          command: 'dashboard.project.status.read',
          intent: 'GetProjectStatusIntent',
          permissionLevel: 1,
          description: 'Read project progress without changing anything.',
          status: 'Allowed',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Get MicroGrow status',
          command: 'microgrow.status.read',
          intent: 'GetMicroGrowStatusIntent',
          permissionLevel: 1,
          description: 'Read MicroGrow readings only.',
          status: 'Allowed',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Add dashboard note',
          command: 'dashboard.note.add',
          intent: 'AddDashboardNoteIntent',
          permissionLevel: 2,
          description: 'Add a note to the dashboard inbox.',
          status: 'Allowed',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Start focus mode',
          command: 'dashboard.focus.start',
          intent: 'StartFocusModeIntent',
          permissionLevel: 2,
          description: 'Start a focus session without touching hardware.',
          status: 'Allowed',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'List next tasks',
          command: 'dashboard.tasks.next',
          intent: 'ListNextTasksIntent',
          permissionLevel: 1,
          description: 'Read the next suggested tasks.',
          status: 'Allowed',
        ),
      ],
      blockedCommands: [
        AlexaVoiceGatewayCommandItem(
          title: 'Delete files',
          command: 'filesystem.delete',
          intent: 'DeleteFileIntent',
          permissionLevel: 4,
          description: 'Never expose file deletion through Alexa.',
          status: 'Blocked',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Open private Obsidian notes',
          command: 'obsidian.raw_vault.read',
          intent: 'OpenPrivateNoteIntent',
          permissionLevel: 4,
          description: 'Do not route raw private notes directly.',
          status: 'Blocked',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Access finance data',
          command: 'finance.private.read',
          intent: 'FinanceReadIntent',
          permissionLevel: 4,
          description: 'Finance information stays inside the protected layer.',
          status: 'Blocked',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Run terminal commands',
          command: 'system.shell.exec',
          intent: 'ShellCommandIntent',
          permissionLevel: 4,
          description: 'Shell execution stays out of the voice doorway.',
          status: 'Blocked',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Trigger AI agents',
          command: 'ai.agent.run',
          intent: 'RunAgentIntent',
          permissionLevel: 4,
          description: 'Agent execution is not exposed through Alexa.',
          status: 'Blocked',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Permanently control relays',
          command: 'microgrow.relay.permanent_control',
          intent: 'ControlRelayIntent',
          permissionLevel: 4,
          description: 'Permanent relay control is blocked by default.',
          status: 'Blocked',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Control dangerous hardware',
          command: 'hardware.dangerous.control',
          intent: 'DangerousHardwareIntent',
          permissionLevel: 4,
          description: 'Dangerous hardware remains blocked from Alexa.',
          status: 'Blocked',
        ),
        AlexaVoiceGatewayCommandItem(
          title: 'Access raw local databases',
          command: 'database.raw.read',
          intent: 'DatabaseReadIntent',
          permissionLevel: 4,
          description: 'Raw databases stay behind the safety layer.',
          status: 'Blocked',
        ),
      ],
      auditLogEntries: [
        AlexaVoiceGatewayAuditEntry(
          timestamp: '2026-06-11T08:00:00Z',
          command: 'dashboard.summary.today',
          source: 'alexa',
          permissionResult: 'allowed',
          actionTaken: 'forwarded_to_dashboard_adapter',
        ),
        AlexaVoiceGatewayAuditEntry(
          timestamp: '2026-06-11T08:03:00Z',
          command: 'microgrow.status.read',
          source: 'alexa',
          permissionResult: 'allowed',
          actionTaken: 'forwarded_to_dashboard_adapter',
        ),
        AlexaVoiceGatewayAuditEntry(
          timestamp: '2026-06-11T08:05:00Z',
          command: 'system.shell.exec',
          source: 'alexa',
          permissionResult: 'blocked',
          actionTaken: 'rejected_by_permission_layer',
          blockedReason: 'Shell execution is blocked for Alexa.',
        ),
      ],
    );
  }
}
