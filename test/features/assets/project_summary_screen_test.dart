import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/project_summary_screen.dart';

void main() {
  test('project asset summary groups equipment and parts by project', () async {
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
                'name': 'Workbench lamp',
                'type': 'Light',
                'project': 'New Earth HQ',
                'owner': 'Hayley',
                'location': 'Studio',
                'condition': 'repairing',
                'status': 'repairing',
                'purchase_date': '2026-04-11',
                'purchase_cost': '45',
                'replacement_value': '50',
                'serial_number': 'SN-002',
                'receipt_link': '',
                'warranty_until': '',
                'notes': '',
              },
            ],
          ),
        ),
        assetPartsRegisterProvider.overrideWith(
          (ref) async => AssetCsvTable(
            headers: AssetRegisterRepository.partsHeaders,
            rows: [
              {
                'part_id': 'NE-PART-0001',
                'name': 'M3 screws',
                'category': 'Fasteners',
                'project': 'MicroGrow',
                'quantity': '4',
                'min_quantity': '10',
                'location': 'Drawer',
                'supplier': 'RS',
                'last_ordered': '2026-05-01',
                'last_cost': '1.25',
                'status': 'low_stock',
                'datasheet_link': '',
                'notes': '',
              },
              {
                'part_id': 'NE-PART-0002',
                'name': 'Labels',
                'category': 'Stationery',
                'project': 'New Earth HQ',
                'quantity': '20',
                'min_quantity': '5',
                'location': 'Shelf',
                'supplier': 'Office Depot',
                'last_ordered': '2026-05-01',
                'last_cost': '2',
                'status': 'available',
                'datasheet_link': '',
                'notes': '',
              },
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final summaries = await container.read(assetProjectSummaryProvider.future);

    expect(summaries.length, 2);
    expect(summaries.first.projectName, 'MicroGrow');
    expect(summaries.first.equipmentCount, 1);
    expect(summaries.first.partsCount, 1);
    expect(summaries.first.lowStockCount, 1);
    expect(summaries.first.brokenCount, 0);
    expect(summaries.last.projectName, 'New Earth HQ');
    expect(summaries.last.needsDecisionCount, 0);
  });

  testWidgets('project summary screen shows grouped project cards', (
    tester,
  ) async {
    final data = _projectFixture();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => data.snapshot),
          assetProjectSummaryProvider.overrideWith(
            (ref) async => data.summaries,
          ),
        ],
        child: const MaterialApp(home: ProjectSummaryScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Project Asset Summary'), findsOneWidget);
    expect(find.text('MicroGrow'), findsOneWidget);
    expect(find.text('New Earth HQ'), findsOneWidget);
    expect(find.textContaining('Mixed project'), findsWidgets);
  });

  testWidgets('project summary screen opens through a route', (tester) async {
    final data = _projectFixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetProjectSummary,
      routes: [
        GoRoute(
          path: RouteNames.assetProjectSummary,
          builder: (context, state) => const ProjectSummaryScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => data.snapshot),
          assetProjectSummaryProvider.overrideWith(
            (ref) async => data.summaries,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Project Asset Summary'), findsOneWidget);
  });
}

_ProjectFixture _projectFixture() {
  final summaries = [
    const AssetProjectSummary(
      projectName: 'MicroGrow',
      equipmentCount: 2,
      partsCount: 3,
      availableCount: 2,
      brokenCount: 1,
      lowStockCount: 1,
      needsDecisionCount: 1,
      isMixedProject: true,
    ),
    const AssetProjectSummary(
      projectName: 'New Earth HQ',
      equipmentCount: 1,
      partsCount: 1,
      availableCount: 1,
      brokenCount: 0,
      lowStockCount: 0,
      needsDecisionCount: 0,
      isMixedProject: true,
    ),
  ];

  return _ProjectFixture(
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
      equipmentCount: 3,
      partsCount: 4,
      guidanceNote: 'The external asset folder is connected.',
    ),
    summaries: summaries,
  );
}

class _ProjectFixture {
  const _ProjectFixture({required this.snapshot, required this.summaries});

  final AssetWorkspaceSnapshot snapshot;
  final List<AssetProjectSummary> summaries;
}
