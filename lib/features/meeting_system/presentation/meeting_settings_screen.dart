import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colours.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class MeetingSettingsScreen extends ConsumerStatefulWidget {
  const MeetingSettingsScreen({super.key});

  @override
  ConsumerState<MeetingSettingsScreen> createState() =>
      _MeetingSettingsScreenState();
}

class _MeetingSettingsScreenState extends ConsumerState<MeetingSettingsScreen> {
  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(meetingWorkspaceProvider);
    final hubSnapshot = ref.watch(meetingOmegaHubProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Meeting Settings'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(meetingWorkspaceProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MeetingSettingsError(
          error: error,
          onRetry: () => ref.invalidate(meetingWorkspaceProvider),
        ),
        data: (workspace) {
          return hubSnapshot.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _MeetingSettingsError(
              error: error,
              onRetry: () => ref.invalidate(meetingOmegaHubProvider),
            ),
            data: (hub) {
              final service = ref.read(meetingFolderServiceProvider);
              final omegaRootPath = workspace.omegaRootPath;
              final meetingsRootPath = workspace.meetingsRootPath;
              final templatePath = omegaRootPath == null
                  ? null
                  : '$omegaRootPath/21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder';

              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: meetingPanelDecoration(highlighted: true),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 980;
                          final chips = Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              MeetingStatChip(
                                label: 'Ready',
                                value: workspace.isReady ? 'Yes' : 'No',
                                accentColor: workspace.isReady
                                    ? AppColours.darkSuccess
                                    : AppColours.darkAmber,
                              ),
                              MeetingStatChip(
                                label: 'Missing folders',
                                value: '${workspace.missingFolders.length}',
                                accentColor: AppColours.darkAmber,
                              ),
                              MeetingStatChip(
                                label: 'Missing files',
                                value: '${workspace.missingFiles.length}',
                                accentColor: AppColours.darkPurple,
                              ),
                            ],
                          );

                          final actions = Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: wide
                                ? WrapAlignment.end
                                : WrapAlignment.start,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: _refreshing
                                    ? null
                                    : () => _createStructure(service),
                                icon: _refreshing
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.build_outlined),
                                label: Text(
                                  workspace.isReady
                                      ? 'Refresh structure'
                                      : 'Create starter files',
                                ),
                              ),
                              TextButton.icon(
                                onPressed: omegaRootPath == null
                                    ? null
                                    : () => service.openFolder(omegaRootPath),
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Open Omega OS'),
                              ),
                              TextButton.icon(
                                onPressed: meetingsRootPath == null
                                    ? null
                                    : () =>
                                          service.openFolder(meetingsRootPath),
                                icon: const Icon(Icons.event_note_outlined),
                                label: const Text('Open meetings folder'),
                              ),
                              TextButton.icon(
                                onPressed: workspace.configPath.isEmpty
                                    ? null
                                    : () => service.openFile(
                                        workspace.configPath,
                                      ),
                                icon: const Icon(Icons.settings_outlined),
                                label: const Text('Open local_paths.json'),
                              ),
                            ],
                          );

                          final titleBlock = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meeting System settings',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColours.darkText,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'These settings keep the meeting module local-first by pointing it at the Omega OS folder and the shared template tree.',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColours.darkMutedText,
                                      height: 1.35,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              chips,
                              const SizedBox(height: 14),
                              if (templatePath != null)
                                SelectableText(
                                  templatePath,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColours.darkSecondary,
                                      ),
                                ),
                            ],
                          );

                          if (!wide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleBlock,
                                const SizedBox(height: 20),
                                actions,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: titleBlock),
                              const SizedBox(width: 20),
                              Flexible(child: actions),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (workspace.issues.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: meetingPanelDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MeetingSectionHeader(
                              title: 'Workspace notes',
                              subtitle:
                                  'What the Meeting System needs before it is fully ready.',
                            ),
                            const SizedBox(height: 10),
                            ...workspace.issues.map(
                              (issue) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• $issue',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColours.darkMutedText,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (workspace.issues.isNotEmpty) const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: meetingPanelDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MeetingSectionHeader(
                            title: 'Configured paths',
                            subtitle:
                                'The local files that keep the module grounded.',
                          ),
                          const SizedBox(height: 12),
                          _PathRow(
                            label: 'Config file',
                            pathText: workspace.configPath,
                            onOpen: workspace.configPath.isEmpty
                                ? null
                                : () => service.openFile(workspace.configPath),
                          ),
                          _PathRow(
                            label: 'Omega OS root',
                            pathText: omegaRootPath ?? 'Not configured',
                            onOpen: omegaRootPath == null
                                ? null
                                : () => service.openFolder(omegaRootPath),
                          ),
                          _PathRow(
                            label: 'Meetings root',
                            pathText: meetingsRootPath ?? 'Not available yet',
                            onOpen: meetingsRootPath == null
                                ? null
                                : () => service.openFolder(meetingsRootPath),
                          ),
                          _PathRow(
                            label: 'Templates folder',
                            pathText: templatePath ?? 'Not available yet',
                            onOpen: templatePath == null
                                ? null
                                : () => service.openFolder(templatePath),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: meetingPanelDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MeetingSectionHeader(
                            title: 'Projects & Programmes hub',
                            subtitle:
                                'This mirrors the exact Omega OS tree where the meetings live.',
                          ),
                          const SizedBox(height: 12),
                          _PathRow(
                            label: '21_PROJECTS_AND_PROGRAMMES root',
                            pathText:
                                hub.projectsRootPath ?? 'Not available yet',
                            onOpen: hub.projectsRootPath == null
                                ? null
                                : () =>
                                      service.openFolder(hub.projectsRootPath!),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Core meeting folders',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColours.darkSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 10),
                          ...hub.coreFolders.map(
                            (folder) => _PathRow(
                              label: folder.label,
                              pathText: folder.path,
                              onOpen: () => service.openFolder(folder.path),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Project areas discovered in Omega OS',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColours.darkSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 10),
                          if (hub.projectAreas.isEmpty)
                            Text(
                              'No project areas were found yet under 21_PROJECTS_AND_PROGRAMMES.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColours.darkMutedText),
                            )
                          else
                            ...hub.projectAreas.map(
                              (folder) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ProjectAreaTile(
                                  folder: folder,
                                  onOpen: () => service.openFolder(folder.path),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createStructure(MeetingFolderService service) async {
    setState(() {
      _refreshing = true;
    });

    try {
      await service.createMissingRequiredStructure();
      ref.invalidate(meetingWorkspaceProvider);
      ref.invalidate(meetingTemplatesProvider);
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }
}

class _ProjectAreaTile extends StatelessWidget {
  const _ProjectAreaTile({required this.folder, required this.onOpen});

  final MeetingOmegaHubFolder folder;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  folder.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  folder.path,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_outlined),
            label: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.label,
    required this.pathText,
    required this.onOpen,
  });

  final String label;
  final String pathText;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColours.darkOutline.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColours.darkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    pathText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_outlined),
              label: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingSettingsError extends StatelessWidget {
  const _MeetingSettingsError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Meeting settings could not load right now.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
