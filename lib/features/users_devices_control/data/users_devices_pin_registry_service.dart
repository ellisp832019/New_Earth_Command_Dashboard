import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

import '../../../core/database/app_database.dart';

class UsersDevicesPinRecord {
  const UsersDevicesPinRecord({
    required this.pinId,
    required this.userId,
    required this.label,
    required this.pinCode,
    required this.status,
    required this.sourceLabel,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
  });

  final String pinId;
  final String userId;
  final String label;
  final String pinCode;
  final String status;
  final String sourceLabel;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UsersDevicesPinRecord.fromJson(Map<String, dynamic> json) {
    return UsersDevicesPinRecord(
      pinId: json['pin_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      pinCode: json['pin_code'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      sourceLabel: json['source_label'] as String? ?? 'Local admin',
      notes: json['notes'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pin_id': pinId,
      'user_id': userId,
      'label': label,
      'pin_code': pinCode,
      'status': status,
      'source_label': sourceLabel,
      'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  UsersDevicesPinRecord copyWith({
    String? label,
    String? pinCode,
    String? status,
    String? sourceLabel,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsersDevicesPinRecord(
      pinId: pinId,
      userId: userId,
      label: label ?? this.label,
      pinCode: pinCode ?? this.pinCode,
      status: status ?? this.status,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UsersDevicesPinRegistrySnapshot {
  const UsersDevicesPinRegistrySnapshot({required this.records});

  final List<UsersDevicesPinRecord> records;

  List<UsersDevicesPinRecord> recordsForUser(String userId) {
    return records
        .where((record) => record.userId == userId)
        .toList(growable: false);
  }

  List<UsersDevicesPinRecord> primaryPinsForUser(String userId) {
    return records
        .where((record) => record.userId == userId && record.status == 'active')
        .toList(growable: false);
  }

  UsersDevicesPinRecord? primaryPinForUser(String userId) {
    final pins = primaryPinsForUser(userId);
    return pins.isEmpty ? null : pins.last;
  }

  List<UsersDevicesPinRecord> recoveryPinsForUser(String userId) {
    return records
        .where(
          (record) => record.userId == userId && record.status == 'recovery',
        )
        .toList(growable: false);
  }

  List<UsersDevicesPinRecord> revokedPinsForUser(String userId) {
    return records
        .where(
          (record) => record.userId == userId && record.status == 'revoked',
        )
        .toList(growable: false);
  }

  int get activeCount =>
      records.where((record) => record.status == 'active').length;

  int get recoveryCount =>
      records.where((record) => record.status == 'recovery').length;

  int get revokedCount =>
      records.where((record) => record.status == 'revoked').length;
}

class UsersDevicesPinAccessDecision {
  const UsersDevicesPinAccessDecision({
    required this.allowed,
    required this.reason,
    required this.nextStep,
    required this.issueCode,
    this.record,
  });

  final bool allowed;
  final String reason;
  final String nextStep;
  final String issueCode;
  final UsersDevicesPinRecord? record;
}

class UsersDevicesPinRegistryService {
  UsersDevicesPinRegistryService({
    this.database,
    this.moduleRootPath = 'modules/01_USERS_AND_DEVICES_CONTROL',
    this.storageNamespace = 'users_devices_control',
    this.legacyPinsFilePath,
  });

  final AppDatabase? database;
  final String moduleRootPath;
  final String storageNamespace;
  final String? legacyPinsFilePath;

  Future<UsersDevicesPinRegistrySnapshot> loadSnapshot() async {
    return UsersDevicesPinRegistrySnapshot(records: await _readPins());
  }

  Future<void> resetToSeedData() async {
    final db = database;
    if (db == null) {
      throw StateError('UsersDevicesPinRegistryService requires a database.');
    }

    await db.customStatement('DELETE FROM users_devices_control_pin_records');
    await _seedDatabaseFromJson(db);
  }

  Future<UsersDevicesPinRecord> setPrimaryPin({
    required String userId,
    required String pinCode,
    String label = 'Primary PIN',
    String sourceLabel = 'Local admin',
    String notes = '',
  }) async {
    final pins = await _readPins();
    final now = DateTime.now().toUtc();
    final updated = <UsersDevicesPinRecord>[
      for (final pin in pins)
        if (pin.userId == userId && pin.status == 'active')
          pin.copyWith(status: 'revoked', updatedAt: now)
        else
          pin,
      UsersDevicesPinRecord(
        pinId: 'pin_${now.microsecondsSinceEpoch}',
        userId: userId,
        label: label,
        pinCode: pinCode,
        status: 'active',
        sourceLabel: sourceLabel,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await _writePins(updated);
    return updated.last;
  }

  Future<UsersDevicesPinRecord> issueRecoveryPin({
    required String userId,
    String label = 'Recovery PIN',
    String sourceLabel = 'Local admin',
    String notes = 'Use this if the primary PIN is lost.',
  }) async {
    final now = DateTime.now().toUtc();
    final recoveryPin = _generateNumericPin(6);
    final pins = await _readPins();
    final record = UsersDevicesPinRecord(
      pinId: 'pin_${now.microsecondsSinceEpoch}',
      userId: userId,
      label: label,
      pinCode: recoveryPin,
      status: 'recovery',
      sourceLabel: sourceLabel,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    final updated = <UsersDevicesPinRecord>[
      for (final pin in pins)
        if (pin.userId == userId && pin.status == 'recovery')
          pin.copyWith(status: 'revoked', updatedAt: now)
        else
          pin,
      record,
    ];
    await _writePins(updated);
    return record;
  }

  Future<void> revokePin(String pinId) async {
    final pins = await _readPins();
    final now = DateTime.now().toUtc();
    var changed = false;
    final updated = <UsersDevicesPinRecord>[];
    for (final pin in pins) {
      if (pin.pinId == pinId) {
        changed = true;
        updated.add(pin.copyWith(status: 'revoked', updatedAt: now));
      } else {
        updated.add(pin);
      }
    }

    if (!changed) {
      throw StateError('PIN not found: $pinId');
    }

    await _writePins(updated);
  }

  Future<void> revokeAllPinsForUser(String userId) async {
    final pins = await _readPins();
    final now = DateTime.now().toUtc();
    final updated = pins
        .map(
          (pin) => pin.userId == userId && pin.status != 'revoked'
              ? pin.copyWith(status: 'revoked', updatedAt: now)
              : pin,
        )
        .toList(growable: false);
    await _writePins(updated);
  }

  Future<UsersDevicesPinAccessDecision> validatePinForUser(
    String userId,
    String pinCode,
  ) async {
    final snapshot = await loadSnapshot();
    final primaryPin = snapshot.primaryPinForUser(userId);
    final recoveryPins = snapshot.recoveryPinsForUser(userId);

    if (primaryPin == null && recoveryPins.isEmpty) {
      return const UsersDevicesPinAccessDecision(
        allowed: false,
        reason: 'No local PIN is configured for this user.',
        nextStep: 'Open PIN Registry and add or restore a PIN first.',
        issueCode: 'missing_pin',
      );
    }

    if (primaryPin != null && primaryPin.pinCode == pinCode) {
      return UsersDevicesPinAccessDecision(
        allowed: true,
        reason: 'Primary PIN matched the selected identity.',
        nextStep: 'The session can unlock normally.',
        issueCode: 'primary_allowed',
        record: primaryPin,
      );
    }

    for (final record in recoveryPins) {
      if (record.pinCode == pinCode) {
        return UsersDevicesPinAccessDecision(
          allowed: true,
          reason: 'Recovery PIN matched the selected identity.',
          nextStep:
              'Unlock can continue, but this recovery PIN should be revoked after use and replaced with a fresh primary PIN if needed.',
          issueCode: 'recovery_allowed',
          record: record,
        );
      }
    }

    if (primaryPin == null && recoveryPins.isNotEmpty) {
      return const UsersDevicesPinAccessDecision(
        allowed: false,
        reason: 'This user does not have an active primary PIN right now.',
        nextStep:
            'Use the latest recovery PIN from PIN Registry, then set a fresh primary PIN after unlock.',
        issueCode: 'primary_missing_recovery_available',
      );
    }

    return UsersDevicesPinAccessDecision(
      allowed: false,
      reason: 'Local PIN did not match the selected identity.',
      nextStep: recoveryPins.isNotEmpty
          ? 'Check the primary PIN first, or use the latest recovery PIN from PIN Registry.'
          : 'Check the PIN Registry or set a fresh primary PIN.',
      issueCode: 'pin_mismatch',
    );
  }

  Future<List<UsersDevicesPinRecord>> _readPins() async {
    final db = database;
    if (db == null) {
      throw StateError('UsersDevicesPinRegistryService requires a database.');
    }

    await _migrateLegacyPinsIfNeeded();
    final rows = await db
        .customSelect(
          'SELECT pin_id, user_id, label, pin_code, status, source_label, notes, created_at, updated_at '
          'FROM users_devices_control_pin_records ORDER BY created_at ASC',
        )
        .get();
    if (rows.isNotEmpty) {
      return rows.map((row) => _recordFromRow(row)).toList(growable: false);
    }

    await _seedDatabaseFromJson(db);
    final seededRows = await db
        .customSelect(
          'SELECT pin_id, user_id, label, pin_code, status, source_label, notes, created_at, updated_at '
          'FROM users_devices_control_pin_records ORDER BY created_at ASC',
        )
        .get();
    return seededRows.map((row) => _recordFromRow(row)).toList(growable: false);
  }

  Future<void> _migrateLegacyPinsIfNeeded() async {
    final legacyPath = legacyPinsFilePath;
    if (legacyPath == null || legacyPath.isEmpty) {
      return;
    }

    final file = File(legacyPath);
    if (!await file.exists()) {
      return;
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      await file.delete();
      return;
    }

    final records = decoded
        .whereType<Map<String, dynamic>>()
        .map(UsersDevicesPinRecord.fromJson)
        .toList(growable: false);

    if (records.isEmpty) {
      await file.delete();
      return;
    }

    await _writePins(records);
    await file.delete();
  }

  Future<void> _writePins(List<UsersDevicesPinRecord> pins) async {
    final db = database;
    if (db == null) {
      throw StateError('UsersDevicesPinRegistryService requires a database.');
    }

    await db.transaction(() async {
      await db.customStatement('DELETE FROM users_devices_control_pin_records');
      for (final pin in pins) {
        await db.customInsert(
          'INSERT INTO users_devices_control_pin_records '
          '(pin_id, user_id, label, pin_code, status, source_label, notes, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable<String>(pin.pinId),
            Variable<String>(pin.userId),
            Variable<String>(pin.label),
            Variable<String>(pin.pinCode),
            Variable<String>(pin.status),
            Variable<String>(pin.sourceLabel),
            Variable<String>(pin.notes),
            Variable<String>(pin.createdAt.toUtc().toIso8601String()),
            Variable<String>(pin.updatedAt.toUtc().toIso8601String()),
          ],
        );
      }
    });
  }

  Future<void> _seedDatabaseFromJson(AppDatabase db) async {
    final fallbackFile = File(_examplePinsPath);
    if (!await fallbackFile.exists()) {
      return;
    }

    final raw = await fallbackFile.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return;
    }

    final records = decoded
        .whereType<Map<String, dynamic>>()
        .map(UsersDevicesPinRecord.fromJson)
        .toList(growable: false);

    await db.transaction(() async {
      await db.customStatement('DELETE FROM users_devices_control_pin_records');
      for (final pin in records) {
        await db.customInsert(
          'INSERT INTO users_devices_control_pin_records '
          '(pin_id, user_id, label, pin_code, status, source_label, notes, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable<String>(pin.pinId),
            Variable<String>(pin.userId),
            Variable<String>(pin.label),
            Variable<String>(pin.pinCode),
            Variable<String>(pin.status),
            Variable<String>(pin.sourceLabel),
            Variable<String>(pin.notes),
            Variable<String>(pin.createdAt.toUtc().toIso8601String()),
            Variable<String>(pin.updatedAt.toUtc().toIso8601String()),
          ],
        );
      }
      if (records.isEmpty) {
        final now = DateTime.now().toUtc();
        await db.customInsert(
          'INSERT INTO users_devices_control_pin_records '
          '(pin_id, user_id, label, pin_code, status, source_label, notes, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable<String>('pin_${now.microsecondsSinceEpoch}'),
            const Variable<String>('user_peter_owner'),
            const Variable<String>('Primary PIN'),
            Variable<String>(_generateNumericPin(6)),
            const Variable<String>('active'),
            const Variable<String>('Seed data'),
            const Variable<String>('Seeded fallback PIN record.'),
            Variable<String>(now.toIso8601String()),
            Variable<String>(now.toIso8601String()),
          ],
        );
      }
    });
  }

  UsersDevicesPinRecord _recordFromRow(dynamic row) {
    return UsersDevicesPinRecord(
      pinId: row.read<String>('pin_id'),
      userId: row.read<String>('user_id'),
      label: row.read<String>('label'),
      pinCode: row.read<String>('pin_code'),
      status: row.read<String>('status'),
      sourceLabel: row.read<String>('source_label'),
      notes: row.read<String>('notes'),
      createdAt:
          DateTime.tryParse(row.read<String>('created_at')) ??
          DateTime.now().toUtc(),
      updatedAt:
          DateTime.tryParse(row.read<String>('updated_at')) ??
          DateTime.now().toUtc(),
    );
  }

  String get _examplePinsPath =>
      path.join(moduleRootPath, 'data', 'pins.example.json');

  String _generateNumericPin(int length) {
    final random = Random();
    return List.generate(length, (_) => random.nextInt(10)).join();
  }
}
