import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/experiments/data/omega_experiment_models.dart';

void main() {
  test('omega experiment workspace loads seeded experiments and validates ids', () {
    const repository = OmegaExperimentRepository();
    final workspace = repository.loadWorkspace();

    expect(workspace.experiments, hasLength(greaterThanOrEqualTo(5)));
    expect(OmegaExperimentRecord.isValidExperimentId('EXP-0001'), isTrue);
    expect(OmegaExperimentRecord.isValidExperimentId('EXP-12'), isFalse);
    expect(
      workspace.experiments.map((experiment) => experiment.experimentId),
      contains('EXP-0005'),
    );
    final sensorExperiment = workspace.experiments.firstWhere(
      (experiment) => experiment.experimentId == 'EXP-0001',
    );
    expect(sensorExperiment.hasEvidence, isTrue);
    expect(
      workspace.config.isSafePath(
        'D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/_EXPERIMENTS/EXP-0001',
      ),
      isTrue,
    );
    expect(workspace.config.isSafePath('C:/Temp/unsafe'), isFalse);
  });

  test('omega experiment repository creates drafts without overwriting files', () async {
    final tempRoot = Directory.systemTemp.createTempSync('omega-experiment-');
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final existingDraftPath = p.join(
      tempRoot.path,
      'storage',
      'experiments',
      'drafts',
      'EXP-0006_sample_experiment.json',
    );
    File(existingDraftPath).createSync(recursive: true);
    File(existingDraftPath).writeAsStringSync('existing');

    final repository = OmegaExperimentRepository(moduleRootPath: tempRoot.path);
    final draft = OmegaExperimentRecord(
      experimentId: 'EXP-0006',
      title: 'Sample Experiment',
      project: 'MicroGrow',
      projectLink: 'projects/microgrow',
      status: OmegaExperimentStatus.planned,
      category: OmegaExperimentCategory.generalValidation,
      owner: 'Peter Ellis',
      createdDate: '2026-06-16',
      objective: 'Validate safe draft creation.',
      hypothesis: 'Draft writing should avoid overwriting existing files.',
      testPlan: 'Save the draft locally.',
      setupNotes: 'Use a temp workspace.',
      evidenceFiles: const ['evidence/sample.md'],
      measurements: const ['count'],
      softwareUsed: const ['Flutter dashboard'],
      hardwareUsed: const [],
      results: 'Pending.',
      conclusion: 'Pending.',
      lessonLearned: 'Pending.',
      nextActions: const ['Review the saved file'],
      relatedRepoCommits: const ['draft: safe create'],
      relatedGithubIssues: const ['#999'],
      relatedObsidianNotes: const ['Sample note'],
    );

    final savedPath = await repository.createDraft(draft);

    expect(savedPath, isNot(equals(existingDraftPath)));
    expect(File(savedPath).existsSync(), isTrue);
    expect(File(existingDraftPath).readAsStringSync(), equals('existing'));
  });
}
