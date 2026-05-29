import 'voice_command_model.dart';

class VoiceCommandService {
  VoiceCommandService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final List<VoiceCommand> _commands = [];
  static const List<VoiceCommandTemplate> _templates = [
    VoiceCommandTemplate(
      id: 'build-day',
      label: 'Build Day',
      description: 'Kick off a calm build-day planning flow.',
      transcript:
          'Start my build day. Review today\'s focus, top 3 tasks, blockers, and the next practical step.',
      type: VoiceCommandType.task,
    ),
    VoiceCommandTemplate(
      id: 'summarize-today',
      label: 'Summarize Today',
      description: 'Turn the day into a quick review or journal note.',
      transcript:
          'Journal: Summarise today\'s progress, blockers, and next steps.',
      type: VoiceCommandType.journalEntry,
    ),
    VoiceCommandTemplate(
      id: 'whats-next',
      label: 'What\'s Next',
      description: 'Ask the assistant for the next practical move.',
      transcript:
          'Task: What should I do next? Review today\'s focus, the Top 3, blockers, and the next practical step.',
      type: VoiceCommandType.task,
    ),
    VoiceCommandTemplate(
      id: 'recall-thread',
      label: 'Recall Memory',
      description: 'Ask Gaia what she remembers about the current thread.',
      transcript:
          'What do you remember about this thread? Tell me the thread, recent captures, and the next useful move.',
      type: VoiceCommandType.journalEntry,
    ),
    VoiceCommandTemplate(
      id: 'plan-day',
      label: 'Plan Day',
      description: 'Turn the current thread into a short action plan.',
      transcript:
          'Plan my day around this thread. Give me a short action plan, the next move, and the best place to save it.',
      type: VoiceCommandType.task,
    ),
    VoiceCommandTemplate(
      id: 'project',
      label: 'Project',
      description: 'Shape a new project from the voice thread.',
      transcript:
          'Project: Create a project for the dashboard voice workflow and define the first milestone.',
      type: VoiceCommandType.project,
    ),
    VoiceCommandTemplate(
      id: 'carry-forward',
      label: 'Carry Forward',
      description: 'Move unfinished work into the next calm step.',
      transcript:
          'Task: Carry forward my unfinished top tasks and show me the next practical step.',
      type: VoiceCommandType.task,
    ),
    VoiceCommandTemplate(
      id: 'meeting-notes',
      label: 'Meeting Notes',
      description: 'Turn a meeting into a summary with follow-ups.',
      transcript:
          'Journal: Turn these meeting notes into a clear summary, decisions, and follow-up actions.',
      type: VoiceCommandType.journalEntry,
    ),
    VoiceCommandTemplate(
      id: 'project-checkpoint',
      label: 'Project Checkpoint',
      description: 'Review the current project shape and next move.',
      transcript:
          'Project: Review the current project checkpoint, status, and next action.',
      type: VoiceCommandType.project,
    ),
    VoiceCommandTemplate(
      id: 'business-follow-up',
      label: 'Business Follow-up',
      description: 'Capture a clear next step for a lead or partner.',
      transcript:
          'Business: Follow up on the lead, confirm the status, and define the next contact step.',
      type: VoiceCommandType.businessOpportunity,
    ),
    VoiceCommandTemplate(
      id: 'quick-review',
      label: 'Quick Review',
      description: 'Turn a rough thought into a short review note.',
      transcript:
          'Journal: Give me a quick review of today, the blockers, and what should carry forward.',
      type: VoiceCommandType.journalEntry,
    ),
    VoiceCommandTemplate(
      id: 'task',
      label: 'Task',
      description: 'Capture one clear action.',
      transcript:
          'Task: Review the dashboard cards and tighten the wording before the next pass.',
      type: VoiceCommandType.task,
    ),
    VoiceCommandTemplate(
      id: 'journal',
      label: 'Journal',
      description: 'Log what moved forward today.',
      transcript:
          'Journal: Today I improved the voice assistant review flow and learned how to keep it calm.',
      type: VoiceCommandType.journalEntry,
    ),
    VoiceCommandTemplate(
      id: 'content',
      label: 'Content',
      description: 'Turn progress into something publishable.',
      transcript:
          'Content: Draft a LinkedIn update about the new voice workflow and why review-first capture matters.',
      type: VoiceCommandType.contentIdea,
    ),
    VoiceCommandTemplate(
      id: 'business',
      label: 'Business',
      description: 'Capture a follow-up or opportunity.',
      transcript:
          'Business: Follow up with OpenAI about the partnership and next pilot steps.',
      type: VoiceCommandType.businessOpportunity,
    ),
    VoiceCommandTemplate(
      id: 'codex',
      label: 'Codex',
      description: 'Prepare a review-first prompt for Codex.',
      transcript:
          'Codex: Review the voice assistant code and suggest the smallest useful upgrade.',
      type: VoiceCommandType.codexPrompt,
    ),
    VoiceCommandTemplate(
      id: 'idea',
      label: 'Idea',
      description: 'Park a future thought safely.',
      transcript:
          'Idea: Let the dashboard suggest the best next action from the day\'s open loops.',
      type: VoiceCommandType.idea,
    ),
  ];

  List<VoiceCommand> getHistory() {
    return List.unmodifiable(_commands.reversed);
  }

  List<VoiceCommandTemplate> getTemplates() {
    return List.unmodifiable(_templates);
  }

  VoiceCommandTemplate? getTemplateById(String id) {
    for (final template in _templates) {
      if (template.id == id) {
        return template;
      }
    }

    return null;
  }

