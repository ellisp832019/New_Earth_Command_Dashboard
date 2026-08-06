import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/evidence_library_screen.dart';

void main() {
  testWidgets('evidence library opens through its route', (tester) async {
    final fixture = _fixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetEvidenceLibrary,
      routes: [
        GoRoute(
          path: RouteNames.assetEvidenceLibrary,
          builder: (context, state) => const EvidenceLibraryScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetEquipmentRegisterProvider.overrideWith(
            (ref) async => fixture.equipmentTable,
          ),
          assetOrdersTrackerProvider.overrideWith(
            (ref) async => fixture.ordersTable,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Receipts / Warranties / Manuals'), findsOneWidget);
    expect(find.text('2 receipts linked'), findsOneWidget);
    expect(find.text('1 warranty dated'), findsOneWidget);
    expect(find.textContaining('manual pointer'), findsWidgets);
    expect(find.text('Field scanner'), findsWidgets);
    expect(find.text('Repair drone manual'), findsOneWidget);
    expect(find.text('M3 screws'), findsOneWidget);
  });
}

_EvidenceFixture _fixture() {
  return _EvidenceFixture(
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
      equipmentCount: 2,
      partsCount: 0,
      guidanceNote: 'Connected.',
    ),
    equipmentTable: AssetCsvTable(
      headers: AssetRegisterRepository.equipmentHeaders,
      rows: [
        {
          'asset_id': 'NE-EQ-0001',
          'name': 'Field scanner',
          'type': 'Scanner',
          'project': 'MicroGrow',
          'owner': 'Peter',
          'location': 'Workbench A',
          'condition': 'good',
          'status': 'available',
          'purchase_date': '2026-04-10',
          'purchase_cost': '120',
          'replacement_value': '140',
          'serial_number': 'SN-001',
          'receipt_link': 'receipts/field_scanner.pdf',
          'warranty_until': '2027-04-10',
          'notes': '',
        },
        {
          'asset_id': 'NE-EQ-0002',
          'name': 'Repair drone manual',
          'type': 'Drone',
          'project': 'MicroGrow',
          'owner': 'Hayley',
          'location': 'Bench',
          'condition': 'broken',
          'status': 'broken',
          'purchase_date': '2026-04-11',
          'purchase_cost': '250',
          'replacement_value': '320',
          'serial_number': 'SN-002',
          'receipt_link': '',
          'warranty_until': '',
          'notes': 'Manual stored as repair_drone_manual.pdf',
        },
      ],
    ),
    ordersTable: AssetCsvTable(
      headers: AssetRegisterRepository.ordersHeaders,
      rows: [
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
          'receipt_link': 'orders/receipt-001.pdf',
          'finance_record_id': 'FIN-123',
          'notes': 'Packed with order paperwork.',
        },
      ],
    ),
  );
}

class _EvidenceFixture {
  const _EvidenceFixture({
    required this.snapshot,
    required this.equipmentTable,
    required this.ordersTable,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable equipmentTable;
  final AssetCsvTable ordersTable;
}
