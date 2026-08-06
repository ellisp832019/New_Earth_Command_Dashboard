import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'package:new_earth_command_dashboard/features/education_learning_hub/application/education_services.dart';
import 'package:new_earth_command_dashboard/features/education_learning_hub/data/education_repository.dart';
import 'package:new_earth_command_dashboard/features/education_learning_hub/domain/education_models.dart';

void main() {
  test('education repository loads the local mock snapshot', () async {
    final repository = LocalEducationRepository();
    final snapshot = await repository.loadSnapshot();

    expect(snapshot.pathwayCount, greaterThanOrEqualTo(5));
    expect(snapshot.lessonCount, greaterThanOrEqualTo(10));
    expect(snapshot.projectCount, greaterThanOrEqualTo(3));
    expect(snapshot.learnerCount, greaterThanOrEqualTo(2));
    expect(snapshot.skillLibrary, isNotEmpty);
    expect(snapshot.contentSources, isNotEmpty);
    expect(
      snapshot.contentSources.where((source) => source.category.isNotEmpty),
      isNotEmpty,
    );
    expect(
      snapshot.progressForProject('project_microgrow_sensor_calibration'),
      isNotEmpty,
    );

    final searchHits = SearchService(snapshot).search('MicroGrow');
    expect(searchHits, isNotEmpty);
    expect(searchHits.first.kind, isNotEmpty);

    final learnerHits = SearchService(snapshot).search('Hayley');
    expect(learnerHits.any((hit) => hit.kind == 'Learner'), isTrue);

    final certificateHits = SearchService(snapshot).search('badge');
    expect(certificateHits.any((hit) => hit.kind == 'Certificate'), isTrue);

    final tutorResponse = TutorService(snapshot).respond(
      'progress',
      learnerName: 'Hayley Arthur',
      pathwayTitle: 'MicroGrow',
      roleLabel: 'Student',
      completionLabel: '50% complete',
    );
    expect(tutorResponse.summary, isNotEmpty);
    expect(tutorResponse.practiceQuestions, isNotEmpty);
    expect(tutorResponse.summary, contains('Hayley Arthur'));
    expect(tutorResponse.nextStep, contains('50% complete'));
  });

  test('education repository persists progress records locally', () async {
    final tempRoot = Directory.systemTemp.createTempSync('education-progress-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final stateFile = path.join(tempRoot.path, 'learning_state.json');
    final repository = LocalEducationRepository(stateFilePath: stateFile);

    final saved = await repository.saveProgressRecord(
      studentId: 'student_hayley',
      entityId: 'lesson_led_calm_build',
      entityType: 'lesson',
      progressPercent: 100,
      status: 'complete',
      note: 'Completed the calm LED build.',
    );

    expect(saved.progressPercent, 100);
    expect(File(stateFile).existsSync(), isTrue);

    final reloaded = await repository.loadSnapshot();
    final progress = reloaded.progressFor(
      'student_hayley',
      'lesson_led_calm_build',
    );
    expect(progress, isNotNull);
    expect(progress?.status, 'complete');
    expect(progress?.note, contains('calm LED build'));
  });

  test('education repository persists reflection entries locally', () async {
    final tempRoot = Directory.systemTemp.createTempSync(
      'education-reflection-',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final repository = LocalEducationRepository(
      stateFilePath: path.join(tempRoot.path, 'learning_state.json'),
    );

    final snapshot = await repository.loadSnapshot();
    final student = snapshot.students.first;
    final lesson = snapshot.lessons.first;
    final project = snapshot.projects.first;
    final saved = await repository.saveReflectionEntry(
      studentId: student.id,
      title: 'Calm build note',
      body: 'The lesson felt steady and the next step is clear.',
      mood: 'Reflective',
      linkedLessonId: lesson.id,
      linkedProjectId: project.id,
    );

    expect(saved.studentId, student.id);
    expect(saved.title, 'Calm build note');
    expect(saved.body, contains('steady'));
    expect(saved.mood, 'Reflective');
    expect(saved.linkedLessonId, lesson.id);
    expect(saved.linkedProjectId, project.id);

    final reloaded = await repository.loadSnapshot();
    final reflection = reloaded.reflections.firstWhere(
      (entry) => entry.id == saved.id,
    );
    expect(reflection.studentId, student.id);
    expect(reflection.title, saved.title);
    expect(reflection.body, saved.body);
    expect(reflection.mood, saved.mood);
    expect(reflection.linkedLessonId, lesson.id);
    expect(reflection.linkedProjectId, project.id);
    expect(reflection.audiences, isNotEmpty);
  });

  test('education repository persists mentor review entries locally', () async {
    final tempRoot = Directory.systemTemp.createTempSync('education-review-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final repository = LocalEducationRepository(
      stateFilePath: path.join(tempRoot.path, 'learning_state.json'),
    );

    final snapshot = await repository.loadSnapshot();
    final student = snapshot.students.first;
    final saved = await repository.saveMentorReview(
      studentId: student.id,
      reviewer: 'Peter Ellis',
      status: 'Ready for sign-off',
      handoffStatus: 'Guardian handoff ready',
      notes: 'Learner is steady and ready for review.',
    );

    expect(saved.studentId, student.id);
    expect(saved.reviewer, 'Peter Ellis');
    expect(saved.status, 'Ready for sign-off');
    expect(saved.handoffStatus, 'Guardian handoff ready');

    final reloaded = await repository.loadSnapshot();
    final review = reloaded
        .reviewsForStudent(student.id)
        .firstWhere((entry) => entry.id == saved.id);
    expect(review.studentId, student.id);
    expect(review.status, saved.status);
    expect(review.handoffStatus, saved.handoffStatus);
    expect(review.notes, saved.notes);
  });

  test(
    'education repository exports and imports a local snapshot bundle',
    () async {
      final tempRoot = Directory.systemTemp.createTempSync('education-bundle-');
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      final exportPath = path.join(
        tempRoot.path,
        'education_snapshot_bundle.json',
      );
      final repository = LocalEducationRepository(
        moduleRootPath: tempRoot.path,
        stateFilePath: path.join(tempRoot.path, 'learning_state.json'),
      );

      final snapshot = await repository.loadSnapshot();
      expect(snapshot.pathwayCount, greaterThan(0));

      final draft = ContentPackDraft(
        title: 'Field Pack',
        version: '1.2.3',
        audience: 'Mentor',
        summary: 'A compact offline pack for field learning and handoff.',
        template: 'mentor_pack',
        validationReady: true,
        validationNotes: 'Ready for export.',
        updatedAt: DateTime.now().toUtc(),
      );
      await repository.saveSnapshot(snapshot.copyWith(contentPackDraft: draft));

      final exported = await repository.exportSnapshotBundle(
        exportPath: exportPath,
      );
      expect(exported.existsSync(), isTrue);

      final imported = await repository.importSnapshotBundle(
        importPath: exportPath,
      );
      expect(imported.pathwayCount, snapshot.pathwayCount);
      expect(imported.lessonCount, snapshot.lessonCount);
      expect(imported.projectCount, snapshot.projectCount);
      expect(imported.contentPackDraft.version, draft.version);
      expect(imported.contentPackDraft.validationReady, isTrue);
      expect(imported.contentPackDraft.bundleId, isNotEmpty);
      expect(imported.contentPackDraft.checksum, isNotEmpty);
    },
  );

  test('education repository exports a content pack draft locally', () async {
    final tempRoot = Directory.systemTemp.createTempSync('education-pack-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final repository = LocalEducationRepository(
      moduleRootPath: tempRoot.path,
      stateFilePath: path.join(tempRoot.path, 'learning_state.json'),
    );

    final snapshot = await repository.loadSnapshot();
    await repository.saveSnapshot(
      snapshot.copyWith(
        contentPackDraft: ContentPackDraft(
          title: 'Field Pack',
          version: '1.0.0',
          audience: 'Admin',
          summary: 'An exportable local pack for field use.',
          template: 'passport_pack',
          validationReady: true,
          validationNotes: 'Ready for local distribution.',
          updatedAt: DateTime.now().toUtc(),
        ),
      ),
    );

    final markdown = await repository.exportContentPackDraft();
    expect(markdown.existsSync(), isTrue);
    expect(await markdown.readAsString(), contains('Field Pack'));
    final pdf = File('${path.withoutExtension(markdown.path)}.pdf');
    expect(pdf.existsSync(), isTrue);
    final manifest = File('${path.withoutExtension(markdown.path)}.json');
    expect(manifest.existsSync(), isTrue);
    final manifestJson =
        jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
    expect(manifestJson['bundleId'], isNotEmpty);
    expect(manifestJson['checksum'], isNotEmpty);
    expect(manifestJson['validationReady'], isTrue);
  });

  test('education repository normalizes invalid content pack drafts', () async {
    final tempRoot = Directory.systemTemp.createTempSync(
      'education-pack-invalid-',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final repository = LocalEducationRepository(
      moduleRootPath: tempRoot.path,
      stateFilePath: path.join(tempRoot.path, 'learning_state.json'),
    );

    final snapshot = await repository.loadSnapshot();
    await repository.saveSnapshot(
      snapshot.copyWith(
        contentPackDraft: ContentPackDraft(
          title: '  ',
          version: 'v2',
          audience: '',
          summary: 'Short summary.',
          template: '',
          validationReady: true,
          validationNotes: 'Should be replaced.',
          updatedAt: DateTime.now().toUtc(),
        ),
      ),
    );

    final reloaded = await repository.loadSnapshot();
    final draft = reloaded.contentPackDraft;
    expect(draft.bundleId, isNotEmpty);
    expect(draft.checksum, isNotEmpty);
    expect(draft.validationReady, isFalse);
    expect(draft.validationNotes, contains('semantic versioning'));
    expect(draft.validationNotes, contains('Choose a primary audience'));
  });

  test('education repository exports mentor reports locally', () async {
    final tempRoot = Directory.systemTemp.createTempSync('education-mentor-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final repository = LocalEducationRepository(
      moduleRootPath: tempRoot.path,
      stateFilePath: path.join(tempRoot.path, 'learning_state.json'),
    );

    final snapshot = await repository.loadSnapshot();
    final student = snapshot.students.first;
    final report = await repository.exportMentorReport(studentId: student.id);

    expect(report.existsSync(), isTrue);
    final text = await report.readAsString();
    expect(text, contains(student.name));
    expect(text, contains('Mentor report'));
    expect(text, contains('Badge readiness'));
    expect(text, contains('Suggested next step'));
  });

  test(
    'education repository issues a draft certificate from assessments',
    () async {
      final tempRoot = Directory.systemTemp.createTempSync(
        'education-certificate-',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      final repository = LocalEducationRepository(
        moduleRootPath: tempRoot.path,
        stateFilePath: path.join(tempRoot.path, 'learning_state.json'),
      );

      final snapshot = await repository.loadSnapshot();
      final student = snapshot.students.firstWhere(
        (profile) =>
            snapshot.completedAssessmentsForStudent(profile.id).isNotEmpty,
        orElse: () => snapshot.students.first,
      );
      final before = snapshot.certificatesForStudent(student.id).length;

      final certificate = await repository.issueCertificateFromAssessments(
        studentId: student.id,
      );

      expect(certificate.studentId, student.id);
      expect(certificate.title, contains(student.name));
      expect(certificate.badgeLevel, isNotEmpty);

      final reloaded = await repository.loadSnapshot();
      final after = reloaded.certificatesForStudent(student.id).length;
      expect(after, before + 1);
      expect(
        reloaded.students
            .firstWhere((profile) => profile.id == student.id)
            .badgeIds,
        contains(certificate.id),
      );

      final pdfPath = path.withoutExtension(
        path.join(
          tempRoot.path,
          '10_LOCAL_FIRST_DATA',
          'exports',
          'certificates',
          '${student.id}_${certificate.id}.md',
        ),
      );
      expect(File('$pdfPath.pdf').existsSync(), isTrue);
    },
  );
}
