import 'package:drift/drift.dart';

class UsersDevicesControlUsers extends Table {
  TextColumn get userId => text().named('user_id')();
  TextColumn get payloadJson => text().named('payload_json')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {userId};
}
