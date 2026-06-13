import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../models/grant_record.dart';
import '../models/grant_status.dart';
import '../models/readiness_score.dart';
import '../services/folder_template_service.dart';
import 'funding_grants_paths.dart';

final fundingGrantsRepositoryProvider = Provider<FundingGrantsRepository>((ref) {
  return FundingGrantsRepository();
});

class FundingGrantsRepository {
  FundingGrantsRepository({FolderTemplateService? folderTemplateService})
      : _folderTemplateService = folderTemplateService ?? FolderTemplateService();

  final FolderTemplateService _folderTemplateService;

  Future<void> bootstrapWorkspace() async {
    await Directory(FundingGrantsPaths.trackerMasterFolder).create(
      recursive: true,
    );

    for (final folderPath in [
      FundingGrantsPaths.activeApplicationsPath,
      FundingGrantsPaths.submittedApplicationsPath,
      FundingGrantsPaths.approvedGrantsPath,
      FundingGrantsPaths.rejectedOrPausedPath,
      FundingGrantsPaths.partnerLettersPath,
      FundingGrantsPaths.evidenceLibraryPath,
      FundingGrantsPaths.budgetTemplatesPath,
      FundingGrantsPaths.reportingAndClaimsPath,
      FundingGrantsPaths.lessonsAndFeedbackPath,
      FundingGrantsPaths.opportunityResearchPath,
      FundingGrantsPaths.complianceAndRiskPath,
      FundingGrantsPaths.meetingsAndCallsPath,
      FundingGrantsPaths.submissionArchivePath,
    ]) {
      await Directory(folderPath).create(recursive: true);
    }

    final configFile = File(FundingGrantsPaths.dashboardConfigPath);
    if (!await configFile.exists()) {
      await configFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(_dashboardConfig()),
        flush: true,
      );
    }

    final trackerJson = File(FundingGrantsPaths.trackerJsonPath);
    if (!await trackerJson.exists()) {
      final seed = await _readSeedGrants();
      await _writeTrackerFiles(seed);
    }

