import 'package:drift/drift.dart';

class JournalEntries extends Table {
  TextColumn get journalEntryId => text().named('journal_entry_id')();
  TextColumn get projectId => text().named('project_id').nullable()();
  TextColumn get taskId => text().named('task_id').nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text()();
  TextColumn get category => text().nullable()();
  TextColumn get whatIWorkedOn => text().named('what_i_worked_on').nullable()();
  TextColumn get whatIBuilt => text().named('what_i_built').nullable()();
  TextColumn get whatILearned => text().named('what_i_learned').nullable()();
  TextColumn get problemsEncountered =>
      text().named('problems_encountered').nullable()();
  TextColumn get decisionsMade => text().named('decisions_made').nullable()();
  TextColumn get nextActions => text().named('next_actions').nullable()();
  BoolColumn get possibleLinkedinPost => boolean()
      .named('possible_linkedin_post')
      .withDefault(const Constant(false))();
  BoolColumn get possibleWebsiteEntry => boolean()
      .named('possible_website_entry')
      .withDefault(const Constant(false))();
  TextColumn get tags => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {journalEntryId};
}
