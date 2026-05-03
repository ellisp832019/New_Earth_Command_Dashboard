import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/learning/data/learning_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

void main() {
  test('learning repository creates and loads linked learning items', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final learningRepository = LearningRepository(database);
    final project = await projectRepository.createProject(
      name: 'Learning Project',
      status: 'Active',
      priority: 'High',
      progressPercentage: 15,
    );

    final createdItem = await learningRepository.createItem(
      topic: 'Flutter Drift Database',
      projectId: project.projectId,
      reasonForLearning: 'The dashboard needs reliable local persistence.',
      resourceLink: 'https://drift.simonbinder.eu',
      status: 'Learning',
      notes: 'Start with the create and list flow.',
      nextStep: 'Build the first repository methods.',
      skillConfidence: 'Medium',
    );
    final items = await learningRepository.getItems();

    expect(createdItem.topic, 'Flutter Drift Database');
    expect(items, hasLength(1));
    expect(items.first.item.topic, 'Flutter Drift Database');
    expect(items.first.item.status, 'Learning');
    expect(items.first.item.skillConfidence, 'Medium');
    expect(items.first.projectName, 'Learning Project');
    expect(items.first.item.nextStep, 'Build the first repository methods.');
  });
}
