import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_control_report_service.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_control_repository.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_pin_registry_service.dart';

void main() {
  test(
    'admin review pack export includes readiness, approvals, and audit',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'users_devices_report_service_test_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final fixedNow = DateTime.utc(2026, 6, 30, 12);
      final service = UsersDevicesControlReportService(
        moduleRootPath: tempDir.path,
        nowProvider: () => fixedNow,
      );

      final snapshot = UsersDevicesControlSnapshot(
        users: const [
          UsersDevicesControlUser(
            id: 'user_peter_owner',
            displayName: 'Peter Ellis',
            role: 'Owner',
            status: 'active',
            permissions: ['dashboard.view', 'finance.view'],
            linkedDevices: ['device_new_earth_dev'],
          ),
        ],
        devices: const [
          UsersDevicesControlDevice(
            id: 'device_new_earth_dev',
            name: 'NEW_EARTH_DEV',
            type: 'workstation',
            trustLevel: 2,
            status: 'quarantined',
            ownerId: 'user_peter_owner',
            allowedActions: ['view_dashboard'],
            quarantineReason: 'Unexpected trust drift',
          ),
        ],
        roles: const [
          UsersDevicesControlRoleDefinition(
            role: 'Owner',
            permissions: ['dashboard.view', 'finance.view'],
          ),
        ],
        permissions: const [],
        trustLevels: const [],
        approvalQueue: [
          UsersDevicesControlApprovalRequest(
            requestId: 'approval_1',
            timestamp: fixedNow
                .subtract(const Duration(hours: 30))
                .toIso8601String(),
            requestedBy: 'user_peter_owner',
            deviceId: 'device_new_earth_dev',
            targetModule: '17_FINANCE_AND_TREASURY',
            action: 'delete_record',
            status: 'pending',
            riskLevel: 'high',
            reason: 'Needs sensitive finance action',
          ),
        ],
        auditLog: [
          UsersDevicesControlAuditEvent(
            eventId: 'audit_1',
            timestamp: fixedNow
                .subtract(const Duration(hours: 1))
                .toIso8601String(),
            actorId: 'user_peter_owner',
            deviceId: 'device_new_earth_dev',
            eventType: 'pin_unlock_failed',
            targetModule: '17_FINANCE_AND_TREASURY',
            action: 'unlock_session',
            result: 'denied',
            reason: 'PIN did not match',
          ),
        ],
        accessRules: const [
          UsersDevicesControlAccessRule(
            moduleId: '17_FINANCE_AND_TREASURY',
            requiresTrustLevel: 4,
            requiresApprovalFor: ['delete_record'],
          ),
        ],
      );

      final pins = UsersDevicesPinRegistrySnapshot(
        records: [
          UsersDevicesPinRecord(
            pinId: 'pin_primary',
            userId: 'user_peter_owner',
            label: 'Primary PIN',
            pinCode: '4434',
            status: 'active',
            sourceLabel: 'Local admin',
            createdAt: fixedNow.subtract(const Duration(days: 5)),
            updatedAt: fixedNow.subtract(const Duration(days: 1)),
          ),
        ],
      );

      final result = await service.exportAdminReviewPack(
        snapshot: snapshot,
        pins: pins,
        focusedUserId: 'user_peter_owner',
        statusFilter: 'all',
        resultFilter: 'denied',
        query: 'unlock',
      );

      expect(result.success, isTrue);
      expect(File(result.reportPath).existsSync(), isTrue);
      expect(result.pdfPath, isNotNull);
      expect(File(result.pdfPath!).existsSync(), isTrue);

      final content = await File(result.reportPath).readAsString();
      expect(content, contains('# Users & Devices Admin Review Pack'));
      expect(content, contains('## Readiness posture'));
      expect(content, contains('## Approval pressure'));
      expect(content, contains('## Audit pressure'));
      expect(content, contains('## Grouped audit pressure'));
      expect(content, contains('## Focused handoff'));
      expect(content, contains('## Approvals needing attention first'));
      expect(content, contains('## Latest matching audit events'));
      expect(content, contains('Trust-blocked pending: 1'));
      expect(content, contains('Matrix-review pending: 0'));
      expect(content, contains('Stale pending: 1'));
    },
  );
}
