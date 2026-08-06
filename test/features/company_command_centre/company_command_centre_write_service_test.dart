import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/company_command_centre/data/company_command_centre_write_service.dart';

void main() {
  test('write service blocks writes while read-only is enabled', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'company_command_read_only_',
    );
    addTearDown(() => tempRoot.deleteSync(recursive: true));

    final omegaRoot = Directory(path.join(tempRoot.path, 'omega_company'));
    final moduleConfig = File(path.join(tempRoot.path, 'module_config.json'));

    await omegaRoot.create(recursive: true);
    await moduleConfig.writeAsString(
      jsonEncode({
        'omegaPath': omegaRoot.path,
        'readOnly': true,
        'backupBeforeWrite': true,
      }),
    );

    final service = CompanyCommandCentreWriteService(
      moduleConfigPath: moduleConfig.path,
      omegaOsPath: omegaRoot.path,
      now: () => DateTime.utc(2026, 6, 20, 12, 34, 56),
    );

    final result = await service.writeMarkdownFile(
      relativePath: 'notes/brief.md',
      contents: '# Company brief\n',
      actorLabel: 'Peter Ellis',
      note: 'Test write should be blocked',
    );

    expect(result.success, isFalse);
    expect(result.message, contains('read-only'));
    expect(File(path.join(omegaRoot.path, 'notes', 'brief.md')).existsSync(), isFalse);
  });

  test('write service creates a timestamped backup and audit entry', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'company_command_write_',
    );
    addTearDown(() => tempRoot.deleteSync(recursive: true));

    final omegaRoot = Directory(path.join(tempRoot.path, 'omega_company'));
    final moduleConfig = File(path.join(tempRoot.path, 'module_config.json'));
    final targetFile = File(path.join(omegaRoot.path, 'notes', 'brief.md'));
    final fixedNow = DateTime.utc(2026, 6, 20, 12, 34, 56);

    await targetFile.parent.create(recursive: true);
    await omegaRoot.create(recursive: true);
    await targetFile.writeAsString('# Old brief\n');
    await moduleConfig.writeAsString(
      jsonEncode({
        'omegaPath': omegaRoot.path,
        'readOnly': false,
        'backupBeforeWrite': true,
      }),
    );

    final service = CompanyCommandCentreWriteService(
      moduleConfigPath: moduleConfig.path,
      omegaOsPath: omegaRoot.path,
      now: () => fixedNow,
    );

    final result = await service.writeMarkdownFile(
      relativePath: 'notes/brief.md',
      contents: '# New brief\n',
      actorLabel: 'Peter Ellis',
      note: 'Refresh the company brief',
    );

    final backupFile = File(
      path.join(
        omegaRoot.path,
        'backups',
        'company_command_centre',
        '20260620_123456',
        'notes',
        'brief.md',
      ),
    );
    final auditFile = File(
      path.join(
        omegaRoot.path,
        'audit',
        'company_command_centre_write_audit.jsonl',
      ),
    );

    expect(result.success, isTrue);
    expect(result.targetPath, targetFile.path);
    expect(result.backupPath, backupFile.path);
    expect(await targetFile.readAsString(), '# New brief\n');
    expect(await backupFile.exists(), isTrue);
    expect(await backupFile.readAsString(), '# Old brief\n');
    expect(await auditFile.exists(), isTrue);

    final auditLines = await auditFile.readAsLines();
    expect(auditLines, hasLength(1));

    final auditEntry = jsonDecode(auditLines.single) as Map<String, dynamic>;
    expect(auditEntry['action'], 'write_markdown');
    expect(auditEntry['target_path'], targetFile.path);
    expect(auditEntry['backup_path'], backupFile.path);
    expect(auditEntry['actor_label'], 'Peter Ellis');
    expect(auditEntry['note'], 'Refresh the company brief');
    expect(auditEntry['result'], 'success');
  });

  test('set read-only mode updates the config with a backup and audit entry', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'company_command_toggle_',
    );
    addTearDown(() => tempRoot.deleteSync(recursive: true));

    final omegaRoot = Directory(path.join(tempRoot.path, 'omega_company'));
    final moduleConfig = File(path.join(tempRoot.path, 'module_config.json'));

    await omegaRoot.create(recursive: true);
    await moduleConfig.writeAsString(
      jsonEncode({
        'omegaPath': omegaRoot.path,
        'readOnly': true,
        'backupBeforeWrite': true,
      }),
    );

    final service = CompanyCommandCentreWriteService(
      moduleConfigPath: moduleConfig.path,
      omegaOsPath: omegaRoot.path,
      now: () => DateTime.utc(2026, 6, 20, 12, 34, 56),
    );

    final result = await service.setReadOnlyMode(
      readOnly: false,
      actorLabel: 'Peter Ellis',
      note: 'Enable write mode for a test toggle',
    );

    final backupFile = File(
      path.join(
        tempRoot.path,
        'backups',
        'company_command_centre_config',
        '20260620_123456',
        'module_config.json',
      ),
    );
    final auditFile = File(
      path.join(
        omegaRoot.path,
        'audit',
        'company_command_centre_write_audit.jsonl',
      ),
    );

    expect(result.success, isTrue);
    expect(await backupFile.exists(), isTrue);
    expect(await auditFile.exists(), isTrue);

    final updatedConfig = jsonDecode(await moduleConfig.readAsString()) as Map<String, dynamic>;
    expect(updatedConfig['readOnly'], isFalse);

    final auditLines = await auditFile.readAsLines();
    final auditEntry = jsonDecode(auditLines.single) as Map<String, dynamic>;
    expect(auditEntry['action'], 'update_read_only_mode');
    expect(auditEntry['result'], 'success');
  });

  test('export audit summary report writes a readable markdown file', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'company_command_report_',
    );
    addTearDown(() => tempRoot.deleteSync(recursive: true));

    final omegaRoot = Directory(path.join(tempRoot.path, 'omega_company'));
    final moduleConfig = File(path.join(tempRoot.path, 'module_config.json'));
    final auditFile = File(
      path.join(omegaRoot.path, 'audit', 'company_command_centre_write_audit.jsonl'),
    );
    final fixedNow = DateTime.utc(2026, 6, 20, 12, 34, 56);

    await omegaRoot.create(recursive: true);
    await moduleConfig.writeAsString(
      jsonEncode({
        'omegaPath': omegaRoot.path,
        'readOnly': false,
        'backupBeforeWrite': true,
      }),
    );
    await auditFile.parent.create(recursive: true);
    await auditFile.writeAsString(
      '${jsonEncode({
        'id': 'entry-1',
        'timestamp': '2026-06-20T12:00:00Z',
        'action': 'write_markdown',
        'target_path': 'notes/brief.md',
        'backup_path': 'backups/company_command_centre/20260620_120000/notes/brief.md',
        'actor_label': 'Peter Ellis',
        'note': 'Initial note',
        'result': 'success',
      })}\n',
    );

    final service = CompanyCommandCentreWriteService(
      moduleConfigPath: moduleConfig.path,
      omegaOsPath: omegaRoot.path,
      now: () => fixedNow,
    );

    final result = await service.exportAuditSummaryReport(
      actorLabel: 'Peter Ellis',
      note: 'Export a summary for review',
    );

    final reportFile = File(
      path.join(
        omegaRoot.path,
        'reports',
        'company_command_centre_audit_summary.md',
      ),
    );

    expect(result.success, isTrue);
    expect(await reportFile.exists(), isTrue);

    final report = await reportFile.readAsString();
    expect(report, contains('# Company Command Centre Audit Summary'));
    expect(report, contains('Audit entries: 1'));
    expect(report, contains('notes/brief.md'));
  });
}
