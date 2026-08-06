import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/wellbeing/data/wellbeing_repository.dart';

void main() {
  test('wellbeing repository creates and loads check-ins', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final wellbeingRepository = WellbeingRepository(database);

    final createdCheckin = await wellbeingRepository.createCheckin(
      date: DateTime(2026, 5, 3, 14, 30),
      energyLevel: 'Low',
      mood: 'Tired',
      sleepQuality: 'Medium',
      stressLevel: 'High',
      movementDone: true,
      foodWaterOk: true,
      meditationReflectionDone: false,
      notes: 'Keep the day lighter and avoid unnecessary context switching.',
    );
    final checkins = await wellbeingRepository.getCheckins();

    expect(createdCheckin.energyLevel, 'Low');
    expect(createdCheckin.mood, 'Tired');
    expect(createdCheckin.suggestedWorkload, 'Light');
    expect(checkins, hasLength(1));
    expect(checkins.first.date, DateTime(2026, 5, 3));
    expect(checkins.first.movementDone, isTrue);
    expect(checkins.first.foodWaterOk, isTrue);
    expect(checkins.first.meditationReflectionDone, isFalse);
  });
}
