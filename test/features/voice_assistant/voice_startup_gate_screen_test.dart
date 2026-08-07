import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_startup_gate_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_startup_gate_screen.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_startup_gate_service.dart';

GoRouter _buildRouter(Widget child) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) => const Scaffold(body: Text('Dashboard')),
      ),
      GoRoute(
        path: RouteNames.voiceAssistant,
        builder: (context, state) =>
            const Scaffold(body: Text('Voice Assistant')),
      ),
    ],
  );
}

void main() {
  testWidgets('startup gate screen explains the no-device state', (
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

    expect(find.text('No microphone or headset found'), findsOneWidget);
    expect(
      find.textContaining('No audio input is showing up yet'),
      findsOneWidget,
    );
    expect(find.text('What the assistant sees'), findsOneWidget);
    expect(find.text('Capture path'), findsOneWidget);
    expect(
      find.textContaining('falls back to the local microphone recognizer'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Skip Voice'), findsOneWidget);
    expect(find.text('Sleep quietly'), findsOneWidget);
    expect(find.text('Exit completely'), findsOneWidget);
    expect(find.text('Continue with Voice'), findsOneWidget);
  });

  testWidgets('startup gate can request voice assistant from the screen', (
    tester,
  ) async {
    addTearDown(() => voiceStartupGateLandingRoute.value = null);

    const result = VoiceStartupGateResult(
      isReady: false,
      message: 'Checking for a connected headset...',
      devices: <VoiceInputDevice>[
        VoiceInputDevice(name: 'USB Audio Device', identifier: 'USB\\ROOT'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: _buildRouter(VoiceStartupGateScreen(result: result)),
        ),
      ),
    );

    expect(voiceStartupGateLandingRoute.value, isNull);
    final continueButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Continue with Voice'),
        matching: find.byType(FilledButton),
      ),
    );
    continueButton.onPressed?.call();
    await tester.pumpAndSettle();
    expect(voiceStartupGateLandingRoute.value, RouteNames.voiceAssistant);
    expect(find.text('Voice Assistant'), findsOneWidget);
  });

  testWidgets('no voice requests the dashboard landing', (tester) async {
    addTearDown(() => voiceStartupGateLandingRoute.value = null);

    const result = VoiceStartupGateResult(
      isReady: false,
      message: 'Checking for a connected headset...',
      devices: <VoiceInputDevice>[],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: _buildRouter(VoiceStartupGateScreen(result: result)),
        ),
      ),
    );

    expect(voiceStartupGateLandingRoute.value, isNull);
    final skipButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Skip Voice'),
        matching: find.byType(OutlinedButton),
      ),
    );
    skipButton.onPressed?.call();
    await tester.pumpAndSettle();
    expect(voiceStartupGateLandingRoute.value, RouteNames.dashboard);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
