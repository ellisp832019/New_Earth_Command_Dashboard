import 'package:drift/drift.dart';

class Tasks extends Table {
  TextColumn get taskId => text().named('task_id')();
  TextColumn get projectId => text().named('project_id').nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get priority => text().withDefault(const Constant('Medium'))();
  TextColumn get status => text().withDefault(const Constant('Inbox'))();
  DateTimeColumn get dueDate => dateTime().named('due_date').nullable()();
  TextColumn get energyLevel => text().named('energy_level').nullable()();
  IntColumn get estimatedMinutes =>
      integer().named('estimated_minutes').nullable()();
  IntColumn get actualMinutes => integer().named('actual_minutes').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isTopThree =>
      boolean().named('is_top_three').withDefault(const Constant(false))();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {taskId};
}
