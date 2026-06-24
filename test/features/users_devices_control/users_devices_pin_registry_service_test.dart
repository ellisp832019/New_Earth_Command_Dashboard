import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_pin_registry_service.dart';
import 'package:path/path.dart' as path;

void main() {
  test('PIN registry seeds and persists through the local database', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final service = UsersDevicesPinRegistryService(database: database);
    final snapshot = await service.loadSnapshot();

    expect(snapshot.records, isNotEmpty);
    expect(snapshot.activeCount, greaterThan(0));

    final selected = snapshot.records.first;
    final validation = await service.validatePinForUser(
      selected.userId,
      selected.pinCode,
    );
    expect(validation.allowed, isTrue);
    expect(validation.record?.pinId, selected.pinId);

    await service.setPrimaryPin(
      userId: selected.userId,
      pinCode: '135790',
      label: 'Primary PIN',
    );

    final updatedSnapshot = await service.loadSnapshot();
    final updatedPins = updatedSnapshot.recordsForUser(selected.userId);
    expect(
      updatedPins.where((pin) => pin.status == 'active'),
      hasLength(1),
    );
    expect(updatedPins.any((pin) => pin.pinCode == '135790'), isTrue);

    final recovery = await service.issueRecoveryPin(userId: selected.userId);
    expect(recovery.status, 'recovery');

    final recoveryValidation = await service.validatePinForUser(
      selected.userId,
      recovery.pinCode,
    );
    expect(recoveryValidation.allowed, isTrue);

    await service.revokeAllPinsForUser(selected.userId);
    final revokedSnapshot = await service.loadSnapshot();
    expect(
      revokedSnapshot.recordsForUser(selected.userId).every(
        (pin) => pin.status == 'revoked',
      ),
      isTrue,
    );
  });

  test('PIN registry imports an existing legacy local PIN file into SQLite', () async {
    final tempDir = await Directory.systemTemp.createTemp('pin_legacy_import_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final legacyPinFile = File(path.join(tempDir.path, 'pins.json'));
    await legacyPinFile.writeAsString(
      jsonEncode([
        {
          'pin_id': 'pin_peter_custom',
          'user_id': 'user_peter_owner',
          'label': 'Primary PIN',
          'pin_code': '4434',
          'status': 'active',
          'source_label': 'Legacy local file',
          'notes': 'Imported from the old local store.',
          'created_at': '2026-06-21T00:00:00.000Z',
          'updated_at': '2026-06-21T00:00:00.000Z',
        },
      ]),
    );

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final service = UsersDevicesPinRegistryService(
      database: database,
      legacyPinsFilePath: legacyPinFile.path,
    );

    final snapshot = await service.loadSnapshot();
    expect(snapshot.records.any((pin) => pin.pinCode == '4434'), isTrue);

    final validation = await service.validatePinForUser(
      'user_peter_owner',
      '4434',
    );
    expect(validation.allowed, isTrue);

    final storedPins = await database
        .customSelect(
          'SELECT pin_code FROM users_devices_control_pin_records WHERE user_id = ?',
          variables: [const Variable<String>('user_peter_owner')],
        )
        .get();
    expect(storedPins.any((row) => row.read<String>('pin_code') == '4434'), isTrue);
  });
}
