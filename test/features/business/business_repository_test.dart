import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

void main() {
  test('business repository creates and loads linked opportunities', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final businessRepository = BusinessRepository(database);
    final project = await projectRepository.createProject(
      name: 'Business Project',
      status: 'Active',
      priority: 'High',
      progressPercentage: 8,
    );

    final createdItem = await businessRepository.createItem(
      name: 'AI Architect Role',
      projectId: project.projectId,
      type: 'Job',
      status: 'Preparing',
      companyOrContact: 'OpenAI',
      deadline: DateTime(2026, 5, 10),
      nextAction: 'Finalise CV',
      followUpDate: DateTime(2026, 5, 12),
      relatedDocumentLink: 'https://example.com/cv',
      notes: 'Keep the application grounded and sharp.',
    );
    final items = await businessRepository.getItems();

    expect(createdItem.name, 'AI Architect Role');
    expect(items, hasLength(1));
    expect(items.first.item.name, 'AI Architect Role');
    expect(items.first.item.type, 'Job');
    expect(items.first.item.status, 'Preparing');
    expect(items.first.item.companyOrContact, 'OpenAI');
    expect(items.first.item.deadline, DateTime(2026, 5, 10));
    expect(items.first.item.followUpDate, DateTime(2026, 5, 12));
    expect(items.first.projectName, 'Business Project');
  });
}
