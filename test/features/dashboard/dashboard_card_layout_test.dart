import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_card_layout.dart';
import 'package:new_earth_command_dashboard/features/dashboard/data/dashboard_repository.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';

void main() {
  test('default Dashboard card order is deterministic', () {
    final first = DashboardCardLayout.defaults();
    final second = DashboardCardLayout.defaults();

    expect(first.orderedIds, DashboardCardLayout.defaultOrder);
    expect(second.orderedIds, first.orderedIds);
    expect(first.hiddenIds, isEmpty);
  });

  test('malformed and unknown preferences safely normalize', () {
    final layout = DashboardCardLayout.fromJson(
      '{"orderedIds":["unknown","treasury","treasury"],"hiddenIds":["removed","daily_flow"]}',
    );

    expect(layout.orderedIds, [
      DashboardCardLayout.treasuryId,
      DashboardCardLayout.dailyFlowId,
      DashboardCardLayout.nextStepId,
      DashboardCardLayout.commandCentreId,
      DashboardCardLayout.supportStackId,
    ]);
    expect(layout.hiddenIds, isEmpty);
    expect(
      DashboardCardLayout.fromJson('not-json').orderedIds,
      DashboardCardLayout.defaultOrder,
    );
  });

  test(
    'visibility and order persist through the existing settings record',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final settings = SettingsRepository(database);
      final custom = DashboardCardLayout(
        orderedIds: const [
          DashboardCardLayout.supportStackId,
          DashboardCardLayout.dailyFlowId,
          DashboardCardLayout.nextStepId,
          DashboardCardLayout.treasuryId,
          DashboardCardLayout.commandCentreId,
        ],
        hiddenIds: const {DashboardCardLayout.treasuryId},
      );

      await settings.updateDashboardCardLayout(custom);
      final reloaded = DashboardCardLayout.fromJson(
        (await settings.getSettings()).settings.dashboardCardLayoutJson,
      );

      expect(reloaded.orderedIds, custom.orderedIds);
      expect(reloaded.hiddenIds, custom.hiddenIds);
      expect(reloaded.visibleOrderedIds, [
        DashboardCardLayout.supportStackId,
        DashboardCardLayout.dailyFlowId,
        DashboardCardLayout.nextStepId,
        DashboardCardLayout.commandCentreId,
      ]);
    },
  );

  test(
    'Dashboard snapshot uses saved presentation layout without changing domain data',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final settings = SettingsRepository(database);
      await settings.updateDashboardCardLayout(
        DashboardCardLayout.defaults().copyWith(
          hiddenIds: const {DashboardCardLayout.commandCentreId},
        ),
      );

      final snapshot = await DashboardRepository(
        database,
        now: () => DateTime(2026, 8, 25),
      ).loadTodaySnapshot();

      expect(
        snapshot.cardLayout.hiddenIds,
        contains(DashboardCardLayout.commandCentreId),
      );
      expect(
        snapshot.cardLayout.visibleOrderedIds,
        isNot(contains('command_centre')),
      );
      expect(snapshot.activeProjectCount, 0);
      expect(snapshot.topTasks, isEmpty);
    },
  );

  test('reset layout restores default order and visibility', () {
    final custom = DashboardCardLayout.defaults().copyWith(
      orderedIds: const [
        DashboardCardLayout.treasuryId,
        DashboardCardLayout.dailyFlowId,
        DashboardCardLayout.nextStepId,
        DashboardCardLayout.commandCentreId,
        DashboardCardLayout.supportStackId,
      ],
      hiddenIds: const {
        DashboardCardLayout.treasuryId,
        DashboardCardLayout.supportStackId,
      },
    );

    final reset = DashboardCardLayout.defaults();

    expect(custom.orderedIds, isNot(reset.orderedIds));
    expect(custom.hiddenIds, isNot(reset.hiddenIds));
    expect(reset.orderedIds, DashboardCardLayout.defaultOrder);
    expect(reset.hiddenIds, isEmpty);
  });
}
