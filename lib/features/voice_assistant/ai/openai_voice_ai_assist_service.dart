import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../voice_command_model.dart';
import 'voice_ai_assist_service.dart';

enum VoiceAiAssistRequestKind { review, wizard, memory, conversation }

class OpenAIVoiceAiAssistService extends VoiceAiAssistService {
  OpenAIVoiceAiAssistService({
    HttpClient? httpClient,
    String? apiKey,
    String? model,
    String? baseUrl,
    bool allowMissingApiKey = false,
    Duration timeout = const Duration(seconds: 25),
  }) : _httpClient = httpClient ?? HttpClient(),
       _ownsHttpClient = httpClient == null,
       _apiKey = apiKey ?? Platform.environment['OPENAI_API_KEY'],
       _model =
           model ??
           Platform.environment['OPENAI_VOICE_MODEL'] ??
           'gpt-realtime-2',
       _baseUrl = _normalizeVoiceAiBaseUrl(
         baseUrl ??
             Platform.environment['OPENAI_BASE_URL'] ??
             'https://api.openai.com/v1',
       ),
       _allowMissingApiKey = allowMissingApiKey,
       _timeout = timeout;

  final HttpClient _httpClient;
  final bool _ownsHttpClient;
  final String? _apiKey;
  final String _model;
  final String _baseUrl;
  final bool _allowMissingApiKey;
  final Duration _timeout;

  bool get isConfigured =>
      !kIsWeb && (_allowMissingApiKey || _apiKey?.trim().isNotEmpty == true);

  @override
  Future<VoiceAiAssistResponse> reviewTranscript(
    VoiceAiAssistRequest request,
  ) async {
    final fallback = LocalVoiceAiAssistService().reviewTranscript(request);
    return _complete(
      requestKind: VoiceAiAssistRequestKind.review,
      request: request,
      fallback: await fallback,
    );
  }

  @override
  Future<VoiceAiAssistResponse> guideWizard(
    VoiceAiAssistRequest request,
  ) async {
    final fallback = LocalVoiceAiAssistService().guideWizard(request);
    return _complete(
      requestKind: VoiceAiAssistRequestKind.wizard,
      request: request,
      fallback: await fallback,
    );
  }

  @override
  Future<VoiceAiAssistResponse> summarizeMemory(
    VoiceAiAssistRequest request,
  ) async {
    final fallback = LocalVoiceAiAssistService().summarizeMemory(request);
    return _complete(
      requestKind: VoiceAiAssistRequestKind.memory,
      request: request,
      fallback: await fallback,
    );
  }

  @override
  Future<VoiceAiAssistResponse> conversationTurn(
    VoiceAiAssistRequest request,
  ) async {
    final fallback = LocalVoiceAiAssistService().conversationTurn(request);
    return _complete(
      requestKind: VoiceAiAssistRequestKind.conversation,
      request: request,
      fallback: await fallback,
    );
  }

  Future<VoiceAiAssistResponse> _complete({
    required VoiceAiAssistRequestKind requestKind,
    required VoiceAiAssistRequest request,
    required VoiceAiAssistResponse fallback,
  }) async {
    if (!isConfigured) {
      return fallback;
    }

    try {
      final responseText = await _sendCompletion(
        requestKind: requestKind,
        request: request,
      );
      final parsed = parseOpenAiVoiceAiAssistResponse(
        responseText,
        fallback: fallback,
      );

      final hints = <String>[
        ...parsed.hints,
        if (_allowMissingApiKey)
          'Local Ollama chat mode active.'
        else
          'OpenAI chat mode active.',
      ];
      return parsed.copyWith(hints: hints);
    } catch (_) {
      return fallback;
    }
  }

  Future<String> _sendCompletion({
    required VoiceAiAssistRequestKind requestKind,
    required VoiceAiAssistRequest request,
  }) async {
    final apiKey = _apiKey?.trim();
    if (!_allowMissingApiKey && (apiKey == null || apiKey.isEmpty)) {
      throw StateError('OpenAI API key is missing.');
    }

    final uri = Uri.parse('$_baseUrl/chat/completions');
    final payload = jsonEncode(<String, Object?>{
      'model': _model,
      'temperature': 0.35,
      'max_tokens': 420,
      'messages': <Map<String, Object>>[
        <String, Object>{'role': 'system', 'content': _buildSystemPrompt()},
        <String, Object>{
          'role': 'user',
          'content': _buildUserPrompt(
            requestKind: requestKind,
            request: request,
          ),
        },
      ],
    });

    final clientRequest = await _httpClient.postUrl(uri).timeout(_timeout);
    clientRequest.headers.contentType = ContentType.json;
    if (apiKey != null && apiKey.isNotEmpty) {
      clientRequest.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $apiKey',
      );
    }
    clientRequest.write(payload);

