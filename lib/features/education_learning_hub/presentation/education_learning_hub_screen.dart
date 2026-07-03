import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/education_services.dart';
import '../data/education_repository.dart';
import '../domain/education_models.dart';

enum EducationRoleView { student, mentor, parentGuardian, admin }

extension EducationRoleViewLabel on EducationRoleView {
  String get label {
    return switch (this) {
      EducationRoleView.student => 'Student',
      EducationRoleView.mentor => 'Mentor',
      EducationRoleView.parentGuardian => 'Parent / Guardian',
      EducationRoleView.admin => 'Admin',
    };
  }

  String get summary {
    return switch (this) {
      EducationRoleView.student =>
        'Focus on the next useful lesson, project, and reflection.',
      EducationRoleView.mentor =>
        'Review learner support, notes, and sign-off cues.',
      EducationRoleView.parentGuardian =>
        'Check progress, wellbeing, and simple at-home support.',
      EducationRoleView.admin =>
        'Review content, pathways, settings, and learning safety.',
    };
  }
}

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
  EducationRoleView _roleView = EducationRoleView.student;
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

  Future<void> _saveLessonProgress({
    required StudentProfile student,
    required Lesson lesson,
  }) async {
    final snapshot = _snapshotOrThrow;
    final record = await _repository.saveProgressRecord(
      studentId: student.id,
      entityId: lesson.id,
      entityType: 'lesson',
      progressPercent: 100,
      status: 'complete',
      note: 'Completed ${lesson.title} locally.',
    );
    if (!mounted) {
      return;
    }

    final updatedRecords = snapshot.progressRecords.toList(growable: true);
    final index = updatedRecords.indexWhere(
      (value) => value.studentId == record.studentId && value.entityId == record.entityId,
    );
    if (index >= 0) {
      updatedRecords[index] = record;
    } else {
      updatedRecords.add(record);
    }

    setState(() {
      _snapshot = snapshot.copyWith(progressRecords: updatedRecords);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${lesson.title} saved as complete for ${student.name}.')),
    );
  }

  Future<void> _saveProjectProgress({
    required StudentProfile student,
    required PracticalProject project,
  }) async {
    final snapshot = _snapshotOrThrow;
    final record = await _repository.saveProgressRecord(
      studentId: student.id,
      entityId: project.id,
      entityType: 'project',
      progressPercent: 75,
      status: 'in progress',
      note: 'Logged a project evidence checkpoint for ${project.title}.',
    );
    if (!mounted) {
      return;
    }

    final updatedRecords = snapshot.progressRecords.toList(growable: true);
    final index = updatedRecords.indexWhere(
      (value) => value.studentId == record.studentId && value.entityId == record.entityId,
    );
    if (index >= 0) {
      updatedRecords[index] = record;
    } else {
      updatedRecords.add(record);
    }

    setState(() {
      _snapshot = snapshot.copyWith(progressRecords: updatedRecords);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${project.title} evidence saved locally for ${student.name}.')),
    );
  }

  void _openLessonDetails(Lesson lesson) {
    final snapshot = _snapshotOrThrow;
    final pathway = snapshot.pathways.firstWhere(
      (value) => value.id == lesson.pathwayId,
      orElse: () => snapshot.pathways.first,
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _LessonDetailSheet(
        lesson: lesson,
        pathway: pathway,
        resources: snapshot.resources
            .where((resource) => lesson.resourceIds.contains(resource.id))
            .toList(growable: false),
        onSaveProgress: () => _saveLessonProgress(
          student: _snapshotOrThrow.students.firstWhere(
            (student) => student.id == _selectedStudentId,
            orElse: () => _snapshotOrThrow.students.first,
          ),
          lesson: lesson,
        ),
      ),
    );
  }

  void _openProjectWorkspace(PracticalProject project) {
    final snapshot = _snapshotOrThrow;
    final selectedStudent = snapshot.students.firstWhere(
      (student) => student.id == _selectedStudentId,
      orElse: () => snapshot.students.first,
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ProjectWorkspaceSheet(
        project: project,
        selectedStudent: selectedStudent,
        roleView: _roleView,
        resources: snapshot.resources
            .where((resource) => project.resourceIds.contains(resource.id))
            .toList(growable: false),
        evidenceRecords: snapshot.progressForProject(project.id),
        onSaveCheckpoint: () => _saveProjectProgress(
          student: selectedStudent,
          project: project,
        ),
      ),
    );
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
        _roleView = snapshot.students.isEmpty
            ? EducationRoleView.student
            : _roleViewForStudent(snapshot.students.first.role);
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

  EducationRoleView _roleViewForStudent(String role) {
    return switch (role.toLowerCase()) {
      'mentor' => EducationRoleView.mentor,
      'parentguardian' => EducationRoleView.parentGuardian,
      'admin' => EducationRoleView.admin,
      _ => EducationRoleView.student,
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
                  final selected = snapshot.students.firstWhere(
                    (student) => student.id == studentId,
                    orElse: () => snapshot.students.first,
                  );
                  setState(() {
                    _selectedStudentId = studentId;
                    _roleView = _roleViewForStudent(selected.role);
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
                    roleView: _roleView,
                    progressService: progressService,
                    reflectionService: reflectionService,
                    certificateService: certificateService,
                    tutorService: tutorService,
                    contentSources: snapshot.contentSources,
                    onSaveLessonProgress: (lesson) =>
                        _saveLessonProgress(student: currentStudent, lesson: lesson),
                    onOpenLessonDetails: _openLessonDetails,
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
                    selectedStudent: currentStudent,
                    roleView: _roleView,
                    onAudienceChanged: (value) {
                      setState(() {
                        _audienceFilter = value;
                      });
                    },
                    onOpenLessonDetails: _openLessonDetails,
                    onSaveLessonProgress: (lesson) =>
                        _saveLessonProgress(student: currentStudent, lesson: lesson),
                  ),
                  _ProjectsTab(
                    snapshot: snapshot,
                    projects: _filteredProjects(snapshot),
                    selectedStudent: currentStudent,
                    roleView: _roleView,
                    onOpenProjectWorkspace: _openProjectWorkspace,
                    onSaveProjectProgress: (project) =>
                        _saveProjectProgress(student: currentStudent, project: project),
                  ),
                  _ProgressTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    roleView: _roleView,
                    progressService: progressService,
                  ),
                  _TutorTab(
                    snapshot: snapshot,
                    tutorService: tutorService,
                    prompt: _tutorPrompt,
                    selectedStudent: currentStudent,
                    selectedPathway: selectedPathway,
                    roleView: _roleView,
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
                    roleView: _roleView,
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
                    contentSources: snapshot.contentSources,
                    roleView: _roleView,
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
    required this.roleView,
    required this.progressService,
    required this.reflectionService,
    required this.certificateService,
    required this.tutorService,
    required this.contentSources,
    required this.onSaveLessonProgress,
    required this.onOpenLessonDetails,
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
  final EducationRoleView roleView;
  final ProgressService progressService;
  final ReflectionService reflectionService;
  final CertificateService certificateService;
  final TutorService tutorService;
  final List<ContentSourceEntry> contentSources;
  final ValueChanged<Lesson> onSaveLessonProgress;
  final ValueChanged<Lesson> onOpenLessonDetails;
  final VoidCallback onOpenPathways;
  final VoidCallback onOpenLessons;
  final VoidCallback onOpenProjects;
  final VoidCallback onOpenTutor;

  @override
  Widget build(BuildContext context) {
    final progress = progressService.completionForStudent(selectedStudent.id);
    final completionLabel = '${(progress * 100).round()}% complete';
    final reflections = reflectionService.reflectionsForAudience(
      EducationAudience.all,
    );
    final certificates = certificateService.certificatesForAudience(
      EducationAudience.all,
    );
    final tutorResponse = tutorService.respond(
      searchQuery.isEmpty ? selectedPathway.title : searchQuery,
      learnerName: selectedStudent.name,
      pathwayTitle: selectedPathway.title,
      roleLabel: roleView.label,
      completionLabel: completionLabel,
    );
    final studentAssessments = snapshot.assessmentsForStudent(selectedStudent.id);
    final badgeReadiness = snapshot.badgeReadinessForStudent(selectedStudent.id);

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
              _InfoTile(
                label: 'Role view',
                value: roleView.label,
                detail: roleView.summary,
              ),
              _InfoTile(
                label: 'Badge readiness',
                value: '${(badgeReadiness * 100).round()}%',
                detail: '${snapshot.earnedBadgeCountForStudent(selectedStudent.id)} earned badge(s)',
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
            onSaveProgress: onSaveLessonProgress,
            onOpenLessonDetails: onOpenLessonDetails,
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
          title: 'Learner checkpoint',
          subtitle: 'What the tutor and the local progress snapshot can see right now.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoTile(
                label: 'Assessments complete',
                value: '${studentAssessments.where((assessment) => assessment.completedAt != null).length}/${studentAssessments.length}',
                detail: 'Used to shape badge readiness',
              ),
              _InfoTile(
                label: 'Progress note',
                value: snapshot.progressLabelForStudent(selectedStudent.id),
                detail: 'The tutor stays advisory only',
              ),
            ],
          ),
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
          subtitle: 'Placeholder badge system for future export and mentor sign-off.',
          child: certificates.isEmpty
              ? const _EmptyInline(
                  title: 'No certificates yet',
                  subtitle: 'Certificates will appear after assessment sign-off.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _InfoTile(
                          label: 'Learner badges',
                          value: '${snapshot.earnedBadgeCountForStudent(selectedStudent.id)}',
                          detail: 'Local badge ids already issued',
                        ),
                        _InfoTile(
                          label: 'Assessments complete',
                          value: '${snapshot.completedAssessmentsForStudent(selectedStudent.id).length}',
                          detail: 'Ready for review and sign-off',
                        ),
                        _InfoTile(
                          label: 'Badge readiness',
                          value: '${(snapshot.badgeReadinessForStudent(selectedStudent.id) * 100).round()}%',
                          detail: 'Based on progress and assessments',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final certificate in certificates.take(4))
                          _CertificateChip(certificate: certificate),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Completed assessments',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (studentAssessments.where((assessment) => assessment.completedAt != null).isEmpty)
                      const _EmptyInline(
                        title: 'No completed assessments yet',
                        subtitle: 'Finish a lesson or project checkpoint to unlock the first badge flow.',
                      )
                    else
                      Column(
                        children: [
                          for (final assessment in studentAssessments.where((assessment) => assessment.completedAt != null))
                            _AssessmentCard(assessment: assessment),
                        ],
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Content pipeline',
          subtitle: 'Source-linked module docs and sample packs ready for import.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(label: '${contentSources.length} source files'),
                  _MiniBadge(
                    label:
                        '${contentSources.where((source) => source.exists).length} available locally',
                  ),
                  _MiniBadge(
                    label:
                        '${contentSources.where((source) => source.kind == 'Sample data').length} sample packs',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (contentSources.isEmpty)
                const _EmptyInline(
                  title: 'No content sources found',
                  subtitle: 'The module will fall back to embedded seeds when needed.',
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final source in contentSources.take(6))
                      _ContentSourceCard(source: source),
                  ],
                ),
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
                _SearchSummaryCard(searchHits: searchHits),
                const SizedBox(height: 12),
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
    required this.selectedStudent,
    required this.roleView,
    required this.onAudienceChanged,
    required this.onOpenLessonDetails,
    required this.onSaveLessonProgress,
  });

  final EducationHubSnapshot snapshot;
  final List<Lesson> filteredLessons;
  final EducationAudience selectedAudience;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
  final ValueChanged<EducationAudience> onAudienceChanged;
  final ValueChanged<Lesson> onOpenLessonDetails;
  final ValueChanged<Lesson> onSaveLessonProgress;

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
              _InfoTile(
                label: 'Active role view',
                value: roleView.label,
                detail: roleView.summary,
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
                    for (final lesson in filteredLessons)
                      _LessonCard(
                        lesson: lesson,
                        onOpenLessonDetails: onOpenLessonDetails,
                        onSaveProgress: onSaveLessonProgress,
                        saveButtonLabel: 'Save for ${selectedStudent.name}',
                      ),
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
  const _ProjectsTab({
    required this.snapshot,
    required this.projects,
    required this.selectedStudent,
    required this.roleView,
    required this.onOpenProjectWorkspace,
    required this.onSaveProjectProgress,
  });

  final EducationHubSnapshot snapshot;
  final List<PracticalProject> projects;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
  final ValueChanged<PracticalProject> onOpenProjectWorkspace;
  final ValueChanged<PracticalProject> onSaveProjectProgress;

  @override
  Widget build(BuildContext context) {
    final studentProgress = snapshot.progressForStudent(selectedStudent.id);
    final projectProgress = <String, ProgressRecord>{
      for (final record in studentProgress)
        if (record.entityType == 'project') record.entityId: record,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Practical Projects',
          subtitle: 'Small project workspaces with materials, steps, and evidence.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoTile(
                label: 'Active learner',
                value: selectedStudent.name,
                detail: '${selectedStudent.role} - ${selectedStudent.stage}',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Role view',
                value: roleView.label,
                detail: roleView.summary,
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Project evidence',
                value: '${projectProgress.length} logged checkpoint(s)',
                detail: 'Project progress records stay local and visible.',
              ),
              const SizedBox(height: 12),
              if (projects.isEmpty)
                const _EmptyInline(
                  title: 'No projects match the current view',
                  subtitle: 'Try adjusting the search or audience filters.',
                )
              else
                Column(
                  children: [
                    for (final project in projects)
                      Column(
                        children: [
                          _ProjectCard(project: project),
                          const SizedBox(height: 8),
                          _ProjectWorkspaceSummary(
                            project: project,
                            evidenceRecord: projectProgress[project.id],
                            onOpenWorkspace: () => onOpenProjectWorkspace(project),
                            onSaveCheckpoint: () => onSaveProjectProgress(project),
                          ),
                        ],
                      ),
                  ],
                ),
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
    required this.roleView,
    required this.progressService,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
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
                detail: '${selectedStudent.role} - ${selectedStudent.stage}',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Role view',
                value: roleView.label,
                detail: roleView.summary,
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
                _ProgressTimeline(records: studentProgress),
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
    required this.selectedStudent,
    required this.selectedPathway,
    required this.roleView,
    required this.onPromptChanged,
    required this.onUseSuggestion,
  });

  final EducationHubSnapshot snapshot;
  final TutorService tutorService;
  final String? prompt;
  final StudentProfile selectedStudent;
  final LearningPathway selectedPathway;
  final EducationRoleView roleView;
  final ValueChanged<String> onPromptChanged;
  final ValueChanged<String> onUseSuggestion;

  @override
  Widget build(BuildContext context) {
    final progressLabel = snapshot.progressLabelForStudent(selectedStudent.id);
    final response = tutorService.respond(
      prompt ?? '',
      learnerName: selectedStudent.name,
      pathwayTitle: selectedPathway.title,
      roleLabel: roleView.label,
      completionLabel: progressLabel,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'AI Tutor',
          subtitle: 'Suggestion-only tutor with safety guardrails.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Learner',
                    value: selectedStudent.name,
                    detail: selectedStudent.stage,
                  ),
                  _InfoTile(
                    label: 'Pathway',
                    value: selectedPathway.title,
                    detail: selectedPathway.domain,
                  ),
                  _InfoTile(
                    label: 'Role view',
                    value: roleView.label,
                    detail: roleView.summary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: onPromptChanged,
                decoration: const InputDecoration(
                  labelText: 'Ask a question',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Explain the next step'),
                    onPressed: () => onUseSuggestion('Explain the next step'),
                  ),
                  ActionChip(
                    label: Text('Plan ${selectedPathway.title}'),
                    onPressed: () => onUseSuggestion('Plan ${selectedPathway.title}'),
                  ),
                  ActionChip(
                    label: Text('Help ${selectedStudent.name}'),
                    onPressed: () => onUseSuggestion('Help ${selectedStudent.name}'),
                  ),
                  ActionChip(
                    label: const Text('Make it safer'),
                    onPressed: () => onUseSuggestion('Make it safer'),
                  ),
                ],
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
    required this.roleView,
    required this.onSelectStudent,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
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
                label: 'Role view',
                value: roleView.label,
                detail: roleView.summary,
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
    final completedAssessments = snapshot.completedAssessmentsForStudent(
      selectedStudent.id,
    );
    final readiness = snapshot.badgeReadinessForStudent(selectedStudent.id);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Certificates & Badges',
          subtitle: 'Placeholder badge system ready for later export flows.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Issued badges',
                    value: '${selectedStudent.badgeIds.length}',
                    detail: 'Local badge ids on the learner profile',
                  ),
                  _InfoTile(
                    label: 'Awarded certificates',
                    value: '${studentCertificates.length}',
                    detail: 'Ready for future export flows',
                  ),
                  _InfoTile(
                    label: 'Assessment readiness',
                    value: '${(readiness * 100).round()}%',
                    detail: 'Based on progress and completed checks',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: readiness),
              const SizedBox(height: 8),
              Text(
                '${completedAssessments.length} assessment(s) complete for ${selectedStudent.name}',
              ),
              const SizedBox(height: 12),
              if (studentCertificates.isEmpty)
                const _EmptyInline(
                  title: 'No badges issued yet',
                  subtitle: 'Badges will appear when assessments are signed off.',
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final certificate in studentCertificates)
                      _CertificateCard(certificate: certificate),
                  ],
                ),
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
    required this.contentSources,
    required this.roleView,
    required this.onOpenKnowledgeEngine,
    required this.onOpenGaiaPlaceholder,
    required this.onOpenMore,
    required this.onExportRoute,
  });

  final EducationHubSnapshot snapshot;
  final List<ContentSourceEntry> contentSources;
  final EducationRoleView roleView;
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
              _InfoTile(
                label: 'Content pipeline',
                value: '${contentSources.length} indexed files',
                detail: 'Markdown docs and sample data are visible as source-linked content.',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Role view',
                value: roleView.label,
                detail: roleView.summary,
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
              if (contentSources.isNotEmpty) ...[
                Text('Latest content sources', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final source in contentSources.take(5)) ...[
                  _ContentSourceCard(source: source),
                  const SizedBox(height: 10),
                ],
              ],
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
  const _LessonCard({
    required this.lesson,
    this.onOpenLessonDetails,
    this.onSaveProgress,
    this.saveButtonLabel = 'Save progress',
  });

  final Lesson lesson;
  final ValueChanged<Lesson>? onOpenLessonDetails;
  final ValueChanged<Lesson>? onSaveProgress;
  final String saveButtonLabel;

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
                if (lesson.sourceKind.isNotEmpty)
                  _MiniBadge(label: lesson.sourceKind),
                for (final tag in lesson.tags.take(3)) _MiniBadge(label: tag),
              ],
            ),
            if (lesson.sourcePath.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Source: ${lesson.sourceTitle.isNotEmpty ? lesson.sourceTitle : path.basename(lesson.sourcePath)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onSaveProgress != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: onOpenLessonDetails == null
                        ? null
                        : () => onOpenLessonDetails!(lesson),
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Open lesson'),
                  ),
                  TextButton.icon(
                    onPressed: onSaveProgress == null
                        ? null
                        : () => onSaveProgress!(lesson),
                    icon: const Icon(Icons.checklist_outlined),
                    label: Text(saveButtonLabel),
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
            Text('Steps: ${project.steps.join(' - ')}'),
          ],
        ),
      ),
    );
  }
}

