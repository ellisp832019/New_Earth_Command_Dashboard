import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_session_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/widgets/voice_presence_chip.dart';

void main() {
  testWidgets('voice presence chip reflects the shared voice session', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: VoicePresenceChip())),
      ),
    );

    final session = container.read(voiceSessionProvider.notifier);
    session.beginProcessing(
      owner: VoiceSessionOwner.dock,
      label: 'Gaia captured',
      detail: 'Processing the follow-up',
      opacity: 0.72,
    );
    await tester.pump();

    expect(find.text('Gaia captured'), findsOneWidget);
    expect(find.textContaining('Dock · Processing'), findsOneWidget);
    expect(find.textContaining('Processing the follow-up'), findsOneWidget);
  });

  testWidgets('compact voice presence chip shows the active phase', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: VoicePresenceChip(compact: true)),
        ),
      ),
    );

    final session = container.read(voiceSessionProvider.notifier);
    session.beginAwaitingFollowUp(
      owner: VoiceSessionOwner.assistant,
      label: 'Gaia ready',
      detail: 'Waiting for your next command',
      opacity: 0.64,
    );
    await tester.pump();

    expect(find.text('Gaia ready · Awaiting follow-up'), findsOneWidget);
  });
}
