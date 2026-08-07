import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/project_filters.dart';
import '../application/projects_controller.dart';
import '../data/project_repository.dart';
import 'widgets/project_card.dart';

enum _ProjectSortMode { priority, name, progress, openTasks }

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  _ProjectSortMode _sortMode = _ProjectSortMode.priority;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectItems = ref.watch(projectListItemsProvider);

    return WorkspaceShell(
      title: 'Projects',
      subtitle: 'New Earth Projects',
      onBack: () => context.go(RouteNames.projectsIntelligence),
      trailingActions: [
        TextButton.icon(
          key: const Key('backToProjectHubButton'),
          onPressed: () => context.go(RouteNames.projectsIntelligence),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to hub'),
        ),
        FilledButton.icon(
          key: const Key('addProjectButton'),
          onPressed: () => context.push(RouteNames.newProject),
          icon: const Icon(Icons.add),
          label: const Text('Add Project'),
        ),
      ],
      child: projectItems.when(
        data: (items) {
          final projects = items.map((item) => item.project).toList();
          final filteredProjects = filterProjects(
            projects: projects,
            statusFilter: _statusFilter,
            priorityFilter: _priorityFilter,
            searchQuery: _searchController.text,
          );
          final filteredIds = filteredProjects
              .map((project) => project.projectId)
              .toSet();
          final filteredItems = items.where(
            (item) => filteredIds.contains(item.project.projectId),
          );
          final sortedItems = _sortedItems(filteredItems.toList());
          final statusOptions = _statusOptions(projects);
          final priorityOptions = _priorityOptions(projects);

          return ListView(
            key: const Key('projectsScrollView'),
            padding: const EdgeInsets.all(20),
            children: [
              _pageHeader(theme, projects.length),
              const SizedBox(height: 12),
              _searchAndFilterPanel(
                theme: theme,
                statusOptions: statusOptions,
                priorityOptions: priorityOptions,
              ),
              const SizedBox(height: 12),
              _statusSummaryPanel(theme, items, sortedItems),
              const SizedBox(height: 12),
              if (items.isEmpty)
                _emptyProjectsCard(theme)
              else if (sortedItems.isEmpty)
                _emptyFilteredCard(theme)
              else
                ...sortedItems.map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProjectCard(
                      project: project.project,
                      openTaskCount: project.openTaskCount,
                      onTap: () => context.push(
                        RouteNames.projectDetail(project.project.projectId),
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
                  'There are $totalProjects active project${totalProjects == 1 ? '' : 's'} ready for a calm review.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            ),
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
          const SizedBox(height: 14),
          Text(
            'Sort by',
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
                label: 'Priority',
                selected: _sortMode == _ProjectSortMode.priority,
                onSelected: () =>
                    setState(() => _sortMode = _ProjectSortMode.priority),
              ),
              _selectionChip(
                label: 'Name',
                selected: _sortMode == _ProjectSortMode.name,
                onSelected: () =>
                    setState(() => _sortMode = _ProjectSortMode.name),
              ),
              _selectionChip(
                label: 'Progress',
                selected: _sortMode == _ProjectSortMode.progress,
                onSelected: () =>
                    setState(() => _sortMode = _ProjectSortMode.progress),
              ),
              _selectionChip(
                label: 'Open tasks',
                selected: _sortMode == _ProjectSortMode.openTasks,
                onSelected: () =>
                    setState(() => _sortMode = _ProjectSortMode.openTasks),
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
    List<ProjectListItem> items,
    List<ProjectListItem> filteredItems,
  ) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final statusCounts = _countBy(items, (item) => item.project.status);
    final priorityCounts = _countBy(items, (item) => item.project.priority);
    final openTaskTotal = items.fold<int>(
      0,
      (sum, item) => sum + item.openTaskCount,
    );
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
              _summaryChip('Open tasks', '$openTaskTotal'),
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
    List<ProjectListItem> items,
    String Function(ProjectListItem item) selector,
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

  List<ProjectListItem> _sortedItems(List<ProjectListItem> items) {
    final sorted = [...items];
    sorted.sort((left, right) {
      final priorityCompare = _priorityRank(
        left.project.priority,
      ).compareTo(_priorityRank(right.project.priority));

      if (_sortMode == _ProjectSortMode.priority && priorityCompare != 0) {
        return priorityCompare;
      }

      if (_sortMode == _ProjectSortMode.name) {
        return left.project.name.toLowerCase().compareTo(
          right.project.name.toLowerCase(),
        );
      }

      if (_sortMode == _ProjectSortMode.progress) {
        return right.project.progressPercentage.compareTo(
          left.project.progressPercentage,
        );
      }

      if (_sortMode == _ProjectSortMode.openTasks) {
        final openTaskCompare = right.openTaskCount.compareTo(
          left.openTaskCount,
        );
        if (openTaskCompare != 0) {
          return openTaskCompare;
        }
      }

      if (priorityCompare != 0) {
        return priorityCompare;
      }

      return left.project.name.toLowerCase().compareTo(
        right.project.name.toLowerCase(),
      );
    });

    return sorted;
  }

  int _priorityRank(String priority) => switch (priority) {
    'High' => 0,
    'Medium' => 1,
    'Low' => 2,
    'Someday' => 3,
    _ => 4,
  };
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
