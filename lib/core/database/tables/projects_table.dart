import 'package:drift/drift.dart';

class Projects extends Table {
  TextColumn get projectId => text().named('project_id')();
  TextColumn get name => text()();
  TextColumn get shortDescription =>
      text().named('short_description').nullable()();
  TextColumn get longDescription =>
      text().named('long_description').nullable()();
  TextColumn get vision => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('Idea'))();
  TextColumn get priority => text().withDefault(const Constant('Medium'))();
  IntColumn get progressPercentage =>
      integer().named('progress_percentage').withDefault(const Constant(0))();
  TextColumn get currentMilestone =>
      text().named('current_milestone').nullable()();
  TextColumn get nextAction => text().named('next_action').nullable()();
  DateTimeColumn get startDate => dateTime().named('start_date').nullable()();
  DateTimeColumn get targetDate => dateTime().named('target_date').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {projectId};
}
