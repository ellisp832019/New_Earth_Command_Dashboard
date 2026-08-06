import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/presentation/engineering_studio_screen.dart';

import 'engineering_studio_test_fixtures.dart';

void main() {
  testWidgets('documentation section surfaces the attachment drop zone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: EngineeringStudioScreen(
          repository: EngineeringStudioFakeRepository(
            buildEngineeringStudioSnapshot(),
          ),
          initialSection: EngineeringSection.documentation,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Drop or pick a local attachment'), findsOneWidget);
    expect(find.text('Add attachment'), findsOneWidget);
    expect(find.text('Add doc'), findsOneWidget);
  });
}
