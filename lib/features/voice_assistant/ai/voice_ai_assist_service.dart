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
    this.suggestedSummary,
    this.suggestedType,
    this.hints = const <String>[],
  });

  const VoiceAiAssistResponse.empty()
    : summary = 'AI assist is not connected yet.',
      nextStep = 'Review the transcript manually before saving.',
      suggestedTitle = null,
      suggestedSummary = null,
      suggestedType = null,
      hints = const <String>[];

  final String summary;
  final String nextStep;
  final String? suggestedTitle;
  final String? suggestedSummary;
  final VoiceCommandType? suggestedType;
  final List<String> hints;

  VoiceAiAssistResponse copyWith({
    String? summary,
    String? nextStep,
    String? suggestedTitle,
    String? suggestedSummary,
    VoiceCommandType? suggestedType,
    List<String>? hints,
  }) {
    return VoiceAiAssistResponse(
      summary: summary ?? this.summary,
      nextStep: nextStep ?? this.nextStep,
      suggestedTitle: suggestedTitle ?? this.suggestedTitle,
      suggestedSummary: suggestedSummary ?? this.suggestedSummary,
      suggestedType: suggestedType ?? this.suggestedType,
      hints: hints ?? this.hints,
    );
  }
}

abstract class VoiceAiAssistAdapter {
  const VoiceAiAssistAdapter();

  Future<VoiceAiAssistResponse> reviewTranscript(VoiceAiAssistRequest request);

  Future<VoiceAiAssistResponse> guideWizard(VoiceAiAssistRequest request);

  Future<VoiceAiAssistResponse> summarizeMemory(VoiceAiAssistRequest request);
}

abstract class VoiceAiAssistService extends VoiceAiAssistAdapter {
  const VoiceAiAssistService();
}

class LocalVoiceAiAssistService extends VoiceAiAssistService {
  const LocalVoiceAiAssistService();

  @override
  Future<VoiceAiAssistResponse> reviewTranscript(
    VoiceAiAssistRequest request,
  ) async {
    final transcript = _normalizeText(request.transcript);
    final inferredType = _inferType(request, transcript);
    final context = request.conversationContext;
    final hasTranscript = transcript.isNotEmpty;

    return VoiceAiAssistResponse(
      summary: hasTranscript
          ? _reviewSummaryFor(inferredType, context)
          : 'AI draft: capture a transcript to get a tuned reply.',
      nextStep: hasTranscript
          ? _reviewNextStepFor(inferredType)
          : 'Capture the reply, then review the type, title, and next move.',
      suggestedTitle: _suggestedTitle(request, transcript),
      suggestedSummary: _suggestedSummary(request, transcript),
      suggestedType: inferredType,
      hints: _buildReviewHints(
        request: request,
        transcript: transcript,
        inferredType: inferredType,
      ),
    );
  }

  @override
  Future<VoiceAiAssistResponse> guideWizard(
    VoiceAiAssistRequest request,
  ) async {
    final transcript = _normalizeText(request.transcript);
    final prompt = _normalizeText(request.prompt ?? '');
    final inferredType = request.selectedType ?? request.conversationContext?.type;
    final hasPrompt = prompt.isNotEmpty;

    return VoiceAiAssistResponse(
      summary: hasPrompt
          ? _wizardSummaryFor(request.wizardStep, inferredType, prompt)
          : 'AI draft: the wizard is waiting for the next prompt.',
      nextStep: _wizardNextStepFor(request.wizardStep, inferredType),
      suggestedTitle: _suggestedTitle(request, transcript.isNotEmpty ? transcript : prompt),
      suggestedSummary: _suggestedSummary(
        request,
        transcript.isNotEmpty ? transcript : prompt,
      ),
      suggestedType: inferredType,
      hints: _buildWizardHints(
        request: request,
        transcript: transcript,
        prompt: prompt,
        inferredType: inferredType,
      ),
    );
  }

