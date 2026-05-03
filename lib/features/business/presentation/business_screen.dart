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
                  'No business opportunities yet. Add a job, funding idea, grant, contact, or partnership lead.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: businessItems.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Hub',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${businessItems.length} opportunities are available in the current view.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _BusinessItemCard(item: businessItems[index - 1]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Business opportunities could not be loaded. Please try again.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
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
    final deadline = item.item.deadline == null
        ? 'Not set'
        : DateFormat('d MMM yyyy').format(item.item.deadline!);
    final followUpDate = item.item.followUpDate == null
        ? 'Not set'
        : DateFormat('d MMM yyyy').format(item.item.followUpDate!);

    return Card(
      key: Key('businessItemCard-${item.item.businessOpportunityId}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.item.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.item.type?.isNotEmpty == true)
                  _BusinessInfoChip(label: item.item.type!),
                if (item.projectName != null)
                  _BusinessInfoChip(label: item.projectName!),
                _BusinessInfoChip(label: 'Status: ${item.item.status}'),
              ],
            ),
            const SizedBox(height: 10),
            Text('Deadline: $deadline', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Next Step: ${item.item.nextAction ?? 'Choose the next practical move.'}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text('Follow-Up: $followUpDate', style: theme.textTheme.bodySmall),
          ],
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
