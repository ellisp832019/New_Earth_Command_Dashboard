import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/security/application/security_session_controller.dart';

void main() {
  group('SecuritySessionNotifier', () {
    tearDown(() {
      SecuritySessionRouterBridge.sync(const SecuritySessionState.locked());
    });

    test('unlock stores active identity, timeout, and router bridge state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(securitySessionProvider.notifier)
          .unlock(
            timeout: const Duration(minutes: 20),
            activeUserLabel: 'Peter Ellis',
            activeDeviceLabel: 'NEW_EARTH_DEV',
            activeUserOnline: true,
          );

      final session = container.read(securitySessionProvider);
      expect(session.isUnlocked, isTrue);
      expect(session.isExpired, isFalse);
      expect(session.timeout, const Duration(minutes: 20));
      expect(session.activeUserLabel, 'Peter Ellis');
      expect(session.activeDeviceLabel, 'NEW_EARTH_DEV');
      expect(session.activeUserOnline, isTrue);
      expect(session.remaining, isNotNull);

      expect(SecuritySessionRouterBridge.current.isUnlocked, isTrue);
      expect(
        SecuritySessionRouterBridge.current.activeUserLabel,
        'Peter Ellis',
      );
      expect(
        SecuritySessionRouterBridge.current.activeDeviceLabel,
        'NEW_EARTH_DEV',
      );
    });

    test('recordActivity refreshes expiry for an unlocked session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(securitySessionProvider.notifier)
          .unlock(
            timeout: const Duration(minutes: 15),
            activeUserLabel: 'Peter Ellis',
          );
      final firstState = container.read(securitySessionProvider);
      final firstExpiry = firstState.expiresAt;

      await Future<void>.delayed(const Duration(milliseconds: 20));
      container.read(securitySessionProvider.notifier).recordActivity();

      final updatedState = container.read(securitySessionProvider);
      expect(updatedState.isUnlocked, isTrue);
      expect(updatedState.lastActivityAt, isNotNull);
      expect(updatedState.expiresAt, isNotNull);
      expect(updatedState.expiresAt!.isAfter(firstExpiry!), isTrue);
    });

    test(
      'lockNow clears session identity and returns router bridge to locked',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(securitySessionProvider.notifier)
            .unlock(
              activeUserLabel: 'Peter Ellis',
              activeDeviceLabel: 'NEW_EARTH_DEV',
              activeUserOnline: true,
            );

        container.read(securitySessionProvider.notifier).lockNow();

        final session = container.read(securitySessionProvider);
        expect(session.isUnlocked, isFalse);
        expect(session.isExpired, isTrue);
        expect(session.activeUserLabel, isNull);
        expect(session.activeDeviceLabel, isNull);
        expect(session.activeUserOnline, isFalse);
        expect(session.remaining, isNull);

        expect(SecuritySessionRouterBridge.current.isUnlocked, isFalse);
        expect(SecuritySessionRouterBridge.current.activeUserLabel, isNull);
        expect(SecuritySessionRouterBridge.current.activeDeviceLabel, isNull);
      },
    );
  });
}
