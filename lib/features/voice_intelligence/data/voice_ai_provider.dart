import 'safety_command_gateway.dart';
import 'voice_openai_transport.dart';
import 'voice_models.dart';

abstract class VoiceAiProvider {
  const VoiceAiProvider();

  Future<VoiceTranscriptionResult> transcribe({
    required VoiceSessionMode mode,
    required String prompt,
    required VoiceRuntimeConfig config,
  });

  Future<MeetingSummaryResult> summarizeMeeting({
    required String transcript,
    required String meetingTitle,
  });

  Future<VoiceAssistantResponse> assist({
    required String message,
    required SafetyCommandGateway safetyGateway,
    String? activeProject,
  });

  Future<MicroGrowVoiceStatusResult> readMicroGrowStatus({
    required String query,
  });
}

class MockVoiceAiProvider extends VoiceAiProvider {
  const MockVoiceAiProvider();

  @override
  Future<VoiceTranscriptionResult> transcribe({
    required VoiceSessionMode mode,
    required String prompt,
    required VoiceRuntimeConfig config,
  }) async {
    final trimmedPrompt = prompt.trim();
    final transcript = trimmedPrompt.isEmpty
        ? _fallbackTranscript(mode)
        : _shapeTranscript(mode, trimmedPrompt);

    return VoiceTranscriptionResult(
      transcript: transcript,
      durationSeconds: _estimateDuration(transcript),
      mode: mode,
      providerLabel: config.canUseOpenAi
          ? 'OpenAI-ready mock transcription'
          : 'Mock transcription',
      notes: config.canUseOpenAi
          ? 'No network call was made. The module is still in mock-first mode.'
          : 'Mock mode is active and the dashboard can run offline.',
    );
  }

  @override
  Future<MeetingSummaryResult> summarizeMeeting({
    required String transcript,
    required String meetingTitle,
  }) async {
    final normalizedTranscript = transcript.trim();
    if (normalizedTranscript.isEmpty) {
      return const MeetingSummaryResult(
        summary: 'No transcript was supplied, so there is nothing to summarise yet.',
        decisions: <String>[],
        actions: <String>[],
        risks: <String>[],
        followUps: <String>[],
      );
    }

    final sentences = normalizedTranscript
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);

    final decisions = _extract(sentences, [
      'decide',
      'agreed',
      'confirmed',
      'approved',
      'decision',
    ]);
    final actions = _extract(sentences, [
      'action',
      'next',
      'will',
      'follow up',
      'owner',
      'todo',
    ]);
    final risks = _extract(sentences, [
      'risk',
      'blocker',
      'issue',
      'problem',
      'concern',
    ]);
    final followUps = _extract(sentences, [
      'follow up',
      'review',
      'check',
      'return',
      'follow-up',
    ]);

    final summary = [
      if (meetingTitle.trim().isNotEmpty) 'Summary for ${meetingTitle.trim()}.',
      if (decisions.isNotEmpty) 'Decisions were captured.',
      if (actions.isNotEmpty) 'Actions were identified.',
      if (risks.isNotEmpty) 'Risks were highlighted.',
      if (followUps.isNotEmpty) 'Follow-ups were noted.',
      if (decisions.isEmpty && actions.isEmpty && risks.isEmpty && followUps.isEmpty)
        'The transcript was read in mock mode and needs manual review.',
    ].join(' ');

