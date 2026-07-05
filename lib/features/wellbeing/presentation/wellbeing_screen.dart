import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/wellbeing_controller.dart';

class WellbeingScreen extends ConsumerWidget {
  const WellbeingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final checkins = ref.watch(wellbeingCheckinsProvider);

    return WorkspaceShell(
      title: 'Wellbeing',
      subtitle: 'Keep a calm read on energy, mood, and pace.',
      onBack: () => context.go(RouteNames.dashboard),
      trailingActions: [
        IconButton(
          key: const Key('addWellbeingCheckinButton'),
          onPressed: () => context.push(RouteNames.newWellbeing),
          icon: const Icon(Icons.add),
          tooltip: 'Add Check-In',
        ),
      ],
      child: checkins.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No wellbeing entries yet. Add a calm check-in when you need one.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _WellbeingOverviewCard(itemCount: items.length);
              }

              if (index == 1) {
                return _WellbeingHintCard();
              }

              return _WellbeingCheckinCard(checkin: items[index - 2]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Wellbeing check-ins could not be loaded. Try again in a moment.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _WellbeingOverviewCard extends StatelessWidget {
  const _WellbeingOverviewCard({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wellbeing overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '$itemCount check-in${itemCount == 1 ? '' : 's'} are ready to review.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Use this page to keep an honest sense of energy, mood, and pace.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WellbeingHintCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _WellbeingHintChip(
              icon: Icons.self_improvement_outlined,
              label: 'Check in honestly',
            ),
            _WellbeingHintChip(
              icon: Icons.nights_stay_outlined,
              label: 'Keep the day sustainable',
            ),
          ],
        ),
      ),
    );
  }
}

class _WellbeingCheckinCard extends StatelessWidget {
  const _WellbeingCheckinCard({required this.checkin});

  final WellbeingCheckin checkin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('d MMM yyyy').format(checkin.date);

    return Card(
      key: Key('wellbeingCheckinCard-${checkin.wellbeingCheckinId}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _WellbeingInfoChip(
                  label: 'Energy: ${checkin.energyLevel ?? 'Not set'}',
                ),
                _WellbeingInfoChip(label: 'Mood: ${checkin.mood ?? 'Not set'}'),
                _WellbeingInfoChip(
                  label: 'Stress: ${checkin.stressLevel ?? 'Not set'}',
                ),
                _WellbeingInfoChip(
                  label:
                      'Workload: ${checkin.suggestedWorkload ?? 'Not suggested'}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Sleep: ${checkin.sleepQuality ?? 'Not set'}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Movement: ${checkin.movementDone ? 'Yes' : 'No'}   Food/Water: ${checkin.foodWaterOk ? 'Yes' : 'No'}   Reflection: ${checkin.meditationReflectionDone ? 'Yes' : 'No'}',
              style: theme.textTheme.bodySmall,
            ),
            if (checkin.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(checkin.notes!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _WellbeingInfoChip extends StatelessWidget {
  const _WellbeingInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: theme.textTheme.bodySmall),
      ),
    );
  }
}

class _WellbeingHintChip extends StatelessWidget {
  const _WellbeingHintChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
