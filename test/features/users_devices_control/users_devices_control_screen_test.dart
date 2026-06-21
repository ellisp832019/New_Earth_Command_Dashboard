import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/security/presentation/security_lock_screen.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/application/users_devices_control_controller.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_control_repository.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/presentation/users_devices_control_screen.dart';

class FakeUsersDevicesControlRepository extends UsersDevicesControlRepository {
  FakeUsersDevicesControlRepository(this._snapshot) : super(database: null);

  final UsersDevicesControlSnapshot _snapshot;

  @override
  Future<UsersDevicesControlSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<UsersDevicesControlAccessDecision> canOpenModule(
    String userId,
    String deviceId,
    String moduleId,
  ) async {
    return const UsersDevicesControlAccessDecision(
      allowed: true,
      requiresApproval: false,
      reason: 'Identity, role, permission, and trust checks passed.',
    );
  }
}

void main() {
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxIterations = 40,
    Duration step = const Duration(milliseconds: 100),
  }) async {
    for (var i = 0; i < maxIterations; i++) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(step);
    }
  }

  UsersDevicesControlSnapshot sampleSnapshot() {
    return const UsersDevicesControlSnapshot(
      users: [
        UsersDevicesControlUser(
          id: 'user_peter_owner',
          displayName: 'Peter Owner',
          role: 'Owner',
          title: 'Module guardian',
          status: 'active',
          permissions: ['*', 'users.manage', 'devices.manage'],
          linkedDevices: ['device_new_earth_dev'],
          notes: 'Primary local reviewer.',
        ),
        UsersDevicesControlUser(
          id: 'user_guest',
          displayName: 'Guest User',
          role: 'Guest',
          status: 'active',
          permissions: ['projects.view'],
          linkedDevices: ['device_phone_scanner'],
          notes: 'Demo identity.',
        ),
      ],
      devices: [
        UsersDevicesControlDevice(
          id: 'device_new_earth_dev',
          name: 'New Earth Dev Machine',
          type: 'laptop',
          trustLevel: 5,
          status: 'trusted',
          ownerId: 'user_peter_owner',
          allowedActions: ['dashboard.view', 'users.manage'],
          notes: 'Trusted local development device.',
        ),
        UsersDevicesControlDevice(
          id: 'device_phone_scanner',
          name: 'Phone Scanner',
          type: 'phone',
          trustLevel: 2,
          status: 'registered',
          ownerId: 'user_guest',
          allowedActions: ['dashboard.view'],
          notes: 'Lower trust test device.',
        ),
      ],
      roles: [
        UsersDevicesControlRoleDefinition(
          role: 'Owner',
          permissions: ['*'],
        ),
      ],
      permissions: [
        UsersDevicesControlPermissionDefinition(
          permission: 'users.manage',
          description: 'Manage the local user registry.',
        ),
        UsersDevicesControlPermissionDefinition(
          permission: 'devices.manage',
          description: 'Manage the local device registry.',
        ),
      ],
      trustLevels: [
        UsersDevicesControlTrustLevelDefinition(
          level: 1,
          name: 'Low',
          description: 'Freshly registered or unverified.',
        ),
        UsersDevicesControlTrustLevelDefinition(
          level: 5,
          name: 'Trusted',
          description: 'Known and verified local device.',
        ),
      ],
      approvalQueue: [
        UsersDevicesControlApprovalRequest(
          requestId: 'approval_demo_1',
          timestamp: '2026-06-18T00:00:00Z',
          requestedBy: 'user_guest',
          deviceId: 'device_phone_scanner',
          targetModule: '01_USERS_AND_DEVICES_CONTROL',
          action: 'assign_role',
          status: 'pending',
          riskLevel: 'high',
          reason: 'Sample approval request for queue review.',
        ),
      ],
      auditLog: [
        UsersDevicesControlAuditEvent(
          eventId: 'audit_demo_1',
          timestamp: '2026-06-18T00:00:00Z',
          actorId: 'user_peter_owner',
          deviceId: 'device_new_earth_dev',
          eventType: 'module_access_checked',
          targetModule: '01_USERS_AND_DEVICES_CONTROL',
          action: 'view',
          result: 'allowed',
          reason: 'Sample audit event.',
        ),
      ],
      accessRules: [
        UsersDevicesControlAccessRule(
          moduleId: '01_USERS_AND_DEVICES_CONTROL',
          viewPermission: 'users.view',
          editPermission: 'users.manage',
          adminPermission: 'users.admin',
          requestPermission: 'users.request',
          executePermission: 'users.execute',
          controlPermission: 'users.control',
          requiresTrustLevel: 3,
          requiresApprovalFor: ['assign_role'],
        ),
        UsersDevicesControlAccessRule(
          moduleId: '17_FINANCE_AND_TREASURY',
          viewPermission: 'finance.view',
          editPermission: 'finance.edit',
          adminPermission: 'finance.admin',
          requiresTrustLevel: 4,
          requiresApprovalFor: [
            'delete_record',
            'export_data',
            'change_bank_details',
          ],
        ),
      ],
    );
  }

  Widget buildTestApp(Widget child) {
    final snapshot = sampleSnapshot();
    final repository = FakeUsersDevicesControlRepository(snapshot);

    return ProviderScope(
      overrides: [
        usersDevicesControlRepositoryProvider.overrideWithValue(repository),
        usersDevicesControlSnapshotProvider.overrideWith((ref) async => snapshot),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('security lock shows the local gate and unlock controls', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const SecurityLockScreen()));
    await pumpUntilFound(tester, find.text('Unlock locally'));

    expect(find.text('Unlock locally'), findsOneWidget);

    await tester.ensureVisible(find.text('Unlock locally'));
    await tester.tap(find.text('Unlock locally'));
    await pumpUntilFound(tester, find.text('Continue to control center'));

    expect(find.text('Continue to control center'), findsOneWidget);
    expect(find.text('Open Users & Devices'), findsOneWidget);
    expect(find.text('Open audit log'), findsOneWidget);
  });

  testWidgets('module home exposes the calm action strip and six screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const UsersDevicesControlScreen()),
    );
    await pumpUntilFound(tester, find.text('Register user'));

    expect(find.text('Register user'), findsWidgets);
    expect(find.text('Register device'), findsWidgets);
    expect(find.text('Create approval'), findsWidgets);
    expect(find.text('Open queue'), findsWidgets);
    expect(find.text('Seed demo path'), findsWidgets);
    expect(find.text('Reset demo data'), findsWidgets);
    expect(find.text('Gatekeeper snapshot'), findsOneWidget);
    expect(find.text('Treasury'), findsWidgets);
    expect(find.text('Open access matrix'), findsOneWidget);
    expect(find.text('Open audit log'), findsOneWidget);
    expect(find.text('Onboarding'), findsWidgets);
    expect(find.text('Approval Queue'), findsWidgets);
    expect(find.text('Audit Log'), findsWidgets);

    await tester.tap(find.text('Onboarding').last);
    await tester.pumpAndSettle();

    expect(find.text('Trust posture'), findsOneWidget);
    expect(find.text('Trust levels'), findsOneWidget);

    await tester.tap(find.text('Approval Queue').last);
    await tester.pumpAndSettle();

    expect(find.text('Queue posture'), findsOneWidget);

    await tester.tap(find.text('Audit Log').last);
    await tester.pumpAndSettle();

    expect(find.text('Audit posture'), findsOneWidget);
  });

}