    return MeetingSummaryResult(
      summary: summary,
      decisions: decisions,
      actions: actions,
      risks: risks,
      followUps: followUps,
    );
  }

  @override
  Future<VoiceAssistantResponse> assist({
    required String message,
    required SafetyCommandGateway safetyGateway,
    String? activeProject,
  }) async {
    final normalized = message.trim().toLowerCase();
    final intent = _classifyIntent(normalized);
    final safetyDecision = safetyGateway.evaluate(
      SafetyCommandRequest(
        rawText: message,
        intent: intent,
        parameters: <String, Object?>{
          if (activeProject?.trim().isNotEmpty == true)
            'activeProject': activeProject!.trim(),
        },
      ),
    );

    if (!safetyDecision.allowed) {
      return VoiceAssistantResponse(
        reply:
            'I can help with the dashboard request, but that action is blocked for V1: ${safetyDecision.reason}',
        intents: <String>[intent],
        actions: const <VoiceCommandAction>[],
        spokenReply: 'That action is blocked in V1.',
        safetyDecision: safetyDecision,
      );
    }

    final actions = <VoiceCommandAction>[];
    String reply;

    if (intent == 'microgrow.status.read') {
      reply =
          'I can read MicroGrow status safely. Ask for temperature, humidity, relay state, or warnings.';
    } else if (intent == 'meeting.summary.create') {
      actions.add(const VoiceCommandAction(type: 'meeting.summary.create', status: 'draft'));
      reply =
          'I drafted a meeting summary flow and kept it review-first for local saving.';
    } else if (intent == 'dashboard.task.create') {
      actions.add(const VoiceCommandAction(type: 'task.create', status: 'draft'));
      reply =
          'I created a draft task response and kept the action local and review-first.';
    } else if (intent == 'dashboard.note.create') {
      actions.add(const VoiceCommandAction(type: 'note.create', status: 'draft'));
      reply = activeProject?.trim().isNotEmpty == true
          ? 'I drafted a note for ${activeProject!.trim()}.'
          : 'I drafted a note and kept it local for review.';
    } else {
      actions.add(const VoiceCommandAction(type: 'dashboard.assistant.reply', status: 'mock'));
      reply =
          'I read your request and returned a calm mock reply without touching hardware.';
    }

    return VoiceAssistantResponse(
      reply: reply,
      intents: <String>[intent],
      actions: actions,
      spokenReply: _spokenReply(reply),
      safetyDecision: safetyDecision,
    );
  }

  @override
  Future<MicroGrowVoiceStatusResult> readMicroGrowStatus({
    required String query,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.contains('offline') || normalizedQuery.contains('down')) {
      return const MicroGrowVoiceStatusResult(
        nodeOnline: false,
        temperatureC: null,
        humidityPercent: null,
        relays: <String, bool>{},
        warnings: <String>[
          'MicroGrow node is offline in mock mode.',
          'No live hardware call was made.',
        ],
        querySummary: 'The node looks offline, so only a safe error can be shown.',
      );
    }

    final relays = <String, bool>{
      'ch1': false,
      'ch2': false,
      'ch3': true,
    };

    final warnings = <String>[
      if (normalizedQuery.contains('temperature') || normalizedQuery.contains('humidity'))
        'This is a mock read-only status response.',
      if (normalizedQuery.contains('warning'))
        'No live warnings were returned from the mock adapter.',
    ];

    return MicroGrowVoiceStatusResult(
      nodeOnline: true,
      temperatureC: 23.4,
      humidityPercent: 51.2,
      relays: relays,
      warnings: warnings,
      querySummary: 'Mock read-only status returned for the requested MicroGrow query.',
    );
  }

  String _fallbackTranscript(VoiceSessionMode mode) {
    return switch (mode) {
      VoiceSessionMode.voiceNote =>
        'I captured a calm voice note about the dashboard voice workflow and the next safe step.',
      VoiceSessionMode.meeting =>
        'The meeting focused on the dashboard voice module, a safe MicroGrow status bridge, and review-first delivery.',
      VoiceSessionMode.assistant =>
        'Draft a safe dashboard action and keep hardware control blocked.',
      VoiceSessionMode.microgrowStatus =>
        'What is the current MicroGrow status?',
    };
  }

  String _shapeTranscript(VoiceSessionMode mode, String prompt) {
    return switch (mode) {
      VoiceSessionMode.voiceNote =>
        'Voice note: $prompt. Next step: review the transcript and save it locally.',
      VoiceSessionMode.meeting =>
        'Meeting transcript: $prompt. Focus on decisions, actions, risks, and follow-ups.',
      VoiceSessionMode.assistant =>
        'Assistant request: $prompt. Keep the response local-first and safe.',
      VoiceSessionMode.microgrowStatus =>
        'MicroGrow query: $prompt. Read status only and do not send hardware commands.',
    };
  }

  int _estimateDuration(String transcript) {
    final words = transcript.trim().isEmpty
        ? 0
        : transcript.trim().split(RegExp(r'\s+')).length;
    return (words / 2.2).ceil().clamp(6, 180);
  }

  List<String> _extract(List<String> sentences, List<String> keywords) {
    final extracted = <String>[];
    for (final sentence in sentences) {
      final lowered = sentence.toLowerCase();
      if (keywords.any(lowered.contains)) {
        extracted.add(sentence.trim());
      }
    }
    return extracted;
  }

  String _classifyIntent(String text) {
    if (text.contains('relay') ||
        text.contains('mist') ||
        text.contains('heater') ||
        text.contains('pump')) {
      return 'microgrow.relay.set';
    }

    if (text.contains('temperature') ||
        text.contains('humidity') ||
        text.contains('warning') ||
        text.contains('microgrow')) {
      return 'microgrow.status.read';
    }

    if (text.contains('meeting') || text.contains('summary')) {
      return 'meeting.summary.create';
    }

    if (text.contains('task') || text.contains('todo') || text.contains('follow up')) {
      return 'dashboard.task.create';
    }

    return 'dashboard.note.create';
  }

  String _spokenReply(String reply) {
    return reply.length <= 120 ? reply : '${reply.substring(0, 117)}...';
  }
}

