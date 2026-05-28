import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/orders_tracker_screen.dart';

void main() {
  testWidgets('orders tracker opens through its route', (tester) async {
    final fixture = _fixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetOrdersTracker,
      routes: [
        GoRoute(
          path: RouteNames.assetOrdersTracker,
          builder: (context, state) => const OrdersTrackerScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetOrdersTrackerProvider.overrideWith((ref) async => fixture.table),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Orders Tracker'), findsOneWidget);
    expect(find.text('RS Components'), findsOneWidget);
  });

  testWidgets('orders tracker saves a record', (tester) async {
    final fixture = _fixture(empty: true);
    final repository = _RecordingAssetRegisterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetOrdersTrackerProvider.overrideWith((ref) async => fixture.table),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: OrdersTrackerScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Add Order'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '2026-05-28');
    await tester.enterText(fields.at(1), 'RS Components');
    await tester.enterText(fields.at(2), 'M3 screws');
    await tester.enterText(fields.at(3), 'MicroGrow');
    await tester.enterText(fields.at(4), '10');
    await tester.enterText(fields.at(5), '12.50');
    await tester.enterText(fields.at(6), 'TRACK-001');
    await tester.enterText(fields.at(7), 'assets/receipt.pdf');
    await tester.enterText(fields.at(8), 'FIN-123');
    await tester.enterText(fields.at(9), 'Ready for the next build.');

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastOrderRow, isNotNull);
    expect(repository.lastOrderRow!['date'], '2026-05-28');
    expect(repository.lastOrderRow!['supplier'], 'RS Components');
    expect(repository.lastOrderRow!['item'], 'M3 screws');
    expect(repository.lastOrderRow!['project'], 'MicroGrow');
    expect(repository.lastOrderRow!['finance_record_id'], 'FIN-123');
  });
}

_OrdersFixture _fixture({bool empty = false}) {
  final rows = empty
      ? <Map<String, String>>[]
      : [
          {
            'order_id': 'NE-ORDER-0001',
            'date': '2026-05-28',
            'supplier': 'RS Components',
            'item': 'M3 screws',
            'project': 'MicroGrow',
            'quantity': '10',
            'total_cost': '12.50',
            'status': 'open',
            'tracking': 'TRACK-001',
            'receipt_link': 'assets/receipt.pdf',
            'finance_record_id': 'FIN-123',
            'notes': 'Ready for the next build.',
          },
        ];

  return _OrdersFixture(
    snapshot: const AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
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
      headers: AssetRegisterRepository.ordersHeaders,
      rows: rows,
    ),
  );
}

class _OrdersFixture {
  const _OrdersFixture({
    required this.snapshot,
    required this.table,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable table;
}

class _RecordingAssetRegisterRepository extends AssetRegisterRepository {
  _RecordingAssetRegisterRepository()
      : super(csvService: AssetCsvService());

  Map<String, String>? lastOrderRow;

  @override
  Future<AssetCsvTable> appendOrderRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    lastOrderRow = Map<String, String>.from(row);
    return AssetCsvTable(
      headers: AssetRegisterRepository.ordersHeaders,
      rows: [row],
    );
  }
}
