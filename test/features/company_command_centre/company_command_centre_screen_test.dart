import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/features/company_command_centre/presentation/company_command_centre_screen.dart';

void main() {
  testWidgets('company command centre shows the read-only shell', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const CompanyCommandCentreScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Company Command Centre'), findsAtLeastNWidgets(1));
    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('New Earth Advanced Technologies Ltd'), findsOneWidget);
    expect(
      find.text(r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Website & brand'), findsOneWidget);
    expect(find.text('LinkedIn & marketing'), findsOneWidget);
    expect(find.text('Create Technologies page'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('IP & Asset Register'), findsOneWidget);
    expect(find.text('Open Assets'), findsOneWidget);
    expect(find.text('Evidence Library'), findsOneWidget);
    expect(find.text('UK company admin checklist'), findsOneWidget);
    expect(find.text('Product portfolio'), findsOneWidget);
    expect(find.text('Grants pipeline'), findsOneWidget);
  });
}
