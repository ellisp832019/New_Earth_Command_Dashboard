import 'voice_models.dart';

class SafetyCommandGateway {
  const SafetyCommandGateway();

  static const Set<String> _blockedHardwareIntents = {
    'microgrow.relay.set',
    'microgrow.mist.run',
    'microgrow.pump.run',
    'microgrow.heater.set',
    'microgrow.firmware.update',
  };

  SafetyDecision evaluate(SafetyCommandRequest command) {
    final normalizedIntent = command.intent.toLowerCase().trim();

    if (_blockedHardwareIntents.contains(normalizedIntent)) {
      return const SafetyDecision(
        allowed: false,
        riskLevel: VoiceRiskLevel.high,
        requiresConfirmation: true,
        reason: 'Hardware voice control is disabled in V1.',
      );
    }

    if (normalizedIntent.contains('delete') ||
        normalizedIntent.contains('disable_safety') ||
        normalizedIntent.contains('bypass')) {
      return const SafetyDecision(
        allowed: false,
        riskLevel: VoiceRiskLevel.blocked,
        requiresConfirmation: false,
        reason: 'This command is blocked by the safety gateway.',
      );
    }

    if (normalizedIntent.contains('openai.secret') ||
        normalizedIntent.contains('api_key')) {
      return const SafetyDecision(
        allowed: false,
        riskLevel: VoiceRiskLevel.blocked,
        requiresConfirmation: false,
        reason: 'Secret handling is not allowed in the voice path.',
      );
    }

    if (normalizedIntent.contains('microgrow.status.read')) {
      return const SafetyDecision(
        allowed: true,
        riskLevel: VoiceRiskLevel.low,
        requiresConfirmation: false,
        reason: 'Read-only MicroGrow status queries are allowed.',
      );
    }

    if (normalizedIntent.contains('meeting.summary') ||
        normalizedIntent.contains('task.create') ||
        normalizedIntent.contains('note.create')) {
      return const SafetyDecision(
        allowed: true,
        riskLevel: VoiceRiskLevel.low,
        requiresConfirmation: false,
        reason: 'This low-risk dashboard action is allowed.',
      );
    }

    return const SafetyDecision(
      allowed: true,
      riskLevel: VoiceRiskLevel.low,
      requiresConfirmation: false,
      reason: 'Allowed by the V1 voice policy.',
    );
  }
}
