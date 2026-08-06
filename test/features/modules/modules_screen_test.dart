import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/modules/modules_screen.dart';

void main() {
  testWidgets('module hub screen keeps the shared registry shell visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ModulesScreen())),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Module Hub'), findsOneWidget);
    expect(find.text('Live local module registry'), findsWidgets);
    expect(find.text('More - Module Hub'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Filters'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Filters'), findsOneWidget);
  });
}
