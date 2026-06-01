import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/folder_bootstrap_wizard.dart';
import '../application/visual_capture_controller.dart';
import '../data/visual_capture_folder_service.dart';

const _visualCaptureUnavailableSnapshot = VisualCaptureWorkspaceSnapshot(
  configPath: 'config/local_paths.json',
  visualCaptureRootPath: null,
  isReady: false,
  issues: <String>['Visual Capture could not be loaded right now.'],
  requiredFolders: VisualCaptureFolderService.requiredFolders,
  missingFolders: <String>[],
  missingFiles: <String>[],
  guidanceNote:
      'The Visual Capture area is waiting for the external Omega OS folder.',
);

class VisualCaptureScreen extends ConsumerStatefulWidget {
  const VisualCaptureScreen({super.key});

  @override
  ConsumerState<VisualCaptureScreen> createState() =>
      _VisualCaptureScreenState();
}

class _VisualCaptureScreenState extends ConsumerState<VisualCaptureScreen> {
  bool _isCreatingStructure = false;
  bool _isImporting = false;
  late final TextEditingController _importPathController;
  String _selectedCaptureType =
      VisualCaptureFolderService.inboxCaptureTypes.first;

  @override
  void initState() {
    super.initState();
    _importPathController = TextEditingController();
  }

  @override
  void dispose() {
    _importPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(visualCaptureWorkspaceProvider);
    final inboxSnapshot = ref.watch(visualCaptureInboxProvider);

    return snapshot.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _VisualCaptureSetupScreen(
        title: 'Visual Capture needs a calm setup',
        body:
            'The Visual Capture folder could not be loaded right now. Check the local path and try again.',
        snapshot: _visualCaptureUnavailableSnapshot,
        isCreatingStructure: _isCreatingStructure,
        onCreateStructure: _handleCreateStructure,
        onReload: () => ref.invalidate(visualCaptureWorkspaceProvider),
        onOpenSetupWizard: () =>
            _openSetupWizard(context, ref, _visualCaptureUnavailableSnapshot),
      ),
      data: (data) {
        if (!data.isReady) {
          return _VisualCaptureSetupScreen(
            title: 'Visual Capture setup',
            body:
                'Hayley can use Visual Capture once the external Omega OS capture folder is linked and healthy.',
            snapshot: data,
            isCreatingStructure: _isCreatingStructure,
            onCreateStructure: _handleCreateStructure,
            onReload: () => ref.invalidate(visualCaptureWorkspaceProvider),
            onOpenSetupWizard: () => _openSetupWizard(context, ref, data),
          );
        }

        return _VisualCaptureHomeScreen(
          snapshot: data,
          inboxSnapshot: inboxSnapshot,
          isImporting: _isImporting,
          selectedCaptureType: _selectedCaptureType,
          importPathController: _importPathController,
          onCaptureTypeChanged: (value) {
            if (value == null || value.isEmpty) {
              return;
            }
            setState(() => _selectedCaptureType = value);
          },
          onPickFile: () => _handlePickFile(data.visualCaptureRootPath),
          onImportFromPath: () =>
              _handleImportFromPath(data.visualCaptureRootPath),
          onOpenInboxFolder: () =>
              _handleOpenFolder(data.visualCaptureRootPath, inboxOnly: true),
          onReload: () => ref.invalidate(visualCaptureWorkspaceProvider),
        );
      },
    );
  }

  Future<void> _handleCreateStructure() async {
    if (_isCreatingStructure) {
      return;
    }

    setState(() => _isCreatingStructure = true);
    try {
      final result = await ref
          .read(visualCaptureFolderServiceProvider)
          .createMissingRequiredStructure();

      if (!mounted) {
        return;
      }

      ref.invalidate(visualCaptureWorkspaceProvider);

      final createdCount =
          result.createdFolders.length + result.createdFiles.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createdCount == 0
                ? 'Visual Capture folder structure was already in place.'
                : 'Created $createdCount visual capture starter item${createdCount == 1 ? '' : 's'}.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingStructure = false);
      }
    }
  }

  Future<void> _handlePickFile(String? visualCaptureRootPath) async {
    if (visualCaptureRootPath == null || _isImporting) {
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );
    final sourcePath = result?.files.single.path;
    if (sourcePath == null || sourcePath.isEmpty) {
      return;
    }

    await _handleImport(
      visualCaptureRootPath: visualCaptureRootPath,
      sourcePath: sourcePath,
    );
  }

  Future<void> _handleImportFromPath(String? visualCaptureRootPath) async {
    if (visualCaptureRootPath == null || _isImporting) {
      return;
    }

    final sourcePath = _importPathController.text.trim();
    if (sourcePath.isEmpty) {
      return;
    }

    await _handleImport(
      visualCaptureRootPath: visualCaptureRootPath,
      sourcePath: sourcePath,
    );
  }

  Future<void> _handleImport({
    required String visualCaptureRootPath,
    required String sourcePath,
  }) async {
    setState(() => _isImporting = true);
    try {
      final result = await ref
          .read(visualCaptureFolderServiceProvider)
          .importImageToInbox(
            visualCaptureRootPath: visualCaptureRootPath,
            sourceFilePath: sourcePath,
            captureType: _selectedCaptureType,
          );

      if (!mounted) {
        return;
      }

      _importPathController.clear();
      ref.invalidate(visualCaptureInboxProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${path.basename(result.copiedFilePath)} to the Visual Capture inbox.',
          ),
        ),
      );
    } on FileSystemException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _handleOpenFolder(
    String? visualCaptureRootPath, {
    bool inboxOnly = false,
  }) async {
    if (visualCaptureRootPath == null) {
      return;
    }

    final service = ref.read(visualCaptureFolderServiceProvider);
    final opened = inboxOnly
        ? await service.openVisualCaptureInboxFolder(visualCaptureRootPath)
        : await service.openVisualCaptureFolder(visualCaptureRootPath);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? inboxOnly
                    ? 'Opened the Visual Capture folder.'
                    : 'Opened the external Visual Capture folder.'
              : 'Visual Capture could not open the folder on this device.',
        ),
      ),
    );
  }
}