class OpenAiVoiceAiProvider extends MockVoiceAiProvider {
  const OpenAiVoiceAiProvider({
    required this.runtimeConfig,
    VoiceOpenAiTransport? transport,
  }) : _transport = transport;

  final VoiceRuntimeConfig runtimeConfig;
  final VoiceOpenAiTransport? _transport;

  VoiceOpenAiTransport get _resolvedTransport {
    return _transport ?? VoiceOpenAiTransport(apiKey: runtimeConfig.apiKey);
  }

  @override
  Future<VoiceTranscriptionResult> transcribe({
    required VoiceSessionMode mode,
    required String prompt,
    required VoiceRuntimeConfig config,
  }) async {
    if (!runtimeConfig.canUseOpenAi) {
      return super.transcribe(
        mode: mode,
        prompt: prompt,
        config: config,
      );
    }

    try {
      final transcript = await _resolvedTransport.completeText(
        model: config.transcriptionModel,
        instructions:
            'Shape the user prompt into a calm dashboard voice transcript draft. Keep it short, readable, and safe. Mention that hardware control stays blocked if the user asks for actions.',
        input:
            'Mode: ${mode.name}\nPrompt: ${prompt.trim().isEmpty ? _fallbackPromptForMode(mode) : prompt.trim()}',
      );

      return VoiceTranscriptionResult(
        transcript: transcript,
        durationSeconds: _estimateDuration(transcript),
        mode: mode,
        providerLabel: 'OpenAI transcription mode',
        notes:
            'OpenAI text transport was used. Recording and review stay local-first.',
      );
    } catch (_) {
      return super.transcribe(
        mode: mode,
        prompt: prompt,
        config: config,
      );
    }
  }

