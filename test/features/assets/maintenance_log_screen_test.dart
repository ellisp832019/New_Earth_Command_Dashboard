import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/maintenance_log_screen.dart';

void main() {
  testWidgets('maintenance log opens through its route', (tester) async {
    final fixture = _fixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetMaintenanceLog,
      routes: [
        GoRoute(
          path: RouteNames.assetMaintenanceLog,
          builder: (context, state) => const MaintenanceLogScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetMaintenanceLogProvider.overrideWith(
            (ref) async => fixture.table,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Maintenance Log'), findsOneWidget);
    expect(find.text('Field scanner'), findsOneWidget);
  });

  testWidgets('maintenance log saves a record', (tester) async {
    final fixture = _fixture(empty: true);
    final repository = _RecordingAssetRegisterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetMaintenanceLogProvider.overrideWith(
            (ref) async => fixture.table,
          ),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: MaintenanceLogScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Add Log'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '2026-05-28');
    await tester.enterText(fields.at(1), 'NE-EQ-0001');
    await tester.enterText(fields.at(2), 'Field scanner');
    await tester.enterText(fields.at(3), 'Screen flickering');
    await tester.enterText(fields.at(4), 'Replace display cable');
    await tester.enterText(fields.at(5), '12.50');
    await tester.enterText(fields.at(6), 'FIN-123');
    await tester.enterText(fields.at(7), 'Check again after the next session.');

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastMaintenanceRow, isNotNull);
    expect(repository.lastMaintenanceRow!['date'], '2026-05-28');
    expect(repository.lastMaintenanceRow!['asset_id'], 'NE-EQ-0001');
    expect(repository.lastMaintenanceRow!['item'], 'Field scanner');
    expect(repository.lastMaintenanceRow!['issue'], 'Screen flickering');
    expect(repository.lastMaintenanceRow!['linked_finance_record'], 'FIN-123');
  });
}

_MaintenanceFixture _fixture({bool empty = false}) {
  final rows = empty
      ? <Map<String, String>>[]
      : [
          {
            'date': '2026-05-28',
            'asset_id': 'NE-EQ-0001',
            'item': 'Field scanner',
            'issue': 'Screen flickering',
            'action': 'Replace display cable',
            'status': 'open',
            'cost': '12.50',
            'linked_finance_record': 'FIN-123',
            'notes': 'Check again after the next session.',
          },
        ];

  return _MaintenanceFixture(
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
      headers: AssetRegisterRepository.maintenanceHeaders,
      rows: rows,
    ),
  );
}

class _MaintenanceFixture {
  const _MaintenanceFixture({required this.snapshot, required this.table});

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable table;
}

class _RecordingAssetRegisterRepository extends AssetRegisterRepository {
  _RecordingAssetRegisterRepository() : super(csvService: AssetCsvService());

  Map<String, String>? lastMaintenanceRow;

  @override
  Future<AssetCsvTable> appendMaintenanceRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    lastMaintenanceRow = Map<String, String>.from(row);
    return AssetCsvTable(
      headers: AssetRegisterRepository.maintenanceHeaders,
      rows: [row],
    );
  }
}
