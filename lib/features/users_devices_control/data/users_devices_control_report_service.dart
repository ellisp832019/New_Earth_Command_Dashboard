import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;

import 'users_devices_control_repository.dart';
import 'users_devices_pin_registry_service.dart';

final usersDevicesControlReportServiceProvider =
    Provider<UsersDevicesControlReportService>(
      (ref) => const UsersDevicesControlReportService(),
    );

class UsersDevicesControlReportService {
  const UsersDevicesControlReportService({
    this.moduleRootPath = 'modules/01_USERS_AND_DEVICES_CONTROL',
    this.nowProvider,
  });

  final String moduleRootPath;
  final DateTime Function()? nowProvider;

  Future<UsersDevicesControlReportExportResult> exportReadinessSummary({
    required UsersDevicesControlSnapshot snapshot,
    required UsersDevicesPinRegistrySnapshot pins,
    String? focusedUserId,
    String statusFilter = 'all',
  }) async {
    final reportFile = File(readinessSummaryPath);
    await reportFile.parent.create(recursive: true);

    String? backupPath;
    if (await reportFile.exists()) {
      backupPath = await _backupExistingReport(
        sourceFile: reportFile,
        reportSlug: 'readiness_summary',
      );
    }

    final reportContent = _buildReadinessSummaryReport(
      snapshot: snapshot,
      pins: pins,
      focusedUserId: focusedUserId,
      statusFilter: statusFilter,
    );
    await reportFile.writeAsString(reportContent, flush: true);
    final pdfFile = await _writePdfReport(
      pdfPath: readinessSummaryPdfPath,
      title: 'Users & Devices Readiness Summary',
      markdownContent: reportContent,
    );

    return UsersDevicesControlReportExportResult.success(
      message: 'Exported the readiness summary.',
      reportPath: reportFile.path,
      backupPath: backupPath,
      pdfPath: pdfFile.path,
    );
  }

  Future<UsersDevicesControlReportExportResult> exportIncidentSummary({
    required UsersDevicesControlSnapshot snapshot,
    String resultFilter = 'all',
    String query = '',
  }) async {
    final reportFile = File(incidentSummaryPath);
    await reportFile.parent.create(recursive: true);

    String? backupPath;
    if (await reportFile.exists()) {
      backupPath = await _backupExistingReport(
        sourceFile: reportFile,
        reportSlug: 'incident_summary',
      );
    }

    final reportContent = _buildIncidentSummaryReport(
      snapshot: snapshot,
      resultFilter: resultFilter,
      query: query,
    );
    await reportFile.writeAsString(reportContent, flush: true);
    final pdfFile = await _writePdfReport(
      pdfPath: incidentSummaryPdfPath,
      title: 'Users & Devices Incident Summary',
      markdownContent: reportContent,
    );

    return UsersDevicesControlReportExportResult.success(
      message: 'Exported the incident summary.',
      reportPath: reportFile.path,
      backupPath: backupPath,
      pdfPath: pdfFile.path,
    );
  }

  Future<UsersDevicesControlReportExportResult> exportAdminReviewPack({
    required UsersDevicesControlSnapshot snapshot,
    required UsersDevicesPinRegistrySnapshot pins,
    String? focusedUserId,
    String statusFilter = 'all',
    String resultFilter = 'all',
    String query = '',
  }) async {
    final reportFile = File(adminReviewPackPath);
    await reportFile.parent.create(recursive: true);

    String? backupPath;
    if (await reportFile.exists()) {
      backupPath = await _backupExistingReport(
        sourceFile: reportFile,
        reportSlug: 'admin_review_pack',
      );
    }

    final reportContent = _buildAdminReviewPack(
      snapshot: snapshot,
      pins: pins,
      focusedUserId: focusedUserId,
      statusFilter: statusFilter,
      resultFilter: resultFilter,
      query: query,
    );
    await reportFile.writeAsString(reportContent, flush: true);
    final pdfFile = await _writePdfReport(
      pdfPath: adminReviewPackPdfPath,
      title: 'Users & Devices Admin Review Pack',
      markdownContent: reportContent,
    );

    return UsersDevicesControlReportExportResult.success(
      message: 'Exported the admin review pack.',
      reportPath: reportFile.path,
      backupPath: backupPath,
      pdfPath: pdfFile.path,
    );
  }