  List<VoiceCommandQuickAction> buildMacroActions({
    VoiceConversationContext? conversationContext,
  }) {
    final macros = <VoiceCommandQuickAction>[
      const VoiceCommandQuickAction(
        id: 'start-build-day',
        label: 'Start Build Day',
        description: 'Open the build-day planning flow.',
        templateId: 'build-day',
      ),
      const VoiceCommandQuickAction(
        id: 'plan-day',
        label: 'Plan Day',
        description: 'Turn the current thread into a short action plan.',
        templateId: 'plan-day',
      ),
      const VoiceCommandQuickAction(
        id: 'summarize-today',
        label: 'Summarize Today',
        description: 'Open the reflective day-review prompt.',
        templateId: 'summarize-today',
      ),
      const VoiceCommandQuickAction(
        id: 'recall-memory',
        label: 'Recall Memory',
        description: 'Ask Gaia what she remembers about the thread.',
        templateId: 'recall-thread',
      ),
      const VoiceCommandQuickAction(
        id: 'whats-next',
        label: "What's Next",
        description: 'Open the next-step prompt for the current thread.',
        templateId: 'whats-next',
      ),
    ];

    if (conversationContext != null && conversationContext.hasMemory) {
      macros.add(
        const VoiceCommandQuickAction(
          id: 'continue-thread',
          label: 'Continue Thread',
          description: 'Pick up the remembered conversation where it left off.',
        ),
      );
    }

    final dedupedMacros = <String, VoiceCommandQuickAction>{};
    for (final macro in macros) {
      dedupedMacros.putIfAbsent(macro.id, () => macro);
    }

    return dedupedMacros.values.toList();
  }

  VoiceCommandQuickAction? resolveFollowUpAction({
    required String transcript,
    VoiceConversationContext? conversationContext,
  }) {
    final normalizedTranscript = transcript.toLowerCase();
    final macros = buildMacroActions(conversationContext: conversationContext);

    VoiceCommandQuickAction? findAction(String id) {
      for (final action in macros) {
        if (action.id == id) {
          return action;
        }
      }
      return null;
    }

    VoiceCommandQuickAction? findMacroByPhrases(
      String id,
      List<String> phrases,
    ) {
      for (final phrase in phrases) {
        if (normalizedTranscript.contains(phrase)) {
          return findAction(id);
        }
      }
      return null;
    }

    final macroMatch =
        findMacroByPhrases('continue-thread', [
          'continue thread',
          'keep going',
          'resume thread',
          'pick up the thread',
        ]) ??
        findMacroByPhrases('start-build-day', [
          'start build day',
          'build day',
          'morning planning',
        ]) ??
        findMacroByPhrases('plan-day', [
          'plan my day',
          'plan day',
          'make a plan',
          'action plan',
        ]) ??
        findMacroByPhrases('summarize-today', [
          'summarize today',
          'summarise today',
          'today summary',
          'summarize the day',
          'summarise the day',
          'review today',
        ]) ??
        findMacroByPhrases('recall-memory', [
          'recall memory',
          'what do you remember',
          'remember this thread',
          'what you remember',
        ]) ??
        findMacroByPhrases('whats-next', [
          "what's next",
          'what is next',
          'what next',
          'next step',
        ]);

    if (macroMatch != null) {
      return macroMatch;
    }

    final routeAndTemplateActions = <VoiceCommandQuickAction>[
      const VoiceCommandQuickAction(
        id: 'open-dashboard',
        label: 'Open Dashboard',
        description: 'Return to the main command surface.',
        route: '/dashboard',
      ),
      const VoiceCommandQuickAction(
        id: 'open-planner',
        label: 'Open Planner',
        description: 'Review the current day plan.',
        route: '/planner',
      ),
      const VoiceCommandQuickAction(
        id: 'open-tasks',
        label: 'Open Tasks',
        description: 'Jump into the task list.',
        route: '/tasks',
      ),
      const VoiceCommandQuickAction(
        id: 'open-projects',
        label: 'Open Projects',
        description: 'Jump into the project list.',
        route: '/projects',
      ),
      const VoiceCommandQuickAction(
        id: 'open-journal',
        label: 'Open Journal',
        description: 'Jump into the journal list.',
        route: '/journal',
      ),
      const VoiceCommandQuickAction(
        id: 'open-content',
        label: 'Open Content',
        description: 'Jump into the content list.',
        route: '/content',
      ),
      const VoiceCommandQuickAction(
        id: 'open-business',
        label: 'Open Business',
        description: 'Jump into the business list.',
        route: '/business',
      ),
      const VoiceCommandQuickAction(
        id: 'open-inbox',
        label: 'Open Inbox',
        description: 'Jump into the inbox list.',
        route: '/inbox',
      ),
      const VoiceCommandQuickAction(
        id: 'load-project',
        label: 'Create Project',
        description: 'Prefill a new project capture.',
        templateId: 'project',
      ),
      const VoiceCommandQuickAction(
        id: 'load-task',
        label: 'Create Task',
        description: 'Prefill a new task capture.',
        templateId: 'task',
      ),
      const VoiceCommandQuickAction(
        id: 'load-journal',
        label: 'Create Journal',
        description: 'Prefill a journal capture.',
        templateId: 'journal',
      ),
      const VoiceCommandQuickAction(
        id: 'load-content',
        label: 'Create Content',
        description: 'Prefill a content capture.',
        templateId: 'content',
      ),
      const VoiceCommandQuickAction(
        id: 'load-business',
        label: 'Create Business',
        description: 'Prefill a business capture.',
        templateId: 'business',
      ),
      const VoiceCommandQuickAction(
        id: 'load-idea',
        label: 'Create Idea',
        description: 'Prefill an inbox idea capture.',
        templateId: 'idea',
      ),
      const VoiceCommandQuickAction(
        id: 'prepare-codex',
        label: 'Prepare Codex',
        description: 'Prefill a Codex review prompt.',
        templateId: 'codex',
      ),
    ];

    VoiceCommandQuickAction? findRouteAction(String id, List<String> phrases) {
      for (final phrase in phrases) {
        if (normalizedTranscript.contains(phrase)) {
          for (final action in routeAndTemplateActions) {
            if (action.id == id) {
              return action;
            }
          }
        }
      }
      return null;
    }

    return findRouteAction('open-dashboard', ['open dashboard']) ??
        findRouteAction('open-planner', ['open planner']) ??
        findRouteAction('open-tasks', ['open tasks', 'show tasks']) ??
        findRouteAction('open-projects', ['open projects', 'show projects']) ??
        findRouteAction('open-journal', ['open journal', 'show journal']) ??
        findRouteAction('open-content', ['open content', 'show content']) ??
        findRouteAction('open-business', ['open business', 'show business']) ??
        findRouteAction('open-inbox', ['open inbox', 'show inbox']) ??
        findRouteAction('load-project', [
          'create a project',
          'create project',
          'add a project',
          'new project',
          'make a project',
          'start project',
          'start a project',
          'project capture',
        ]) ??
        findRouteAction('load-task', [
          'create a task',
          'create task',
          'add a task',
          'new task',
          'add task',
          'task capture',
        ]) ??
        findRouteAction('load-journal', [
          'create a journal',
          'create journal',
          'journal entry',
          'journal note',
        ]) ??
        findRouteAction('load-content', [
          'create content',
          'create a content idea',
          'content idea',
          'draft content',
        ]) ??
        findRouteAction('load-business', [
          'create a business',
          'create business',
          'create a business opportunity',
          'business lead',
          'business opportunity',
        ]) ??
        findRouteAction('load-idea', [
          'create an idea',
          'create idea',
          'new idea',
          'idea capture',
        ]) ??
        findRouteAction('prepare-codex', [
          'prepare codex',
          'codex prompt',
          'code review',
        ]);
  }

