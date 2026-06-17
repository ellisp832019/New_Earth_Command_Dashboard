import 'package:drift/drift.dart';

class UsersDevicesControlAccessRules extends Table {
  TextColumn get moduleId => text().named('module_id')();
  TextColumn get viewPermission =>
      text().named('view_permission').withDefault(const Constant(''))();
  TextColumn get editPermission =>
      text().named('edit_permission').withDefault(const Constant(''))();
  TextColumn get adminPermission =>
      text().named('admin_permission').withDefault(const Constant(''))();
  TextColumn get requestPermission =>
      text().named('request_permission').withDefault(const Constant(''))();
  TextColumn get executePermission =>
      text().named('execute_permission').withDefault(const Constant(''))();
  TextColumn get controlPermission =>
      text().named('control_permission').withDefault(const Constant(''))();
  IntColumn get requiresTrustLevel =>
      integer().named('requires_trust_level').withDefault(const Constant(0))();
  TextColumn get requiresApprovalForJson =>
      text().named('requires_approval_for_json').withDefault(const Constant('[]'))();
  TextColumn get payloadJson => text().named('payload_json')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {moduleId};
}