  Future<void> openExportsFolder() async {
    final folder = Directory(exportsRootPath);
    await folder.create(recursive: true);
    await _openPath(folder.path);
  }

  String get exportsRootPath => path.join(moduleRootPath, 'output', 'reports');

  String get readinessSummaryPath =>
      path.join(exportsRootPath, 'users_devices_readiness_summary.md');

  String get incidentSummaryPath =>
      path.join(exportsRootPath, 'users_devices_incident_summary.md');

  String get adminReviewPackPath =>
      path.join(exportsRootPath, 'users_devices_admin_review_pack.md');

  String get pdfExportsRootPath => path.join(moduleRootPath, 'output', 'pdf');

  String get readinessSummaryPdfPath =>
      path.join(pdfExportsRootPath, 'users_devices_readiness_summary.pdf');

  String get incidentSummaryPdfPath =>
      path.join(pdfExportsRootPath, 'users_devices_incident_summary.pdf');

  String get adminReviewPackPdfPath =>
      path.join(pdfExportsRootPath, 'users_devices_admin_review_pack.pdf');

  Future<String> _backupExistingReport({
    required File sourceFile,
    required String reportSlug,
  }) async {
    final stamp = _timestampStamp(_now());
    final backupPath = path.join(
      exportsRootPath,
      'backups',
      reportSlug,
      stamp,
      path.basename(sourceFile.path),
    );
    final backupFile = File(backupPath);
    await backupFile.parent.create(recursive: true);
    await sourceFile.copy(backupFile.path);
    return backupFile.path;
  }

  Future<File> _writePdfReport({
    required String pdfPath,
    required String title,
    required String markdownContent,
  }) async {
    final pdfFile = File(pdfPath);
    await pdfFile.parent.create(recursive: true);
    final pdfBytes = await _buildReportPdfBytes(
      title: title,
      markdownContent: markdownContent,
    );
    await pdfFile.writeAsBytes(pdfBytes, flush: true);
    return pdfFile;
  }

