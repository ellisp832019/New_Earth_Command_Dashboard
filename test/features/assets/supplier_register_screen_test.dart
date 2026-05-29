import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/supplier_register_screen.dart';

void main() {
  testWidgets('supplier register opens through its route', (tester) async {
    final fixture = _fixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetSupplierRegister,
      routes: [
        GoRoute(
          path: RouteNames.assetSupplierRegister,
          builder: (context, state) => const SupplierRegisterScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetSupplierRegisterProvider.overrideWith(
            (ref) async => fixture.table,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Supplier Register'), findsOneWidget);
    expect(find.text('RS Components'), findsOneWidget);
  });

  testWidgets('supplier register saves a supplier row', (tester) async {
    final fixture = _fixture(empty: true);
    final repository = _RecordingAssetRegisterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetSupplierRegisterProvider.overrideWith(
            (ref) async => fixture.table,
          ),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: SupplierRegisterScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Add Supplier'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'SUP-001');
    await tester.enterText(fields.at(1), 'RS Components');
    await tester.enterText(fields.at(2), 'https://rs-online.com');
    await tester.enterText(fields.at(3), 'Electronics');
    await tester.enterText(fields.at(4), 'good');
    await tester.enterText(fields.at(5), 'fast');
    await tester.enterText(fields.at(6), 'steady');
    await tester.enterText(fields.at(7), 'Good for fast prototype orders.');

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastSupplierRow, isNotNull);
    expect(repository.lastSupplierRow!['supplier_id'], 'SUP-001');
    expect(repository.lastSupplierRow!['name'], 'RS Components');
    expect(repository.lastSupplierRow!['website'], 'https://rs-online.com');
    expect(repository.lastSupplierRow!['category'], 'Electronics');
    expect(repository.lastSupplierRow!['preferred'], 'no');
    expect(
      repository.lastSupplierRow!['notes'],
      'Good for fast prototype orders.',
    );
  });

  testWidgets('supplier register edits a supplier row', (tester) async {
    final fixture = _fixture();
    final repository = _RecordingAssetRegisterRepository();
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetSupplierRegisterProvider.overrideWith(
            (ref) async => fixture.table,
          ),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: SupplierRegisterScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byTooltip('Edit supplier').first);
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'RS Components Pro');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastSupplierRow, isNotNull);
    expect(repository.lastSupplierRow!['supplier_id'], 'SUP-001');
    expect(repository.lastSupplierRow!['name'], 'RS Components Pro');
  });
}

_SupplierFixture _fixture({bool empty = false}) {
  final rows = empty
      ? <Map<String, String>>[]
      : [
          {
            'supplier_id': 'SUP-001',
            'name': 'RS Components',
            'website': 'https://rs-online.com',
            'category': 'Electronics',
            'reliability': 'good',
            'delivery_speed': 'fast',
            'quality': 'steady',
            'preferred': 'yes',
            'notes': 'Used for common parts.',
          },
        ];

  return _SupplierFixture(
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
      headers: AssetRegisterRepository.supplierHeaders,
      rows: rows,
    ),
  );
}

class _SupplierFixture {
  const _SupplierFixture({required this.snapshot, required this.table});

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable table;
}

class _RecordingAssetRegisterRepository extends AssetRegisterRepository {
  _RecordingAssetRegisterRepository() : super(csvService: AssetCsvService());

  Map<String, String>? lastSupplierRow;

  @override
  Future<AssetCsvTable> appendSupplierRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    lastSupplierRow = Map<String, String>.from(row);
    return AssetCsvTable(
      headers: AssetRegisterRepository.supplierHeaders,
      rows: [row],
    );
  }

  @override
  Future<AssetCsvTable> updateSupplierRecord(
    String assetsRootPath,
    Map<String, String> updatedRow,
  ) async {
    lastSupplierRow = Map<String, String>.from(updatedRow);
    return AssetCsvTable(
      headers: AssetRegisterRepository.supplierHeaders,
      rows: [updatedRow],
    );
  }
}
