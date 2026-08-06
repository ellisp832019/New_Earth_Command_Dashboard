import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'company_command_centre_config.dart';

final companyCommandCentreWriteServiceProvider =
    Provider<CompanyCommandCentreWriteService>(
      (ref) => const CompanyCommandCentreWriteService(),
    );

class CompanyCommandCentreWriteService {
  const CompanyCommandCentreWriteService({
    this.moduleConfigPath = companyCommandCentreModuleConfigPath,
    this.omegaOsPath = companyCommandCentreOmegaOsPath,
    this.now,
  });

  final String moduleConfigPath;
  final String omegaOsPath;
  final DateTime Function()? now;

  Future<CompanyCommandCentreWritePlan> loadPlan() async {
    final config = await _readJsonMap(moduleConfigPath);
    final configuredOmegaPath = _stringValue(config, const [
      'omegaPath',
      'omega_os_path',
    ]);
    final effectiveOmegaPath = configuredOmegaPath.isNotEmpty
        ? configuredOmegaPath
        : omegaOsPath;
    final readOnly = _boolValue(config, const [
      'readOnly',
      'read_only',
    ], fallback: true);
    final backupBeforeWrite = _boolValue(config, const [
      'backupBeforeWrite',
      'backup_before_write',
    ], fallback: true);

    return CompanyCommandCentreWritePlan(
      moduleConfigPath: moduleConfigPath,
      moduleConfigExists: File(moduleConfigPath).existsSync(),
      omegaPath: effectiveOmegaPath,
      omegaPathExists: Directory(effectiveOmegaPath).existsSync(),
      readOnly: readOnly,
      backupBeforeWrite: backupBeforeWrite,
      backupRootPath: path.join(
        effectiveOmegaPath,
        'backups',
        'company_command_centre',
      ),
      auditLogPath: path.join(
        effectiveOmegaPath,
        'audit',
        'company_command_centre_write_audit.jsonl',
      ),
    );
  }

  Future<CompanyCommandCentreWriteResult> writeMarkdownFile({
    required String relativePath,
    required String contents,
    required String actorLabel,
    required String note,
  }) async {
    final plan = await loadPlan();
    if (plan.readOnly) {
      return CompanyCommandCentreWriteResult.failure(
        message:
            'Write mode is disabled. Switch the module out of read-only mode first.',
        plan: plan,
      );
    }

    if (!plan.omegaPathExists) {
      return CompanyCommandCentreWriteResult.failure(
        message: 'The Omega OS company path is not available yet.',
        plan: plan,
      );
    }

    final targetPath = _resolveWithinRoot(plan.omegaPath, relativePath);
    final targetFile = File(targetPath);
    await targetFile.parent.create(recursive: true);

    String? backupPath;
    if (plan.backupBeforeWrite && await targetFile.exists()) {
      backupPath = await _createTimestampedBackup(
        sourceFile: targetFile,
        backupRootPath: plan.backupRootPath,
        relativePath: relativePath,
      );
    }

    await targetFile.writeAsString(contents);

    final auditEntry = CompanyCommandCentreAuditEntry(
      id: _buildEntryId(),
      timestamp: _now().toUtc(),
      action: 'write_markdown',
      targetPath: targetPath,
      backupPath: backupPath,
      actorLabel: actorLabel.trim(),
      note: note.trim(),
      result: 'success',
    );
    await _appendAuditEntry(plan.auditLogPath, auditEntry);

    return CompanyCommandCentreWriteResult.success(
      plan: plan,
      targetPath: targetPath,
      backupPath: backupPath,
      auditLogPath: plan.auditLogPath,
      message: 'Saved ${path.basename(targetPath)} with a backup-first write.',
    );
  }

  Future<CompanyCommandCentreWriteResult> setReadOnlyMode({
    required bool readOnly,
    required String actorLabel,
    required String note,
  }) async {
    final plan = await loadPlan();
    if (!plan.moduleConfigExists) {
      return CompanyCommandCentreWriteResult.failure(
        message:
            'Module config is missing, so the write toggle cannot be saved.',
        plan: plan,
      );
    }

    final configFile = File(plan.moduleConfigPath);
    final config = await _readJsonMap(plan.moduleConfigPath);
    final currentReadOnly = _boolValue(config, const [
      'readOnly',
      'read_only',
    ], fallback: true);
    if (currentReadOnly == readOnly) {
      return CompanyCommandCentreWriteResult.success(
        plan: plan,
        targetPath: configFile.path,
        message: readOnly
            ? 'Read-only mode is already enabled.'
            : 'Write mode is already enabled.',
      );
    }

    await configFile.parent.create(recursive: true);
    String? backupPath;
    if (await configFile.exists()) {
      backupPath = await _createConfigBackup(configFile);
    }

    final updatedConfig = Map<String, dynamic>.from(config)
      ..['readOnly'] = readOnly;
    await configFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(updatedConfig),
    );

