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

  Future<void> updateFocusReason(String value) async {
    await _updateTodayPlan(
      DailyPlansCompanion(
        focusReason: Value(_normalizeText(value)),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> updateCarryForwardNotes(String value) async {
    await _updateTodayPlan(
      DailyPlansCompanion(
        carryForwardNotes: Value(_normalizeText(value)),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> updateTomorrowFocus(String value) async {
    await _updateTodayPlan(
      DailyPlansCompanion(
        tomorrowFocus: Value(_normalizeText(value)),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> updateEveningReview({
    required String movedForward,
    required String completed,
    required String learned,
    required String blockers,
  }) async {
    final normalizedMovedForward = _normalizeText(movedForward);
    final normalizedCompleted = _normalizeText(completed);
    final normalizedLearned = _normalizeText(learned);
    final normalizedBlockers = _normalizeText(blockers);

    await _updateTodayPlan(
      DailyPlansCompanion(
        whatMovedForward: Value(normalizedMovedForward),
        whatWasCompleted: Value(normalizedCompleted),
        whatWasLearned: Value(normalizedLearned),
        blockers: Value(normalizedBlockers),
        eveningReview: Value(
          _buildEveningReviewSummary(
            movedForward: normalizedMovedForward,
            completed: normalizedCompleted,
            learned: normalizedLearned,
            blockers: normalizedBlockers,
          ),
        ),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> clearFocus() async {
    await _updateTodayPlan(
      DailyPlansCompanion(
        mainFocus: const Value(null),
        focusReason: const Value(null),
        morningIntention: const Value(null),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> saveTopThreeTaskIds(List<String> taskIds) async {
    final normalizedTaskIds = _normalizeTaskIds(taskIds);
    if (normalizedTaskIds.length > 3) {
      throw StateError(
        'You already have 3 priority tasks for today. Complete, remove, or carry one forward first.',
      );
    }

    final todayPlan = await getTodayPlan();
    final previousTopTaskIds = [
      todayPlan.topTask1Id,
      todayPlan.topTask2Id,
      todayPlan.topTask3Id,
    ].whereType<String>().toList();

    await _database.transaction(() async {
      if (previousTopTaskIds.isNotEmpty) {
        await (_database.update(
          _database.tasks,
        )..where((table) => table.taskId.isIn(previousTopTaskIds))).write(
          TasksCompanion(
            isTopThree: const Value(false),
            updatedAt: Value(_now()),
          ),
        );
      }

      if (normalizedTaskIds.isNotEmpty) {
        await (_database.update(
          _database.tasks,
        )..where((table) => table.taskId.isIn(normalizedTaskIds))).write(
          TasksCompanion(
            isTopThree: const Value(true),
            updatedAt: Value(_now()),
          ),
        );
      }

      await (_database.update(_database.dailyPlans)
            ..where((table) => table.dailyPlanId.equals(todayPlan.dailyPlanId)))
          .write(
            DailyPlansCompanion(
              topTask1Id: Value(_taskIdAt(normalizedTaskIds, 0)),
              topTask2Id: Value(_taskIdAt(normalizedTaskIds, 1)),
              topTask3Id: Value(_taskIdAt(normalizedTaskIds, 2)),
              updatedAt: Value(_now()),
            ),
          );
    });
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

  String? _buildEveningReviewSummary({
    required String? movedForward,
    required String? completed,
    required String? learned,
    required String? blockers,
  }) {
    final parts = <String>[];

    if (movedForward != null) {
      parts.add('Moved forward: $movedForward');
    }

    if (completed != null) {
      parts.add('Completed: $completed');
    }

    if (learned != null) {
      parts.add('Learned: $learned');
    }

    if (blockers != null) {
      parts.add('Blocked by: $blockers');
    }

    if (parts.isEmpty) {
      return null;
    }

    return parts.join('\n\n');
  }

  List<String> _normalizeTaskIds(List<String> taskIds) {
    final normalized = <String>[];

    for (final taskId in taskIds) {
      final trimmed = taskId.trim();
      if (trimmed.isEmpty || normalized.contains(trimmed)) {
        continue;
      }

      normalized.add(trimmed);
    }

    return normalized;
  }

  String? _taskIdAt(List<String> taskIds, int index) {
    return index < taskIds.length ? taskIds[index] : null;
  }
}
