import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/reorder_list_screen.dart';

void main() {
  testWidgets('reorder list opens through its route', (tester) async {
    final fixture = _fixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetReorderList,
      routes: [
        GoRoute(
          path: RouteNames.assetReorderList,
          builder: (context, state) => const ReorderListScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetReorderListProvider.overrideWith((ref) async => fixture.table),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Reorder List'), findsAtLeastNWidgets(1));
    expect(find.text('M3 screws'), findsAtLeastNWidgets(1));
  });

  testWidgets('reorder list saves a record', (tester) async {
    final fixture = _fixture(empty: true);
    final repository = _RecordingAssetRegisterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetReorderListProvider.overrideWith((ref) async => fixture.table),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: ReorderListScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Add Reorder'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '2026-05-28');
    await tester.enterText(fields.at(1), 'M3 screws');
    await tester.enterText(fields.at(2), 'MicroGrow');
    await tester.enterText(fields.at(3), '5');
    await tester.enterText(fields.at(4), '12.50');
    await tester.enterText(fields.at(5), 'RS Components');
    await tester.enterText(fields.at(6), 'Keep ready for the next build.');

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastReorderRow, isNotNull);
    expect(repository.lastReorderRow!['date'], '2026-05-28');
    expect(repository.lastReorderRow!['item'], 'M3 screws');
    expect(repository.lastReorderRow!['project'], 'MicroGrow');
    expect(repository.lastReorderRow!['quantity_needed'], '5');
    expect(repository.lastReorderRow!['supplier'], 'RS Components');
  });
}

_ReorderFixture _fixture({bool empty = false}) {
  final rows = empty
      ? <Map<String, String>>[]
      : [
          {
            'date': '2026-05-28',
            'item': 'M3 screws',
            'project': 'MicroGrow',
            'quantity_needed': '5',
            'estimated_cost': '12.50',
            'priority': 'urgent',
            'status': 'open',
            'supplier': 'RS Components',
            'notes': 'Keep ready for the next build.',
          },
        ];

  return _ReorderFixture(
    snapshot: const AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath:
          'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
      isReady: true,
      issues: <String>[],
      requiredFolders: <String>[],
      missingFolders: <String>[],
      missingFiles: <String>[],
      summaryCards: <AssetSummaryCard>[],
      equipmentCount: 0,
      partsCount: 0,
      guidanceNote: 'Connected.',
    ),
    table: AssetCsvTable(
      headers: AssetRegisterRepository.reorderHeaders,
      rows: rows,
    ),
  );
}

class _ReorderFixture {
  const _ReorderFixture({required this.snapshot, required this.table});

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable table;
}

class _RecordingAssetRegisterRepository extends AssetRegisterRepository {
  _RecordingAssetRegisterRepository() : super(csvService: AssetCsvService());

  Map<String, String>? lastReorderRow;

  @override
  Future<AssetCsvTable> appendReorderRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    lastReorderRow = Map<String, String>.from(row);
    return AssetCsvTable(
      headers: AssetRegisterRepository.reorderHeaders,
      rows: [row],
    );
  }
}