  @override
  Future<MeetingSummaryResult> summarizeMeeting({
    required String transcript,
    required String meetingTitle,
  }) async {
    if (!runtimeConfig.canUseOpenAi) {
      return super.summarizeMeeting(
        transcript: transcript,
        meetingTitle: meetingTitle,
      );
    }

    try {
      final summaryJson = await _resolvedTransport.completeJson(
        model: runtimeConfig.transcriptionModel,
        instructions:
            'Return strict JSON with keys summary, decisions, actions, risks, followUps. Keep values concise, clear, and review-first.',
        input:
            'Meeting title: ${meetingTitle.trim()}\nTranscript:\n${transcript.trim()}',
      );

      return MeetingSummaryResult(
        summary: summaryJson['summary']?.toString() ??
            'OpenAI meeting summary draft is ready for review.',
        decisions: _stringList(summaryJson['decisions']),
        actions: _stringList(summaryJson['actions']),
        risks: _stringList(summaryJson['risks']),
        followUps: _stringList(summaryJson['followUps']),
      );
    } catch (_) {
      return super.summarizeMeeting(
        transcript: transcript,
        meetingTitle: meetingTitle,
      );
    }
  }

  @override
  Future<VoiceAssistantResponse> assist({
    required String message,
    required SafetyCommandGateway safetyGateway,
    String? activeProject,
  }) async {
    if (!runtimeConfig.canUseOpenAi) {
      return super.assist(
        message: message,
        safetyGateway: safetyGateway,
        activeProject: activeProject,
      );
    }

    final normalized = message.trim().toLowerCase();
    final intent = _classifyIntent(normalized);
    final safetyDecision = safetyGateway.evaluate(
      SafetyCommandRequest(
        rawText: message,
        intent: intent,
        parameters: <String, Object?>{
          if (activeProject?.trim().isNotEmpty == true)
            'activeProject': activeProject!.trim(),
        },
      ),
    );

    if (!safetyDecision.allowed) {
      return VoiceAssistantResponse(
        reply:
            'I can help with the dashboard request, but that action is blocked for V1: ${safetyDecision.reason}',
        intents: <String>[intent],
        actions: const <VoiceCommandAction>[],
        spokenReply: 'That action is blocked in V1.',
        safetyDecision: safetyDecision,
      );
    }

    try {
      final reply = await _resolvedTransport.completeText(
        model: runtimeConfig.transcriptionModel,
        instructions:
            'You are a calm dashboard assistant. Reply in one or two short paragraphs. Keep hardware writes blocked in V1 and suggest safe next steps only.',
        input:
            'User message: ${message.trim()}\nActive project: ${activeProject?.trim().isEmpty == true ? 'none' : activeProject?.trim() ?? 'none'}\nIntent: $intent',
      );

      return VoiceAssistantResponse(
        reply: reply,
        intents: <String>[intent],
        actions: _actionsForIntent(intent),
        spokenReply: _spokenReply(reply),
        safetyDecision: safetyDecision,
      );
    } catch (_) {
      return super.assist(
        message: message,
        safetyGateway: safetyGateway,
        activeProject: activeProject,
      );
    }
  }

  String _fallbackPromptForMode(VoiceSessionMode mode) {
    return switch (mode) {
      VoiceSessionMode.voiceNote =>
        'I captured a calm voice note about the dashboard voice workflow and the next safe step.',
      VoiceSessionMode.meeting =>
        'The meeting focused on the dashboard voice module, a safe MicroGrow status bridge, and review-first delivery.',
      VoiceSessionMode.assistant =>
        'Draft a safe dashboard action and keep hardware control blocked.',
      VoiceSessionMode.microgrowStatus =>
        'What is the current MicroGrow status?',
    };
  }

  List<String> _stringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }

    return value.map((item) => item.toString()).toList(growable: false);
  }

  List<VoiceCommandAction> _actionsForIntent(String intent) {
    return switch (intent) {
      'microgrow.status.read' => const <VoiceCommandAction>[],
      'meeting.summary.create' => const [
        VoiceCommandAction(type: 'meeting.summary.create', status: 'draft'),
      ],
      'dashboard.task.create' => const [
        VoiceCommandAction(type: 'task.create', status: 'draft'),
      ],
      'dashboard.note.create' => const [
        VoiceCommandAction(type: 'note.create', status: 'draft'),
      ],
      _ => const [
        VoiceCommandAction(type: 'dashboard.assistant.reply', status: 'openai'),
      ],
    };
  }

}
