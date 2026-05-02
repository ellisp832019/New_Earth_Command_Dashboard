import 'package:drift/drift.dart';

class WellbeingCheckins extends Table {
  TextColumn get wellbeingCheckinId => text().named('wellbeing_checkin_id')();
  DateTimeColumn get date => dateTime()();
  TextColumn get energyLevel => text().named('energy_level').nullable()();
  TextColumn get mood => text().nullable()();
  TextColumn get sleepQuality => text().named('sleep_quality').nullable()();
  TextColumn get stressLevel => text().named('stress_level').nullable()();
  BoolColumn get movementDone =>
      boolean().named('movement_done').withDefault(const Constant(false))();
  BoolColumn get foodWaterOk =>
      boolean().named('food_water_ok').withDefault(const Constant(false))();
  BoolColumn get meditationReflectionDone => boolean()
      .named('meditation_reflection_done')
      .withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get suggestedWorkload =>
      text().named('suggested_workload').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {wellbeingCheckinId};
}
