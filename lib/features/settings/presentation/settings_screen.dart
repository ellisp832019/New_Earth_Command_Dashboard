import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _themeOptions = ['Light', 'Dark', 'System'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsSnapshotProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        data: (snapshot) {
          final appSettings = snapshot.settings;

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
                        'Dashboard Preferences',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Adjust a few calm defaults without widening the system too early.',
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
                        'Switch between a calm light workspace and a darker branded command view.',
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
                        'This stays fixed for the current MVP so the daily rule remains stable.',
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
                      Text(
                        'Dashboard Cards',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose which supporting cards stay visible on the Dashboard.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        key: const Key('settingsShowWellbeingCardToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Wellbeing Card'),
                        subtitle: const Text(
                          'Keep energy and sustainability visible on the Dashboard.',
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
                          'Keep funding and opportunity reminders in view.',
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
                          'Keep current learning effort visible on the Dashboard.',
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
                          'Keep public-awareness and publishing work visible.',
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
