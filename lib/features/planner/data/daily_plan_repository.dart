import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class DailyPlanRepository {
  DailyPlanRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  Future<DailyPlan> getTodayPlan() async {
    final today = DateTime(_now().year, _now().month, _now().day);

    return (_database.select(
      _database.dailyPlans,
    )..where((table) => table.date.equals(today))).getSingle();
  }

  Future<void> updateMorningIntention(String value) async {
    await _updateTodayPlan(
      DailyPlansCompanion(
        morningIntention: Value(_normalizeText(value)),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> updateMainFocus(String value) async {
    await _updateTodayPlan(
      DailyPlansCompanion(
        mainFocus: Value(_normalizeText(value)),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> _updateTodayPlan(DailyPlansCompanion companion) async {
    final todayPlan = await getTodayPlan();

    await (_database.update(_database.dailyPlans)
          ..where((table) => table.dailyPlanId.equals(todayPlan.dailyPlanId)))
        .write(companion);
  }

  String? _normalizeText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
