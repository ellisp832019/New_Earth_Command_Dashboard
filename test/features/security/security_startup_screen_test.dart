import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/security/presentation/security_startup_screen.dart';

void main() {
  testWidgets('startup screen waits before opening the security lock', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: RouteNames.startup,
      routes: [
        GoRoute(
          path: RouteNames.startup,
          builder: (context, state) =>
              const SecurityStartupScreen(delay: Duration(seconds: 2)),
        ),
        GoRoute(
          path: RouteNames.securityLock,
          builder: (context, state) =>
              const Scaffold(body: Text('Security Lock')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Security Lock'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Security Lock'), findsOneWidget);
  });
}