    final response = await clientRequest.close().timeout(_timeout);
    final body = await utf8.decoder.bind(response).join().timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'OpenAI request failed with status ${response.statusCode}: $body',
        uri: uri,
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected OpenAI response format.');
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const FormatException('OpenAI response did not include choices.');
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      throw const FormatException('OpenAI choice payload was malformed.');
    }

    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) {
      throw const FormatException('OpenAI message payload was malformed.');
    }

    final content = message['content'];
    if (content is String) {
      return content;
    }

    if (content is List) {
      final buffer = StringBuffer();
      for (final part in content) {
        if (part is Map<String, dynamic>) {
          final text = part['text'];
          if (text is String && text.trim().isNotEmpty) {
            if (buffer.isNotEmpty) {
              buffer.write(' ');
            }
            buffer.write(text.trim());
          }
        }
      }
      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    throw const FormatException('OpenAI message content was empty.');
  }

  String _buildSystemPrompt() {
    return [
      'You are Gaia, a calm local-first voice copilot for the New Earth Command Dashboard.',
      'Keep replies short, warm, practical, and review-first.',
      'When the user is speaking conversationally, answer naturally but stay brief and helpful.',
      'Prefer Parked or Carry Forward over failure language.',
      'Do not overwrite the raw transcript.',
      'Do not sound chatty or dramatic.',
      'The user should hear a natural spoken reply that feels responsive and useful.',
      'Return plain text only in this exact format:',
      'SUMMARY: one short sentence',
      'NEXT_STEP: one short sentence',
      'TITLE: one short title or the word none',
      'SUGGESTED_SUMMARY: one short draft summary or the word none',
      'SUGGESTED_WIZARD_ANSWER: one short answer or the word none',
      'TYPE: task, project, journalEntry, contentIdea, businessOpportunity, idea, codexPrompt, or none',
      'HINTS: short hint 1 | short hint 2 | short hint 3',
    ].join('\n');
  }

  String _buildUserPrompt({
    required VoiceAiAssistRequestKind requestKind,
    required VoiceAiAssistRequest request,
  }) {
    final buffer = StringBuffer()
      ..writeln('Request kind: ${requestKind.name}')
      ..writeln('Transcript: ${request.transcript.trim()}')
      ..writeln('Prompt: ${request.prompt?.trim() ?? 'none'}')
      ..writeln('Selected type: ${request.selectedType?.name ?? 'none'}')
      ..writeln('Wizard step: ${request.wizardStep?.name ?? 'none'}')
      ..writeln(
        'Conversation context: ${_formatConversationContext(request.conversationContext)}',
      )
      ..writeln(
        'If the transcript is empty, help the user continue the thread instead of inventing facts.',
      )
      ..writeln(
        'Keep the response concise enough for speech and clear enough for review.',
      );

    switch (requestKind) {
      case VoiceAiAssistRequestKind.review:
        buffer.writeln(
          'Focus on the best calm briefing, the next step, and the most likely destination type.',
        );
        break;
      case VoiceAiAssistRequestKind.wizard:
        buffer.writeln(
          'Focus on the current wizard question and give the best one-line answer for the step.',
        );
        break;
      case VoiceAiAssistRequestKind.memory:
        buffer.writeln(
          'Focus on summarizing the remembered thread and the next small move.',
        );
        break;
      case VoiceAiAssistRequestKind.conversation:
        buffer.writeln(
          'Focus on a calm conversational reply that sounds like a helpful assistant, then keep the next step short and practical.',
        );
        break;
    }

    return buffer.toString().trim();
  }

  String _formatConversationContext(VoiceConversationContext? context) {
    if (context == null) {
      return 'none';
    }

    final parts = <String>[
      if (context.projectName != null && context.projectName!.isNotEmpty)
        'project=${context.projectName}',
      'label=${context.label}',
      'summary=${context.summary}',
      if (context.type != null) 'type=${context.type!.name}',
      if (context.title != null && context.title!.isNotEmpty)
        'title=${context.title}',
      if (context.transcript != null && context.transcript!.isNotEmpty)
        'latest=${context.transcript}',
      'entries=${context.entryCount}',
    ];

    return parts.join(' | ');
  }

  void dispose() {
    if (_ownsHttpClient) {
      _httpClient.close(force: true);
    }
  }
}