class _VisualCaptureHomeScreen extends StatelessWidget {
  const _VisualCaptureHomeScreen({
    required this.snapshot,
    required this.inboxSnapshot,
    required this.isImporting,
    required this.selectedCaptureType,
    required this.importPathController,
    required this.onCaptureTypeChanged,
    required this.onPickFile,
    required this.onImportFromPath,
    required this.onOpenInboxFolder,
    required this.onReload,
  });

  final VisualCaptureWorkspaceSnapshot snapshot;
  final AsyncValue<VisualCaptureInboxSnapshot> inboxSnapshot;
  final bool isImporting;
  final String selectedCaptureType;
  final TextEditingController importPathController;
  final ValueChanged<String?> onCaptureTypeChanged;
  final VoidCallback onPickFile;
  final VoidCallback onImportFromPath;
  final VoidCallback onOpenInboxFolder;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1060;
    final dateLabel = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            isWide ? 28 : 18,
            isWide ? 28 : 18,
            isWide ? 28 : 18,
            24,
          ),
          children: [
            _BackRow(
              onBackToDashboard: () => context.go(RouteNames.dashboard),
            ),
            const SizedBox(height: 14),
            _VisualCaptureHeroCard(
              snapshot: snapshot,
              dateLabel: dateLabel,
              onReload: onReload,
            ),
            const SizedBox(height: 18),
            _VisualCaptureHealthCard(snapshot: snapshot, onReload: onReload),
            const SizedBox(height: 18),
            _VisualCaptureInboxCard(
              snapshot: snapshot,
              inboxSnapshot: inboxSnapshot,
              isImporting: isImporting,
              selectedCaptureType: selectedCaptureType,
              importPathController: importPathController,
              onCaptureTypeChanged: onCaptureTypeChanged,
              onPickFile: onPickFile,
              onImportFromPath: onImportFromPath,
              onOpenInboxFolder: onOpenInboxFolder,
            ),
            const SizedBox(height: 18),
            _VisualCaptureFoundationCard(snapshot: snapshot),
            const SizedBox(height: 18),
            _VisualCaptureFooterCard(theme: theme, snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}

class _VisualCaptureInboxCard extends StatelessWidget {
  const _VisualCaptureInboxCard({
    required this.snapshot,
    required this.inboxSnapshot,
    required this.isImporting,
    required this.selectedCaptureType,
    required this.importPathController,
    required this.onCaptureTypeChanged,
    required this.onPickFile,
    required this.onImportFromPath,
    required this.onOpenInboxFolder,
  });

  final VisualCaptureWorkspaceSnapshot snapshot;
  final AsyncValue<VisualCaptureInboxSnapshot> inboxSnapshot;
  final bool isImporting;
  final String selectedCaptureType;
  final TextEditingController importPathController;
  final ValueChanged<String?> onCaptureTypeChanged;
  final VoidCallback onPickFile;
  final VoidCallback onImportFromPath;
  final VoidCallback onOpenInboxFolder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(title: 'Capture inbox', icon: Icons.inbox_outlined),
          const SizedBox(height: 10),
          Text(
            'Import receipt photos, asset photos, repair evidence, and workbench snapshots into the Omega OS inbox without touching finance or asset records yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          inboxSnapshot.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => Text(
              'Capture inbox could not load right now.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
            data: (inbox) {
              final items = inbox.items;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InlineTag(
                        label: inbox.inboxPath ?? 'Inbox path not linked',
                        accent: AppColours.darkSurfaceRaised,
                        foreground: AppColours.darkText,
                      ),
                      _InlineTag(
                        label:
                            '${inbox.queuedFileCount} file${inbox.queuedFileCount == 1 ? '' : 's'} in inbox',
                        accent: AppColours.darkSuccess,
                        foreground: AppColours.darkText,
                      ),
                      _InlineTag(
                        label:
                            '${items.length} indexed capture${items.length == 1 ? '' : 's'}',
                        accent: AppColours.darkSecondary,
                        foreground: AppColours.darkText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 920;
                      final actionColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: selectedCaptureType,
                            decoration: const InputDecoration(
                              labelText: 'Capture type',
                              border: OutlineInputBorder(),
                            ),
                            items: VisualCaptureFolderService.inboxCaptureTypes
                                .map(
                                  (type) => DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type.replaceAll('_', ' ')),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: onCaptureTypeChanged,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: importPathController,
                            decoration: const InputDecoration(
                              labelText: 'Source file path',
                              hintText:
                                  'Paste a local image path if file picker is not available',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: isImporting ? null : onPickFile,
                                icon: isImporting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.file_open_outlined),
                                label: const Text('Pick image'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: isImporting
                                    ? null
                                    : onImportFromPath,
                                icon: const Icon(Icons.upload_file_outlined),
                                label: const Text('Import path'),
                              ),
                              TextButton.icon(
                                onPressed: onOpenInboxFolder,
                                icon: const Icon(Icons.folder_open_outlined),
                                label: const Text('Open inbox'),
                              ),
                            ],
                          ),
                        ],
                      );

                      final preview = _InboxPreviewList(items: items);

                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            actionColumn,
                            const SizedBox(height: 16),
                            preview,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: actionColumn),
                          const SizedBox(width: 18),
                          Expanded(child: preview),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InboxPreviewList extends StatelessWidget {
  const _InboxPreviewList({required this.items});

  final List<VisualCaptureInboxItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.85),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent imports',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'No imports yet. Pick a local image file to add the first inbox item.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
            )
          else
            ...items
                .take(5)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.captureId,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColours.darkText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.captureType.replaceAll('_', ' ')} · ${path.basename(item.filePath)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColours.darkMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _VisualCaptureHeroCard extends StatelessWidget {
  const _VisualCaptureHeroCard({
    required this.snapshot,
    required this.dateLabel,
    required this.onReload,
  });

  final VisualCaptureWorkspaceSnapshot snapshot;
  final String dateLabel;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = snapshot.isReady ? 'Ready' : 'Setup needed';
    final headline = snapshot.isReady
        ? 'Visual Capture is linked and calm'
        : 'Set up the capture folder to begin sorting evidence';
    final supportingCopy = snapshot.isReady
        ? 'Keep receipt photos, asset photos, repair evidence, and inbox uploads local-first while the dashboard stays clear and lightweight.'
        : 'This tab stays local-first and only becomes fully useful once the external Omega OS visual capture folder is connected.';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InlineTag(
                label: statusLabel,
                accent: snapshot.isReady
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
                foreground: AppColours.darkText,
              ),
              _InlineTag(
                label: 'Capture first',
                accent: AppColours.darkSecondary,
                foreground: AppColours.darkText,
              ),
              _InlineTag(
                label: dateLabel,
                accent: AppColours.darkPurple,
                foreground: AppColours.darkText,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Visual Capture',
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppColours.darkText,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            headline,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            supportingCopy,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisualCaptureHealthCard extends StatelessWidget {
  const _VisualCaptureHealthCard({
    required this.snapshot,
    required this.onReload,
  });

  final VisualCaptureWorkspaceSnapshot snapshot;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 960;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _PanelTitle(
                    title: 'Folder health',
                    icon: Icons.photo_library_outlined,
                  ),
                  const Spacer(),
                  _InlineTag(
                    label: snapshot.isReady ? 'Linked' : 'Needs setup',
                    accent: snapshot.isReady
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                    foreground: AppColours.darkText,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Source path',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                snapshot.visualCaptureRootPath ?? 'Not linked yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                snapshot.guidanceNote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              if (snapshot.issues.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final issue in snapshot.issues)
                      _InlineTag(
                        label: issue,
                        accent: AppColours.darkAmber,
                        foreground: AppColours.darkText,
                      ),
                  ],
                ),
              ],
              if (snapshot.missingFolders.isNotEmpty ||
                  snapshot.missingFiles.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Missing data',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Starter folders and tracker files are missing, so the setup helper can finish the structure cleanly.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (snapshot.missingFolders.isNotEmpty)
                      _InlineTag(
                        label:
                            '${snapshot.missingFolders.length} folder${snapshot.missingFolders.length == 1 ? '' : 's'} missing',
                        accent: AppColours.darkAmber,
                        foreground: AppColours.darkText,
                      ),
                    if (snapshot.missingFiles.isNotEmpty)
                      _InlineTag(
                        label:
                            '${snapshot.missingFiles.length} file${snapshot.missingFiles.length == 1 ? '' : 's'} missing',
                        accent: AppColours.darkAmber,
                        foreground: AppColours.darkText,
                      ),
                  ],
                ),
              ],
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 20),
              SizedBox(width: 220, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _VisualCaptureFoundationCard extends StatelessWidget {
  const _VisualCaptureFoundationCard({required this.snapshot});

  final VisualCaptureWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final folders = snapshot.requiredFolders;
    final files = snapshot.missingFiles.isEmpty
        ? VisualCaptureFolderService.requiredFiles
        : snapshot.missingFiles;

    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Foundations',
            icon: Icons.rule_folder_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Visual Capture keeps the inbox and evidence structure in Omega OS, not in the repo. The first build only creates safe starter folders and CSV indexes.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tracked folders',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final folder in folders)
                _InlineTag(
                  label: folder,
                  accent: AppColours.darkSurfaceRaised,
                  foreground: AppColours.darkText,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Starter indexes',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final file in files)
                _InlineTag(
                  label: file,
                  accent: AppColours.darkSurfaceRaised,
                  foreground: AppColours.darkText,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisualCaptureFooterCard extends StatelessWidget {
  const _VisualCaptureFooterCard({required this.theme, required this.snapshot});

  final ThemeData theme;
  final VisualCaptureWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      padding: const EdgeInsets.all(20),
      child: Text(
        snapshot.isReady
            ? 'The capture foundation is ready. Next we can add the inbox, import flow, and photo linking without changing the Omega OS source folders.'
            : 'Open the setup helper to create only the missing folders and starter CSVs. Existing visual capture data stays outside the repo.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColours.darkMutedText,
          height: 1.45,
        ),
      ),
    );
  }
}

class _VisualCaptureSetupScreen extends StatelessWidget {
  const _VisualCaptureSetupScreen({
    required this.title,
    required this.body,
    required this.snapshot,
    required this.isCreatingStructure,
    required this.onCreateStructure,
    required this.onReload,
    required this.onOpenSetupWizard,
  });

  final String title;
  final String body;
  final VisualCaptureWorkspaceSnapshot snapshot;
  final bool isCreatingStructure;
  final VoidCallback onCreateStructure;
  final VoidCallback onReload;
  final VoidCallback onOpenSetupWizard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _BackRow(
              onBackToDashboard: () => context.go(RouteNames.dashboard),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: _panelDecoration(highlighted: true),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: isCreatingStructure
                            ? null
                            : onCreateStructure,
                        icon: isCreatingStructure
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.build_outlined),
                        label: Text(
                          isCreatingStructure
                              ? 'Creating setup'
                              : 'Create starter files',
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed:
                            snapshot.missingFiles.isEmpty &&
                                snapshot.missingFolders.isEmpty
                            ? null
                            : onOpenSetupWizard,
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: const Text('Open setup wizard'),
                      ),
                      TextButton.icon(
                        onPressed: onReload,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reload Visual Capture'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: _panelDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PanelTitle(
                    title: 'Calm setup steps',
                    icon: Icons.checklist_rtl_outlined,
                  ),
                  const SizedBox(height: 14),
                  ...[
                    'Make sure `config/local_paths.json` exists in the dashboard repo.',
                    'Set `visual_capture_path` to the external Omega OS capture folder.',
                    'Open the setup helper to create only the missing folders and starter templates.',
                    'Return here and reload Visual Capture after the helper finishes.',
                  ].map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.arrow_right_rounded,
                            size: 18,
                            color: AppColours.darkSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColours.darkText,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openSetupWizard(
  BuildContext context,
  WidgetRef ref,
  VisualCaptureWorkspaceSnapshot snapshot,
) {
  final service = ref.read(visualCaptureFolderServiceProvider);

  return showFolderBootstrapWizard(
    context: context,
    plan: FolderBootstrapWizardPlan(
      title: 'Visual Capture setup wizard',
      subtitle:
          'This calm pipeline checks the external capture folder and creates only what is missing. Raw photos stay in Omega OS.',
      steps: const [
        FolderBootstrapWizardStep(
          title: 'Review the link',
          body:
              'Confirm the external Omega OS folder is the source of truth before any file changes happen.',
          icon: Icons.link_outlined,
        ),
        FolderBootstrapWizardStep(
          title: 'Create missing structure',
          body:
              'Only the missing folders and starter CSV indexes are added. Existing capture data stays untouched.',
          icon: Icons.auto_awesome_outlined,
        ),
        FolderBootstrapWizardStep(
          title: 'Reload and confirm',
          body:
              'Visual Capture rechecks the folder after creation and stays calm when the path is healthy.',
          icon: Icons.refresh_outlined,
        ),
      ],
      missingFolders: snapshot.missingFolders,
      missingFiles: snapshot.missingFiles,
    ),
    onCreateMissingStructure: () async {
      final result = await service.createMissingRequiredStructure();
      ref.invalidate(visualCaptureWorkspaceProvider);
      return result;
    },
    onReload: () => ref.invalidate(visualCaptureWorkspaceProvider),
  );
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColours.darkSecondary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
        ),
      ],
    );
  }
}

class _BackRow extends StatelessWidget {
  const _BackRow({required this.onBackToDashboard});

  final VoidCallback onBackToDashboard;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onBackToDashboard,
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text('Back to Dashboard'),
      ),
    );
  }
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({
    required this.label,
    required this.accent,
    this.foreground,
  });

  final String label;
  final Color accent;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foreground ?? accent,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration({bool highlighted = false}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurface.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? AppColours.darkSecondary.withValues(alpha: 0.22)
          : AppColours.darkOutline.withValues(alpha: 0.9),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 26,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
