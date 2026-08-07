import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/quick_capture_screen.dart';

void main() {
  testWidgets('quick capture screen opens through its route', (tester) async {
    final fixture = await _fixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetQuickCapture,
      routes: [
        GoRoute(
          path: RouteNames.assetQuickCapture,
          builder: (context, state) => const QuickCaptureScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Quick Capture'), findsAtLeastNWidgets(1));
    expect(find.text('One-minute capture'), findsAtLeastNWidgets(1));
  });

  testWidgets('quick capture saves an equipment row', (tester) async {
    final fixture = await _fixture();
    final repository = _RecordingAssetRegisterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: QuickCaptureScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Item name'),
      'Cordless drill',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Type / category'),
      'Tool',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project'),
      'MicroGrow',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Location'),
      'Workbench A',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notes'),
      'Use for assembly work.',
    );

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(repository.lastEquipmentRow, isNotNull);
    expect(repository.lastEquipmentRow!['name'], 'Cordless drill');
    expect(repository.lastEquipmentRow!['type'], 'Tool');
    expect(repository.lastEquipmentRow!['project'], 'MicroGrow');
    expect(repository.lastEquipmentRow!['location'], 'Workbench A');
    expect(repository.lastEquipmentRow!['notes'], 'Use for assembly work.');
    expect(repository.lastEquipmentRow!['asset_id'], startsWith('NE-EQ-'));
  });

  testWidgets('quick capture saves a part row', (tester) async {
    final fixture = await _fixture();
    final repository = _RecordingAssetRegisterRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetRegisterRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: const MaterialApp(home: QuickCaptureScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(FilledButton, 'Part'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Item name'),
      'M3 screws',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Type / category'),
      'Fasteners',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Project'),
      'MicroGrow',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Location'),
      'Drawer 2',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notes'),
      'Keep ready for the next build.',
    );

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(repository.lastPartRow, isNotNull);
    expect(repository.lastPartRow!['name'], 'M3 screws');
    expect(repository.lastPartRow!['category'], 'Fasteners');
    expect(repository.lastPartRow!['project'], 'MicroGrow');
    expect(repository.lastPartRow!['location'], 'Drawer 2');
    expect(repository.lastPartRow!['notes'], 'Keep ready for the next build.');
    expect(repository.lastPartRow!['part_id'], startsWith('NE-PART-'));
  });
}

Future<_QuickCaptureFixture> _fixture() async {
  return _QuickCaptureFixture(
    snapshot: AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath:
          'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
      isReady: true,
      issues: const <String>[],
      requiredFolders: const <String>[],
      missingFolders: const <String>[],
      missingFiles: const <String>[],
      summaryCards: const <AssetSummaryCard>[],
      equipmentCount: 0,
      partsCount: 0,
      guidanceNote: 'Connected.',
    ),
  );
}

class _QuickCaptureFixture {
  const _QuickCaptureFixture({required this.snapshot});

  final AssetWorkspaceSnapshot snapshot;
}

class _RecordingAssetRegisterRepository extends AssetRegisterRepository {
  _RecordingAssetRegisterRepository() : super(csvService: AssetCsvService());

  Map<String, String>? lastEquipmentRow;
  Map<String, String>? lastPartRow;

  @override
  Future<AssetCsvTable> appendEquipmentRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    lastEquipmentRow = Map<String, String>.from(row);
    return AssetCsvTable(
      headers: AssetRegisterRepository.equipmentHeaders,
      rows: [row],
    );
  }

  @override
  Future<AssetCsvTable> appendPartRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    lastPartRow = Map<String, String>.from(row);
    return AssetCsvTable(
      headers: AssetRegisterRepository.partsHeaders,
      rows: [row],
    );
  }
}
