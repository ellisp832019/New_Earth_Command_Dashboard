import '../domain/education_models.dart';

class EducationSearchHit {
  const EducationSearchHit({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.needle,
  });

  final String title;
  final String subtitle;
  final String kind;
  final String needle;
}

class EducationTutorResponse {
  const EducationTutorResponse({
    required this.summary,
    required this.nextStep,
    required this.safetyNote,
    required this.practiceQuestions,
  });

  final String summary;
  final String nextStep;
  final String safetyNote;
  final List<String> practiceQuestions;
}

class LearningPathwayService {
  const LearningPathwayService(this.snapshot);

  final EducationHubSnapshot snapshot;

  List<LearningPathway> pathwaysForAudience(EducationAudience audience) {
    return snapshot.pathways.where((pathway) {
      if (audience == EducationAudience.all) {
        return true;
      }
      return pathway.audiences.contains(audience.name);
    }).toList(growable: false);
  }

  LearningPathway? pathwayById(String id) {
    for (final pathway in snapshot.pathways) {
      if (pathway.id == id) {
        return pathway;
      }
    }
    return null;
  }
}

class LessonService {
  const LessonService(this.snapshot);

  final EducationHubSnapshot snapshot;

  List<Lesson> lessonsForAudience(EducationAudience audience) {
    return snapshot.lessons.where((lesson) {
      if (audience == EducationAudience.all) {
        return true;
      }
      return lesson.audiences.contains(audience.name);
    }).toList(growable: false);
  }
}

class ProgressService {
  const ProgressService(this.snapshot);

  final EducationHubSnapshot snapshot;

  double completionForStudent(String studentId) {
    final progress = snapshot.progressForStudent(studentId);
    if (progress.isEmpty) {
      return 0;
    }
    final total = progress.fold<int>(
      0,
      (sum, record) => sum + record.progressPercent,
    );
    return total / (progress.length * 100);
  }
}

class AssessmentService {
  const AssessmentService(this.snapshot);

  final EducationHubSnapshot snapshot;

  List<Assessment> assessmentsForAudience(EducationAudience audience) {
    return snapshot.assessments.where((assessment) {
      if (audience == EducationAudience.all) {
        return true;
      }
      return assessment.audiences.contains(audience.name);
    }).toList(growable: false);
  }
}

class ReflectionService {
  const ReflectionService(this.snapshot);

  final EducationHubSnapshot snapshot;

  List<ReflectionEntry> reflectionsForAudience(EducationAudience audience) {
    return snapshot.reflections.where((reflection) {
      if (audience == EducationAudience.all) {
        return true;
      }
      return reflection.audiences.contains(audience.name);
    }).toList(growable: false);
  }
}

class CertificateService {
  const CertificateService(this.snapshot);

  final EducationHubSnapshot snapshot;

  List<Certificate> certificatesForAudience(EducationAudience audience) {
    return snapshot.certificates.where((certificate) {
      if (audience == EducationAudience.all) {
        return true;
      }
      final student = snapshot.students
          .where((profile) => profile.id == certificate.studentId)
          .cast<StudentProfile?>()
          .firstOrNull;
      return student == null || student.badgeIds.isNotEmpty;
    }).toList(growable: false);
  }
}

class SearchService {
  const SearchService(this.snapshot);

  final EducationHubSnapshot snapshot;

