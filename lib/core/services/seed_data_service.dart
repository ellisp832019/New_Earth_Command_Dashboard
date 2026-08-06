import 'package:drift/drift.dart';

import '../constants/default_seed_data.dart';
import '../database/app_database.dart';

class SeedDataService {
  const SeedDataService(this._database);

  final AppDatabase _database;

  Future<void> ensureSeedData() async {
    await _database.transaction(() async {
      await _seedProjects();
      await _seedTasks();
      await _seedSettings();
    });
  }

  Future<void> _seedProjects() async {
    final existingProjects = await _database.select(_database.projects).get();
    final existingProjectIds = existingProjects
        .map((project) => project.projectId)
        .toSet();
    final missingProjects = DefaultSeedData.projects
        .where((project) => !existingProjectIds.contains(project.id))
        .toList();
    if (missingProjects.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _database.batch((batch) {
      batch.insertAll(
        _database.projects,
        missingProjects.map((project) {
          return ProjectsCompanion.insert(
            projectId: project.id,
            name: project.name,
            shortDescription: Value(project.shortDescription),
            vision: Value(project.vision),
            status: Value(project.status),
            priority: Value(project.priority),
            currentMilestone: Value(project.currentMilestone),
            nextAction: Value(project.nextAction),
            createdAt: now,
            updatedAt: now,
          );
        }).toList(),
      );
    });
  }

  Future<void> _seedTasks() async {
    final existingTasks = await _database.select(_database.tasks).get();
    final existingTaskIds = existingTasks.map((task) => task.taskId).toSet();
    final missingTasks = DefaultSeedData.futureTasks
        .where((task) => !existingTaskIds.contains(task.id))
        .toList();
    if (missingTasks.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _database.batch((batch) {
      batch.insertAll(
        _database.tasks,
        missingTasks.map((task) {
          return TasksCompanion.insert(
            taskId: task.id,
            projectId: Value(task.projectId),
            title: task.title,
            description: Value(task.description),
            category: Value(task.category),
            priority: Value(task.priority),
            status: Value(task.status),
            createdAt: now,
            updatedAt: now,
          );
        }).toList(),
      );
    });
  }

  Future<void> _seedSettings() async {
    final settings =
        await (_database.select(_database.appSettings)..where(
              (table) => table.settingsId.equals(DefaultSeedData.settingsId),
            ))
            .getSingleOrNull();
    if (settings != null) {
      return;
    }

    final now = DateTime.now();
    await _database
        .into(_database.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            settingsId: DefaultSeedData.settingsId,
            themeMode: const Value('System'),
            defaultDashboardView: const Value('Dashboard'),
            showWellbeingCard: const Value(true),
            showBusinessCard: const Value(true),
            showLearningCard: const Value(true),
            showContentCard: const Value(true),
            showProjectsWorkspaceSnapshot: const Value(true),
            showDockOverlays: const Value(true),
            showBackupGuardianDock: const Value(true),
            showTreasuryDock: const Value(true),
            showKnowledgeLibraryDock: const Value(true),
            showVoiceConversationDock: const Value(true),
            showVoicePresenceChip: const Value(true),
            dailyTopTaskLimit: const Value(3),
            voiceRepliesEnabled: const Value(true),
            preferredTtsVoiceName: const Value(null),
            preferredTtsVoiceLocale: const Value(null),
            preferredTtsVoiceGender: const Value(null),
            preferredTtsVoiceIdentifier: const Value(null),
            preferredTtsVoiceRate: const Value(0.5),
            preferredTtsVoicePitch: const Value(1.0),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }
}
