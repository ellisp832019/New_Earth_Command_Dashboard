import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../application/content_controller.dart';
import '../data/content_repository.dart';

class ContentScreen extends ConsumerWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(contentItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content'),
        actions: [
          IconButton(
            key: const Key('addContentItemButton'),
            onPressed: () => context.push(RouteNames.newContent),
            icon: const Icon(Icons.add),
            tooltip: 'Add Content Idea',
          ),
        ],
      ),
      body: items.when(
        data: (contentItems) {
          if (contentItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No content ideas yet. Turn a build update into your first post idea.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: contentItems.length + 1,
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
                          'Content Planner',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${contentItems.length} content ideas are available in the current view.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _ContentItemCard(item: contentItems[index - 1]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Content ideas could not be loaded. Please try again.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentItemCard extends StatelessWidget {
  const _ContentItemCard({required this.item});

  final ContentListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final publishDate = item.item.publishDate == null
        ? 'Not scheduled yet'
        : DateFormat('d MMM yyyy').format(item.item.publishDate!);
    final imageNeededLabel = item.item.imageNeeded ? 'Yes' : 'No';

    return Card(
      child: InkWell(
        key: Key('contentItemCard-${item.item.contentItemId}'),
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push(RouteNames.editContent(item.item.contentItemId)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.item.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.item.platform?.isNotEmpty == true)
                    _ContentInfoChip(label: item.item.platform!),
                  if (item.projectName != null)
                    _ContentInfoChip(label: item.projectName!),
                  if (item.item.contentType?.isNotEmpty == true)
                    _ContentInfoChip(label: item.item.contentType!),
                  _ContentInfoChip(label: 'Status: ${item.item.status}'),
                  _ContentInfoChip(label: 'Image Needed: $imageNeededLabel'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Publish Date: $publishDate',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentInfoChip extends StatelessWidget {
  const _ContentInfoChip({required this.label});

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
