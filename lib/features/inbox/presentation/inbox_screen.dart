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
                  'Nothing needs triage yet. Capture a thought here, then review it when you are ready.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: inboxItems.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _InboxOverviewCard(itemCount: inboxItems.length);
              }

              if (index == 1) {
                return _InboxTriageHintCard();
              }

              return _InboxItemCard(item: inboxItems[index - 2]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Inbox items could not be loaded. Try again in a moment.',
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
      elevation: 0,
      color: theme.colorScheme.surface.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.88),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.item.title ?? 'Untitled Capture',
              style: theme.textTheme.titleMedium?.copyWith(height: 1.15),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (item.item.type?.isNotEmpty == true)
                  _InboxInfoChip(label: item.item.type!),
                if (item.projectName != null)
                  _InboxInfoChip(label: item.projectName!),
                _InboxInfoChip(label: 'Status: ${item.item.status}'),
              ],
            ),
            if (item.item.body?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                item.item.body!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Park it for later, or convert it into the next right place.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                  label: Text(_isProcessing ? 'Processing...' : 'Review & Convert'),
                ),
                OutlinedButton.icon(
                  key: Key('parkInboxItemButton-${item.item.inboxItemId}'),
                  onPressed: _isProcessing ? null : _parkItem,
                  icon: const Icon(Icons.push_pin_outlined),
                  label: const Text('Park for Later'),
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
              title: const Text('Review and Move'),
              subtitle: const Text('Choose the calmest next home for this capture.'),
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
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(height: 1.1),
        ),
      ),
    );
  }
}

class _InboxOverviewCard extends StatelessWidget {
  const _InboxOverviewCard({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.88),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inbox triage', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '$itemCount unprocessed item${itemCount == 1 ? '' : 's'} are ready for review.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'New and parked items stay here. Processed items leave the list when they have been moved on.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxTriageHintCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InboxHintChip(
              icon: Icons.push_pin_outlined,
              label: 'Park to keep for later',
            ),
            _InboxHintChip(
              icon: Icons.play_arrow_outlined,
              label: 'Convert to move it on',
            ),
          ],
        ),
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

class _InboxHintChip extends StatelessWidget {
  const _InboxHintChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
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

enum _InboxConversionTarget { task, journal, content, learning, business }
