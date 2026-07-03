import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/education_services.dart';
import '../data/education_repository.dart';
import '../domain/education_models.dart';

class EducationLearningHubScreen extends StatefulWidget {
  const EducationLearningHubScreen({super.key, this.repository});

  final EducationRepository? repository;

  @override
  State<EducationLearningHubScreen> createState() =>
      _EducationLearningHubScreenState();
}

class _EducationLearningHubScreenState
    extends State<EducationLearningHubScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabLabels = [
    'Dashboard',
    'Learning Pathways',
    'Lesson Library',
    'Practical Projects',
    'Student Progress',
    'AI Tutor',
    'Mentor Workspace',
    'Assessments',
    'Reflection Journal',
    'Certificates & Badges',
    'Settings',
  ];

  late final EducationRepository _repository =
      widget.repository ?? LocalEducationRepository();
  late final TextEditingController _searchController;
  late final TabController _tabController;
  EducationHubSnapshot? _snapshot;
  String? _error;
  bool _loading = true;
  int _initialTabIndex = 0;
  bool _resolvedInitialTabIndex = false;
  String _searchQuery = '';
  EducationAudience _audienceFilter = EducationAudience.all;
  String? _selectedStudentId;
  String? _selectedPathwayId;
  String? _tutorPrompt;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    unawaited(_loadSnapshot());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedInitialTabIndex) {
      return;
    }

    final tab = GoRouterState.of(context).uri.queryParameters['tab'];
    _initialTabIndex = _tabIndexFor(tab);
    _resolvedInitialTabIndex = true;
    _tabController.index = _initialTabIndex;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSnapshot() async {
    try {
      final snapshot = await _repository.loadSnapshot();
      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _loading = false;
        _error = null;
        _selectedStudentId = snapshot.students.isEmpty
            ? null
            : snapshot.students.first.id;
        _selectedPathwayId = snapshot.pathways.isEmpty
            ? null
            : snapshot.pathways.first.id;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  int _tabIndexFor(String? tab) {
    return switch (tab) {
      'pathways' => 1,
      'lesson-library' => 2,
      'projects' => 3,
      'progress' => 4,
      'tutor' => 5,
      'mentor' => 6,
      'assessments' => 7,
      'reflection' => 8,
      'certificates' => 9,
      'settings' => 10,
      _ => 0,
    };
  }

  EducationHubSnapshot get _snapshotOrThrow {
    final snapshot = _snapshot;
    if (snapshot == null) {
      throw StateError('Education hub snapshot not loaded.');
    }
    return snapshot;
  }

  List<LearningPathway> _filteredPathways(EducationHubSnapshot snapshot) {
    final query = _searchQuery.trim().toLowerCase();
    return snapshot.pathways.where((pathway) {
      if (_audienceFilter != EducationAudience.all &&
          !pathway.audiences.contains(_audienceFilter.name)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return pathway.title.toLowerCase().contains(query) ||
          pathway.summary.toLowerCase().contains(query) ||
          pathway.domain.toLowerCase().contains(query) ||
          pathway.skillTags.any((tag) => tag.toLowerCase().contains(query));
    }).toList(growable: false);
  }

  List<Lesson> _filteredLessons(EducationHubSnapshot snapshot) {
    final query = _searchQuery.trim().toLowerCase();
    return snapshot.lessons.where((lesson) {
      if (_audienceFilter != EducationAudience.all &&
          !lesson.audiences.contains(_audienceFilter.name)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return lesson.title.toLowerCase().contains(query) ||
          lesson.summary.toLowerCase().contains(query) ||
          lesson.objective.toLowerCase().contains(query) ||
          lesson.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList(growable: false);
  }

  List<PracticalProject> _filteredProjects(EducationHubSnapshot snapshot) {
    final query = _searchQuery.trim().toLowerCase();
    return snapshot.projects.where((project) {
      if (_audienceFilter != EducationAudience.all &&
          !project.audiences.contains(_audienceFilter.name)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return project.title.toLowerCase().contains(query) ||
          project.summary.toLowerCase().contains(query) ||
          project.domain.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  void _copyText(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied locally.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _snapshot == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go(RouteNames.more)),
          title: const Text('Education & Learning Hub'),
        ),
        body: _ErrorState(
          error: _error!,
          onRetry: () {
            setState(() {
              _loading = true;
              _error = null;
            });
            unawaited(_loadSnapshot());
          },
        ),
      );
    }

    final snapshot = _snapshotOrThrow;
    final pathwayService = LearningPathwayService(snapshot);
    final progressService = ProgressService(snapshot);
    final assessmentService = AssessmentService(snapshot);
    final reflectionService = ReflectionService(snapshot);
    final certificateService = CertificateService(snapshot);
    final searchService = SearchService(snapshot);
    final tutorService = TutorService(snapshot);
    final currentStudent = snapshot.students.firstWhere(
      (student) => student.id == _selectedStudentId,
      orElse: () => snapshot.students.first,
    );
    final selectedPathway = pathwayService.pathwayById(_selectedPathwayId ?? '') ??
        snapshot.pathways.first;
    final searchHits = searchService.search(
      _searchQuery,
      audience: _audienceFilter,
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RouteNames.more)),
        title: const Text('Education & Learning Hub'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(RouteNames.omegaKnowledgeEngine),
            icon: const Icon(Icons.travel_explore_outlined),
            label: const Text('Knowledge Engine'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.push(RouteNames.voiceAssistant),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('GAIA placeholder'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: _HeroCard(
                snapshot: snapshot,
                searchController: _searchController,
                searchQuery: _searchQuery,
                audienceFilter: _audienceFilter,
                selectedStudent: currentStudent,
                onQueryChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onAudienceChanged: (value) {
                  setState(() {
                    _audienceFilter = value;
                  });
                },
                onPickStudent: (studentId) {
                  setState(() {
                    _selectedStudentId = studentId;
                  });
                },
                onClearSearch: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                onCopyRoute: () => _copyText(
                  snapshot.settings.knowledgeEngineRoute,
                  'Knowledge Engine route',
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                for (final label in _tabLabels) Tab(text: label),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DashboardTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    selectedPathway: selectedPathway,
                    searchHits: searchHits,
                    searchQuery: _searchQuery,
                    progressService: progressService,
                    reflectionService: reflectionService,
                    certificateService: certificateService,
                    tutorService: tutorService,
                    onOpenPathways: () => _tabController.animateTo(1),
                    onOpenLessons: () => _tabController.animateTo(2),
                    onOpenProjects: () => _tabController.animateTo(3),
                    onOpenTutor: () => _tabController.animateTo(5),
                  ),
                  _PathwaysTab(
                    snapshot: snapshot,
                    filteredPathways: _filteredPathways(snapshot),
                    selectedPathwayId: _selectedPathwayId,
                    onSelectPathway: (pathwayId) {
                      setState(() {
                        _selectedPathwayId = pathwayId;
                      });
                    },
                  ),
                  _LessonLibraryTab(
                    snapshot: snapshot,
                    filteredLessons: _filteredLessons(snapshot),
                    selectedAudience: _audienceFilter,
                    onAudienceChanged: (value) {
                      setState(() {
                        _audienceFilter = value;
                      });
                    },
                  ),
                  _ProjectsTab(
                    snapshot: snapshot,
                    projects: _filteredProjects(snapshot),
                  ),
                  _ProgressTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    progressService: progressService,
                  ),
                  _TutorTab(
                    snapshot: snapshot,
                    tutorService: tutorService,
                    prompt: _tutorPrompt,
                    onPromptChanged: (value) {
                      setState(() {
                        _tutorPrompt = value;
                      });
                    },
                    onUseSuggestion: (prompt) {
                      setState(() {
                        _tutorPrompt = prompt;
                        _tabController.animateTo(2);
                        _searchQuery = prompt;
                        _searchController.text = prompt;
                      });
                    },
                  ),
                  _MentorTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    onSelectStudent: (studentId) {
                      setState(() {
                        _selectedStudentId = studentId;
                      });
                    },
                  ),
                  _AssessmentsTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    assessments: assessmentService.assessmentsForAudience(
                      _audienceFilter,
                    ),
                  ),
                  _ReflectionTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    reflections: reflectionService.reflectionsForAudience(
                      _audienceFilter,
                    ),
                  ),
                  _CertificatesTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    certificates: certificateService.certificatesForAudience(
                      _audienceFilter,
                    ),
                  ),
                  _SettingsTab(
                    snapshot: snapshot,
                    onOpenKnowledgeEngine: () =>
                        context.push(RouteNames.omegaKnowledgeEngine),
                    onOpenGaiaPlaceholder: () =>
                        context.push(RouteNames.voiceAssistant),
                    onOpenMore: () => context.go(RouteNames.more),
                    onExportRoute: () => _copyText(
                      snapshot.settings.gaiaAssistantRoute,
                      'GAIA route placeholder',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.snapshot,
    required this.searchController,
    required this.searchQuery,
    required this.audienceFilter,
    required this.selectedStudent,
    required this.onQueryChanged,
    required this.onAudienceChanged,
    required this.onPickStudent,
    required this.onClearSearch,
    required this.onCopyRoute,
  });

  final EducationHubSnapshot snapshot;
  final TextEditingController searchController;
  final String searchQuery;
  final EducationAudience audienceFilter;
  final StudentProfile selectedStudent;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<EducationAudience> onAudienceChanged;
  final ValueChanged<String> onPickStudent;
  final VoidCallback onClearSearch;
  final VoidCallback onCopyRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Education Dashboard',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A calm learning operating system for electronics, embedded systems, MicroGrow, BioCalm, AI literacy, resilience, and practical project work.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetricBadge(
                          label: 'Pathways',
                          value: '${snapshot.pathwayCount}',
                        ),
                        _MetricBadge(
                          label: 'Lessons',
                          value: '${snapshot.lessonCount}',
                        ),
                        _MetricBadge(
                          label: 'Projects',
                          value: '${snapshot.projectCount}',
                        ),
                        _MetricBadge(
                          label: 'Learners',
                          value: '${snapshot.learnerCount}',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  onChanged: onQueryChanged,
                  decoration: InputDecoration(
                    labelText: 'Search pathways, lessons, projects, and resources',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: onClearSearch,
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final audience in EducationAudience.values)
                      ChoiceChip(
                        label: Text(audience.label),
                        selected: audienceFilter == audience,
                        onSelected: (_) => onAudienceChanged(audience),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: onCopyRoute,
                      icon: const Icon(Icons.route_outlined),
                      label: const Text('Copy engine route'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onPickStudent(selectedStudent.id),
                      icon: const Icon(Icons.switch_account_outlined),
                      label: Text('Active learner: ${selectedStudent.name}'),
                    ),
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

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.selectedPathway,
    required this.searchHits,
    required this.searchQuery,
    required this.progressService,
    required this.reflectionService,
    required this.certificateService,
    required this.tutorService,
    required this.onOpenPathways,
    required this.onOpenLessons,
    required this.onOpenProjects,
    required this.onOpenTutor,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final LearningPathway selectedPathway;
  final List<EducationSearchHit> searchHits;
  final String searchQuery;
  final ProgressService progressService;
  final ReflectionService reflectionService;
  final CertificateService certificateService;
  final TutorService tutorService;
  final VoidCallback onOpenPathways;
  final VoidCallback onOpenLessons;
  final VoidCallback onOpenProjects;
  final VoidCallback onOpenTutor;

  @override
  Widget build(BuildContext context) {
    final progress = progressService.completionForStudent(selectedStudent.id);
    final reflections = reflectionService.reflectionsForAudience(
      EducationAudience.all,
    );
    final certificates = certificateService.certificatesForAudience(
      EducationAudience.all,
    );
    final tutorResponse = tutorService.respond(
      searchQuery.isEmpty ? selectedPathway.title : searchQuery,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Today at a glance',
          subtitle: 'Pick the next useful action without overload.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoTile(
                label: 'Active pathway',
                value: selectedPathway.title,
                detail: selectedPathway.summary,
              ),
              _InfoTile(
                label: 'Selected learner',
                value: selectedStudent.name,
                detail: selectedStudent.stage,
              ),
              _InfoTile(
                label: 'Completion',
                value: '${(progress * 100).round()}%',
                detail: 'Across recent progress records',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ActionCard(
              title: 'Learning Pathways',
              subtitle: 'Browse the calm route map for study and build work.',
              buttonText: 'Open pathways',
              onPressed: onOpenPathways,
            ),
            _ActionCard(
              title: 'Lesson Library',
              subtitle: 'Step-by-step lessons with offline content structure.',
              buttonText: 'Open lessons',
              onPressed: onOpenLessons,
            ),
            _ActionCard(
              title: 'Practical Projects',
              subtitle: 'Use project workspaces to turn learning into evidence.',
              buttonText: 'Open projects',
              onPressed: onOpenProjects,
            ),
            _ActionCard(
              title: 'AI Tutor',
              subtitle: 'Suggestion-only tutor with safety-aware placeholder flow.',
              buttonText: 'Open tutor',
              onPressed: onOpenTutor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Recommended next lesson',
          subtitle: 'A calm starting point for the next step.',
          child: _LessonCard(
            lesson: snapshot.lessons.firstWhere(
              (lesson) => lesson.pathwayId == selectedPathway.id,
              orElse: () => snapshot.lessons.first,
            ),
            showActions: false,
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Tutor response preview',
          subtitle: 'Placeholder AI guidance that stays local and safe.',
          child: _TutorPreviewCard(response: tutorResponse),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Recent reflections',
          subtitle: 'Short entries that support learning and memory.',
          child: reflections.isEmpty
              ? const _EmptyInline(
                  title: 'No reflections yet',
                  subtitle: 'Add one after the next lesson or project step.',
                )
              : Column(
                  children: [
                    for (final reflection in reflections.take(3))
                      _ReflectionCard(reflection: reflection),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Certificates and badges',
          subtitle: 'Placeholder badge system for future export.',
          child: certificates.isEmpty
              ? const _EmptyInline(
                  title: 'No certificates yet',
                  subtitle: 'Certificates will appear after assessment sign-off.',
                )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final certificate in certificates.take(4))
                        _CertificateChip(certificate: certificate),
                    ],
                  ),
        ),
        if (searchHits.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Panel(
            title: 'Search matches',
            subtitle: 'Local search across the learning hub content.',
            child: Column(
              children: [
                for (final hit in searchHits.take(6)) _SearchHitCard(hit: hit),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PathwaysTab extends StatelessWidget {
  const _PathwaysTab({
    required this.snapshot,
    required this.filteredPathways,
    required this.selectedPathwayId,
    required this.onSelectPathway,
  });

  final EducationHubSnapshot snapshot;
  final List<LearningPathway> filteredPathways;
  final String? selectedPathwayId;
  final ValueChanged<String> onSelectPathway;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Learning Pathways',
          subtitle: 'Browse the supported learning routes for New Earth.',
          child: filteredPathways.isEmpty
              ? const _EmptyInline(
                  title: 'No pathways match the filter',
                  subtitle: 'Try a broader search or switch audience view.',
                )
              : Column(
                  children: [
                    for (final pathway in filteredPathways)
                      _PathwayCard(
                        pathway: pathway,
                        selected: pathway.id == selectedPathwayId,
                        onTap: () => onSelectPathway(pathway.id),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _LessonLibraryTab extends StatelessWidget {
  const _LessonLibraryTab({
    required this.snapshot,
    required this.filteredLessons,
    required this.selectedAudience,
    required this.onAudienceChanged,
  });

  final EducationHubSnapshot snapshot;
  final List<Lesson> filteredLessons;
  final EducationAudience selectedAudience;
  final ValueChanged<EducationAudience> onAudienceChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Lesson Library',
          subtitle: 'Calm reading panels, steps, and reflection prompts.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final audience in EducationAudience.values)
                    FilterChip(
                      label: Text(audience.label),
                      selected: selectedAudience == audience,
                      onSelected: (_) => onAudienceChanged(audience),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (filteredLessons.isEmpty)
                const _EmptyInline(
                  title: 'No lessons match the current view',
                  subtitle: 'Try changing audience or clearing the search.',
                )
              else
                Column(
                  children: [
                    for (final lesson in filteredLessons) _LessonCard(lesson: lesson),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab({required this.snapshot, required this.projects});

  final EducationHubSnapshot snapshot;
  final List<PracticalProject> projects;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Practical Projects',
          subtitle: 'Small project workspaces with materials, steps, and evidence.',
          child: Column(
            children: [
              for (final project in projects) _ProjectCard(project: project),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.progressService,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final ProgressService progressService;

  @override
  Widget build(BuildContext context) {
    final studentProgress = snapshot.progressForStudent(selectedStudent.id);
    final completion = progressService.completionForStudent(selectedStudent.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Student Progress',
          subtitle: 'A local view of pathways, lessons, projects, and completion.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoTile(
                label: 'Active learner',
                value: selectedStudent.name,
                detail: '${selectedStudent.role} • ${selectedStudent.stage}',
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: completion),
              const SizedBox(height: 8),
              Text('${(completion * 100).round()}% overall learning progress'),
              const SizedBox(height: 12),
              if (studentProgress.isEmpty)
                const _EmptyInline(
                  title: 'No progress records yet',
                  subtitle: 'Progress will appear as lessons and projects are completed.',
                )
              else
                Column(
                  children: [
                    for (final record in studentProgress) _ProgressRecordCard(record: record),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TutorTab extends StatelessWidget {
  const _TutorTab({
    required this.snapshot,
    required this.tutorService,
    required this.prompt,
    required this.onPromptChanged,
    required this.onUseSuggestion,
  });

  final EducationHubSnapshot snapshot;
  final TutorService tutorService;
  final String? prompt;
  final ValueChanged<String> onPromptChanged;
  final ValueChanged<String> onUseSuggestion;

  @override
  Widget build(BuildContext context) {
    final response = tutorService.respond(prompt ?? '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'AI Tutor',
          subtitle: 'Suggestion-only tutor with safety guardrails.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: onPromptChanged,
                decoration: const InputDecoration(
                  labelText: 'Ask a question',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _TutorPreviewCard(response: response),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final question in response.practiceQuestions)
                    ActionChip(
                      label: Text(question),
                      onPressed: () => onUseSuggestion(question),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Integration hook: later this tab can hand off to the Omega Knowledge Engine or GAIA assistant without changing the learning content model.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MentorTab extends StatelessWidget {
  const _MentorTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.onSelectStudent,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final ValueChanged<String> onSelectStudent;

  @override
  Widget build(BuildContext context) {
    final notes = snapshot.notesForStudent(selectedStudent.id);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Mentor Workspace',
          subtitle: 'Track learner notes, support actions, and gentle sign-off.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final student in snapshot.students)
                    ChoiceChip(
                      label: Text(student.name),
                      selected: student.id == selectedStudent.id,
                      onSelected: (_) => onSelectStudent(student.id),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Mentor',
                value: selectedStudent.mentorName,
                detail: 'Guardian: ${selectedStudent.guardianName}',
              ),
              const SizedBox(height: 12),
              if (notes.isEmpty)
                const _EmptyInline(
                  title: 'No mentor notes yet',
                  subtitle: 'Mentor notes will appear as work sessions progress.',
                )
              else
                Column(
                  children: [
                    for (final note in notes) _MentorNoteCard(note: note),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssessmentsTab extends StatelessWidget {
  const _AssessmentsTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.assessments,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final List<Assessment> assessments;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Assessments',
          subtitle: 'Practical checklists, simple scores, and mentor feedback.',
          child: Column(
            children: [
              for (final assessment in assessments)
                _AssessmentCard(assessment: assessment),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReflectionTab extends StatelessWidget {
  const _ReflectionTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.reflections,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final List<ReflectionEntry> reflections;

  @override
  Widget build(BuildContext context) {
    final studentReflections = reflections
        .where((reflection) => reflection.studentId == selectedStudent.id)
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Reflection Journal',
          subtitle: 'A quiet place for learning memory and practical insight.',
          child: studentReflections.isEmpty
              ? const _EmptyInline(
                  title: 'No reflections yet',
                  subtitle: 'Add a reflection after the next learning step.',
                )
              : Column(
                  children: [
                    for (final reflection in studentReflections)
                      _ReflectionCard(reflection: reflection),
                  ],
                ),
        ),
      ],
    );
  }
}

class _CertificatesTab extends StatelessWidget {
  const _CertificatesTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.certificates,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final List<Certificate> certificates;

  @override
  Widget build(BuildContext context) {
    final studentCertificates = certificates
        .where((certificate) => certificate.studentId == selectedStudent.id)
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Certificates & Badges',
          subtitle: 'Placeholder badge system ready for later export flows.',
          child: studentCertificates.isEmpty
              ? const _EmptyInline(
                  title: 'No badges issued yet',
                  subtitle: 'Badges will appear when assessments are signed off.',
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final certificate in studentCertificates)
                      _CertificateCard(certificate: certificate),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    required this.snapshot,
    required this.onOpenKnowledgeEngine,
    required this.onOpenGaiaPlaceholder,
    required this.onOpenMore,
    required this.onExportRoute,
  });

  final EducationHubSnapshot snapshot;
  final VoidCallback onOpenKnowledgeEngine;
  final VoidCallback onOpenGaiaPlaceholder;
  final VoidCallback onOpenMore;
  final VoidCallback onExportRoute;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Settings',
          subtitle: 'Local-first module settings and integration hooks.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoTile(
                label: 'Module root',
                value: snapshot.settings.moduleRootPath,
                detail: 'Content root: ${snapshot.settings.contentRootPath}',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Offline-first',
                value: snapshot.settings.offlineOnly ? 'Enabled' : 'Disabled',
                detail: 'Learning content stays local by default.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: onOpenKnowledgeEngine,
                    icon: const Icon(Icons.travel_explore_outlined),
                    label: const Text('Open Omega Knowledge Engine'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenGaiaPlaceholder,
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Open GAIA placeholder'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onExportRoute,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy GAIA route'),
                  ),
                  TextButton.icon(
                    onPressed: onOpenMore,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to More'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _TodoList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(subtitle),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  const _EmptyInline({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Icon(Icons.auto_stories_outlined, size: 36),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text(
                'The Education Hub could not load.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathwayCard extends StatelessWidget {
  const _PathwayCard({
    required this.pathway,
    required this.selected,
    required this.onTap,
  });

  final LearningPathway pathway;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.24)
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pathway.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (selected)
                    const Chip(label: Text('Selected'))
                  else
                    Chip(label: Text(pathway.level)),
                ],
              ),
              const SizedBox(height: 6),
              Text(pathway.summary),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(label: pathway.domain),
                  _MiniBadge(label: '${pathway.estimatedHours} h'),
                  for (final tag in pathway.skillTags.take(3)) _MiniBadge(label: tag),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, this.showActions = true});

  final Lesson lesson;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _MiniBadge(label: '${lesson.estimatedMinutes} min'),
              ],
            ),
            const SizedBox(height: 4),
            Text(lesson.summary),
            const SizedBox(height: 6),
            Text('Objective: ${lesson.objective}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(label: lesson.difficulty),
                for (final tag in lesson.tags.take(3)) _MiniBadge(label: tag),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Open lesson'),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.checklist_outlined),
                    label: const Text('Save progress'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final PracticalProject project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(project.summary),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(label: project.domain),
                _MiniBadge(label: '${project.estimatedHours} h'),
                for (final skill in project.skillTags.take(3)) _MiniBadge(label: skill),
              ],
            ),
            const SizedBox(height: 8),
            Text('Materials: ${project.materials.join(', ')}'),
            const SizedBox(height: 4),
            Text('Steps: ${project.steps.join(' • ')}'),
          ],
        ),
      ),
    );
  }
}

class _ProgressRecordCard extends StatelessWidget {
  const _ProgressRecordCard({required this.record});

  final ProgressRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${record.entityType.toUpperCase()} • ${record.entityId}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                _MiniBadge(label: record.status),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: record.progressPercent / 100),
            const SizedBox(height: 6),
            Text('${record.progressPercent}% complete'),
            const SizedBox(height: 2),
            Text('Updated ${record.updatedAt.toLocal()}'),
            if (record.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(record.note),
            ],
          ],
        ),
      ),
    );
  }
}

class _TutorPreviewCard extends StatelessWidget {
  const _TutorPreviewCard({required this.response});

  final EducationTutorResponse response;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(response.summary),
          const SizedBox(height: 8),
          Text('Next step: ${response.nextStep}'),
          const SizedBox(height: 8),
          Text('Safety note: ${response.safetyNote}'),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.reflection});

  final ReflectionEntry reflection;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reflection.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _MiniBadge(label: reflection.mood),
              ],
            ),
            const SizedBox(height: 6),
            Text(reflection.body),
            const SizedBox(height: 4),
            Text('Created ${reflection.createdAt.toLocal()}'),
          ],
        ),
      ),
    );
  }
}

class _MentorNoteCard extends StatelessWidget {
  const _MentorNoteCard({required this.note});

  final MentorNote note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.author,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _MiniBadge(label: note.priority),
              ],
            ),
            const SizedBox(height: 6),
            Text(note.content),
            const SizedBox(height: 4),
            Text('Created ${note.createdAt.toLocal()}'),
          ],
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    final completed = assessment.completedAt != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assessment.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _MiniBadge(label: completed ? 'Complete' : 'Pending'),
              ],
            ),
            const SizedBox(height: 6),
            Text(assessment.summary),
            const SizedBox(height: 4),
            Text(
              'Score: ${assessment.score}/${assessment.maxScore} • ${assessment.kind}',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final criterion in assessment.criteria.take(4))
                  _MiniBadge(label: criterion),
              ],
            ),
            if (assessment.mentorFeedback.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Mentor note: ${assessment.mentorFeedback}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(certificate.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(certificate.summary),
          const SizedBox(height: 8),
          _MiniBadge(label: certificate.badgeLevel),
          const SizedBox(height: 4),
          Text('Issued by ${certificate.issuedBy}'),
          const SizedBox(height: 2),
          Text('Awarded ${certificate.awardedAt.toLocal()}'),
        ],
      ),
    );
  }
}

class _CertificateChip extends StatelessWidget {
  const _CertificateChip({required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(certificate.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(certificate.badgeLevel),
        ],
      ),
    );
  }
}

class _SearchHitCard extends StatelessWidget {
  const _SearchHitCard({required this.hit});

  final EducationSearchHit hit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hit.title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(hit.subtitle),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MiniBadge(label: hit.kind),
                const SizedBox(height: 4),
                Text(hit.needle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Developer notes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const _TodoLine('Add richer lesson player interactions later.'),
        const _TodoLine('Wire content pack import/export for offline packs.'),
        const _TodoLine('Connect tutor prompts to a future approval gate.'),
        const _TodoLine('Replace the placeholder Open GAIA route with the real assistant flow when ready.'),
      ],
    );
  }
}

class _TodoLine extends StatelessWidget {
  const _TodoLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
