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
    expect(find.text('This Week'), findsWidgets);
    expect(find.text('This Month'), findsWidgets);
    expect(find.text('Product portfolio'), findsOneWidget);
    expect(find.text('Grants pipeline'), findsOneWidget);
    expect(find.text('Index Explorer'), findsOneWidget);
    expect(find.text('Generated indexes'), findsOneWidget);
    expect(find.text('Linked files'), findsOneWidget);
    expect(find.text('company_index.generated.json'), findsOneWidget);

    await tester.tap(find.text('Compliance & Deadlines').last);
    await tester.pumpAndSettle();

    expect(find.text('Compliance & deadlines'), findsOneWidget);
    expect(find.text('Company records'), findsWidgets);
    expect(find.text('Banking'), findsWidgets);
    expect(find.text('Tax/admin'), findsWidgets);
    expect(find.text('Public presence'), findsWidgets);
    expect(find.text('modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md'), findsWidgets);

    await tester.tap(find.text('Finance Snapshot').last);
    await tester.pumpAndSettle();

    expect(find.text('Finance task tracker'), findsOneWidget);
    expect(find.text('Confirm bank account details'), findsOneWidget);
    expect(find.text('Review VAT / PAYE timing'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Backup root'), findsOneWidget);
    expect(find.text('Audit log'), findsOneWidget);
    expect(find.text('Copy first, then overwrite'), findsOneWidget);
    expect(find.text('Export company summary'), findsOneWidget);
    expect(find.text('Summary report'), findsOneWidget);

    await tester.tap(find.text('Index Explorer').last);
    await tester.pumpAndSettle();

    expect(find.text('Search indexes'), findsOneWidget);
    expect(find.text('Source available'), findsWidgets);
    expect(find.text('All'), findsWidgets);
  });
}