  @override
  Future<VoiceAiAssistResponse> summarizeMemory(
    VoiceAiAssistRequest request,
  ) async {
    final context = request.conversationContext;
    final transcript = _normalizeText(request.transcript);
    final hasMemory = context != null && context.hasMemory;
    final inferredType = request.selectedType ?? context?.type;

    return VoiceAiAssistResponse(
      summary: hasMemory
          ? _memorySummaryFor(context)
          : 'AI draft: remember a thread first, then I can tune the reply.',
      nextStep: hasMemory
          ? _memoryNextStepFor(context, inferredType)
          : 'Start a new capture or choose a starter template.',
      suggestedTitle: _suggestedTitle(request, transcript),
      suggestedSummary: _suggestedSummary(request, transcript),
      suggestedType: inferredType,
      hints: _buildMemoryHints(
        request: request,
        hasMemory: hasMemory,
        context: context,
        transcript: transcript,
      ),
    );
  }
}

class NoOpVoiceAiAssistService extends LocalVoiceAiAssistService {
  const NoOpVoiceAiAssistService();
}

String _normalizeText(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _buildFallbackTitle(String transcript) {
  final cleaned = _normalizeText(transcript).replaceAll(
    RegExp(r'^(project|task|journal|content|business|idea|codex)\s*:\s*',
      caseSensitive: false,
    ),
    '',
  ).replaceAll(RegExp(r'[.!?]+$'), '');
  if (cleaned.isEmpty) {
    return 'Voice capture';
  }

  final words = cleaned.split(' ');
  if (words.length <= 6) {
    return cleaned;
  }

  return words.take(6).join(' ');
}

String _suggestedTitle(VoiceAiAssistRequest request, String transcript) {
  final contextTitle = _normalizeText(request.conversationContext?.title ?? '');
  if (contextTitle.isNotEmpty) {
    return _buildFallbackTitle(contextTitle);
  }

  final latestEntry = _normalizeText(
    request.conversationContext?.latestEntryLabel ?? '',
  );
  if (transcript.isEmpty && latestEntry.isNotEmpty) {
    return _buildFallbackTitle(latestEntry);
  }

  return _buildFallbackTitle(transcript);
}

String _suggestedSummary(VoiceAiAssistRequest request, String transcript) {
  final cleanedTranscript = _normalizeText(transcript);
  if (cleanedTranscript.isNotEmpty) {
    return _buildFallbackSummary(cleanedTranscript);
  }

  final latestEntry = _normalizeText(
    request.conversationContext?.latestEntryPreview ?? '',
  );
  if (latestEntry.isNotEmpty) {
    return _buildFallbackSummary(latestEntry);
  }

  return 'Short summary will appear here after a transcript is captured.';
}

String _buildFallbackSummary(String transcript) {
  final stripped = _normalizeText(transcript).replaceAll(
    RegExp(r'[.!?]+$'),
    '',
  );
  if (stripped.isEmpty) {
    return 'Short summary will appear here after a transcript is captured.';
  }

  final words = stripped.split(' ').where((word) => word.isNotEmpty).toList();
  if (words.length <= 14) {
    return stripped;
  }

  return '${words.take(14).join(' ')}...';
}

String _keywordLabel(VoiceCommandType? type) {
  return switch (type) {
    VoiceCommandType.task => 'task',
    VoiceCommandType.project => 'project',
    VoiceCommandType.journalEntry => 'journal entry',
    VoiceCommandType.contentIdea => 'content idea',
    VoiceCommandType.businessOpportunity => 'business lead',
    VoiceCommandType.codexPrompt => 'Codex prompt',
    VoiceCommandType.idea => 'idea',
    null => 'capture',
  };
}

VoiceCommandType? _inferType(VoiceAiAssistRequest request, String transcript) {
  return request.selectedType ??
      request.conversationContext?.type ??
      _inferTypeFromTranscript(transcript);
}

VoiceCommandType? _inferTypeFromTranscript(String transcript) {
  final lower = transcript.toLowerCase();
  if (lower.contains('project') ||
      lower.contains('vision') ||
      lower.contains('milestone')) {
    return VoiceCommandType.project;
  }
  if (lower.contains('journal') ||
      lower.contains('review') ||
      lower.contains('learned') ||
      lower.contains('reflection')) {
    return VoiceCommandType.journalEntry;
  }
  if (lower.contains('content') ||
      lower.contains('post') ||
      lower.contains('linkedin') ||
      lower.contains('youtube')) {
    return VoiceCommandType.contentIdea;
  }
  if (lower.contains('business') ||
      lower.contains('follow up') ||
      lower.contains('lead') ||
      lower.contains('partner') ||
      lower.contains('contact')) {
    return VoiceCommandType.businessOpportunity;
  }
  if (lower.contains('codex') || lower.contains('repo') || lower.contains('code')) {
    return VoiceCommandType.codexPrompt;
  }
  if (lower.contains('idea') || lower.contains('future')) {
    return VoiceCommandType.idea;
  }
  if (lower.contains('task') ||
      lower.contains('todo') ||
      lower.contains('next step') ||
      lower.contains('priority')) {
    return VoiceCommandType.task;
  }
  return null;
}

String _reviewSummaryFor(
  VoiceCommandType? inferredType,
  VoiceConversationContext? context,
) {
  final label = _keywordLabel(inferredType);
  if (context != null && context.hasMemory) {
    final memoryLabel = _normalizeText(context.projectName ?? context.threadScopeLabel);
    return 'AI draft: this $label stays connected to the remembered thread at $memoryLabel.';
  }

  return switch (inferredType) {
    VoiceCommandType.project =>
      'AI draft: this looks like a project capture with a clear next milestone.',
    VoiceCommandType.task =>
      'AI draft: this looks like a task capture with a clean next action.',
    VoiceCommandType.journalEntry =>
      'AI draft: this looks like a journal review with a short reflection path.',
    VoiceCommandType.contentIdea =>
      'AI draft: this looks like a content idea with a publish-ready angle.',
    VoiceCommandType.businessOpportunity =>
      'AI draft: this looks like a business follow-up with a next contact step.',
    VoiceCommandType.codexPrompt =>
      'AI draft: this looks like a Codex prompt that should stay review-first.',
    VoiceCommandType.idea =>
      'AI draft: this looks like a future idea worth parking for later.',
    null =>
      'AI draft: this capture can still be reviewed into the right local module.',
  };
}

String _reviewNextStepFor(VoiceCommandType? inferredType) {
  return switch (inferredType) {
    VoiceCommandType.project =>
      'Confirm the project name, status, and first action before saving.',
    VoiceCommandType.task =>
      'Confirm the category, priority, and owner before saving.',
    VoiceCommandType.journalEntry =>
      'Trim the summary, the reflection, and the next action before saving.',
    VoiceCommandType.contentIdea =>
      'Confirm the platform and content type before saving.',
    VoiceCommandType.businessOpportunity =>
      'Confirm the contact, status, and next follow-up before saving.',
    VoiceCommandType.codexPrompt =>
      'Read the prompt once more, then keep it review-first before copying it.',
    VoiceCommandType.idea =>
      'Keep it lightweight and decide whether Inbox or a project is the better home.',
    null =>
      'Choose the best local destination, then review the title before saving.',
  };
}

String _wizardSummaryFor(
  VoiceWizardStep? step,
  VoiceCommandType? inferredType,
  String prompt,
) {
  final stepLabel = step?.label ?? 'Wizard';
  final promptLabel = _buildFallbackTitle(prompt);

  return switch (step) {
    VoiceWizardStep.type =>
      'AI draft: pick the entry type first, then the assistant will shape the rest.',
    VoiceWizardStep.title =>
      'AI draft: this title step should stay short and specific.',
    VoiceWizardStep.project =>
      'AI draft: this project step should confirm the best match and keep the thread calm.',
    VoiceWizardStep.details =>
      'AI draft: this detail step should capture only the useful information for a ${_keywordLabel(inferredType)}.',
    VoiceWizardStep.review =>
      'AI draft: the assembled record is ready for a final review.',
    null => 'AI draft: $stepLabel is ready for the next wizard answer. Prompt: $promptLabel.',
  };
}

String _wizardNextStepFor(VoiceWizardStep? step, VoiceCommandType? inferredType) {
  return switch (step) {
    VoiceWizardStep.type =>
      'Say task, project, journal, content, business, idea, or Codex.',
    VoiceWizardStep.title =>
      'Use a concise title that makes the next review easy.',
    VoiceWizardStep.project =>
      'Choose the closest project and keep the next action practical.',
    VoiceWizardStep.details =>
      'Answer with only the details needed to save this ${_keywordLabel(inferredType)} cleanly.',
    VoiceWizardStep.review =>
      'Review the draft now, then save it locally when it feels right.',
    null => 'Answer the current wizard question, one step at a time.',
  };
}

List<String> _buildReviewHints({
  required VoiceAiAssistRequest request,
  required String transcript,
  required VoiceCommandType? inferredType,
}) {
  return [
    'Local AI adapter active.',
    'Review-first mode.',
    if (request.wizardStep != null) 'Wizard step: ${request.wizardStep!.label}',
    if (inferredType != null) 'Inferred type: ${inferredType.label}',
    if (transcript.isNotEmpty) 'Suggested title: ${_buildFallbackTitle(transcript)}',
    if (request.conversationContext?.hasMemory == true)
      'Remembered thread is available for review.',
  ];
}

List<String> _buildWizardHints({
  required VoiceAiAssistRequest request,
  required String transcript,
  required String prompt,
  required VoiceCommandType? inferredType,
}) {
  final hints = <String>[
    'Local AI adapter active.',
    'Review-first mode.',
    if (prompt.isNotEmpty) 'Wizard prompt is ready.',
    if (request.wizardStep != null) 'Current step: ${request.wizardStep!.label}',
  ];

  if (transcript.isNotEmpty) {
    hints.add('Draft title: ${_buildFallbackTitle(transcript)}');
  }
  if (inferredType != null) {
    hints.add('Draft type: ${inferredType.label}');
  }

  return hints;
}

List<String> _buildMemoryHints({
  required VoiceAiAssistRequest request,
  required bool hasMemory,
  required VoiceConversationContext? context,
  required String transcript,
}) {
  final hints = <String>[
    'Local AI adapter active.',
    'Review-first mode.',
    if (hasMemory) 'Remembered thread is available.',
    if (request.transcript.trim().isNotEmpty) 'Transcript can be reused.',
  ];

  if (context != null && hasMemory) {
    hints.add(context.entryCountLabel);
    hints.add('Latest entry: ${context.latestEntryPreview}');
  } else if (transcript.isNotEmpty) {
    hints.add('Draft title: ${_buildFallbackTitle(transcript)}');
  }

  return hints;
}

String _memorySummaryFor(VoiceConversationContext? context) {
  if (context == null) {
    return 'AI draft: the remembered thread can be summarized once it exists.';
  }

  final parts = <String>[
    if (context.projectName != null && context.projectName!.isNotEmpty)
      context.projectName!,
    context.threadScopeLabel,
  ];
  final memoryBase = parts.join(' / ');
  final latestEntry = _normalizeText(context.latestEntryLabel);
  final latestPreview = _normalizeText(context.latestEntryPreview);

  if (latestEntry.isNotEmpty && latestPreview.isNotEmpty) {
    return 'AI draft: remembering $memoryBase. Latest entry: $latestPreview.';
  }

  if (latestEntry.isNotEmpty) {
    return 'AI draft: remembering $memoryBase. Latest entry: $latestEntry.';
  }

  return 'AI draft: remembering $memoryBase.';
}

String _memoryNextStepFor(
  VoiceConversationContext? context,
  VoiceCommandType? inferredType,
) {
  if (context == null) {
    return 'Start a new capture or choose a starter template.';
  }

  final label = _keywordLabel(inferredType);
  return 'Reopen the $label flow, review the latest entry, and keep the next move small.';
}
