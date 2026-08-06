import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../core/routing/route_names.dart';
import '../data/omega_experiment_models.dart';
import '../data/omega_experiment_repository.dart';

enum OmegaExperimentScreenSection {
  registry,
  create,
  evidence,
  results,
  lessons,
  reports,
  integrations,
  aiReview,
  settings,
}

extension OmegaExperimentScreenSectionLabel on OmegaExperimentScreenSection {
  String get label {
    switch (this) {
      case OmegaExperimentScreenSection.registry:
        return 'Workspace';
      case OmegaExperimentScreenSection.create:
        return 'New Draft';
      case OmegaExperimentScreenSection.evidence:
        return 'Evidence';
      case OmegaExperimentScreenSection.results:
        return 'Results';
      case OmegaExperimentScreenSection.lessons:
        return 'Lessons';
      case OmegaExperimentScreenSection.reports:
        return 'Reports';
      case OmegaExperimentScreenSection.integrations:
        return 'Integrations';
      case OmegaExperimentScreenSection.aiReview:
        return 'AI Review';
      case OmegaExperimentScreenSection.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case OmegaExperimentScreenSection.registry:
        return Icons.view_list_outlined;
      case OmegaExperimentScreenSection.create:
        return Icons.add_circle_outline;
      case OmegaExperimentScreenSection.evidence:
        return Icons.folder_copy_outlined;
      case OmegaExperimentScreenSection.results:
        return Icons.compare_arrows_outlined;
      case OmegaExperimentScreenSection.lessons:
        return Icons.lightbulb_outline;
      case OmegaExperimentScreenSection.reports:
        return Icons.description_outlined;
      case OmegaExperimentScreenSection.integrations:
        return Icons.integration_instructions_outlined;
      case OmegaExperimentScreenSection.aiReview:
        return Icons.auto_awesome_outlined;
      case OmegaExperimentScreenSection.settings:
        return Icons.settings_outlined;
    }
  }
}

enum OmegaExperimentEvidenceFilter {
  all,
  ready,
  needsEvidence,
  note,
  data,
  log,
  image,
  screenshot,
  file,
}

extension OmegaExperimentEvidenceFilterLabel on OmegaExperimentEvidenceFilter {
  String get label {
    switch (this) {
      case OmegaExperimentEvidenceFilter.all:
        return 'All';
      case OmegaExperimentEvidenceFilter.ready:
        return 'Evidence ready';
      case OmegaExperimentEvidenceFilter.needsEvidence:
        return 'Needs evidence';
      case OmegaExperimentEvidenceFilter.note:
        return 'Notes';
      case OmegaExperimentEvidenceFilter.data:
        return 'Data';
      case OmegaExperimentEvidenceFilter.log:
        return 'Logs';
      case OmegaExperimentEvidenceFilter.image:
        return 'Images';
      case OmegaExperimentEvidenceFilter.screenshot:
        return 'Screenshots';
      case OmegaExperimentEvidenceFilter.file:
        return 'Files';
    }
  }
}

enum OmegaExperimentTemplate {
  projectValidation,
  workflowTest,
  buildCheck,
  learningExperiment,
  researchCheck,
}

extension OmegaExperimentTemplateLabel on OmegaExperimentTemplate {
  String get label {
    switch (this) {
      case OmegaExperimentTemplate.projectValidation:
        return 'Project validation';
      case OmegaExperimentTemplate.workflowTest:
        return 'Workflow test';
      case OmegaExperimentTemplate.buildCheck:
        return 'Build / hardware check';
      case OmegaExperimentTemplate.learningExperiment:
        return 'Learning experiment';
      case OmegaExperimentTemplate.researchCheck:
        return 'Research check';
    }
  }

  String get description {
    switch (this) {
      case OmegaExperimentTemplate.projectValidation:
        return 'Check whether a project idea is worth carrying forward.';
      case OmegaExperimentTemplate.workflowTest:
        return 'Test a process, UI flow, or dashboard workflow end to end.';
      case OmegaExperimentTemplate.buildCheck:
        return 'Validate a build step, hardware part, or enclosure behaviour.';
      case OmegaExperimentTemplate.learningExperiment:
        return 'Capture a short learning run and record the lesson.';
      case OmegaExperimentTemplate.researchCheck:
        return 'Compare references, findings, or likely options before deciding.';
    }
  }
}

class OmegaExperimentScreen extends ConsumerStatefulWidget {
  const OmegaExperimentScreen({
    super.key,
    this.initialSection = OmegaExperimentScreenSection.registry,
    this.initialExperimentId,
  });

  final OmegaExperimentScreenSection initialSection;
  final String? initialExperimentId;

  @override
  ConsumerState<OmegaExperimentScreen> createState() =>
      _OmegaExperimentScreenState();
}

class _OmegaExperimentScreenState extends ConsumerState<OmegaExperimentScreen> {
  late OmegaExperimentScreenSection _section;
  String? _selectedExperimentId;
  OmegaExperimentEvidenceFilter _evidenceFilter =
      OmegaExperimentEvidenceFilter.all;
  OmegaExperimentTemplate _selectedTemplate =
      OmegaExperimentTemplate.projectValidation;

  final _titleController = TextEditingController();
  final _projectController = TextEditingController(text: 'MicroGrow');
  final _projectLinkController = TextEditingController(text: 'projects/microgrow');
  final _ownerController = TextEditingController(text: 'Peter Ellis');
  final _objectiveController = TextEditingController();
  final _hypothesisController = TextEditingController();
  final _testPlanController = TextEditingController();
  final _setupNotesController = TextEditingController();
  final _evidenceController = TextEditingController();
  final _measurementsController = TextEditingController();
  final _resultsController = TextEditingController();
  final _conclusionController = TextEditingController();
  final _lessonController = TextEditingController();
  final _nextActionsController = TextEditingController();
  final _repoCommitsController = TextEditingController();
  final _issuesController = TextEditingController();
  final _obsidianController = TextEditingController();

  OmegaExperimentStatus _createStatus = OmegaExperimentStatus.planned;
  OmegaExperimentCategory _createCategory =
      OmegaExperimentCategory.generalValidation;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _selectedExperimentId = widget.initialExperimentId;
    _fillTemplateFields(_selectedTemplate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _projectController.dispose();
    _projectLinkController.dispose();
    _ownerController.dispose();
    _objectiveController.dispose();
    _hypothesisController.dispose();
    _testPlanController.dispose();
    _setupNotesController.dispose();
    _evidenceController.dispose();
    _measurementsController.dispose();
    _resultsController.dispose();
    _conclusionController.dispose();
    _lessonController.dispose();
    _nextActionsController.dispose();
    _repoCommitsController.dispose();
    _issuesController.dispose();
    _obsidianController.dispose();
    super.dispose();
  }

  List<OmegaExperimentRecord> _filteredExperiments(
    Iterable<OmegaExperimentRecord> experiments,
  ) {
    return experiments
        .where(_matchesEvidenceFilter)
        .toList(growable: false);
  }

