import 'package:drift/drift.dart';

class ContentItems extends Table {
  TextColumn get contentItemId => text().named('content_item_id')();
  TextColumn get projectId => text().named('project_id').nullable()();
  TextColumn get journalEntryId =>
      text().named('journal_entry_id').nullable()();
  TextColumn get title => text()();
  TextColumn get platform => text().nullable()();
  TextColumn get contentType => text().named('content_type').nullable()();
  TextColumn get status => text().withDefault(const Constant('Idea'))();
  TextColumn get draftText => text().named('draft_text').nullable()();
  BoolColumn get imageNeeded =>
      boolean().named('image_needed').withDefault(const Constant(false))();
  TextColumn get imagePrompt => text().named('image_prompt').nullable()();
  DateTimeColumn get publishDate =>
      dateTime().named('publish_date').nullable()();
  TextColumn get publishedLink => text().named('published_link').nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {contentItemId};
}
