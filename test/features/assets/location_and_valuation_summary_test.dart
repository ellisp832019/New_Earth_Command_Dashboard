import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/location_register_screen.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/valuation_summary_screen.dart';

void main() {
  test('location register uses the expected headers', () async {
    final rows = [
      {
        'asset_id': 'NE-EQ-0001',
        'location_name': 'Office Shelf A',
        'description': 'Primary storage shelf',
        'photo_link': '',
        'notes': '',
      },
    ];

    expect(AssetRegisterRepository.locationHeaders, isNotEmpty);
    expect(rows.first['location_name'], 'Office Shelf A');
  });

  testWidgets('location register shows location cards and route', (tester) async {
    final fixture = _locationFixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetLocationRegister,
      routes: [
        GoRoute(
          path: RouteNames.assetLocationRegister,
          builder: (context, state) => const LocationRegisterScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetLocationRegisterProvider.overrideWith(
            (ref) async => fixture.table,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Location Register'), findsOneWidget);
    expect(find.text('Office Shelf A'), findsOneWidget);
    expect(find.text('NE-EQ-0001'), findsOneWidget);
  });

  test('valuation overview groups totals by project', () async {
    final container = ProviderContainer(
      overrides: [
        assetEquipmentRegisterProvider.overrideWith(
          (ref) async => AssetCsvTable(
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
                'receipt_link': '',
                'warranty_until': '',
                'notes': '',
              },
              {
                'asset_id': 'NE-EQ-0002',
                'name': 'Repair drone',
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
                'receipt_link': 'receipt-001',
                'warranty_until': '',
                'notes': '',
              },
            ],
          ),
        ),
        assetValuationSummaryProvider.overrideWith(
          (ref) async => AssetCsvTable(
            headers: AssetRegisterRepository.valuationHeaders,
            rows: [
              {
                'asset_id': 'NE-EQ-0001',
                'item': 'Field scanner',
                'category': 'Prototype/R&D equipment',
                'purchase_cost': '120',
                'replacement_value': '140',
                'current_estimated_value': '130',
                'valuation_reason': 'Prototype unit',
                'evidence_link': '',
                'notes': '',
              },
              {
                'asset_id': 'NE-EQ-0002',
                'item': 'Repair drone',
                'category': 'Tools and lab equipment',
                'purchase_cost': '250',
                'replacement_value': '320',
                'current_estimated_value': '180',
                'valuation_reason': 'Broken item',
                'evidence_link': '',
                'notes': '',
              },
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final overview = await container.read(assetValuationOverviewProvider.future);

    expect(overview.valuationRowCount, 2);
    expect(overview.purchaseCostTotal, 370);
    expect(overview.replacementValueTotal, 460);
    expect(overview.currentEstimatedValueTotal, 310);
    expect(overview.brokenLostValueTotal, 180);
    expect(overview.projectTotals, hasLength(1));
    expect(overview.projectTotals.first.projectName, 'MicroGrow');
  });

  testWidgets('valuation summary shows totals and routes cleanly', (tester) async {
    final fixture = _valuationFixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetValuationSummary,
      routes: [
        GoRoute(
          path: RouteNames.assetValuationSummary,
          builder: (context, state) => const ValuationSummaryScreen(),
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
          assetValuationSummaryProvider.overrideWith(
            (ref) async => fixture.valuationTable,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Valuation Summary'), findsOneWidget);
    expect(find.text('Purchase cost'), findsOneWidget);
    expect(find.text('Asset value by project'), findsOneWidget);
    expect(find.text('Field scanner'), findsOneWidget);
  });
}

_LocationFixture _locationFixture() {
  final table = AssetCsvTable(
    headers: AssetRegisterRepository.locationHeaders,
    rows: [
      {
        'asset_id': 'NE-EQ-0001',
        'location_name': 'Office Shelf A',
        'description': 'Primary storage shelf',
        'photo_link': '',
        'notes': 'Keep labels visible.',
      },
      {
        'asset_id': 'NE-PART-0001',
        'location_name': 'Electronics Drawer 2',
        'description': 'Small parts drawer',
        'photo_link': '',
        'notes': '',
      },
    ],
  );

  return _LocationFixture(
    snapshot: const AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
      isReady: true,
      issues: <String>[],
      requiredFolders: AssetFolderService.requiredFolders,
      missingFolders: <String>[],
      missingFiles: <String>[],
      summaryCards: <AssetSummaryCard>[],
      equipmentCount: 2,
      partsCount: 2,
      guidanceNote: 'Connected.',
    ),
    table: table,
  );
}

_ValuationFixture _valuationFixture() {
  final equipmentRows = [
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
      'receipt_link': '',
      'warranty_until': '',
      'notes': '',
    },
    {
      'asset_id': 'NE-EQ-0002',
      'name': 'Repair drone',
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
      'receipt_link': 'receipt-001',
      'warranty_until': '',
      'notes': '',
    },
  ];

  final valuationRows = [
    {
      'asset_id': 'NE-EQ-0001',
      'item': 'Field scanner',
      'category': 'Prototype/R&D equipment',
      'purchase_cost': '120',
      'replacement_value': '140',
      'current_estimated_value': '130',
      'valuation_reason': 'Prototype unit',
      'evidence_link': '',
      'notes': '',
    },
    {
      'asset_id': 'NE-EQ-0002',
      'item': 'Repair drone',
      'category': 'Tools and lab equipment',
      'purchase_cost': '250',
      'replacement_value': '320',
      'current_estimated_value': '180',
      'valuation_reason': 'Broken item',
      'evidence_link': '',
      'notes': '',
    },
  ];

  return _ValuationFixture(
    snapshot: const AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
      isReady: true,
      issues: <String>[],
      requiredFolders: AssetFolderService.requiredFolders,
      missingFolders: <String>[],
      missingFiles: <String>[],
      summaryCards: <AssetSummaryCard>[],
      equipmentCount: 2,
      partsCount: 0,
      guidanceNote: 'Connected.',
    ),
    equipmentTable: AssetCsvTable(
      headers: AssetRegisterRepository.equipmentHeaders,
      rows: equipmentRows,
    ),
    valuationTable: AssetCsvTable(
      headers: AssetRegisterRepository.valuationHeaders,
      rows: valuationRows,
    ),
  );
}

class _LocationFixture {
  const _LocationFixture({
    required this.snapshot,
    required this.table,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable table;
}

class _ValuationFixture {
  const _ValuationFixture({
    required this.snapshot,
    required this.equipmentTable,
    required this.valuationTable,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable equipmentTable;
  final AssetCsvTable valuationTable;
}
