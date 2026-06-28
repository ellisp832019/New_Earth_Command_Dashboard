import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../application/inbox_controller.dart';
import '../data/inbox_repository.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  _InboxStatusFilter _filter = _InboxStatusFilter.all;

  @override
  Widget build(BuildContext context) {
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
          final filteredItems = _applyFilter(inboxItems);

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

          if (filteredItems.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _InboxOverviewCard(
                  itemCount: inboxItems.length,
                  newCount: _countByStatus(inboxItems, 'New'),
                  parkedCount: _countByStatus(inboxItems, 'Parked'),
                  filter: _filter,
                  onFilterChanged: _setFilter,
                ),
                const SizedBox(height: 12),
                _InboxTriageHintCard(filter: _filter),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surface.withValues(alpha: 0.94),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.88,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      _emptyFilterMessage(_filter),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filteredItems.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _InboxOverviewCard(
                  itemCount: inboxItems.length,
                  newCount: _countByStatus(inboxItems, 'New'),
                  parkedCount: _countByStatus(inboxItems, 'Parked'),
                  filter: _filter,
                  onFilterChanged: _setFilter,
                );
              }

              if (index == 1) {
                return _InboxTriageHintCard(filter: _filter);
              }

              return _InboxItemCard(item: filteredItems[index - 2]);
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

  List<InboxListItem> _applyFilter(List<InboxListItem> items) {
    switch (_filter) {
      case _InboxStatusFilter.all:
        return items;
      case _InboxStatusFilter.newOnly:
        return items.where((item) => item.item.status == 'New').toList();
      case _InboxStatusFilter.parkedOnly:
        return items.where((item) => item.item.status == 'Parked').toList();
    }
  }

  int _countByStatus(List<InboxListItem> items, String status) {
    return items.where((item) => item.item.status == status).length;
  }

  void _setFilter(_InboxStatusFilter filter) {
    setState(() => _filter = filter);
  }

  String _emptyFilterMessage(_InboxStatusFilter filter) {
    switch (filter) {
      case _InboxStatusFilter.all:
        return 'Nothing needs triage right now.';
      case _InboxStatusFilter.newOnly:
        return 'No brand-new captures are waiting right now. Parked items are still here when you want them.';
      case _InboxStatusFilter.parkedOnly:
        return 'Nothing is parked right now. If something is not for today, you can park it here for later review.';
    }
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
                  key: Key('reviewInboxItemButton-${item.item.inboxItemId}'),
                  onPressed: _isProcessing ? null : _showReviewSheet,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.visibility_outlined),
                  label: Text(
                    _isProcessing ? 'Processing...' : 'Open Review',
                  ),
                ),
                OutlinedButton.icon(
                  key: Key('parkInboxItemButton-${item.item.inboxItemId}'),
                  onPressed: _isProcessing || item.item.status == 'Parked'
                      ? null
                      : _parkItem,
                  icon: const Icon(Icons.push_pin_outlined),
                  label: Text(
                    item.item.status == 'Parked'
                        ? 'Already Parked'
                        : 'Park for Later',
                  ),
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

  Future<void> _showReviewSheet() async {
    final item = widget.item;
    final action = await showModalBottomSheet<_InboxReviewAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.item.title ?? 'Untitled Capture',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
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
                      const SizedBox(height: 10),
                      Text(
                        item.item.body!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Choose the calmest next home for this capture.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _ConversionChoiceTile(
                icon: Icons.task_alt_outlined,
                label: 'Convert to Task',
                onTap: () =>
                    Navigator.of(context).pop(_InboxReviewAction.task),
              ),
              _ConversionChoiceTile(
                icon: Icons.book_outlined,
                label: 'Convert to Journal Entry',
                onTap: () =>
                    Navigator.of(context).pop(_InboxReviewAction.journal),
              ),
              if (item.item.status != 'Parked')
                _ConversionChoiceTile(
                  icon: Icons.push_pin_outlined,
                  label: 'Park for Later',
                  onTap: () =>
                      Navigator.of(context).pop(_InboxReviewAction.park),
                ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(
                  'Other destinations',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              _ConversionChoiceTile(
                icon: Icons.article_outlined,
                label: 'Convert to Content Idea',
                onTap: () =>
                    Navigator.of(context).pop(_InboxReviewAction.content),
              ),
              _ConversionChoiceTile(
                icon: Icons.school_outlined,
                label: 'Convert to Learning Item',
                onTap: () =>
                    Navigator.of(context).pop(_InboxReviewAction.learning),
              ),
              _ConversionChoiceTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Convert to Business Opportunity',
                onTap: () =>
                    Navigator.of(context).pop(_InboxReviewAction.business),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (action == null) {
      return;
    }

    switch (action) {
      case _InboxReviewAction.task:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToTask(widget.item.item.inboxItemId),
          'Inbox item converted to Task.',
        );
        break;
      case _InboxReviewAction.journal:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToJournalEntry(widget.item.item.inboxItemId),
          'Inbox item converted to Journal Entry.',
        );
        break;
      case _InboxReviewAction.park:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .parkItem(widget.item.item.inboxItemId),
          'Inbox item parked.',
        );
        break;
      case _InboxReviewAction.content:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToContentItem(widget.item.item.inboxItemId),
          'Inbox item converted to Content Idea.',
        );
        break;
      case _InboxReviewAction.learning:
        await _performAction(
          () => ref
              .read(inboxActionsControllerProvider)
              .convertToLearningItem(widget.item.item.inboxItemId),
          'Inbox item converted to Learning Item.',
        );
        break;
      case _InboxReviewAction.business:
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
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inbox item could not be processed. Please try again.'),
        ),
      );
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
  const _InboxOverviewCard({
    required this.itemCount,
    required this.newCount,
    required this.parkedCount,
    required this.filter,
    required this.onFilterChanged,
  });

  final int itemCount;
  final int newCount;
  final int parkedCount;
  final _InboxStatusFilter filter;
  final ValueChanged<_InboxStatusFilter> onFilterChanged;

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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InboxFilterChip(
                  label: 'All $itemCount',
                  selected: filter == _InboxStatusFilter.all,
                  onSelected: () => onFilterChanged(_InboxStatusFilter.all),
                ),
                _InboxFilterChip(
                  label: 'New $newCount',
                  selected: filter == _InboxStatusFilter.newOnly,
                  onSelected: () => onFilterChanged(_InboxStatusFilter.newOnly),
                ),
                _InboxFilterChip(
                  label: 'Parked $parkedCount',
                  selected: filter == _InboxStatusFilter.parkedOnly,
                  onSelected: () =>
                      onFilterChanged(_InboxStatusFilter.parkedOnly),
                ),
              ],
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
  const _InboxTriageHintCard({required this.filter});

  final _InboxStatusFilter filter;

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
              label: filter == _InboxStatusFilter.parkedOnly
                  ? 'Parked items stay here until you move them on'
                  : 'Park to keep for later',
            ),
            _InboxHintChip(
              icon: Icons.visibility_outlined,
              label: 'Open review to choose the next home',
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

class _InboxFilterChip extends StatelessWidget {
  const _InboxFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(),
    );
  }
}

enum _InboxStatusFilter { all, newOnly, parkedOnly }

enum _InboxReviewAction { task, journal, park, content, learning, business }
