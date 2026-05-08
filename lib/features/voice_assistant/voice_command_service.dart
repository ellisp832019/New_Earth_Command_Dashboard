import 'voice_command_model.dart';

class VoiceCommandService {
  VoiceCommandService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final List<VoiceCommand> _commands = [];

  List<VoiceCommand> getHistory() {
    return List.unmodifiable(_commands.reversed);
  }

  VoiceCommand addCommand({
    required String transcript,
    required VoiceCommandType type,
  }) {
    final timestamp = _now();
    final command = VoiceCommand(
      id: timestamp.microsecondsSinceEpoch.toString(),
      transcript: transcript.trim(),
      type: type,
      createdAt: timestamp,
    );

    _commands.add(command);
    return command;
  }

  String createCodexPrompt(String transcript) {
    return '''
You are working inside the New Earth Dashboard repo.

User voice command:
${transcript.trim()}

Rules:
- Make minimal, high-confidence changes.
- Explain what files you changed.
- Do not delete existing work.
- Do not make destructive changes.
- Ask for approval before major rewrites.
''';
  }

  VoiceCommandSuggestion suggestCommand({
    required String transcript,
    List<VoiceAssistantProjectOption> projectOptions = const [],
  }) {
    final normalizedTranscript = _normalizeTranscript(transcript);
    final explicitTypeMatch = _matchExplicitType(normalizedTranscript);
    final explicitType = explicitTypeMatch?.$1;
    final cleanedTranscript = explicitTypeMatch == null
        ? normalizedTranscript
        : explicitTypeMatch.$2;
    final suggestedProject = _matchProject(cleanedTranscript, projectOptions);

    final suggestedType =
        explicitType ?? _inferTypeFromKeywords(cleanedTranscript);
    final extraction = _extractStructuredFields(
      transcript: cleanedTranscript,
      type: suggestedType,
    );

    return VoiceCommandSuggestion(
      transcript: cleanedTranscript,
      suggestedType: suggestedType,
      suggestedTitle: _titleFromTranscript(cleanedTranscript),
      extractedTaskCategory: extraction.taskCategory,
      extractedTaskPriority: extraction.taskPriority,
      extractedJournalWorkedOn: extraction.journalWorkedOn,
      extractedJournalLearned: extraction.journalLearned,
      extractedJournalNextActions: extraction.journalNextActions,
      extractedContentPlatform: extraction.contentPlatform,
      extractedContentType: extraction.contentType,
      extractedBusinessType: extraction.businessType,
      extractedBusinessStatus: extraction.businessStatus,
      extractedBusinessContact: extraction.businessContact,
      extractedBusinessNextAction: extraction.businessNextAction,
      suggestedProjectId: suggestedProject?.id,
      suggestedProjectName: suggestedProject?.name,
      usedExplicitType: explicitType != null,
    );
  }

