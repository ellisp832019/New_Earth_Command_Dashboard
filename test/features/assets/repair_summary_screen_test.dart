import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/repair_summary_screen.dart';

void main() {
  test('asset repository helpers identify broken and repairing equipment', () {
    final repository = AssetFolderService().registerRepository;
    final rows = [
      {
        'asset_id': 'NE-EQ-0001',
        'name': 'Field scanner',
        'status': 'broken',
        'condition': 'broken',
      },
      {
        'asset_id': 'NE-EQ-0002',
        'name': 'Power pack',
        'status': 'available',
        'condition': 'repairing',
      },
      {
        'asset_id': 'NE-EQ-0003',
        'name': 'Spare sensor',
        'status': 'available',
        'condition': 'good',
      },
    ];

    final repairRows = repository.filterBrokenRepairEquipment(rows);

    expect(repairRows.length, 2);
    expect(repairRows.any((row) => row['asset_id'] == 'NE-EQ-0001'), isTrue);
    expect(repairRows.any((row) => row['asset_id'] == 'NE-EQ-0002'), isTrue);
  });

  testWidgets('repair summary screen shows broken and repairing items', (
    tester,
  ) async {
    final data = _repairFixture();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => data.snapshot),
          assetEquipmentRegisterProvider.overrideWith(
            (ref) async => data.equipmentTable,
          ),
          assetBrokenRepairEquipmentProvider.overrideWith(
            (ref) async => data.repairRows,
          ),
        ],
        child: const MaterialApp(home: RepairSummaryScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Broken / Repair'), findsOneWidget);
    expect(find.text('Next actions'), findsOneWidget);
    expect(find.text('Repair resolution handoff'), findsOneWidget);
    expect(find.text('Open Equipment Register'), findsOneWidget);
    expect(find.text('Open Orders Tracker'), findsWidgets);
    expect(find.text('Open Maintenance Log'), findsOneWidget);
    expect(find.text('Open Evidence Library'), findsOneWidget);
    expect(find.text('Field scanner'), findsOneWidget);
    expect(find.text('Power pack'), findsOneWidget);
    expect(find.text('Spare sensor'), findsNothing);
  });

  testWidgets('repair summary screen opens through a route', (tester) async {
    final data = _repairFixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetRepairSummary,
      routes: [
        GoRoute(
          path: RouteNames.assetRepairSummary,
          builder: (context, state) => const RepairSummaryScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => data.snapshot),
          assetEquipmentRegisterProvider.overrideWith(
            (ref) async => data.equipmentTable,
          ),
          assetBrokenRepairEquipmentProvider.overrideWith(
            (ref) async => data.repairRows,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Broken / Repair'), findsOneWidget);
  });
}

_RepairFixture _repairFixture() {
  final rows = [
    {
      'asset_id': 'NE-EQ-0001',
      'name': 'Field scanner',
      'type': 'Scanner',
      'project': 'MicroGrow',
      'owner': 'Peter',
      'location': 'Workbench A',
      'condition': 'broken',
      'status': 'broken',
      'purchase_date': '2026-04-10',
      'purchase_cost': '120',
      'replacement_value': '140',
      'serial_number': 'SN-001',
      'receipt_link': '',
      'warranty_until': '',
      'notes': 'Screen cracked after field use.',
    },
    {
      'asset_id': 'NE-EQ-0002',
      'name': 'Power pack',
      'type': 'Battery',
      'project': 'MicroGrow',
      'owner': 'Peter',
      'location': 'Charging Shelf',
      'condition': 'repairing',
      'status': 'available',
      'purchase_date': '2026-04-12',
      'purchase_cost': '60',
      'replacement_value': '72',
      'serial_number': 'SN-002',
      'receipt_link': '',
      'warranty_until': '',
      'notes': 'Connector is being replaced.',
    },
  ];

  return _RepairFixture(
    snapshot: const AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath:
          'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
      isReady: true,
      issues: <String>[],
      requiredFolders: AssetFolderService.requiredFolders,
      missingFolders: <String>[],
      missingFiles: <String>[],
      summaryCards: <AssetSummaryCard>[],
      equipmentCount: 2,
      partsCount: 0,
      guidanceNote: 'The external asset folder is connected.',
    ),
    equipmentTable: AssetCsvTable(
      headers: AssetRegisterRepository.equipmentHeaders,
      rows: rows,
    ),
    repairRows: rows,
  );
}

class _RepairFixture {
  const _RepairFixture({
    required this.snapshot,
    required this.equipmentTable,
    required this.repairRows,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable equipmentTable;
  final List<Map<String, String>> repairRows;
}
