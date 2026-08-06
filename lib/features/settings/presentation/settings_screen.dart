import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/routing/security_route_policy.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../security/application/security_session_controller.dart';
import '../../security/presentation/security_locked_notice_card.dart';
import '../application/settings_controller.dart';
import '../../voice_assistant/voice_speech_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _themeOptions = ['Light', 'Dark', 'System'];

  bool? _voiceRepliesEnabled;
  bool? _voiceAssistantEnabled;
  bool? _voiceStartupGateEnabled;
  double? _voiceRate;
  double? _voicePitch;
  VoiceTtsVoiceOption? _selectedVoice;
  bool _voiceStateInitialized = false;

  void _syncVoiceState({
    required bool voiceRepliesEnabled,
    required bool voiceAssistantEnabled,
    required bool voiceStartupGateEnabled,
    required double voiceRate,
    required double voicePitch,
    VoiceTtsVoiceOption? selectedVoice,
  }) {
    if (_voiceStateInitialized) {
      return;
    }

    _voiceRepliesEnabled = voiceRepliesEnabled;
    _voiceAssistantEnabled = voiceAssistantEnabled;
    _voiceStartupGateEnabled = voiceStartupGateEnabled;
    _voiceRate = voiceRate;
    _voicePitch = voicePitch;
    _selectedVoice = selectedVoice;
    _voiceStateInitialized = true;
  }

  VoiceTtsVoiceOption? _matchSelectedVoice(
    List<VoiceTtsVoiceOption> voices,
    AppSetting appSettings,
  ) {
    for (final voice in voices) {
      if (voice.name == appSettings.preferredTtsVoiceName &&
          voice.locale == appSettings.preferredTtsVoiceLocale &&
          voice.gender == appSettings.preferredTtsVoiceGender &&
          voice.identifier == appSettings.preferredTtsVoiceIdentifier) {
        return voice;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsSnapshotProvider);
    final voices = ref.watch(voiceAssistantVoicesProvider);
    final securitySession = ref.watch(securitySessionProvider);
    final isSessionLocked =
        !securitySession.isUnlocked || securitySession.isExpired;

    return WorkspaceShell(
      title: 'Settings',
      subtitle: 'Calm, local controls for the dashboard and assistant.',
      onBack: () => context.go(RouteNames.dashboard),
      child: settings.when(
        data: (snapshot) {
          final appSettings = snapshot.settings;
          final selectedVoice = voices.maybeWhen(
            data: (voiceOptions) =>
                _matchSelectedVoice(voiceOptions, appSettings),
            orElse: () => null,
          );
          _syncVoiceState(
            voiceRepliesEnabled: appSettings.voiceRepliesEnabled,
            voiceAssistantEnabled: appSettings.voiceAssistantEnabled,
            voiceStartupGateEnabled: appSettings.voiceStartupGateEnabled,
            voiceRate: appSettings.preferredTtsVoiceRate,
            voicePitch: appSettings.preferredTtsVoicePitch,
            selectedVoice: selectedVoice,
          );
          final voiceRepliesEnabled =
              _voiceRepliesEnabled ?? appSettings.voiceRepliesEnabled;
          final voiceAssistantEnabled =
              _voiceAssistantEnabled ?? appSettings.voiceAssistantEnabled;
          final voiceStartupGateEnabled =
              _voiceStartupGateEnabled ?? appSettings.voiceStartupGateEnabled;
          final voiceRate = _voiceRate ?? appSettings.preferredTtsVoiceRate;
          final voicePitch = _voicePitch ?? appSettings.preferredTtsVoicePitch;
          final selectedVoiceOption = _selectedVoice ?? selectedVoice;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What these settings change',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'These controls stay local to this device and only shape the parts that help the day feel calmer.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      const _SettingsNote(
                        icon: Icons.check_circle_outline,
                        text: 'The Top 3 rule stays fixed at 3 for now.',
                      ),
                      const SizedBox(height: 6),
                      const _SettingsNote(
                        icon: Icons.volume_up_outlined,
                        text:
                            'Voice replies, Voice Assistant, and the optional startup voice gate can be controlled separately.',
                      ),
                      const SizedBox(height: 6),
                      const _SettingsNote(
                        icon: Icons.view_quilt_outlined,
                        text:
                            'Dashboard cards can be hidden if they add noise rather than clarity.',
                      ),
                      const SizedBox(height: 6),
                      const _SettingsNote(
                        icon: Icons.auto_awesome_outlined,
                        text:
                            'Optional AI voice assist stays off unless the OpenAI provider is configured.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security & Access',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This is where local identity, device trust, approvals, and PIN controls should sit.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (isSessionLocked) ...[
                        const SizedBox(height: 12),
                        SecurityLockedNoticeCard(
                          title:
                              'Security controls are waiting on local unlock',
                          message:
                              'Open Security Lock before you manage users, devices, or PINs from Settings.',
                          detail:
                              'The settings screen stays visible, but protected admin actions wait until the same local session is active again.',
                          secondaryActionLabel: 'Open Module Hub',
                          onSecondaryAction: () {
                            context.push(RouteNames.moduleHub);
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () {
                              context.push(
                                SecurityRoutePolicy.securityLockFrom(
                                  GoRouterState.of(context).uri,
                                ),
                              );
                            },
                            icon: const Icon(Icons.lock_outline),
                            label: const Text('Open Security Lock'),
                          ),
                          FilledButton.icon(
                            key: const Key('settingsLockNowButton'),
                            onPressed: () {
                              ref
                                  .read(securitySessionProvider.notifier)
                                  .lockNow();
                              context.go(
                                SecurityRoutePolicy.securityLockFrom(
                                  GoRouterState.of(context).uri,
                                ),
                              );
                            },
                            icon: const Icon(Icons.lock_reset_outlined),
                            label: const Text('Lock now'),
                          ),
                          OutlinedButton.icon(
                            onPressed: isSessionLocked
                                ? null
                                : () {
                                    context.push(RouteNames.usersDevices);
                                  },
                            icon: const Icon(Icons.shield_outlined),
                            label: Text(
                              isSessionLocked
                                  ? 'Unlock to open Users & Devices'
                                  : 'Open Users & Devices',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: isSessionLocked
                                ? null
                                : () {
                                    context.push(RouteNames.usersDevicesUsers);
                                  },
                            icon: const Icon(Icons.people_outline),
                            label: Text(
                              isSessionLocked
                                  ? 'Unlock to manage users'
                                  : 'Manage Users',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: isSessionLocked
                                ? null
                                : () {
                                    context.push(
                                      RouteNames.usersDevicesDevices,
                                    );
                                  },
                            icon: const Icon(Icons.devices_outlined),
                            label: Text(
                              isSessionLocked
                                  ? 'Unlock to manage devices'
                                  : 'Manage Devices',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: isSessionLocked
                                ? null
                                : () {
                                    context.push(RouteNames.usersDevicesPins);
                                  },
                            icon: const Icon(Icons.pin_outlined),
                            label: Text(
                              isSessionLocked ? 'PINs locked' : 'Manage PINs',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              context.push(RouteNames.moduleHub);
                            },
                            icon: const Icon(Icons.extension_outlined),
                            label: const Text('Open Module Hub'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SessionStatusCard(session: securitySession),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repo Research Engine Extensions',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Local AI and RAG stay registry-backed, deterministic by default, and opt-in for future providers.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const _SettingsNote(
                            icon: Icons.auto_awesome_outlined,
                            text:
                                'DeterministicLocal and InMemoryLocal are the current defaults.',
                          ),
                          TextButton.icon(
                            onPressed: () {
                              context.push(
                                RouteNames.repoResearchEngineSettings,
                              );
                            },
                            icon: const Icon(Icons.travel_explore_outlined),
                            label: const Text('Open Repo Research Engine'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard Preferences',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Keep the page focused on the few choices that matter right now.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme Mode', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Pick the look that is easiest to live with each day.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        key: const Key('settingsThemeModeSegmentedButton'),
                        segments: _themeOptions
                            .map(
                              (option) => ButtonSegment<String>(
                                value: option,
                                label: Text(
                                  option,
                                  key: Key('settingsThemeModeOption$option'),
                                ),
                              ),
                            )
                            .toList(),
                        selected: {appSettings.themeMode},
                        onSelectionChanged: (selection) {
                          final value = selection.first;
                          ref
                              .read(settingsControllerProvider)
                              .setThemeMode(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top 3 Task Limit',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${appSettings.dailyTopTaskLimit} priority tasks per day',
                        key: const Key('settingsTopTaskLimitValue'),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This stays fixed at three for the current MVP so the dashboard stays calm.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voice Output', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Use this only if you want Gaia to speak replies and briefings on this device.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Advanced AI voice assist can be enabled separately through the configured provider.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        key: const Key('settingsVoiceAssistantToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable Voice Assistant'),
                        subtitle: const Text(
                          'Keep the assistant available for local headset capture and spoken commands.',
                        ),
                        value: voiceAssistantEnabled,
                        onChanged: (value) {
                          setState(() {
                            _voiceAssistantEnabled = value;
                          });
                          ref
                              .read(settingsControllerProvider)
                              .setVoicePreferences(
                                voiceAssistantEnabled: value,
                              );
                        },
                      ),
                      SwitchListTile(
                        key: const Key('settingsVoiceStartupGateToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Voice Startup Gate'),
                        subtitle: const Text(
                          'Ask for the headset check after the security lock before opening the dashboard.',
                        ),
                        value: voiceStartupGateEnabled,
                        onChanged: (value) {
                          setState(() {
                            _voiceStartupGateEnabled = value;
                          });
                          ref
                              .read(settingsControllerProvider)
                              .setVoicePreferences(
                                voiceStartupGateEnabled: value,
                              );
                        },
                      ),
                      SwitchListTile(
                        key: const Key('settingsVoiceRepliesToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Speak Assistant Replies'),
                        subtitle: const Text(
                          'Read short replies and confirmations aloud when that helps.',
                        ),
                        value: voiceRepliesEnabled,
                        onChanged: (value) {
                          setState(() {
                            _voiceRepliesEnabled = value;
                          });
                          ref
                              .read(settingsControllerProvider)
                              .setVoicePreferences(voiceRepliesEnabled: value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.tonalIcon(
                            key: const Key(
                              'settingsOpenVoiceStartupGateButton',
                            ),
                            onPressed: voiceStartupGateEnabled
                                ? () {
                                    context.push(RouteNames.voiceStartupGate);
                                  }
                                : null,
                            icon: const Icon(Icons.headset_mic_outlined),
                            label: const Text('Open Voice Startup Gate'),
                          ),
                          Text(
                            voiceStartupGateEnabled
                                ? 'The voice gate is available and can run after the security lock.'
                                : 'Turn on the voice startup gate if you want the headset check available at startup.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      voices.when(
                        data: (voiceOptions) {
                          if (voiceOptions.isEmpty) {
                            return Text(
                              'No system voices are available on this device yet.',
                              style: theme.textTheme.bodySmall,
                            );
                          }

                          return DropdownButtonFormField<VoiceTtsVoiceOption>(
                            key: const Key('settingsVoiceDropdown'),
                            initialValue: selectedVoiceOption,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Voice',
                            ),
                            items: voiceOptions
                                .map(
                                  (voice) =>
                                      DropdownMenuItem<VoiceTtsVoiceOption>(
                                        value: voice,
                                        child: Text(voice.label),
                                      ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedVoice = value;
                              });
                              ref
                                  .read(settingsControllerProvider)
                                  .setVoicePreferences(
                                    preferredTtsVoiceName: value?.name,
                                    preferredTtsVoiceLocale: value?.locale,
                                    preferredTtsVoiceGender: value?.gender,
                                    preferredTtsVoiceIdentifier:
                                        value?.identifier,
                                  );
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (error, stackTrace) => Text(
                          'Voice list could not be loaded right now.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Speech Rate', style: theme.textTheme.titleSmall),
                      Slider(
                        key: const Key('settingsVoiceRateSlider'),
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        value: voiceRate.clamp(0.0, 1.0),
                        label: voiceRate.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _voiceRate = value;
                          });
                          ref
                              .read(settingsControllerProvider)
                              .setVoicePreferences(
                                preferredTtsVoiceRate: value,
                              );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text('Pitch', style: theme.textTheme.titleSmall),
                      Slider(
                        key: const Key('settingsVoicePitchSlider'),
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        value: voicePitch.clamp(0.5, 2.0),
                        label: voicePitch.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _voicePitch = value;
                          });
                          ref
                              .read(settingsControllerProvider)
                              .setVoicePreferences(
                                preferredTtsVoicePitch: value,
                              );
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.tonalIcon(
                            key: const Key('settingsPreviewVoiceButton'),
                            onPressed: () async {
                              final previewText =
                                  'This is your chosen voice for New Earth command replies.';
                              await ref
                                  .read(voiceAssistantSpeechServiceProvider)
                                  .speak(
                                    previewText,
                                    enabled: voiceRepliesEnabled,
                                    rate: voiceRate,
                                    pitch: voicePitch,
                                    voice: selectedVoiceOption,
                                  );
                            },
                            icon: const Icon(Icons.volume_up_outlined),
                            label: const Text('Preview Voice'),
                          ),
                          Text(
                            selectedVoiceOption == null
                                ? 'Pick a voice if you want Gaia to speak.'
                                : 'Selected: ${selectedVoiceOption.label}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard Cards',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hide anything that adds noise instead of helping the day.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        key: const Key('settingsShowWellbeingCardToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Wellbeing Card'),
                        subtitle: const Text(
                          'Keep energy and sustainability visible when they are useful.',
                        ),
                        value: appSettings.showWellbeingCard,
                        onChanged: (value) => ref
                            .read(settingsControllerProvider)
                            .setShowWellbeingCard(value),
                      ),
                      SwitchListTile(
                        key: const Key('settingsShowBusinessCardToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Business Card'),
                        subtitle: const Text(
                          'Keep funding and opportunity reminders in view if they matter today.',
                        ),
                        value: appSettings.showBusinessCard,
                        onChanged: (value) => ref
                            .read(settingsControllerProvider)
                            .setShowBusinessCard(value),
                      ),
                      SwitchListTile(
                        key: const Key('settingsShowLearningCardToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Learning Card'),
                        subtitle: const Text(
                          'Keep current learning effort visible when you are actively using it.',
                        ),
                        value: appSettings.showLearningCard,
                        onChanged: (value) => ref
                            .read(settingsControllerProvider)
                            .setShowLearningCard(value),
                      ),
                      SwitchListTile(
                        key: const Key('settingsShowContentCardToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Content Card'),
                        subtitle: const Text(
                          'Keep public-awareness and publishing work visible if it is in play.',
                        ),
                        value: appSettings.showContentCard,
                        onChanged: (value) => ref
                            .read(settingsControllerProvider)
                            .setShowContentCard(value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Docking Windows',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hide the shell docks if they distract from the main dashboard. You can switch the whole group off or control each dock separately.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        key: const Key('settingsShowDockOverlaysToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Docking Windows'),
                        subtitle: const Text(
                          'Master switch for all shell dock overlays.',
                        ),
                        value: appSettings.showDockOverlays,
                        onChanged: (value) => ref
                            .read(settingsControllerProvider)
                            .setShowDockOverlays(value),
                      ),
                      ExpansionTile(
                        key: const Key('settingsDockDetailsExpansionTile'),
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(left: 4, top: 4),
                        title: Text(
                          'Individual dock controls',
                          style: theme.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Hide only the panels you do not want today.',
                          style: theme.textTheme.bodySmall,
                        ),
                        children: [
                          SwitchListTile(
                            key: const Key(
                              'settingsShowBackupGuardianDockToggle',
                            ),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Show Backup Guardian Dock'),
                            subtitle: const Text(
                              'Keep the backup status panel visible on the dashboard.',
                            ),
                            value: appSettings.showBackupGuardianDock,
                            onChanged: (value) => ref
                                .read(settingsControllerProvider)
                                .setShowBackupGuardianDock(value),
                          ),
                          SwitchListTile(
                            key: const Key('settingsShowTreasuryDockToggle'),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Show Treasury Dock'),
                            subtitle: const Text(
                              'Keep the finance and treasury panel visible on the dashboard.',
                            ),
                            value: appSettings.showTreasuryDock,
                            onChanged: (value) => ref
                                .read(settingsControllerProvider)
                                .setShowTreasuryDock(value),
                          ),
                          SwitchListTile(
                            key: const Key(
                              'settingsShowKnowledgeLibraryDockToggle',
                            ),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Show Knowledge Library Dock'),
                            subtitle: const Text(
                              'Keep the local knowledge panel visible on the dashboard.',
                            ),
                            value: appSettings.showKnowledgeLibraryDock,
                            onChanged: (value) => ref
                                .read(settingsControllerProvider)
                                .setShowKnowledgeLibraryDock(value),
                          ),
                          SwitchListTile(
                            key: const Key(
                              'settingsShowVoiceConversationDockToggle',
                            ),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Show Voice Conversation Dock'),
                            subtitle: const Text(
                              'Keep the assistant follow-up dock visible when wake capture lands on the dashboard.',
                            ),
                            value: appSettings.showVoiceConversationDock,
                            onChanged: (value) => ref
                                .read(settingsControllerProvider)
                                .setShowVoiceConversationDock(value),
                          ),
                          SwitchListTile(
                            key: const Key(
                              'settingsShowVoicePresenceChipToggle',
                            ),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Show Assistant Status Chip'),
                            subtitle: const Text(
                              'Keep the small assistant status chip in the top-right corner.',
                            ),
                            value: appSettings.showVoicePresenceChip,
                            onChanged: (value) => ref
                                .read(settingsControllerProvider)
                                .setShowVoicePresenceChip(value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  subtitle: Text(
                    snapshot.appVersion,
                    key: const Key('settingsAppVersionValue'),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Settings could not be loaded right now. Try again in a moment.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsNote extends StatelessWidget {
  const _SettingsNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}

class _SessionStatusCard extends StatelessWidget {
  const _SessionStatusCard({required this.session});

  final SecuritySessionState session;

  String _formatRemaining(Duration? duration) {
    if (duration == null) {
      return 'Locked';
    }

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes <= 0) {
      return '${seconds}s left';
    }

    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s left';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = session.isUnlocked && !session.isExpired;

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security session', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              isUnlocked
                  ? 'Unlocked locally. Idle lock after ${session.timeout.inMinutes} minutes.'
                  : 'Locked. Open Security Lock to start a local session.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(isUnlocked ? 'Active' : 'Locked')),
                Chip(
                  label: Text('Timeout: ${session.timeout.inMinutes} minutes'),
                ),
                Chip(label: Text(_formatRemaining(session.remaining))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