  bool _matchesEvidenceFilter(OmegaExperimentRecord experiment) {
    return switch (_evidenceFilter) {
      OmegaExperimentEvidenceFilter.all => true,
      OmegaExperimentEvidenceFilter.ready => experiment.hasEvidence,
      OmegaExperimentEvidenceFilter.needsEvidence => experiment.needsEvidence,
      OmegaExperimentEvidenceFilter.note =>
        experiment.evidenceTypes.contains(OmegaExperimentEvidenceType.note),
      OmegaExperimentEvidenceFilter.data =>
        experiment.evidenceTypes.contains(OmegaExperimentEvidenceType.data),
      OmegaExperimentEvidenceFilter.log =>
        experiment.evidenceTypes.contains(OmegaExperimentEvidenceType.log),
      OmegaExperimentEvidenceFilter.image =>
        experiment.evidenceTypes.contains(OmegaExperimentEvidenceType.image),
      OmegaExperimentEvidenceFilter.screenshot =>
        experiment.evidenceTypes.contains(
          OmegaExperimentEvidenceType.screenshot,
        ),
      OmegaExperimentEvidenceFilter.file =>
        experiment.evidenceTypes.contains(OmegaExperimentEvidenceType.file),
    };
  }

  void _setEvidenceFilter(OmegaExperimentEvidenceFilter value) {
    setState(() => _evidenceFilter = value);
  }

  void _applyTemplate(OmegaExperimentTemplate template) {
    setState(() => _selectedTemplate = template);
    _fillTemplateFields(template);
  }

  void _fillTemplateFields(OmegaExperimentTemplate template) {
    _titleController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation =>
        'New Project Validation Experiment',
      OmegaExperimentTemplate.workflowTest => 'New Workflow Test',
      OmegaExperimentTemplate.buildCheck => 'New Build Check',
      OmegaExperimentTemplate.learningExperiment => 'New Learning Experiment',
      OmegaExperimentTemplate.researchCheck => 'New Research Check',
    };

