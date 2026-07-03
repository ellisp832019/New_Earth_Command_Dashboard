import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/presentation/engineering_studio_screen.dart';

import 'engineering_studio_test_fixtures.dart';

void main() {
  testWidgets('engineering dashboard renders a calm overview', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: EngineeringStudioScreen(
          repository: EngineeringStudioFakeRepository(
            buildEngineeringStudioSnapshot(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(EngineeringStudioScreen),
      matchesGoldenFile('goldens/engineering_studio_dashboard.png'),
    );
  });
}
