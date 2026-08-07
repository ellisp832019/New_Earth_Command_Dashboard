import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/journal_controller.dart';
import '../data/journal_repository.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = ref.watch(journalEntriesProvider);

    return WorkspaceShell(
      title: 'Journal',
      subtitle:
          'Capture what moved, what was learned, and what continues next.',
      onBack: () => context.go(RouteNames.dashboard),
      trailingActions: [
        IconButton(
          key: const Key('addJournalEntryButton'),
          onPressed: () => context.push(RouteNames.newJournal),
          icon: const Icon(Icons.add),
          tooltip: 'Add Entry',
        ),
      ],
      child: entries.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No journal entries yet. Capture today\'s progress when you are ready.',
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
                return _JournalOverviewCard(entryCount: items.length);
              }

              if (index == 1) {
                return _JournalHintCard();
              }

              final item = items[index - 2];
              return _JournalEntryCard(
                item: item,
                onTap: () => context.push(
                  RouteNames.editJournal(item.entry.journalEntryId),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Journal entries could not be loaded. Try again in a moment.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalOverviewCard extends StatelessWidget {
  const _JournalOverviewCard({required this.entryCount});

  final int entryCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Journal overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '$entryCount journal entr${entryCount == 1 ? 'y' : 'ies'} are ready to review.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This is the calm record of what moved, what was learned, and what can continue next.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalHintCard extends StatelessWidget {
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
            _JournalHintChip(
              icon: Icons.book_outlined,
              label: 'Capture what moved today',
            ),
            _JournalHintChip(
              icon: Icons.link_outlined,
              label: 'Link to project or task',
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.item, required this.onTap});

  final JournalListEntry item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('d MMM yyyy').format(item.entry.date);

    return Card(
      child: InkWell(
        key: Key('journalEntryCard-${item.entry.journalEntryId}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(item.entry.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.projectName != null)
                    _JournalInfoChip(label: item.projectName!),
                  if (item.entry.category?.isNotEmpty == true)
                    _JournalInfoChip(label: item.entry.category!),
                  if (item.taskTitle != null)
                    _JournalInfoChip(label: item.taskTitle!),
                ],
              ),
              if (item.preview != null) ...[
                const SizedBox(height: 10),
                Text(item.preview!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalInfoChip extends StatelessWidget {
  const _JournalInfoChip({required this.label});

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

class _JournalHintChip extends StatelessWidget {
  const _JournalHintChip({required this.icon, required this.label});

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