  List<VoiceCommandQuickAction> suggestQuickActions({
    required String transcript,
    VoiceCommandSuggestion? suggestion,
    VoiceConversationContext? conversationContext,
  }) {
    final normalizedTranscript = transcript.toLowerCase();
    final suggestedType = suggestion?.suggestedType;
    final hasProjectSuggestion = suggestion?.suggestedProjectId != null;
    final projectId = suggestion?.suggestedProjectId;
    final isWakeOnly = suggestion?.isWakeOnly ?? false;
    final summaryRequest = _isSummaryRequest(normalizedTranscript);
    final nextStepRequest = _isNextStepRequest(normalizedTranscript);
    final memoryRequest = _isMemoryRequest(normalizedTranscript);
    final planningRequest = _isPlanningRequest(normalizedTranscript);

    final actions = <VoiceCommandQuickAction>[];

    if (isWakeOnly) {
      actions.addAll([
        const VoiceCommandQuickAction(
          id: 'start-build-day',
          label: 'Start Build Day',
          description: 'Move into the planning flow right away.',
          templateId: 'build-day',
        ),
        const VoiceCommandQuickAction(
          id: 'summarize-today',
          label: 'Summarize Today',
          description: 'Ask for the day-level review shape.',
          templateId: 'summarize-today',
        ),
        const VoiceCommandQuickAction(
          id: 'create-project',
          label: 'Create Project',
          description: 'Open the project capture path.',
          templateId: 'project',
        ),
      ]);
    }

    if (summaryRequest) {
      actions.addAll([
        const VoiceCommandQuickAction(
          id: 'open-planner-summary',
          label: 'Open Planner',
          description: 'Review today\'s plan and capture a day summary.',
          route: '/planner',
        ),
        const VoiceCommandQuickAction(
          id: 'load-summarize-today',
          label: 'Summarize Today',
          description: 'Prefill the review prompt for the day.',
          templateId: 'summarize-today',
        ),
      ]);
    }

    if (memoryRequest || (conversationContext?.hasMemory ?? false)) {
      actions.addAll([
        const VoiceCommandQuickAction(
          id: 'recall-memory',
          label: 'Recall Memory',
          description: 'Ask Gaia what she remembers from the thread.',
          templateId: 'recall-thread',
        ),
        const VoiceCommandQuickAction(
          id: 'plan-day',
          label: 'Plan Day',
          description: 'Turn the remembered thread into a short action plan.',
          templateId: 'plan-day',
        ),
      ]);
    }

    if (planningRequest) {
      actions.addAll([
        const VoiceCommandQuickAction(
          id: 'plan-day',
          label: 'Plan Day',
          description: 'Turn the current thread into a short action plan.',
          templateId: 'plan-day',
        ),
        const VoiceCommandQuickAction(
          id: 'open-planner',
          label: 'Open Planner',
          description: 'Review the plan alongside today\'s focus.',
          route: '/planner',
        ),
      ]);
    }

    if (nextStepRequest) {
      actions.addAll([
        const VoiceCommandQuickAction(
          id: 'open-tasks-next',
          label: 'Open Tasks',
          description: 'Surface the next practical task.',
          route: '/tasks',
        ),
        const VoiceCommandQuickAction(
          id: 'open-projects-next',
          label: 'Open Projects',
          description: 'Check the project context around the next move.',
          route: '/projects',
        ),
      ]);
    }

    if (normalizedTranscript.contains('build day') ||
        normalizedTranscript.contains('start my build day') ||
        normalizedTranscript.contains('morning planning')) {
      actions.add(
        const VoiceCommandQuickAction(
          id: 'open-dashboard',
          label: 'Open Dashboard',
          description: 'Jump back to the daily command surface.',
          route: '/dashboard',
        ),
      );
      actions.add(
        const VoiceCommandQuickAction(
          id: 'open-planner',
          label: 'Open Planner',
          description: 'Review today\'s plan and evening review notes.',
          route: '/planner',
        ),
      );
      actions.add(
        const VoiceCommandQuickAction(
          id: 'load-build-day',
          label: 'Load Build Day',
          description: 'Prefill a build-day planning command.',
          templateId: 'build-day',
        ),
      );
      return actions;
    }

    switch (suggestedType) {
      case VoiceCommandType.task:
        actions.addAll([
          const VoiceCommandQuickAction(
            id: 'open-tasks',
            label: 'Open Tasks',
            description: 'Triage or refine the task in the task list.',
            route: '/tasks',
          ),
          const VoiceCommandQuickAction(
            id: 'load-task',
            label: 'Load Task',
            description: 'Prefill the standard task capture shape.',
            templateId: 'task',
          ),
          const VoiceCommandQuickAction(
            id: 'open-planner',
            label: 'Open Planner',
            description: 'Check whether it belongs in today\'s Top 3.',
            route: '/planner',
          ),
        ]);
        break;
      case VoiceCommandType.project:
        actions.addAll([
          const VoiceCommandQuickAction(
            id: 'open-projects',
            label: 'Open Projects',
            description: 'Review the project list or create one manually.',
            route: '/projects',
          ),
          const VoiceCommandQuickAction(
            id: 'load-project',
            label: 'Load Project',
            description: 'Prefill a project creation command.',
            templateId: 'project',
          ),
          const VoiceCommandQuickAction(
            id: 'summarize-today',
            label: 'Summarize Today',
            description: 'Turn the project thought into a review prompt.',
            templateId: 'summarize-today',
          ),
          const VoiceCommandQuickAction(
            id: 'open-tasks',
            label: 'Open Tasks',
            description: 'Add tasks once the project shape is clear.',
            route: '/tasks',
          ),
        ]);
        break;
      case VoiceCommandType.journalEntry:
        actions.addAll([
          const VoiceCommandQuickAction(
            id: 'open-journal',
            label: 'Open Journal',
            description: 'Move from capture to reflection.',
            route: '/journal',
          ),
          const VoiceCommandQuickAction(
            id: 'load-journal',
            label: 'Load Journal',
            description: 'Prefill the reflection template.',
            templateId: 'journal',
          ),
          const VoiceCommandQuickAction(
            id: 'open-dashboard',
            label: 'Open Dashboard',
            description: 'Return to the daily overview.',
            route: '/dashboard',
          ),
        ]);
        break;
      case VoiceCommandType.contentIdea:
        actions.addAll([
          const VoiceCommandQuickAction(
            id: 'open-content',
            label: 'Open Content',
            description: 'Move into the content planning space.',
            route: '/content',
          ),
          const VoiceCommandQuickAction(
            id: 'load-content',
            label: 'Load Content',
            description: 'Prefill a content drafting template.',
            templateId: 'content',
          ),
          const VoiceCommandQuickAction(
            id: 'open-projects',
            label: 'Open Projects',
            description: 'Find the project the content belongs to.',
            route: '/projects',
          ),
        ]);
        break;
      case VoiceCommandType.businessOpportunity:
        actions.addAll([
          const VoiceCommandQuickAction(
            id: 'open-business',
            label: 'Open Business',
            description: 'Review the opportunity in Business Hub.',
            route: '/business',
          ),
          const VoiceCommandQuickAction(
            id: 'load-business',
            label: 'Load Business',
            description: 'Prefill the business capture shape.',
            templateId: 'business',
          ),
          const VoiceCommandQuickAction(
            id: 'open-projects',
            label: 'Open Projects',
            description: 'Check the project context around this lead.',
            route: '/projects',
          ),
        ]);
        break;
      case VoiceCommandType.codexPrompt:
        actions.addAll([
          const VoiceCommandQuickAction(
            id: 'prepare-codex',
            label: 'Prepare Codex Prompt',
            description: 'Keep the prompt review-first.',
            templateId: 'codex',
          ),
          const VoiceCommandQuickAction(
            id: 'open-dashboard',
            label: 'Open Dashboard',
            description: 'Return to the main control surface.',
            route: '/dashboard',
          ),
        ]);
        break;
      case VoiceCommandType.idea:
        actions.addAll([
          const VoiceCommandQuickAction(
            id: 'open-inbox',
            label: 'Open Inbox',
            description: 'Park the idea before it becomes scope.',
            route: '/inbox',
          ),
          const VoiceCommandQuickAction(
            id: 'load-idea',
            label: 'Load Idea',
            description: 'Prefill the future idea template.',
            templateId: 'idea',
          ),
          const VoiceCommandQuickAction(
            id: 'open-dashboard',
            label: 'Open Dashboard',
            description: 'Keep the focus on today.',
            route: '/dashboard',
          ),
        ]);
        break;
      case null:
        actions.addAll([
          const VoiceCommandQuickAction(
            id: 'load-build-day',
            label: 'Start Build Day',
            description: 'Use a ready-made planning prompt.',
            templateId: 'build-day',
          ),
          const VoiceCommandQuickAction(
            id: 'summarize-today',
            label: 'Summarize Today',
            description: 'Load the reflective review prompt.',
            templateId: 'summarize-today',
          ),
          const VoiceCommandQuickAction(
            id: 'open-tasks',
            label: 'Open Tasks',
            description: 'Start with the task list.',
            route: '/tasks',
          ),
          const VoiceCommandQuickAction(
            id: 'prepare-codex',
            label: 'Prepare Codex Prompt',
            description: 'Turn a thought into a safe prompt.',
            templateId: 'codex',
          ),
        ]);
        break;
    }

    if (conversationContext != null && conversationContext.hasMemory) {
      actions.add(
        const VoiceCommandQuickAction(
          id: 'continue-thread',
          label: 'Continue Thread',
          description:
              'Pick up the current voice thread from where it left off.',
        ),
      );
    }

    if (hasProjectSuggestion && projectId != null) {
      actions.insert(
        0,
        VoiceCommandQuickAction(
          id: 'open-project-$projectId',
          label: 'Open Project',
          description: 'Jump into the matched project context.',
          route: '/projects/$projectId',
        ),
      );
    }

    final dedupedActions = <String, VoiceCommandQuickAction>{};
    for (final action in actions) {
      dedupedActions.putIfAbsent(action.id, () => action);
    }

    return dedupedActions.values.toList();
  }

