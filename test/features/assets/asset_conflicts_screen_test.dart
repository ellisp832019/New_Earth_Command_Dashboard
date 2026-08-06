import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_change_journal.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/asset_conflicts_screen.dart';

void main() {
  testWidgets('asset conflicts screen opens and shows calm summaries', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: RouteNames.assetConflictReview,
      routes: [
        GoRoute(
          path: RouteNames.assetConflictReview,
          builder: (context, state) => const AssetConflictsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith(
            (ref) async => const AssetWorkspaceSnapshot(
              configPath: 'config/local_paths.json',
              assetsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
              isReady: true,
              issues: <String>[],
              requiredFolders: AssetFolderService.requiredFolders,
              missingFolders: <String>[],
              missingFiles: <String>[],
              summaryCards: <AssetSummaryCard>[],
              equipmentCount: 0,
              partsCount: 0,
              guidanceNote: 'Connected.',
            ),
          ),
          assetChangeConflictsProvider.overrideWith(
            (ref) async => [
              AssetChangeConflict(
                recordId: 'NE-EQ-0001',
                recordType: 'equipment',
                entryCount: 2,
                machineIds: const ['HAYLEY-LAPTOP', 'PETER-DESKTOP'],
                lastChangeAt: DateTime.utc(2026, 5, 28, 10, 12),
              ),
            ],
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Asset Conflicts'), findsOneWidget);
    expect(find.text('1'), findsAtLeastNWidgets(1));
    expect(find.text('equipment NE-EQ-0001'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('changed 2 times across 2 machines.'),
      findsOneWidget,
    );
    expect(find.text('Compact journal to latest'), findsOneWidget);
  });
}
