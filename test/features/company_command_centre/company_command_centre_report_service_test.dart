import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/company_command_centre/data/company_command_centre_index_service.dart';
import 'package:new_earth_command_dashboard/features/company_command_centre/data/company_command_centre_repository.dart';
import 'package:new_earth_command_dashboard/features/company_command_centre/data/company_command_centre_report_service.dart';

void main() {
  test(
    'company summary report exports source-linked markdown and backups on overwrite',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'company_command_report_',
      );
      addTearDown(() => tempRoot.deleteSync(recursive: true));

      final moduleRoot = Directory(path.join(tempRoot.path, 'module_root'));
      await moduleRoot.create(recursive: true);

      final snapshot = _buildSnapshot(
        reportRootPath: moduleRoot.path,
        generatedAt: DateTime.utc(2026, 6, 20, 12, 34, 56),
      );

      final service = CompanyCommandCentreReportService(
        moduleRootPath: moduleRoot.path,
        now: () => DateTime.utc(2026, 6, 20, 12, 34, 56),
      );

      final firstResult = await service.exportSummaryReport(snapshot: snapshot);
      final reportFile = File(
        path.join(
          moduleRoot.path,
          'omega_os_bridge',
          'reports',
          'company_command_centre_summary.md',
        ),
      );

      expect(firstResult.success, isTrue);
      expect(await reportFile.exists(), isTrue);

      final firstReport = await reportFile.readAsString();
      expect(firstReport, contains('# Company Command Centre Summary'));
      expect(firstReport, contains('New Earth Advanced Technologies Ltd'));
      expect(firstReport, contains('company_index.generated.json'));
      expect(firstReport, contains('website_next_steps.md'));

      final secondResult = await service.exportSummaryReport(
        snapshot: snapshot,
      );
      final backupFile = File(
        path.join(
          moduleRoot.path,
          'omega_os_bridge',
          'reports',
          'backups',
          'company_command_centre_summary',
          '20260620_123456',
          'company_command_centre_summary.md',
        ),
      );

      expect(secondResult.success, isTrue);
      expect(secondResult.backupPath, backupFile.path);
      expect(await backupFile.exists(), isTrue);
      expect(await backupFile.readAsString(), firstReport);
    },
  );
}

CompanyCommandCentreSnapshot _buildSnapshot({
  required String reportRootPath,
  required DateTime generatedAt,
}) {
  return CompanyCommandCentreSnapshot(
    overview: CompanyOverviewData(
      companyName: 'New Earth Advanced Technologies Ltd',
      companyNumber: '15234567',
      domain: 'newearth.example',
      bank: 'Tide',
      omegaOsPath: reportRootPath,
      status: 'Active',
      focus: const ['Keep the company ops calm'],
      nextMilestone: 'Publish a source-linked summary report',
      omegaOsPathExists: true,
    ),
    actionBoard: const [
      CompanyActionItemData(
        id: 'action-1',
        title: 'Review launch copy',
        lane: 'Today',
        area: 'Marketing',
        priority: 'High',
      ),
    ],
    productPortfolio: const [
      CompanyProductItemData(
        name: 'MicroGrow',
        type: 'Platform',
        status: 'Draft',
        commercialReadiness: 'Low',
      ),
    ],
    grantsPipeline: const [
      CompanyGrantItemData(
        id: 'grant-1',
        name: 'Innovation Grant',
        stage: 'Research',
        fit: 'Medium',
        nextAction: 'Check criteria',
      ),
    ],
    moduleConfigPath:
        'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/src/module_shell/module_config.json',
    moduleConfigExists: true,
    configuredOmegaPath: reportRootPath,
    moduleReadOnly: true,
    moduleBackupBeforeWrite: true,
    backupRootPath: path.join(
      reportRootPath,
      'omega_os_bridge',
      'reports',
      'backups',
      'company_command_centre_summary',
    ),
    auditLogPath: path.join(
      reportRootPath,
      'audit',
      'company_command_centre_write_audit.jsonl',
    ),
    indexSnapshot: CompanyCommandCentreIndexSnapshot(
      generatedAt: generatedAt,
      sourcePath: reportRootPath,
      sourceExists: true,
      sourceMarkdownCount: 3,
      companyIndexPath: path.join(
        reportRootPath,
        'omega_os_bridge',
        'indexes',
        'company_index.generated.json',
      ),
      actionItemsIndexPath: path.join(
        reportRootPath,
        'omega_os_bridge',
        'indexes',
        'action_items_index.generated.json',
      ),
      deadlinesIndexPath: path.join(
        reportRootPath,
        'omega_os_bridge',
        'indexes',
        'deadlines_index.generated.json',
      ),
      productsIndexPath: path.join(
        reportRootPath,
        'omega_os_bridge',
        'indexes',
        'products_index.generated.json',
      ),
      grantsIndexPath: path.join(
        reportRootPath,
        'omega_os_bridge',
        'indexes',
        'grants_index.generated.json',
      ),
      ipAssetsIndexPath: path.join(
        reportRootPath,
        'omega_os_bridge',
        'indexes',
        'ip_assets_index.generated.json',
      ),
      evidenceIndexPath: path.join(
        reportRootPath,
        'omega_os_bridge',
        'indexes',
        'evidence_index.generated.json',
      ),
      recentFiles: const [
        CompanyCommandCentreMarkdownRecord(
          title: 'Website Next Steps',
          relativePath: 'data/checklists/website_next_steps.md',
          sourcePath: 'D:/Omega/data/checklists/website_next_steps.md',
          checkboxCount: 3,
          openCheckboxCount: 2,
          closedCheckboxCount: 1,
          dueDates: ['2026-07-01'],
          frontmatter: {},
          labels: ['website', 'action'],
          excerpt: 'Website next steps list.',
        ),
      ],
      records: const [],
    ),
  );
}