    final auditEntry = CompanyCommandCentreAuditEntry(
      id: _buildEntryId(),
      timestamp: _now().toUtc(),
      action: 'update_read_only_mode',
      targetPath: configFile.path,
      backupPath: backupPath,
      actorLabel: actorLabel.trim(),
      note: note.trim(),
      result: 'success',
    );
    await _appendAuditEntry(plan.auditLogPath, auditEntry);

    return CompanyCommandCentreWriteResult.success(
      plan: plan,
      targetPath: configFile.path,
      backupPath: backupPath,
      auditLogPath: plan.auditLogPath,
      message: readOnly
          ? 'Read-only mode enabled.'
          : 'Write mode enabled for local company changes.',
    );
  }

  Future<CompanyCommandCentreWriteResult> exportAuditSummaryReport({
    required String actorLabel,
    required String note,
  }) async {
    final plan = await loadPlan();
    if (!plan.omegaPathExists) {
      return CompanyCommandCentreWriteResult.failure(
        message: 'The Omega OS company path is not available yet.',
        plan: plan,
      );
    }

    final auditEntries = await _readAuditEntries(plan.auditLogPath);
    final reportPath = path.join(
      plan.omegaPath,
      'reports',
      'company_command_centre_audit_summary.md',
    );
    final reportFile = File(reportPath);
    await reportFile.parent.create(recursive: true);

    String? backupPath;
    if (await reportFile.exists()) {
      backupPath = await _createTimestampedBackup(
        sourceFile: reportFile,
        backupRootPath: plan.backupRootPath,
        relativePath: path.join(
          'reports',
          'company_command_centre_audit_summary.md',
        ),
      );
    }

    final report = _buildAuditSummaryReport(
      plan: plan,
      auditEntries: auditEntries,
    );
    await reportFile.writeAsString(report);

    final auditEntry = CompanyCommandCentreAuditEntry(
      id: _buildEntryId(),
      timestamp: _now().toUtc(),
      action: 'export_audit_summary',
      targetPath: reportPath,
      backupPath: backupPath,
      actorLabel: actorLabel.trim(),
      note: note.trim(),
      result: 'success',
    );
    await _appendAuditEntry(plan.auditLogPath, auditEntry);

    return CompanyCommandCentreWriteResult.success(
      plan: plan,
      targetPath: reportPath,
      backupPath: backupPath,
      auditLogPath: plan.auditLogPath,
      message: 'Exported the audit summary report.',
    );
  }

  Future<String> _createTimestampedBackup({
    required File sourceFile,
    required String backupRootPath,
    required String relativePath,
  }) async {
    final stamp = _timestampStamp(_now());
    final backupFilePath = path.join(
      backupRootPath,
      stamp,
      _cleanRelativePath(relativePath),
    );
    final backupFile = File(backupFilePath);
    await backupFile.parent.create(recursive: true);
    await sourceFile.copy(backupFile.path);
    return backupFile.path;
  }

  Future<String> _createConfigBackup(File sourceFile) {
    return _createTimestampedBackup(
      sourceFile: sourceFile,
      backupRootPath: path.join(
        sourceFile.parent.path,
        'backups',
        'company_command_centre_config',
      ),
      relativePath: path.basename(sourceFile.path),
    );
  }

  Future<void> _appendAuditEntry(
    String auditLogPath,
    CompanyCommandCentreAuditEntry entry,
  ) async {
    final auditFile = File(auditLogPath);
    await auditFile.parent.create(recursive: true);
    await auditFile.writeAsString(
      '${jsonEncode(entry.toJson())}\n',
      mode: FileMode.append,
    );
  }

  Future<List<CompanyCommandCentreAuditEntry>> _readAuditEntries(
    String auditLogPath,
  ) async {
    final auditFile = File(auditLogPath);
    if (!await auditFile.exists()) {
      return const <CompanyCommandCentreAuditEntry>[];
    }

    final entries = <CompanyCommandCentreAuditEntry>[];
    for (final rawLine in await auditFile.readAsLines()) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          entries.add(CompanyCommandCentreAuditEntry.fromJson(decoded));
        } else if (decoded is Map) {
          entries.add(
            CompanyCommandCentreAuditEntry.fromJson(
              decoded.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      } catch (_) {
        continue;
      }
    }
    return entries;
  }

  String _buildAuditSummaryReport({
    required CompanyCommandCentreWritePlan plan,
    required List<CompanyCommandCentreAuditEntry> auditEntries,
  }) {
    final latestEntries = auditEntries.length <= 12
        ? auditEntries
        : auditEntries.sublist(auditEntries.length - 12);
    final buffer = StringBuffer()
      ..writeln('# Company Command Centre Audit Summary')
      ..writeln()
      ..writeln('- Generated: ${_now().toUtc().toIso8601String()}')
      ..writeln('- Omega OS path: ${plan.omegaPath}')
      ..writeln('- Read-only: ${plan.readOnly}')
      ..writeln('- Backup before write: ${plan.backupBeforeWrite}')
      ..writeln('- Audit entries: ${auditEntries.length}')
      ..writeln('- Backup root: ${plan.backupRootPath}')
      ..writeln()
      ..writeln('## Recent audit entries');

    if (latestEntries.isEmpty) {
      buffer.writeln('- No audit entries have been recorded yet.');
    } else {
      for (final entry in latestEntries.reversed) {
        buffer
          ..writeln('- ${entry.timestamp.toUtc().toIso8601String()}')
          ..writeln('  - Action: ${entry.action}')
          ..writeln('  - Target: ${entry.targetPath}')
          ..writeln('  - Result: ${entry.result}')
          ..writeln(
            '  - Note: ${entry.note.isEmpty ? 'No note provided.' : entry.note}',
          );
        if (entry.backupPath != null && entry.backupPath!.isNotEmpty) {
          buffer.writeln('  - Backup: ${entry.backupPath}');
        }
      }
    }

    return buffer.toString();
  }

  String _resolveWithinRoot(String rootPath, String relativePath) {
    final cleanedRelativePath = _cleanRelativePath(relativePath);
    final resolvedPath = path.normalize(
      path.join(rootPath, cleanedRelativePath),
    );
    if (!path.isWithin(path.normalize(rootPath), resolvedPath) &&
        path.normalize(rootPath) != resolvedPath) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'The target must stay within the Omega OS company root.',
      );
    }
    return resolvedPath;
  }

  String _cleanRelativePath(String relativePath) {
    final trimmed = relativePath.trim().replaceAll('\\', '/');
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'A relative path is required.',
      );
    }
    if (path.isAbsolute(trimmed)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Absolute paths are not allowed.',
      );
    }
    final parts = path.split(trimmed);
    if (parts.any((part) => part == '..')) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Path traversal is not allowed.',
      );
    }
    return path.joinAll(parts);
  }

  Future<Map<String, dynamic>> _readJsonMap(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  String _stringValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  bool _boolValue(
    Map<String, dynamic> data,
    List<String> keys, {
    required bool fallback,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value is bool) {
        return value;
      }
      if (value == null) {
        continue;
      }

      final text = value.toString().trim().toLowerCase();
      if (text == 'true' || text == 'yes' || text == '1') {
        return true;
      }
      if (text == 'false' || text == 'no' || text == '0') {
        return false;
      }
    }

    return fallback;
  }

  DateTime _now() => now?.call() ?? DateTime.now();

  String _buildEntryId() {
    final stamp = _now().toUtc().toIso8601String().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    return 'company-write-$stamp';
  }

  String _timestampStamp(DateTime value) {
    final utc = value.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    return '$year$month${day}_$hour$minute$second';
  }
}