    final trackerCsv = File(FundingGrantsPaths.trackerCsvPath);
    if (!await trackerCsv.exists()) {
      final seed = await _readGrantsFromTracker();
      await _writeTrackerCsv(seed);
    }
  }

  Future<List<GrantRecord>> loadGrants() async {
    await bootstrapWorkspace();
    final grants = await _readGrantsFromTracker();
    final normalized = <GrantRecord>[];
    var changed = false;

    for (final grant in grants) {
      final normalizedGrant = await _ensureGrantWorkspace(grant);
      normalized.add(normalizedGrant);
      if (normalizedGrant.folderPath != grant.folderPath) {
        changed = true;
      }
    }

    if (changed) {
      await _writeTrackerFiles(normalized);
    }

    return normalized;
  }

  Future<GrantRecord> createGrant(GrantRecord grant) async {
    final grants = await loadGrants();
    final nextId = _nextGrantId(grants);
    final draft = grant.copyWith(id: nextId);
    return saveGrant(draft);
  }

  Future<GrantRecord> saveGrant(
    GrantRecord grant, {
    GrantRecord? previous,
  }) async {
    await bootstrapWorkspace();
    final grants = await _readGrantsFromTracker();
    final existingIndex = grants.indexWhere((item) => item.id == grant.id);

    final persisted = await _persistGrantWorkspace(
      grant,
      previous: previous ?? (existingIndex == -1 ? null : grants[existingIndex]),
    );

    if (existingIndex == -1) {
      grants.add(persisted);
    } else {
      grants[existingIndex] = persisted;
    }

    await _writeTrackerFiles(grants);
    return persisted;
  }

  Future<void> deleteGrant(String grantId) async {
    final grants = await loadGrants();
    grants.removeWhere((grant) => grant.id == grantId);
    await _writeTrackerFiles(grants);
  }

  Future<Directory> exportTrackerSnapshot() async {
    await bootstrapWorkspace();
    final exportsDir = Directory(
      path.join(FundingGrantsPaths.trackerMasterFolder, 'exports'),
    );
    await exportsDir.create(recursive: true);

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final jsonTarget = File(path.join(exportsDir.path, 'grant_tracker_$timestamp.json'));
    final csvTarget = File(path.join(exportsDir.path, 'grant_tracker_$timestamp.csv'));
    final jsonSource = File(FundingGrantsPaths.trackerJsonPath);
    final csvSource = File(FundingGrantsPaths.trackerCsvPath);

    if (await jsonSource.exists()) {
      await jsonSource.copy(jsonTarget.path);
    }
    if (await csvSource.exists()) {
      await csvSource.copy(csvTarget.path);
    }

    return exportsDir;
  }

  Future<void> importTrackerFile(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Import file not found', sourcePath);
    }

    final ext = path.extension(sourcePath).toLowerCase();
    if (ext == '.json') {
      final decoded = jsonDecode(await source.readAsString()) as Map<String, dynamic>;
      final grants = _grantsFromDecodedJson(decoded).map(_normalizeGrant).toList();
      await _writeTrackerFiles(grants);
      return;
    }

    if (ext == '.csv') {
      final grants = _grantsFromCsv(await source.readAsString());
      await _writeTrackerFiles(grants.map(_normalizeGrant).toList());
      return;
    }

    throw UnsupportedError('Only grant_tracker JSON or CSV files can be imported.');
  }

  Future<GrantRecord> updateGrantStatus(
    GrantRecord grant,
    GrantStatus status,
  ) async {
    return saveGrant(grant.copyWith(status: status), previous: grant);
  }

  Future<GrantRecord> _ensureGrantWorkspace(GrantRecord grant) async {
    final normalizedFolderPath = _normalizeFolderPath(grant);
    final folder = Directory(normalizedFolderPath);
    if (await folder.exists()) {
      return grant.copyWith(folderPath: folder.path);
    }

    final createdPath = await _folderTemplateService.createGrantFolder(
      targetFolderPath: folder.path,
      grant: grant.copyWith(folderPath: folder.path),
    );
    return grant.copyWith(folderPath: createdPath);
  }

  Future<GrantRecord> _persistGrantWorkspace(
    GrantRecord grant, {
    GrantRecord? previous,
  }) async {
    final folderName = _folderNameForGrant(grant, previous: previous);
    final targetFolderPath = path.join(
      _parentFolderForStatus(grant.status),
      folderName,
    );

    String resolvedFolderPath = targetFolderPath;
    if (previous != null &&
        previous.folderPath.isNotEmpty &&
        previous.folderPath != targetFolderPath &&
        await Directory(previous.folderPath).exists()) {
      resolvedFolderPath = await _folderTemplateService.moveGrantFolder(
        sourceFolderPath: previous.folderPath,
        targetFolderPath: targetFolderPath,
      );
    }

    final resolvedFolder = Directory(resolvedFolderPath);
    if (!await resolvedFolder.exists()) {
      resolvedFolderPath = await _folderTemplateService.createGrantFolder(
        targetFolderPath: resolvedFolderPath,
        grant: grant.copyWith(folderPath: resolvedFolderPath),
      );
    }

    return grant.copyWith(folderPath: resolvedFolderPath);
  }

  Future<List<GrantRecord>> _readGrantsFromTracker() async {
    final file = File(FundingGrantsPaths.trackerJsonPath);
    if (!await file.exists()) {
      return <GrantRecord>[];
    }

    final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return _grantsFromDecodedJson(decoded);
  }

  Future<List<GrantRecord>> _readSeedGrants() async {
    final seedFile = File(
      path.join(
        'modules',
        'funding_grants_command_centre',
        'data',
        'grant_tracker_seed.json',
      ),
    );

    if (!await seedFile.exists()) {
      return <GrantRecord>[];
    }

    final decoded = jsonDecode(await seedFile.readAsString()) as Map<String, dynamic>;
    final grants = decoded['grants'] as List<dynamic>? ?? const <dynamic>[];
    return grants
        .whereType<Map<String, dynamic>>()
        .map(GrantRecord.fromJson)
        .map(_normalizeGrant)
        .toList();
  }

  Future<void> _writeTrackerFiles(List<GrantRecord> grants) async {
    final normalized = grants.map(_normalizeGrant).toList();
    await _writeTrackerJson(normalized);
    await _writeTrackerCsv(normalized);
  }

  Future<void> _writeTrackerJson(List<GrantRecord> grants) async {
    final file = File(FundingGrantsPaths.trackerJsonPath);
    await file.parent.create(recursive: true);
    final payload = {
      'version': '1.0.0',
      'updated': DateTime.now().toIso8601String(),
      'grants': grants.map((grant) => grant.toJson()).toList(),
    };
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
  }

  Future<void> _writeTrackerCsv(List<GrantRecord> grants) async {
    final file = File(FundingGrantsPaths.trackerCsvPath);
    await file.parent.create(recursive: true);
    final lines = <String>[_csvHeaders.join(',')];
    for (final grant in grants) {
      lines.add(_csvRow(grant).join(','));
    }
    await file.writeAsString('${lines.join('\n')}\n', flush: true);
  }

  List<GrantRecord> _grantsFromDecodedJson(Map<String, dynamic> decoded) {
    final grants = decoded['grants'] as List<dynamic>? ?? const <dynamic>[];
    return grants
        .whereType<Map<String, dynamic>>()
        .map(GrantRecord.fromJson)
        .toList();
  }

  List<GrantRecord> _grantsFromCsv(String rawCsv) {
    final lines = rawCsv
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return <GrantRecord>[];
    }

    final headers = _parseCsvLine(lines.first);
    final grants = <GrantRecord>[];
    for (var i = 1; i < lines.length; i++) {
      final cells = _parseCsvLine(lines[i]);
      final row = <String, dynamic>{};
      for (var index = 0; index < headers.length && index < cells.length; index++) {
        row[headers[index]] = cells[index];
      }
      grants.add(_grantFromCsvRow(row));
    }
    return grants;
  }

  GrantRecord _grantFromCsvRow(Map<String, dynamic> row) {
    final tagsValue = row['tags']?.toString() ?? '';
    return GrantRecord(
      id: row['id']?.toString() ?? '',
      grantName: row['grant_name']?.toString() ?? '',
      project: row['project']?.toString() ?? '',
      fundingBody: row['funding_body']?.toString() ?? '',
      fundingType: row['funding_type']?.toString() ?? '',
      amountRequested: double.tryParse(row['amount_requested']?.toString() ?? '') ?? 0,
      matchFundingRequired: row['match_funding_required']?.toString() ?? '',
      status: GrantStatusLabel.fromLabel(row['status']?.toString() ?? ''),
      deadline: row['deadline']?.toString().isNotEmpty == true
          ? row['deadline'].toString()
          : 'TBC',
      submissionDate: _nullableText(row['submission_date']),
      decisionDate: _nullableText(row['decision_date']),
      priority: row['priority']?.toString().isNotEmpty == true
          ? row['priority'].toString()
          : 'Medium',
      owner: row['owner']?.toString() ?? '',
      nextAction: row['next_action']?.toString() ?? '',
      riskLevel: row['risk_level']?.toString().isNotEmpty == true
          ? row['risk_level'].toString()
          : 'Medium',
      readinessScore: ReadinessScore(
        projectSummary: _intFromText(row['project_summary']),
        budget: _intFromText(row['budget']),
        evidence: _intFromText(row['evidence']),
        partnerSupport: _intFromText(row['partner_support']),
        impactCase: _intFromText(row['impact_case']),
        commercialPlan: _intFromText(row['commercial_plan']),
        riskManagement: _intFromText(row['risk_management']),
      ),
      folderPath: row['folder_path']?.toString() ?? '',
      notes: row['notes']?.toString() ?? '',
      tags: tagsValue
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
    );
  }

  List<String> _csvRow(GrantRecord grant) {
    return [
      grant.id,
      grant.grantName,
      grant.project,
      grant.fundingBody,
      grant.fundingType,
      grant.amountRequested.toStringAsFixed(0),
      grant.matchFundingRequired,
      grant.status.label,
      grant.deadline,
      grant.submissionDate ?? '',
      grant.decisionDate ?? '',
      grant.priority,
      grant.owner,
      grant.nextAction,
      grant.riskLevel,
      grant.readinessScore.total.toString(),
      grant.readinessScore.max.toString(),
      grant.folderPath,
      grant.notes,
      grant.tags.join(','),
    ].map(_csvCell).toList();
  }

  GrantRecord _normalizeGrant(GrantRecord grant) {
    final folderPath = _normalizeFolderPath(grant);
    return grant.copyWith(folderPath: folderPath);
  }

  String _normalizeFolderPath(GrantRecord grant) {
    final folderPath = grant.folderPath.trim();
    if (folderPath.isEmpty) {
      return _resolvedFolderPath(grant);
    }

    return FundingGrantsPaths.normalizeOmegaPath(folderPath);
  }

  String _resolvedFolderPath(GrantRecord grant) {
    final folderName = grant.folderPath.trim().isNotEmpty
        ? path.basename(grant.folderPath)
        : _defaultFolderName(grant);
    return path.join(_parentFolderForStatus(grant.status), folderName);
  }

  String _defaultFolderName(GrantRecord grant) {
    final nameBits = [
      grant.grantName,
      grant.project,
    ].where((value) => value.trim().isNotEmpty).join(' ');
    final slug = _slugify(nameBits);
    return '${grant.id}_$slug';
  }

  String _folderNameForGrant(GrantRecord grant, {GrantRecord? previous}) {
    final existing = previous?.folderPath.trim().isNotEmpty == true
        ? path.basename(previous!.folderPath)
        : grant.folderPath.trim().isNotEmpty
            ? path.basename(grant.folderPath)
            : '';
    if (existing.isNotEmpty) {
      return existing;
    }
    return _defaultFolderName(grant);
  }

  String _parentFolderForStatus(GrantStatus status) {
    switch (status) {
      case GrantStatus.submitted:
      case GrantStatus.underReview:
        return FundingGrantsPaths.submittedApplicationsPath;
      case GrantStatus.approved:
      case GrantStatus.reportingPhase:
      case GrantStatus.closed:
        return FundingGrantsPaths.approvedGrantsPath;
      case GrantStatus.rejected:
      case GrantStatus.paused:
        return FundingGrantsPaths.rejectedOrPausedPath;
      default:
        return FundingGrantsPaths.activeApplicationsPath;
    }
  }

  String _nextGrantId(List<GrantRecord> grants) {
    var highest = 0;
    for (final grant in grants) {
      final match = RegExp(r'^GRANT-(\d+)$').firstMatch(grant.id.trim());
      if (match == null) {
        continue;
      }
      final value = int.tryParse(match.group(1) ?? '');
      if (value != null && value > highest) {
        highest = value;
      }
    }
    return 'GRANT-${(highest + 1).toString().padLeft(4, '0')}';
  }

  String _csvCell(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  List<String> _parseCsvLine(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        final nextIsQuote = i + 1 < line.length && line[i + 1] == '"';
        if (nextIsQuote) {
          buffer.write('"');
          i += 1;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (char == ',' && !inQuotes) {
        cells.add(buffer.toString());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    cells.add(buffer.toString());
    return cells;
  }

  String? _nullableText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  int _intFromText(dynamic value) {
    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  String _slugify(String value) {
    final cleaned = value
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return cleaned.isEmpty ? 'GRANT_FOLDER' : cleaned;
  }

  static Map<String, dynamic> _dashboardConfig() {
    return {
      'version': '1.0.0',
      'module_id': 'funding_grants_command_centre',
      'omega_os_root': FundingGrantsPaths.omegaRoot,
      'master_folder': FundingGrantsPaths.trackerMasterFolder,
      'tracker_json': FundingGrantsPaths.trackerJsonPath,
      'tracker_csv': FundingGrantsPaths.trackerCsvPath,
      'active_applications': FundingGrantsPaths.activeApplicationsPath,
      'submitted_applications': FundingGrantsPaths.submittedApplicationsPath,
      'approved_grants': FundingGrantsPaths.approvedGrantsPath,
      'rejected_or_paused': FundingGrantsPaths.rejectedOrPausedPath,
      'templates_source': FundingGrantsPaths.moduleTemplatesPath,
    };
  }

  static const List<String> _csvHeaders = [
    'id',
    'grant_name',
    'project',
    'funding_body',
    'funding_type',
    'amount_requested',
    'match_funding_required',
    'status',
    'deadline',
    'submission_date',
    'decision_date',
    'priority',
    'owner',
    'next_action',
    'risk_level',
    'readiness_total',
    'readiness_max',
    'folder_path',
    'notes',
    'tags',
  ];
}