  VoiceCommandAssistantResponse buildAssistantResponse({
    required String transcript,
    VoiceCommandSuggestion? suggestion,
    VoiceConversationContext? conversationContext,
  }) {
    final cleanedTranscript = suggestion?.transcript ?? transcript;
    final projectContext = suggestion?.suggestedProjectName;
    final threadContext = _buildThreadContextLine(conversationContext);
    final isWakeOnly = suggestion?.isWakeOnly ?? false;
    final lowerTranscript = cleanedTranscript.toLowerCase();

    if (isWakeOnly) {
      return VoiceCommandAssistantResponse(
        summary: 'Wake phrase heard. I am here and ready to help.',
        nextStep:
            'Say what you want to create, open, summarize, continue, or ask what I can do.',
        projectContext: projectContext,
        threadContext: threadContext,
      );
    }

    if (_isConversationGreetingRequest(lowerTranscript)) {
      return VoiceCommandAssistantResponse(
        summary:
            'I am doing well and I am here with you. Ask me what I can do, or tell me to create, open, summarize, or continue.',
        nextStep:
            'You can keep the conversation going by asking for help, a summary, or the next practical move.',
        projectContext: projectContext,
        threadContext: threadContext,
      );
    }

    if (_isHelpRequest(lowerTranscript)) {
      return VoiceCommandAssistantResponse(
        summary:
            'I can help you create tasks, projects, journal entries, content ideas, business opportunities, inbox items, and more.',
        nextStep:
            'Try saying create a task, create a project, summarize today, continue the thread, or ask for the next move.',
        projectContext: projectContext,
        threadContext: threadContext,
      );
    }

    if (_isSummaryRequest(lowerTranscript)) {
      return VoiceCommandAssistantResponse(
        summary:
            'This sounds like a daily review. I can help you summarize the day, open Planner, or shape the note into Journal or Tasks.',
        nextStep:
            'Choose whether you want a summary, a journal note, or the next practical task.',
        projectContext: projectContext,
        threadContext: threadContext,
      );
    }

    if (_isNextStepRequest(lowerTranscript)) {
      return VoiceCommandAssistantResponse(
        summary:
            'This sounds like a next-step request. I can surface Tasks, Projects, or the current thread to keep momentum moving.',
        nextStep:
            'Open the place that matches the next move, then save the capture if it belongs there.',
        projectContext: projectContext,
        threadContext: threadContext,
      );
    }

    if (_isMemoryRequest(lowerTranscript)) {
      return VoiceCommandAssistantResponse(
        summary: _buildMemorySummary(conversationContext),
        nextStep:
            'Ask me to recall the last thread, open the related project, or turn the memory into a task or plan.',
        projectContext: projectContext,
        threadContext: threadContext,
      );
    }

    if (_isPlanningRequest(lowerTranscript)) {
      return VoiceCommandAssistantResponse(
        summary: _buildPlannerSummary(
          suggestion: suggestion,
          conversationContext: conversationContext,
        ),
        nextStep:
            'Use the suggested action plan, then save the result in the right local module.',
        projectContext: projectContext,
        threadContext: threadContext,
      );
    }

    if (lowerTranscript.contains('build day')) {
      return VoiceCommandAssistantResponse(
        summary:
            'I heard a build-day command. I can help you open the day view, check the planner, or preload the build-day template.',
        nextStep:
            'Use the router or template deck to open Planner and shape the day before you save anything.',
        projectContext: projectContext,
      );
    }

    switch (suggestion?.suggestedType) {
      case VoiceCommandType.task:
        return VoiceCommandAssistantResponse(
          summary:
              'This reads like a task. I can open Tasks, preload the task template, or send it toward Planner if it belongs in today.',
          nextStep:
              'Review the title, category, and priority before you save it.',
          projectContext: projectContext,
          threadContext: threadContext,
        );
      case VoiceCommandType.project:
        return VoiceCommandAssistantResponse(
          summary:
              'This sounds like a project. I can open Projects, preload the project template, or help you turn the idea into a concrete project record.',
          nextStep:
              'Check the project name, status, priority, vision, and first next action before saving.',
          projectContext: projectContext,
          threadContext: threadContext,
        );
      case VoiceCommandType.journalEntry:
        return VoiceCommandAssistantResponse(
          summary:
              'This sounds like a journal entry. I can open Journal or reload the reflection template for a cleaner note.',
          nextStep:
              'Tighten the worked-on, learned, and next-actions fields before saving.',
          projectContext: projectContext,
          threadContext: threadContext,
        );
      case VoiceCommandType.contentIdea:
        return VoiceCommandAssistantResponse(
          summary:
              'This looks like a content idea. I can open Content, preload the draft template, or jump to Projects for context.',
          nextStep: 'Check the platform and content type before you keep it.',
          projectContext: projectContext,
          threadContext: threadContext,
        );
      case VoiceCommandType.businessOpportunity:
        return VoiceCommandAssistantResponse(
          summary:
              'This sounds like a business lead. I can open Business, preload the opportunity template, or move into Projects for context.',
          nextStep:
              'Confirm the contact, status, and next action before saving.',
          projectContext: projectContext,
          threadContext: threadContext,
        );
      case VoiceCommandType.codexPrompt:
        return VoiceCommandAssistantResponse(
          summary:
              'I can shape this into a safe Codex prompt for review. The prompt will stay local until you copy it.',
          nextStep: 'Read the prompt once more before you hand it off.',
          projectContext: projectContext,
          threadContext: threadContext,
        );
      case VoiceCommandType.idea:
        return VoiceCommandAssistantResponse(
          summary:
              'This reads like a future idea. I can park it in Inbox or keep it attached to the day for later review.',
          nextStep:
              'If it does not belong to today, let Inbox hold it for you.',
          projectContext: projectContext,
          threadContext: threadContext,
        );
      case null:
        return VoiceCommandAssistantResponse(
          summary:
              'I do not have a strong type yet. I can still help by opening the right area, loading a starter, or turning this into a safe prompt.',
          nextStep:
              'Pick a starter deck option or let the router guide the next move.',
          projectContext: projectContext,
          threadContext: threadContext,
        );
    }
  }