class CompanyCommandCentreWritePlan {
  const CompanyCommandCentreWritePlan({
    required this.moduleConfigPath,
    required this.moduleConfigExists,
    required this.omegaPath,
    required this.omegaPathExists,
    required this.readOnly,
    required this.backupBeforeWrite,
    required this.backupRootPath,
    required this.auditLogPath,
  });

  final String moduleConfigPath;
  final bool moduleConfigExists;
  final String omegaPath;
  final bool omegaPathExists;
  final bool readOnly;
  final bool backupBeforeWrite;
  final String backupRootPath;
  final String auditLogPath;
}

class CompanyCommandCentreWriteResult {
  const CompanyCommandCentreWriteResult._({
    required this.success,
    required this.message,
    required this.plan,
    this.targetPath,
    this.backupPath,
    this.auditLogPath,
  });

  factory CompanyCommandCentreWriteResult.success({
    required CompanyCommandCentreWritePlan plan,
    required String targetPath,
    required String message,
    String? backupPath,
    String? auditLogPath,
  }) {
    return CompanyCommandCentreWriteResult._(
      success: true,
      message: message,
      plan: plan,
      targetPath: targetPath,
      backupPath: backupPath,
      auditLogPath: auditLogPath,
    );
  }

  factory CompanyCommandCentreWriteResult.failure({
    required CompanyCommandCentreWritePlan plan,
    required String message,
  }) {
    return CompanyCommandCentreWriteResult._(
      success: false,
      message: message,
      plan: plan,
    );
  }

  final bool success;
  final String message;
  final CompanyCommandCentreWritePlan plan;
  final String? targetPath;
  final String? backupPath;
  final String? auditLogPath;
}

class CompanyCommandCentreAuditEntry {
  const CompanyCommandCentreAuditEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.targetPath,
    required this.actorLabel,
    required this.note,
    required this.result,
    this.backupPath,
  });

  final String id;
  final DateTime timestamp;
  final String action;
  final String targetPath;
  final String? backupPath;
  final String actorLabel;
  final String note;
  final String result;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'target_path': targetPath,
      'backup_path': backupPath,
      'actor_label': actorLabel,
      'note': note,
      'result': result,
    };
  }

  factory CompanyCommandCentreAuditEntry.fromJson(Map<String, dynamic> json) {
    return CompanyCommandCentreAuditEntry(
      id: (json['id'] ?? '').toString(),
      timestamp:
          DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      action: (json['action'] ?? '').toString(),
      targetPath: (json['target_path'] ?? '').toString(),
      backupPath: json['backup_path']?.toString(),
      actorLabel: (json['actor_label'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      result: (json['result'] ?? '').toString(),
    );
  }
}
