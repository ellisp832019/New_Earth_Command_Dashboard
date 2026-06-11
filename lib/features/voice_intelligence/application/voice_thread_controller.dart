import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../data/voice_conversation_thread_repository.dart';

class VoiceConversationPrompt {
  const VoiceConversationPrompt({
    required this.label,
    required this.description,
    this.route,
  });

  final String label;
  final String description;
  final String? route;
}

enum VoiceConversationMessageKind { system, user, assistant, safety }

class VoiceConversationMessage {
  const VoiceConversationMessage({
    required this.id,
    required this.kind,
    required this.body,
    required this.timestamp,
    this.title,
    this.intent,
  });

  final String id;
  final VoiceConversationMessageKind kind;
  final String body;
  final DateTime timestamp;
  final String? title;
  final String? intent;
}

class VoiceConversationThreadState {
  const VoiceConversationThreadState({
    this.threadTitle = 'No thread yet',
    this.summary =
        'Start with a note, meeting, assistant question, or MicroGrow status check.',
    this.nextStep =
        'Pick a calm starting point and keep the flow review-first.',
    this.reviewPrompt = 'Review before saving keeps the flow local and safe.',
    this.resumeRoute = RouteNames.voiceNotes,
    this.latestCaptureLabel = 'Nothing captured yet',
    this.latestCapturePreview = 'Your latest capture will appear here.',
    this.lastThingYouSaid = 'Nothing yet.',
    this.prompts = const <VoiceConversationPrompt>[],
    this.conversationEntries = const <VoiceConversationMessage>[],
    this.pinnedTurnTitle,
    this.pinnedTurnBody,
    this.pinnedTurnNote,
    this.draftText = '',
    this.isSending = false,
    this.isFresh = true,
  });

  final String threadTitle;
  final String summary;
  final String nextStep;
  final String reviewPrompt;
  final String resumeRoute;
  final String latestCaptureLabel;
  final String latestCapturePreview;
  final String lastThingYouSaid;
  final List<VoiceConversationPrompt> prompts;
  final List<VoiceConversationMessage> conversationEntries;
  final String? pinnedTurnTitle;
  final String? pinnedTurnBody;
  final String? pinnedTurnNote;
  final String draftText;
  final bool isSending;
  final bool isFresh;

  VoiceConversationThreadState copyWith({
    String? threadTitle,
    String? summary,
    String? nextStep,
    String? reviewPrompt,
    String? resumeRoute,
    String? latestCaptureLabel,
    String? latestCapturePreview,
    String? lastThingYouSaid,
    List<VoiceConversationPrompt>? prompts,
    List<VoiceConversationMessage>? conversationEntries,
    String? pinnedTurnTitle,
    String? pinnedTurnBody,
    String? pinnedTurnNote,
    String? draftText,
    bool? isSending,
    bool? isFresh,
  }) {
    return VoiceConversationThreadState(
      threadTitle: threadTitle ?? this.threadTitle,
      summary: summary ?? this.summary,
      nextStep: nextStep ?? this.nextStep,
      reviewPrompt: reviewPrompt ?? this.reviewPrompt,
      resumeRoute: resumeRoute ?? this.resumeRoute,
      latestCaptureLabel: latestCaptureLabel ?? this.latestCaptureLabel,
      latestCapturePreview: latestCapturePreview ?? this.latestCapturePreview,
      lastThingYouSaid: lastThingYouSaid ?? this.lastThingYouSaid,
      prompts: prompts ?? this.prompts,
      conversationEntries: conversationEntries ?? this.conversationEntries,
      pinnedTurnTitle: pinnedTurnTitle ?? this.pinnedTurnTitle,
      pinnedTurnBody: pinnedTurnBody ?? this.pinnedTurnBody,
      pinnedTurnNote: pinnedTurnNote ?? this.pinnedTurnNote,
      draftText: draftText ?? this.draftText,
      isSending: isSending ?? this.isSending,
      isFresh: isFresh ?? this.isFresh,
    );
  }
}

