import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/core/routing/security_route_policy.dart';
import 'package:new_earth_command_dashboard/features/security/application/security_session_controller.dart';

void main() {
  group('SecurityRoutePolicy', () {
    test('only allows security lock while locked', () {
      const locked = SecuritySessionState.locked();

      expect(
        SecurityRoutePolicy.redirectForSession(
          requestedUri: Uri.parse(RouteNames.securityLock),
          session: locked,
        ),
        isNull,
      );
      expect(
        SecurityRoutePolicy.redirectForSession(
          requestedUri: Uri.parse(RouteNames.usersDevices),
          session: locked,
        ),
        isNotNull,
      );
      expect(
        SecurityRoutePolicy.redirectForSession(
          requestedUri: Uri.parse(RouteNames.usersDevicesAuditLog),
          session: locked,
        ),
        isNotNull,
      );
    });

    test('blocks protected routes while locked and preserves resume route', () {
      const locked = SecuritySessionState.locked();

      final redirect = SecurityRoutePolicy.redirectForSession(
        requestedUri: Uri.parse('${RouteNames.treasury}?tab=summary'),
        session: locked,
      );

      expect(redirect, isNotNull);
      final redirectUri = Uri.parse(redirect!);
      expect(redirectUri.path, RouteNames.securityLock);
      expect(
        redirectUri.queryParameters['resume'],
        '${RouteNames.treasury}?tab=summary',
      );
    });

    test('blocks PIN registry while locked', () {
      const locked = SecuritySessionState.locked();

      final redirect = SecurityRoutePolicy.redirectForSession(
        requestedUri: Uri.parse(RouteNames.usersDevicesPins),
        session: locked,
      );

      expect(redirect, isNotNull);
      expect(Uri.parse(redirect!).path, RouteNames.securityLock);
    });

    test('blocks users-devices admin child routes while locked', () {
      const locked = SecuritySessionState.locked();

      final protectedRoutes = [
        RouteNames.usersDevicesUsers,
        RouteNames.usersDevicesDevices,
        RouteNames.usersDevicesAccessMatrix,
        RouteNames.usersDevicesDeviceOnboarding,
        RouteNames.usersDevicesOnboardingReport,
        RouteNames.usersDevicesApprovalQueue,
        RouteNames.usersDevicesAuditLog,
        RouteNames.usersDevicesPins,
      ];

      for (final route in protectedRoutes) {
        final redirect = SecurityRoutePolicy.redirectForSession(
          requestedUri: Uri.parse(route),
          session: locked,
        );

        expect(
          redirect,
          isNotNull,
          reason: 'Expected $route to redirect while locked.',
        );
        final redirectUri = Uri.parse(redirect!);
        expect(redirectUri.path, RouteNames.securityLock);
        expect(redirectUri.queryParameters['resume'], route);
      }
    });

    test(
      'does not treat future users-devices child routes as public by prefix',
      () {
        const locked = SecuritySessionState.locked();

        final redirect = SecurityRoutePolicy.redirectForSession(
          requestedUri: Uri.parse('/users-devices/future-admin-surface'),
          session: locked,
        );

        expect(redirect, isNotNull);
        expect(Uri.parse(redirect!).path, RouteNames.securityLock);
      },
    );

    test('resume route parser ignores empty and self-referential values', () {
      expect(
        SecurityRoutePolicy.resumeRouteFrom(Uri.parse(RouteNames.securityLock)),
        isNull,
      );
      expect(
        SecurityRoutePolicy.resumeRouteFrom(
          Uri.parse(RouteNames.securityLockWithResume(RouteNames.securityLock)),
        ),
        isNull,
      );
      expect(
        SecurityRoutePolicy.resumeRouteFrom(
          Uri.parse(
            RouteNames.securityLockWithResume(
              RouteNames.usersDevicesAccessMatrix,
            ),
          ),
        ),
        RouteNames.usersDevicesAccessMatrix,
      );
    });

    test('securityLockFrom preserves current protected destination', () {
      final redirect = SecurityRoutePolicy.securityLockFrom(
        Uri.parse(RouteNames.usersDevicesAccessMatrix),
      );

      final redirectUri = Uri.parse(redirect);
      expect(redirectUri.path, RouteNames.securityLock);
      expect(
        redirectUri.queryParameters['resume'],
        RouteNames.usersDevicesAccessMatrix,
      );
    });
  });
}