  VoiceCommandBriefing buildBriefing({
    required String transcript,
    VoiceCommandSuggestion? suggestion,
    VoiceConversationContext? conversationContext,
  }) {
    final cleanedTranscript = suggestion?.transcript ?? transcript;
    final assistantResponse = buildAssistantResponse(
      transcript: cleanedTranscript,
      suggestion: suggestion,
      conversationContext: conversationContext,
    );
    final actions = suggestQuickActions(
      transcript: cleanedTranscript,
      suggestion: suggestion,
      conversationContext: conversationContext,
    );

    return VoiceCommandBriefing(
      summary: assistantResponse.summary,
      nextStep: assistantResponse.nextStep,
      projectContext: assistantResponse.projectContext,
      threadContext: assistantResponse.threadContext,
      actions: actions.take(3).toList(),
      memorySummary: _buildMemorySummary(conversationContext),
      memoryHighlights: _buildMemoryHighlights(conversationContext),
      plannerSummary: _buildPlannerSummary(
        suggestion: suggestion,
        conversationContext: conversationContext,
      ),
      plannerSteps: _buildPlannerSteps(
        suggestion: suggestion,
        conversationContext: conversationContext,
        actions: actions,
      ),
    );
  }

  String buildWizardPrompt({
    required VoiceWizardStep step,
    VoiceCommandType? selectedType,
    String? projectName,
    VoiceConversationContext? conversationContext,
  }) {
    final threadLeadIn = _buildWizardLeadIn(conversationContext);
    switch (step) {
      case VoiceWizardStep.type:
        return '$threadLeadIn What kind of entry do you want to create? Say task, journal, content, business, idea, or Codex.';
      case VoiceWizardStep.title:
        return '$threadLeadIn What title should I use?';
      case VoiceWizardStep.project:
        return projectName == null
            ? '$threadLeadIn Which project should this belong to?'
            : '$threadLeadIn Which project should this belong to? I can see $projectName as a possible match.';
      case VoiceWizardStep.details:
        switch (selectedType) {
          case VoiceCommandType.task:
            return '$threadLeadIn Any category or priority you want me to remember?';
          case VoiceCommandType.project:
            return '$threadLeadIn What status, priority, vision, or next action should I capture for this project?';
          case VoiceCommandType.journalEntry:
            return '$threadLeadIn What did you work on, what did you learn, and what should happen next?';
          case VoiceCommandType.contentIdea:
            return '$threadLeadIn Which platform and content type fit this best?';
          case VoiceCommandType.businessOpportunity:
            return '$threadLeadIn Who is this with, and what is the next action?';
          case VoiceCommandType.codexPrompt:
            return '$threadLeadIn What should Codex change or review?';
          case VoiceCommandType.idea:
            return '$threadLeadIn What should I remember about this idea?';
          case null:
            return '$threadLeadIn Tell me a little more detail.';
        }
      case VoiceWizardStep.review:
        return '$threadLeadIn I have the draft. Review it, then save or start again.';
    }
  }

