import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/features/security/application/security_session_controller.dart';
import 'package:new_earth_command_dashboard/features/security/presentation/security_session_activity_tracker.dart';

class _SpySecuritySessionNotifier extends SecuritySessionNotifier {
  static int recordActivityCalls = 0;

  @override
  SecuritySessionState build() {
    final now = DateTime.now();
    final unlocked = SecuritySessionState(
      isUnlocked: true,
      timeout: const Duration(minutes: 15),
      lastActivityAt: now,
      expiresAt: now.add(const Duration(minutes: 15)),
      activeUserLabel: 'Test User',
      activeDeviceLabel: 'TEST_DEVICE',
      activeUserOnline: true,
    );
    SecuritySessionRouterBridge.sync(unlocked);
    ref.onDispose(
      () =>
          SecuritySessionRouterBridge.sync(const SecuritySessionState.locked()),
    );
    return unlocked;
  }

  @override
  void recordActivity() {
    recordActivityCalls++;
  }
}

void main() {
  setUp(() {
    _SpySecuritySessionNotifier.recordActivityCalls = 0;
  });

  testWidgets('tap gestures mark security session activity', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securitySessionProvider.overrideWith(_SpySecuritySessionNotifier.new),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SecuritySessionActivityTracker(
              child: SizedBox.expand(child: ColoredBox(color: Colors.blue)),
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(120, 120));
    await tester.pump();

    expect(_SpySecuritySessionNotifier.recordActivityCalls, greaterThan(0));
  });
}