String _normalizeVoiceAiBaseUrl(String rawBaseUrl) {
  final trimmed = rawBaseUrl.trim();
  if (trimmed.isEmpty) {
    return 'https://api.openai.com/v1';
  }

  final withoutTrailingSlash = trimmed.endsWith('/')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
  if (withoutTrailingSlash.endsWith('/v1')) {
    return withoutTrailingSlash;
  }

  return '$withoutTrailingSlash/v1';
}

@visibleForTesting
VoiceAiAssistResponse parseOpenAiVoiceAiAssistResponse(
  String responseText, {
  required VoiceAiAssistResponse fallback,
}) {
  final parsed = _ParsedVoiceAiAssistResponse.fromText(responseText);
  return fallback.copyWith(
    summary: parsed.summary?.isNotEmpty == true
        ? parsed.summary
        : fallback.summary,
    nextStep: parsed.nextStep?.isNotEmpty == true
        ? parsed.nextStep
        : fallback.nextStep,
    suggestedTitle:
        parsed.suggestedTitle?.isNotEmpty == true &&
            parsed.suggestedTitle!.toLowerCase() != 'none'
        ? parsed.suggestedTitle
        : fallback.suggestedTitle,
    suggestedSummary:
        parsed.suggestedSummary?.isNotEmpty == true &&
            parsed.suggestedSummary!.toLowerCase() != 'none'
        ? parsed.suggestedSummary
        : fallback.suggestedSummary,
    suggestedWizardAnswer:
        parsed.suggestedWizardAnswer?.isNotEmpty == true &&
            parsed.suggestedWizardAnswer!.toLowerCase() != 'none'
        ? parsed.suggestedWizardAnswer
        : fallback.suggestedWizardAnswer,
    suggestedType: parsed.suggestedType ?? fallback.suggestedType,
    hints: parsed.hints.isNotEmpty ? parsed.hints : fallback.hints,
  );
}

class _ParsedVoiceAiAssistResponse {
  const _ParsedVoiceAiAssistResponse({
    this.summary,
    this.nextStep,
    this.suggestedTitle,
    this.suggestedSummary,
    this.suggestedWizardAnswer,
    this.suggestedType,
    this.hints = const <String>[],
  });

  factory _ParsedVoiceAiAssistResponse.fromText(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String? readValue(String prefix) {
      for (final line in lines) {
        if (line.toLowerCase().startsWith(prefix.toLowerCase())) {
          return line.substring(prefix.length).trim();
        }
      }
      return null;
    }

    final summary = readValue('SUMMARY:');
    final nextStep = readValue('NEXT_STEP:');
    final suggestedTitle = readValue('TITLE:');
    final suggestedSummary = readValue('SUGGESTED_SUMMARY:');
    final suggestedWizardAnswer = readValue('SUGGESTED_WIZARD_ANSWER:');
    final typeValue = readValue('TYPE:');
    final hintsValue = readValue('HINTS:');

    final hints = <String>[];
    if (hintsValue != null && hintsValue.isNotEmpty) {
      hints.addAll(
        hintsValue
            .split('|')
            .map((hint) => hint.trim())
            .where((hint) => hint.isNotEmpty),
      );
    }

    return _ParsedVoiceAiAssistResponse(
      summary: summary,
      nextStep: nextStep,
      suggestedTitle: suggestedTitle,
      suggestedSummary: suggestedSummary,
      suggestedWizardAnswer: suggestedWizardAnswer,
      suggestedType: parseVoiceCommandType(_normalizeTypeValue(typeValue)),
      hints: hints,
    );
  }

  final String? summary;
  final String? nextStep;
  final String? suggestedTitle;
  final String? suggestedSummary;
  final String? suggestedWizardAnswer;
  final VoiceCommandType? suggestedType;
  final List<String> hints;
}

String _normalizeTypeValue(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return '';
  }

  final lower = normalized.toLowerCase();
  return switch (lower) {
    'task' => 'task',
    'project' => 'project',
    'journalentry' => 'journalEntry',
    'journal entry' => 'journalEntry',
    'contentidea' => 'contentIdea',
    'content idea' => 'contentIdea',
    'businessopportunity' => 'businessOpportunity',
    'business opportunity' => 'businessOpportunity',
    'idea' => 'idea',
    'codexprompt' => 'codexPrompt',
    'codex prompt' => 'codexPrompt',
    _ => '',
  };
}
