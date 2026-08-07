import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/settings/application/settings_controller.dart';
import 'package:new_earth_command_dashboard/features/settings/data/settings_repository.dart';
import 'package:new_earth_command_dashboard/features/voice_intelligence/application/voice_startup_coordinator.dart';

import '../../support/voice_startup_test_support.dart';

Future<SettingsSnapshot> _buildSettingsSnapshot({
  required bool voiceAssistantEnabled,
  required bool voiceStartupGateEnabled,
}) async {
  final database = AppDatabase(NativeDatabase.memory());
  final snapshot = await SettingsRepository(database).getSettings();
  await database.close();

  return SettingsSnapshot(
    settings: snapshot.settings.copyWith(
      voiceAssistantEnabled: voiceAssistantEnabled,
      voiceStartupGateEnabled: voiceStartupGateEnabled,
      showDockOverlays: false,
      showBackupGuardianDock: false,
      showTreasuryDock: false,
      showKnowledgeLibraryDock: false,
      showVoiceConversationDock: false,
      showVoicePresenceChip: false,
    ),
    appVersion: snapshot.appVersion,
  );
}

ProviderContainer _buildContainer({
  required TestVoiceStartupProbe probe,
  required bool voiceAssistantEnabled,
  required bool voiceStartupGateEnabled,
}) {
  final snapshotFuture = _buildSettingsSnapshot(
    voiceAssistantEnabled: voiceAssistantEnabled,
    voiceStartupGateEnabled: voiceStartupGateEnabled,
  );

  return ProviderContainer(
    overrides: [
      settingsSnapshotProvider.overrideWith((ref) => snapshotFuture),
      voiceStartupProbeProvider.overrideWithValue(probe),
    ],
  );
}

void main() {
  test('initial state is disabled when voice is off', () async {
    final probe = TestVoiceStartupProbe();
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    final state = container.read(voiceStartupCoordinatorProvider);

    expect(state.status, VoiceStartupStatus.disabled);
    expect(state.message, contains('disabled'));
    expect(probe.callCount, 0);
  });

  test('disabled state does not initialize', () async {
    final probe = TestVoiceStartupProbe();
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    await container
        .read(voiceStartupCoordinatorProvider.notifier)
        .start(voiceEnabled: false, voiceFirstMode: false);

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.disabled,
    );
    expect(probe.callCount, 0);
  });

  test('enabled state initializes asynchronously', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.ready(),
      delay: const Duration(milliseconds: 25),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    final future = container
        .read(voiceStartupCoordinatorProvider.notifier)
        .start(voiceEnabled: true, voiceFirstMode: false);

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.initializing,
    );

    await future;

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.ready,
    );
    expect(probe.callCount, 1);
  });

  test('successful initialization reaches ready', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.ready(message: 'Voice is ready.'),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    await container
        .read(voiceStartupCoordinatorProvider.notifier)
        .start(voiceEnabled: true, voiceFirstMode: false);

    final state = container.read(voiceStartupCoordinatorProvider);
    expect(state.status, VoiceStartupStatus.ready);
    expect(state.message, contains('ready'));
  });

  test('missing plugin reaches pluginUnavailable', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.pluginUnavailable(
        message: 'The voice plugin is unavailable right now.',
      ),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    await container
        .read(voiceStartupCoordinatorProvider.notifier)
        .start(voiceEnabled: true, voiceFirstMode: false);

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.pluginUnavailable,
    );
  });

  test('permission denial reaches permissionDenied', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.permissionDenied(
        message: 'Microphone permission is not granted.',
      ),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    await container
        .read(voiceStartupCoordinatorProvider.notifier)
        .start(voiceEnabled: true, voiceFirstMode: false);

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.permissionDenied,
    );
  });

  test('hardware missing reaches hardwareMissing', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.hardwareMissing(
        message: 'No microphone or headset was detected.',
      ),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    await container
        .read(voiceStartupCoordinatorProvider.notifier)
        .start(voiceEnabled: true, voiceFirstMode: false);

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.hardwareMissing,
    );
  });

  test('timeout reaches failed', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.ready(),
      delay: const Duration(milliseconds: 200),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    await container
        .read(voiceStartupCoordinatorProvider.notifier)
        .start(
          voiceEnabled: true,
          voiceFirstMode: false,
          timeout: const Duration(milliseconds: 10),
        );

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.failed,
    );
  });

  test('retry succeeds after an initial failure', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.failed(
        message: 'Voice startup failed.',
      ),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    await container
        .read(voiceStartupCoordinatorProvider.notifier)
        .start(voiceEnabled: true, voiceFirstMode: false);

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.failed,
    );

    probe.enabledState = const VoiceStartupState.ready();
    await container.read(voiceStartupCoordinatorProvider.notifier).retry();

    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.ready,
    );
  });

  test('concurrent retry is prevented', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.ready(),
      delay: const Duration(milliseconds: 25),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );
    addTearDown(container.dispose);

    await container.read(settingsSnapshotProvider.future);
    final coordinator = container.read(
      voiceStartupCoordinatorProvider.notifier,
    );
    final startFuture = coordinator.start(
      voiceEnabled: true,
      voiceFirstMode: false,
      timeout: const Duration(milliseconds: 200),
    );

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await coordinator.retry();

    expect(probe.callCount, 1);
    await startFuture;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(probe.callCount, 2);
    expect(
      container.read(voiceStartupCoordinatorProvider).status,
      VoiceStartupStatus.ready,
    );
  });

  test('disposal does not leave delayed work affecting state', () async {
    final probe = TestVoiceStartupProbe(
      enabledState: const VoiceStartupState.ready(),
      delay: const Duration(milliseconds: 50),
    );
    final container = _buildContainer(
      probe: probe,
      voiceAssistantEnabled: false,
      voiceStartupGateEnabled: false,
    );

    await container.read(settingsSnapshotProvider.future);
    final coordinator = container.read(
      voiceStartupCoordinatorProvider.notifier,
    );
    unawaited(coordinator.start(voiceEnabled: true, voiceFirstMode: false));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(probe.callCount, 1);
  });
}
