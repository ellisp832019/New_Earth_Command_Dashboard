import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/local_pdf_screen.dart';
import '../../../core/theme/app_colours.dart';
import '../application/education_content_pack_service.dart';
import '../application/education_services.dart';
import '../data/education_repository.dart';
import '../domain/education_models.dart';

enum EducationRoleView { student, mentor, parentGuardian, admin }

enum EducationAssessmentFilter { all, completed, pending }

enum EducationReportWindow { all, recent, today }

extension EducationAssessmentFilterLabel on EducationAssessmentFilter {
  String get label {
    return switch (this) {
      EducationAssessmentFilter.all => 'All',
      EducationAssessmentFilter.completed => 'Completed',
      EducationAssessmentFilter.pending => 'Pending',
    };
  }
}

extension EducationReportWindowLabel on EducationReportWindow {
  String get label {
    return switch (this) {
      EducationReportWindow.all => 'All time',
      EducationReportWindow.recent => 'Recent',
      EducationReportWindow.today => 'Today',
    };
  }
}

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

class _ReflectionDraft {
  const _ReflectionDraft({
    required this.title,
    required this.body,
    required this.mood,
  });

  final String title;
  final String body;
  final String mood;
}

class _ReflectionTemplateSpec {
  const _ReflectionTemplateSpec({
    required this.label,
    required this.title,
    required this.body,
    required this.mood,
  });

  final String label;
  final String title;
  final String body;
  final String mood;
}

class _MentorReviewTemplateSpec {
  const _MentorReviewTemplateSpec({
    required this.label,
    required this.reviewer,
    required this.status,
    required this.handoffStatus,
    required this.notes,
  });

  final String label;
  final String reviewer;
  final String status;
  final String handoffStatus;
  final String notes;
}

const _contentPackService = EducationContentPackService();

class EducationLearningHubScreen extends StatefulWidget {
  const EducationLearningHubScreen({super.key, this.repository});

  final EducationRepository? repository;

  @override
  State<EducationLearningHubScreen> createState() =>
      _EducationLearningHubScreenState();
}

