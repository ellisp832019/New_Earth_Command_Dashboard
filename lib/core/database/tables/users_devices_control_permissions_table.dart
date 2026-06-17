import 'package:drift/drift.dart';

class UsersDevicesControlPermissions extends Table {
  TextColumn get permissionName => text().named('permission_name')();
  TextColumn get payloadJson => text().named('payload_json')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {permissionName};
}
