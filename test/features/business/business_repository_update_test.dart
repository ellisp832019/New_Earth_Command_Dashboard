import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/business/data/business_repository.dart';
import 'package:new_earth_command_dashboard/features/projects/data/project_repository.dart';

void main() {
  test('business repository can update an existing opportunity', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final projectRepository = ProjectRepository(database);
    final businessRepository = BusinessRepository(database);

    final project = await projectRepository.createProject(
      name: 'Update Project',
      status: 'Active',
      priority: 'Medium',
      progressPercentage: 5,
    );

    final created = await businessRepository.createItem(
      name: 'Original Name',
      projectId: project.projectId,
      type: 'Job',
      status: 'Researching',
      companyOrContact: 'ACME',
      deadline: DateTime(2026, 5, 10),
      nextAction: 'Initial step',
      followUpDate: DateTime(2026, 5, 12),
      relatedDocumentLink: 'https://example.com/original',
      notes: 'Original notes',
    );

    final updated = await businessRepository.updateItem(
      businessOpportunityId: created.businessOpportunityId,
      name: 'Updated Name',
      projectId: project.projectId,
      type: 'Contract',
      status: 'Preparing',
      companyOrContact: 'Updated Co',
      deadline: DateTime(2026, 6, 1),
      nextAction: 'Follow up',
      followUpDate: DateTime(2026, 6, 3),
      relatedDocumentLink: 'https://example.com/updated',
      notes: 'Updated notes',
    );

    expect(updated.name, 'Updated Name');
    expect(updated.type, 'Contract');
    expect(updated.status, 'Preparing');
    expect(updated.companyOrContact, 'Updated Co');
    expect(updated.deadline, DateTime(2026, 6, 1));
    expect(updated.nextAction, 'Follow up');
    expect(updated.followUpDate, DateTime(2026, 6, 3));
    expect(updated.relatedDocumentLink, 'https://example.com/updated');
    expect(updated.notes, 'Updated notes');
  });
}
