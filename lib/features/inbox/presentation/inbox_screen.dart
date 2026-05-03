import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../application/inbox_controller.dart';
import '../data/inbox_repository.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(inboxItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            key: const Key('addInboxItemButton'),
            onPressed: () => context.push(RouteNames.newInbox),
            icon: const Icon(Icons.add),
            tooltip: 'Add Inbox Item',
          ),
        ],
      ),
      body: items.when(
        data: (inboxItems) {
          if (inboxItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No inbox items yet. Capture a thought here so it does not get lost.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: inboxItems.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inbox', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          '${inboxItems.length} captured items are available in the current view.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _InboxItemCard(item: inboxItems[index - 1]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Inbox items could not be loaded. Please try again.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _InboxItemCard extends StatelessWidget {
  const _InboxItemCard({required this.item});

  final InboxListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: Key('inboxItemCard-${item.item.inboxItemId}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.item.title ?? 'Untitled Capture',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.item.type?.isNotEmpty == true)
                  _InboxInfoChip(label: item.item.type!),
                if (item.projectName != null)
                  _InboxInfoChip(label: item.projectName!),
                _InboxInfoChip(label: 'Status: ${item.item.status}'),
              ],
            ),
            if (item.item.body?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(item.item.body!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _InboxInfoChip extends StatelessWidget {
  const _InboxInfoChip({required this.label});

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