class _EducationLearningHubScreenState extends State<EducationLearningHubScreen>
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
    'Reports',
    'Community / Classroom Mode',
    'Content Builder',
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
  EducationAssessmentFilter _assessmentFilter = EducationAssessmentFilter.all;
  String? _selectedStudentId;
  String? _selectedPathwayId;
  String? _tutorPrompt;
  String? _reportsFocusStudentId;
  EducationReportWindow _reportsWindow = EducationReportWindow.recent;
  String? _latestMentorReportPath;
  String? _latestCertificateDraftPath;
  String? _latestContentPackDraftPath;
  String? _latestContentPackDraftPdfPath;
  String? _latestContentPackDraftManifestPath;

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
      (value) =>
          value.studentId == record.studentId &&
          value.entityId == record.entityId,
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
      SnackBar(
        content: Text('${lesson.title} saved as complete for ${student.name}.'),
      ),
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
      (value) =>
          value.studentId == record.studentId &&
          value.entityId == record.entityId,
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
      SnackBar(
        content: Text(
          '${project.title} evidence saved locally for ${student.name}.',
        ),
      ),
    );
  }

  Future<void> _createReflectionForCurrentStudent({
    required StudentProfile selectedStudent,
    _ReflectionTemplateSpec? template,
  }) async {
    final snapshot = _snapshotOrThrow;
    final availableLessons = snapshot.lessons
        .where((lesson) => lesson.pathwayId == selectedStudent.activePathwayId)
        .toList(growable: false);
    final availableProjects = snapshot.projects.toList(growable: false);
    final titleController = TextEditingController(
      text: template?.title ?? '${selectedStudent.name} reflection',
    );
    final bodyController = TextEditingController(
      text:
          template?.body ??
          'What felt steady or useful in the last learning step?',
    );
    String mood = template?.mood ?? 'Reflective';
    String linkedLessonId = '';
    String linkedProjectId = '';

    final draft = await showDialog<_ReflectionDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add reflection'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Save a quiet note for ${selectedStudent.name}.'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'What is this reflection about?',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: mood,
                      decoration: const InputDecoration(labelText: 'Mood'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Reflective',
                          child: Text('Reflective'),
                        ),
                        DropdownMenuItem(
                          value: 'Focused',
                          child: Text('Focused'),
                        ),
                        DropdownMenuItem(
                          value: 'Encouraged',
                          child: Text('Encouraged'),
                        ),
                        DropdownMenuItem(
                          value: 'Unsure',
                          child: Text('Unsure'),
                        ),
                        DropdownMenuItem(value: 'Calm', child: Text('Calm')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          mood = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: linkedLessonId,
                      decoration: const InputDecoration(
                        labelText: 'Linked lesson',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('No linked lesson'),
                        ),
                        for (final lesson in availableLessons)
                          DropdownMenuItem(
                            value: lesson.id,
                            child: Text(lesson.title),
                          ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          linkedLessonId = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: linkedProjectId,
                      decoration: const InputDecoration(
                        labelText: 'Linked project',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('No linked project'),
                        ),
                        for (final project in availableProjects)
                          DropdownMenuItem(
                            value: project.id,
                            child: Text(project.title),
                          ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          linkedProjectId = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Reflection',
                        alignLabelWithHint: true,
                        hintText:
                            'What happened, what felt useful, and what next?',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final body = bodyController.text.trim();
                    if (title.isEmpty || body.isEmpty) {
                      return;
                    }
                    Navigator.of(dialogContext).pop(
                      _ReflectionDraft(title: title, body: body, mood: mood),
                    );
                  },
                  child: const Text('Save reflection'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    bodyController.dispose();
    if (draft == null) {
      return;
    }

    try {
      final reflection = await _repository.saveReflectionEntry(
        studentId: selectedStudent.id,
        title: draft.title,
        body: draft.body,
        mood: draft.mood,
        linkedLessonId: linkedLessonId,
        linkedProjectId: linkedProjectId,
      );
      if (!mounted) {
        return;
      }
      final updatedReflections = snapshot.reflections.toList(growable: true)
        ..add(reflection);
      setState(() {
        _snapshot = snapshot.copyWith(reflections: updatedReflections);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reflection saved locally for ${selectedStudent.name}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reflection save failed: $error')));
    }
  }

  Future<void> _exportEducationSnapshot() async {
    try {
      final exported = await _repository.exportSnapshotBundle();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Education snapshot exported to ${exported.path}.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  Future<void> _importEducationSnapshot() async {
    try {
      final imported = await _repository.importSnapshotBundle();
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = imported;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Education snapshot imported locally.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    }
  }

  Future<void> _exportMentorReportForCurrentStudent() async {
    final snapshot = _snapshotOrThrow;
    final student = snapshot.students.firstWhere(
      (profile) => profile.id == _selectedStudentId,
      orElse: () => snapshot.students.first,
    );
    try {
      final report = await _repository.exportMentorReport(
        studentId: student.id,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mentor report exported to ${report.path}')),
      );
      setState(() {
        _latestMentorReportPath = report.path;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mentor export failed: $error')));
    }
  }

  Future<void> _createMentorReviewForCurrentStudent({
    required StudentProfile selectedStudent,
    _MentorReviewTemplateSpec? template,
  }) async {
    final snapshot = _snapshotOrThrow;
    final reviewerController = TextEditingController(
      text:
          template?.reviewer ??
          (selectedStudent.mentorName.isNotEmpty
              ? selectedStudent.mentorName
              : 'Peter Ellis'),
    );
    final notesController = TextEditingController(
      text:
          template?.notes ??
          'Learner is ready for a calm handoff once the final review is complete.',
    );
    String status = template?.status ?? 'Ready for sign-off';
    String handoffStatus = template?.handoffStatus ?? 'Guardian handoff ready';
    final templates = const <_MentorReviewTemplateSpec>[
      _MentorReviewTemplateSpec(
        label: 'Ready to sign off',
        reviewer: 'Peter Ellis',
        status: 'Ready for sign-off',
        handoffStatus: 'Guardian handoff ready',
        notes:
            'Learner has met the agreed checks and can move to local handoff.',
      ),
      _MentorReviewTemplateSpec(
        label: 'Needs follow-up',
        reviewer: 'Peter Ellis',
        status: 'Needs follow-up',
        handoffStatus: 'Mentor review in progress',
        notes:
            'A short follow-up is needed for one or two checks before sign-off.',
      ),
      _MentorReviewTemplateSpec(
        label: 'Waiting for evidence',
        reviewer: 'Peter Ellis',
        status: 'Ready for sign-off',
        handoffStatus: 'Waiting for evidence',
        notes:
            'The learner is progressing well, but evidence still needs to be added.',
      ),
    ];

    final saved = await showDialog<MentorReviewRecord>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add mentor review'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create a local review for ${selectedStudent.name}.'),
                    const SizedBox(height: 16),
                    Text(
                      'Templates',
                      style: Theme.of(dialogContext).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final template in templates)
                          ActionChip(
                            label: Text(template.label),
                            onPressed: () {
                              setDialogState(() {
                                reviewerController.text = template.reviewer;
                                status = template.status;
                                handoffStatus = template.handoffStatus;
                                notesController.text = template.notes;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reviewerController,
                      decoration: const InputDecoration(labelText: 'Reviewer'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Ready for sign-off',
                          child: Text('Ready for sign-off'),
                        ),
                        DropdownMenuItem(
                          value: 'Needs follow-up',
                          child: Text('Needs follow-up'),
                        ),
                        DropdownMenuItem(
                          value: 'Signed off locally',
                          child: Text('Signed off locally'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          status = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: handoffStatus,
                      decoration: const InputDecoration(
                        labelText: 'Handoff status',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Guardian handoff ready',
                          child: Text('Guardian handoff ready'),
                        ),
                        DropdownMenuItem(
                          value: 'Mentor review in progress',
                          child: Text('Mentor review in progress'),
                        ),
                        DropdownMenuItem(
                          value: 'Waiting for evidence',
                          child: Text('Waiting for evidence'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          handoffStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Review notes',
                        alignLabelWithHint: true,
                        hintText: 'What should the next supporter know?',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final reviewer = reviewerController.text.trim();
                    final notes = notesController.text.trim();
                    if (reviewer.isEmpty || notes.isEmpty) {
                      return;
                    }
                    Navigator.of(dialogContext).pop(
                      MentorReviewRecord(
                        id: '',
                        studentId: selectedStudent.id,
                        reviewer: reviewer,
                        status: status,
                        handoffStatus: handoffStatus,
                        notes: notes,
                        reviewedAt: DateTime.now().toUtc(),
                      ),
                    );
                  },
                  child: const Text('Save review'),
                ),
              ],
            );
          },
        );
      },
    );

    reviewerController.dispose();
    notesController.dispose();
    if (saved == null) {
      return;
    }

    try {
      final review = await _repository.saveMentorReview(
        studentId: selectedStudent.id,
        reviewer: saved.reviewer,
        status: saved.status,
        handoffStatus: saved.handoffStatus,
        notes: saved.notes,
      );
      if (!mounted) {
        return;
      }
      final updatedReviews = snapshot.mentorReviews.toList(growable: true)
        ..add(review);
      setState(() {
        _snapshot = snapshot.copyWith(mentorReviews: updatedReviews);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mentor review saved locally for ${selectedStudent.name}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Mentor review failed: $error')));
    }
  }

  Future<void> _issueDraftCertificateForCurrentStudent() async {
    final snapshot = _snapshotOrThrow;
    final student = snapshot.students.firstWhere(
      (profile) => profile.id == _selectedStudentId,
      orElse: () => snapshot.students.first,
    );
    try {
      final certificate = await _repository.issueCertificateFromAssessments(
        studentId: student.id,
      );
      if (!mounted) {
        return;
      }
      final updatedCertificates = snapshot.certificates.toList(growable: true)
        ..add(certificate);
      final updatedStudents = snapshot.students
          .map((profile) {
            if (profile.id != student.id) {
              return profile;
            }
            final badgeIds = profile.badgeIds.toList(growable: true);
            if (!badgeIds.contains(certificate.id)) {
              badgeIds.add(certificate.id);
            }
            return profile.copyWith(badgeIds: badgeIds);
          })
          .toList(growable: false);
      setState(() {
        _snapshot = snapshot.copyWith(
          certificates: updatedCertificates,
          students: updatedStudents,
        );
        _latestCertificateDraftPath = _repositoryDirectoryForCertificate(
          student.id,
          certificate.id,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Draft certificate issued for ${student.name}: ${certificate.badgeLevel}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Certificate issue failed: $error')),
      );
    }
  }

  Future<void> _openLatestCertificateDraftPdf() async {
    final draftPath = _latestCertificateDraftPath;
    if (draftPath == null || draftPath.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No certificate PDF draft has been created yet.'),
        ),
      );
      return;
    }

    await openLocalPdfDocument(
      context,
      title: 'Certificate draft',
      pdfPath: draftPath,
    );
  }

  Future<void> _openLatestContentPackDraftPdf() async {
    final draftPath = _latestContentPackDraftPdfPath;
    if (draftPath == null || draftPath.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No content pack PDF has been exported yet.'),
        ),
      );
      return;
    }

    await openLocalPdfDocument(
      context,
      title: 'Content pack draft',
      pdfPath: draftPath,
    );
  }

  String _repositoryDirectoryForCertificate(
    String studentId,
    String certificateId,
  ) {
    return path.join(
      _snapshotOrThrow.settings.moduleRootPath,
      '10_LOCAL_FIRST_DATA',
      'exports',
      'certificates',
      '${studentId}_$certificateId.pdf',
    );
  }

  Future<void> _saveContentPackDraft(ContentPackDraft draft) async {
    final snapshot = _snapshotOrThrow;
    final normalizedDraft = _contentPackService.normalize(draft);
    final updatedSnapshot = snapshot.copyWith(
      contentPackDraft: normalizedDraft.copyWith(
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    try {
      await _repository.saveSnapshot(updatedSnapshot);
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = updatedSnapshot;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content pack draft saved locally.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Content pack save failed: $error')),
      );
    }
  }

  Future<void> _exportContentPackDraft() async {
    try {
      final markdownFile = await _repository.exportContentPackDraft();
      if (!mounted) {
        return;
      }
      setState(() {
        _latestContentPackDraftPath = markdownFile.path;
        _latestContentPackDraftPdfPath =
            '${path.withoutExtension(markdownFile.path)}.pdf';
        _latestContentPackDraftManifestPath =
            '${path.withoutExtension(markdownFile.path)}.json';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content pack draft exported locally.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Content pack export failed: $error')),
      );
    }
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
        onSaveCheckpoint: () =>
            _saveProjectProgress(student: selectedStudent, project: project),
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
    return snapshot.pathways
        .where((pathway) {
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
        })
        .toList(growable: false);
  }

  void _resetLearningFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _audienceFilter = EducationAudience.all;
      _assessmentFilter = EducationAssessmentFilter.all;
    });
  }

  List<Lesson> _filteredLessons(EducationHubSnapshot snapshot) {
    final query = _searchQuery.trim().toLowerCase();
    return snapshot.lessons
        .where((lesson) {
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
        })
        .toList(growable: false);
  }

  List<PracticalProject> _filteredProjects(EducationHubSnapshot snapshot) {
    final query = _searchQuery.trim().toLowerCase();
    return snapshot.projects
        .where((project) {
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
        })
        .toList(growable: false);
  }

  void _copyText(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied locally.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
    final reportFocusStudent = snapshot.students.firstWhere(
      (student) => student.id == _reportsFocusStudentId,
      orElse: () => currentStudent,
    );
    final selectedPathway =
        pathwayService.pathwayById(_selectedPathwayId ?? '') ??
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
            onPressed: () => context.push(
              RouteNames.modulePackage('26_OMEGA_KNOWLEDGE_ENGINE'),
            ),
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
              tabs: [for (final label in _tabLabels) Tab(text: label)],
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
                    contentPackDraft: snapshot.contentPackDraft,
                    onSaveLessonProgress: (lesson) => _saveLessonProgress(
                      student: currentStudent,
                      lesson: lesson,
                    ),
                    onOpenLessonDetails: _openLessonDetails,
                    onOpenPathways: () => _tabController.animateTo(1),
                    onOpenLessons: () => _tabController.animateTo(2),
                    onOpenProjects: () => _tabController.animateTo(3),
                    onOpenTutor: () => _tabController.animateTo(5),
                    onOpenReports: () => _tabController.animateTo(10),
                    onOpenCommunity: () => _tabController.animateTo(11),
                  ),
                  _PathwaysTab(
                    snapshot: snapshot,
                    filteredPathways: _filteredPathways(snapshot),
                    selectedPathwayId: _selectedPathwayId,
                    selectedStudent: currentStudent,
                    searchQuery: _searchQuery,
                    activeAudience: _audienceFilter,
                    onResetFilters: _resetLearningFilters,
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
                    searchQuery: _searchQuery,
                    onResetFilters: _resetLearningFilters,
                    onAudienceChanged: (value) {
                      setState(() {
                        _audienceFilter = value;
                      });
                    },
                    onOpenLessonDetails: _openLessonDetails,
                    onSaveLessonProgress: (lesson) => _saveLessonProgress(
                      student: currentStudent,
                      lesson: lesson,
                    ),
                  ),
                  _ProjectsTab(
                    snapshot: snapshot,
                    projects: _filteredProjects(snapshot),
                    selectedStudent: currentStudent,
                    roleView: _roleView,
                    onOpenProjectWorkspace: _openProjectWorkspace,
                    onSaveProjectProgress: (project) => _saveProjectProgress(
                      student: currentStudent,
                      project: project,
                    ),
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
                    onExportReport: _exportMentorReportForCurrentStudent,
                    onAddReview: ({_MentorReviewTemplateSpec? template}) =>
                        _createMentorReviewForCurrentStudent(
                          selectedStudent: currentStudent,
                          template: template,
                        ),
                  ),
                  _AssessmentsTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    assessments: assessmentService.assessmentsForAudience(
                      _audienceFilter,
                    ),
                    selectedAudience: _audienceFilter,
                    selectedFilter: _assessmentFilter,
                    onAudienceChanged: (value) {
                      setState(() {
                        _audienceFilter = value;
                      });
                    },
                    onFilterChanged: (value) {
                      setState(() {
                        _assessmentFilter = value;
                      });
                    },
                  ),
                  _ReflectionTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    reflections: reflectionService.reflectionsForAudience(
                      _audienceFilter,
                    ),
                    onAddReflection: (_ReflectionTemplateSpec template) {
                      return _createReflectionForCurrentStudent(
                        selectedStudent: currentStudent,
                        template: template,
                      );
                    },
                  ),
                  _CertificatesTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    certificates: certificateService.certificatesForAudience(
                      _audienceFilter,
                    ),
                    onIssueDraftCertificate:
                        _issueDraftCertificateForCurrentStudent,
                    onOpenDraftCertificatePdf: _openLatestCertificateDraftPdf,
                  ),
                  _ReportsTab(
                    snapshot: snapshot,
                    selectedStudent: reportFocusStudent,
                    selectedPathway: selectedPathway,
                    roleView: _roleView,
                    reportWindow: _reportsWindow,
                    latestMentorReportPath: _latestMentorReportPath,
                    latestCertificateDraftPath: _latestCertificateDraftPath,
                    latestContentPackDraftPath: _latestContentPackDraftPath,
                    latestContentPackDraftPdfPath:
                        _latestContentPackDraftPdfPath,
                    onExportReport: _exportMentorReportForCurrentStudent,
                    onSelectStudent: (studentId) {
                      setState(() {
                        _reportsFocusStudentId = studentId;
                      });
                    },
                    onWindowChanged: (window) {
                      setState(() {
                        _reportsWindow = window;
                      });
                    },
                    onIssueDraftCertificate:
                        _issueDraftCertificateForCurrentStudent,
                    onExportContentPack: _exportContentPackDraft,
                    onOpenCertificatePdf: _openLatestCertificateDraftPdf,
                    onOpenContentPackPdf: _openLatestContentPackDraftPdf,
                  ),
                  _CommunityTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    roleView: _roleView,
                    onOpenMentorWorkspace: () => _tabController.animateTo(6),
                  ),
                  _ContentBuilderTab(
                    snapshot: snapshot,
                    selectedStudent: currentStudent,
                    roleView: _roleView,
                    onExportBundle: _exportEducationSnapshot,
                    onImportBundle: _importEducationSnapshot,
                    onSaveDraft: _saveContentPackDraft,
                    onExportDraft: _exportContentPackDraft,
                  ),
                  _SettingsTab(
                    snapshot: snapshot,
                    contentSources: snapshot.contentSources,
                    roleView: _roleView,
                    latestMentorReportPath: _latestMentorReportPath,
                    latestCertificateDraftPath: _latestCertificateDraftPath,
                    latestContentPackDraftPath: _latestContentPackDraftPath,
                    latestContentPackDraftPdfPath:
                        _latestContentPackDraftPdfPath,
                    latestContentPackDraftManifestPath:
                        _latestContentPackDraftManifestPath,
                    onOpenLatestContentPackDraftPdf:
                        _openLatestContentPackDraftPdf,
                    onOpenKnowledgeEngine: () => context.push(
                      RouteNames.modulePackage('26_OMEGA_KNOWLEDGE_ENGINE'),
                    ),
                    onOpenGaiaPlaceholder: () =>
                        context.push(RouteNames.voiceAssistant),
                    onOpenMore: () => context.go(RouteNames.more),
                    onExportRoute: () => _copyText(
                      snapshot.settings.gaiaAssistantRoute,
                      'GAIA route placeholder',
                    ),
                    onExportContentPack: _exportEducationSnapshot,
                    onImportContentPack: _importEducationSnapshot,
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
                    labelText:
                        'Search pathways, lessons, projects, and resources',
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
    required this.contentPackDraft,
    required this.onSaveLessonProgress,
    required this.onOpenLessonDetails,
    required this.onOpenPathways,
    required this.onOpenLessons,
    required this.onOpenProjects,
    required this.onOpenTutor,
    required this.onOpenReports,
    required this.onOpenCommunity,
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
  final ContentPackDraft contentPackDraft;
  final ValueChanged<Lesson> onSaveLessonProgress;
  final ValueChanged<Lesson> onOpenLessonDetails;
  final VoidCallback onOpenPathways;
  final VoidCallback onOpenLessons;
  final VoidCallback onOpenProjects;
  final VoidCallback onOpenTutor;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenCommunity;

  @override
  Widget build(BuildContext context) {
    final progress = progressService.completionForStudent(selectedStudent.id);
    final completionLabel = '${(progress * 100).round()}% complete';
    final reflections = reflectionService.reflectionsForAudience(
      EducationAudience.all,
    );
    final mentorNotes = snapshot.notesForStudent(selectedStudent.id);
    final studentProgress = snapshot.progressForStudent(selectedStudent.id);
    final lessonTitles = {
      for (final lesson in snapshot.lessons) lesson.id: lesson.title,
    };
    final projectTitles = {
      for (final project in snapshot.projects) project.id: project.title,
    };
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
    final studentAssessments = snapshot.assessmentsForStudent(
      selectedStudent.id,
    );
    final badgeReadiness = snapshot.badgeReadinessForStudent(
      selectedStudent.id,
    );

    return ListView(
      key: const Key('educationLessonLibraryScrollView'),
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
                detail:
                    '${snapshot.earnedBadgeCountForStudent(selectedStudent.id)} earned badge(s)',
              ),
              _InfoTile(
                label: 'Content pack',
                value: contentPackDraft.title,
                detail: contentPackDraft.validationReady
                    ? 'Draft saved at v${contentPackDraft.version}'
                    : 'Draft needs a little more detail',
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
              subtitle:
                  'Use project workspaces to turn learning into evidence.',
              buttonText: 'Open projects',
              onPressed: onOpenProjects,
            ),
            _ActionCard(
              title: 'AI Tutor',
              subtitle:
                  'Suggestion-only tutor with safety-aware placeholder flow.',
              buttonText: 'Open tutor',
              onPressed: onOpenTutor,
            ),
            _ActionCard(
              title: 'Reports',
              subtitle: 'Review local mentor reports, drafts, and exports.',
              buttonText: 'Open reports',
              onPressed: onOpenReports,
            ),
            _ActionCard(
              title: 'Community / Classroom',
              subtitle: 'See the learner group and classroom support lens.',
              buttonText: 'Open classroom',
              onPressed: onOpenCommunity,
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
          subtitle:
              'What the tutor and the local progress snapshot can see right now.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoTile(
                label: 'Assessments complete',
                value:
                    '${studentAssessments.where((assessment) => assessment.completedAt != null).length}/${studentAssessments.length}',
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
                      _ReflectionCard(
                        reflection: reflection,
                        linkedLessonTitle:
                            lessonTitles[reflection.linkedLessonId],
                        linkedProjectTitle:
                            projectTitles[reflection.linkedProjectId],
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Certificates and badges',
          subtitle:
              'Placeholder badge system for future export and mentor sign-off.',
          child: certificates.isEmpty
              ? const _EmptyInline(
                  title: 'No certificates yet',
                  subtitle:
                      'Certificates will appear after assessment sign-off.',
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
                          value:
                              '${snapshot.earnedBadgeCountForStudent(selectedStudent.id)}',
                          detail: 'Local badge ids already issued',
                        ),
                        _InfoTile(
                          label: 'Assessments complete',
                          value:
                              '${snapshot.completedAssessmentsForStudent(selectedStudent.id).length}',
                          detail: 'Ready for review and sign-off',
                        ),
                        _InfoTile(
                          label: 'Badge readiness',
                          value:
                              '${(snapshot.badgeReadinessForStudent(selectedStudent.id) * 100).round()}%',
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
                    if (studentAssessments
                        .where((assessment) => assessment.completedAt != null)
                        .isEmpty)
                      const _EmptyInline(
                        title: 'No completed assessments yet',
                        subtitle:
                            'Finish a lesson or project checkpoint to unlock the first badge flow.',
                      )
                    else
                      Column(
                        children: [
                          for (final assessment in studentAssessments.where(
                            (assessment) => assessment.completedAt != null,
                          ))
                            _AssessmentCard(
                              assessment: assessment,
                              mentorNotes: mentorNotes,
                              progressRecords: studentProgress,
                              lessonTitles: lessonTitles,
                            ),
                        ],
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'Content pipeline',
          subtitle:
              'Source-linked module docs and sample packs ready for import.',
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
                  subtitle:
                      'The module will fall back to embedded seeds when needed.',
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
    required this.selectedStudent,
    required this.filteredPathways,
    required this.selectedPathwayId,
    required this.searchQuery,
    required this.activeAudience,
    required this.onResetFilters,
    required this.onSelectPathway,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final List<LearningPathway> filteredPathways;
  final String? selectedPathwayId;
  final String searchQuery;
  final EducationAudience activeAudience;
  final VoidCallback onResetFilters;
  final ValueChanged<String> onSelectPathway;

  @override
  Widget build(BuildContext context) {
    final studentProgress = snapshot.progressForStudent(selectedStudent.id);
    final completedLessonIds = studentProgress
        .where(
          (record) =>
              record.entityType == 'lesson' && record.progressPercent >= 100,
        )
        .map((record) => record.entityId)
        .toSet();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Learning Pathways',
          subtitle: 'Browse the supported learning routes for New Earth.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(label: '${filteredPathways.length} pathways'),
                  if (searchQuery.trim().isNotEmpty)
                    _MiniBadge(label: 'Search: ${searchQuery.trim()}'),
                  if (activeAudience != EducationAudience.all)
                    _MiniBadge(label: 'Audience: ${activeAudience.label}'),
                  TextButton.icon(
                    onPressed: onResetFilters,
                    icon: const Icon(Icons.restart_alt_outlined),
                    label: const Text('Reset filters'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              filteredPathways.isEmpty
                  ? const _EmptyInline(
                      title: 'No pathways match the filter',
                      subtitle: 'Try a broader search or switch audience view.',
                    )
                  : Column(
                      children: [
                        for (final pathway in filteredPathways)
                          (() {
                            final lessonIds = pathway.units
                                .expand((unit) => unit.lessons)
                                .toSet();
                            final completedLessons = lessonIds
                                .where(completedLessonIds.contains)
                                .length;
                            return _PathwayCard(
                              pathway: pathway,
                              selected: pathway.id == selectedPathwayId,
                              onTap: () => onSelectPathway(pathway.id),
                              selectedStudent: selectedStudent,
                              completedLessons: completedLessons,
                              totalLessons: lessonIds.length,
                              unitCount: pathway.units.length,
                            );
                          })(),
                      ],
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
    required this.searchQuery,
    required this.onResetFilters,
    required this.onAudienceChanged,
    required this.onOpenLessonDetails,
    required this.onSaveLessonProgress,
  });

  final EducationHubSnapshot snapshot;
  final List<Lesson> filteredLessons;
  final EducationAudience selectedAudience;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
  final String searchQuery;
  final VoidCallback onResetFilters;
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniBadge(label: '${filteredLessons.length} lessons'),
                  if (searchQuery.trim().isNotEmpty)
                    _MiniBadge(label: 'Search: ${searchQuery.trim()}'),
                  if (selectedAudience != EducationAudience.all)
                    _MiniBadge(label: 'Audience: ${selectedAudience.label}'),
                  TextButton.icon(
                    onPressed: onResetFilters,
                    icon: const Icon(Icons.restart_alt_outlined),
                    label: const Text('Reset filters'),
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
          subtitle:
              'Small project workspaces with materials, steps, and evidence.',
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
                            onOpenWorkspace: () =>
                                onOpenProjectWorkspace(project),
                            onSaveCheckpoint: () =>
                                onSaveProjectProgress(project),
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
    final score = snapshot.learnerProgressScoreForStudent(selectedStudent.id);
    final completedLessons = studentProgress
        .where(
          (record) =>
              record.entityType == 'lesson' && record.progressPercent >= 100,
        )
        .length;
    final completedProjects = studentProgress
        .where(
          (record) =>
              record.entityType == 'project' && record.progressPercent >= 100,
        )
        .length;
    final inProgressItems = studentProgress
        .where(
          (record) =>
              record.progressPercent > 0 && record.progressPercent < 100,
        )
        .length;
    final readiness = snapshot.badgeReadinessForStudent(selectedStudent.id);
    final nextStep = studentProgress.isEmpty
        ? 'Start with one lesson and one reflection.'
        : completedLessons < 3
        ? 'Finish one more lesson and note what felt useful.'
        : inProgressItems > 0
        ? 'Move one in-progress item toward completion.'
        : 'Review a project checkpoint and prepare the next evidence note.';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Student Progress',
          subtitle:
              'A local view of pathways, lessons, projects, and completion.',
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
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Overall progress',
                    value: '${(completion * 100).round()}%',
                    detail: 'Across local lesson and project checkpoints',
                  ),
                  _InfoTile(
                    label: 'Badge readiness',
                    value: '${(readiness * 100).round()}%',
                    detail: 'Based on completion and recent evidence',
                  ),
                  _InfoTile(
                    label: 'Learner score',
                    value: '${(score.overall * 100).round()}%',
                    detail:
                        'Blend of lessons, projects, assessments, reflections, and reviews',
                  ),
                  _InfoTile(
                    label: 'Completed items',
                    value: '${completedLessons + completedProjects}',
                    detail:
                        '$completedLessons lessons and $completedProjects projects complete',
                  ),
                  _InfoTile(
                    label: 'Active items',
                    value: '$inProgressItems',
                    detail: 'Items with visible local progress',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: completion),
              const SizedBox(height: 8),
              Text('${(completion * 100).round()}% overall learning progress'),
              const SizedBox(height: 12),
              _Panel(
                title: 'Learner score breakdown',
                subtitle:
                    'A calmer view of the evidence behind the overall progress score.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _InfoTile(
                          label: 'Lessons',
                          value: '${(score.lessonCompletion * 100).round()}%',
                          detail:
                              '${score.completedLessons} of ${score.totalLessons} complete',
                        ),
                        _InfoTile(
                          label: 'Projects',
                          value: '${(score.projectCompletion * 100).round()}%',
                          detail:
                              '${score.completedProjects} of ${score.totalProjects} complete',
                        ),
                        _InfoTile(
                          label: 'Assessments',
                          value:
                              '${(score.assessmentCompletion * 100).round()}%',
                          detail:
                              '${score.completedAssessments} of ${score.totalAssessments} complete',
                        ),
                        _InfoTile(
                          label: 'Reflections',
                          value:
                              '${(score.reflectionEngagement * 100).round()}%',
                          detail:
                              '${score.reflectionCount} reflection(s) logged',
                        ),
                        _InfoTile(
                          label: 'Mentor reviews',
                          value:
                              '${(score.mentorReviewCoverage * 100).round()}%',
                          detail: '${score.reviewCount} review(s) recorded',
                        ),
                        _InfoTile(
                          label: 'Badges',
                          value: '${(score.badgeCoverage * 100).round()}%',
                          detail:
                              '${score.certificateCount} certificate(s) issued',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: score.overall),
                    const SizedBox(height: 8),
                    Text(snapshot.progressLabelForStudent(selectedStudent.id)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Suggested next step',
                subtitle: 'Keep the next move small and easy to finish.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nextStep),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(
                          label: '${studentProgress.length} checkpoints',
                        ),
                        _MiniBadge(label: '$completedLessons lessons'),
                        _MiniBadge(label: '$completedProjects projects'),
                        _MiniBadge(
                          label: '${(readiness * 100).round()}% readiness',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (studentProgress.isEmpty)
                const _EmptyInline(
                  title: 'No progress records yet',
                  subtitle:
                      'Progress will appear as lessons and projects are completed.',
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
                    onPressed: () =>
                        onUseSuggestion('Plan ${selectedPathway.title}'),
                  ),
                  ActionChip(
                    label: Text('Help ${selectedStudent.name}'),
                    onPressed: () =>
                        onUseSuggestion('Help ${selectedStudent.name}'),
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
    required this.onExportReport,
    required this.onAddReview,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
  final ValueChanged<String> onSelectStudent;
  final VoidCallback onExportReport;
  final Future<void> Function({_MentorReviewTemplateSpec? template})
  onAddReview;

  @override
  Widget build(BuildContext context) {
    final templates = [
      const _MentorReviewTemplateSpec(
        label: 'Ready to sign off',
        reviewer: 'Peter Ellis',
        status: 'Ready for sign-off',
        handoffStatus: 'Guardian handoff ready',
        notes:
            'Learner has met the agreed checks and can move to local handoff.',
      ),
      const _MentorReviewTemplateSpec(
        label: 'Needs follow-up',
        reviewer: 'Peter Ellis',
        status: 'Needs follow-up',
        handoffStatus: 'Mentor review in progress',
        notes:
            'A short follow-up is needed for one or two checks before sign-off.',
      ),
      const _MentorReviewTemplateSpec(
        label: 'Waiting for evidence',
        reviewer: 'Peter Ellis',
        status: 'Ready for sign-off',
        handoffStatus: 'Waiting for evidence',
        notes:
            'The learner is progressing well, but evidence still needs to be added.',
      ),
    ];
    final notes = snapshot.notesForStudent(selectedStudent.id);
    final reviews = snapshot.reviewsForStudent(selectedStudent.id)
      ..sort((left, right) => right.reviewedAt.compareTo(left.reviewedAt));
    final reflections = snapshot.reflectionsForStudent(selectedStudent.id);
    final assessments = snapshot.assessmentsForStudent(selectedStudent.id);
    final completedAssessments = assessments
        .where((assessment) => assessment.completedAt != null)
        .length;
    final badgeCount = snapshot.earnedBadgeCountForStudent(selectedStudent.id);
    final progressLabel = snapshot.progressLabelForStudent(selectedStudent.id);
    final roleGuidance = switch (roleView) {
      EducationRoleView.student =>
        'Student view keeps the next lesson, project, and reflection in front of the learner.',
      EducationRoleView.mentor =>
        'Mentor view keeps the next support note, assessment, and handoff in view.',
      EducationRoleView.parentGuardian =>
        'Guardian view keeps progress, wellbeing, and simple home support calm and visible.',
      EducationRoleView.admin =>
        'Admin view keeps readiness, sign-off, and learning safety easy to review.',
    };
    final mentorSummary = StringBuffer()
      ..writeln('Learner: ${selectedStudent.name}')
      ..writeln('Role view: ${roleView.label}')
      ..writeln('Mentor: ${selectedStudent.mentorName}')
      ..writeln('Guardian: ${selectedStudent.guardianName}')
      ..writeln('Progress: $progressLabel')
      ..writeln(
        'Assessments: $completedAssessments of ${assessments.length} complete',
      )
      ..writeln('Reflections: ${reflections.length}')
      ..writeln('Mentor reviews: ${reviews.length}')
      ..writeln('Badges: $badgeCount')
      ..writeln('Latest support note count: ${notes.length}');
    final reviewStatusCounts = <String, int>{};
    final handoffStatusCounts = <String, int>{};
    for (final review in reviews) {
      reviewStatusCounts[review.status] =
          (reviewStatusCounts[review.status] ?? 0) + 1;
      handoffStatusCounts[review.handoffStatus] =
          (handoffStatusCounts[review.handoffStatus] ?? 0) + 1;
    }
    final latestReview = reviews.isEmpty ? null : reviews.first;
    final mentorNoteStarter = StringBuffer()
      ..writeln('Support note starter for ${selectedStudent.name}')
      ..writeln('1. What is already working well?')
      ..writeln('2. What is the next calm action?')
      ..writeln('3. What support should stay local and human-reviewed?');
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Mentor Workspace',
          subtitle:
              'Track learner notes, support actions, and gentle sign-off.',
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
              _Panel(
                title: 'Classroom / guardian lens',
                subtitle:
                    'A calm role-aware snapshot for the people supporting the learner.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(roleGuidance),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(
                          label: 'Mentor: ${selectedStudent.mentorName}',
                        ),
                        _MiniBadge(
                          label: 'Guardian: ${selectedStudent.guardianName}',
                        ),
                        _MiniBadge(label: 'Progress: $progressLabel'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use this view for home check-ins, classroom handoff, or quiet support planning.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Local mentor summary',
                subtitle:
                    'A calm clipboard-friendly snapshot for review or handoff.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(label: progressLabel),
                        _MiniBadge(
                          label:
                              '$completedAssessments/${assessments.length} assessments',
                        ),
                        _MiniBadge(label: '${reflections.length} reflections'),
                        _MiniBadge(label: '$badgeCount badges'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(mentorSummary.toString().trim()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: mentorSummary.toString().trim(),
                              ),
                            );
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mentor summary copied locally.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_all_outlined),
                          label: const Text('Copy summary'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onExportReport,
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Export report'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Review workflow',
                subtitle:
                    'Sign-off, notes, and handoff status stay in one calm lane.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reviews.isEmpty)
                      const _EmptyInline(
                        title: 'No review flow yet',
                        subtitle:
                            'Add the first sign-off note when the learner is ready.',
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latestReview == null
                                ? 'No recent review found.'
                                : 'Latest review by ${latestReview.reviewer}: ${latestReview.status} / ${latestReview.handoffStatus}.',
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MiniBadge(label: '${reviews.length} reviews'),
                              for (final entry in reviewStatusCounts.entries)
                                _MiniBadge(
                                  label: '${entry.key}: ${entry.value}',
                                ),
                              for (final entry in handoffStatusCounts.entries)
                                _MiniBadge(
                                  label: '${entry.key}: ${entry.value}',
                                ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    const Text(
                      'Keep each review short, specific, and clearly handoff-ready.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Mentor note flow',
                subtitle: 'A short starter for support handoffs and reviews.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mentorNoteStarter.toString().trim()),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(label: '${notes.length} notes'),
                        _MiniBadge(label: '${reflections.length} reflections'),
                        _MiniBadge(label: '$completedAssessments assessments'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Review presets',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final template in templates)
                          ActionChip(
                            label: Text(template.label),
                            onPressed: () {
                              unawaited(onAddReview(template: template));
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: mentorNoteStarter.toString().trim(),
                          ),
                        );
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Mentor note starter copied locally.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_all_outlined),
                      label: const Text('Copy note starter'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () {
                        unawaited(onAddReview());
                      },
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Add mentor review'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reviews.isEmpty
                          ? 'No mentor review has been signed off yet.'
                          : 'Latest review: ${reviews.first.status} / ${reviews.first.handoffStatus}.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Mentor review log',
                subtitle: 'Local sign-off and handoff status history.',
                child: reviews.isEmpty
                    ? const _EmptyInline(
                        title: 'No mentor reviews yet',
                        subtitle: 'Add the first handoff review when ready.',
                      )
                    : Column(
                        children: [
                          for (final review in reviews.take(4))
                            _MentorReviewCard(review: review),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              if (notes.isEmpty)
                const _EmptyInline(
                  title: 'No mentor notes yet',
                  subtitle:
                      'Mentor notes will appear as work sessions progress.',
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
    required this.selectedAudience,
    required this.selectedFilter,
    required this.onAudienceChanged,
    required this.onFilterChanged,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final List<Assessment> assessments;
  final EducationAudience selectedAudience;
  final EducationAssessmentFilter selectedFilter;
  final ValueChanged<EducationAudience> onAudienceChanged;
  final ValueChanged<EducationAssessmentFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final studentNotes = snapshot.notesForStudent(selectedStudent.id);
    final studentProgress = snapshot.progressForStudent(selectedStudent.id);
    final lessonTitles = {
      for (final lesson in snapshot.lessons) lesson.id: lesson.title,
    };
    final sortedAssessments =
        assessments
            .where((assessment) {
              return switch (selectedFilter) {
                EducationAssessmentFilter.all => true,
                EducationAssessmentFilter.completed =>
                  assessment.completedAt != null,
                EducationAssessmentFilter.pending =>
                  assessment.completedAt == null,
              };
            })
            .toList(growable: false)
          ..sort((left, right) {
            final leftCompleted = left.completedAt != null;
            final rightCompleted = right.completedAt != null;
            if (leftCompleted != rightCompleted) {
              return leftCompleted ? 1 : -1;
            }
            return left.title.compareTo(right.title);
          });
    final completedCount = sortedAssessments
        .where((assessment) => assessment.completedAt != null)
        .length;
    final pendingCount = sortedAssessments.length - completedCount;
    final averageScore = sortedAssessments.isEmpty
        ? 0.0
        : sortedAssessments.fold<double>(
                0.0,
                (sum, assessment) =>
                    sum + assessment.score / assessment.maxScore,
              ) /
              sortedAssessments.length;
    final reviewGuide = pendingCount == 0
        ? 'All assessments are complete. Review the best evidence and sign off when ready.'
        : 'Focus on the next pending assessment and keep the feedback short and specific.';
    final mentorFeedbackCoverage = sortedAssessments.isEmpty
        ? 0.0
        : sortedAssessments
                  .where(
                    (assessment) => assessment.mentorFeedback.trim().isNotEmpty,
                  )
                  .length /
              sortedAssessments.length;
    final evidenceCoverage = sortedAssessments.isEmpty
        ? 0.0
        : sortedAssessments
                  .where(
                    (assessment) => studentProgress.any(
                      (record) =>
                          record.entityId == assessment.id &&
                          record.progressPercent >= 80,
                    ),
                  )
                  .length /
              sortedAssessments.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Assessments',
          subtitle: 'Practical checklists, simple scores, and mentor feedback.',
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filter in EducationAssessmentFilter.values)
                    FilterChip(
                      label: Text(filter.label),
                      selected: selectedFilter == filter,
                      onSelected: (_) => onFilterChanged(filter),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Completed',
                    value: '$completedCount',
                    detail: 'Signed off checks ready for review',
                  ),
                  _InfoTile(
                    label: 'Pending',
                    value: '$pendingCount',
                    detail: 'Still waiting on practical completion',
                  ),
                  _InfoTile(
                    label: 'Average score',
                    value: '${(averageScore * 100).round()}%',
                    detail: 'Simple local assessment snapshot',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Score breakdown',
                subtitle:
                    'Simple local signals behind the current assessment view.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _InfoTile(
                          label: 'Completion',
                          value:
                              '${(completedCount / (sortedAssessments.isEmpty ? 1 : sortedAssessments.length) * 100).round()}%',
                          detail: 'Completed assessments in the current view',
                        ),
                        _InfoTile(
                          label: 'Mentor feedback',
                          value: '${(mentorFeedbackCoverage * 100).round()}%',
                          detail: 'Assessments with moderation notes',
                        ),
                        _InfoTile(
                          label: 'Evidence linked',
                          value: '${(evidenceCoverage * 100).round()}%',
                          detail: 'Assessments with clear supporting evidence',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: averageScore),
                    const SizedBox(height: 8),
                    Text(
                      'Average score: ${(averageScore * 100).round()}% of the local rubric, with $completedCount complete and $pendingCount pending.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Review guide',
                subtitle: 'A short reading cue for mentors and guardians.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reviewGuide),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(label: '$completedCount complete'),
                        _MiniBadge(label: '$pendingCount pending'),
                        _MiniBadge(label: selectedStudent.name),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      studentNotes.isEmpty
                          ? 'No mentor notes yet for this learner.'
                          : 'Mentor notes: ${studentNotes.length} local note(s) ready for review.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (sortedAssessments.isEmpty)
                const _EmptyInline(
                  title: 'No assessments yet',
                  subtitle:
                      'Assessment cards will appear as the content set grows.',
                )
              else
                for (final assessment in sortedAssessments)
                  _AssessmentCard(
                    assessment: assessment,
                    mentorNotes: studentNotes,
                    progressRecords: studentProgress,
                    lessonTitles: lessonTitles,
                  ),
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
    required this.onAddReflection,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final List<ReflectionEntry> reflections;
  final Future<void> Function(_ReflectionTemplateSpec template) onAddReflection;

  @override
  Widget build(BuildContext context) {
    final templates = [
      const _ReflectionTemplateSpec(
        label: 'Lesson review',
        title: 'Lesson review',
        body: 'What felt clear in the lesson, and what should stay slow?',
        mood: 'Reflective',
      ),
      const _ReflectionTemplateSpec(
        label: 'Project checkpoint',
        title: 'Project checkpoint',
        body: 'What has been built so far, and what is the next small step?',
        mood: 'Focused',
      ),
      const _ReflectionTemplateSpec(
        label: 'Mood check-in',
        title: 'Mood check-in',
        body: 'How does the learning feel today, and what support would help?',
        mood: 'Calm',
      ),
    ];
    final lessonTitles = {
      for (final lesson in snapshot.lessons) lesson.id: lesson.title,
    };
    final projectTitles = {
      for (final project in snapshot.projects) project.id: project.title,
    };
    final studentReflections =
        reflections
            .where((reflection) => reflection.studentId == selectedStudent.id)
            .toList(growable: false)
          ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    final latestReflection = studentReflections.isEmpty
        ? null
        : studentReflections.first;
    final reflectionPrompt = latestReflection == null
        ? 'What felt steady or useful in the last learning step?'
        : 'What changed since "${latestReflection.title}" and what would you keep?';
    final reflectionSummary = StringBuffer()
      ..writeln('Learner: ${selectedStudent.name}')
      ..writeln('Reflection count: ${studentReflections.length}')
      ..writeln(
        studentReflections.isEmpty
            ? 'Latest reflection: none yet'
            : 'Latest reflection: ${studentReflections.first.title} - ${studentReflections.first.body}',
      );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Reflection Journal',
          subtitle: 'A quiet place for learning memory and practical insight.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Reflections',
                    value: '${studentReflections.length}',
                    detail: 'Local notes saved for this learner',
                  ),
                  _InfoTile(
                    label: 'Latest mood',
                    value: latestReflection == null
                        ? 'None'
                        : latestReflection.mood,
                    detail: studentReflections.isEmpty
                        ? 'Waiting for the first reflection'
                        : 'Most recent journal entry',
                  ),
                  _InfoTile(
                    label: 'Latest title',
                    value: latestReflection == null
                        ? 'None yet'
                        : latestReflection.title,
                    detail: 'Latest memory from the learner journal',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Reflection prompt',
                subtitle: 'A calm prompt to guide the next journal entry.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reflectionPrompt),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(
                          label: '${studentReflections.length} entries',
                        ),
                        if (latestReflection != null)
                          _MiniBadge(label: latestReflection.mood),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Reflection templates',
                subtitle:
                    'Quick-start prompts for lesson reviews, project notes, and mood check-ins.',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final template in templates)
                      ActionChip(
                        label: Text(template.label),
                        onPressed: () {
                          unawaited(onAddReflection(template));
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      unawaited(onAddReflection(templates.first));
                    },
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Add reflection'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: reflectionSummary.toString().trim(),
                        ),
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reflection summary copied locally.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Copy summary'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (studentReflections.isEmpty)
                const _EmptyInline(
                  title: 'No reflections yet',
                  subtitle: 'Add a reflection after the next learning step.',
                )
              else
                Column(
                  children: [
                    for (final reflection in studentReflections)
                      _ReflectionCard(
                        reflection: reflection,
                        linkedLessonTitle:
                            lessonTitles[reflection.linkedLessonId],
                        linkedProjectTitle:
                            projectTitles[reflection.linkedProjectId],
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

class _CertificatesTab extends StatelessWidget {
  const _CertificatesTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.certificates,
    required this.onIssueDraftCertificate,
    required this.onOpenDraftCertificatePdf,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final List<Certificate> certificates;
  final VoidCallback onIssueDraftCertificate;
  final VoidCallback onOpenDraftCertificatePdf;

  @override
  Widget build(BuildContext context) {
    final studentCertificates = certificates
        .where((certificate) => certificate.studentId == selectedStudent.id)
        .toList(growable: false);
    final completedAssessments = snapshot.completedAssessmentsForStudent(
      selectedStudent.id,
    );
    final readiness = snapshot.badgeReadinessForStudent(selectedStudent.id);
    final pathwayTitle = snapshot.pathways
        .firstWhere(
          (pathway) => pathway.id == selectedStudent.activePathwayId,
          orElse: () => snapshot.pathways.first,
        )
        .title;
    final canIssueDraft = completedAssessments.isNotEmpty && readiness >= 0.5;
    final passportSummary = StringBuffer()
      ..writeln('Learner: ${selectedStudent.name}')
      ..writeln('Role: ${selectedStudent.role}')
      ..writeln('Pathway: ${selectedStudent.activePathwayId}')
      ..writeln('Badges: ${selectedStudent.badgeIds.join(', ')}')
      ..writeln('Certificates: ${studentCertificates.length}')
      ..writeln('Assessment readiness: ${(readiness * 100).round()}%')
      ..writeln('Completed assessments: ${completedAssessments.length}');
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
              _CertificatePreviewCard(
                studentName: selectedStudent.name,
                pathwayTitle: pathwayTitle,
                readiness: readiness,
                completedAssessments: completedAssessments.length,
                canIssue: canIssueDraft,
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Issuance rules',
                subtitle: 'The certificate flow stays calm and intentional.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in [
                      'At least one completed assessment is required.',
                      'Readiness should reach 50% before a draft is issued.',
                      'Mentor review is recommended before export.',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('- $line'),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(
                          label: canIssueDraft
                              ? 'Eligible now'
                              : 'Hold for review',
                        ),
                        _MiniBadge(
                          label: '${(readiness * 100).round()}% readiness',
                        ),
                        _MiniBadge(
                          label:
                              '${completedAssessments.length} completed assessments',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Passport summary',
                subtitle: 'Clipboard-friendly badge and certificate snapshot.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(passportSummary.toString().trim()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: passportSummary.toString().trim(),
                              ),
                            );
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Passport summary copied locally.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_all_outlined),
                          label: const Text('Copy passport'),
                        ),
                        FilledButton.icon(
                          onPressed: canIssueDraft
                              ? onIssueDraftCertificate
                              : null,
                          icon: const Icon(Icons.workspace_premium_outlined),
                          label: const Text('Issue draft certificate'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onOpenDraftCertificatePdf,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Open PDF draft'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      canIssueDraft
                          ? 'Draft certificates use the completed assessment set and readiness summary.'
                          : 'Finish one assessment and keep progress moving before issuing a draft certificate.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (studentCertificates.isEmpty)
                const _EmptyInline(
                  title: 'No badges issued yet',
                  subtitle:
                      'Badges will appear when assessments are signed off.',
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

class _ReportsTab extends StatelessWidget {
  const _ReportsTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.selectedPathway,
    required this.roleView,
    required this.reportWindow,
    required this.latestMentorReportPath,
    required this.latestCertificateDraftPath,
    required this.latestContentPackDraftPath,
    required this.latestContentPackDraftPdfPath,
    required this.onExportReport,
    required this.onSelectStudent,
    required this.onWindowChanged,
    required this.onIssueDraftCertificate,
    required this.onExportContentPack,
    required this.onOpenCertificatePdf,
    required this.onOpenContentPackPdf,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final LearningPathway selectedPathway;
  final EducationRoleView roleView;
  final EducationReportWindow reportWindow;
  final String? latestMentorReportPath;
  final String? latestCertificateDraftPath;
  final String? latestContentPackDraftPath;
  final String? latestContentPackDraftPdfPath;
  final VoidCallback onExportReport;
  final ValueChanged<String> onSelectStudent;
  final ValueChanged<EducationReportWindow> onWindowChanged;
  final VoidCallback onIssueDraftCertificate;
  final VoidCallback onExportContentPack;
  final VoidCallback onOpenCertificatePdf;
  final VoidCallback onOpenContentPackPdf;

  List<T> _applyReportWindow<T>(
    List<T> items,
    DateTime Function(T item) dateSelector,
  ) {
    final now = DateTime.now().toLocal();
    bool include(T item) {
      final local = dateSelector(item).toLocal();
      return switch (reportWindow) {
        EducationReportWindow.all => true,
        EducationReportWindow.recent => now.difference(local).inDays <= 7,
        EducationReportWindow.today =>
          now.year == local.year &&
              now.month == local.month &&
              now.day == local.day,
      };
    }

    final filtered = items.where(include).toList(growable: false);
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final progressLabel = snapshot.progressLabelForStudent(selectedStudent.id);
    final badgeReadiness = snapshot.badgeReadinessForStudent(
      selectedStudent.id,
    );
    final reflections = snapshot.reflectionsForStudent(selectedStudent.id);
    final completedAssessments = snapshot.completedAssessmentsForStudent(
      selectedStudent.id,
    );
    final filteredReflections = _applyReportWindow(
      reflections,
      (entry) => entry.createdAt,
    );
    final filteredAssessments = _applyReportWindow(
      completedAssessments,
      (assessment) =>
          assessment.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
    final reportSummary = StringBuffer()
      ..writeln('Learner: ${selectedStudent.name}')
      ..writeln('Role view: ${roleView.label}')
      ..writeln('Pathway: ${selectedPathway.title}')
      ..writeln('Window: ${reportWindow.label}')
      ..writeln('Progress: $progressLabel')
      ..writeln('Reflections: ${filteredReflections.length}')
      ..writeln('Completed assessments: ${filteredAssessments.length}')
      ..writeln('Badge readiness: ${(badgeReadiness * 100).round()}%')
      ..writeln(
        'Mentor report: ${latestMentorReportPath == null ? 'None yet' : path.basename(latestMentorReportPath!)}',
      )
      ..writeln(
        'Certificate draft: ${latestCertificateDraftPath == null ? 'None yet' : path.basename(latestCertificateDraftPath!)}',
      )
      ..writeln(
        'Content pack: ${latestContentPackDraftPath == null ? 'None yet' : path.basename(latestContentPackDraftPath!)}',
      );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Reports',
          subtitle:
              'Read-only summaries for mentor reports, certificate drafts, and content pack outputs.',
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final window in EducationReportWindow.values)
                    ChoiceChip(
                      label: Text(window.label),
                      selected: window == reportWindow,
                      onSelected: (_) => onWindowChanged(window),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Mentor report',
                    value: latestMentorReportPath == null
                        ? 'None yet'
                        : path.basename(latestMentorReportPath!),
                    detail: 'Local handoff note from Mentor Workspace.',
                  ),
                  _InfoTile(
                    label: 'Certificate draft',
                    value: latestCertificateDraftPath == null
                        ? 'None yet'
                        : path.basename(latestCertificateDraftPath!),
                    detail: 'Draft preview ready for review and PDF export.',
                  ),
                  _InfoTile(
                    label: 'Content pack',
                    value: latestContentPackDraftPath == null
                        ? 'None yet'
                        : path.basename(latestContentPackDraftPath!),
                    detail:
                        'Local pack draft with validation and preview file.',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Report bundle snapshot',
                subtitle: 'A calm summary of the current learner and exports.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reportSummary.toString().trim()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(label: roleView.label),
                        _MiniBadge(label: progressLabel),
                        _MiniBadge(label: '${reflections.length} reflections'),
                        _MiniBadge(
                          label: '${completedAssessments.length} assessments',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Quick actions',
                subtitle:
                    'Refresh the local reports or open preview artifacts.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: onExportReport,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Export mentor report'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onIssueDraftCertificate,
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: const Text('Issue draft certificate'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onExportContentPack,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Export content pack'),
                    ),
                    if (latestCertificateDraftPath != null)
                      OutlinedButton.icon(
                        onPressed: onOpenCertificatePdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Open certificate PDF'),
                      ),
                    if (latestContentPackDraftPdfPath != null)
                      OutlinedButton.icon(
                        onPressed: onOpenContentPackPdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Open pack PDF'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Latest outputs',
                subtitle:
                    'The most recent local files are listed here for quick review.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MiniBadge(
                      label: latestMentorReportPath == null
                          ? 'Mentor report not created yet'
                          : 'Mentor report ready',
                    ),
                    const SizedBox(height: 8),
                    _MiniBadge(
                      label: latestCertificateDraftPath == null
                          ? 'Certificate draft not created yet'
                          : 'Certificate draft ready',
                    ),
                    const SizedBox(height: 8),
                    _MiniBadge(
                      label: latestContentPackDraftPath == null
                          ? 'Content pack draft not created yet'
                          : 'Content pack draft ready',
                    ),
                    const SizedBox(height: 8),
                    _MiniBadge(
                      label: latestContentPackDraftPdfPath == null
                          ? 'Pack PDF preview not created yet'
                          : 'Pack PDF preview ready',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.roleView,
    required this.onOpenMentorWorkspace,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
  final VoidCallback onOpenMentorWorkspace;

  @override
  Widget build(BuildContext context) {
    final pathway = snapshot.pathways.firstWhere(
      (value) => value.id == selectedStudent.activePathwayId,
      orElse: () => snapshot.pathways.first,
    );
    final supportSummary = StringBuffer()
      ..writeln('Learner: ${selectedStudent.name}')
      ..writeln('Role lens: ${roleView.label}')
      ..writeln('Active pathway: ${pathway.title}')
      ..writeln('Mentor: ${selectedStudent.mentorName}')
      ..writeln('Guardian: ${selectedStudent.guardianName}')
      ..writeln(
        'Badge readiness: ${(snapshot.badgeReadinessForStudent(selectedStudent.id) * 100).round()}%',
      )
      ..writeln(
        'Community note: Keep handoffs calm, local, and human-reviewed.',
      );
    final groupedByRole = <String, List<StudentProfile>>{};
    for (final student in snapshot.students) {
      groupedByRole
          .putIfAbsent(student.role, () => <StudentProfile>[])
          .add(student);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Community / Classroom Mode',
          subtitle:
              'A calm group view for mentors, guardians, and classroom support.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Learners',
                    value: '${snapshot.learnerCount}',
                    detail: 'Local learner profiles in the hub',
                  ),
                  _InfoTile(
                    label: 'Active pathway',
                    value: pathway.title,
                    detail: selectedStudent.stage,
                  ),
                  _InfoTile(
                    label: 'Role lens',
                    value: roleView.label,
                    detail: roleView.summary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Classroom rhythm',
                subtitle:
                    'Use this view for group support, home handoffs, or short class check-ins.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(supportSummary.toString().trim()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final student in snapshot.students)
                          _MiniBadge(label: student.name),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: onOpenMentorWorkspace,
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Open mentor workspace'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final entry in groupedByRole.entries)
                    _Panel(
                      title: entry.key,
                      subtitle: '${entry.value.length} learner(s)',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final student in entry.value)
                            _MiniBadge(label: student.name),
                        ],
                      ),
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

class _ContentBuilderTab extends StatefulWidget {
  const _ContentBuilderTab({
    required this.snapshot,
    required this.selectedStudent,
    required this.roleView,
    required this.onExportBundle,
    required this.onImportBundle,
    required this.onSaveDraft,
    required this.onExportDraft,
  });

  final EducationHubSnapshot snapshot;
  final StudentProfile selectedStudent;
  final EducationRoleView roleView;
  final VoidCallback onExportBundle;
  final VoidCallback onImportBundle;
  final Future<void> Function(ContentPackDraft draft) onSaveDraft;
  final VoidCallback onExportDraft;

  @override
  State<_ContentBuilderTab> createState() => _ContentBuilderTabState();
}

class _ContentBuilderTabState extends State<_ContentBuilderTab> {
  late final TextEditingController _packNameController;
  late final TextEditingController _packSummaryController;
  late final TextEditingController _packAudienceController;
  late final TextEditingController _packVersionController;
  String _selectedTemplate = 'lesson_first';

  @override
  void initState() {
    super.initState();
    final draft = widget.snapshot.contentPackDraft;
    _packNameController = TextEditingController(
      text: draft.title.isNotEmpty ? draft.title : 'Education Content Pack',
    );
    _packSummaryController = TextEditingController(
      text: draft.summary.isNotEmpty
          ? draft.summary
          : 'Local-first pack for lessons, projects, reflections, and badges.',
    );
    _packAudienceController = TextEditingController(
      text: draft.audience.isNotEmpty ? draft.audience : widget.roleView.label,
    );
    _packVersionController = TextEditingController(
      text: draft.version.isNotEmpty ? draft.version : '0.1.0',
    );
    _selectedTemplate = draft.template.isNotEmpty
        ? draft.template
        : 'lesson_first';
  }

  @override
  void didUpdateWidget(covariant _ContentBuilderTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final draft = widget.snapshot.contentPackDraft;
    if (oldWidget.snapshot.contentPackDraft == draft) {
      return;
    }
    if (_packNameController.text != draft.title && draft.title.isNotEmpty) {
      _packNameController.text = draft.title;
    }
    if (_packSummaryController.text != draft.summary &&
        draft.summary.isNotEmpty) {
      _packSummaryController.text = draft.summary;
    }
    if (_packAudienceController.text != draft.audience &&
        draft.audience.isNotEmpty) {
      _packAudienceController.text = draft.audience;
    }
    if (_packVersionController.text != draft.version &&
        draft.version.isNotEmpty) {
      _packVersionController.text = draft.version;
    }
    if (_selectedTemplate != draft.template && draft.template.isNotEmpty) {
      setState(() {
        _selectedTemplate = draft.template;
      });
    }
  }

  @override
  void dispose() {
    _packNameController.dispose();
    _packSummaryController.dispose();
    _packAudienceController.dispose();
    _packVersionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final contentSources = snapshot.contentSources;
    final docsCount = contentSources
        .where((source) => source.kind == 'Documentation')
        .length;
    final sampleCount = contentSources
        .where((source) => source.kind == 'Sample data')
        .length;
    final resourceCount = snapshot.resources.length;
    final selectedCount = [
      snapshot.pathways.take(3).length,
      snapshot.lessons.take(5).length,
      snapshot.projects.take(2).length,
    ].fold<int>(0, (sum, value) => sum + value);
    final templateLabel = switch (_selectedTemplate) {
      'project_first' => 'Project first',
      'mentor_pack' => 'Mentor pack',
      'passport_pack' => 'Passport pack',
      _ => 'Lesson first',
    };
    final previewDraft = _contentPackService.normalize(
      ContentPackDraft(
        title: _packNameController.text.trim(),
        version: _packVersionController.text.trim(),
        audience: _packAudienceController.text.trim(),
        summary: _packSummaryController.text.trim(),
        template: _selectedTemplate,
        validationReady: false,
        validationNotes: '',
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    final previewChecksum = previewDraft.checksum;
    final previewBundleId = previewDraft.bundleId;
    final validationReady = previewDraft.validationReady;
    final validationNotes = previewDraft.validationNotes;
    final validationChecks = <({String label, bool passed, String detail})>[
      (
        label: 'Title set',
        passed: _packNameController.text.trim().isNotEmpty,
        detail: 'The pack needs a clear working title.',
      ),
      (
        label: 'Summary ready',
        passed: _packSummaryController.text.trim().length >= 24,
        detail: 'A short summary keeps the pack easy to scan.',
      ),
      (
        label: 'Audience chosen',
        passed: _packAudienceController.text.trim().isNotEmpty,
        detail: 'Every pack should start with a clear reader.',
      ),
      (
        label: 'Version tagged',
        passed:
            previewDraft.version.isNotEmpty &&
            EducationContentPackService.semanticVersionPattern.hasMatch(
              previewDraft.version,
            ),
        detail: 'Use semantic versioning like 0.1.0 or 1.0.0.',
      ),
      (
        label: 'Checksum ready',
        passed: previewChecksum.isNotEmpty,
        detail: 'Each pack draft carries a local checksum for verification.',
      ),
    ];
    final packBlueprint = <String>[
      'Template: $templateLabel',
      'Version: ${_packVersionController.text.trim()}',
      'Audience: ${_packAudienceController.text.trim()}',
      'Lessons: ${snapshot.lessons.take(5).map((lesson) => lesson.title).join(', ')}',
      'Projects: ${snapshot.projects.take(2).map((project) => project.title).join(', ')}',
      'Sources: ${contentSources.take(4).map((source) => source.title).join(', ')}',
    ];
    final packSummary = StringBuffer()
      ..writeln('Pack: ${_packNameController.text.trim()}')
      ..writeln('Template: $templateLabel')
      ..writeln('Version: ${_packVersionController.text.trim()}')
      ..writeln('Audience: ${_packAudienceController.text.trim()}')
      ..writeln('Bundle ID: $previewBundleId')
      ..writeln('Checksum: $previewChecksum')
      ..writeln('Owner learner: ${widget.selectedStudent.name}')
      ..writeln('Summary: ${_packSummaryController.text.trim()}')
      ..writeln('Documentation sources: $docsCount')
      ..writeln('Sample packs: $sampleCount')
      ..writeln('Resources: $resourceCount')
      ..writeln('Validation: ${validationReady ? 'Ready' : 'Needs detail'}');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _Panel(
          title: 'Content Builder',
          subtitle:
              'Draft offline learning packs, review source coverage, and keep the pack local.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoTile(
                    label: 'Pack title',
                    value: _packNameController.text.trim(),
                    detail: 'Local-only draft name for the pack',
                  ),
                  _InfoTile(
                    label: 'Audience',
                    value: _packAudienceController.text.trim(),
                    detail: 'Set the starting role view for the pack',
                  ),
                  _InfoTile(
                    label: 'Coverage',
                    value: '${contentSources.length} sources',
                    detail:
                        '$docsCount docs, $sampleCount sample packs, $resourceCount resources',
                  ),
                  _InfoTile(
                    label: 'Version',
                    value: _packVersionController.text.trim(),
                    detail: validationReady
                        ? 'Pack is tagged and ready for the next draft step'
                        : 'Add a version tag before export or handoff',
                  ),
                  _InfoTile(
                    label: 'Bundle ID',
                    value: previewBundleId,
                    detail: 'Local manifest id for exports and handoff',
                  ),
                  _InfoTile(
                    label: 'Checksum',
                    value: previewChecksum,
                    detail: 'Stable local checksum for pack verification',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Template presets',
                subtitle:
                    'Start from a calm pack shape and adjust the details.',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Lesson first'),
                      selected: _selectedTemplate == 'lesson_first',
                      onSelected: (_) => setState(() {
                        _selectedTemplate = 'lesson_first';
                        _packNameController.text = 'Lesson Pack';
                        _packSummaryController.text =
                            'A calm lesson-first pack for local learning.';
                        _packAudienceController.text = widget.roleView.label;
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('Project first'),
                      selected: _selectedTemplate == 'project_first',
                      onSelected: (_) => setState(() {
                        _selectedTemplate = 'project_first';
                        _packNameController.text = 'Project Pack';
                        _packSummaryController.text =
                            'A practical project-first pack with evidence and steps.';
                        _packAudienceController.text = widget.roleView.label;
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('Mentor pack'),
                      selected: _selectedTemplate == 'mentor_pack',
                      onSelected: (_) => setState(() {
                        _selectedTemplate = 'mentor_pack';
                        _packNameController.text = 'Mentor Support Pack';
                        _packSummaryController.text =
                            'A support pack for mentor review, handoff, and guidance.';
                        _packAudienceController.text = 'Mentor';
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('Passport pack'),
                      selected: _selectedTemplate == 'passport_pack',
                      onSelected: (_) => setState(() {
                        _selectedTemplate = 'passport_pack';
                        _packNameController.text = 'Passport Pack';
                        _packSummaryController.text =
                            'A certificate and badge pack for local export and review.';
                        _packAudienceController.text = 'Admin';
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _packNameController,
                decoration: const InputDecoration(
                  labelText: 'Pack name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _packSummaryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Pack summary',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _packAudienceController,
                decoration: const InputDecoration(
                  labelText: 'Primary audience',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _packVersionController,
                decoration: const InputDecoration(
                  labelText: 'Pack version',
                  border: OutlineInputBorder(),
                  helperText: 'Use a calm version like 0.1.0 or 1.0.0',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Pack blueprint',
                subtitle: 'A quick draft of what this pack currently contains.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(label: '$selectedCount draft items'),
                        _MiniBadge(label: '$docsCount docs'),
                        _MiniBadge(label: '$sampleCount sample packs'),
                        _MiniBadge(label: '$resourceCount resources'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final line in packBlueprint)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('- $line'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Pack validation',
                subtitle: validationReady
                    ? 'The current draft is ready for local export.'
                    : 'Keep the draft calm by clearing the remaining checks.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(
                          label: validationReady
                              ? 'Ready to export'
                              : 'Needs detail',
                        ),
                        _MiniBadge(label: '${validationChecks.length} checks'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final check in validationChecks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              check.passed
                                  ? Icons.check_circle_outline
                                  : Icons.radio_button_unchecked,
                              size: 18,
                              color: check.passed
                                  ? AppColours.darkSuccess
                                  : AppColours.darkAmber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(check.label),
                                  const SizedBox(height: 2),
                                  Text(
                                    check.detail,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColours.darkMutedText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Build checklist',
                subtitle: 'A calm list for the next offline pack draft.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in const [
                      'Choose the lesson set.',
                      'Check the linked sources.',
                      'Add one project activity.',
                      'Review assessments and reflections.',
                      'Export the bundle locally.',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('- $line'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Pack summary',
                subtitle:
                    'Clipboard-ready snapshot for future pack creation work.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(packSummary.toString().trim()),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(label: '${snapshot.pathwayCount} pathways'),
                        _MiniBadge(label: '${snapshot.lessonCount} lessons'),
                        _MiniBadge(label: '${snapshot.projectCount} projects'),
                        _MiniBadge(
                          label: '${snapshot.certificateCount} certificates',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () {
                            unawaited(
                              widget.onSaveDraft(
                                ContentPackDraft(
                                  title: _packNameController.text.trim(),
                                  version: _packVersionController.text.trim(),
                                  audience: _packAudienceController.text.trim(),
                                  summary: _packSummaryController.text.trim(),
                                  template: _selectedTemplate,
                                  validationReady: validationReady,
                                  validationNotes: validationNotes.isEmpty
                                      ? 'Draft is ready locally.'
                                      : validationNotes,
                                  updatedAt: DateTime.now().toUtc(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save draft'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: packSummary.toString().trim(),
                              ),
                            );
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pack summary copied locally.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_all_outlined),
                          label: const Text('Copy summary'),
                        ),
                        OutlinedButton.icon(
                          onPressed: widget.onExportBundle,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: const Text('Export bundle'),
                        ),
                        OutlinedButton.icon(
                          onPressed: widget.onImportBundle,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Import bundle'),
                        ),
                        OutlinedButton.icon(
                          onPressed: widget.onExportDraft,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Export draft'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (contentSources.isNotEmpty) ...[
                Text(
                  'Source library preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final source in contentSources.take(4)) ...[
                  _ContentSourceCard(source: source),
                  const SizedBox(height: 10),
                ],
              ],
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
    required this.latestMentorReportPath,
    required this.latestCertificateDraftPath,
    required this.latestContentPackDraftPath,
    required this.latestContentPackDraftPdfPath,
    required this.latestContentPackDraftManifestPath,
    required this.onOpenLatestContentPackDraftPdf,
    required this.onOpenKnowledgeEngine,
    required this.onOpenGaiaPlaceholder,
    required this.onOpenMore,
    required this.onExportRoute,
    required this.onExportContentPack,
    required this.onImportContentPack,
  });

  final EducationHubSnapshot snapshot;
  final List<ContentSourceEntry> contentSources;
  final EducationRoleView roleView;
  final String? latestMentorReportPath;
  final String? latestCertificateDraftPath;
  final String? latestContentPackDraftPath;
  final String? latestContentPackDraftPdfPath;
  final String? latestContentPackDraftManifestPath;
  final VoidCallback onOpenLatestContentPackDraftPdf;
  final VoidCallback onOpenKnowledgeEngine;
  final VoidCallback onOpenGaiaPlaceholder;
  final VoidCallback onOpenMore;
  final VoidCallback onExportRoute;
  final VoidCallback onExportContentPack;
  final VoidCallback onImportContentPack;

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
                detail:
                    'Markdown docs and sample data are visible as source-linked content.',
              ),
              const SizedBox(height: 12),
              _InfoTile(
                label: 'Role view',
                value: roleView.label,
                detail: roleView.summary,
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Local outputs',
                subtitle:
                    'Keep track of the latest mentor report and certificate draft generated by the hub.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoTile(
                      label: 'Latest mentor report',
                      value: latestMentorReportPath ?? 'None yet',
                      detail: latestMentorReportPath == null
                          ? 'Export one from Mentor Workspace to surface it here.'
                          : 'Stored locally and ready to copy into a handoff note.',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Latest certificate draft',
                      value: latestCertificateDraftPath ?? 'None yet',
                      detail: latestCertificateDraftPath == null
                          ? 'Issue a draft certificate to surface it here.'
                          : 'Stored locally and ready for review.',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Latest content pack',
                      value: latestContentPackDraftPath ?? 'None yet',
                      detail: latestContentPackDraftPath == null
                          ? 'Export a content pack draft to surface it here.'
                          : 'Stored locally with a PDF preview and manifest beside it.',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Latest manifest',
                      value: latestContentPackDraftManifestPath ?? 'None yet',
                      detail: latestContentPackDraftManifestPath == null
                          ? 'The validation manifest appears after export.'
                          : 'Version, checksum, and coverage are saved here.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Draft shortcuts',
                subtitle: 'Open the most recent exported preview artifacts.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _QuickActionChip(
                          label: 'Certificate PDF',
                          tooltip: latestCertificateDraftPath ?? '',
                          onTap: latestCertificateDraftPath == null
                              ? null
                              : () => openLocalPdfDocument(
                                  context,
                                  title: 'Certificate draft',
                                  pdfPath: latestCertificateDraftPath!,
                                ),
                        ),
                        _QuickActionChip(
                          label: 'Pack PDF',
                          tooltip: latestContentPackDraftPdfPath ?? '',
                          onTap: latestContentPackDraftPdfPath == null
                              ? null
                              : onOpenLatestContentPackDraftPdf,
                        ),
                        _QuickActionChip(
                          label: 'Pack manifest',
                          tooltip: latestContentPackDraftManifestPath ?? '',
                          onTap: latestContentPackDraftManifestPath == null
                              ? null
                              : () async {
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: latestContentPackDraftManifestPath!,
                                    ),
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Content pack manifest path copied locally.',
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      latestContentPackDraftPath == null
                          ? 'No content pack export has been created yet.'
                          : 'Content pack draft note: ${path.basename(latestContentPackDraftPath!)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Output paths',
                subtitle:
                    'Copy the latest local export locations for handoff or review.',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (latestMentorReportPath != null)
                      _CopyPathChip(
                        label: 'Report',
                        tooltip: latestMentorReportPath!,
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: latestMentorReportPath!),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Mentor report path copied locally.',
                              ),
                            ),
                          );
                        },
                      ),
                    if (latestCertificateDraftPath != null)
                      _CopyPathChip(
                        label: 'Certificate',
                        tooltip: latestCertificateDraftPath!,
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: latestCertificateDraftPath!),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Certificate draft path copied locally.',
                              ),
                            ),
                          );
                        },
                      ),
                    if (latestContentPackDraftPath != null)
                      _CopyPathChip(
                        label: 'Pack',
                        tooltip: latestContentPackDraftPath!,
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: latestContentPackDraftPath!),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Content pack draft path copied locally.',
                              ),
                            ),
                          );
                        },
                      ),
                    if (latestContentPackDraftPdfPath != null)
                      _CopyPathChip(
                        label: 'Pack PDF',
                        tooltip: latestContentPackDraftPdfPath!,
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: latestContentPackDraftPdfPath!),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Content pack PDF path copied locally.',
                              ),
                            ),
                          );
                        },
                      ),
                    if (latestContentPackDraftManifestPath != null)
                      _CopyPathChip(
                        label: 'Manifest',
                        tooltip: latestContentPackDraftManifestPath!,
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: latestContentPackDraftManifestPath!,
                            ),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Content pack manifest path copied locally.',
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Offline pack controls',
                subtitle:
                    'Import and export the learning pack bundle from one calm place.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use these buttons to move the local content pack in and out of the module without cloud sync.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onExportContentPack,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: const Text('Export content pack'),
                        ),
                        OutlinedButton.icon(
                          onPressed: onImportContentPack,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Import content pack'),
                        ),
                      ],
                    ),
                  ],
                ),
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
                Text(
                  'Latest content sources',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
              FilledButton.tonal(onPressed: onPressed, child: Text(buttonText)),
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
  const _EmptyInline({required this.title, required this.subtitle});

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
    required this.selectedStudent,
    required this.completedLessons,
    required this.totalLessons,
    required this.unitCount,
  });

  final LearningPathway pathway;
  final bool selected;
  final VoidCallback onTap;
  final StudentProfile selectedStudent;
  final int completedLessons;
  final int totalLessons;
  final int unitCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.24)
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
                  _MiniBadge(label: '$unitCount units'),
                  _MiniBadge(label: '$completedLessons/$totalLessons lessons'),
                  if (pathway.id == selectedStudent.activePathwayId)
                    const _MiniBadge(label: 'Active pathway'),
                  for (final tag in pathway.skillTags.take(3))
                    _MiniBadge(label: tag),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: totalLessons == 0 ? 0 : completedLessons / totalLessons,
                minHeight: 6,
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
                for (final skill in project.skillTags.take(3))
                  _MiniBadge(label: skill),
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
                _MiniBadge(
                  label: '${project.resourceIds.length} linked source(s)',
                ),
                _MiniBadge(label: project.domain),
                if (evidenceRecord != null)
                  _MiniBadge(label: evidenceRecord!.status),
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
        Text(
          'Learning timeline',
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
                  if (lesson.sourceKind.isNotEmpty)
                    _MiniBadge(label: lesson.sourceKind),
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
                        subtitle:
                            'This lesson will gain source links as content packs grow.',
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
              Text(
                project.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
                detail:
                    'Use this panel to keep the project notes, checkpoints, and links calm.',
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
                subtitle:
                    'Local checkpoints that show progress on the project.',
                child: evidenceRecords.isEmpty
                    ? const _EmptyInline(
                        title: 'No checkpoint history yet',
                        subtitle:
                            'Save a checkpoint to create the first local evidence entry.',
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
  const _ReflectionCard({
    required this.reflection,
    this.linkedLessonTitle,
    this.linkedProjectTitle,
  });

  final ReflectionEntry reflection;
  final String? linkedLessonTitle;
  final String? linkedProjectTitle;

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
            if ((linkedLessonTitle ?? '').isNotEmpty ||
                (linkedProjectTitle ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if ((linkedLessonTitle ?? '').isNotEmpty)
                    _MiniBadge(label: 'Lesson: $linkedLessonTitle'),
                  if ((linkedProjectTitle ?? '').isNotEmpty)
                    _MiniBadge(label: 'Project: $linkedProjectTitle'),
                ],
              ),
            ],
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

class _MentorReviewCard extends StatelessWidget {
  const _MentorReviewCard({required this.review});

  final MentorReviewRecord review;

  @override
  Widget build(BuildContext context) {
    final moderationNote = _mentorModerationNote(review);
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
                    review.reviewer,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _MiniBadge(label: review.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(review.notes),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColours.darkSurfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColours.darkOutline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moderation note',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(moderationNote),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(label: review.handoffStatus),
                _MiniBadge(label: review.reviewedAt.toLocal().toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _mentorModerationNote(MentorReviewRecord review) {
  final base = switch (review.status) {
    'Ready for sign-off' =>
      'Keep the evidence attached and confirm the handoff is calm and clear.',
    'Needs follow-up' =>
      'Leave one short follow-up action and revisit the evidence before sign-off.',
    'Signed off locally' =>
      'Record the handoff, keep the review note short, and preserve the local trail.',
    _ => 'Keep the review short, specific, and ready for local handoff.',
  };
  if (review.handoffStatus == 'Waiting for evidence') {
    return '$base The handoff is still waiting on supporting evidence.';
  }
  if (review.handoffStatus == 'Mentor review in progress') {
    return '$base The learner is still in review, so keep the next action small.';
  }
  return base;
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.assessment,
    required this.mentorNotes,
    required this.progressRecords,
    required this.lessonTitles,
  });

  final Assessment assessment;
  final List<MentorNote> mentorNotes;
  final List<ProgressRecord> progressRecords;
  final Map<String, String> lessonTitles;

  @override
  Widget build(BuildContext context) {
    final completed = assessment.completedAt != null;
    final scoreRatio = assessment.maxScore == 0
        ? 0.0
        : assessment.score / assessment.maxScore;
    final rubricBand = switch (scoreRatio) {
      >= 0.85 => 'Strong',
      >= 0.65 => 'Building well',
      >= 0.4 => 'Building',
      _ => 'Starting',
    };
    final evidenceRecords = progressRecords
        .where(
          (record) =>
              record.studentId == assessment.studentId &&
              record.progressPercent >= 80,
        )
        .take(3)
        .toList(growable: false);
    final evidenceRefs = evidenceRecords
        .map((record) => lessonTitles[record.entityId] ?? record.entityId)
        .toList(growable: false);
    final statusLine = completed
        ? 'Ready for sign-off'
        : assessment.score > 0
        ? 'Partly complete'
        : 'Awaiting first evidence';
    final mentorNote = mentorNotes.isEmpty
        ? null
        : mentorNotes.firstWhere(
            (note) => note.content.toLowerCase().contains(
              assessment.title.toLowerCase(),
            ),
            orElse: () => mentorNotes.first,
          );
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
            const SizedBox(height: 4),
            Text('Status: $statusLine'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(label: completed ? 'Complete' : 'Pending'),
                _MiniBadge(label: '${assessment.audiences.length} audience(s)'),
                _MiniBadge(label: rubricBand),
                for (final criterion in assessment.criteria.take(4))
                  _MiniBadge(label: criterion),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              evidenceRefs.isEmpty
                  ? 'Evidence refs: none linked yet.'
                  : 'Evidence refs: ${evidenceRefs.join(', ')}',
            ),
            if (assessment.mentorFeedback.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Mentor moderation note: ${assessment.mentorFeedback}'),
            ] else if (mentorNote != null) ...[
              const SizedBox(height: 6),
              Text('Mentor moderation note: ${mentorNote.content}'),
            ],
            const SizedBox(height: 10),
            Text(
              'Score breakdown',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            _AssessmentBreakdownRow(
              label: 'Rubric score',
              value: scoreRatio,
              detail: '${(scoreRatio * 100).round()}% of max score',
            ),
            const SizedBox(height: 6),
            _AssessmentBreakdownRow(
              label: 'Evidence depth',
              value: evidenceRecords.isEmpty
                  ? 0.0
                  : (evidenceRecords.length / 3).clamp(0.0, 1.0),
              detail: evidenceRecords.isEmpty
                  ? 'No local evidence links yet'
                  : '${evidenceRecords.length} evidence reference(s)',
            ),
            const SizedBox(height: 6),
            _AssessmentBreakdownRow(
              label: 'Mentor moderation',
              value: assessment.mentorFeedback.isNotEmpty
                  ? 1.0
                  : mentorNote != null
                  ? 0.7
                  : completed
                  ? 0.5
                  : 0.25,
              detail: assessment.mentorFeedback.isNotEmpty
                  ? 'Direct moderation note recorded'
                  : mentorNote != null
                  ? 'Pulled from mentor notes'
                  : 'Waiting for a mentor note',
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentBreakdownRow extends StatelessWidget {
  const _AssessmentBreakdownRow({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final double value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('${(clamped * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: clamped),
        const SizedBox(height: 4),
        Text(detail, style: Theme.of(context).textTheme.bodySmall),
      ],
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
          Text(
            certificate.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
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

class _CertificatePreviewCard extends StatelessWidget {
  const _CertificatePreviewCard({
    required this.studentName,
    required this.pathwayTitle,
    required this.readiness,
    required this.completedAssessments,
    required this.canIssue,
  });

  final String studentName;
  final String pathwayTitle;
  final double readiness;
  final int completedAssessments;
  final bool canIssue;

  @override
  Widget build(BuildContext context) {
    final badgeLevel = readiness >= 0.8
        ? 'Gold'
        : readiness >= 0.6
        ? 'Silver'
        : readiness >= 0.4
        ? 'Bronze'
        : 'Draft';
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Certificate preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _MiniBadge(label: canIssue ? 'Eligible' : 'Needs review'),
            ],
          ),
          const SizedBox(height: 8),
          Text(studentName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Learning Passport for $pathwayTitle'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniBadge(label: badgeLevel),
              _MiniBadge(label: '${(readiness * 100).round()}% readiness'),
              _MiniBadge(label: '$completedAssessments completed'),
              _MiniBadge(
                label: canIssue
                    ? 'Export-ready draft'
                    : 'Hold for mentor review',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A calm export layout for local handoff, print, or later PDF generation.',
          ),
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
          Text(
            certificate.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
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
                  Text(
                    hit.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
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
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CopyPathChip extends StatelessWidget {
  const _CopyPathChip({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ActionChip(
        avatar: const Icon(Icons.copy_outlined, size: 16),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip.isEmpty ? label : tooltip,
      child: ActionChip(
        avatar: const Icon(Icons.picture_as_pdf_outlined, size: 16),
        label: Text(label),
        onPressed: onTap,
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
        const _TodoLine(
          'Replace the placeholder Open GAIA route with the real assistant flow when ready.',
        ),
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
