import '../voice_command_model.dart';

class VoiceAiAssistRequest {
  const VoiceAiAssistRequest({
    required this.transcript,
    this.prompt,
    this.selectedType,
    this.wizardStep,
    this.conversationContext,
  });

  final String transcript;
  final String? prompt;
  final VoiceCommandType? selectedType;
  final VoiceWizardStep? wizardStep;
  final VoiceConversationContext? conversationContext;

  @override
  bool operator ==(Object other) {
    return other is VoiceAiAssistRequest &&
        other.transcript == transcript &&
        other.prompt == prompt &&
        other.selectedType == selectedType &&
        other.wizardStep == wizardStep &&
        other.conversationContext == conversationContext;
  }

  @override
  int get hashCode => Object.hash(
    transcript,
    prompt,
    selectedType,
    wizardStep,
    conversationContext,
  );
}

class VoiceAiAssistResponse {
  const VoiceAiAssistResponse({
    required this.summary,
    required this.nextStep,
    this.suggestedTitle,
    this.suggestedType,
    this.hints = const <String>[],
  });

  const VoiceAiAssistResponse.empty()
    : summary = 'AI assist is not connected yet.',
      nextStep = 'Review the transcript manually before saving.',
      suggestedTitle = null,
      suggestedType = null,
      hints = const <String>[];

  final String summary;
  final String nextStep;
  final String? suggestedTitle;
  final VoiceCommandType? suggestedType;
  final List<String> hints;

  VoiceAiAssistResponse copyWith({
    String? summary,
    String? nextStep,
    String? suggestedTitle,
    VoiceCommandType? suggestedType,
    List<String>? hints,
  }) {
    return VoiceAiAssistResponse(
      summary: summary ?? this.summary,
      nextStep: nextStep ?? this.nextStep,
      suggestedTitle: suggestedTitle ?? this.suggestedTitle,
      suggestedType: suggestedType ?? this.suggestedType,
      hints: hints ?? this.hints,
    );
  }
}

abstract class VoiceAiAssistService {
  const VoiceAiAssistService();

  Future<VoiceAiAssistResponse> reviewTranscript(VoiceAiAssistRequest request);

  Future<VoiceAiAssistResponse> guideWizard(VoiceAiAssistRequest request);

  Future<VoiceAiAssistResponse> summarizeMemory(VoiceAiAssistRequest request);
}

class NoOpVoiceAiAssistService implements VoiceAiAssistService {
  const NoOpVoiceAiAssistService();

  @override
  Future<VoiceAiAssistResponse> reviewTranscript(
    VoiceAiAssistRequest request,
  ) async {
    final cleanedTranscript = request.transcript.trim();
    final fallbackTitle = _buildFallbackTitle(cleanedTranscript);
    final hasTranscript = cleanedTranscript.isNotEmpty;

    return VoiceAiAssistResponse(
      summary: hasTranscript
          ? 'AI assist is not connected yet. Review the transcript manually before saving.'
          : 'AI assist is not connected yet.',
      nextStep: hasTranscript
          ? 'Use the current review flow to confirm the type, title, and project.'
          : 'Capture a transcript first, then review it here.',
      suggestedTitle: fallbackTitle,
      suggestedType: request.selectedType ?? request.conversationContext?.type,
      hints: [
        if (request.wizardStep != null)
          'Wizard step: ${request.wizardStep!.label}',
        if (request.conversationContext != null &&
            request.conversationContext!.hasMemory)
          'Thread memory is available for manual review.',
      ],
    );
  }

  @override
  Future<VoiceAiAssistResponse> guideWizard(
    VoiceAiAssistRequest request,
  ) async {
    final prompt = request.prompt?.trim();
    final cleanedTranscript = request.transcript.trim();

    return VoiceAiAssistResponse(
      summary: prompt?.isNotEmpty == true
          ? 'AI assist is not connected yet. Keep answering the wizard manually.'
          : 'AI assist is not connected yet.',
      nextStep: cleanedTranscript.isNotEmpty
          ? 'Continue the manual wizard with the current answer.'
          : 'Answer the current wizard question manually.',
      suggestedTitle: _buildFallbackTitle(cleanedTranscript),
      suggestedType: request.selectedType,
      hints: [
        if (prompt?.isNotEmpty == true) 'Wizard prompt is ready for review.',
        if (request.wizardStep != null)
          'Current step: ${request.wizardStep!.label}',
      ],
    );
  }

  @override
  Future<VoiceAiAssistResponse> summarizeMemory(
    VoiceAiAssistRequest request,
  ) async {
    final hasMemory =
        request.conversationContext != null &&
        request.conversationContext!.hasMemory;

    return VoiceAiAssistResponse(
      summary: hasMemory
          ? 'AI assist is not connected yet, but the current thread can still be reviewed manually.'
          : 'AI assist is not connected yet.',
      nextStep: hasMemory
          ? 'Use the remembered thread and review the next manual action.'
          : 'Start a new capture or choose a starter template.',
      suggestedTitle: _buildFallbackTitle(request.transcript),
      suggestedType: request.selectedType ?? request.conversationContext?.type,
      hints: [
        if (hasMemory) 'Thread memory is available.',
        if ((request.transcript.trim()).isNotEmpty) 'Transcript can be reused.',
      ],
    );
  }
}

String _buildFallbackTitle(String transcript) {
  final cleaned = transcript
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[.!?]+$'), '');
  if (cleaned.isEmpty) {
    return 'Voice capture';
  }

  final words = cleaned.split(' ');
  if (words.length <= 6) {
    return cleaned;
  }

  return words.take(6).join(' ');
}
