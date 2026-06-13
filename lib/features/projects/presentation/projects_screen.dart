import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/project_filters.dart';
import '../application/projects_controller.dart';
import 'widgets/project_card.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _statusFilter = 'All';
  String _priorityFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: projects.when(
        data: (items) {
          final filteredItems = filterProjects(
            projects: items,
            statusFilter: _statusFilter,
            priorityFilter: _priorityFilter,
            searchQuery: _searchController.text,
          );
          final statusOptions = _statusOptions(items);
          final priorityOptions = _priorityOptions(items);

          return ListView(
            key: const Key('projectsScrollView'),
            padding: const EdgeInsets.all(20),
            children: [
              _pageHeader(theme, items.length),
              const SizedBox(height: 12),
              _searchAndFilterPanel(
                theme: theme,
                statusOptions: statusOptions,
                priorityOptions: priorityOptions,
              ),
              const SizedBox(height: 12),
              _statusSummaryPanel(theme, items, filteredItems),
              const SizedBox(height: 12),
              if (items.isEmpty)
                _emptyProjectsCard(theme)
              else if (filteredItems.isEmpty)
                _emptyFilteredCard(theme)
              else
                ...filteredItems.map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProjectCard(
                      project: project,
                      onTap: () => context.push(
                        RouteNames.projectDetail(project.projectId),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Projects could not be loaded. Try again in a moment.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageHeader(ThemeData theme, int totalProjects) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _pagePanelDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projects',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColours.darkText,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'New Earth Projects',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'There are $totalProjects active project${totalProjects == 1 ? '' : 's'} ready to browse.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            key: const Key('addProjectButton'),
            onPressed: () => context.push(RouteNames.newProject),
            icon: const Icon(Icons.add),
            label: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  Widget _searchAndFilterPanel({
    required ThemeData theme,
    required List<String> statusOptions,
    required List<String> priorityOptions,
  }) {
    final hasFilters =
        _statusFilter != 'All' ||
        _priorityFilter != 'All' ||
        _searchController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _pagePanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search and filter',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
            ),
            decoration: InputDecoration(
              hintText: 'Search by project name, milestone, or next action',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Status',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _selectionChip(
                label: 'All',
                selected: _statusFilter == 'All',
                onSelected: () => setState(() => _statusFilter = 'All'),
              ),
              for (final status in statusOptions)
                _selectionChip(
                  label: status,
                  selected: _statusFilter == status,
                  onSelected: () => setState(() => _statusFilter = status),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Priority',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _selectionChip(
                label: 'All',
                selected: _priorityFilter == 'All',
                onSelected: () => setState(() => _priorityFilter = 'All'),
              ),
              for (final priority in priorityOptions)
                _selectionChip(
                  label: priority,
                  selected: _priorityFilter == priority,
                  onSelected: () => setState(() => _priorityFilter = priority),
                ),
            ],
          ),
          if (hasFilters) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _statusFilter = 'All';
                    _priorityFilter = 'All';
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear filters'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusSummaryPanel(
    ThemeData theme,
    List<Project> items,
    List<Project> filteredItems,
  ) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final statusCounts = _countBy(items, (project) => project.status);
    final priorityCounts = _countBy(items, (project) => project.priority);
    final topStatuses = _topCounts(statusCounts);
    final topPriorities = _topCounts(priorityCounts);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _pagePanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'At a glance',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _summaryChip('Total', '${items.length}'),
              _summaryChip('Showing', '${filteredItems.length}'),
              _summaryChip('High priority', '${priorityCounts['High'] ?? 0}'),
              _summaryChip(
                'Most common',
                topStatuses.isEmpty
                    ? 'n/a'
                    : '${topStatuses.first.key} (${topStatuses.first.value})',
              ),
            ],
          ),
          if (topStatuses.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Status summary',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in topStatuses)
                  _summaryChip(entry.key, '${entry.value}'),
              ],
            ),
          ],
          if (topPriorities.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Priority mix',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in topPriorities)
                  _summaryChip(entry.key, '${entry.value}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyProjectsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _pagePanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No projects yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add the first New Earth project to start the active list.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.push(RouteNames.newProject),
            icon: const Icon(Icons.add),
            label: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  Widget _emptyFilteredCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _pagePanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No projects match this view',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a broader search or clear the status and priority filters.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _statusFilter = 'All';
                _priorityFilter = 'All';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _selectionChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      label: Text(label),
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        color: selected ? AppColours.darkText : AppColours.darkSecondary,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: AppColours.darkPrimary.withValues(alpha: 0.82),
      backgroundColor: AppColours.darkSurfaceRaised.withValues(alpha: 0.94),
      side: BorderSide(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    );
  }

  Widget _summaryChip(String label, String value) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: '$label: '),
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _statusOptions(List<Project> items) {
    final statuses = items.map((project) => project.status).toSet().toList()
      ..sort();
    return statuses;
  }

  List<String> _priorityOptions(List<Project> items) {
    const preferredOrder = ['High', 'Medium', 'Low', 'Someday'];
    final presentPriorities = items.map((project) => project.priority).toSet();
    return preferredOrder.where(presentPriorities.contains).toList();
  }

  Map<String, int> _countBy(
    List<Project> items,
    String Function(Project project) selector,
  ) {
    final counts = <String, int>{};
    for (final item in items) {
      final key = selector(item);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  List<MapEntry<String, int>> _topCounts(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((left, right) {
        final countCompare = right.value.compareTo(left.value);
        if (countCompare != 0) {
          return countCompare;
        }
        return left.key.compareTo(right.key);
      });
    return entries;
  }
}

BoxDecoration _pagePanelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