  List<EducationSearchHit> search(
    String query, {
    EducationAudience audience = EducationAudience.all,
  }) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return const [];
    }

    final hits = <EducationSearchHit>[];

    for (final pathway in snapshot.pathways) {
      if (!_matchesAudience(pathway.audiences, audience)) {
        continue;
      }
      if (_contains(needle, [pathway.title, pathway.summary, pathway.domain])) {
        hits.add(
          EducationSearchHit(
            title: pathway.title,
            subtitle: pathway.summary,
            kind: 'Pathway',
            needle: pathway.domain,
          ),
        );
      }
    }

    for (final lesson in snapshot.lessons) {
      if (!_matchesAudience(lesson.audiences, audience)) {
        continue;
      }
      if (_contains(needle, [lesson.title, lesson.summary, lesson.objective])) {
        hits.add(
          EducationSearchHit(
            title: lesson.title,
            subtitle: lesson.summary,
            kind: 'Lesson',
            needle: lesson.difficulty,
          ),
        );
      }
    }

    for (final project in snapshot.projects) {
      if (!_matchesAudience(project.audiences, audience)) {
        continue;
      }
      if (_contains(needle, [project.title, project.summary, project.domain])) {
        hits.add(
          EducationSearchHit(
            title: project.title,
            subtitle: project.summary,
            kind: 'Project',
            needle: project.domain,
          ),
        );
      }
    }

    for (final resource in snapshot.resources) {
      if (_contains(needle, [resource.title, resource.description, resource.path])) {
        hits.add(
          EducationSearchHit(
            title: resource.title,
            subtitle: resource.description,
            kind: 'Resource',
            needle: resource.category,
          ),
        );
      }
    }

    for (final source in snapshot.contentSources) {
      if (_contains(needle, [source.title, source.description, source.path])) {
        hits.add(
          EducationSearchHit(
            title: source.title,
            subtitle: source.description,
            kind: 'Source',
            needle: source.category,
          ),
        );
      }
    }

    for (final student in snapshot.students) {
      if (_contains(
        needle,
        [
          student.name,
          student.role,
          student.stage,
          student.mentorName,
          student.guardianName,
          student.activePathwayId,
          ...student.badgeIds,
        ],
      )) {
        hits.add(
          EducationSearchHit(
            title: student.name,
            subtitle: '${student.role} • ${student.stage}',
            kind: 'Learner',
            needle: student.activePathwayId,
          ),
        );
      }
    }

    for (final assessment in snapshot.assessments) {
      if (_contains(
        needle,
        [
          assessment.title,
          assessment.summary,
          assessment.kind,
          assessment.mentorFeedback,
          ...assessment.criteria,
        ],
      )) {
        hits.add(
          EducationSearchHit(
            title: assessment.title,
            subtitle: assessment.summary,
            kind: 'Assessment',
            needle: assessment.kind,
          ),
        );
      }
    }

    for (final reflection in snapshot.reflections) {
      if (_contains(needle, [reflection.title, reflection.body, reflection.mood])) {
        hits.add(
          EducationSearchHit(
            title: reflection.title,
            subtitle: reflection.body,
            kind: 'Reflection',
            needle: reflection.mood,
          ),
        );
      }
    }

    for (final certificate in snapshot.certificates) {
      if (_contains(
        needle,
        [
          certificate.title,
          certificate.summary,
          certificate.badgeLevel,
          certificate.issuedBy,
        ],
      )) {
        hits.add(
          EducationSearchHit(
            title: certificate.title,
            subtitle: certificate.summary,
            kind: 'Certificate',
            needle: certificate.badgeLevel,
          ),
        );
      }
    }

    for (final note in snapshot.mentorNotes) {
      if (_contains(needle, [note.author, note.content, note.priority])) {
        hits.add(
          EducationSearchHit(
            title: note.author,
            subtitle: note.content,
            kind: 'Mentor note',
            needle: note.priority,
          ),
        );
      }
    }

    return hits.toList(growable: false);
  }

  bool _matchesAudience(List<String> audiences, EducationAudience audience) {
    if (audience == EducationAudience.all) {
      return true;
    }
    return audiences.contains(audience.name);
  }

  bool _contains(String needle, List<String> fields) {
    for (final field in fields) {
      if (field.toLowerCase().contains(needle)) {
        return true;
      }
    }
    return false;
  }
}

class TutorService {
  const TutorService(this.snapshot);

  final EducationHubSnapshot snapshot;

