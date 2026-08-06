import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';
import 'meeting_system_widgets.dart';

class MeetingTemplatesScreen extends ConsumerWidget {
  const MeetingTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(meetingTemplatesProvider);

    return WorkspaceShell(
      title: 'Meeting Templates',
      subtitle: 'Template library workspace',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      trailingActions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => ref.invalidate(meetingTemplatesProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MeetingTemplatesError(
          error: error,
          onRetry: () => ref.invalidate(meetingTemplatesProvider),
        ),
        data: (data) {
          final service = ref.read(meetingFolderServiceProvider);
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
                      final statusChips = Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          MeetingStatChip(
                            label: 'Templates',
                            value: '${data.documents.length}',
                            accentColor: AppColours.darkSecondary,
                          ),
                          MeetingStatChip(
                            label: 'Ready',
                            value:
                                '${data.documents.where((item) => item.exists).length}',
                            accentColor: AppColours.darkSuccess,
                          ),
                          MeetingStatChip(
                            label: 'Missing',
                            value:
                                '${data.documents.where((item) => !item.exists).length}',
                            accentColor: AppColours.darkAmber,
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
                            onPressed: data.templateFolderPath == null
                                ? null
                                : () => service.openFolder(
                                    data.templateFolderPath!,
                                  ),
                            icon: const Icon(Icons.folder_open_outlined),
                            label: const Text('Open template folder'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingDashboard),
                            icon: const Icon(Icons.dashboard_outlined),
                            label: const Text('Dashboard'),
                          ),
                        ],
                      );

                      final titleBlock = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meeting template library',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'These Omega OS markdown templates are copied into each new meeting folder so the notes stay calm and consistent.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColours.darkMutedText,
                                  height: 1.35,
                                ),
                          ),
                          const SizedBox(height: 14),
                          statusChips,
                          const SizedBox(height: 14),
                          if (data.templateFolderPath != null)
                            SelectableText(
                              data.templateFolderPath!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColours.darkSecondary),
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
                if (data.issues.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: meetingPanelDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MeetingSectionHeader(
                          title: 'Workspace notes',
                          subtitle:
                              'What the template library needs before it is fully ready.',
                        ),
                        const SizedBox(height: 10),
                        ...data.issues.map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• $issue',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColours.darkMutedText),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (data.issues.isNotEmpty) const SizedBox(height: 16),
                if (data.documents.isEmpty)
                  const MeetingEmptyPanel(
                    title: 'No templates found',
                    message:
                        'Open the template folder or create the starter structure from the Meeting Dashboard.',
                    icon: Icons.description_outlined,
                  )
                else
                  ...data.documents.map(
                    (document) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _TemplateCard(
                        document: document,
                        onOpenFolder: data.templateFolderPath == null
                            ? null
                            : () =>
                                  service.openFolder(data.templateFolderPath!),
                        onOpenFile: () => service.openFile(document.filePath),
                        onCopyPath: () async {
                          await Clipboard.setData(
                            ClipboardData(text: document.filePath),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Copied ${document.displayName} path',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.document,
    required this.onOpenFile,
    required this.onCopyPath,
    required this.onOpenFolder,
  });

  final MeetingTemplateDocument document;
  final VoidCallback onOpenFile;
  final VoidCallback onCopyPath;
  final VoidCallback? onOpenFolder;

  @override
  Widget build(BuildContext context) {
    final borderColor = document.exists
        ? AppColours.darkOutline.withValues(alpha: 0.9)
        : AppColours.darkAmber.withValues(alpha: 0.9);
    final chipColor = document.exists
        ? AppColours.darkSuccess
        : AppColours.darkAmber;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: meetingPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      document.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: chipColor.withValues(alpha: 0.28)),
                ),
                child: Text(
                  document.exists ? 'Ready' : 'Missing',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: chipColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SelectableText(
            document.filePath,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkSecondary),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColours.darkSurfaceRaised.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              document.preview,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkText,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onOpenFile,
                icon: const Icon(Icons.open_in_new_outlined),
                label: const Text('Open file'),
              ),
              TextButton.icon(
                onPressed: onCopyPath,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy path'),
              ),
              TextButton.icon(
                onPressed: onOpenFolder,
                icon: const Icon(Icons.folder_outlined),
                label: const Text('Open folder'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeetingTemplatesError extends StatelessWidget {
  const _MeetingTemplatesError({required this.error, required this.onRetry});

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
            const Icon(Icons.description_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Meeting templates could not load right now.',
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