  String buildWizardTranscriptPiece({
    required VoiceWizardStep step,
    required String answer,
    VoiceCommandType? selectedType,
  }) {
    final trimmedAnswer = answer.trim();

    switch (step) {
      case VoiceWizardStep.type:
        final typeLabel = selectedType?.label ?? trimmedAnswer;
        return 'Type: $typeLabel.';
      case VoiceWizardStep.title:
        return 'Title: $trimmedAnswer.';
      case VoiceWizardStep.project:
        return 'Project: $trimmedAnswer.';
      case VoiceWizardStep.details:
        switch (selectedType) {
          case VoiceCommandType.task:
            return 'Details: $trimmedAnswer.';
          case VoiceCommandType.project:
            return 'Project Details: $trimmedAnswer.';
          case VoiceCommandType.journalEntry:
            return 'Journal Notes: $trimmedAnswer.';
          case VoiceCommandType.contentIdea:
            return 'Content Notes: $trimmedAnswer.';
          case VoiceCommandType.businessOpportunity:
            return 'Business Notes: $trimmedAnswer.';
          case VoiceCommandType.codexPrompt:
            return 'Codex Request: $trimmedAnswer.';
          case VoiceCommandType.idea:
            return 'Idea Notes: $trimmedAnswer.';
          case null:
            return 'Details: $trimmedAnswer.';
        }
      case VoiceWizardStep.review:
        return 'Review: $trimmedAnswer.';
    }
  }

