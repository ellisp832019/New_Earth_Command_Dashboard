import 'package:drift/drift.dart';

class InboxItems extends Table {
  TextColumn get inboxItemId => text().named('inbox_item_id')();
  TextColumn get title => text().nullable()();
  TextColumn get body => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get projectId => text().named('project_id').nullable()();
  TextColumn get status => text().withDefault(const Constant('New'))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get processedAt =>
      dateTime().named('processed_at').nullable()();
  TextColumn get convertedToType =>
      text().named('converted_to_type').nullable()();
  TextColumn get convertedToId => text().named('converted_to_id').nullable()();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {inboxItemId};
}
