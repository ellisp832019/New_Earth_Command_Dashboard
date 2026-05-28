import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/qr_label_register_screen.dart';

void main() {
  test('qr label register uses the expected headers', () {
    expect(AssetRegisterRepository.qrLabelHeaders, isNotEmpty);
    expect(AssetRegisterRepository.qrLabelHeaders.first, 'asset_id');
  });

  testWidgets('qr label register shows labels and route', (tester) async {
    final fixture = _fixture();
    final router = GoRouter(
      initialLocation: RouteNames.assetQrLabelRegister,
      routes: [
        GoRoute(
          path: RouteNames.assetQrLabelRegister,
          builder: (context, state) => const QrLabelRegisterScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetQrLabelRegisterProvider.overrideWith(
            (ref) async => fixture.table,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('QR Labels'), findsOneWidget);
    expect(find.text('NE-EQ-0001'), findsOneWidget);
    expect(find.text('NE-EQ-0001-QR'), findsOneWidget);
    expect(find.text('Missing codes'), findsOneWidget);
  });

  testWidgets('qr label register supports an empty state', (tester) async {
    final fixture = _fixture(empty: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetQrLabelRegisterProvider.overrideWith(
            (ref) async => fixture.table,
          ),
        ],
        child: const MaterialApp(home: QrLabelRegisterScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('No QR labels yet'), findsOneWidget);
  });
}

_QrFixture _fixture({bool empty = false}) {
  final rows = empty
      ? <Map<String, String>>[]
      : [
          {
            'asset_id': 'NE-EQ-0001',
            'label_code': 'NE-EQ-0001-QR',
            'qr_target': 'asset-search:NE-EQ-0001',
            'file_or_url': 'assets/NE-EQ-0001.md',
            'status': 'pending',
            'printed_date': '2026-05-28',
            'notes': 'Print on durable stock.',
          },
        ];

  return _QrFixture(
    snapshot: const AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
      isReady: true,
      issues: <String>[],
      requiredFolders: AssetFolderService.requiredFolders,
      missingFolders: <String>[],
      missingFiles: <String>[],
      summaryCards: <AssetSummaryCard>[],
      equipmentCount: 1,
      partsCount: 0,
      guidanceNote: 'Connected.',
    ),
    table: AssetCsvTable(
      headers: AssetRegisterRepository.qrLabelHeaders,
      rows: rows,
    ),
  );
}

class _QrFixture {
  const _QrFixture({
    required this.snapshot,
    required this.table,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable table;
}
