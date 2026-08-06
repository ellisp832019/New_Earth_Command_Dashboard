import 'package:drift/drift.dart';

class VoiceModulePreferences extends Table {
  TextColumn get preferenceId => text().named('preference_id')();
  TextColumn get providerMode => text().named('provider_mode')();
  TextColumn get featureFlagsJson => text().named('feature_flags_json')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {preferenceId};
}
