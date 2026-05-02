import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/dashboard_controller.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = DateFormat('EEEE d MMMM y').format(DateTime.now());
    final snapshot = ref.watch(dashboardSnapshotProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('New Earth Command Dashboard'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(74),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      'What moves the mission forward today?',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        snapshot.when(
          data: (data) => _DashboardCardList(snapshot: data),
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => SliverFillRemaining(
            hasScrollBody: false,
            child: _DashboardError(error: error),
          ),
        ),
      ],
    );
  }
}

class _DashboardCardList extends StatelessWidget {
  const _DashboardCardList({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DashboardCardData(
        title: 'Today\'s Focus',
        description: snapshot.mainFocus?.isNotEmpty == true
            ? snapshot.mainFocus!
            : 'A blank daily plan is ready for today.',
        icon: Icons.flag_outlined,
      ),
      _DashboardCardData(
        title: 'Top 3 Tasks',
        description: snapshot.topTaskTitles.isEmpty
            ? 'No Top 3 tasks selected yet.'
            : snapshot.topTaskTitles.join('\n'),
        icon: Icons.filter_3_outlined,
      ),
      _DashboardCardData(
        title: 'Active Projects',
        description: '${snapshot.activeProjectCount} projects are available.',
        icon: Icons.folder_copy_outlined,
      ),
      const _DashboardCardData(
        title: 'Learning Focus',
        description: 'Track the skill that supports today\'s build.',
        icon: Icons.school_outlined,
      ),
      const _DashboardCardData(
        title: 'Content Focus',
        description: 'Turn progress into public awareness.',
        icon: Icons.campaign_outlined,
      ),
      const _DashboardCardData(
        title: 'Business Reminder',
        description: 'Keep funding and opportunity actions visible.',
        icon: Icons.handshake_outlined,
      ),
      const _DashboardCardData(
        title: 'Wellbeing',
        description: 'Build New Earth without burning out.',
        icon: Icons.self_improvement_outlined,
      ),
      const _DashboardCardData(
        title: 'Quick Capture',
        description: 'Capture a task, idea, note, or content seed.',
        icon: Icons.add_circle_outline,
      ),
      const _DashboardCardData(
        title: 'Evening Review',
        description: 'Record what moved forward before the day ends.',
        icon: Icons.nightlight_round,
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList.separated(
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          return _DashboardCard(
            title: card.title,
            description: card.description,
            icon: card.icon,
          );
        },
      ),
    );
  }
}

class _DashboardCardData {
  const _DashboardCardData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Dashboard could not be loaded. Please try again.',
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
