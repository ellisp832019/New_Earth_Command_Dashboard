import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _cards = [
    ('Today\'s Focus', 'Set one main focus for the day.', Icons.flag_outlined),
    (
      'Top 3 Tasks',
      'Choose three useful actions, not a huge list.',
      Icons.filter_3_outlined,
    ),
    (
      'Active Projects',
      'See the New Earth projects currently moving.',
      Icons.folder_copy_outlined,
    ),
    (
      'Learning Focus',
      'Track the skill that supports today\'s build.',
      Icons.school_outlined,
    ),
    (
      'Content Focus',
      'Turn progress into public awareness.',
      Icons.campaign_outlined,
    ),
    (
      'Business Reminder',
      'Keep funding and opportunity actions visible.',
      Icons.handshake_outlined,
    ),
    (
      'Wellbeing',
      'Build New Earth without burning out.',
      Icons.self_improvement_outlined,
    ),
    (
      'Quick Capture',
      'Capture a task, idea, note, or content seed.',
      Icons.add_circle_outline,
    ),
    (
      'Evening Review',
      'Record what moved forward before the day ends.',
      Icons.nightlight_round,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('EEEE d MMMM y').format(DateTime.now());

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
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList.separated(
            itemCount: _cards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final card = _cards[index];
              return _DashboardCard(
                title: card.$1,
                description: card.$2,
                icon: card.$3,
              );
            },
          ),
        ),
      ],
    );
  }
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