    _projectController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation => 'MicroGrow',
      OmegaExperimentTemplate.workflowTest => 'New Earth Dashboard',
      OmegaExperimentTemplate.buildCheck => 'MicroGrow',
      OmegaExperimentTemplate.learningExperiment => 'New Earth Dashboard',
      OmegaExperimentTemplate.researchCheck => 'MicroGrow',
    };

    _projectLinkController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation => 'projects/microgrow',
      OmegaExperimentTemplate.workflowTest => 'projects/new-earth-dashboard',
      OmegaExperimentTemplate.buildCheck => 'projects/microgrow',
      OmegaExperimentTemplate.learningExperiment => 'projects/new-earth-dashboard',
      OmegaExperimentTemplate.researchCheck => 'projects/microgrow',
    };

    _objectiveController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation =>
        'Validate whether this project direction is worth continuing.',
      OmegaExperimentTemplate.workflowTest =>
        'Test whether the workflow is clear, calm, and repeatable.',
      OmegaExperimentTemplate.buildCheck =>
        'Verify the build, part, or setup behaves as expected.',
      OmegaExperimentTemplate.learningExperiment =>
        'Capture one useful lesson from a focused learning run.',
      OmegaExperimentTemplate.researchCheck =>
        'Compare the available references before deciding the next step.',
    };

    _hypothesisController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation =>
        'If the setup is feasible, the project should show a clear next step.',
      OmegaExperimentTemplate.workflowTest =>
        'If the flow is simple enough, it should be easy to repeat without friction.',
      OmegaExperimentTemplate.buildCheck =>
        'If the build path is sound, the check should pass with minimal rework.',
      OmegaExperimentTemplate.learningExperiment =>
        'If the learning step is useful, it will produce one repeatable rule.',
      OmegaExperimentTemplate.researchCheck =>
        'If the references agree, the choice should become easier to make.',
    };

    _testPlanController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation =>
        '1. Review the project direction.\n2. List the risks.\n3. Decide whether to continue.',
      OmegaExperimentTemplate.workflowTest =>
        '1. Run the workflow.\n2. Note any confusion.\n3. Capture the best next step.',
      OmegaExperimentTemplate.buildCheck =>
        '1. Set up the build.\n2. Run the check.\n3. Record what passed or failed.',
      OmegaExperimentTemplate.learningExperiment =>
        '1. Study the topic.\n2. Practice once.\n3. Record the lesson and next step.',
      OmegaExperimentTemplate.researchCheck =>
        '1. Gather references.\n2. Compare findings.\n3. Record the recommendation.',
    };

    _setupNotesController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation =>
        'Use calm notes and keep the decision review-first.',
      OmegaExperimentTemplate.workflowTest =>
        'Focus on clarity, steps, and repeatability.',
      OmegaExperimentTemplate.buildCheck =>
        'Record the setup path, tools, and anything that could break the run.',
      OmegaExperimentTemplate.learningExperiment =>
        'Keep the experiment short so the lesson stays visible.',
      OmegaExperimentTemplate.researchCheck =>
        'Collect sources, links, and short notes only.',
    };

    _evidenceController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation => 'notes/validation-summary.md',
      OmegaExperimentTemplate.workflowTest => 'notes/workflow-observation.md',
      OmegaExperimentTemplate.buildCheck => 'data/build-log.txt',
      OmegaExperimentTemplate.learningExperiment => 'notes/learning-journal.md',
      OmegaExperimentTemplate.researchCheck => 'notes/research-summary.md',
    };

    _measurementsController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation =>
        'confidence\nrisk level\nnext action',
      OmegaExperimentTemplate.workflowTest => 'steps completed\nfriction points',
      OmegaExperimentTemplate.buildCheck => 'pass/fail\nnotes\nmeasurements',
      OmegaExperimentTemplate.learningExperiment => 'lesson clarity\npractice result',
      OmegaExperimentTemplate.researchCheck => 'source count\nagreement level',
    };

    _resultsController.text = 'Pending run.';
    _conclusionController.text = 'Pending run.';
    _lessonController.text = 'Pending run.';
    _nextActionsController.text = switch (template) {
      OmegaExperimentTemplate.projectValidation =>
        'Decide continue / park\nCreate follow-up task',
      OmegaExperimentTemplate.workflowTest =>
        'Refine the workflow\nCapture the best sequence',
      OmegaExperimentTemplate.buildCheck =>
        'Fix the issue\nRun the check again',
      OmegaExperimentTemplate.learningExperiment =>
        'Turn the lesson into a practice task\nStore the note',
      OmegaExperimentTemplate.researchCheck =>
        'Summarise the recommendation\nOpen a follow-up task',
    };

    _repoCommitsController.text = 'draft: template starter';
    _issuesController.text = '#000';
    _obsidianController.text = 'Template note';

    _createStatus = OmegaExperimentStatus.planned;
    _createCategory = switch (template) {
      OmegaExperimentTemplate.projectValidation =>
        OmegaExperimentCategory.generalValidation,
      OmegaExperimentTemplate.workflowTest =>
        OmegaExperimentCategory.softwareTest,
      OmegaExperimentTemplate.buildCheck =>
        OmegaExperimentCategory.mechanicalTest,
      OmegaExperimentTemplate.learningExperiment =>
        OmegaExperimentCategory.userTest,
      OmegaExperimentTemplate.researchCheck =>
        OmegaExperimentCategory.grantStrategyTest,
    };
  }

  @override
  Widget build(BuildContext context) {
    final workspaceAsync = ref.watch(omegaExperimentWorkspaceProvider);

    return workspaceAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => _goBack(context)),
          title: const Text('Experiment workspace'),
        ),
        body: Center(
          child: Text(
            'Could not load experiment workspace.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      data: (workspace) {
        _primeCreateForm(workspace);
        final visibleExperiments = _filteredExperiments(workspace.experiments);
        final selectedExperiments = _selectedExperimentId == null
            ? <OmegaExperimentRecord>[]
            : workspace.experiments
                  .where(
                    (experiment) =>
                        experiment.experimentId == _selectedExperimentId,
                  )
                  .toList(growable: false);
        final selectedExperimentRecord = selectedExperiments.isEmpty
            ? null
            : selectedExperiments.first;
        final repo = ref.read(omegaExperimentRepositoryProvider);

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () => _goBack(context),
            ),
            title: const Text('Experiment workspace'),
            actions: [
              IconButton(
                tooltip: 'Workspace',
                onPressed: () => _navigateTo(context, OmegaExperimentScreenSection.registry),
                icon: const Icon(Icons.view_list_outlined),
              ),
              IconButton(
                tooltip: 'New draft',
                onPressed: () => _navigateTo(context, OmegaExperimentScreenSection.create),
                icon: const Icon(Icons.add_circle_outline),
              ),
              IconButton(
                tooltip: 'Settings',
                onPressed: () => _navigateTo(context, OmegaExperimentScreenSection.settings),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeroCard(workspace: workspace),
              const SizedBox(height: 16),
              _SectionTabs(
                section: _section,
                onSelected: (section) => _navigateTo(context, section),
              ),
              const SizedBox(height: 16),
              switch (_section) {
                OmegaExperimentScreenSection.registry => _RegistrySection(
                    workspace: workspace,
                    visibleExperiments: visibleExperiments,
                    selectedExperiment: selectedExperimentRecord,
                    onSelectExperiment: (id) {
                      setState(() => _selectedExperimentId = id);
                    },
                    evidenceFilter: _evidenceFilter,
                    onEvidenceFilterChanged: _setEvidenceFilter,
                    onOpenCreate: () =>
                        _navigateTo(context, OmegaExperimentScreenSection.create),
                  ),
                OmegaExperimentScreenSection.create => _CreateSection(
                    workspace: workspace,
                    selectedTemplate: _selectedTemplate,
                    titleController: _titleController,
                    projectController: _projectController,
                    projectLinkController: _projectLinkController,
                    ownerController: _ownerController,
                    objectiveController: _objectiveController,
                    hypothesisController: _hypothesisController,
                    testPlanController: _testPlanController,
                    setupNotesController: _setupNotesController,
                    evidenceController: _evidenceController,
                    measurementsController: _measurementsController,
                    resultsController: _resultsController,
                    conclusionController: _conclusionController,
                    lessonController: _lessonController,
                    nextActionsController: _nextActionsController,
                    repoCommitsController: _repoCommitsController,
                    issuesController: _issuesController,
                    obsidianController: _obsidianController,
                    nextExperimentId: repo.nextExperimentId(workspace.experiments),
                    createStatus: _createStatus,
                    createCategory: _createCategory,
                    onTemplateSelected: _applyTemplate,
                    onStatusChanged: (status) =>
                        setState(() => _createStatus = status),
                    onCategoryChanged: (category) =>
                        setState(() => _createCategory = category),
                    onSave: () async {
                      final repo =
                          ref.read(omegaExperimentRepositoryProvider);
                      final nextId =
                          repo.nextExperimentId(workspace.experiments);
                      final draft = OmegaExperimentRecord(
                        experimentId: nextId,
                        title: _titleController.text.trim().isEmpty
                            ? 'Untitled Experiment'
                            : _titleController.text.trim(),
                        project: _projectController.text.trim().isEmpty
                            ? 'Unassigned'
                            : _projectController.text.trim(),
                        projectLink: _projectLinkController.text.trim(),
                        status: _createStatus,
                        category: _createCategory,
                        owner: _ownerController.text.trim(),
                        createdDate:
                            DateTime.now().toIso8601String().split('T').first,
                        objective: _objectiveController.text.trim(),
                        hypothesis: _hypothesisController.text.trim(),
                        testPlan: _testPlanController.text.trim(),
                        setupNotes: _setupNotesController.text.trim(),
                        evidenceFiles: _splitLines(_evidenceController.text),
                        measurements: _splitLines(
                          _measurementsController.text,
                        ),
                        softwareUsed: const ['Flutter dashboard'],
                        hardwareUsed: const [],
                        results: _resultsController.text.trim(),
                        conclusion: _conclusionController.text.trim(),
                        lessonLearned: _lessonController.text.trim(),
                        nextActions: _splitLines(_nextActionsController.text),
                        relatedRepoCommits:
                            _splitLines(_repoCommitsController.text),
                        relatedGithubIssues: _splitLines(_issuesController.text),
                        relatedObsidianNotes:
                            _splitLines(_obsidianController.text),
                      );
                      final path = await repo.createDraft(draft);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Draft saved to $path')),
                      );
                      setState(() {
                        _selectedExperimentId = nextId;
                        _section = OmegaExperimentScreenSection.registry;
                      });
                    },
                ),
                OmegaExperimentScreenSection.evidence => _EvidenceSection(
                    workspace: workspace,
                    visibleExperiments: visibleExperiments,
                    evidenceFilter: _evidenceFilter,
                    onEvidenceFilterChanged: _setEvidenceFilter,
                  ),
                OmegaExperimentScreenSection.results => _ResultsSection(
                    workspace: workspace,
                  ),
                OmegaExperimentScreenSection.lessons => _LessonsSection(
                    workspace: workspace,
                  ),
                OmegaExperimentScreenSection.reports => _ReportsSection(
                    workspace: workspace,
                  ),
                OmegaExperimentScreenSection.integrations =>
                  _IntegrationsSection(workspace: workspace),
                OmegaExperimentScreenSection.aiReview => _AiReviewSection(
                    workspace: workspace,
                  ),
                OmegaExperimentScreenSection.settings => _SettingsSection(
                    workspace: workspace,
                  ),
              },
            ],
          ),
        );
      },
    );
  }

  void _primeCreateForm(OmegaExperimentWorkspace workspace) {
    if (_titleController.text.isNotEmpty) {
      return;
    }

    _titleController.text = 'New Omega Experiment';
    _objectiveController.text =
        'Describe the measurement goal, validation question, or evidence gap.';
    _hypothesisController.text =
        'State the expected outcome before the test begins.';
    _testPlanController.text =
        'List the setup, steps, and success criteria for the experiment.';
    _setupNotesController.text =
        'Add any hardware, firmware, or tooling details needed for the run.';
    _evidenceController.text = 'evidence/notes.md';
    _measurementsController.text = 'measurement 1\nmeasurement 2';
    _resultsController.text = 'Pending first run.';
    _conclusionController.text = 'Pending first run.';
    _lessonController.text = 'Document the main rule learned from the run.';
    _nextActionsController.text = 'Capture evidence\nUpdate the report';
    _repoCommitsController.text = 'draft: link commit';
    _issuesController.text = '#000';
    _obsidianController.text = 'Experiment note';

    if (_projectController.text.isEmpty) {
      _projectController.text = workspace.experiments.isNotEmpty
          ? workspace.experiments.first.project
          : 'MicroGrow';
    }
  }

  void _navigateTo(
    BuildContext context,
    OmegaExperimentScreenSection section,
  ) {
    setState(() => _section = section);

    final route = switch (section) {
      OmegaExperimentScreenSection.registry => RouteNames.experimentWorkspace,
      OmegaExperimentScreenSection.create => RouteNames.experimentWorkspaceCreate,
      OmegaExperimentScreenSection.evidence => RouteNames.experimentWorkspaceEvidence,
      OmegaExperimentScreenSection.results => RouteNames.experimentWorkspaceResults,
      OmegaExperimentScreenSection.lessons => RouteNames.experimentWorkspaceLessons,
      OmegaExperimentScreenSection.reports => RouteNames.experimentWorkspaceReports,
      OmegaExperimentScreenSection.integrations =>
        RouteNames.experimentWorkspaceIntegrations,
      OmegaExperimentScreenSection.aiReview => RouteNames.experimentWorkspaceAiReview,
      OmegaExperimentScreenSection.settings => RouteNames.experimentWorkspaceSettings,
    };

    context.go(route);
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.experimentWorkspace);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.workspace});

  final OmegaExperimentWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Omega Experiment Workspace',
                  style: theme.textTheme.labelLarge,
                ),
                const Spacer(),
                Chip(
                  label: Text('Workspace ready'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'A safe-first registry for experiments, evidence, validation, and lessons learned.',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Routes, local storage, and report templates stay aligned with the imported module tree.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricTile(label: 'Experiments', value: '${workspace.experimentCount}'),
                _MetricTile(label: 'Active', value: '${workspace.activeExperimentCount}'),
                _MetricTile(label: 'Evidence ready', value: '${workspace.evidenceReadyCount}'),
                _MetricTile(label: 'Needs evidence', value: '${workspace.needsEvidenceCount}'),
                _MetricTile(label: 'Tools', value: '${workspace.supportedTools.length}'),
                _MetricTile(label: 'Reports', value: '${workspace.reportTemplates.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({
    required this.section,
    required this.onSelected,
  });

  final OmegaExperimentScreenSection section;
  final ValueChanged<OmegaExperimentScreenSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final sections = OmegaExperimentScreenSection.values;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in sections)
          ChoiceChip(
            selected: section == item,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 16),
                const SizedBox(width: 6),
                Text(item.label),
              ],
            ),
            onSelected: (_) => onSelected(item),
          ),
      ],
    );
  }
}

