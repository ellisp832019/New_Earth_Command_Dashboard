import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class WellbeingRepository {
  WellbeingRepository(this._database, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<List<WellbeingCheckin>> getCheckins() {
    return (_database.select(_database.wellbeingCheckins)..orderBy([
          (table) => OrderingTerm.desc(table.date),
          (table) => OrderingTerm.desc(table.createdAt),
        ]))
        .get();
  }

  Future<WellbeingCheckin> createCheckin({
    required DateTime date,
    String? energyLevel,
    String? mood,
    String? sleepQuality,
    String? stressLevel,
    required bool movementDone,
    required bool foodWaterOk,
    required bool meditationReflectionDone,
    String? notes,
  }) async {
    final timestamp = _now();
    final wellbeingCheckinId = 'wellbeing-${_uuid.v4()}';

    await _database
        .into(_database.wellbeingCheckins)
        .insert(
          WellbeingCheckinsCompanion.insert(
            wellbeingCheckinId: wellbeingCheckinId,
            date: _dateOnly(date),
            energyLevel: Value(_normalizeText(energyLevel)),
            mood: Value(_normalizeText(mood)),
            sleepQuality: Value(_normalizeText(sleepQuality)),
            stressLevel: Value(_normalizeText(stressLevel)),
            movementDone: Value(movementDone),
            foodWaterOk: Value(foodWaterOk),
            meditationReflectionDone: Value(meditationReflectionDone),
            notes: Value(_normalizeText(notes)),
            suggestedWorkload: Value(_suggestedWorkload(energyLevel)),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return getById(wellbeingCheckinId);
  }

  Future<WellbeingCheckin> getById(String wellbeingCheckinId) {
    return (_database.select(_database.wellbeingCheckins)..where(
          (table) => table.wellbeingCheckinId.equals(wellbeingCheckinId),
        ))
        .getSingle();
  }

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String? _suggestedWorkload(String? energyLevel) => switch (energyLevel) {
    'Low' => 'Light',
    'Medium' => 'Normal',
    'High' => 'Deep Work',
    _ => null,
  };
}
