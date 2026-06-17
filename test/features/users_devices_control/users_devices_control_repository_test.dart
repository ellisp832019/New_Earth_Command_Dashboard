import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart'
    hide
        UsersDevicesControlAccessRule,
        UsersDevicesControlAuditEvent,
        UsersDevicesControlApprovalRequest,
        UsersDevicesControlDevice,
        UsersDevicesControlUser;
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_control_repository.dart';

void main() {
  test('repository seeds the full local registry into Drift once', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = UsersDevicesControlRepository(database: database);
    final snapshot = await repository.loadSnapshot();

    expect(snapshot.users, hasLength(7));
    expect(snapshot.devices, hasLength(9));
    expect(snapshot.roles, hasLength(10));
    expect(snapshot.permissions, hasLength(18));
    expect(snapshot.trustLevels, hasLength(6));
    expect(snapshot.approvalQueue, hasLength(1));
    expect(snapshot.auditLog, hasLength(1));
    expect(snapshot.accessRules, hasLength(5));

    final users = await database.select(database.usersDevicesControlUsers).get();
    final devices = await database.select(database.usersDevicesControlDevices).get();
    final roles = await database.select(database.usersDevicesControlRoles).get();
    final permissions =
        await database.select(database.usersDevicesControlPermissions).get();
    final trustLevels =
        await database.select(database.usersDevicesControlTrustLevels).get();
    final approvals =
        await database.select(database.usersDevicesControlApprovalRequests).get();
    final auditEvents =
        await database.select(database.usersDevicesControlAuditEvents).get();
    final accessRules =
        await database.select(database.usersDevicesControlAccessRules).get();

    expect(users, hasLength(7));
    expect(devices, hasLength(9));
    expect(roles, hasLength(10));
    expect(permissions, hasLength(18));
    expect(trustLevels, hasLength(6));
    expect(approvals, hasLength(1));
    expect(auditEvents, hasLength(1));
    expect(accessRules, hasLength(5));
  });

  test('register and approval actions persist through the local database', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = UsersDevicesControlRepository(database: database);
    await repository.loadSnapshot();

    await repository.registerUser(
      const UsersDevicesControlUser(
        id: 'user_test_contributor',
        displayName: 'Test Contributor',
        role: 'Project Contributor',
        status: 'active',
        permissions: ['projects.view'],
        linkedDevices: ['device_new_earth_dev'],
        notes: 'Created during repository test.',
      ),
    );
    await repository.registerDevice(
      const UsersDevicesControlDevice(
        id: 'device_test_tablet',
        name: 'Test Tablet',
        type: 'tablet',
        trustLevel: 2,
        status: 'registered',
        ownerId: 'user_test_contributor',
        allowedActions: ['dashboard.view'],
        notes: 'Created during repository test.',
      ),
    );
    final request = await repository.createApprovalRequest(
      requestedBy: 'user_test_contributor',
      deviceId: 'device_test_tablet',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'register_device',
      riskLevel: 'medium',
      reason: 'Test approval request.',
    );
    await repository.approveRequest(
      request.requestId,
      reviewedBy: 'user_peter_owner',
    );

    final reloadedRepository = UsersDevicesControlRepository(database: database);
    final snapshot = await reloadedRepository.loadSnapshot();

    expect(
      snapshot.users.any((user) => user.id == 'user_test_contributor'),
      isTrue,
    );
    expect(
      snapshot.devices.any((device) => device.id == 'device_test_tablet'),
      isTrue,
    );
    expect(
      snapshot.approvalQueue.any((item) => item.requestId == request.requestId),
      isTrue,
    );
    final storedRequest = snapshot.approvalQueue.firstWhere(
      (item) => item.requestId == request.requestId,
    );
    expect(storedRequest.status, 'approved');
    expect(storedRequest.reviewedBy, 'user_peter_owner');

    final auditReasons = snapshot.auditLog.map((event) => event.reason).toList();
    expect(auditReasons, contains('Test approval request.'));
  });

  test('access checks still enforce trust and permission rules from stored policies', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = UsersDevicesControlRepository(database: database);
    await repository.loadSnapshot();

    final allowed = await repository.canOpenModule(
      'user_peter_owner',
      'device_new_earth_dev',
      '01_USERS_AND_DEVICES_CONTROL',
    );

    final denied = await repository.canPerformAction(
      'user_guest',
      'device_phone_scanner',
      '01_USERS_AND_DEVICES_CONTROL',
      'assign_role',
    );

    expect(allowed.allowed, isTrue);
    expect(allowed.requiresApproval, isFalse);
    expect(denied.allowed, isFalse);
    expect(denied.requiresApproval, isTrue);
  });

  test('access checks deny unknown users and low trust devices with clear reasons', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = UsersDevicesControlRepository(database: database);
    await repository.loadSnapshot();

    final unknownUserDecision = await repository.canOpenModule(
      'user_missing',
      'device_new_earth_dev',
      '01_USERS_AND_DEVICES_CONTROL',
    );
    final lowTrustDecision = await repository.canOpenModule(
      'user_peter_owner',
      'device_workshop_tablet',
      '01_USERS_AND_DEVICES_CONTROL',
    );

    expect(unknownUserDecision.allowed, isFalse);
    expect(unknownUserDecision.reason, contains('Unknown user'));
    expect(lowTrustDecision.allowed, isFalse);
    expect(lowTrustDecision.reason, contains('trust must be at least level 4'));
  });

  test('high risk actions require approval in the access workflow', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = UsersDevicesControlRepository(database: database);
    await repository.loadSnapshot();

    final decision = await repository.canPerformAction(
      'user_peter_owner',
      'device_new_earth_dev',
      '01_USERS_AND_DEVICES_CONTROL',
      'assign_role',
    );

    expect(decision.allowed, isFalse);
    expect(decision.requiresApproval, isTrue);
    expect(decision.reason, contains('approval'));
  });
}
