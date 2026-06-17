import 'package:drift/drift.dart';

class UsersDevicesControlTrustLevels extends Table {
  IntColumn get trustLevel => integer().named('trust_level')();
  TextColumn get payloadJson => text().named('payload_json')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {trustLevel};
}
