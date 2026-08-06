export type RiskLevel = 'low' | 'medium' | 'high' | 'blocked';

export interface VoiceCommandRequest {
  rawText: string;
  intent: string;
  parameters?: Record<string, unknown>;
}

export interface SafetyDecision {
  allowed: boolean;
  riskLevel: RiskLevel;
  requiresConfirmation: boolean;
  reason: string;
}

const HARDWARE_WRITE_INTENTS = new Set([
  'microgrow.relay.set',
  'microgrow.mist.run',
  'microgrow.pump.run',
  'microgrow.heater.set',
  'microgrow.firmware.update'
]);

export function evaluateVoiceCommand(command: VoiceCommandRequest): SafetyDecision {
  if (HARDWARE_WRITE_INTENTS.has(command.intent)) {
    return {
      allowed: false,
      riskLevel: 'high',
      requiresConfirmation: true,
      reason: 'Hardware voice control is disabled in V1. Read-only MicroGrow status is allowed.'
    };
  }

  if (command.intent.includes('delete') || command.intent.includes('disable_safety')) {
    return {
      allowed: false,
      riskLevel: 'blocked',
      requiresConfirmation: false,
      reason: 'This command is blocked by the safety policy.'
    };
  }

  return {
    allowed: true,
    riskLevel: 'low',
    requiresConfirmation: false,
    reason: 'Allowed by V1 voice policy.'
  };
}