class _RegistrySection extends StatelessWidget {
  const _RegistrySection({
    required this.workspace,
    required this.visibleExperiments,
    required this.selectedExperiment,
    required this.onSelectExperiment,
    required this.evidenceFilter,
    required this.onEvidenceFilterChanged,
    required this.onOpenCreate,
  });

  final OmegaExperimentWorkspace workspace;
  final List<OmegaExperimentRecord> visibleExperiments;
  final OmegaExperimentRecord? selectedExperiment;
  final ValueChanged<String> onSelectExperiment;
  final OmegaExperimentEvidenceFilter evidenceFilter;
  final ValueChanged<OmegaExperimentEvidenceFilter> onEvidenceFilterChanged;
  final VoidCallback onOpenCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Experiment workspace', style: theme.textTheme.titleLarge),
            ),
            FilledButton.icon(
              onPressed: onOpenCreate,
              icon: const Icon(Icons.add),
              label: const Text('Add experiment'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(label: 'Ready to review', value: '${workspace.experiments.where((experiment) => experiment.hasAllCoreFields).length}'),
            _MetricTile(label: 'Evidence ready', value: '${workspace.evidenceReadyCount}'),
            _MetricTile(label: 'Needs evidence', value: '${workspace.needsEvidenceCount}'),
            _MetricTile(label: 'Projects', value: '${workspace.experiments.map((experiment) => experiment.project).toSet().length}'),
          ],
        ),
        const SizedBox(height: 12),
        _EvidenceFilterBar(
          filter: evidenceFilter,
          onChanged: onEvidenceFilterChanged,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            final list = Column(
              children: [
                if (visibleExperiments.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No experiments match the current evidence filter.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                for (final experiment in visibleExperiments) ...[
                  _ExperimentCard(
                    experiment: experiment,
                    selected: selectedExperiment?.experimentId ==
                        experiment.experimentId,
                    onTap: () => onSelectExperiment(experiment.experimentId),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );

            if (!wide) {
              return list;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: list),
                const SizedBox(width: 16),
                SizedBox(
                  width: 420,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: selectedExperiment == null
                        ? const _EmptyDetailPanel()
                        : KeyedSubtree(
                            key: ValueKey(selectedExperiment!.experimentId),
                            child: _ExperimentDetailPanel(
                              experiment: selectedExperiment!,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
        if (selectedExperiment != null) ...[
          const SizedBox(height: 16),
          if (MediaQuery.sizeOf(context).width < 1000)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(selectedExperiment!.experimentId),
                child: _ExperimentDetailPanel(
                  experiment: selectedExperiment!,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _EvidenceFilterBar extends StatelessWidget {
  const _EvidenceFilterBar({
    required this.filter,
    required this.onChanged,
  });

  final OmegaExperimentEvidenceFilter filter;
  final ValueChanged<OmegaExperimentEvidenceFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in OmegaExperimentEvidenceFilter.values)
          ChoiceChip(
            selected: filter == item,
            label: Text(item.label),
            onSelected: (_) => onChanged(item),
          ),
      ],
    );
  }
}

class _CreateSection extends StatelessWidget {
  const _CreateSection({
    required this.workspace,
    required this.selectedTemplate,
    required this.titleController,
    required this.projectController,
    required this.projectLinkController,
    required this.ownerController,
    required this.objectiveController,
    required this.hypothesisController,
    required this.testPlanController,
    required this.setupNotesController,
    required this.evidenceController,
    required this.measurementsController,
    required this.resultsController,
    required this.conclusionController,
    required this.lessonController,
    required this.nextActionsController,
    required this.repoCommitsController,
    required this.issuesController,
    required this.obsidianController,
    required this.nextExperimentId,
    required this.createStatus,
    required this.createCategory,
    required this.onTemplateSelected,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onSave,
  });

  final OmegaExperimentWorkspace workspace;
  final OmegaExperimentTemplate selectedTemplate;
  final TextEditingController titleController;
  final TextEditingController projectController;
  final TextEditingController projectLinkController;
  final TextEditingController ownerController;
  final TextEditingController objectiveController;
  final TextEditingController hypothesisController;
  final TextEditingController testPlanController;
  final TextEditingController setupNotesController;
  final TextEditingController evidenceController;
  final TextEditingController measurementsController;
  final TextEditingController resultsController;
  final TextEditingController conclusionController;
  final TextEditingController lessonController;
  final TextEditingController nextActionsController;
  final TextEditingController repoCommitsController;
  final TextEditingController issuesController;
  final TextEditingController obsidianController;
  final String nextExperimentId;
  final OmegaExperimentStatus createStatus;
  final OmegaExperimentCategory createCategory;
  final ValueChanged<OmegaExperimentTemplate> onTemplateSelected;
  final ValueChanged<OmegaExperimentStatus> onStatusChanged;
  final ValueChanged<OmegaExperimentCategory> onCategoryChanged;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create draft', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Draft a new experiment safely. Save writes a new local file only and never overwrites an existing draft.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricTile(label: 'Next ID', value: nextExperimentId),
                _MetricTile(label: 'Draft root', value: workspace.storageRootPath),
                _MetricTile(label: 'Dry-run safe', value: 'Yes'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Templates', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Choose a starter to preload a common experiment pattern.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final template in OmegaExperimentTemplate.values)
                  ChoiceChip(
                    selected: selectedTemplate == template,
                    label: Text(template.label),
                    onSelected: (_) => onTemplateSelected(template),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedTemplate.description,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _SectionField(
              controller: titleController,
              label: 'Title',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SectionField(
                    controller: projectController,
                    label: 'Project',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SectionField(
                    controller: projectLinkController,
                    label: 'Project link',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DropdownField<OmegaExperimentStatus>(
                    label: 'Lifecycle',
                    value: createStatus,
                    items: OmegaExperimentStatus.values,
                    onChanged: onStatusChanged,
                    labelFor: (value) => value.label,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownField<OmegaExperimentCategory>(
                    label: 'Category',
                    value: createCategory,
                    items: OmegaExperimentCategory.values,
                    onChanged: onCategoryChanged,
                    labelFor: (value) => value.label,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionField(controller: ownerController, label: 'Owner'),
            const SizedBox(height: 12),
            _SectionField(
              controller: objectiveController,
              label: 'Objective',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: hypothesisController,
              label: 'Hypothesis',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: testPlanController,
              label: 'Test plan',
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: setupNotesController,
              label: 'Setup notes',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: evidenceController,
              label: 'Evidence files, one per line',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: measurementsController,
              label: 'Measurements, one per line',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: resultsController,
              label: 'Results',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: conclusionController,
              label: 'Conclusion',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: lessonController,
              label: 'Lesson learned',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: nextActionsController,
              label: 'Next actions, one per line',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: repoCommitsController,
              label: 'Related repo commits, one per line',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: issuesController,
              label: 'Related GitHub issues, one per line',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _SectionField(
              controller: obsidianController,
              label: 'Related Obsidian notes, one per line',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    onSave();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save draft'),
                ),
                TextButton.icon(
                  onPressed: () {
                    onTemplateSelected(selectedTemplate);
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset starter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({
    required this.workspace,
    required this.visibleExperiments,
    required this.evidenceFilter,
    required this.onEvidenceFilterChanged,
  });

  final OmegaExperimentWorkspace workspace;
  final List<OmegaExperimentRecord> visibleExperiments;
  final OmegaExperimentEvidenceFilter evidenceFilter;
  final ValueChanged<OmegaExperimentEvidenceFilter> onEvidenceFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Evidence stream', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _EvidenceFilterBar(
          filter: evidenceFilter,
          onChanged: onEvidenceFilterChanged,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(label: 'Evidence ready', value: '${workspace.evidenceReadyCount}'),
            _MetricTile(label: 'Needs evidence', value: '${workspace.needsEvidenceCount}'),
            for (final entry in workspace.evidenceTypeCounts.entries)
              _MetricTile(label: entry.key.label, value: '${entry.value}'),
          ],
        ),
        const SizedBox(height: 16),
        if (visibleExperiments.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No experiments match the current evidence filter.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        for (final experiment in visibleExperiments) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(experiment.experimentId, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(experiment.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (experiment.evidenceFiles.isEmpty)
                        const Chip(label: Text('Needs evidence'))
                      else
                        for (final evidence in experiment.evidenceLabels)
                          Chip(label: Text(evidence)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    experiment.hasEvidence
                        ? (workspace.config.isSafePath(workspace.config.experimentsRoot)
                            ? 'Evidence should remain inside the approved Omega OS roots.'
                            : 'Evidence root needs a local path check before sync is trusted.')
                        : 'This experiment still needs proof before review is complete.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ResultsSection extends StatefulWidget {
  const _ResultsSection({required this.workspace});

  final OmegaExperimentWorkspace workspace;

  @override
  State<_ResultsSection> createState() => _ResultsSectionState();
}

class _ResultsSectionState extends State<_ResultsSection> {
  String? _leftExperimentId;
  String? _rightExperimentId;
  String? _comparisonThemeKey;

  @override
  void initState() {
    super.initState();
    final experiments = widget.workspace.experiments;
    if (experiments.isNotEmpty) {
      _rightExperimentId = experiments.last.experimentId;
    }
    if (experiments.length >= 2) {
      _leftExperimentId = experiments[experiments.length - 2].experimentId;
    } else if (experiments.isNotEmpty) {
      _leftExperimentId = experiments.last.experimentId;
    }
  }

  @override
  void didUpdateWidget(covariant _ResultsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final experimentIds = widget.workspace.experiments
        .map((experiment) => experiment.experimentId)
        .toSet();
    if (_leftExperimentId != null && !experimentIds.contains(_leftExperimentId)) {
      _leftExperimentId = widget.workspace.experiments.isNotEmpty
          ? widget.workspace.experiments.last.experimentId
          : null;
    }
    if (_rightExperimentId != null &&
        !experimentIds.contains(_rightExperimentId)) {
      _rightExperimentId = widget.workspace.experiments.isNotEmpty
          ? widget.workspace.experiments.last.experimentId
          : null;
    }
  }

  OmegaExperimentRecord? _experimentById(String? experimentId) {
    if (experimentId == null) {
      return null;
    }
    for (final experiment in widget.workspace.experiments) {
      if (experiment.experimentId == experimentId) {
        return experiment;
      }
    }
    return null;
  }

  void _compareTopRepeatedTheme() {
    final repeatedTheme = widget.workspace.lessonThemeCounts.entries
        .where((entry) => entry.value > 1 && entry.key.isNotEmpty)
        .toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    if (repeatedTheme.isEmpty) {
      return;
    }

    final targetTheme = repeatedTheme.first.key;
    final matches = widget.workspace.experiments
        .where((experiment) =>
            experiment.lessonThemeKey.isNotEmpty &&
            experiment.lessonThemeKey == targetTheme)
        .toList(growable: false);

    if (matches.length < 2) {
      return;
    }

    setState(() {
      _leftExperimentId = matches.first.experimentId;
      _rightExperimentId = matches[1].experimentId;
      _comparisonThemeKey = targetTheme;
    });
  }

  String _buildComparisonSummary(
    OmegaExperimentRecord left,
    OmegaExperimentRecord right,
  ) {
    return [
      '# Experiment Comparison',
      '',
      '## Left',
      '- ID: ${left.experimentId}',
      '- Title: ${left.title}',
      '- Lifecycle: ${left.status.lifecycleLabel}',
      '- Results: ${left.results}',
      '- Conclusion: ${left.conclusion}',
      '- Lesson: ${left.lessonLearned.isEmpty ? 'No lesson recorded yet.' : left.lessonLearned}',
      '- Next step: ${left.nextActions.isEmpty ? 'No next action recorded yet.' : left.nextActions.first}',
      '',
      '## Right',
      '- ID: ${right.experimentId}',
      '- Title: ${right.title}',
      '- Lifecycle: ${right.status.lifecycleLabel}',
      '- Results: ${right.results}',
      '- Conclusion: ${right.conclusion}',
      '- Lesson: ${right.lessonLearned.isEmpty ? 'No lesson recorded yet.' : right.lessonLearned}',
      '- Next step: ${right.nextActions.isEmpty ? 'No next action recorded yet.' : right.nextActions.first}',
      '',
      '## Quick read',
      '- Shared lesson theme: ${left.lessonThemeKey.isNotEmpty && left.lessonThemeKey == right.lessonThemeKey ? left.lessonThemeKey : 'Different or not yet captured'}',
      '- Evidence counts: ${left.evidenceFiles.length} vs ${right.evidenceFiles.length}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final withLessons = widget.workspace.experimentsWithLessons;
    final repeatedThemes = widget.workspace.lessonThemeCounts.entries
        .where((entry) => entry.value > 1)
        .toList(growable: false);
    final recentLessons = withLessons.reversed.take(3).toList(growable: false);
    final leftExperiment = _experimentById(_leftExperimentId);
    final rightExperiment = _experimentById(_rightExperimentId);
    final comparisonReady =
        leftExperiment != null && rightExperiment != null && leftExperiment != rightExperiment;
    final comparisonTheme = _comparisonThemeKey;
    final comparisonThemeCount = comparisonTheme == null
        ? null
        : widget.workspace.lessonThemeCounts[comparisonTheme];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Results review', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pick experiments to compare', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Choose any two experiment records and compare their lifecycle, lesson, and next step side by side.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final controls = [
                      _ComparisonSelector(
                        label: 'Left experiment',
                        value: _leftExperimentId,
                        experiments: widget.workspace.experiments,
                        onChanged: (value) => setState(() => _leftExperimentId = value),
                      ),
                      _ComparisonSelector(
                        label: 'Right experiment',
                        value: _rightExperimentId,
                        experiments: widget.workspace.experiments,
                        onChanged: (value) => setState(() => _rightExperimentId = value),
                      ),
                    ];

                    if (!wide) {
                      return Column(
                        children: [
                          controls[0],
                          const SizedBox(height: 12),
                          controls[1],
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: controls[0]),
                        const SizedBox(width: 12),
                        Expanded(child: controls[1]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (!comparisonReady)
                  Text(
                    'Select two different experiments to compare them side by side.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 760;
                      final left = _ComparisonCard(
                        label: 'Left',
                        experiment: leftExperiment,
                      );
                      final right = _ComparisonCard(
                        label: 'Right',
                        experiment: rightExperiment,
                      );

                      if (!wide) {
                        return Column(
                          children: [
                            left,
                            const SizedBox(height: 12),
                            right,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: 12),
                          Expanded(child: right),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 12),
                if (comparisonReady)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        final summary = _buildComparisonSummary(
                          leftExperiment,
                          rightExperiment,
                        );
                        await Clipboard.setData(ClipboardData(text: summary));
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comparison summary copied.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy comparison summary'),
                    ),
                  ),
                const SizedBox(height: 12),
                if (comparisonReady)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final summary = _buildComparisonSummary(
                          leftExperiment,
                          rightExperiment,
                        );
                        final savedPath = await _saveWorkspaceReport(
                          widget.workspace,
                          'comparison_${leftExperiment.experimentId}_${rightExperiment.experimentId}',
                          summary,
                        );
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              savedPath == null
                                  ? 'Comparison folder is not configured yet.'
                                  : 'Saved comparison summary to $savedPath',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save comparison'),
                    ),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.workspace.lessonThemeCounts.entries.any(
                              (entry) => entry.value > 1 && entry.key.isNotEmpty,
                            )
                            ? _compareTopRepeatedTheme
                            : null,
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: const Text('Compare top theme'),
                      ),
                      if (comparisonTheme != null)
                        Chip(
                          avatar: const Icon(Icons.local_fire_department_outlined),
                          label: Text(
                            comparisonThemeCount == null
                                ? comparisonTheme
                                : '$comparisonTheme x$comparisonThemeCount',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lesson patterns', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (repeatedThemes.isEmpty)
                  Text(
                    'No repeated lesson themes yet. Keep capturing lessons and the pattern view will become more useful over time.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in repeatedThemes)
                        Chip(label: Text('${entry.key} x${entry.value}')),
                    ],
                  ),
                const SizedBox(height: 12),
                if (recentLessons.isNotEmpty) ...[
                  Text('Recent lessons', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  for (final experiment in recentLessons)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${experiment.experimentId} - ${experiment.lessonLearned}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Lifecycle')),
              DataColumn(label: Text('Results')),
              DataColumn(label: Text('Conclusion')),
            ],
            rows: [
              for (final experiment in widget.workspace.experiments)
                DataRow(
                  cells: [
                    DataCell(Text(experiment.experimentId)),
                    DataCell(Text(experiment.title)),
                    DataCell(Text(experiment.status.lifecycleLabel)),
                    DataCell(Text(experiment.results)),
                    DataCell(Text(experiment.conclusion)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.label,
    required this.experiment,
  });

  final String label;
  final OmegaExperimentRecord experiment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(experiment.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(experiment.status.lifecycleLabel)),
                Chip(label: Text(experiment.category.label)),
                Chip(label: Text('${experiment.evidenceFiles.length} evidence')),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Lesson',
              style: theme.textTheme.labelMedium,
            ),
            Text(
              experiment.lessonLearned.isEmpty
                  ? 'No lesson recorded yet.'
                  : experiment.lessonLearned,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Next',
              style: theme.textTheme.labelMedium,
            ),
            Text(
              experiment.nextActions.isEmpty
                  ? 'No next action recorded yet.'
                  : experiment.nextActions.first,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonSelector extends StatelessWidget {
  const _ComparisonSelector({
    required this.label,
    required this.value,
    required this.experiments,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<OmegaExperimentRecord> experiments;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final experiment in experiments)
          DropdownMenuItem<String>(
            value: experiment.experimentId,
            child: Text(
              '${experiment.experimentId} - ${experiment.title}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _LessonsSection extends StatelessWidget {
  const _LessonsSection({required this.workspace});

  final OmegaExperimentWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lessons learned', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final experiment in workspace.experiments) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(experiment.title),
              subtitle: Text(
                experiment.lessonLearned.isEmpty
                    ? 'No lesson recorded yet.'
                    : experiment.lessonLearned,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ReportsSection extends StatefulWidget {
  const _ReportsSection({required this.workspace});

  final OmegaExperimentWorkspace workspace;

  @override
  State<_ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends State<_ReportsSection> {
  String? _selectedReportPath;

  @override
  void initState() {
    super.initState();
    _syncSelection();
  }

  @override
  void didUpdateWidget(covariant _ReportsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSelection();
  }

  void _syncSelection() {
    final reports = _listWorkspaceReports(widget.workspace);
    if (reports.isEmpty) {
      _selectedReportPath = null;
      return;
    }

    final selectedStillExists =
        _selectedReportPath != null &&
        reports.any((report) => report.path == _selectedReportPath);
    if (!selectedStillExists) {
      _selectedReportPath = reports.first.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestExperiments = widget.workspace.experiments.reversed.take(3).toList();
    final reportMarkdown = _buildWorkspaceReportMarkdown(
      widget.workspace,
      latestExperiments,
    );
    final savedReports = _listWorkspaceReports(widget.workspace);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reports', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Template set', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final template in widget.workspace.reportTemplates)
                  Text('- $template'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace report',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate a calm markdown summary from the latest experiments and save it into the local reports folder.',
                ),
                const SizedBox(height: 12),
                SelectableText(
                  reportMarkdown,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final savedPath = await _saveWorkspaceReport(
                          widget.workspace,
                          'workspace_report',
                          reportMarkdown,
                        );
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              savedPath == null
                                  ? 'Report folder is not configured yet.'
                                  : 'Saved workspace report to $savedPath',
                            ),
                          ),
                        );
                        setState(_syncSelection);
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save report'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: reportMarkdown),
                        );
                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Workspace report copied.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy markdown'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await _openWorkspaceReportsFolder(widget.workspace);
                      },
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('Open folder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Report output root'),
            subtitle: Text(p.join(widget.workspace.storageRootPath, 'reports')),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved reports', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (savedReports.isEmpty)
                  Text(
                    'No saved markdown reports yet. Save one above to start the archive.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Column(
                    children: [
                      for (final report in savedReports) ...[
                        _SavedReportListTile(
                          report: report,
                          selected: report.path == _selectedReportPath,
                          onSelect: () {
                            setState(() => _selectedReportPath = report.path);
                          },
                          onOpen: () async {
                            await _openWorkspaceReport(report);
                          },
                          onDelete: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Delete saved report?'),
                                  content: Text(
                                    'This will permanently remove ${p.basename(report.path)} from the local reports folder.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed != true) {
                              return;
                            }

                            try {
                              if (await report.exists()) {
                                await report.delete();
                              }
                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                if (_selectedReportPath == report.path) {
                                  _selectedReportPath = null;
                                  _syncSelection();
                                }
                              });

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Deleted ${p.basename(report.path)}.',
                                  ),
                                ),
                              );
                            } catch (_) {
                            if (!mounted) {
                                return;
                              }

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not delete ${p.basename(report.path)}.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        if (report != savedReports.last)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SavedReportPreviewCard(
          workspace: widget.workspace,
          selectedReportPath: _selectedReportPath,
          onSelectedReportPathChanged: (value) {
            setState(() => _selectedReportPath = value);
          },
        ),
      ],
    );
  }
}

class _SavedReportPreviewCard extends StatelessWidget {
  const _SavedReportPreviewCard({
    required this.workspace,
    required this.selectedReportPath,
    required this.onSelectedReportPathChanged,
  });

  final OmegaExperimentWorkspace workspace;
  final String? selectedReportPath;
  final ValueChanged<String?> onSelectedReportPathChanged;

  @override
  Widget build(BuildContext context) {
    final reports = _listWorkspaceReports(workspace);
    File? report;
    if (selectedReportPath != null) {
      for (final item in reports) {
        if (item.path == selectedReportPath) {
          report = item;
          break;
        }
      }
    }
    final selectedReport = report;
    final preview = selectedReport != null && selectedReport.existsSync()
        ? (() {
            try {
              return selectedReport.readAsStringSync();
            } catch (_) {
              return null;
            }
          })()
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report preview', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (reports.isEmpty)
              Text(
                'Save a report first, then choose it here to preview the markdown in place.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
              DropdownButtonFormField<String>(
                initialValue: selectedReportPath,
                decoration: const InputDecoration(
                  labelText: 'Saved report',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final item in reports)
                    DropdownMenuItem<String>(
                      value: item.path,
                      child: Text(
                        p.basename(item.path),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onSelectedReportPathChanged,
              ),
              const SizedBox(height: 12),
              if (report != null) ...[
                Text(
                  report.path,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      preview ?? 'This report could not be read.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SavedReportListTile extends StatelessWidget {
  const _SavedReportListTile({
    required this.report,
    required this.selected,
    required this.onSelect,
    required this.onOpen,
    required this.onDelete,
  });

  final File report;
  final bool selected;
  final VoidCallback onSelect;
  final Future<void> Function() onOpen;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return ListTile(
      selected: selected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.description_outlined,
        color: selected ? accent : null,
      ),
      title: Text(p.basename(report.path)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(report.path),
          if (selected) ...[
            const SizedBox(height: 6),
            Chip(
              avatar: const Icon(Icons.check_circle_outline),
              label: const Text('Selected'),
            ),
          ],
        ],
      ),
      onTap: onSelect,
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'open') {
            await onOpen();
          } else if (value == 'delete') {
            await onDelete();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'open',
            child: Text('Open'),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

String _buildWorkspaceReportMarkdown(
  OmegaExperimentWorkspace workspace,
  List<OmegaExperimentRecord> latestExperiments,
) {
  final repeatedThemes = workspace.lessonThemeCounts.entries
      .where((entry) => entry.value > 1)
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final buffer = StringBuffer()
    ..writeln('# Omega Experiment Workspace Report')
    ..writeln()
    ..writeln('## Summary')
    ..writeln('- Total experiments: ${workspace.experimentCount}')
    ..writeln('- Active lifecycle: ${workspace.activeExperimentCount}')
    ..writeln('- Evidence ready: ${workspace.evidenceReadyCount}')
    ..writeln('- Needs evidence: ${workspace.needsEvidenceCount}')
    ..writeln('- Repeated lesson themes: ${repeatedThemes.length}')
    ..writeln()
    ..writeln('## Latest experiments');

  if (latestExperiments.isEmpty) {
    buffer
      ..writeln('- No experiments available yet.')
      ..writeln();
  } else {
    for (final experiment in latestExperiments) {
      buffer
        ..writeln('- `${experiment.experimentId}` ${experiment.title}')
        ..writeln('  - Lifecycle: ${experiment.status.lifecycleLabel}')
        ..writeln('  - Result: ${experiment.conclusion}')
        ..writeln(
          '  - Lesson: ${experiment.lessonLearned.isEmpty ? 'No lesson recorded yet.' : experiment.lessonLearned}',
        );
    }
    buffer.writeln();
  }

  buffer.writeln('## Repeated lesson themes');
  if (repeatedThemes.isEmpty) {
    buffer
      ..writeln('- No repeated themes yet.')
      ..writeln();
  } else {
    for (final theme in repeatedThemes) {
      buffer.writeln('- ${theme.key} (${theme.value})');
    }
    buffer.writeln();
  }

  buffer.writeln('## Report templates');
  if (workspace.reportTemplates.isEmpty) {
    buffer
      ..writeln('- No report templates configured.')
      ..writeln();
  } else {
    for (final template in workspace.reportTemplates) {
      buffer.writeln('- $template');
    }
    buffer.writeln();
  }

  return buffer.toString();
}

Future<String?> _saveWorkspaceReport(
  OmegaExperimentWorkspace workspace,
  String fileNamePrefix,
  String markdown,
) async {
  final moduleRoot = Directory(workspace.moduleRootPath);
  if (!moduleRoot.existsSync()) {
    return null;
  }

  final reportsDir = Directory(
    p.join(workspace.moduleRootPath, 'storage', 'reports'),
  );
  await reportsDir.create(recursive: true);

  final timestamp = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final reportFile = File(
    p.join(reportsDir.path, '${fileNamePrefix}_$timestamp.md'),
  );
  await reportFile.writeAsString(markdown, flush: true);
  return reportFile.path;
}

Future<void> _openWorkspaceReportsFolder(
  OmegaExperimentWorkspace workspace,
) async {
  final reportsDir = Directory(
    p.join(workspace.moduleRootPath, 'storage', 'reports'),
  );
  await reportsDir.create(recursive: true);

  if (Platform.isWindows) {
    await Process.start('explorer.exe', <String>[reportsDir.path]);
    return;
  }

  if (Platform.isMacOS) {
    await Process.start('open', <String>[reportsDir.path]);
    return;
  }

  await Process.start('xdg-open', <String>[reportsDir.path]);
}

List<File> _listWorkspaceReports(OmegaExperimentWorkspace workspace) {
  final reportsDir = Directory(
    p.join(workspace.moduleRootPath, 'storage', 'reports'),
  );
  if (!reportsDir.existsSync()) {
    return const [];
  }

  final files = reportsDir
      .listSync(followLinks: false)
      .whereType<File>()
      .where((file) => p.extension(file.path).toLowerCase() == '.md')
      .toList()
    ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

  return files;
}

Future<void> _openWorkspaceReport(File report) async {
  final normalized = report.path;
  if (Platform.isWindows) {
    await Process.start('explorer.exe', <String>[normalized]);
    return;
  }

  if (Platform.isMacOS) {
    await Process.start('open', <String>[normalized]);
    return;
  }

  await Process.start('xdg-open', <String>[normalized]);
}

class _IntegrationsSection extends StatelessWidget {
  const _IntegrationsSection({required this.workspace});

  final OmegaExperimentWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Software integrations', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tool in workspace.supportedTools)
              Chip(label: Text(tool)),
          ],
        ),
      ],
    );
  }
}

class _AiReviewSection extends StatelessWidget {
  const _AiReviewSection({required this.workspace});

  final OmegaExperimentWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI review queue', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Ready for future local AI review'),
                SizedBox(height: 8),
                Text('Summarise likely failure causes'),
                Text('Propose the next test'),
                Text('Draft the engineering summary'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('AI root'),
            subtitle: Text(workspace.config.aiRoot),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.workspace});

  final OmegaExperimentWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final config = workspace.config;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workspace settings', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Omega root', value: config.omegaRoot),
                _DetailRow(label: 'Experiments root', value: config.experimentsRoot),
                _DetailRow(label: 'Knowledge root', value: config.knowledgeRoot),
                _DetailRow(label: 'AI root', value: config.aiRoot),
                _DetailRow(label: 'Visual root', value: config.visualRoot),
                _DetailRow(label: 'Obsidian vault', value: config.obsidianVault),
                _DetailRow(label: 'GitHub owner', value: config.githubOwner),
                _DetailRow(label: 'GitHub repo', value: config.githubRepo),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safe path validation', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final root in config.approvedRoots)
                  Text('- $root'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({
    required this.experiment,
    required this.selected,
    required this.onTap,
  });

  final OmegaExperimentRecord experiment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.9)
        : theme.colorScheme.outlineVariant;
    final backgroundColor = selected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.14)
        : theme.colorScheme.surface;

    return Card(
      elevation: selected ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        experiment.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (selected)
                      Chip(
                        label: const Text('Selected'),
                        visualDensity: VisualDensity.compact,
                      )
                    else
                      Chip(
                        label: Text(experiment.status.lifecycleLabel),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${experiment.experimentId} • ${experiment.project}',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  experiment.objective,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(experiment.category.label)),
                    Chip(label: Text('${experiment.nextActions.length} next actions')),
                    if (experiment.hasEvidence) ...[
                      Chip(label: Text('${experiment.evidenceFiles.length} evidence')),
                      for (final type in experiment.evidenceTypes.take(2))
                        Chip(label: Text(type.label)),
                    ] else
                      const Chip(label: Text('Needs evidence')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExperimentDetailPanel extends StatelessWidget {
  const _ExperimentDetailPanel({required this.experiment});

  final OmegaExperimentRecord experiment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Experiment detail', style: theme.textTheme.titleMedium),
                const Spacer(),
                Chip(
                  label: Text(experiment.status.lifecycleLabel),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(experiment.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              experiment.objective,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('ID: ${experiment.experimentId}')),
                Chip(label: Text(experiment.project)),
                Chip(label: Text(experiment.category.label)),
                Chip(label: Text('Owner: ${experiment.owner}')),
                Chip(label: Text('Created: ${experiment.createdDate}')),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Project link', value: experiment.projectLink),
            _DetailRow(label: 'Hypothesis', value: experiment.hypothesis),
            _DetailRow(label: 'Test plan', value: experiment.testPlan),
            _DetailRow(label: 'Setup notes', value: experiment.setupNotes),
            _DetailRow(label: 'Measurements', value: experiment.measurements.join('\n')),
            _DetailRow(label: 'Results', value: experiment.results),
            _DetailRow(label: 'Conclusion', value: experiment.conclusion),
            _DetailRow(label: 'Lesson learned', value: experiment.lessonLearned),
            _DetailRow(label: 'Next actions', value: experiment.nextActions.join('\n')),
            _DetailRow(
              label: 'Repo commits',
              value: experiment.relatedRepoCommits.join('\n'),
            ),
            _DetailRow(
              label: 'GitHub issues',
              value: experiment.relatedGithubIssues.join('\n'),
            ),
            _DetailRow(
              label: 'Obsidian notes',
              value: experiment.relatedObsidianNotes.join('\n'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Evidence review', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      experiment.hasEvidence
                          ? 'Evidence is attached and can be filtered by type.'
                          : 'This experiment still needs evidence before it is fully review-ready.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (experiment.hasEvidence)
                          for (final label in experiment.evidenceLabels)
                            Chip(label: Text(label))
                        else
                          const Chip(label: Text('Needs evidence')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Linked workflow', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      experiment.hasProjectLink
                          ? 'Open the linked project and carry the outcome into a task or journal note.'
                          : 'This experiment has no explicit project link yet, so it will fall back to the project name.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.push(
                              RouteNames.projectDetail(
                                experiment.linkedProjectId,
                              ),
                            );
                          },
                          icon: const Icon(Icons.folder_open_outlined),
                          label: const Text('Open project'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.push(
                              RouteNames.newTaskForProject(
                                experiment.linkedProjectId,
                              ),
                            );
                          },
                          icon: const Icon(Icons.checklist_outlined),
                          label: const Text('Add task'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.push(
                              RouteNames.newJournalForProject(
                                experiment.linkedProjectId,
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_note_outlined),
                          label: const Text('Add journal'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.push(RouteNames.projectsWorkspace);
                          },
                          icon: const Icon(Icons.account_tree_outlined),
                          label: const Text('Open projects'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reuse outcome', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Turn this result into the next practical action without retyping the context.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.push(
                              RouteNames.newTaskWithContext(
                                projectId: experiment.linkedProjectId,
                                title: 'Follow-up: ${experiment.title}',
                                description: experiment.objective,
                                notes: [
                                  if (experiment.results.isNotEmpty)
                                    'Result: ${experiment.results}',
                                  if (experiment.conclusion.isNotEmpty)
                                    'Conclusion: ${experiment.conclusion}',
                                  if (experiment.lessonLearned.isNotEmpty)
                                    'Lesson: ${experiment.lessonLearned}',
                                ].join('\n'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.checklist_outlined),
                          label: const Text('Create task'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.push(
                              RouteNames.newJournalWithContext(
                                projectId: experiment.linkedProjectId,
                                title: 'Journal: ${experiment.title}',
                                whatIWorkedOn: experiment.objective,
                                whatILearned: experiment.lessonLearned,
                                nextActions: experiment.nextActions.join('\n'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_note_outlined),
                          label: const Text('Create journal'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.push(
                              RouteNames.newLearningWithContext(
                                projectId: experiment.linkedProjectId,
                                topic: experiment.title,
                                reason: experiment.objective,
                                resourceLink: experiment.relatedObsidianNotes.isNotEmpty
                                    ? experiment.relatedObsidianNotes.first
                                    : experiment.projectLink,
                                notes: [
                                  if (experiment.lessonLearned.isNotEmpty)
                                    experiment.lessonLearned,
                                  if (experiment.conclusion.isNotEmpty)
                                    'Conclusion: ${experiment.conclusion}',
                                ].join('\n'),
                                nextStep: experiment.nextActions.isNotEmpty
                                    ? experiment.nextActions.first
                                    : null,
                              ),
                            );
                          },
                          icon: const Icon(Icons.menu_book_outlined),
                          label: const Text('Create learning'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            context.push(
                              RouteNames.newContentWithContext(
                                projectId: experiment.linkedProjectId,
                                title: '${experiment.title} summary',
                                draftText: [
                                  if (experiment.objective.isNotEmpty)
                                    'Objective: ${experiment.objective}',
                                  if (experiment.results.isNotEmpty)
                                    'Results: ${experiment.results}',
                                  if (experiment.conclusion.isNotEmpty)
                                    'Conclusion: ${experiment.conclusion}',
                                ].join('\n\n'),
                                imagePrompt:
                                    'Create a calm visual summary for ${experiment.title}',
                                notes: experiment.lessonLearned,
                              ),
                            );
                          },
                          icon: const Icon(Icons.article_outlined),
                          label: const Text('Create content'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDetailPanel extends StatelessWidget {
  const _EmptyDetailPanel();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Select an experiment to see the detail panel.'),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(value.isEmpty ? 'None' : value),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionField extends StatelessWidget {
  const _SectionField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelFor,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T value) labelFor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(labelFor(item)),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

List<String> _splitLines(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}


