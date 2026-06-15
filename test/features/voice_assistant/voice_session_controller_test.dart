import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_presence_controller.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/application/voice_session_controller.dart';

void main() {
  test('voice session controller claims and releases a single owner', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(voiceSessionProvider.notifier);

    expect(
      session.beginListening(
        owner: VoiceSessionOwner.handsfree,
        label: 'Assistant listening',
        detail: 'Arming voice input',
      ),
      isTrue,
    );

    expect(
      container.read(voiceSessionProvider).owner,
      VoiceSessionOwner.handsfree,
    );
    expect(container.read(voicePresenceProvider).label, 'Assistant listening');

    expect(
      session.beginListening(
        owner: VoiceSessionOwner.dock,
        label: 'Assistant listening',
        detail: 'Listening for a follow-up',
      ),
      isFalse,
    );

    session.release(
      owner: VoiceSessionOwner.handsfree,
      label: 'Assistant idle',
      detail: 'Ready when you are',
    );

    expect(container.read(voiceSessionProvider).owner, VoiceSessionOwner.none);
    expect(container.read(voicePresenceProvider).label, 'Assistant idle');

    session.beginAwaitingFollowUp(
      owner: VoiceSessionOwner.assistant,
      label: 'Assistant ready',
      detail: 'Ask another follow-up',
    );
    expect(
      container.read(voiceSessionProvider).owner,
      VoiceSessionOwner.assistant,
    );
    expect(
      container.read(voiceSessionProvider).phase,
      VoiceSessionPhase.awaitingFollowUp,
    );
  });

  test('voice session controller allows a handoff after release', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(voiceSessionProvider.notifier);

    session.beginProcessing(
      owner: VoiceSessionOwner.dock,
      label: 'Assistant captured',
      detail: 'Processing the follow-up',
    );

    session.release(
      owner: VoiceSessionOwner.dock,
      label: 'Assistant idle',
      detail: 'Ready when you are',
    );

    session.beginAwaitingFollowUp(
      owner: VoiceSessionOwner.assistant,
      label: 'Assistant ready',
      detail: 'Ask another follow-up',
    );
    expect(
      container.read(voiceSessionProvider).owner,
      VoiceSessionOwner.assistant,
    );
    expect(
      container.read(voiceSessionProvider).phase,
      VoiceSessionPhase.awaitingFollowUp,
    );
  });

  test('voice session controller hands off ownership without going idle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(voiceSessionProvider.notifier);

    session.beginSpeaking(
      owner: VoiceSessionOwner.handsfree,
      label: 'Assistant speaking',
      detail: 'Reading back the response',
    );

    final handoff = session.handoff(
      from: VoiceSessionOwner.handsfree,
      to: VoiceSessionOwner.assistant,
      phase: VoiceSessionPhase.awaitingFollowUp,
      label: 'Assistant ready',
      detail: 'Review before saving',
    );

    expect(handoff, isTrue);
    expect(
      container.read(voiceSessionProvider).owner,
      VoiceSessionOwner.assistant,
    );
    expect(
      container.read(voiceSessionProvider).phase,
      VoiceSessionPhase.awaitingFollowUp,
    );
    expect(container.read(voicePresenceProvider).label, 'Assistant ready');
  });
}
