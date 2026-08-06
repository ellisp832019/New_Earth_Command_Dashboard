import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/low_stock_screen.dart';

void main() {
  test('asset repository helpers identify low stock reorder pressure', () {
    final repository = AssetFolderService().registerRepository;
    final rows = [
      {
        'part_id': 'NE-PART-0001',
        'name': 'M3 screws',
        'quantity': '4',
        'min_quantity': '10',
        'status': 'available',
        'last_cost': '1.25',
      },
      {
        'part_id': 'NE-PART-0002',
        'name': 'Cable ties',
        'quantity': '2',
        'min_quantity': '5',
        'status': 'reorder_needed',
        'last_cost': '0.50',
      },
      {
        'part_id': 'NE-PART-0003',
        'name': 'Labels',
        'quantity': '20',
        'min_quantity': '5',
        'status': 'available',
        'last_cost': '2.00',
      },
    ];

    final lowStock = repository.filterLowStockParts(rows);
    final reorderNeeded = repository.filterReorderNeededParts(rows);

    expect(lowStock.length, 2);
    expect(reorderNeeded.length, 2);
    expect(repository.estimateReorderSpend(rows), greaterThan(0));
  });

  testWidgets('low stock screen shows reorder cards and summary', (
    tester,
  ) async {
    final data = _lowStockFixture();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => data.snapshot),
          assetPartsRegisterProvider.overrideWith((ref) async => data.partsTable),
          assetLowStockPartsProvider.overrideWith((ref) async => data.lowStockRows),
        ],
        child: const MaterialApp(home: LowStockScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Low Stock / Reorder'), findsOneWidget);
    expect(find.text('Next actions'), findsOneWidget);
    expect(find.text('Open Parts Inventory'), findsOneWidget);
    expect(find.text('Open Orders Tracker'), findsOneWidget);
    expect(find.text('M3 screws'), findsWidgets);
    expect(find.text('Cable ties'), findsWidgets);
    expect(find.textContaining('reorder needed'), findsOneWidget);
  });

  testWidgets('low stock screen opens through a route', (tester) async {
    final data = _lowStockFixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetLowStock,
      routes: [
        GoRoute(
          path: RouteNames.assetLowStock,
          builder: (context, state) => const LowStockScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => data.snapshot),
          assetPartsRegisterProvider.overrideWith((ref) async => data.partsTable),
          assetLowStockPartsProvider.overrideWith((ref) async => data.lowStockRows),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Low Stock / Reorder'), findsOneWidget);
  });
}

_LowStockFixture _lowStockFixture() {
  final rows = [
    {
      'part_id': 'NE-PART-0001',
      'name': 'M3 screws',
      'category': 'Fasteners',
      'project': 'MicroGrow',
      'quantity': '4',
      'min_quantity': '10',
      'location': 'Electronics Drawer 2',
      'supplier': 'RS Components',
      'last_ordered': '2026-05-01',
      'last_cost': '1.25',
      'status': 'low_stock',
      'datasheet_link': '',
      'notes': 'Running low for the prototype bench.',
    },
    {
      'part_id': 'NE-PART-0002',
      'name': 'Cable ties',
      'category': 'Fasteners',
      'project': 'MicroGrow',
      'quantity': '2',
      'min_quantity': '5',
      'location': 'Storage Box 1',
      'supplier': 'RS Components',
      'last_ordered': '2026-05-01',
      'last_cost': '0.50',
      'status': 'reorder_needed',
      'datasheet_link': '',
      'notes': 'Reorder before the next session.',
    },
  ];

  return _LowStockFixture(
    snapshot: AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
      isReady: true,
      issues: const <String>[],
      requiredFolders: AssetFolderService.requiredFolders,
      missingFolders: const <String>[],
      missingFiles: const <String>[],
      summaryCards: const <AssetSummaryCard>[],
      equipmentCount: 3,
      partsCount: rows.length,
      guidanceNote: 'The external asset folder is connected.',
    ),
    partsTable: AssetCsvTable(
      headers: AssetRegisterRepository.partsHeaders,
      rows: rows,
    ),
    lowStockRows: rows,
  );
}

class _LowStockFixture {
  const _LowStockFixture({
    required this.snapshot,
    required this.partsTable,
    required this.lowStockRows,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable partsTable;
  final List<Map<String, String>> lowStockRows;
}