  Future<Uint8List> _buildReportPdfBytes({
    required String title,
    required String markdownContent,
  }) async {
    final pdf = pw.Document();
    final lines = markdownContent.split('\n');
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(margin: const pw.EdgeInsets.all(28)),
        build: (context) => [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          ..._pdfWidgetsForMarkdownLines(lines),
        ],
      ),
    );
    return pdf.save();
  }

  List<pw.Widget> _pdfWidgetsForMarkdownLines(List<String> lines) {
    final widgets = <pw.Widget>[];
    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 6));
        continue;
      }
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('# ')) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 10, bottom: 6),
            child: pw.Text(
              trimmed.substring(2),
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
        continue;
      }
      if (trimmed.startsWith('## ')) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
            child: pw.Text(
              trimmed.substring(3),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
        continue;
      }
      if (trimmed.startsWith('- ')) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('- '),
                pw.Expanded(child: pw.Text(trimmed.substring(2))),
              ],
            ),
          ),
        );
        continue;
      }
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Text(trimmed),
        ),
      );
    }
    return widgets;
  }

  String _buildReadinessSummaryReport({
    required UsersDevicesControlSnapshot snapshot,
    required UsersDevicesPinRegistrySnapshot pins,
    required String? focusedUserId,
    required String statusFilter,
  }) {
    final statuses = snapshot.users
        .map(
          (user) =>
              _buildReadinessStatus(snapshot: snapshot, pins: pins, user: user),
        )
        .toList(growable: false);
    final filtered = statuses
        .where((status) => _matchesReadinessFilter(status, statusFilter))
        .toList(growable: false);
    final focused = statuses
        .where((status) => status.user.id == focusedUserId)
        .toList();
    final selected = focused.isNotEmpty
        ? focused.first
        : (statuses.isNotEmpty ? statuses.first : null);

    final buffer = StringBuffer()
      ..writeln('# Users & Devices Readiness Summary')
      ..writeln()
      ..writeln('- Generated: ${_now().toUtc().toIso8601String()}')
      ..writeln('- Scope: local-first onboarding and trust readiness')
      ..writeln('- Filter: $statusFilter')
      ..writeln('- Users in snapshot: ${snapshot.users.length}')
      ..writeln('- Matching users: ${filtered.length}')
      ..writeln('- Devices in snapshot: ${snapshot.devices.length}')
      ..writeln(
        '- Active PIN records: ${pins.records.where((record) => record.status == 'active').length}',
      )
      ..writeln(
        '- Recovery PIN records: ${pins.records.where((record) => record.status == 'recovery').length}',
      )
      ..writeln()
      ..writeln('## Readiness counts')
      ..writeln(
        '- Ready: ${statuses.where((status) => status.label == 'ready').length}',
      )
      ..writeln(
        '- Blocked: ${statuses.where((status) => status.label == 'blocked').length}',
      )
      ..writeln(
        '- Archived: ${statuses.where((status) => status.label == 'archived').length}',
      )
      ..writeln(
        '- Exception-only: ${statuses.where((status) => status.label == 'exception-only').length}',
      )
      ..writeln(
        '- Needs role: ${statuses.where((status) => status.label == 'missing-role').length}',
      )
      ..writeln(
        '- Needs PIN: ${statuses.where((status) => status.label == 'missing-pin').length}',
      )
      ..writeln(
        '- Needs trust: ${statuses.where((status) => status.label == 'missing-trust').length}',
      );

    if (selected != null) {
      buffer
        ..writeln()
        ..writeln('## Focused handoff')
        ..writeln('- User: ${selected.user.displayName}')
        ..writeln('- Role: ${selected.user.role}')
        ..writeln('- Status: ${selected.label}')
        ..writeln('- Linked devices: ${selected.linkedDeviceNames}')
        ..writeln('- Trusted devices: ${selected.trustedDeviceNames}')
        ..writeln('- Recovery PIN count: ${selected.recoveryPinCount}')
        ..writeln('- Denied audit count: ${selected.deniedAuditCount}')
        ..writeln('- Pending audit count: ${selected.pendingAuditCount}')
        ..writeln('- Next step: ${selected.nextStep}');
    }

    buffer
      ..writeln()
      ..writeln('## Matching users');

    if (filtered.isEmpty) {
      buffer.writeln('- No users matched the current readiness filter.');
    } else {
      for (final status in filtered) {
        buffer
          ..writeln('- ${status.user.displayName} (${status.user.role})')
          ..writeln('  - Label: ${status.label}')
          ..writeln('  - User state: ${status.user.status}')
          ..writeln('  - Linked devices: ${status.linkedDeviceNames}')
          ..writeln('  - Trusted devices: ${status.trustedDeviceNames}')
          ..writeln('  - Recovery PIN count: ${status.recoveryPinCount}')
          ..writeln('  - Denied audit count: ${status.deniedAuditCount}')
          ..writeln('  - Pending audit count: ${status.pendingAuditCount}')
          ..writeln('  - Next step: ${status.nextStep}');
      }
    }

    return buffer.toString();
  }

  String _buildIncidentSummaryReport({
    required UsersDevicesControlSnapshot snapshot,
    required String resultFilter,
    required String query,
  }) {
    final filteredEvents = _buildFilteredIncidentEvents(
      snapshot: snapshot,
      resultFilter: resultFilter,
      query: query,
    );

    final deniedEvents = filteredEvents
        .where((event) => event.result == 'denied')
        .toList(growable: false);
    final pendingEvents = filteredEvents
        .where((event) => event.result == 'pending')
        .toList(growable: false);
    final failedUnlocks = filteredEvents
        .where(
          (event) =>
              event.result == 'denied' &&
              (event.eventType.contains('pin_') ||
                  event.eventType.contains('unlock')),
        )
        .length;

    final buffer = StringBuffer()
      ..writeln('# Users & Devices Incident Summary')
      ..writeln()
      ..writeln('- Generated: ${_now().toUtc().toIso8601String()}')
      ..writeln('- Scope: local audit review only')
      ..writeln('- Result filter: $resultFilter')
      ..writeln(
        '- Search query: ${query.trim().isEmpty ? 'none' : query.trim()}',
      )
      ..writeln('- Events reviewed: ${filteredEvents.length}')
      ..writeln('- Denied events: ${deniedEvents.length}')
      ..writeln('- Pending events: ${pendingEvents.length}')
      ..writeln('- Failed unlocks: $failedUnlocks')
      ..writeln()
      ..writeln('## Pressure summary')
      ..writeln(
        '- Top users: ${_topCounts(filteredEvents, (event) => event.actorId.isEmpty ? 'unknown' : event.actorId).take(3).map((entry) => '${entry.key} (${entry.value})').join(', ')}',
      )
      ..writeln(
        '- Top devices: ${_topCounts(filteredEvents, (event) => event.deviceId.isEmpty ? 'unknown' : event.deviceId).take(3).map((entry) => '${entry.key} (${entry.value})').join(', ')}',
      )
      ..writeln(
        '- Top action families: ${_topCounts(filteredEvents, _actionFamily).take(3).map((entry) => '${entry.key} (${entry.value})').join(', ')}',
      )
      ..writeln()
      ..writeln('## Latest matching events');

    if (filteredEvents.isEmpty) {
      buffer.writeln('- No events matched the current incident view.');
    } else {
      for (final event in filteredEvents.take(12)) {
        buffer
          ..writeln(
            '- ${event.timestamp} :: ${event.eventType} :: ${event.result}',
          )
          ..writeln('  - Actor: ${event.actorId}')
          ..writeln('  - Device: ${event.deviceId}')
          ..writeln('  - Module: ${event.targetModule}')
          ..writeln('  - Action: ${event.action}')
          ..writeln('  - Reason: ${event.reason}');
      }
    }

    return buffer.toString();
  }

  String _buildAdminReviewPack({
    required UsersDevicesControlSnapshot snapshot,
    required UsersDevicesPinRegistrySnapshot pins,
    required String? focusedUserId,
    required String statusFilter,
    required String resultFilter,
    required String query,
  }) {
    final statuses = snapshot.users
        .map(
          (user) =>
              _buildReadinessStatus(snapshot: snapshot, pins: pins, user: user),
        )
        .toList(growable: false);
    final filteredStatuses = statuses
        .where((status) => _matchesReadinessFilter(status, statusFilter))
        .toList(growable: false);
    final selected = statuses
        .where((status) => status.user.id == focusedUserId)
        .toList();
    final focusedStatus = selected.isNotEmpty
        ? selected.first
        : (statuses.isNotEmpty ? statuses.first : null);
    final filteredEvents = _buildFilteredIncidentEvents(
      snapshot: snapshot,
      resultFilter: resultFilter,
      query: query,
    );
    final pendingApprovals = snapshot.approvalQueue
        .where((request) => request.isPending)
        .toList(growable: false);
    final trustBlockedApprovals = pendingApprovals
        .where((request) => _approvalHasTrustBlocker(snapshot, request))
        .toList(growable: false);
    final matrixReviewApprovals = pendingApprovals
        .where((request) => _approvalNeedsMatrixReview(snapshot, request))
        .toList(growable: false);
    final staleApprovals = pendingApprovals
        .where((request) => _approvalAgeHours(request) >= 24)
        .toList(growable: false);
    final highRiskApprovals = pendingApprovals
        .where((request) => request.riskLevel.trim().toLowerCase() == 'high')
        .toList(growable: false);
    final failedUnlocks = filteredEvents
        .where(
          (event) =>
              event.result == 'denied' &&
              (event.eventType.contains('pin_') ||
                  event.eventType.contains('unlock')),
        )
        .length;
    final groupedByActor = _topCounts(
      filteredEvents,
      (event) => event.actorId.isEmpty ? 'unknown' : event.actorId,
    );
    final groupedByDevice = _topCounts(
      filteredEvents,
      (event) => event.deviceId.isEmpty ? 'unknown' : event.deviceId,
    );
    final groupedByModule = _topCounts(
      filteredEvents,
      (event) => _moduleLabel(event.targetModule),
    );
    final groupedByActionFamily = _topCounts(filteredEvents, _actionFamily);
    final prioritizedApprovals = [...pendingApprovals]
      ..sort((left, right) {
        final riskCompare = _approvalRiskScore(
          right.riskLevel,
        ).compareTo(_approvalRiskScore(left.riskLevel));
        if (riskCompare != 0) {
          return riskCompare;
        }
        return _approvalAgeHours(right).compareTo(_approvalAgeHours(left));
      });

    final buffer = StringBuffer()
      ..writeln('# Users & Devices Admin Review Pack')
      ..writeln()
      ..writeln('- Generated: ${_now().toUtc().toIso8601String()}')
      ..writeln('- Scope: local-first admin handoff and trust review')
      ..writeln('- Readiness filter: $statusFilter')
      ..writeln('- Incident result filter: $resultFilter')
      ..writeln(
        '- Incident query: ${query.trim().isEmpty ? 'none' : query.trim()}',
      )
      ..writeln('- Users in snapshot: ${snapshot.users.length}')
      ..writeln('- Matching readiness users: ${filteredStatuses.length}')
      ..writeln('- Devices in snapshot: ${snapshot.devices.length}')
      ..writeln('- Audit events in pack: ${filteredEvents.length}')
      ..writeln()
      ..writeln('## Readiness posture')
      ..writeln(
        '- Ready: ${statuses.where((status) => status.label == 'ready').length}',
      )
      ..writeln(
        '- Blocked: ${statuses.where((status) => status.label == 'blocked').length}',
      )
      ..writeln(
        '- Archived: ${statuses.where((status) => status.label == 'archived').length}',
      )
      ..writeln(
        '- Exception-only: ${statuses.where((status) => status.label == 'exception-only').length}',
      )
      ..writeln(
        '- Need role: ${statuses.where((status) => status.label == 'missing-role').length}',
      )
      ..writeln(
        '- Need PIN: ${statuses.where((status) => status.label == 'missing-pin').length}',
      )
      ..writeln(
        '- Need trust: ${statuses.where((status) => status.label == 'missing-trust').length}',
      )
      ..writeln()
      ..writeln('## Approval pressure')
      ..writeln('- Pending approvals: ${pendingApprovals.length}')
      ..writeln('- High-risk pending: ${highRiskApprovals.length}')
      ..writeln('- Trust-blocked pending: ${trustBlockedApprovals.length}')
      ..writeln('- Matrix-review pending: ${matrixReviewApprovals.length}')
      ..writeln('- Stale pending: ${staleApprovals.length}')
      ..writeln()
      ..writeln('## Audit pressure')
      ..writeln('- Matching events: ${filteredEvents.length}')
      ..writeln(
        '- Denied events: ${filteredEvents.where((event) => event.result == 'denied').length}',
      )
      ..writeln(
        '- Pending events: ${filteredEvents.where((event) => event.result == 'pending').length}',
      )
      ..writeln('- Failed unlocks: $failedUnlocks')
      ..writeln()
      ..writeln('## Grouped audit pressure')
      ..writeln('- Top users: ${_formatTopCounts(groupedByActor)}')
      ..writeln('- Top devices: ${_formatTopCounts(groupedByDevice)}')
      ..writeln('- Top modules: ${_formatTopCounts(groupedByModule)}')
      ..writeln(
        '- Top action families: ${_formatTopCounts(groupedByActionFamily)}',
      );

    if (focusedStatus != null) {
      buffer
        ..writeln()
        ..writeln('## Focused handoff')
        ..writeln('- User: ${focusedStatus.user.displayName}')
        ..writeln('- Role: ${focusedStatus.user.role}')
        ..writeln('- Readiness label: ${focusedStatus.label}')
        ..writeln('- Linked devices: ${focusedStatus.linkedDeviceNames}')
        ..writeln('- Trusted devices: ${focusedStatus.trustedDeviceNames}')
        ..writeln('- Recovery PIN count: ${focusedStatus.recoveryPinCount}')
        ..writeln('- Denied audit count: ${focusedStatus.deniedAuditCount}')
        ..writeln('- Pending audit count: ${focusedStatus.pendingAuditCount}')
        ..writeln('- Next step: ${focusedStatus.nextStep}');
    }

    buffer
      ..writeln()
      ..writeln('## Approvals needing attention first');

    if (prioritizedApprovals.isEmpty) {
      buffer.writeln('- No pending approvals are waiting right now.');
    } else {
      for (final request in prioritizedApprovals.take(8)) {
        buffer
          ..writeln(
            '- ${_moduleLabel(request.targetModule)} :: ${request.action} :: ${request.riskLevel} risk :: age ${_approvalAgeLabel(request)}',
          )
          ..writeln('  - Requester: ${request.requestedBy}')
          ..writeln('  - Device: ${request.deviceId}')
          ..writeln(
            '  - Trust blocker: ${_approvalHasTrustBlocker(snapshot, request) ? 'yes' : 'no'}',
          )
          ..writeln(
            '  - Matrix review: ${_approvalNeedsMatrixReview(snapshot, request) ? 'yes' : 'no'}',
          )
          ..writeln('  - Reason: ${request.reason}');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Latest matching audit events');

    if (filteredEvents.isEmpty) {
      buffer.writeln('- No audit events matched the current pack scope.');
    } else {
      for (final event in filteredEvents.take(12)) {
        buffer
          ..writeln(
            '- ${event.timestamp} :: ${event.eventType} :: ${event.result} :: ${_moduleLabel(event.targetModule)}',
          )
          ..writeln('  - Actor: ${event.actorId}')
          ..writeln('  - Device: ${event.deviceId}')
          ..writeln('  - Action: ${event.action}')
          ..writeln('  - Reason: ${event.reason}');
      }
    }

    return buffer.toString();
  }

  _ReadinessStatus _buildReadinessStatus({
    required UsersDevicesControlSnapshot snapshot,
    required UsersDevicesPinRegistrySnapshot pins,
    required UsersDevicesControlUser user,
  }) {
    final rolePermissions = snapshot.roles
        .firstWhere(
          (role) => role.role.toLowerCase() == user.role.toLowerCase(),
          orElse: () => const UsersDevicesControlRoleDefinition(
            role: '',
            permissions: [],
          ),
        )
        .permissions;
    final linkedDevices = snapshot.devices
        .where((device) => user.linkedDevices.contains(device.id))
        .toList(growable: false);
    final trustedDevices = linkedDevices
        .where((device) => device.isTrusted)
        .toList(growable: false);
    final relatedPins = pins.records
        .where((record) => record.userId == user.id)
        .toList(growable: false);
    final relatedEvents = snapshot.auditLog
        .where(
          (event) =>
              event.actorId == user.id ||
              linkedDevices.any((device) => device.id == event.deviceId),
        )
        .toList(growable: false);
    final hasPrimaryPin = relatedPins.any(
      (record) => record.status == 'active',
    );
    final hasRoleAndPermissions =
        user.permissions.isNotEmpty || rolePermissions.isNotEmpty;
    final hasTrustedDevice = trustedDevices.isNotEmpty;
    final deniedAuditCount = relatedEvents
        .where((event) => event.result == 'denied')
        .length;
    final pendingAuditCount = relatedEvents
        .where((event) => event.result == 'pending')
        .length;
    final recoveryPinCount = relatedPins
        .where((record) => record.status == 'recovery')
        .length;
    final hasBlockedLinkedDevice = linkedDevices.any(
      (device) => device.status == 'blocked',
    );
    final hasQuarantinedLinkedDevice = linkedDevices.any(
      (device) => device.status == 'quarantined',
    );
    final accessReady =
        user.status == 'active' &&
        hasRoleAndPermissions &&
        hasPrimaryPin &&
        hasTrustedDevice &&
        !hasBlockedLinkedDevice &&
        !hasQuarantinedLinkedDevice;

    final label = _readinessLabel(
      userStatus: user.status,
      accessReady: accessReady,
      hasRoleAndPermissions: hasRoleAndPermissions,
      hasPrimaryPin: hasPrimaryPin,
      hasTrustedDevice: hasTrustedDevice,
      recoveryPinCount: recoveryPinCount,
      deniedAuditCount: deniedAuditCount,
      pendingAuditCount: pendingAuditCount,
      hasBlockedLinkedDevice: hasBlockedLinkedDevice,
      hasQuarantinedLinkedDevice: hasQuarantinedLinkedDevice,
    );

    return _ReadinessStatus(
      user: user,
      label: label,
      linkedDeviceNames: linkedDevices.isEmpty
          ? 'None linked'
          : linkedDevices.map((device) => device.name).join(', '),
      trustedDeviceNames: trustedDevices.isEmpty
          ? 'None yet'
          : trustedDevices.map((device) => device.name).join(', '),
      deniedAuditCount: deniedAuditCount,
      pendingAuditCount: pendingAuditCount,
      recoveryPinCount: recoveryPinCount,
      nextStep: accessReady
          ? 'Open Security Lock or a gated module and verify the route.'
          : _nextReadinessStep(
              hasRoleAndPermissions: hasRoleAndPermissions,
              hasPrimaryPin: hasPrimaryPin,
              hasTrustedDevice: hasTrustedDevice,
              hasBlockedLinkedDevice: hasBlockedLinkedDevice,
              hasQuarantinedLinkedDevice: hasQuarantinedLinkedDevice,
            ),
    );
  }

  bool _matchesReadinessFilter(_ReadinessStatus status, String filter) {
    if (filter == 'all') {
      return true;
    }
    return status.label == filter;
  }

  String _readinessLabel({
    required String userStatus,
    required bool accessReady,
    required bool hasRoleAndPermissions,
    required bool hasPrimaryPin,
    required bool hasTrustedDevice,
    required int recoveryPinCount,
    required int deniedAuditCount,
    required int pendingAuditCount,
    required bool hasBlockedLinkedDevice,
    required bool hasQuarantinedLinkedDevice,
  }) {
    if (userStatus == 'archived' || userStatus == 'disabled') {
      return 'archived';
    }
    if (hasBlockedLinkedDevice || hasQuarantinedLinkedDevice) {
      return 'blocked';
    }
    if (accessReady &&
        (deniedAuditCount > 0 ||
            pendingAuditCount > 0 ||
            recoveryPinCount > 0)) {
      return 'exception-only';
    }
    if (accessReady) {
      return 'ready';
    }
    if (!hasRoleAndPermissions) {
      return 'missing-role';
    }
    if (!hasPrimaryPin) {
      return 'missing-pin';
    }
    if (!hasTrustedDevice) {
      return 'missing-trust';
    }
    return 'in-progress';
  }

  String _nextReadinessStep({
    required bool hasRoleAndPermissions,
    required bool hasPrimaryPin,
    required bool hasTrustedDevice,
    required bool hasBlockedLinkedDevice,
    required bool hasQuarantinedLinkedDevice,
  }) {
    if (!hasRoleAndPermissions) {
      return 'Assign the missing role or permission shape first.';
    }
    if (!hasPrimaryPin) {
      return 'Issue a primary PIN before the user is treated as ready.';
    }
    if (hasBlockedLinkedDevice || hasQuarantinedLinkedDevice) {
      return 'Review the linked device before it can satisfy trust checks.';
    }
    if (!hasTrustedDevice) {
      return 'Finish device pairing and trust review.';
    }
    return 'Review the latest audit trail and verify locally.';
  }

  List<MapEntry<String, int>> _topCounts(
    List<UsersDevicesControlAuditEvent> events,
    String Function(UsersDevicesControlAuditEvent event) keyFor,
  ) {
    final counts = <String, int>{};
    for (final event in events) {
      final key = keyFor(event).trim();
      if (key.isEmpty) {
        continue;
      }
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final entries = counts.entries.toList(growable: false)
      ..sort((left, right) => right.value.compareTo(left.value));
    return entries;
  }

  List<UsersDevicesControlAuditEvent> _buildFilteredIncidentEvents({
    required UsersDevicesControlSnapshot snapshot,
    required String resultFilter,
    required String query,
  }) {
    return snapshot.auditLog
        .where((event) {
          if (resultFilter != 'all' && event.result != resultFilter) {
            return false;
          }
          final trimmed = query.trim().toLowerCase();
          if (trimmed.isEmpty) {
            return true;
          }
          final haystack = [
            event.actorId,
            event.deviceId,
            event.eventType,
            event.targetModule,
            event.action,
            event.result,
            event.reason,
            _actionFamily(event),
          ].join(' ').toLowerCase();
          return haystack.contains(trimmed);
        })
        .toList(growable: false);
  }

  bool _approvalHasTrustBlocker(
    UsersDevicesControlSnapshot snapshot,
    UsersDevicesControlApprovalRequest request,
  ) {
    final device = snapshot.devices.where(
      (item) => item.id == request.deviceId,
    );
    final rule = snapshot.accessRules.where(
      (entry) => entry.moduleId == request.targetModule,
    );
    final deviceMatch = device.isEmpty ? null : device.first;
    final matchingRule = rule.isEmpty ? null : rule.first;
    if (deviceMatch == null) {
      return false;
    }
    if (deviceMatch.status == 'quarantined' ||
        deviceMatch.status == 'blocked' ||
        deviceMatch.status == 'archived') {
      return true;
    }
    if (matchingRule == null) {
      return false;
    }
    return deviceMatch.trustLevel < matchingRule.requiresTrustLevel;
  }

  bool _approvalNeedsMatrixReview(
    UsersDevicesControlSnapshot snapshot,
    UsersDevicesControlApprovalRequest request,
  ) {
    final matchingRule = snapshot.accessRules.where(
      (rule) => rule.moduleId == request.targetModule,
    );
    if (matchingRule.isEmpty) {
      return true;
    }
    return !matchingRule.first.requiresApprovalFor.contains(request.action);
  }

  int _approvalAgeHours(UsersDevicesControlApprovalRequest request) {
    final createdAt = DateTime.tryParse(request.timestamp)?.toUtc();
    if (createdAt == null) {
      return 0;
    }
    return _now().toUtc().difference(createdAt).inHours;
  }

  String _approvalAgeLabel(UsersDevicesControlApprovalRequest request) {
    final hours = _approvalAgeHours(request);
    if (hours < 1) {
      return '<1h';
    }
    if (hours < 24) {
      return '${hours}h';
    }
    final days = (hours / 24).floor();
    return '${days}d';
  }

  int _approvalRiskScore(String riskLevel) {
    switch (riskLevel.trim().toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      default:
        return 1;
    }
  }

  String _formatTopCounts(List<MapEntry<String, int>> entries) {
    if (entries.isEmpty) {
      return 'none';
    }
    return entries
        .take(3)
        .map((entry) => '${entry.key} (${entry.value})')
        .join(', ');
  }

  String _moduleLabel(String moduleId) {
    switch (moduleId) {
      case '01_USERS_AND_DEVICES_CONTROL':
        return 'Users & Devices Control';
      case '17_FINANCE_AND_TREASURY':
        return 'Treasury';
      case 'repo_research_engine':
        return 'Repo Research Engine';
      case 'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE':
        return 'Alexa Voice Gateway';
      case 'gaia_voice_assistant':
        return 'GAIA Voice Assistant';
      default:
        return moduleId;
    }
  }

  String _actionFamily(UsersDevicesControlAuditEvent event) {
    final eventType = event.eventType.toLowerCase();
    final action = event.action.toLowerCase();

    if (eventType.contains('pin_') || action.contains('pin')) {
      return 'PIN governance';
    }
    if (eventType.contains('unlock') || action.contains('unlock')) {
      return 'Unlock flow';
    }
    if (eventType.contains('approval') || action.contains('approve')) {
      return 'Approval flow';
    }
    if (eventType.contains('trust') || action.contains('trust')) {
      return 'Device trust';
    }
    if (eventType.contains('role') || action.contains('role')) {
      return 'Role assignment';
    }
    if (eventType.contains('permission') || action.contains('permission')) {
      return 'Permission update';
    }
    if (eventType.contains('device') || action.contains('device')) {
      return 'Device lifecycle';
    }
    if (eventType.contains('module_access') || action.contains('open_')) {
      return 'Module access';
    }
    return 'General audit';
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

  DateTime _now() => nowProvider?.call() ?? DateTime.now();

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

class UsersDevicesControlReportExportResult {
  const UsersDevicesControlReportExportResult._({
    required this.success,
    required this.message,
    required this.reportPath,
    this.backupPath,
    this.pdfPath,
  });

  factory UsersDevicesControlReportExportResult.success({
    required String message,
    required String reportPath,
    String? backupPath,
    String? pdfPath,
  }) {
    return UsersDevicesControlReportExportResult._(
      success: true,
      message: message,
      reportPath: reportPath,
      backupPath: backupPath,
      pdfPath: pdfPath,
    );
  }

  final bool success;
  final String message;
  final String reportPath;
  final String? backupPath;
  final String? pdfPath;
}

class _ReadinessStatus {
  const _ReadinessStatus({
    required this.user,
    required this.label,
    required this.linkedDeviceNames,
    required this.trustedDeviceNames,
    required this.deniedAuditCount,
    required this.pendingAuditCount,
    required this.recoveryPinCount,
    required this.nextStep,
  });

  final UsersDevicesControlUser user;
  final String label;
  final String linkedDeviceNames;
  final String trustedDeviceNames;
  final int deniedAuditCount;
  final int pendingAuditCount;
  final int recoveryPinCount;
  final String nextStep;
}
