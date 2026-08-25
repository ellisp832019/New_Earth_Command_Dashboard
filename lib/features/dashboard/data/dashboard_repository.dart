import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

enum DashboardNextStepActionType { planner, tasks, parkedTasks, projectDetail }

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.date,
    required this.hasTodayPlan,
    required this.activeProjectCount,
    required this.activeProjects,
    required this.topTasks,
    required this.topTaskTitles,
    required this.nextStepTitle,
    required this.nextStepSummary,
    required this.nextStepReason,
    required this.nextStepActionType,
    required this.nextStepActionLabel,
    required this.showWellbeingCard,
    required this.showBusinessCard,
    required this.showLearningCard,
    required this.showContentCard,
    required this.energyLabel,
    required this.hasEveningReview,
    this.mainFocus,
    this.focusReason,
    this.morningIntention,
    this.eveningReview,
    this.carryForwardNotes,
    this.tomorrowFocus,
    this.nextStepProjectId,
  });

  final DateTime date;
  final bool hasTodayPlan;
  final int activeProjectCount;
  final List<DashboardProjectSummary> activeProjects;
  final List<DashboardTopTask> topTasks;
  final List<String> topTaskTitles;
  final bool showWellbeingCard;
  final bool showBusinessCard;
  final bool showLearningCard;
  final bool showContentCard;
  final String energyLabel;
  final bool hasEveningReview;
  final String nextStepTitle;
  final String nextStepSummary;
  final String nextStepReason;
  final DashboardNextStepActionType nextStepActionType;
  final String nextStepActionLabel;
  final String? mainFocus;
  final String? focusReason;
  final String? morningIntention;
  final String? eveningReview;
  final String? carryForwardNotes;
  final String? tomorrowFocus;
  final String? nextStepProjectId;
}

class DashboardProjectSummary {
  const DashboardProjectSummary({
    required this.projectId,
    required this.name,
    required this.progressPercentage,
    this.currentMilestone,
    this.nextAction,
  });

  final String projectId;
  final String name;
  final int progressPercentage;
  final String? currentMilestone;
  final String? nextAction;
}

class DashboardTopTask {
  const DashboardTopTask({
    required this.taskId,
    required this.title,
    required this.status,
    required this.priority,
    this.projectName,
  });

  final String taskId;
  final String title;
  final String status;
  final String priority;
  final String? projectName;
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
    final settings = await (_database.select(
      _database.appSettings,
    )..limit(1)).getSingleOrNull();
    final activeProjectCount = await _activeProjectCount();
    final activeProjects = await _activeProjectSummaries();
    final topTasks = await _topTasks(todayPlan);
    final energyLabel = await _energyLabel();
    final guidance = _nextStepGuidance(
      todayPlan: todayPlan,
      topTasks: topTasks,
      activeProjects: activeProjects,
      energyLabel: energyLabel,
    );

