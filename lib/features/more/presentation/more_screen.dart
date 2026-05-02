import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _items = [
    _MoreItem(
      title: 'Journal',
      description:
          'Capture build progress, lessons, decisions, and reflections.',
      icon: Icons.edit_note_outlined,
      route: RouteNames.journal,
    ),
    _MoreItem(
      title: 'Learning',
      description: 'Track skills that help build New Earth.',
      icon: Icons.school_outlined,
      route: RouteNames.learning,
    ),
    _MoreItem(
      title: 'Content',
      description:
          'Plan LinkedIn posts, website updates, videos, and book ideas.',
      icon: Icons.campaign_outlined,
      route: RouteNames.content,
    ),
    _MoreItem(
      title: 'Business',
      description:
          'Track funding, job applications, partnerships, and opportunities.',
      icon: Icons.handshake_outlined,
      route: RouteNames.business,
    ),
    _MoreItem(
      title: 'Wellbeing',
      description: 'Check energy, mood, stress, and balance.',
      icon: Icons.self_improvement_outlined,
      route: RouteNames.wellbeing,
    ),
    _MoreItem(
      title: 'Inbox',
      description: 'Process quick captured ideas and notes.',
      icon: Icons.inbox_outlined,
      route: RouteNames.inbox,
    ),
    _MoreItem(
      title: 'Voice Assistant',
      description:
          'Review spoken commands safely before turning them into dashboard actions.',
      icon: Icons.mic_none_rounded,
      route: RouteNames.voiceAssistant,
    ),
    _MoreItem(
      title: 'Settings',
      description: 'Configure the dashboard.',
      icon: Icons.settings_outlined,
      route: RouteNames.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: Icon(item.icon, color: theme.colorScheme.primary),
              title: Text(item.title, style: theme.textTheme.titleMedium),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(item.description),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(item.route),
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
}
