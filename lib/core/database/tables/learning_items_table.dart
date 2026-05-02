import 'package:drift/drift.dart';

class LearningItems extends Table {
  TextColumn get learningItemId => text().named('learning_item_id')();
  TextColumn get projectId => text().named('project_id').nullable()();
  TextColumn get topic => text()();
  TextColumn get reasonForLearning =>
      text().named('reason_for_learning').nullable()();
  TextColumn get resourceLink => text().named('resource_link').nullable()();
  TextColumn get status => text().withDefault(const Constant('To Learn'))();
  TextColumn get notes => text().nullable()();
  TextColumn get practiceTaskId =>
      text().named('practice_task_id').nullable()();
  TextColumn get nextStep => text().named('next_step').nullable()();
  TextColumn get skillConfidence =>
      text().named('skill_confidence').nullable()();
  DateTimeColumn get dateStarted =>
      dateTime().named('date_started').nullable()();
  DateTimeColumn get dateApplied =>
      dateTime().named('date_applied').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {learningItemId};
}