    return DashboardSnapshot(
      date: today,
      hasTodayPlan: todayPlan != null,
      hasEveningReview: todayPlan?.eveningReview?.trim().isNotEmpty == true,
      mainFocus: todayPlan?.mainFocus,
      focusReason: todayPlan?.focusReason,
      morningIntention: todayPlan?.morningIntention,
      eveningReview: todayPlan?.eveningReview,
      carryForwardNotes: todayPlan?.carryForwardNotes,
      tomorrowFocus: todayPlan?.tomorrowFocus,
      activeProjectCount: activeProjectCount,
      activeProjects: activeProjects,
      topTasks: topTasks,
      topTaskTitles: topTasks.map((task) => task.title).toList(),
      nextStepTitle: guidance.title,
      nextStepSummary: guidance.summary,
      nextStepReason: guidance.reason,
      nextStepActionType: guidance.actionType,
      nextStepActionLabel: guidance.actionLabel,
      nextStepProjectId: guidance.projectId,
      showWellbeingCard: settings?.showWellbeingCard ?? true,
      showBusinessCard: settings?.showBusinessCard ?? true,
      showLearningCard: settings?.showLearningCard ?? true,
      showContentCard: settings?.showContentCard ?? true,
      energyLabel: energyLabel,
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

  Future<List<DashboardProjectSummary>> _activeProjectSummaries() async {
    final projects =
        await (_database.select(_database.projects)
              ..where((table) => table.isArchived.equals(false))
              ..orderBy([
                (table) => OrderingTerm.desc(table.priority),
                (table) => OrderingTerm.desc(table.updatedAt),
              ])
              ..limit(4))
            .get();

    return projects
        .map(
          (project) => DashboardProjectSummary(
            projectId: project.projectId,
            name: project.name,
            progressPercentage: project.progressPercentage,
            currentMilestone: project.currentMilestone,
            nextAction: project.nextAction,
          ),
        )
        .toList();
  }

  Future<String> _energyLabel() async {
    final checkin =
        await (_database.select(_database.wellbeingCheckins)
              ..orderBy([(table) => OrderingTerm.desc(table.date)])
              ..limit(1))
            .getSingleOrNull();

    return checkin?.energyLevel ?? 'Unrated';
  }

  _DashboardGuidance _nextStepGuidance({
    required DailyPlan? todayPlan,
    required List<DashboardTopTask> topTasks,
    required List<DashboardProjectSummary> activeProjects,
    required String energyLabel,
  }) {
    final mainFocus = todayPlan?.mainFocus?.trim();
    final tomorrowFocus = todayPlan?.tomorrowFocus?.trim();
    final carryForwardNotes = todayPlan?.carryForwardNotes?.trim();
    final hasEveningReview =
        todayPlan?.eveningReview?.trim().isNotEmpty == true;
    final firstTask = topTasks.isNotEmpty ? topTasks.first : null;
    final firstProject = activeProjects.isNotEmpty
        ? activeProjects.first
        : null;
    final isLowEnergy = energyLabel.toLowerCase().contains('low');

    if (mainFocus != null && mainFocus.isNotEmpty && firstTask != null) {
      return _DashboardGuidance(
        title: 'Stay with today\'s focus',
        summary: 'Start with $mainFocus, then move into ${firstTask.title}.',
        reason:
            'It follows the plan you already set and keeps the day anchored.',
        actionType: DashboardNextStepActionType.tasks,
        actionLabel: 'Open Tasks',
      );
    }

    if (mainFocus != null && mainFocus.isNotEmpty) {
      return _DashboardGuidance(
        title: 'Stay with today\'s focus',
        summary: 'Start with $mainFocus.',
        reason:
            'It gives the day one clear anchor before anything else competes for attention.',
        actionType: DashboardNextStepActionType.planner,
        actionLabel: 'Open Planner',
      );
    }

    if (hasEveningReview && tomorrowFocus != null && tomorrowFocus.isNotEmpty) {
      return _DashboardGuidance(
        title: 'Tomorrow is already lined up',
        summary: _tomorrowFocusSummary(tomorrowFocus),
        reason:
            'You already closed the last loop, so the next useful move is waiting for you.',
        actionType: DashboardNextStepActionType.planner,
        actionLabel: 'Continue Planner',
      );
    }

    if (carryForwardNotes != null && carryForwardNotes.isNotEmpty) {
      return _DashboardGuidance(
        title: 'Pick up the handoff gently',
        summary: _carryForwardSummary(carryForwardNotes),
        reason:
            'You left yourself a clear carry-forward note, so nothing important needs to be rediscovered.',
        actionType: DashboardNextStepActionType.parkedTasks,
        actionLabel: 'Review Parked',
      );
    }

    if (firstTask != null) {
      return _DashboardGuidance(
        title: isLowEnergy ? 'Keep today light' : 'Next useful move',
        summary: 'Start with ${firstTask.title}.',
        reason: isLowEnergy
            ? 'Energy looks low, so one clear step is enough to keep momentum.'
            : 'It is already in the Top 3, so it is the clearest local move.',
        actionType: DashboardNextStepActionType.tasks,
        actionLabel: 'Open Tasks',
      );
    }

    if (firstProject != null) {
      final projectLine =
          firstProject.nextAction ??
          firstProject.currentMilestone ??
          'one small step';
      return _DashboardGuidance(
        title: 'Next useful move',
        summary: 'Continue ${firstProject.name} with $projectLine.',
        reason: 'It uses the strongest project context available right now.',
        actionType: DashboardNextStepActionType.projectDetail,
        actionLabel: 'Open Project',
        projectId: firstProject.projectId,
      );
    }

    return _DashboardGuidance(
      title: 'Choose one gentle move',
      summary: 'Open Planner and pick one small focus for today.',
      reason:
          'Nothing is pinned yet, so one simple choice will keep the day steady.',
      actionType: DashboardNextStepActionType.planner,
      actionLabel: 'Open Planner',
    );
  }

  String _carryForwardSummary(String carryForwardNotes) {
    if (carryForwardNotes.length <= 110) {
      return carryForwardNotes;
    }

    return '${carryForwardNotes.substring(0, 107).trimRight()}...';
  }

  String _tomorrowFocusSummary(String tomorrowFocus) {
    final normalized = tomorrowFocus.trim();
    final sentence = normalized.endsWith('.')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
    final lower = sentence.toLowerCase();
    if (lower.startsWith('start with ')) {
      return '${sentence[0].toUpperCase()}${sentence.substring(1)}.';
    }

    return 'Start with $sentence.';
  }

  Future<List<DashboardTopTask>> _topTasks(DailyPlan? todayPlan) async {
    final planTaskIds = todayPlan == null
        ? const <String>[]
        : [
            todayPlan.topTask1Id,
            todayPlan.topTask2Id,
            todayPlan.topTask3Id,
          ].whereType<String>().toList();

    if (planTaskIds.isNotEmpty) {
      final tasks = await (_database.select(
        _database.tasks,
      )..where((table) => table.taskId.isIn(planTaskIds))).get();
      final tasksById = {for (final task in tasks) task.taskId: task};
      final projectIds = tasks
          .map((task) => task.projectId)
          .whereType<String>()
          .toSet()
          .toList();
      final projects = projectIds.isEmpty
          ? const <Project>[]
          : await (_database.select(
              _database.projects,
            )..where((table) => table.projectId.isIn(projectIds))).get();
      final projectNames = {
        for (final project in projects) project.projectId: project.name,
      };

      return planTaskIds
          .map((taskId) {
            final task = tasksById[taskId];
            if (task == null ||
                _isClosedOrParked(task.status) ||
                task.isArchived) {
              return null;
            }

            return DashboardTopTask(
              taskId: task.taskId,
              title: task.title,
              status: task.status,
              priority: task.priority,
              projectName: task.projectId == null
                  ? null
                  : projectNames[task.projectId],
            );
          })
          .whereType<DashboardTopTask>()
          .toList();
    }

    final tasks =
        await (_database.select(_database.tasks)
              ..where(
                (table) =>
                    table.isArchived.equals(false) &
                    table.isTopThree.equals(true) &
                    table.status.isNotIn(const ['Done', 'Parked', 'Blocked']),
              )
              ..orderBy([
                (table) => OrderingTerm.asc(table.createdAt),
                (table) => OrderingTerm.asc(table.taskId),
              ])
              ..limit(3))
            .get();
    final projectIds = tasks
        .map((task) => task.projectId)
        .whereType<String>()
        .toSet()
        .toList();
    final projects = projectIds.isEmpty
        ? const <Project>[]
        : await (_database.select(
            _database.projects,
          )..where((table) => table.projectId.isIn(projectIds))).get();
    final projectNames = {
      for (final project in projects) project.projectId: project.name,
    };

    return tasks
        .map(
          (task) => DashboardTopTask(
            taskId: task.taskId,
            title: task.title,
            status: task.status,
            priority: task.priority,
            projectName: task.projectId == null
                ? null
                : projectNames[task.projectId],
          ),
        )
        .toList();
  }

  bool _isClosedOrParked(String status) {
    return const {'Done', 'Parked', 'Blocked'}.contains(status);
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _DashboardGuidance {
  const _DashboardGuidance({
    required this.title,
    required this.summary,
    required this.reason,
    required this.actionType,
    required this.actionLabel,
    this.projectId,
  });

  final String title;
  final String summary;
  final String reason;
  final DashboardNextStepActionType actionType;
  final String actionLabel;
  final String? projectId;
}
