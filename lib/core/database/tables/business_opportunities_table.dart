import 'package:drift/drift.dart';

class BusinessOpportunities extends Table {
  TextColumn get businessOpportunityId =>
      text().named('business_opportunity_id')();
  TextColumn get projectId => text().named('project_id').nullable()();
  TextColumn get name => text()();
  TextColumn get type => text().nullable()();
  TextColumn get companyOrContact =>
      text().named('company_or_contact').nullable()();
  TextColumn get status => text().withDefault(const Constant('Researching'))();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get nextAction => text().named('next_action').nullable()();
  DateTimeColumn get followUpDate =>
      dateTime().named('follow_up_date').nullable()();
  TextColumn get relatedDocumentLink =>
      text().named('related_document_link').nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {businessOpportunityId};
}
