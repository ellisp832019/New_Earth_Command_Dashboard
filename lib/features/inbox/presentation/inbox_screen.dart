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

class _InboxItemCard extends ConsumerStatefulWidget {
  const _InboxItemCard({required this.item});

  final InboxListItem item;

  @override
  ConsumerState<_InboxItemCard> createState() => _InboxItemCardState();
}

class _InboxItemCardState extends ConsumerState<_InboxItemCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;

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
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  key: Key('convertInboxItemButton-${item.item.inboxItemId}'),
                  onPressed: _isProcessing ? null : _showConvertOptions,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_outlined),
                  label: Text(_isProcessing ? 'Processing...' : 'Convert'),
                ),
                OutlinedButton.icon(
                  key: Key('parkInboxItemButton-${item.item.inboxItemId}'),
                  onPressed: _isProcessing ? null : _parkItem,
                  icon: const Icon(Icons.push_pin_outlined),
                  label: const Text('Park'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _parkItem() async {
    await _performAction(
      () => ref
          .read(inboxActionsControllerProvider)
          .parkItem(widget.item.item.inboxItemId),
      'Inbox item parked.',
    );
  }

  Future<void> _showConvertOptions() async {
    final target = await showModalBottomSheet<_InboxConversionTarget>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Convert Inbox Item'),
              subtitle: const Text('Choose where this capture should go.'),
            ),
            const Divider(height: 1),
            _ConversionChoiceTile(
              icon: Icons.task_alt_outlined,
              label: 'Task',
              onTap: () =>
                  Navigator.of(context).pop(_InboxConversionTarget.task),
            ),
            _ConversionChoiceTile(
              icon: Icons.book_outlined,
              label: 'Journal Entry',
              onTap: () =>
                  Navigator.of(context).pop(_InboxConversionTarget.journal),
            ),
            _ConversionChoiceTile(
              icon: Icons.article_outlined,
              label: 'Content Idea',
              onTap: () =>
                  Navigator.of(context).pop(_InboxConversionTarget.content),
            ),
            _ConversionChoiceTile(
              icon: Icons.school_outlined,
              label: 'Learning Item',
              onTap: () =>
                  Navigator.of(context).pop(_InboxConversionTarget.learning),
            ),
            _ConversionChoiceTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Business Opportunity',
              onTap: () =>
                  Navigator.of(context).pop(_InboxConversionTarget.business),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (target == null) {
      return;
    }

    switch (target) {
      case _InboxConversionTarget.task:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToTask(widget.item.item.inboxItemId),
          'Inbox item converted to Task.',
        );
        break;
      case _InboxConversionTarget.journal:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToJournalEntry(widget.item.item.inboxItemId),
          'Inbox item converted to Journal Entry.',
        );
        break;
      case _InboxConversionTarget.content:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToContentItem(widget.item.item.inboxItemId),
          'Inbox item converted to Content Idea.',
        );
        break;
      case _InboxConversionTarget.learning:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToLearningItem(widget.item.item.inboxItemId),
          'Inbox item converted to Learning Item.',
        );
        break;
      case _InboxConversionTarget.business:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToBusinessOpportunity(widget.item.item.inboxItemId),
          'Inbox item converted to Business Opportunity.',
        );
        break;
    }
  }

  Future<void> _performAction(
    Future<void> Function() action,
    String message,
  ) async {
    setState(() => _isProcessing = true);
    try {
      await action();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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

class _ConversionChoiceTile extends StatelessWidget {
  const _ConversionChoiceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}

enum _InboxConversionTarget { task, journal, content, learning, business }
