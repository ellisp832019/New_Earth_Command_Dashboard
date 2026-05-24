import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../application/learning_controller.dart';
import '../data/learning_repository.dart';

class LearningScreen extends ConsumerWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(learningItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning'),
        actions: [
          IconButton(
            key: const Key('addLearningItemButton'),
            onPressed: () => context.push(RouteNames.newLearning),
            icon: const Icon(Icons.add),
            tooltip: 'Add Learning Topic',
          ),
        ],
      ),
      body: items.when(
        data: (learningItems) {
          if (learningItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nothing is in Learning yet. Add a skill when it feels useful.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: learningItems.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _LearningOverviewCard(itemCount: learningItems.length);
              }

              if (index == 1) {
                return _LearningHintCard();
              }

              return _LearningItemCard(item: learningItems[index - 2]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Learning topics could not be loaded. Please try again.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningOverviewCard extends StatelessWidget {
  const _LearningOverviewCard({required this.itemCount});

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
            Text('Learning overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '$itemCount learning topic${itemCount == 1 ? '' : 's'} are ready to review.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This is the quiet shelf for skills, references, and the next practical step.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningHintCard extends StatelessWidget {
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
            _LearningHintChip(
              icon: Icons.school_outlined,
              label: 'Track one useful skill',
            ),
            _LearningHintChip(
              icon: Icons.arrow_forward_outlined,
              label: 'Keep the next step small',
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningItemCard extends StatelessWidget {
  const _LearningItemCard({required this.item});

  final LearningListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        key: Key('learningItemCard-${item.item.learningItemId}'),
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push(RouteNames.editLearning(item.item.learningItemId)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.item.topic, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.projectName != null)
                    _LearningInfoChip(label: item.projectName!),
                  _LearningInfoChip(label: 'Status: ${item.item.status}'),
                  _LearningInfoChip(
                    label:
                        'Confidence: ${item.item.skillConfidence ?? 'Not set yet'}',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Next Step: ${item.item.nextStep ?? 'Choose the next learning action.'}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningInfoChip extends StatelessWidget {
  const _LearningInfoChip({required this.label});

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

class _LearningHintChip extends StatelessWidget {
  const _LearningHintChip({required this.icon, required this.label});

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