class VoiceConversationThreadController
    extends Notifier<VoiceConversationThreadState> {
  bool _hasHydrated = false;
  bool _hasDirtyChanges = false;

  @override
  VoiceConversationThreadState build() {
    unawaited(_hydratePersistedThread());
    return const VoiceConversationThreadState();
  }

  void startFresh() {
    state = const VoiceConversationThreadState();
    _hasDirtyChanges = true;
    _clearPersistedState();
  }

  void ensureConversationSeeded() {
    if (state.conversationEntries.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final title = state.threadTitle == 'No thread yet'
        ? 'Voice Conversation'
        : state.threadTitle;
    final entries = <VoiceConversationMessage>[
      VoiceConversationMessage(
        id: 'voice-thread-${now.millisecondsSinceEpoch}-system',
        kind: VoiceConversationMessageKind.system,
        title: 'Conversation opened',
        body:
            'We are continuing the ${title.toLowerCase()} thread in a calm, review-first way.',
        timestamp: now,
      ),
      VoiceConversationMessage(
        id: 'voice-thread-${now.millisecondsSinceEpoch}-assistant',
        kind: VoiceConversationMessageKind.assistant,
        title: 'Dashboard reply',
        body: state.summary,
        timestamp: now,
      ),
      if (state.lastThingYouSaid.trim().isNotEmpty)
        VoiceConversationMessage(
          id: 'voice-thread-${now.millisecondsSinceEpoch}-user',
          kind: VoiceConversationMessageKind.user,
          title: 'Last thing you said',
          body: state.lastThingYouSaid,
          timestamp: now,
        ),
      VoiceConversationMessage(
        id: 'voice-thread-${now.millisecondsSinceEpoch}-next',
        kind: VoiceConversationMessageKind.assistant,
        title: 'Next step',
        body: state.nextStep,
        timestamp: now,
      ),
    ];

    state = state.copyWith(conversationEntries: entries, isFresh: false);
    _hasDirtyChanges = true;
    _persistState();
  }

  void setDraftText(String draftText) {
    state = state.copyWith(draftText: draftText);
    _hasDirtyChanges = true;
    _persistState();
  }

  void setSending(bool isSending) {
    state = state.copyWith(isSending: isSending);
    _hasDirtyChanges = true;
    _persistState();
  }

  void pinCurrentTurn({
    required String title,
    required String body,
    String? note,
  }) {
    state = state.copyWith(
      pinnedTurnTitle: title,
      pinnedTurnBody: body,
      pinnedTurnNote: note,
    );
    _hasDirtyChanges = true;
    _persistState();
  }

  void clearPinnedTurn() {
    state = state.copyWith(
      pinnedTurnTitle: null,
      pinnedTurnBody: null,
      pinnedTurnNote: null,
    );
    _hasDirtyChanges = true;
    _persistState();
  }

  void appendSystemMessage(String body, {String? title, String? intent}) {
    _appendMessage(
      VoiceConversationMessage(
        id: _messageId('system'),
        kind: VoiceConversationMessageKind.system,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        intent: intent,
      ),
    );
    _hasDirtyChanges = true;
    _persistState();
  }

  void appendUserMessage(String body, {String? title, String? intent}) {
    state = state.copyWith(
      lastThingYouSaid: body,
      draftText: '',
      isFresh: false,
    );
    _appendMessage(
      VoiceConversationMessage(
        id: _messageId('user'),
        kind: VoiceConversationMessageKind.user,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        intent: intent,
      ),
    );
    _hasDirtyChanges = true;
    _persistState();
  }

  void appendAssistantMessage(String body, {String? title, String? intent}) {
    _appendMessage(
      VoiceConversationMessage(
        id: _messageId('assistant'),
        kind: VoiceConversationMessageKind.assistant,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        intent: intent,
      ),
    );
    _hasDirtyChanges = true;
    _persistState();
  }

  void appendSafetyMessage(String body, {String? title, String? intent}) {
    _appendMessage(
      VoiceConversationMessage(
        id: _messageId('safety'),
        kind: VoiceConversationMessageKind.safety,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        intent: intent,
      ),
    );
    _hasDirtyChanges = true;
    _persistState();
  }

  void _appendMessage(VoiceConversationMessage message) {
    state = state.copyWith(
      conversationEntries: <VoiceConversationMessage>[
        ...state.conversationEntries,
        message,
      ],
    );
  }

  String _messageId(String prefix) {
    return 'voice-thread-$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  void rememberThread({
    required String threadTitle,
    required String summary,
    required String nextStep,
    required String resumeRoute,
    required String latestCaptureLabel,
    required String latestCapturePreview,
    String reviewPrompt = 'Review before saving keeps the flow local and safe.',
    bool isFresh = false,
    String? lastThingYouSaid,
    List<VoiceConversationPrompt> prompts = const <VoiceConversationPrompt>[],
  }) {
    state = state.copyWith(
      threadTitle: threadTitle,
      summary: summary,
      nextStep: nextStep,
      reviewPrompt: reviewPrompt,
      resumeRoute: resumeRoute,
      latestCaptureLabel: latestCaptureLabel,
      latestCapturePreview: latestCapturePreview,
      lastThingYouSaid: lastThingYouSaid,
      prompts: prompts,
      isFresh: isFresh,
    );
    _hasDirtyChanges = true;
    _persistState();
  }

  Future<void> _hydratePersistedThread() async {
    if (_hasHydrated) {
      return;
    }

    _hasHydrated = true;
    final repository = VoiceConversationThreadRepository(ref.read(appDatabaseProvider));
    final payloadJson = await repository.loadPersistedThreadPayload();
    if (payloadJson == null || _hasDirtyChanges) {
      return;
    }

    final decoded = repository.decodePayload(payloadJson);
    state = _stateFromJson(decoded);
    _hasDirtyChanges = false;
  }

  void _persistState() {
    unawaited(_savePersistedThread(state));
  }

  void _clearPersistedState() {
    unawaited(() async {
      final repository = VoiceConversationThreadRepository(
        ref.read(appDatabaseProvider),
      );
      await repository.clearPersistedThread();
    }());
  }

  Future<void> _savePersistedThread(
    VoiceConversationThreadState currentState,
  ) async {
    final repository = VoiceConversationThreadRepository(ref.read(appDatabaseProvider));
    await repository.savePersistedThreadPayload(
      repository.encodePayload(_stateToJson(currentState)),
    );
  }

  VoiceConversationThreadState _stateFromJson(Map<String, dynamic> json) {
    return VoiceConversationThreadState(
      threadTitle: _stringValue(json['threadTitle']) ?? 'No thread yet',
      summary: _stringValue(json['summary']) ??
          'Start with a note, meeting, assistant question, or MicroGrow status check.',
      nextStep: _stringValue(json['nextStep']) ??
          'Pick a calm starting point and keep the flow review-first.',
      reviewPrompt: _stringValue(json['reviewPrompt']) ??
          'Review before saving keeps the flow local and safe.',
      resumeRoute: _stringValue(json['resumeRoute']) ?? RouteNames.voiceNotes,
      latestCaptureLabel:
          _stringValue(json['latestCaptureLabel']) ?? 'Nothing captured yet',
      latestCapturePreview: _stringValue(json['latestCapturePreview']) ??
          'Your latest capture will appear here.',
      lastThingYouSaid: _stringValue(json['lastThingYouSaid']) ?? 'Nothing yet.',
      prompts: _listValue(json['prompts'])
          .map(_promptFromJson)
          .toList(growable: false),
      conversationEntries: _listValue(json['conversationEntries'])
          .map(_messageFromJson)
          .toList(growable: false),
      pinnedTurnTitle: _stringValue(json['pinnedTurnTitle']),
      pinnedTurnBody: _stringValue(json['pinnedTurnBody']),
      pinnedTurnNote: _stringValue(json['pinnedTurnNote']),
      draftText: _stringValue(json['draftText']) ?? '',
      isSending: json['isSending'] == true,
      isFresh: json['isFresh'] == true,
    );
  }

  Map<String, dynamic> _stateToJson(VoiceConversationThreadState value) {
    return <String, dynamic>{
      'threadTitle': value.threadTitle,
      'summary': value.summary,
      'nextStep': value.nextStep,
      'reviewPrompt': value.reviewPrompt,
      'resumeRoute': value.resumeRoute,
      'latestCaptureLabel': value.latestCaptureLabel,
      'latestCapturePreview': value.latestCapturePreview,
      'lastThingYouSaid': value.lastThingYouSaid,
      'prompts': value.prompts.map(_promptToJson).toList(growable: false),
      'conversationEntries':
          value.conversationEntries.map(_messageToJson).toList(growable: false),
      'pinnedTurnTitle': value.pinnedTurnTitle,
      'pinnedTurnBody': value.pinnedTurnBody,
      'pinnedTurnNote': value.pinnedTurnNote,
      'draftText': value.draftText,
      'isSending': value.isSending,
      'isFresh': value.isFresh,
    };
  }

  Map<String, dynamic> _promptToJson(VoiceConversationPrompt prompt) {
    return <String, dynamic>{
      'label': prompt.label,
      'description': prompt.description,
      'route': prompt.route,
    };
  }

  VoiceConversationPrompt _promptFromJson(Map<String, dynamic> json) {
    return VoiceConversationPrompt(
      label: _stringValue(json['label']) ?? 'Continue',
      description: _stringValue(json['description']) ?? '',
      route: _stringValue(json['route']),
    );
  }

  Map<String, dynamic> _messageToJson(VoiceConversationMessage message) {
    return <String, dynamic>{
      'id': message.id,
      'kind': message.kind.name,
      'body': message.body,
      'timestamp': message.timestamp.toIso8601String(),
      'title': message.title,
      'intent': message.intent,
    };
  }

  VoiceConversationMessage _messageFromJson(Map<String, dynamic> json) {
    final kindName = _stringValue(json['kind']) ?? 'system';
    final kind = VoiceConversationMessageKind.values.firstWhere(
      (candidate) => candidate.name == kindName,
      orElse: () => VoiceConversationMessageKind.system,
    );

    return VoiceConversationMessage(
      id: _stringValue(json['id']) ??
          _messageId(kind.name),
      kind: kind,
      body: _stringValue(json['body']) ?? '',
      timestamp: DateTime.tryParse(_stringValue(json['timestamp']) ?? '') ??
          DateTime.now(),
      title: _stringValue(json['title']),
      intent: _stringValue(json['intent']),
    );
  }

  List<Map<String, dynamic>> _listValue(Object? value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
