import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.date,
    required this.hasTodayPlan,
    required this.activeProjectCount,
    required this.topTaskTitles,
    this.mainFocus,
    this.morningIntention,
  });

  final DateTime date;
  final bool hasTodayPlan;
  final int activeProjectCount;
  final List<String> topTaskTitles;
  final String? mainFocus;
  final String? morningIntention;
}

class DashboardRepository {
  DashboardRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  Future<DashboardSnapshot> loadTodaySnapshot() async {
    final today = _dateOnly(_now());
    final todayPlan = await (_database.select(
      _database.dailyPlans,
    )..where((table) => table.date.equals(today))).getSingleOrNull();
    final activeProjectCount = await _activeProjectCount();
    final topTaskTitles = await _topTaskTitles();

    return DashboardSnapshot(
      date: today,
      hasTodayPlan: todayPlan != null,
      mainFocus: todayPlan?.mainFocus,
      morningIntention: todayPlan?.morningIntention,
      activeProjectCount: activeProjectCount,
      topTaskTitles: topTaskTitles,
    );
  }

  Future<int> _activeProjectCount() async {
    final countExpression = _database.projects.projectId.count();
    final row =
        await (_database.selectOnly(_database.projects)
              ..addColumns([countExpression])
              ..where(_database.projects.isArchived.equals(false)))
            .getSingle();

    return row.read(countExpression) ?? 0;
  }

  Future<List<String>> _topTaskTitles() async {
    final tasks =
        await (_database.select(_database.tasks)
              ..where(
                (table) =>
                    table.isArchived.equals(false) &
                    table.isTopThree.equals(true),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();

    return tasks.map((task) => task.title).toList();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
