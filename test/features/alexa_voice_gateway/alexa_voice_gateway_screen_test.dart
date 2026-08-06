import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/alexa_voice_gateway/presentation/alexa_voice_gateway_screen.dart';

void main() {
  testWidgets('alexa voice gateway screen shows the guarded doorway status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AlexaVoiceGatewayScreen(enableAutoRefresh: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alexa Voice Gateway is paused'), findsOneWidget);
    expect(find.text('Quick start'), findsOneWidget);
    expect(find.text('Start gateway now'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Copy Windows start'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Copy Windows start'), findsOneWidget);
    expect(find.text('Copy launcher command'), findsOneWidget);
    expect(find.text('Copy launcher path'), findsOneWidget);
    expect(find.text('Copy module path'), findsOneWidget);
    expect(find.text('Copy launcher filenames'), findsOneWidget);
    expect(find.text('Copy all setup info'), findsOneWidget);
    expect(find.text('Open launcher folder'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Launch helper'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Launch helper'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('dashboard.summary.today'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('dashboard.summary.today'), findsOneWidget);
    expect(find.text('dashboard.project.status.read'), findsOneWidget);
    expect(find.text('system.shell.exec'), findsOneWidget);
  });
}
