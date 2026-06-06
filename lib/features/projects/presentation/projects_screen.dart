import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/projects_controller.dart';
import 'widgets/project_card.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: projects.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No projects yet. Seeded projects will appear here once the dashboard is ready.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            key: const Key('projectsScrollView'),
            padding: const EdgeInsets.all(20),
            itemCount: items.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: const EdgeInsets.all(22),
                  decoration: _pagePanelDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                  '${items.length} projects are available for the current build view.',
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
                    ],
                  ),
                );
              }

              final project = items[index - 1];
              return ProjectCard(
                project: project,
                onTap: () =>
                    context.push(RouteNames.projectDetail(project.projectId)),
              );
            },
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
