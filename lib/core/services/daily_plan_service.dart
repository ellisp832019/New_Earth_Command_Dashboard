import '../database/app_database.dart';

class DailyPlanService {
  const DailyPlanService(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  Future<void> ensureTodayPlan() async {
    await ensurePlanForDate(_now());
  }

  Future<void> ensurePlanForDate(DateTime date) async {
    final planDate = _dateOnly(date);
    final existingPlan = await (_database.select(
      _database.dailyPlans,
    )..where((table) => table.date.equals(planDate))).getSingleOrNull();
    if (existingPlan != null) {
      return;
    }

    final timestamp = _now();
    await _database
        .into(_database.dailyPlans)
        .insert(
          DailyPlansCompanion.insert(
            dailyPlanId: _dailyPlanIdForDate(planDate),
            date: planDate,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dailyPlanIdForDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'daily-plan-$year-$month-$day';
  }
}
