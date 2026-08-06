import 'package:drift/drift.dart';

class UsersDevicesControlRoles extends Table {
  TextColumn get roleName => text().named('role_name')();
  TextColumn get permissionsJson =>
      text().named('permissions_json').withDefault(const Constant('[]'))();
  TextColumn get payloadJson => text().named('payload_json')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {roleName};
}
