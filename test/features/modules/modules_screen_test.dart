import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/modules/modules_screen.dart';

void main() {
  testWidgets('module hub screen shows a back button to More', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ModulesScreen())),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Back to More'), findsOneWidget);
    expect(find.text('Module Hub'), findsOneWidget);
  });
}