class _ProjectWorkspaceSummary extends StatelessWidget {
  const _ProjectWorkspaceSummary({
    required this.project,
    required this.evidenceRecord,
    required this.onOpenWorkspace,
    required this.onSaveCheckpoint,
  });

  final PracticalProject project;
  final ProgressRecord? evidenceRecord;
  final VoidCallback onOpenWorkspace;
  final VoidCallback onSaveCheckpoint;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evidence workspace',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              evidenceRecord == null
                  ? 'No checkpoint logged for ${project.title} yet.'
                  : 'Latest checkpoint: ${evidenceRecord!.progressPercent}% complete and ${evidenceRecord!.status}.',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(label: '${project.resourceIds.length} linked source(s)'),
                _MiniBadge(label: project.domain),
                if (evidenceRecord != null) _MiniBadge(label: evidenceRecord!.status),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onOpenWorkspace,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Open workspace'),
                ),
                OutlinedButton.icon(
                  onPressed: onSaveCheckpoint,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Save checkpoint'),
                ),
              ],
            ),
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
                    '${record.entityType.toUpperCase()} - ${record.entityId}',
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

class _ProgressTimeline extends StatelessWidget {
  const _ProgressTimeline({required this.records});

  final List<ProgressRecord> records;

  @override
  Widget build(BuildContext context) {
    final sorted = records.toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Learning timeline', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final record in sorted) ...[
          _ProgressRecordCard(record: record),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _LessonDetailSheet extends StatelessWidget {
  const _LessonDetailSheet({
    required this.lesson,
    required this.pathway,
    required this.resources,
    required this.onSaveProgress,
  });

  final Lesson lesson;
  final LearningPathway pathway;
  final List<ResourceItem> resources;
  final VoidCallback onSaveProgress;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.88;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(lesson.summary),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(label: pathway.title),
                  _MiniBadge(label: lesson.difficulty),
                  _MiniBadge(label: '${lesson.estimatedMinutes} min'),
                  if (lesson.sourceKind.isNotEmpty) _MiniBadge(label: lesson.sourceKind),
                ],
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Learning objective',
                value: lesson.objective,
                detail: 'Pathway: ${pathway.title}',
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Lesson steps',
                subtitle: 'Work through these one at a time.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final step in lesson.steps)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('- $step'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Source-linked resources',
                subtitle: 'Open these later as the module matures.',
                child: resources.isEmpty
                    ? const _EmptyInline(
                        title: 'No linked resources',
                        subtitle: 'This lesson will gain source links as content packs grow.',
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final resource in resources)
                            _MiniBadge(label: resource.title),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Reflection prompt',
                subtitle: 'A gentle note to capture after the lesson.',
                child: Text(lesson.reflectionPrompt),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: onSaveProgress,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark complete'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectWorkspaceSheet extends StatelessWidget {
  const _ProjectWorkspaceSheet({
    required this.project,
    required this.selectedStudent,
    required this.roleView,
    required this.resources,
    required this.evidenceRecords,
    required this.onSaveCheckpoint,
  });

  final PracticalProject project;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
  final List<ResourceItem> resources;
  final List<ProgressRecord> evidenceRecords;
  final VoidCallback onSaveCheckpoint;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(project.summary),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(label: project.domain),
                  _MiniBadge(label: roleView.label),
                  _MiniBadge(label: selectedStudent.name),
                  _MiniBadge(label: '${project.estimatedHours} h'),
                ],
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Project workspace',
                value: 'Evidence-led and local',
                detail: 'Use this panel to keep the project notes, checkpoints, and links calm.',
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Project steps',
                subtitle: 'Work through one small action at a time.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final step in project.steps)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('- $step'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Linked resources',
                subtitle: 'Source-linked notes and templates for this project.',
                child: resources.isEmpty
                    ? const _EmptyInline(
                        title: 'No linked resources yet',
                        subtitle: 'Add project resources as the module grows.',
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final resource in resources)
                            _MiniBadge(label: resource.title),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Evidence log',
                subtitle: 'Local checkpoints that show progress on the project.',
                child: evidenceRecords.isEmpty
                    ? const _EmptyInline(
                        title: 'No checkpoint history yet',
                        subtitle: 'Save a checkpoint to create the first local evidence entry.',
                      )
                    : Column(
                        children: [
                          for (final record in evidenceRecords)
                            _ProgressRecordCard(record: record),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: onSaveCheckpoint,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Save checkpoint'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
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
              'Score: ${assessment.score}/${assessment.maxScore} - ${assessment.kind}',
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

class _SearchSummaryCard extends StatelessWidget {
  const _SearchSummaryCard({required this.searchHits});

  final List<EducationSearchHit> searchHits;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, int>{};
    for (final hit in searchHits) {
      grouped[hit.kind] = (grouped[hit.kind] ?? 0) + 1;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${searchHits.length} local match${searchHits.length == 1 ? '' : 'es'} found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in grouped.entries)
                _MiniBadge(label: '${entry.key}: ${entry.value}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContentSourceCard extends StatelessWidget {
  const _ContentSourceCard({required this.source});

  final ContentSourceEntry source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      source.title,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  _MiniBadge(label: source.exists ? 'Local' : 'Fallback'),
                ],
              ),
              const SizedBox(height: 4),
              Text(source.description),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(label: source.category),
                  _MiniBadge(label: source.kind),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                source.path,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
          const Text('-  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

