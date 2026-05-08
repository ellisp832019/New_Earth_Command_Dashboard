enum VoiceCommandType {
  task,
  journalEntry,
  contentIdea,
  businessOpportunity,
  idea,
  codexPrompt,
}

extension VoiceCommandTypeLabel on VoiceCommandType {
  String get label {
    switch (this) {
      case VoiceCommandType.task:
        return 'Task';
      case VoiceCommandType.journalEntry:
        return 'Journal Entry';
      case VoiceCommandType.contentIdea:
        return 'Content Idea';
      case VoiceCommandType.businessOpportunity:
        return 'Business Opportunity';
      case VoiceCommandType.codexPrompt:
        return 'Codex Prompt';
      case VoiceCommandType.idea:
        return 'Idea';
    }
  }
}

class VoiceCommand {
  VoiceCommand({
    required this.id,
    required this.transcript,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String transcript;
  final VoiceCommandType type;
  final DateTime createdAt;
}

class VoiceAssistantProjectOption {
  const VoiceAssistantProjectOption({required this.id, required this.name});

  final String id;
  final String name;
}

class VoiceCommandSuggestion {
  const VoiceCommandSuggestion({
    required this.transcript,
    required this.suggestedType,
    required this.suggestedTitle,
    this.extractedTaskCategory,
    this.extractedTaskPriority,
    this.extractedJournalWorkedOn,
    this.extractedJournalLearned,
    this.extractedJournalNextActions,
    this.extractedContentPlatform,
    this.extractedContentType,
    this.extractedBusinessType,
    this.extractedBusinessStatus,
    this.extractedBusinessContact,
    this.extractedBusinessNextAction,
    this.suggestedProjectId,
    this.suggestedProjectName,
    this.usedExplicitType = false,
  });

  VoiceCommandSuggestion copyWith({
    String? transcript,
    VoiceCommandType? suggestedType,
    String? suggestedTitle,
    String? extractedTaskCategory,
    String? extractedTaskPriority,
    String? extractedJournalWorkedOn,
    String? extractedJournalLearned,
    String? extractedJournalNextActions,
    String? extractedContentPlatform,
    String? extractedContentType,
    String? extractedBusinessType,
    String? extractedBusinessStatus,
    String? extractedBusinessContact,
    String? extractedBusinessNextAction,
    String? suggestedProjectId,
    String? suggestedProjectName,
    bool? usedExplicitType,
  }) {
    return VoiceCommandSuggestion(
      transcript: transcript ?? this.transcript,
      suggestedType: suggestedType ?? this.suggestedType,
      suggestedTitle: suggestedTitle ?? this.suggestedTitle,
      extractedTaskCategory:
          extractedTaskCategory ?? this.extractedTaskCategory,
      extractedTaskPriority:
          extractedTaskPriority ?? this.extractedTaskPriority,
      extractedJournalWorkedOn:
          extractedJournalWorkedOn ?? this.extractedJournalWorkedOn,
      extractedJournalLearned:
          extractedJournalLearned ?? this.extractedJournalLearned,
      extractedJournalNextActions:
          extractedJournalNextActions ?? this.extractedJournalNextActions,
      extractedContentPlatform:
          extractedContentPlatform ?? this.extractedContentPlatform,
      extractedContentType: extractedContentType ?? this.extractedContentType,
      extractedBusinessType:
          extractedBusinessType ?? this.extractedBusinessType,
      extractedBusinessStatus:
          extractedBusinessStatus ?? this.extractedBusinessStatus,
      extractedBusinessContact:
          extractedBusinessContact ?? this.extractedBusinessContact,
      extractedBusinessNextAction:
          extractedBusinessNextAction ?? this.extractedBusinessNextAction,
      suggestedProjectId: suggestedProjectId ?? this.suggestedProjectId,
      suggestedProjectName: suggestedProjectName ?? this.suggestedProjectName,
      usedExplicitType: usedExplicitType ?? this.usedExplicitType,
    );
  }

  final String transcript;
  final VoiceCommandType suggestedType;
  final String suggestedTitle;
  final String? extractedTaskCategory;
  final String? extractedTaskPriority;
  final String? extractedJournalWorkedOn;
  final String? extractedJournalLearned;
  final String? extractedJournalNextActions;
  final String? extractedContentPlatform;
  final String? extractedContentType;
  final String? extractedBusinessType;
  final String? extractedBusinessStatus;
  final String? extractedBusinessContact;
  final String? extractedBusinessNextAction;
  final String? suggestedProjectId;
  final String? suggestedProjectName;
  final bool usedExplicitType;

  bool get hasProjectSuggestion => suggestedProjectId != null;
}

class VoiceCommandTemplate {
  const VoiceCommandTemplate({
    required this.id,
    required this.label,
    required this.description,
    required this.transcript,
    required this.type,
  });

  final String id;
  final String label;
  final String description;
  final String transcript;
  final VoiceCommandType type;
}

class VoiceCommandQuickAction {
  const VoiceCommandQuickAction({
    required this.id,
    required this.label,
    required this.description,
    this.route,
    this.templateId,
  });

  final String id;
  final String label;
  final String description;
  final String? route;
  final String? templateId;
}