  VoiceConversationContext buildConversationContext({
    required String transcript,
    required VoiceCommandType type,
    String? title,
    String? projectId,
    String? projectName,
    VoiceConversationContext? previous,
  }) {
    final normalizedTitle = title?.trim();
    final normalizedProjectName = projectName?.trim();
    final contextParts = <String>[];

    if (normalizedProjectName != null && normalizedProjectName.isNotEmpty) {
      contextParts.add(normalizedProjectName);
    }
    contextParts.add(type.label);

    final entryParts = <String>[...contextParts];
    if (normalizedTitle != null && normalizedTitle.isNotEmpty) {
      entryParts.add(normalizedTitle);
    }

    final contextLabel = contextParts.join(' · ');
    final label = entryParts.join(' · ');
    final previousLabel = previous?.label;
    final entryCount = (previous?.entryCount ?? 0) + 1;
    final summary = previousLabel == null
        ? 'Starting a new thread around $contextLabel.'
        : 'Continuing the $contextLabel thread. Latest entry: ${normalizedTitle ?? label}.';

    return VoiceConversationContext(
      label: label,
      summary: summary,
      type: type,
      projectId: projectId,
      projectName: normalizedProjectName,
      title: normalizedTitle,
      transcript: transcript.trim(),
      entryCount: entryCount,
    );
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
    final wakePhraseMatch = _stripWakePhrase(normalizedTranscript);
    final explicitTypeMatch = _matchExplicitType(wakePhraseMatch.transcript);
    final explicitType = explicitTypeMatch?.$1;
    final cleanedTranscript = explicitTypeMatch == null
        ? wakePhraseMatch.transcript
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
      extractedProjectStatus: extraction.projectStatus,
      extractedProjectPriority: extraction.projectPriority,
      extractedProjectVision: extraction.projectVision,
      extractedProjectNextAction: extraction.projectNextAction,
      extractedProjectNotes: extraction.projectNotes,
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
      usedWakePhrase: wakePhraseMatch.usedWakePhrase,
      isWakeOnly: wakePhraseMatch.usedWakePhrase && cleanedTranscript.isEmpty,
      wakePhrase: wakePhraseMatch.wakePhrase,
    );
  }

  String _normalizeTranscript(String transcript) {
    return transcript.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  _WakePhraseExtraction _stripWakePhrase(String transcript) {
    final lowerTranscript = transcript.toLowerCase();
    const patterns = <String>[
      r'^(hey\s+)?(gaia|new earth|newearth)[\s,.:;\-]*',
      r'^(wake up|wake)\s+(gaia|new earth|newearth|assistant|dashboard)[\s,.:;\-]*',
      r'^(hey\s+)?(assistant|dashboard)[\s,.:;\-]*',
    ];

    for (final pattern in patterns) {
      final match = RegExp(
        pattern,
        caseSensitive: false,
      ).firstMatch(lowerTranscript);
      if (match != null) {
        final cleaned = transcript.substring(match.end).trim();
        return _WakePhraseExtraction(
          transcript: cleaned,
          usedWakePhrase: true,
          wakePhrase: transcript.substring(0, match.end).trim(),
        );
      }
    }

    return _WakePhraseExtraction(
      transcript: transcript,
      usedWakePhrase: false,
      wakePhrase: null,
    );
  }

  (VoiceCommandType, String)? _matchExplicitType(String transcript) {
    const prefixes = <String, VoiceCommandType>{
      'task': VoiceCommandType.task,
      'todo': VoiceCommandType.task,
      'project': VoiceCommandType.project,
      'new project': VoiceCommandType.project,
      'create project': VoiceCommandType.project,
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
      VoiceCommandType.project: 0,
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
    addScore(VoiceCommandType.project, [
      'project',
      'new project',
      'create project',
      'start a project',
      'launch project',
      'build a project',
      'project plan',
      'project for',
      'project around',
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

  String _buildWizardLeadIn(VoiceConversationContext? conversationContext) {
    if (conversationContext == null || !conversationContext.hasMemory) {
      return '';
    }

    return '${conversationContext.summary} ';
  }

  String? _buildThreadContextLine(
    VoiceConversationContext? conversationContext,
  ) {
    if (conversationContext == null || !conversationContext.hasMemory) {
      return null;
    }

    final parts = <String>[
      if (conversationContext.projectName != null &&
          conversationContext.projectName!.isNotEmpty)
        conversationContext.projectName!,
      conversationContext.type?.label ?? conversationContext.label,
      if (conversationContext.title != null &&
          conversationContext.title!.isNotEmpty)
        conversationContext.title!,
    ];

    return parts.join(' · ');
  }

  String _buildMemorySummary(VoiceConversationContext? conversationContext) {
    final history = getHistory();

    if (conversationContext != null && conversationContext.hasMemory) {
      final memoryBits = <String>[
        if (conversationContext.projectName != null &&
            conversationContext.projectName!.isNotEmpty)
          'project ${conversationContext.projectName}',
        'thread ${conversationContext.label}',
        if (conversationContext.entryCount > 0)
          '${conversationContext.entryCount} entry${conversationContext.entryCount == 1 ? '' : 's'}',
      ];

      if (history.isNotEmpty) {
        return 'Gaia remembers ${memoryBits.join(', ')}. Recent captures are ready to reuse as well.';
      }

      return 'Gaia remembers ${memoryBits.join(', ')}.';
    }

    if (history.isNotEmpty) {
      return 'Gaia remembers ${history.length} recent voice capture${history.length == 1 ? '' : 's'} and can keep the next move connected.';
    }

    return 'Gaia will build memory from the first saved command in this thread.';
  }

  List<String> _buildMemoryHighlights(
    VoiceConversationContext? conversationContext,
  ) {
    final highlights = <String>[];

    if (conversationContext != null && conversationContext.hasMemory) {
      highlights.add('Thread: ${conversationContext.label}');
      if (conversationContext.projectName != null &&
          conversationContext.projectName!.isNotEmpty) {
        highlights.add('Project: ${conversationContext.projectName}');
      }
      if (conversationContext.entryCount > 0) {
        highlights.add('Entries: ${conversationContext.entryCount}');
      }
    }

    for (final command in getHistory().take(3)) {
      final highlight =
          '${command.type.label}: ${_titleFromTranscript(command.transcript)}';
      if (!highlights.contains(highlight)) {
        highlights.add(highlight);
      }
    }

    return highlights.take(4).toList();
  }

  String _buildPlannerSummary({
    VoiceCommandSuggestion? suggestion,
    VoiceConversationContext? conversationContext,
  }) {
    final plannerType = suggestion?.suggestedType ?? conversationContext?.type;

    switch (plannerType) {
      case VoiceCommandType.task:
        return 'Gaia sees a task and the plan is to tighten the title, category, and priority before saving it.';
      case VoiceCommandType.project:
        return 'Gaia sees a project and the plan is to confirm the status, vision, and first action before saving it.';
      case VoiceCommandType.journalEntry:
        return 'Gaia sees a journal note and the plan is to capture what moved forward, what was learned, and what comes next.';
      case VoiceCommandType.contentIdea:
        return 'Gaia sees a content idea and the plan is to confirm the platform, format, and draft angle before saving it.';
      case VoiceCommandType.businessOpportunity:
        return 'Gaia sees a business lead and the plan is to confirm the contact, status, and next action before saving it.';
      case VoiceCommandType.codexPrompt:
        return 'Gaia sees a Codex prompt and the plan is to keep it review-first before any code moves.';
      case VoiceCommandType.idea:
        return 'Gaia sees a future idea and the plan is to keep it light, remembered, and easy to revisit.';
      case null:
        if (conversationContext != null && conversationContext.hasMemory) {
          return 'Gaia can use the remembered thread to suggest the next practical move.';
        }
        return 'Gaia is ready to turn the current capture into a practical plan.';
    }
  }

  List<String> _buildPlannerSteps({
    VoiceCommandSuggestion? suggestion,
    VoiceConversationContext? conversationContext,
    List<VoiceCommandQuickAction> actions = const [],
  }) {
    final plannerType = suggestion?.suggestedType ?? conversationContext?.type;

    final steps = switch (plannerType) {
      VoiceCommandType.task => <String>[
        'Open Tasks',
        'Review category and priority',
        'Save as Task',
      ],
      VoiceCommandType.project => <String>[
        'Open Projects',
        'Review status, vision, and first action',
        'Save as Project',
      ],
      VoiceCommandType.journalEntry => <String>[
        'Open Journal',
        'Review what moved forward and what was learned',
        'Save as Journal Entry',
      ],
      VoiceCommandType.contentIdea => <String>[
        'Open Content',
        'Review platform and content type',
        'Save as Content Idea',
      ],
      VoiceCommandType.businessOpportunity => <String>[
        'Open Business',
        'Review contact, status, and next action',
        'Save as Business Opportunity',
      ],
      VoiceCommandType.codexPrompt => <String>[
        'Review the prompt',
        'Keep the change request manual-review only',
        'Ask for approval before code changes',
      ],
      VoiceCommandType.idea => <String>[
        'Open Inbox',
        'Keep the idea lightweight',
        'Save it for later review',
      ],
      null => <String>[
        if (conversationContext != null && conversationContext.hasMemory)
          'Reuse the remembered thread',
        if (actions.isNotEmpty) actions.first.label,
        if (actions.length > 1) actions[1].label,
      ],
    };

    return steps.where((step) => step.trim().isNotEmpty).take(3).toList();
  }

  _StructuredVoiceFields _extractStructuredFields({
    required String transcript,
    required VoiceCommandType type,
  }) {
    switch (type) {
      case VoiceCommandType.task:
        return _extractTaskFields(transcript);
      case VoiceCommandType.project:
        return _extractProjectFields(transcript);
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

  _StructuredVoiceFields _extractProjectFields(String transcript) {
    final lowerTranscript = transcript.toLowerCase();

    String projectStatus = 'Idea';
    if (lowerTranscript.contains('active') ||
        lowerTranscript.contains('start') ||
        lowerTranscript.contains('launch') ||
        lowerTranscript.contains('create') ||
        lowerTranscript.contains('build')) {
      projectStatus = 'Active';
    } else if (lowerTranscript.contains('paused') ||
        lowerTranscript.contains('hold')) {
      projectStatus = 'Paused';
    } else if (lowerTranscript.contains('blocked')) {
      projectStatus = 'Blocked';
    } else if (lowerTranscript.contains('complete') ||
        lowerTranscript.contains('done')) {
      projectStatus = 'Completed';
    } else if (lowerTranscript.contains('archive')) {
      projectStatus = 'Archived';
    }

    String projectPriority = 'Medium';
    if (lowerTranscript.contains('high priority') ||
        lowerTranscript.contains('urgent')) {
      projectPriority = 'High';
    } else if (lowerTranscript.contains('low priority')) {
      projectPriority = 'Low';
    } else if (lowerTranscript.contains('someday')) {
      projectPriority = 'Someday';
    }

    final projectVision = _captureAfterLabel(transcript, [
      'vision',
      'purpose',
      'why',
    ]);
    final projectNextAction = _captureAfterLabel(transcript, [
      'next action',
      'next step',
      'first milestone',
      'milestone',
    ]);
    final projectNotes = transcript;

    return _StructuredVoiceFields(
      projectStatus: projectStatus,
      projectPriority: projectPriority,
      projectVision: projectVision,
      projectNextAction: projectNextAction ?? transcript,
      projectNotes: projectNotes,
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

  bool _isSummaryRequest(String transcript) {
    return transcript.contains('summarize today') ||
        transcript.contains('summarise today') ||
        transcript.contains('today summary') ||
        transcript.contains('daily review') ||
        transcript.contains('review today');
  }

  bool _isNextStepRequest(String transcript) {
    return transcript.contains('what\'s next') ||
        transcript.contains('what is next') ||
        transcript.contains('next step for') ||
        transcript.contains('next steps for') ||
        transcript.contains('what should i do next');
  }

  bool _isMemoryRequest(String transcript) {
    return transcript.contains('what do you remember') ||
        transcript.contains('what did you remember') ||
        transcript.contains('recall memory') ||
        transcript.contains('recall thread') ||
        transcript.contains('remember this thread') ||
        transcript.contains('last thread') ||
        transcript.contains('memory') ||
        transcript.contains('what did we talk about');
  }

  bool _isPlanningRequest(String transcript) {
    return transcript.contains('plan my day') ||
        transcript.contains('make a plan') ||
        transcript.contains('action plan') ||
        transcript.contains('help me plan') ||
        transcript.contains('plan this') ||
        transcript.contains('plan around this');
  }

  bool _isHelpRequest(String transcript) {
    return transcript.contains('what can you do') ||
        transcript.contains('what can i do') ||
        transcript.contains('help me') ||
        transcript == 'help' ||
        transcript.contains('help with') ||
        transcript.contains('what do you do');
  }

  bool _isConversationGreetingRequest(String transcript) {
    return transcript.contains('how are you') ||
        transcript.contains('how is it going') ||
        transcript.contains("how's it going") ||
        transcript.contains('what are you doing') ||
        transcript.contains('how do you feel') ||
        transcript.contains('are you there') ||
        transcript.contains('hello gaia') ||
        transcript.contains('hey gaia');
  }
}

class _StructuredVoiceFields {
  const _StructuredVoiceFields({
    this.taskCategory,
    this.taskPriority,
    this.projectStatus,
    this.projectPriority,
    this.projectVision,
    this.projectNextAction,
    this.projectNotes,
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
  final String? projectStatus;
  final String? projectPriority;
  final String? projectVision;
  final String? projectNextAction;
  final String? projectNotes;
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

class _WakePhraseExtraction {
  const _WakePhraseExtraction({
    required this.transcript,
    required this.usedWakePhrase,
    required this.wakePhrase,
  });

  final String transcript;
  final bool usedWakePhrase;
  final String? wakePhrase;
}
