import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
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
  double? _voiceRate;
  double? _voicePitch;
  VoiceTtsVoiceOption? _selectedVoice;
  bool _voiceStateInitialized = false;

  void _syncVoiceState({
    required bool voiceRepliesEnabled,
    required bool voiceAssistantEnabled,
    required double voiceRate,
    required double voicePitch,
    VoiceTtsVoiceOption? selectedVoice,
  }) {
    if (_voiceStateInitialized) {
      return;
    }

    _voiceRepliesEnabled = voiceRepliesEnabled;
    _voiceAssistantEnabled = voiceAssistantEnabled;
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
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
            voiceRate: appSettings.preferredTtsVoiceRate,
            voicePitch: appSettings.preferredTtsVoicePitch,
            selectedVoice: selectedVoice,
          );
          final voiceRepliesEnabled =
              _voiceRepliesEnabled ?? appSettings.voiceRepliesEnabled;
          final voiceAssistantEnabled =
              _voiceAssistantEnabled ?? appSettings.voiceAssistantEnabled;
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
                            'Voice replies and Voice Assistant can be turned on separately.',
                      ),
                      const SizedBox(height: 6),
                      const _SettingsNote(
                        icon: Icons.view_quilt_outlined,
                        text:
                            'Dashboard cards can be hidden if they add noise rather than clarity.',
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
                              .setVoicePreferences(
                                voiceRepliesEnabled: value,
                              );
                        },
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
                                  (voice) => DropdownMenuItem<VoiceTtsVoiceOption>(
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
                                    preferredTtsVoiceIdentifier: value?.identifier,
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
                      Text(
                        'Speech Rate',
                        style: theme.textTheme.titleSmall,
                      ),
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
                      Text(
                        'Pitch',
                        style: theme.textTheme.titleSmall,
                      ),
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
                                  .read(
                                    voiceAssistantSpeechServiceProvider,
                                  )
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
              'Settings could not be loaded right now. Please try again.',
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
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
