import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'company_command_centre_repository.dart';

final companyCommandCentreReportServiceProvider =
    Provider<CompanyCommandCentreReportService>(
      (ref) => const CompanyCommandCentreReportService(),
    );

class CompanyCommandCentreReportService {
  const CompanyCommandCentreReportService({
    this.moduleRootPath = 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE',
    this.now,
  });

  final String moduleRootPath;
  final DateTime Function()? now;

  String get summaryReportPath => path.join(
    moduleRootPath,
    'omega_os_bridge',
    'reports',
    'company_command_centre_summary.md',
  );

  Future<CompanyCommandCentreReportResult> exportSummaryReport({
    required CompanyCommandCentreSnapshot snapshot,
  }) async {
    final reportFile = File(summaryReportPath);
    await reportFile.parent.create(recursive: true);

    String? backupPath;
    if (await reportFile.exists()) {
      backupPath = await _createTimestampedBackup(
        sourceFile: reportFile,
        relativePath: 'company_command_centre_summary.md',
      );
    }

    await reportFile.writeAsString(
      buildCompanyCommandCentreSummaryReport(
        snapshot: snapshot,
        generatedAt: _now(),
      ),
      flush: true,
    );

    return CompanyCommandCentreReportResult.success(
      reportPath: reportFile.path,
      backupPath: backupPath,
      message: 'Exported the company summary report.',
    );
  }

  Future<CompanyCommandCentreReportResult> openLatestReport() async {
    final reportFile = File(summaryReportPath);
    if (!await reportFile.exists()) {
      return CompanyCommandCentreReportResult.failure(
        message: 'No company summary report has been exported yet.',
        reportPath: summaryReportPath,
      );
    }

    await _openPath(reportFile.path);
    return CompanyCommandCentreReportResult.success(
      reportPath: reportFile.path,
      message: 'Opened the latest company summary report.',
    );
  }

  Future<String> _createTimestampedBackup({
    required File sourceFile,
    required String relativePath,
  }) async {
    final stamp = _timestampStamp(_now());
    final backupFilePath = path.join(
      moduleRootPath,
      'omega_os_bridge',
      'reports',
      'backups',
      'company_command_centre_summary',
      stamp,
      relativePath,
    );
    final backupFile = File(backupFilePath);
    await backupFile.parent.create(recursive: true);
    await sourceFile.copy(backupFile.path);
    return backupFile.path;
  }

  Future<void> _openPath(String filePath) async {
    if (Platform.isWindows) {
      await Process.start('cmd.exe', ['/c', 'start', '', filePath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [filePath]);
      return;
    }

    await Process.start('xdg-open', [filePath]);
  }

  DateTime _now() => now?.call() ?? DateTime.now();

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

String buildCompanyCommandCentreSummaryReport({
  required CompanyCommandCentreSnapshot snapshot,
  DateTime? generatedAt,
}) {
  final now = (generatedAt ?? DateTime.now()).toUtc();
  final buffer = StringBuffer()
    ..writeln('# Company Command Centre Summary')
    ..writeln()
    ..writeln('- Generated: ${now.toIso8601String()}')
    ..writeln('- Company: ${snapshot.overview.companyName}')
    ..writeln('- Company number: ${snapshot.overview.companyNumber}')
    ..writeln('- Domain: ${snapshot.overview.domain}')
    ..writeln('- Bank: ${snapshot.overview.bank}')
    ..writeln('- Status: ${snapshot.overview.status}')
    ..writeln('- Main focus items: ${snapshot.overview.focus.length}')
    ..writeln('- Next milestone: ${snapshot.overview.nextMilestone}')
    ..writeln('- Omega OS source path: ${snapshot.configuredOmegaPath}')
    ..writeln(
      '- Source path available: ${snapshot.overview.omegaOsPathExists ? 'yes' : 'no'}',
    )
    ..writeln()
    ..writeln('## Source-linked trackers')
    ..writeln(
      '- Compliance checklist: modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
    )
    ..writeln(
      '- Website tracker: modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md',
    )
    ..writeln(
      '- LinkedIn tracker: modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md',
    )
    ..writeln(
      '- Company overview template: modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/company_overview_template.md',
    )
    ..writeln(
      '- Capability statement template: modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/capability_statement_template.md',
    )
    ..writeln(
      '- Product page template: modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/product_page_template.md',
    )
    ..writeln()
    ..writeln('## Operational snapshot')
    ..writeln('- Action board items: ${snapshot.actionBoard.length}')
    ..writeln('- Product portfolio items: ${snapshot.productPortfolio.length}')
    ..writeln('- Grants pipeline items: ${snapshot.grantsPipeline.length}')
    ..writeln(
      '- Indexed markdown files: ${snapshot.indexSnapshot.sourceMarkdownCount}',
    )
    ..writeln(
      '- Generated company index: ${snapshot.indexSnapshot.companyIndexPath}',
    )
    ..writeln(
      '- Generated action index: ${snapshot.indexSnapshot.actionItemsIndexPath}',
    )
    ..writeln(
      '- Generated deadlines index: ${snapshot.indexSnapshot.deadlinesIndexPath}',
    )
    ..writeln(
      '- Generated products index: ${snapshot.indexSnapshot.productsIndexPath}',
    )
    ..writeln(
      '- Generated grants index: ${snapshot.indexSnapshot.grantsIndexPath}',
    )
    ..writeln(
      '- Generated IP assets index: ${snapshot.indexSnapshot.ipAssetsIndexPath}',
    )
    ..writeln(
      '- Generated evidence index: ${snapshot.indexSnapshot.evidenceIndexPath}',
    )
    ..writeln()
    ..writeln('## Recent linked files');

  if (snapshot.indexSnapshot.recentFiles.isEmpty) {
    buffer.writeln('- No linked files were found yet.');
  } else {
    for (final record in snapshot.indexSnapshot.recentFiles) {
      buffer
        ..writeln('- ${record.title}')
        ..writeln('  - Source: ${record.relativePath}')
        ..writeln('  - Labels: ${record.labels.join(', ')}')
        ..writeln(
          '  - Due dates: ${record.dueDates.isEmpty ? 'None' : record.dueDates.join(', ')}',
        );
    }
  }

  return buffer.toString();
}

class CompanyCommandCentreReportResult {
  const CompanyCommandCentreReportResult._({
    required this.success,
    required this.message,
    required this.reportPath,
    this.backupPath,
  });

  factory CompanyCommandCentreReportResult.success({
    required String message,
    required String reportPath,
    String? backupPath,
  }) {
    return CompanyCommandCentreReportResult._(
      success: true,
      message: message,
      reportPath: reportPath,
      backupPath: backupPath,
    );
  }

  factory CompanyCommandCentreReportResult.failure({
    required String message,
    required String reportPath,
    String? backupPath,
  }) {
    return CompanyCommandCentreReportResult._(
      success: false,
      message: message,
      reportPath: reportPath,
      backupPath: backupPath,
    );
  }

  final bool success;
  final String message;
  final String reportPath;
  final String? backupPath;
}
