import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/qr_label_printing_service.dart';

void main() {
  test('buildReadyQueuePdfBytes rejects an empty ready queue', () async {
    final service = _EmptyQueueQrLabelPrintService();

    expect(
      () => service.buildReadyQueuePdfBytes('D:/NEW_EARTH_ASSETS'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('No ready QR labels'),
        ),
      ),
    );
  });
}

class _EmptyQueueQrLabelPrintService extends QrLabelPrintService {
  _EmptyQueueQrLabelPrintService()
      : super(
          csvService: AssetCsvService(),
          workingDirectory: Directory.current,
        );

  @override
  Future<AssetCsvTable> readPrintQueue(String assetsRootPath) async {
    return const AssetCsvTable(
      headers: QrLabelPrintService.queueHeaders,
      rows: <Map<String, String>>[],
    );
  }
}
