import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/security/application/security_session_controller.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/application/users_devices_control_controller.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/application/users_devices_pin_registry_controller.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_control_repository.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/data/users_devices_pin_registry_service.dart';
import 'package:new_earth_command_dashboard/features/users_devices_control/presentation/users_devices_pins_screen.dart';

class _FakeUsersDevicesControlRepository extends UsersDevicesControlRepository {
  _FakeUsersDevicesControlRepository(this._snapshot) : super(database: null);

  final UsersDevicesControlSnapshot _snapshot;

  @override
  Future<UsersDevicesControlSnapshot> loadSnapshot() async => _snapshot;
}

class _UnlockedSecuritySessionNotifier extends SecuritySessionNotifier {
  @override
  SecuritySessionState build() {
    final now = DateTime.now();
    final unlocked = SecuritySessionState(
      isUnlocked: true,
      timeout: const Duration(minutes: 15),
      lastActivityAt: now,
      expiresAt: now.add(const Duration(minutes: 15)),
      activeUserLabel: 'Peter Ellis',
      activeDeviceLabel: 'NEW_EARTH_DEV',
      activeUserOnline: true,
    );
    SecuritySessionRouterBridge.sync(unlocked);
    ref.onDispose(_reset);
    return unlocked;
  }

  void _reset() {
    SecuritySessionRouterBridge.sync(const SecuritySessionState.locked());
  }
}

void main() {
  UsersDevicesControlSnapshot sampleSnapshot() {
    return const UsersDevicesControlSnapshot(
      users: [
        UsersDevicesControlUser(
          id: 'user_peter_owner',
          displayName: 'Peter Ellis',
          role: 'Owner',
          status: 'active',
          permissions: ['*'],
          linkedDevices: ['device_new_earth_dev'],
        ),
        UsersDevicesControlUser(
          id: 'user_hayley_finance',
          displayName: 'Hayley Arthur',
          role: 'Co-founder',
          status: 'active',
          permissions: ['finance.view'],
          linkedDevices: ['device_phone_scanner'],
        ),
        UsersDevicesControlUser(
          id: 'user_guest_ops',
          displayName: 'Guest Ops',
          role: 'Operator',
          status: 'active',
          permissions: ['projects.view'],
          linkedDevices: ['device_guest_tablet'],
        ),
      ],
      devices: [
        UsersDevicesControlDevice(
          id: 'device_new_earth_dev',
          name: 'NEW_EARTH_DEV',
          type: 'laptop',
          trustLevel: 5,
          status: 'trusted',
          ownerId: 'user_peter_owner',
          allowedActions: ['dashboard.view'],
        ),
        UsersDevicesControlDevice(
          id: 'device_phone_scanner',
          name: 'Phone Scanner',
          type: 'phone',
          trustLevel: 3,
          status: 'registered',
          ownerId: 'user_hayley_finance',
          allowedActions: ['finance.view'],
        ),
        UsersDevicesControlDevice(
          id: 'device_guest_tablet',
          name: 'Guest Tablet',
          type: 'tablet',
          trustLevel: 2,
          status: 'registered',
          ownerId: 'user_guest_ops',
          allowedActions: ['projects.view'],
        ),
      ],
      roles: [],
      permissions: [],
      trustLevels: [],
      approvalQueue: [],
      auditLog: [],
      accessRules: [],
    );
  }

  Widget buildTestApp({
    String? initialUserId,
    required UsersDevicesPinRegistrySnapshot pinSnapshot,
  }) {
    final snapshot = sampleSnapshot();
    return ProviderScope(
      overrides: [
        usersDevicesControlRepositoryProvider.overrideWithValue(
          _FakeUsersDevicesControlRepository(snapshot),
        ),
        usersDevicesControlSnapshotProvider.overrideWith(
          (ref) async => snapshot,
        ),
        usersDevicesPinRegistrySnapshotProvider.overrideWith(
          (ref) async => pinSnapshot,
        ),
        securitySessionProvider.overrideWith(
          _UnlockedSecuritySessionNotifier.new,
        ),
      ],
      child: MaterialApp(
        home: UsersDevicesPinsScreen(initialUserId: initialUserId),
      ),
    );
  }

  testWidgets('pins screen shows recovery queue and reset flow', (
    tester,
  ) async {
    final pinSnapshot = UsersDevicesPinRegistrySnapshot(
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
      lockouts: [
        UsersDevicesPinLockoutState(
          userId: 'user_hayley_finance',
          failedAttempts: 3,
          lockedUntil: DateTime.now().toUtc().add(const Duration(minutes: 4)),
          lastFailedAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      ],
    );

    await tester.pumpWidget(
      buildTestApp(
        initialUserId: 'user_hayley_finance',
        pinSnapshot: pinSnapshot,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Recovery & reset queue', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Locked out: 1', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Missing primary: 2', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Recovery live: 1', skipOffstage: false), findsOneWidget);
    expect(find.text('Admin reset flow'), findsOneWidget);
    expect(find.text('Governed reset checklist'), findsOneWidget);
    expect(find.text('Clear lockout timer'), findsOneWidget);
    expect(find.text('Recovery rotation guidance'), findsOneWidget);
    expect(find.text('PIN event timeline'), findsOneWidget);
    expect(find.textContaining('Cooldown:'), findsOneWidget);
    expect(
      find.textContaining('currently in a cooldown window'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Verify the person and confirm you are working on'),
      findsOneWidget,
    );
    expect(find.text('Set primary PIN'), findsWidgets);
    expect(find.text('Hayley Arthur (Co-founder)'), findsWidgets);
    expect(find.text('Focus user', skipOffstage: false), findsWidgets);
  });

  testWidgets(
    'pins screen shows calm queue clear state when no user needs help',
    (tester) async {
      final pinSnapshot = UsersDevicesPinRegistrySnapshot(
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
            pinId: 'pin_hayley_primary',
            userId: 'user_hayley_finance',
            label: 'Primary PIN',
            pinCode: '7788',
            status: 'active',
            sourceLabel: 'Local admin',
            createdAt: DateTime(2026, 6, 26),
            updatedAt: DateTime(2026, 6, 26),
          ),
          UsersDevicesPinRecord(
            pinId: 'pin_guest_primary',
            userId: 'user_guest_ops',
            label: 'Primary PIN',
            pinCode: '8899',
            status: 'active',
            sourceLabel: 'Local admin',
            createdAt: DateTime(2026, 6, 26),
            updatedAt: DateTime(2026, 6, 26),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(
          initialUserId: 'user_peter_owner',
          pinSnapshot: pinSnapshot,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'No users need PIN recovery help right now. Primary and recovery posture looks calm.',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.text('Locked out: 0', skipOffstage: false), findsOneWidget);
      expect(find.text('Governed reset checklist'), findsOneWidget);
      expect(
        find.text('Missing primary: 0', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('Recovery live: 0', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Recovery rotation guidance'), findsOneWidget);
      expect(find.text('PIN event timeline'), findsOneWidget);
    },
  );
}
