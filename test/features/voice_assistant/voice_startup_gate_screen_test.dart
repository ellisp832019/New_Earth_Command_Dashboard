import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Continue without Voice'), findsOneWidget);
  });
}
