import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/equipment_register_screen.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/parts_inventory_screen.dart';

void main() {
  testWidgets('equipment register filters by search text', (tester) async {
    final fixture = _fixture();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetEquipmentRegisterProvider.overrideWith(
            (ref) async => fixture.equipmentTable,
          ),
        ],
        child: const MaterialApp(home: EquipmentRegisterScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Cordless drill'), findsOneWidget);
    expect(find.text('Workbench lamp'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'drill');
    await tester.pump();

    expect(find.text('Cordless drill'), findsOneWidget);
    expect(find.text('Workbench lamp'), findsNothing);
    expect(find.text('1 of 2 equipment items shown.'), findsOneWidget);
  });

  testWidgets('equipment register edits a row', (tester) async {
    final fixture = _fixture();
    final repository = _RecordingAssetRegisterRepository();
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetEquipmentRegisterProvider.overrideWith(
            (ref) async => fixture.equipmentTable,
          ),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: EquipmentRegisterScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.enterText(find.byType(TextField).first, 'drill');
    await tester.pump();
    await tester.tap(find.byTooltip('Edit equipment').first);
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'Cordless drill pro');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastEquipmentRow, isNotNull);
    expect(repository.lastEquipmentRow!['asset_id'], 'NE-EQ-0001');
    expect(repository.lastEquipmentRow!['name'], 'Cordless drill pro');
  });

  testWidgets('equipment register deletes a row', (tester) async {
    final fixture = _fixture();
    final repository = _RecordingAssetRegisterRepository();
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetEquipmentRegisterProvider.overrideWith(
            (ref) async => fixture.equipmentTable,
          ),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: EquipmentRegisterScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byTooltip('Delete equipment').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete equipment entry?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastDeletedEquipmentId, 'NE-EQ-0001');
  });

  testWidgets('parts inventory filters by low stock chip', (tester) async {
    final fixture = _fixture();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetPartsRegisterProvider.overrideWith(
            (ref) async => fixture.partsTable,
          ),
        ],
        child: const MaterialApp(home: PartsInventoryScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('M3 screws'), findsOneWidget);
    expect(find.text('Sensor kit'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Low Stock'));
    await tester.pump();

    expect(find.text('M3 screws'), findsOneWidget);
    expect(find.text('Sensor kit'), findsNothing);
    expect(find.text('1 of 2 part records shown.'), findsOneWidget);
  });

  testWidgets('parts inventory edits a row', (tester) async {
    final fixture = _fixture();
    final repository = _RecordingAssetRegisterRepository();
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetPartsRegisterProvider.overrideWith(
            (ref) async => fixture.partsTable,
          ),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: PartsInventoryScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.widgetWithText(FilterChip, 'Low Stock'));
    await tester.pump();
    await tester.tap(find.byTooltip('Edit part').first);
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'M3 screws pack');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastPartRow, isNotNull);
    expect(repository.lastPartRow!['part_id'], 'NE-PART-0001');
    expect(repository.lastPartRow!['name'], 'M3 screws pack');
  });
}

_RegisterFixture _fixture() {
  return _RegisterFixture(
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
    equipmentTable: AssetCsvTable(
      headers: AssetRegisterRepository.equipmentHeaders,
      rows: <Map<String, String>>[
        {
          'asset_id': 'NE-EQ-0001',
          'name': 'Cordless drill',
          'type': 'Tool',
          'project': 'Workshop',
          'owner': '',
          'location': 'Drawer 1',
          'condition': 'good',
          'status': 'available',
          'purchase_date': '',
          'purchase_cost': '',
          'replacement_value': '',
          'serial_number': '',
          'receipt_link': '',
          'warranty_until': '',
          'notes': '',
        },
        {
          'asset_id': 'NE-EQ-0002',
          'name': 'Workbench lamp',
          'type': 'Light',
          'project': 'Workshop',
          'owner': '',
          'location': 'Shelf 3',
          'condition': 'fair',
          'status': 'repairing',
          'purchase_date': '',
          'purchase_cost': '',
          'replacement_value': '',
          'serial_number': '',
          'receipt_link': '',
          'warranty_until': '',
          'notes': '',
        },
      ],
    ),
    partsTable: AssetCsvTable(
      headers: AssetRegisterRepository.partsHeaders,
      rows: <Map<String, String>>[
        {
          'part_id': 'NE-PART-0001',
          'name': 'M3 screws',
          'category': 'Fasteners',
          'project': 'Workshop',
          'quantity': '6',
          'min_quantity': '10',
          'location': 'Drawer 2',
          'supplier': 'RS Components',
          'last_ordered': '',
          'last_cost': '12',
          'status': 'low_stock',
          'datasheet_link': '',
          'notes': '',
        },
        {
          'part_id': 'NE-PART-0002',
          'name': 'Sensor kit',
          'category': 'Electronics',
          'project': 'Workshop',
          'quantity': '18',
          'min_quantity': '12',
          'location': 'Drawer 4',
          'supplier': 'Farnell',
          'last_ordered': '',
          'last_cost': '24',
          'status': 'available',
          'datasheet_link': '',
          'notes': '',
        },
      ],
    ),
  );
}

class _RegisterFixture {
  const _RegisterFixture({
    required this.snapshot,
    required this.equipmentTable,
    required this.partsTable,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable equipmentTable;
  final AssetCsvTable partsTable;
}

class _RecordingAssetRegisterRepository extends AssetRegisterRepository {
  _RecordingAssetRegisterRepository() : super(csvService: AssetCsvService());

  Map<String, String>? lastEquipmentRow;
  String? lastDeletedEquipmentId;
  Map<String, String>? lastPartRow;

  @override
  Future<AssetCsvTable> updateEquipmentRecord(
    String assetsRootPath,
    Map<String, String> updatedRow,
  ) async {
    lastEquipmentRow = Map<String, String>.from(updatedRow);
    return AssetCsvTable(
      headers: AssetRegisterRepository.equipmentHeaders,
      rows: [updatedRow],
    );
  }

  @override
  Future<AssetCsvTable> deleteEquipmentRecord(
    String assetsRootPath,
    String assetId,
  ) async {
    lastDeletedEquipmentId = assetId;
    return AssetCsvTable(
      headers: AssetRegisterRepository.equipmentHeaders,
      rows: <Map<String, String>>[],
    );
  }

  @override
  Future<AssetCsvTable> updatePartRecord(
    String assetsRootPath,
    Map<String, String> updatedRow,
  ) async {
    lastPartRow = Map<String, String>.from(updatedRow);
    return AssetCsvTable(
      headers: AssetRegisterRepository.partsHeaders,
      rows: [updatedRow],
    );
  }
}
