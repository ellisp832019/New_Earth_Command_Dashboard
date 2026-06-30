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
    expect(updatedPins.where((pin) => pin.status == 'active'), hasLength(1));
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
      revokedSnapshot
          .recordsForUser(selected.userId)
          .every((pin) => pin.status == 'revoked'),
      isTrue,
    );
  });

  test(
    'PIN registry imports an existing legacy local PIN file into SQLite',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'pin_legacy_import_',
      );
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
      expect(
        storedPins.any((row) => row.read<String>('pin_code') == '4434'),
        isTrue,
      );
    },
  );

  test(
    'PIN registry locks a user after repeated failed attempts and clears after cooldown',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      var now = DateTime.utc(2026, 6, 26, 9, 0, 0);
      final service = UsersDevicesPinRegistryService(
        database: database,
        maxFailedAttempts: 3,
        lockoutDuration: const Duration(minutes: 5),
        nowProvider: () => now,
      );

      final snapshot = await service.loadSnapshot();
      final selected = snapshot.records.firstWhere(
        (record) => record.status == 'active',
      );

      final firstFailure = await service.validatePinForUser(
        selected.userId,
        '000000',
      );
      expect(firstFailure.allowed, isFalse);
      expect(firstFailure.issueCode, 'pin_mismatch');
      expect(firstFailure.failedAttempts, 1);
      expect(firstFailure.remainingAttempts, 2);

      final secondFailure = await service.validatePinForUser(
        selected.userId,
        '000000',
      );
      expect(secondFailure.allowed, isFalse);
      expect(secondFailure.issueCode, 'pin_mismatch');
      expect(secondFailure.failedAttempts, 2);
      expect(secondFailure.remainingAttempts, 1);

      final thirdFailure = await service.validatePinForUser(
        selected.userId,
        '000000',
      );
      expect(thirdFailure.allowed, isFalse);
      expect(thirdFailure.issueCode, 'locked_out_triggered');
      expect(thirdFailure.failedAttempts, 3);
      expect(thirdFailure.remainingAttempts, 0);
      expect(thirdFailure.lockedUntil, isA<DateTime>());

      final blockedValidPin = await service.validatePinForUser(
        selected.userId,
        selected.pinCode,
      );
      expect(blockedValidPin.allowed, isFalse);
      expect(blockedValidPin.issueCode, 'locked_out_active');

      now = now.add(const Duration(minutes: 6));
      final postCooldownSuccess = await service.validatePinForUser(
        selected.userId,
        selected.pinCode,
      );
      expect(postCooldownSuccess.allowed, isTrue);
      expect(postCooldownSuccess.issueCode, 'primary_allowed');

      final lockoutRows = await database
          .customSelect(
            'SELECT failed_attempts FROM users_devices_control_pin_lockouts WHERE user_id = ?',
            variables: [Variable<String>(selected.userId)],
          )
          .get();
      expect(lockoutRows, isEmpty);
    },
  );

  test(
    'successful unlock clears earlier failed attempts before the next mismatch',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final service = UsersDevicesPinRegistryService(
        database: database,
        maxFailedAttempts: 3,
      );

      final snapshot = await service.loadSnapshot();
      final selected = snapshot.records.firstWhere(
        (record) => record.status == 'active',
      );

      final firstFailure = await service.validatePinForUser(
        selected.userId,
        '999999',
      );
      expect(firstFailure.failedAttempts, 1);

      final success = await service.validatePinForUser(
        selected.userId,
        selected.pinCode,
      );
      expect(success.allowed, isTrue);

      final laterFailure = await service.validatePinForUser(
        selected.userId,
        '999999',
      );
      expect(laterFailure.allowed, isFalse);
      expect(laterFailure.issueCode, 'pin_mismatch');
      expect(laterFailure.failedAttempts, 1);
      expect(laterFailure.remainingAttempts, 2);
    },
  );

  test(
    'active lockout stays distinguishable from a new lockout trigger',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      var now = DateTime.utc(2026, 6, 26, 10, 0, 0);
      final service = UsersDevicesPinRegistryService(
        database: database,
        maxFailedAttempts: 2,
        lockoutDuration: const Duration(minutes: 3),
        nowProvider: () => now,
      );

      final snapshot = await service.loadSnapshot();
      final selected = snapshot.records.firstWhere(
        (record) => record.status == 'active',
      );

      final firstFailure = await service.validatePinForUser(
        selected.userId,
        '111111',
      );
      expect(firstFailure.issueCode, 'pin_mismatch');

      final triggerFailure = await service.validatePinForUser(
        selected.userId,
        '111111',
      );
      expect(triggerFailure.issueCode, 'locked_out_triggered');
      expect(triggerFailure.lockedUntil, isA<DateTime>());

      now = now.add(const Duration(seconds: 30));
      final activeLockout = await service.validatePinForUser(
        selected.userId,
        '111111',
      );
      expect(activeLockout.issueCode, 'locked_out_active');
      expect(activeLockout.lockedUntil, triggerFailure.lockedUntil);
    },
  );

  test(
    'PIN and lockout state survive a fresh service reload',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      var now = DateTime.utc(2026, 6, 27, 10, 0, 0);
      final service = UsersDevicesPinRegistryService(
        database: database,
        maxFailedAttempts: 2,
        lockoutDuration: const Duration(minutes: 4),
        nowProvider: () => now,
      );

      final snapshot = await service.loadSnapshot();
      final selected = snapshot.records.firstWhere(
        (record) => record.status == 'active',
      );

      await service.setPrimaryPin(
        userId: selected.userId,
        pinCode: '4434',
        notes: 'Reload persistence test primary PIN.',
      );
      now = now.add(const Duration(seconds: 1));
      final recovery = await service.issueRecoveryPin(userId: selected.userId);

      await service.validatePinForUser(selected.userId, '000000');
      final triggerFailure = await service.validatePinForUser(
        selected.userId,
        '000000',
      );
      expect(triggerFailure.issueCode, 'locked_out_triggered');

      final reloaded = UsersDevicesPinRegistryService(
        database: database,
        maxFailedAttempts: 2,
        lockoutDuration: const Duration(minutes: 4),
        nowProvider: () => now,
      );

      final reloadedSnapshot = await reloaded.loadSnapshot();
      expect(
        reloadedSnapshot.primaryPinForUser(selected.userId)?.pinCode,
        '4434',
      );
      expect(
        reloadedSnapshot.recoveryPinsForUser(selected.userId).any(
          (pin) => pin.pinCode == recovery.pinCode,
        ),
        isTrue,
      );
      expect(
        reloadedSnapshot.lockoutForUser(selected.userId)?.isLockedAt(now),
        isTrue,
      );
    },
  );
}