  String _normalizeTranscript(String transcript) {
    return transcript.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  (VoiceCommandType, String)? _matchExplicitType(String transcript) {
    const prefixes = <String, VoiceCommandType>{
      'task': VoiceCommandType.task,
      'todo': VoiceCommandType.task,
      'journal': VoiceCommandType.journalEntry,
      'journal entry': VoiceCommandType.journalEntry,
      'journal note': VoiceCommandType.journalEntry,
      'content': VoiceCommandType.contentIdea,
      'content idea': VoiceCommandType.contentIdea,
      'post': VoiceCommandType.contentIdea,
      'business': VoiceCommandType.businessOpportunity,
      'business opportunity': VoiceCommandType.businessOpportunity,
      'idea': VoiceCommandType.idea,
      'future idea': VoiceCommandType.idea,
      'codex': VoiceCommandType.codexPrompt,
      'codex prompt': VoiceCommandType.codexPrompt,
    };

    final lowerTranscript = transcript.toLowerCase();
    for (final entry in prefixes.entries) {
      final pattern = RegExp('^${RegExp.escape(entry.key)}\\s*[:\\-]\\s*');
      final match = pattern.firstMatch(lowerTranscript);
      if (match != null) {
        final cleaned = transcript.substring(match.end).trim();
        return (entry.value, cleaned.isEmpty ? transcript : cleaned);
      }
    }

    return null;
  }

  VoiceAssistantProjectOption? _matchProject(
    String transcript,
    List<VoiceAssistantProjectOption> projectOptions,
  ) {
    final lowerTranscript = transcript.toLowerCase();
    final sortedProjects = [...projectOptions]
      ..sort((a, b) => b.name.length.compareTo(a.name.length));

    for (final project in sortedProjects) {
      if (lowerTranscript.contains(project.name.toLowerCase())) {
        return project;
      }
    }

    return null;
  }

  VoiceCommandType _inferTypeFromKeywords(String transcript) {
    final lowerTranscript = transcript.toLowerCase();
    final scores = <VoiceCommandType, int>{
      VoiceCommandType.task: 0,
      VoiceCommandType.journalEntry: 0,
      VoiceCommandType.contentIdea: 0,
      VoiceCommandType.businessOpportunity: 0,
      VoiceCommandType.idea: 0,
    };

    void addScore(VoiceCommandType type, List<String> keywords) {
      for (final keyword in keywords) {
        if (lowerTranscript.contains(keyword)) {
          scores[type] = scores[type]! + 1;
        }
      }
    }

    addScore(VoiceCommandType.task, [
      'task',
      'todo',
      'need to',
      'review',
      'fix',
      'update',
      'finish',
      'follow up',
      'send',
      'check',
      'build',
    ]);
    addScore(VoiceCommandType.journalEntry, [
      'journal',
      'today i',
      'worked on',
      'learned',
      'progress',
      'reflection',
      'log',
    ]);
    addScore(VoiceCommandType.contentIdea, [
      'content',
      'post',
      'video',
      'linkedin',
      'website',
      'article',
      'draft',
      'publish',
      'update',
    ]);
    addScore(VoiceCommandType.businessOpportunity, [
      'client',
      'customer',
      'partner',
      'grant',
      'funding',
      'job',
      'application',
      'apply',
      'investor',
      'contract',
      'lead',
      'business',
    ]);
    addScore(VoiceCommandType.idea, [
      'idea',
      'maybe',
      'someday',
      'brainstorm',
      'future',
      'explore',
    ]);

    final bestType = scores.entries.reduce((best, candidate) {
      if (candidate.value > best.value) {
        return candidate;
      }
      return best;
    });

    if (bestType.value > 0) {
      return bestType.key;
    }

    if (lowerTranscript.startsWith('today i') ||
        lowerTranscript.startsWith('i worked')) {
      return VoiceCommandType.journalEntry;
    }

    return VoiceCommandType.task;
  }

  String _titleFromTranscript(String transcript) {
    if (transcript.isEmpty) {
      return 'Voice capture';
    }

    final firstSentence = transcript
        .split(RegExp(r'[.!?]'))
        .first
        .trim()
        .replaceAll('"', '');

    if (firstSentence.length <= 72) {
      return firstSentence;
    }

    return '${firstSentence.substring(0, 69).trimRight()}...';
  }

  _StructuredVoiceFields _extractStructuredFields({
    required String transcript,
    required VoiceCommandType type,
  }) {
    switch (type) {
      case VoiceCommandType.task:
        return _extractTaskFields(transcript);
      case VoiceCommandType.journalEntry:
        return _extractJournalFields(transcript);
      case VoiceCommandType.contentIdea:
        return _extractContentFields(transcript);
      case VoiceCommandType.businessOpportunity:
        return _extractBusinessFields(transcript);
      case VoiceCommandType.idea:
      case VoiceCommandType.codexPrompt:
        return const _StructuredVoiceFields();
    }
  }

  _StructuredVoiceFields _extractTaskFields(String transcript) {
    final lowerTranscript = transcript.toLowerCase();

    String? category;
    if (lowerTranscript.contains('design')) {
      category = 'Design';
    } else if (lowerTranscript.contains('research')) {
      category = 'Research';
    } else if (lowerTranscript.contains('plan') ||
        lowerTranscript.contains('planning')) {
      category = 'Planning';
    } else if (lowerTranscript.contains('business')) {
      category = 'Business';
    } else if (lowerTranscript.contains('learn')) {
      category = 'Learning';
    } else if (lowerTranscript.contains('content') ||
        lowerTranscript.contains('post') ||
        lowerTranscript.contains('article')) {
      category = 'Content';
    } else if (lowerTranscript.contains('wellbeing') ||
        lowerTranscript.contains('rest')) {
      category = 'Wellbeing';
    } else if (lowerTranscript.contains('build') ||
        lowerTranscript.contains('fix') ||
        lowerTranscript.contains('code')) {
      category = 'Build';
    } else {
      category = 'Admin';
    }

    String? priority;
    if (lowerTranscript.contains('urgent') ||
        lowerTranscript.contains('asap') ||
        lowerTranscript.contains('high priority')) {
      priority = 'High';
    } else if (lowerTranscript.contains('low priority') ||
        lowerTranscript.contains('someday')) {
      priority = 'Low';
    } else if (lowerTranscript.contains('later maybe')) {
      priority = 'Someday';
    }

    return _StructuredVoiceFields(
      taskCategory: category,
      taskPriority: priority,
    );
  }

  _StructuredVoiceFields _extractJournalFields(String transcript) {
    final workedOn = _captureAfterLabel(transcript, [
      'worked on',
      'progress',
      'today i',
    ]);
    final learned = _captureAfterLabel(transcript, ['learned', 'i learned']);
    final nextActions = _captureAfterLabel(transcript, [
      'next actions',
      'next action',
      'next step',
      'tomorrow',
    ]);

    return _StructuredVoiceFields(
      journalWorkedOn: workedOn ?? transcript,
      journalLearned: learned,
      journalNextActions: nextActions,
    );
  }

  _StructuredVoiceFields _extractContentFields(String transcript) {
    final lowerTranscript = transcript.toLowerCase();

    String? platform;
    if (lowerTranscript.contains('linkedin')) {
      platform = 'LinkedIn';
    } else if (lowerTranscript.contains('website')) {
      platform = 'Website';
    } else if (lowerTranscript.contains('youtube') ||
        lowerTranscript.contains('video')) {
      platform = 'YouTube';
    } else if (lowerTranscript.contains('book')) {
      platform = 'Book';
    } else if (lowerTranscript.contains('newsletter')) {
      platform = 'Newsletter';
    }

    String? contentType;
    if (lowerTranscript.contains('linkedin')) {
      contentType = 'LinkedIn Post';
    } else if (lowerTranscript.contains('website journal')) {
      contentType = 'Website Journal';
    } else if (lowerTranscript.contains('video') ||
        lowerTranscript.contains('youtube')) {
      contentType = 'Video Script';
    } else if (lowerTranscript.contains('founder journey')) {
      contentType = 'Founder Journey';
    } else if (lowerTranscript.contains('technical')) {
      contentType = 'Technical Update';
    } else if (lowerTranscript.contains('awareness')) {
      contentType = 'Awareness Post';
    } else {
      contentType = 'Project Update';
    }

    return _StructuredVoiceFields(
      contentPlatform: platform,
      contentType: contentType,
    );
  }

  _StructuredVoiceFields _extractBusinessFields(String transcript) {
    final lowerTranscript = transcript.toLowerCase();

    String businessType = 'Business Idea';
    if (lowerTranscript.contains('job') || lowerTranscript.contains('role')) {
      businessType = 'Job';
    } else if (lowerTranscript.contains('contract')) {
      businessType = 'Contract';
    } else if (lowerTranscript.contains('grant')) {
      businessType = 'Grant';
    } else if (lowerTranscript.contains('partner')) {
      businessType = 'Partnership';
    } else if (lowerTranscript.contains('client')) {
      businessType = 'Client';
    } else if (lowerTranscript.contains('funding')) {
      businessType = 'Funding';
    } else if (lowerTranscript.contains('mentor')) {
      businessType = 'Mentor';
    } else if (lowerTranscript.contains('investor')) {
      businessType = 'Investor';
    } else if (lowerTranscript.contains('collab')) {
      businessType = 'Collaboration';
    }

    final businessStatus = lowerTranscript.contains('follow up')
        ? 'Follow-up Needed'
        : lowerTranscript.contains('apply') ||
              lowerTranscript.contains('application')
        ? 'Preparing'
        : 'Researching';

    final businessContact = _extractContactName(transcript);

    return _StructuredVoiceFields(
      businessType: businessType,
      businessStatus: businessStatus,
      businessContact: businessContact,
      businessNextAction: transcript,
    );
  }

  String? _captureAfterLabel(String transcript, List<String> labels) {
    for (final label in labels) {
      final match = RegExp(
        '(?:^|[.;])\\s*${RegExp.escape(label)}\\s*[:\\-]?\\s*(.+?)(?=(?:[.;]\\s*(?:worked on|progress|today i|learned|i learned|next actions|next action|next step|tomorrow)\\b)|\$)',
        caseSensitive: false,
      ).firstMatch(transcript);
      if (match != null) {
        final captured = match.group(1)?.trim();
        if (captured != null && captured.isNotEmpty) {
          return captured;
        }
      }
    }

    return null;
  }

  String? _extractContactName(String transcript) {
    final withMatch = RegExp(
      '\\b(?:with|at)\\s+([A-Z][A-Za-z0-9&\\- ]{1,40})',
    ).firstMatch(transcript);
    final captured = withMatch?.group(1)?.trim();
    if (captured == null || captured.isEmpty) {
      return null;
    }

    return captured.replaceAll(RegExp(r'[.,;:]$'), '').trim();
  }
}

class _StructuredVoiceFields {
  const _StructuredVoiceFields({
    this.taskCategory,
    this.taskPriority,
    this.journalWorkedOn,
    this.journalLearned,
    this.journalNextActions,
    this.contentPlatform,
    this.contentType,
    this.businessType,
    this.businessStatus,
    this.businessContact,
    this.businessNextAction,
  });

  final String? taskCategory;
  final String? taskPriority;
  final String? journalWorkedOn;
  final String? journalLearned;
  final String? journalNextActions;
  final String? contentPlatform;
  final String? contentType;
  final String? businessType;
  final String? businessStatus;
  final String? businessContact;
  final String? businessNextAction;
}
