import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'package:new_earth_command_dashboard/features/education_learning_hub/application/education_services.dart';
import 'package:new_earth_command_dashboard/features/education_learning_hub/data/education_repository.dart';

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
    final progress = reloaded.progressFor('student_hayley', 'lesson_led_calm_build');
    expect(progress, isNotNull);
    expect(progress?.status, 'complete');
    expect(progress?.note, contains('calm LED build'));
  });

  test('education repository exports and imports a local snapshot bundle', () async {
    final tempRoot = Directory.systemTemp.createTempSync('education-bundle-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final exportPath = path.join(tempRoot.path, 'education_snapshot_bundle.json');
    final repository = LocalEducationRepository(
      moduleRootPath: tempRoot.path,
      stateFilePath: path.join(tempRoot.path, 'learning_state.json'),
    );

    final snapshot = await repository.loadSnapshot();
    expect(snapshot.pathwayCount, greaterThan(0));

    final exported = await repository.exportSnapshotBundle(exportPath: exportPath);
    expect(exported.existsSync(), isTrue);

    final imported = await repository.importSnapshotBundle(importPath: exportPath);
    expect(imported.pathwayCount, snapshot.pathwayCount);
    expect(imported.lessonCount, snapshot.lessonCount);
    expect(imported.projectCount, snapshot.projectCount);
  });
}
