import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_startup_gate_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_startup_gate_screen.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_startup_gate_service.dart';

void main() {
  testWidgets('startup gate screen explains automatic rechecking', (
    tester,
  ) async {
    const result = VoiceStartupGateResult(
      isReady: false,
      message: 'Checking for a connected headset...',
      devices: <VoiceInputDevice>[],
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: VoiceStartupGateScreen(result: result)),
      ),
    );

    expect(find.text('Gaia is waiting for your headset'), findsOneWidget);
    expect(find.textContaining('connect the headset'), findsOneWidget);
    expect(find.text('Capture path'), findsOneWidget);
    expect(
      find.textContaining('falls back to the local microphone recognizer'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Continue without Voice'), findsOneWidget);
    expect(find.text('Use headset anyway'), findsOneWidget);
  });

  testWidgets('startup gate bypass can be accepted from the screen', (
    tester,
  ) async {
    const result = VoiceStartupGateResult(
      isReady: false,
      message: 'Checking for a connected headset...',
      devices: <VoiceInputDevice>[
        VoiceInputDevice(
          name: 'USB Audio Device',
          identifier: 'USB\\ROOT',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Consumer(
                builder: (context, ref, _) {
                  final bypass = ref.watch(voiceStartupGateBypassProvider);
                  return Column(
                    children: [
                      Expanded(
                        child: VoiceStartupGateScreen(result: result),
                      ),
                      Text('Bypass: $bypass'),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Bypass: false'), findsOneWidget);
    await tester.tap(find.text('Use headset anyway'));
    await tester.pumpAndSettle();
    expect(find.text('Bypass: true'), findsOneWidget);
  });
}