  EducationTutorResponse respond(
    String prompt, {
    String learnerName = '',
    String pathwayTitle = '',
    String roleLabel = '',
    String completionLabel = '',
  }) {
    final normalized = prompt.trim().toLowerCase();
    final contextLabel = [
      if (learnerName.trim().isNotEmpty) learnerName.trim(),
      if (roleLabel.trim().isNotEmpty) roleLabel.trim(),
      if (pathwayTitle.trim().isNotEmpty) pathwayTitle.trim(),
    ].join(' • ');

    if (normalized.isEmpty) {
      return EducationTutorResponse(
        summary: contextLabel.isEmpty
            ? 'Ask a practical learning question and the tutor will suggest a calm next step.'
            : 'Ask a practical learning question for $contextLabel and the tutor will suggest a calm next step.',
        nextStep: completionLabel.isEmpty
            ? 'Try asking about a lesson, a project, or a build obstacle.'
            : 'Try asking about a lesson, a project, or the current ${completionLabel.toLowerCase()}.',
        safetyNote: 'The tutor stays in suggestion mode only and keeps a human in the loop.',
        practiceQuestions: [
          'What do you want to understand?',
          'What have you already tried?',
        ],
      );
    }

    final match = snapshot.lessons
        .where(
          (lesson) =>
              lesson.title.toLowerCase().contains(normalized) ||
              lesson.summary.toLowerCase().contains(normalized),
        )
        .cast<Lesson?>()
        .firstOrNull;

    if (match != null) {
      return EducationTutorResponse(
        summary: contextLabel.isEmpty
            ? 'Here is a calm way to approach "${match.title}": ${match.summary}'
            : 'Here is a calm way for $contextLabel to approach "${match.title}": ${match.summary}',
        nextStep: completionLabel.isEmpty
            ? 'Work through one step, then write one short reflection.'
            : 'Keep the next step short, then capture how it changes $completionLabel.',
        safetyNote:
            'This is a teaching prompt only. Check anything important with a mentor or guardian.',
        practiceQuestions: [
          'What is the first small action?',
          'What would success look like after 10 minutes?',
          'What evidence will you save?',
        ],
      );
    }

    if (normalized.contains('pathway') || normalized.contains('route')) {
      return EducationTutorResponse(
        summary: contextLabel.isEmpty
            ? 'Use the pathway view to choose one route and move only one step forward.'
            : 'Use the pathway view for $contextLabel to choose one route and move only one step forward.',
        nextStep: 'Open the matching pathway, review the unit list, and select the next lesson.',
        safetyNote:
            'The tutor keeps recommendations local and avoids making decisions for the learner.',
        practiceQuestions: [
          'Which pathway fits the current goal?',
          'What is the next unit to open?',
          'What evidence should be saved after the step?',
        ],
      );
    }

    if (normalized.contains('progress') || normalized.contains('badge') || normalized.contains('certificate')) {
      return EducationTutorResponse(
        summary: contextLabel.isEmpty
            ? 'Progress is tracked locally, so the next useful action is to complete one visible step.'
            : 'Progress for $contextLabel is tracked locally, so the next useful action is to complete one visible step.',
        nextStep: completionLabel.isEmpty
            ? 'Mark one lesson or project complete, then review the passport tab.'
            : 'Use the current ${completionLabel.toLowerCase()} snapshot to choose a small completion step.',
        safetyNote:
            'Badges stay human-reviewed until a mentor, guardian, or admin signs off.',
        practiceQuestions: [
          'What is already complete?',
          'What still needs mentor sign-off?',
          'Which badge feels closest to ready?',
        ],
      );
    }

    if (normalized.contains('mentor') || normalized.contains('guardian') || normalized.contains('support')) {
      return EducationTutorResponse(
        summary: contextLabel.isEmpty
            ? 'Mentor support should stay calm, specific, and tied to one practical outcome.'
            : 'For $contextLabel, mentor support should stay calm, specific, and tied to one practical outcome.',
        nextStep: 'Review one note, one assessment, and one support action before changing the plan.',
        safetyNote:
            'Keep any important learner support decisions human-reviewed and documented locally.',
        practiceQuestions: [
          'What support would help most right now?',
          'What should be left alone for now?',
          'What would a helpful mentor note say?',
        ],
      );
    }

    return EducationTutorResponse(
      summary: contextLabel.isEmpty
          ? 'I could not match that directly, but I can still help you plan a simple next step.'
          : 'I could not match that directly for $contextLabel, but I can still help you plan a simple next step.',
      nextStep: completionLabel.isEmpty
          ? 'Break the task into one observation, one action, and one reflection.'
          : 'Use the current ${completionLabel.toLowerCase()} state to choose one observation, one action, and one reflection.',
      safetyNote:
          'The AI tutor stays advisory and does not replace a mentor or adult supervisor.',
      practiceQuestions: [
        'What are you trying to learn?',
        'Which pathway or project does it belong to?',
        'What is the smallest safe next action?',
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
