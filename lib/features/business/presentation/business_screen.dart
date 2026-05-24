import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../application/business_controller.dart';
import '../data/business_repository.dart';

class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(businessItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.dashboard),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            key: const Key('addBusinessItemButton'),
            onPressed: () => context.push(RouteNames.newBusiness),
            icon: const Icon(Icons.add),
            tooltip: 'Add Opportunity',
          ),
        ],
      ),
      body: items.when(
        data: (businessItems) {
          if (businessItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No business items yet. Capture a lead when it feels useful.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: businessItems.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _BusinessOverviewCard(itemCount: businessItems.length);
              }

              if (index == 1) {
                return _BusinessHintCard();
              }

              return _BusinessItemCard(item: businessItems[index - 2]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Business opportunities could not be loaded. Try again in a moment.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _BusinessOverviewCard extends StatelessWidget {
  const _BusinessOverviewCard({required this.itemCount});

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
            Text('Business overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              itemCount == 1
                  ? '1 opportunity is ready to review.'
                  : '$itemCount opportunities are ready to review.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Keep the next move small, practical, and easy to follow up on.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessHintCard extends StatelessWidget {
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
            _BusinessHintChip(
              icon: Icons.work_outline,
              label: 'Capture one lead',
            ),
            _BusinessHintChip(
              icon: Icons.follow_the_signs_outlined,
              label: 'Keep the next action visible',
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessItemCard extends StatelessWidget {
  const _BusinessItemCard({required this.item});

  final BusinessListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = item.item.name;
    final deadline = item.item.deadline == null
        ? 'Not set'
        : DateFormat('d MMM yyyy').format(item.item.deadline!);
    final followUpDate = item.item.followUpDate == null
        ? 'Not set'
        : DateFormat('d MMM yyyy').format(item.item.followUpDate!);
    final statusLabel = 'Status: ${item.item.status}';
    final typeLabel = item.item.type;
    final projectLabel = item.projectName;

    return Card(
      key: Key('businessItemCard-${item.item.businessOpportunityId}'),
      child: InkWell(
        onTap: () =>
            GoRouter.of(context).push(RouteNames.editBusiness(item.item.businessOpportunityId)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (typeLabel != null && typeLabel.isNotEmpty)
                    _BusinessInfoChip(label: typeLabel),
                  if (projectLabel != null) _BusinessInfoChip(label: projectLabel),
                  _BusinessInfoChip(label: statusLabel),
                ],
              ),
              const SizedBox(height: 10),
              Text('Deadline: $deadline', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                "Next Step: ${item.item.nextAction ?? 'Choose the next practical move.'}",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text('Follow-Up: $followUpDate', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessInfoChip extends StatelessWidget {
  const _BusinessInfoChip({required this.label});

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

class _BusinessHintChip extends StatelessWidget {
  const _BusinessHintChip({required this.icon, required this.label});

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
