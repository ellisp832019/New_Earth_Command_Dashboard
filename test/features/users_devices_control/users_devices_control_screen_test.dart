import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/security/presentation/security_lock_screen.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/application/users_devices_control_controller.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/application/users_devices_pin_registry_controller.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_control_repository.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_pin_registry_service.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/presentation/users_devices_control_screen.dart';

class FakeUsersDevicesControlRepository extends UsersDevicesControlRepository {
  FakeUsersDevicesControlRepository(this._snapshot) : super(database: null);

  final UsersDevicesControlSnapshot _snapshot;

  @override
  Future<UsersDevicesControlSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<UsersDevicesControlMigrationHealthSnapshot>
  loadMigrationHealth() async {
    return const UsersDevicesControlMigrationHealthSnapshot(
      usingDatabase: true,
      schemaVersion: 15,
      databasePath: 'C:/Users/test/Documents/new_earth_command_dashboard.db',
      databaseFileExists: true,
      seedFiles: [
        UsersDevicesControlMigrationSeedFileStatus(
          label: 'Users seed',
          path: 'modules/01_USERS_AND_DEVICES_CONTROL/data/users.example.json',
          exists: true,
        ),
        UsersDevicesControlMigrationSeedFileStatus(
          label: 'Access rules config',
          path:
              'modules/01_USERS_AND_DEVICES_CONTROL/config/module_access_rules.json',
          exists: true,
        ),
      ],
      tables: [
        UsersDevicesControlMigrationTableStatus(
          label: 'Users',
          tableName: 'users_devices_control_users',
          exists: true,
          rowCount: 3,
        ),
        UsersDevicesControlMigrationTableStatus(
          label: 'PIN records',
          tableName: 'users_devices_control_pin_records',
          exists: true,
          rowCount: 2,
        ),
      ],
    );
  }

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
          id: 'user_hayley_finance',
          displayName: 'Hayley Arthur',
          role: 'Co-founder',
          title: 'Finance / Treasury',
          status: 'active',
          permissions: ['finance.view', 'finance.edit'],
          linkedDevices: ['device_phone_scanner'],
          notes: 'Finance test identity.',
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
          trustSource: 'owner review',
          trustReviewedBy: 'user_peter_owner',
          trustReviewedAt: '2026-06-28T09:00:00Z',
          lastSeenAt: '2026-06-29T08:30:00Z',
          operatorNote: 'Primary workstation for admin tasks.',
        ),
        UsersDevicesControlDevice(
          id: 'device_phone_scanner',
          name: 'Phone Scanner',
          type: 'phone',
          trustLevel: 2,
          status: 'quarantined',
          ownerId: 'user_hayley_finance',
          allowedActions: ['dashboard.view'],
          notes: 'Lower trust test device.',
          trustSource: 'onboarding check',
          trustReviewedBy: 'user_peter_owner',
          trustReviewedAt: '2026-06-29T07:15:00Z',
          lastSeenAt: '2026-06-29T07:10:00Z',
          operatorNote: 'Needs another pairing review.',
          quarantineReason:
              'Unexpected device posture during finance onboarding.',
          quarantinedAt: '2026-06-29T07:16:00Z',
        ),
      ],
      roles: [
        UsersDevicesControlRoleDefinition(role: 'Owner', permissions: ['*']),
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
        UsersDevicesControlApprovalRequest(
          requestId: 'approval_demo_2',
          timestamp: '2026-06-17T00:00:00Z',
          requestedBy: 'user_peter_owner',
          deviceId: 'device_new_earth_dev',
          targetModule: '17_FINANCE_AND_TREASURY',
          action: 'export_data',
          status: 'allowed',
          riskLevel: 'medium',
          reason: 'Legacy approval status sample.',
          reviewedBy: 'user_peter_owner',
          reviewedAt: '2026-06-17T01:00:00Z',
        ),
        UsersDevicesControlApprovalRequest(
          requestId: 'approval_demo_3',
          timestamp: '2026-06-16T00:00:00Z',
          requestedBy: 'user_hayley_finance',
          deviceId: 'device_phone_scanner',
          targetModule: '17_FINANCE_AND_TREASURY',
          action: 'change_bank_details',
          status: 'denied',
          riskLevel: 'high',
          reason: 'Denied sample request.',
          reviewedBy: 'user_peter_owner',
          reviewedAt: '2026-06-16T02:00:00Z',
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
    final pins = UsersDevicesPinRegistrySnapshot(
      records: [
        UsersDevicesPinRecord(
          pinId: 'pin_peter_primary',
          userId: 'user_peter_owner',
          label: 'Primary PIN',
          pinCode: '4434',
          status: 'active',
          sourceLabel: 'Local admin',
          createdAt: DateTime(2026, 6, 26),
          updatedAt: DateTime(2026, 6, 26),
        ),
        UsersDevicesPinRecord(
          pinId: 'pin_hayley_recovery',
          userId: 'user_hayley_finance',
          label: 'Recovery PIN',
          pinCode: '112233',
          status: 'recovery',
          sourceLabel: 'Local admin',
          createdAt: DateTime(2026, 6, 26),
          updatedAt: DateTime(2026, 6, 26),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        usersDevicesControlRepositoryProvider.overrideWithValue(repository),
        usersDevicesControlSnapshotProvider.overrideWith(
          (ref) async => snapshot,
        ),
        usersDevicesPinRegistrySnapshotProvider.overrideWith(
          (ref) async => pins,
        ),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('security lock shows the local gate and unlock controls', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const SecurityLockScreen()));
    await pumpUntilFound(tester, find.text('Unlock session'));

    expect(find.text('Unlock session'), findsWidgets);
    expect(find.text('Sleep quietly'), findsWidgets);
    expect(find.text('Exit completely'), findsWidgets);
    expect(find.text('Open Users & Devices'), findsWidgets);
    expect(find.text('Open audit log'), findsOneWidget);
  });

  testWidgets(
    'security lock suggests a stronger identity after switching users',
    (tester) async {
      await tester.pumpWidget(buildTestApp(const SecurityLockScreen()));
      await pumpUntilFound(tester, find.text('Change selected identity'));

      await tester.ensureVisible(find.text('Change selected identity'));
      await tester.tap(find.text('Change selected identity').first);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hayley Arthur').last);
      await tester.pumpAndSettle();

      expect(find.text('Recommended identity'), findsWidgets);
      expect(
        find.textContaining('Peter Owner already has owner-level access'),
        findsWidgets,
      );
      expect(find.text('Use suggested user'), findsOneWidget);
    },
  );

  testWidgets('module home exposes the calm action strip and six screens', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const UsersDevicesControlScreen()));
    await pumpUntilFound(tester, find.text('Register user'));

    expect(find.text('Session checkpoint'), findsOneWidget);
    expect(find.textContaining('Active user: none'), findsOneWidget);
    expect(find.text('Open Security Lock'), findsOneWidget);
    expect(find.text('Register user'), findsWidgets);
    expect(find.text('Register device'), findsWidgets);
    expect(find.text('Create approval'), findsWidgets);
    expect(find.text('Open queue'), findsWidgets);
    expect(find.text('Onboarding pack PDF'), findsWidgets);
    expect(find.text('Recovery drills PDF'), findsWidgets);
    expect(find.text('Migration health'), findsWidgets);
    expect(find.text('Seed demo path'), findsWidgets);
    expect(find.text('Reset demo data'), findsWidgets);
    expect(find.text('Onboarding'), findsWidgets);
    expect(find.text('Onboarding Report'), findsWidgets);
    expect(find.text('Approval Queue'), findsWidgets);
    expect(find.text('Audit Log'), findsWidgets);
    expect(find.text('Migration Health'), findsWidgets);
  });

  testWidgets('module home shows the access review dashboard', (tester) async {
    await tester.pumpWidget(buildTestApp(const UsersDevicesControlScreen()));
    await pumpUntilFound(tester, find.text('Access review dashboard'));

    expect(find.text('Access review dashboard'), findsOneWidget);
    expect(find.text('Session lockouts'), findsOneWidget);
    expect(find.text('Recovery coverage'), findsOneWidget);
    expect(find.text('Device trust pressure'), findsOneWidget);
    expect(find.text('Approval workload'), findsOneWidget);
    expect(find.text('Open approval queue'), findsOneWidget);
  });

  testWidgets('route gate suggests a stronger local user when one is available', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const UsersDevicesRouteGateScreen(
          moduleId: '17_FINANCE_AND_TREASURY',
          title: 'Treasury Access Gate',
          subtitle:
              'Confirm local identity and device trust before opening finance and treasury.',
          child: SizedBox.shrink(),
        ),
      ),
    );
    await pumpUntilFound(tester, find.text('Gate check'));

    await tester.ensureVisible(
      find.byType(DropdownButtonFormField<String>).first,
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hayley Arthur (Co-founder)'));
    await tester.pumpAndSettle();

    expect(find.text('Recommended user'), findsOneWidget);
    expect(find.text('Use suggested user'), findsOneWidget);
    expect(
      find.textContaining('Peter Owner already has owner-level access'),
      findsOneWidget,
    );
  });

  testWidgets('route gate keeps protected context visible after unlock', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const UsersDevicesRouteGateScreen(
          moduleId: '17_FINANCE_AND_TREASURY',
          title: 'Treasury Access Gate',
          subtitle:
              'Confirm local identity and device trust before opening finance and treasury.',
          child: Scaffold(body: Center(child: Text('Treasury workspace'))),
        ),
      ),
    );
    await pumpUntilFound(tester, find.text('Open screen'));

    await tester.ensureVisible(find.text('Open screen').first);
    await tester.tap(find.text('Open screen').first);
    await tester.pumpAndSettle();

    expect(find.text('Treasury workspace'), findsOneWidget);
    expect(find.text('Protected route context'), findsOneWidget);
    expect(find.textContaining('User: '), findsWidgets);
    expect(find.textContaining('Device: '), findsWidgets);
    expect(find.textContaining('Security Lock'), findsOneWidget);
  });

  testWidgets('device onboarding shows the guided user readiness workspace', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const UsersDevicesDeviceOnboardingScreen()),
    );
    await pumpUntilFound(tester, find.text('User readiness workspace'));

    expect(find.text('User readiness workspace'), findsOneWidget);
    expect(find.text('Operator progress board'), findsOneWidget);
    expect(find.text('Device trust review queue'), findsOneWidget);
    expect(find.text('Trust drill checklist'), findsOneWidget);
    expect(find.text('Completion summary'), findsOneWidget);
    expect(find.textContaining('Role and permissions set'), findsOneWidget);
    expect(find.textContaining('Primary PIN is ready'), findsOneWidget);
    expect(find.textContaining('Trusted device linked'), findsOneWidget);
    expect(find.textContaining('Ready to verify locally'), findsOneWidget);
    expect(find.text('Verify access'), findsWidgets);
    expect(find.text('Open PIN Registry'), findsOneWidget);
    expect(find.text('Next operator step'), findsOneWidget);
    expect(find.text('Current blocker summary'), findsOneWidget);
    expect(find.text('Next users to help'), findsOneWidget);
  });

  testWidgets('devices screen shows trust evidence and quarantine review', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const UsersDevicesDevicesScreen()));
    await pumpUntilFound(tester, find.text('Trust evidence queue'));

    expect(find.text('Trust evidence queue'), findsOneWidget);
    expect(find.text('Trust decision checklist'), findsOneWidget);
    expect(find.text('Quarantined devices'), findsOneWidget);
    expect(find.text('Quarantine watchlist'), findsOneWidget);
    expect(find.text('Focus device'), findsWidgets);
    expect(find.text('Review device'), findsWidgets);
    expect(find.textContaining('Unexpected device posture'), findsWidgets);
    expect(find.text('Quarantine'), findsOneWidget);
  });

  testWidgets('approval queue shows triage and normalized approval statuses', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const UsersDevicesApprovalQueueScreen()),
    );
    await pumpUntilFound(tester, find.text('Triage view'));

    expect(find.text('Triage view'), findsOneWidget);
    expect(find.text('Requests needing attention first'), findsOneWidget);
    expect(find.text('Approved'), findsWidgets);
    expect(find.textContaining('This device is quarantined'), findsWidgets);
  });

  testWidgets(
    'onboarding report shows filtered admin status and handoff sheet',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const UsersDevicesOnboardingReportScreen(
            initialUserId: 'user_peter_owner',
          ),
        ),
      );
      await pumpUntilFound(tester, find.text('Copy summary'));

      expect(find.text('Onboarding Report'), findsOneWidget);
      expect(find.text('Readiness dashboard'), findsOneWidget);
      expect(find.text('Open onboarding'), findsOneWidget);
      expect(find.text('Selected user for handoff sheet'), findsOneWidget);
      expect(find.text('Copy summary'), findsWidgets);
      expect(find.text('Export readiness'), findsWidgets);
      expect(find.text('Open exports'), findsWidgets);
      expect(find.text('Onboarding pack PDF'), findsWidgets);
      expect(find.text('Recovery drills PDF'), findsWidgets);
      expect(find.text('Blocked'), findsWidgets);
      expect(find.text('Archived'), findsWidgets);
      expect(find.text('Exceptions'), findsWidgets);
      expect(find.text('Ready'), findsWidgets);
    },
  );

  testWidgets('audit log shows grouped and risk reporting panels', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const UsersDevicesAuditLogScreen()));
    await pumpUntilFound(tester, find.text('Audit posture'));

    expect(find.text('Export incident'), findsOneWidget);
    expect(find.text('Open exports'), findsOneWidget);
    expect(find.text('Latest risk panel'), findsOneWidget);
    expect(find.text('Grouped audit view'), findsOneWidget);
    expect(find.text('By user'), findsOneWidget);
    expect(find.text('By device'), findsOneWidget);
    expect(find.text('By module'), findsOneWidget);
    expect(find.text('By action family'), findsOneWidget);
  });

  testWidgets('migration health shows sqlite and seed posture', (tester) async {
    await tester.pumpWidget(
      buildTestApp(const UsersDevicesMigrationHealthScreen()),
    );
    await pumpUntilFound(tester, find.text('SQLite-first posture'));

    expect(find.text('Migration Health'), findsOneWidget);
    expect(find.text('SQLite-first posture'), findsOneWidget);
    expect(find.text('Tracked tables'), findsOneWidget);
    expect(find.text('Tracked seed and config files'), findsOneWidget);
    expect(find.text('Database mode'), findsOneWidget);
    expect(find.text('Database file'), findsOneWidget);
  });
}
