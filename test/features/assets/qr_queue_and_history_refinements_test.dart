import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/qr_label_printing_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/qr_label_history_screen.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/qr_print_queue_screen.dart';

void main() {
  testWidgets('qr print queue surfaces history and retry only on retry rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith(
            (ref) async => const AssetWorkspaceSnapshot(
              configPath: 'config/local_paths.json',
              assetsRootPath:
                  'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
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
          ),
          assetQrPrintQueueProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.queueHeaders,
              rows: const [
                {
                  'queue_id': 'queue-001',
                  'asset_id': 'NE-EQ-0001',
                  'label_type': 'Asset label',
                  'label_size': '50 x 30 mm',
                  'priority': 'normal',
                  'status': 'queued',
                  'generated_file': 'D:/queue/generated/queue-001.pdf',
                  'printer_profile': 'ETIKEZ PM260',
                  'notes': '',
                },
                {
                  'queue_id': 'queue-002',
                  'asset_id': 'NE-EQ-0002',
                  'label_type': 'Asset label',
                  'label_size': '50 x 30 mm',
                  'priority': 'normal',
                  'status': 'reprint_needed',
                  'generated_file': 'D:/queue/generated/queue-002.pdf',
                  'printer_profile': 'ETIKEZ PM260',
                  'notes': '',
                },
              ],
            ),
          ),
        ],
        child: const MaterialApp(home: QrPrintQueueScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Queue summary'), findsOneWidget);
    expect(
      find.text(
        'The queue stays readable by separating labels ready to print, labels that need another try, and labels already completed.',
      ),
      findsOneWidget,
    );
    expect(find.text('Ready: 1'), findsOneWidget);
    expect(find.text('Retry: 1'), findsOneWidget);
    expect(find.text('Printed: 0'), findsOneWidget);
    expect(find.text('Applied: 0'), findsOneWidget);
    expect(find.text('Open History'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Retry now'), findsOneWidget);
  });

  testWidgets('qr label history groups exports into a dedicated card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith(
            (ref) async => const AssetWorkspaceSnapshot(
              configPath: 'config/local_paths.json',
              assetsRootPath:
                  'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
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
          ),
          assetQrLabelTemplateRegisterProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.labelRegisterHeaders,
              rows: const [
                {
                  'label_id': 'label-001',
                  'asset_id': 'NE-EQ-0001',
                  'label_type': 'Asset label',
                  'label_size': '50 x 30 mm',
                  'print_status': 'printed',
                  'generated_file': 'D:/history/generated/label-001.pdf',
                  'manifest_file': 'D:/history/generated/label-001.json',
                  'printed_date': '2026-05-28',
                  'applied_date': '2026-05-29',
                  'location': 'Desk',
                  'notes': 'Ready for file.',
                },
              ],
            ),
          ),
          assetQrPrintQueueProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.queueHeaders,
              rows: const [
                {
                  'queue_id': 'queue-001',
                  'asset_id': 'NE-EQ-0001',
                  'label_type': 'Asset label',
                  'label_size': '50 x 30 mm',
                  'priority': 'normal',
                  'status': 'printed',
                  'generated_file': 'D:/history/generated/label-001.pdf',
                  'printer_profile': 'ETIKEZ PM260',
                  'manifest_file': 'D:/history/generated/label-001.json',
                  'notes': '',
                },
              ],
            ),
          ),
        ],
        child: const MaterialApp(home: QrLabelHistoryScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('History exports'), findsOneWidget);
    expect(find.text('Export recent'), findsOneWidget);
    expect(find.text('Print recent'), findsOneWidget);
    expect(find.text('Open export folder'), findsOneWidget);
    expect(find.textContaining(' |  Applied: '), findsOneWidget);
    expect(find.text('Print Queue'), findsOneWidget);
  });

  testWidgets('qr label history can edit and delete register entries', (
    tester,
  ) async {
    final service = _FakeQrLabelPrintService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith(
            (ref) async => const AssetWorkspaceSnapshot(
              configPath: 'config/local_paths.json',
              assetsRootPath:
                  'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
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
          ),
          assetQrLabelPrintServiceProvider.overrideWithValue(service),
          assetQrLabelTemplateRegisterProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.labelRegisterHeaders,
              rows: const [
                {
                  'label_id': 'label-001',
                  'asset_id': 'NE-EQ-0001',
                  'label_type': 'Asset label',
                  'label_size': '50 x 30 mm',
                  'print_status': 'printed',
                  'generated_file': 'D:/history/generated/label-001.pdf',
                  'manifest_file': 'D:/history/generated/label-001.json',
                  'printed_date': '2026-05-28',
                  'applied_date': '2026-05-29',
                  'location': 'Desk',
                  'notes': 'Ready for file.',
                },
              ],
            ),
          ),
          assetQrPrintQueueProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.queueHeaders,
              rows: const [],
            ),
          ),
        ],
        child: const MaterialApp(home: QrLabelHistoryScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.scrollUntilVisible(
      find.text('Edit'),
      400.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Edit'), findsWidgets);
    expect(find.text('Delete'), findsWidgets);

    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();

    expect(find.text('Edit label entry'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);

    await tester.tap(find.text('Cancel').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete label entry?'), findsOneWidget);
    expect(find.text('Delete entry'), findsOneWidget);
  });
}

class _FakeQrLabelPrintService extends QrLabelPrintService {
  _FakeQrLabelPrintService()
      : super(csvService: AssetCsvService(), workingDirectory: Directory.current);

  String? updatedLabelId;
  String? deletedLabelId;

  @override
  Future<void> updateLabelRegisterEntry(
    String assetsRootPath,
    QrLabelRegisterEntry entry,
  ) async {
    updatedLabelId = entry.labelId;
  }

  @override
  Future<void> deleteLabelRegisterEntry(
    String assetsRootPath,
    String labelId,
  ) async {
    deletedLabelId = labelId;
  }
}
