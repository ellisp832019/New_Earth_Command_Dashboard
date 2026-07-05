import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/modules/module_package_screen.dart';

void main() {
  testWidgets('module package screen uses the module name as its title', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: RouteNames.modulePackage(
              '01_OMEGA_ENGINEERING_STUDIO_MODULE',
            ),
            routes: [
              GoRoute(
                path: '${RouteNames.modulePackages}/:moduleId',
                builder: (context, state) => const ModulePackageScreen(
                  moduleId: '01_OMEGA_ENGINEERING_STUDIO_MODULE',
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Omega Engineering Studio'), findsWidgets);
    expect(find.text('Omega Engineering Studio Package'), findsNothing);
    expect(find.text('Sections'), findsOneWidget);
  });
}
