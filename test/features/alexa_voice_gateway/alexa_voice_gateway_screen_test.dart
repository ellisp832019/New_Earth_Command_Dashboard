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

    final alexaVoiceGatewayList = find.byKey(
      const Key('alexaVoiceGatewayList'),
    );

    for (
      var i = 0;
      i < 6 && find.text('Copy Windows start').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(alexaVoiceGatewayList, const Offset(0, -480));
      await tester.pumpAndSettle();
    }

    expect(find.text('Copy Windows start'), findsOneWidget);
    expect(find.text('Copy launcher command'), findsOneWidget);
    expect(find.text('Copy launcher path'), findsOneWidget);
    expect(find.text('Copy module path'), findsOneWidget);
    expect(find.text('Copy launcher filenames'), findsOneWidget);
    expect(find.text('Copy all setup info'), findsOneWidget);
    expect(find.text('Open launcher folder'), findsOneWidget);

    for (
      var i = 0;
      i < 6 && find.text('Launch helper').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(alexaVoiceGatewayList, const Offset(0, -480));
      await tester.pumpAndSettle();
    }

    expect(find.text('Launch helper'), findsOneWidget);

    for (
      var i = 0;
      i < 6 &&
          find
              .byKey(const Key('alexaVoiceGatewaySqliteCommands'))
              .evaluate()
              .isEmpty;
      i++
    ) {
      await tester.drag(alexaVoiceGatewayList, const Offset(0, -480));
      await tester.pumpAndSettle();
    }

    final sqliteCommandBlock = find.byKey(
      const Key('alexaVoiceGatewaySqliteCommands'),
    );

    expect(sqliteCommandBlock, findsOneWidget);
    expect(
      find.descendant(
        of: sqliteCommandBlock,
        matching: find.byType(SelectableText),
      ),
      findsOneWidget,
    );
  });
}
