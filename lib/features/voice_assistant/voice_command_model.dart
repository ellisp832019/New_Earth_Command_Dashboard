enum VoiceCommandType {
  task,
  project,
  journalEntry,
  contentIdea,
  businessOpportunity,
  idea,
  codexPrompt,
}

VoiceCommandType? parseVoiceCommandType(String? value) {
  switch (value) {
    case 'task':
      return VoiceCommandType.task;
    case 'project':
      return VoiceCommandType.project;
    case 'journalEntry':
      return VoiceCommandType.journalEntry;
    case 'contentIdea':
      return VoiceCommandType.contentIdea;
    case 'businessOpportunity':
      return VoiceCommandType.businessOpportunity;
    case 'idea':
      return VoiceCommandType.idea;
    case 'codexPrompt':
      return VoiceCommandType.codexPrompt;
    default:
      return null;
  }
}

extension VoiceCommandTypeLabel on VoiceCommandType {
  String get label {
    switch (this) {
      case VoiceCommandType.task:
        return 'Task';
      case VoiceCommandType.project:
        return 'Project';
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

enum VoiceWizardStep { type, title, project, details, review }

extension VoiceWizardStepLabel on VoiceWizardStep {
  String get label {
    switch (this) {
      case VoiceWizardStep.type:
        return 'Type';
      case VoiceWizardStep.title:
        return 'Title';
      case VoiceWizardStep.project:
        return 'Project';
      case VoiceWizardStep.details:
        return 'Details';
      case VoiceWizardStep.review:
        return 'Review';
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
    this.usedWakePhrase = false,
    this.isWakeOnly = false,
    this.wakePhrase,
    this.extractedTaskCategory,
    this.extractedTaskPriority,
    this.extractedProjectStatus,
    this.extractedProjectPriority,
    this.extractedProjectVision,
    this.extractedProjectNextAction,
    this.extractedProjectNotes,
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
    bool? usedWakePhrase,
    bool? isWakeOnly,
    String? wakePhrase,
    String? extractedTaskCategory,
    String? extractedTaskPriority,
    String? extractedProjectStatus,
    String? extractedProjectPriority,
    String? extractedProjectVision,
    String? extractedProjectNextAction,
    String? extractedProjectNotes,
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
      usedWakePhrase: usedWakePhrase ?? this.usedWakePhrase,
      isWakeOnly: isWakeOnly ?? this.isWakeOnly,
      wakePhrase: wakePhrase ?? this.wakePhrase,
      extractedTaskCategory:
          extractedTaskCategory ?? this.extractedTaskCategory,
      extractedTaskPriority:
          extractedTaskPriority ?? this.extractedTaskPriority,
      extractedProjectStatus:
          extractedProjectStatus ?? this.extractedProjectStatus,
      extractedProjectPriority:
          extractedProjectPriority ?? this.extractedProjectPriority,
      extractedProjectVision:
          extractedProjectVision ?? this.extractedProjectVision,
      extractedProjectNextAction:
          extractedProjectNextAction ?? this.extractedProjectNextAction,
      extractedProjectNotes:
          extractedProjectNotes ?? this.extractedProjectNotes,
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
  final bool usedWakePhrase;
  final bool isWakeOnly;
  final String? wakePhrase;
  final String? extractedTaskCategory;
  final String? extractedTaskPriority;
  final String? extractedProjectStatus;
  final String? extractedProjectPriority;
  final String? extractedProjectVision;
  final String? extractedProjectNextAction;
  final String? extractedProjectNotes;
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

class VoiceCommandAssistantResponse {
  const VoiceCommandAssistantResponse({
    required this.summary,
    required this.nextStep,
    this.projectContext,
    this.threadContext,
  });

  final String summary;
  final String nextStep;
  final String? projectContext;
  final String? threadContext;
}

class VoiceCommandBriefing {
  const VoiceCommandBriefing({
    required this.summary,
    required this.nextStep,
    required this.actions,
    this.projectContext,
    this.threadContext,
    this.memorySummary,
    this.memoryHighlights = const [],
    this.plannerSummary,
    this.plannerSteps = const [],
  });

  final String summary;
  final String nextStep;
  final String? projectContext;
  final String? threadContext;
  final List<VoiceCommandQuickAction> actions;
  final String? memorySummary;
  final List<String> memoryHighlights;
  final String? plannerSummary;
  final List<String> plannerSteps;
}

class VoiceConversationContext {
  const VoiceConversationContext({
    required this.label,
    required this.summary,
    this.type,
    this.projectId,
    this.projectName,
    this.title,
    this.transcript,
    this.entryCount = 0,
  });

  VoiceConversationContext copyWith({
    String? label,
    String? summary,
    VoiceCommandType? type,
    String? projectId,
    String? projectName,
    String? title,
    String? transcript,
    int? entryCount,
  }) {
    return VoiceConversationContext(
      label: label ?? this.label,
      summary: summary ?? this.summary,
      type: type ?? this.type,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      title: title ?? this.title,
      transcript: transcript ?? this.transcript,
      entryCount: entryCount ?? this.entryCount,
    );
  }

  final String label;
  final String summary;
  final VoiceCommandType? type;
  final String? projectId;
  final String? projectName;
  final String? title;
  final String? transcript;
  final int entryCount;

  String get threadScopeLabel {
    final parts = <String>[
      if (projectName != null && projectName!.isNotEmpty) projectName!,
      type?.label ?? label,
    ];

    return parts.join(' · ');
  }

  String get latestEntryLabel {
    final latestTitle = title?.trim();
    if (latestTitle != null && latestTitle.isNotEmpty) {
      return latestTitle;
    }

    final latestTranscript = transcript?.trim();
    if (latestTranscript != null && latestTranscript.isNotEmpty) {
      return latestTranscript;
    }

    return label;
  }

  bool get hasMemory =>
      type != null || projectId != null || projectName != null || title != null;
}
