import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class TaskRepository {
  TaskRepository(this._database, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<Task> createTask({
    required String title,
    String? projectId,
    String? description,
    String? category,
    String priority = 'Medium',
    String status = 'Inbox',
    DateTime? dueDate,
    String? energyLevel,
    int? estimatedMinutes,
    String? notes,
  }) async {
    final timestamp = _now();
    final taskId = 'task-${_uuid.v4()}';
    final isCompleted = status == 'Done';

    await _database
        .into(_database.tasks)
        .insert(
          TasksCompanion.insert(
            taskId: taskId,
            projectId: Value(projectId),
            title: title,
            description: Value(description),
            category: Value(category),
            priority: Value(priority),
            status: Value(status),
            dueDate: Value(dueDate),
            energyLevel: Value(energyLevel),
            estimatedMinutes: Value(estimatedMinutes),
            notes: Value(notes),
            completedAt: Value(isCompleted ? timestamp : null),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return getById(taskId);
  }

  Future<Task> getById(String taskId) {
    return (_database.select(
      _database.tasks,
    )..where((table) => table.taskId.equals(taskId))).getSingle();
  }

  Future<Task> updateTask({
    required String taskId,
    required String title,
    String? projectId,
    String? description,
    String? category,
    required String priority,
    required String status,
    String? energyLevel,
    int? estimatedMinutes,
    String? notes,
  }) async {
    final existing = await getById(taskId);
    final timestamp = _now();
    final isCompleted = status == 'Done';
    final isParked = status == 'Parked';

    await (_database.update(
      _database.tasks,
    )..where((table) => table.taskId.equals(taskId))).write(
      TasksCompanion(
        projectId: Value(projectId),
        title: Value(title),
        description: Value(description),
        category: Value(category),
        priority: Value(priority),
        status: Value(status),
        energyLevel: Value(energyLevel),
        estimatedMinutes: Value(estimatedMinutes),
        notes: Value(notes),
        completedAt: Value(
          isCompleted ? (existing.completedAt ?? timestamp) : null,
        ),
        isTopThree: Value(
          isCompleted || isParked ? false : existing.isTopThree,
        ),
        updatedAt: Value(timestamp),
      ),
    );

    return getById(taskId);
  }

  Future<List<Task>> getActiveTasks() {
    return (_database.select(_database.tasks)
          ..where((table) => table.isArchived.equals(false))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
  }

  Future<List<Task>> getTopThreeTasks() {
    return (_database.select(_database.tasks)
          ..where(
            (table) =>
                table.isArchived.equals(false) & table.isTopThree.equals(true),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
  }

  Future<void> markDone(String taskId) async {
    final timestamp = _now();
    await (_database.update(
      _database.tasks,
    )..where((table) => table.taskId.equals(taskId))).write(
      TasksCompanion(
        status: const Value('Done'),
        completedAt: Value(timestamp),
        updatedAt: Value(timestamp),
        isTopThree: const Value(false),
      ),
    );
  }

  Future<void> moveToToday(String taskId) async {
    final timestamp = _now();
    await (_database.update(
      _database.tasks,
    )..where((table) => table.taskId.equals(taskId))).write(
      TasksCompanion(status: const Value('Today'), updatedAt: Value(timestamp)),
    );
  }

  Future<void> parkTask(String taskId) async {
    final timestamp = _now();
    await (_database.update(
      _database.tasks,
    )..where((table) => table.taskId.equals(taskId))).write(
      TasksCompanion(
        status: const Value('Parked'),
        updatedAt: Value(timestamp),
        isTopThree: const Value(false),
      ),
    );
  }

  Future<void> archiveTask(String taskId) async {
    final timestamp = _now();
    await (_database.update(
      _database.tasks,
    )..where((table) => table.taskId.equals(taskId))).write(
      TasksCompanion(
        isArchived: const Value(true),
        isTopThree: const Value(false),
        updatedAt: Value(timestamp),
      ),
    );
  }

  Future<void> setTopThree(String taskId, {required bool isTopThree}) async {
    await (_database.update(
      _database.tasks,
    )..where((table) => table.taskId.equals(taskId))).write(
      TasksCompanion(isTopThree: Value(isTopThree), updatedAt: Value(_now())),
    );
  }
}
