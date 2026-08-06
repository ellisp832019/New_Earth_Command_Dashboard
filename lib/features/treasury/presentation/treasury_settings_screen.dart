import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/treasury_controller.dart';
import '../data/treasury_folder_service.dart';

class TreasurySettingsScreen extends ConsumerStatefulWidget {
  const TreasurySettingsScreen({super.key});

  @override
  ConsumerState<TreasurySettingsScreen> createState() =>
      _TreasurySettingsScreenState();
}

class _TreasurySettingsScreenState
    extends ConsumerState<TreasurySettingsScreen> {
  bool _isCreating = false;
  bool _isOpeningFolder = false;

  @override
  Widget build(BuildContext context) {
    final workspaceAsync = ref.watch(treasuryWorkspaceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings / Folder Link Health'),
        leading: IconButton(
          tooltip: 'Back to Treasury',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.go(RouteNames.treasury);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: () => ref.invalidate(treasuryWorkspaceProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: workspaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => SafeArea(
          child: _SettingsErrorCard(
            onReload: () => ref.invalidate(treasuryWorkspaceProvider),
          ),
        ),
        data: (snapshot) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SettingsHeroCard(snapshot: snapshot),
                const SizedBox(height: 16),
                _SettingsSetupStateCard(snapshot: snapshot),
                const SizedBox(height: 16),
                _SettingsPathCard(snapshot: snapshot),
                const SizedBox(height: 16),
                _SettingsHealthCard(snapshot: snapshot),
                const SizedBox(height: 16),
                _SettingsActionsCard(
                  snapshot: snapshot,
                  isCreating: _isCreating,
                  isOpeningFolder: _isOpeningFolder,
                  onOpenFolder: () => _handleOpenFolder(snapshot),
                  onReload: () => ref.invalidate(treasuryWorkspaceProvider),
                  onCreateMissingTemplates: () =>
                      _handleCreateMissingTemplates(snapshot),
                ),
                const SizedBox(height: 16),
                _SettingsMissingItemsCard(snapshot: snapshot),
                const SizedBox(height: 16),
                const _SettingsFooterCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleOpenFolder(TreasuryWorkspaceSnapshot snapshot) async {
    final financeRootPath = snapshot.financeRootPath;
    if (_isOpeningFolder || financeRootPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Treasury needs a linked finance folder first.'),
        ),
      );
      return;
    }

    setState(() => _isOpeningFolder = true);
    try {
      final opened = await ref
          .read(treasuryFolderServiceProvider)
          .openFinanceFolder(financeRootPath);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? 'Opened the external Treasury folder.'
                : 'Treasury could not open the folder on this device.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningFolder = false);
      }
    }
  }

  Future<void> _handleCreateMissingTemplates(
    TreasuryWorkspaceSnapshot snapshot,
  ) async {
    if (_isCreating) {
      return;
    }

    if (snapshot.financeRootPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Treasury needs a linked finance folder first.'),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      final result = await ref
          .read(treasuryFolderServiceProvider)
          .createMissingRequiredStructure();
      ref.invalidate(treasuryWorkspaceProvider);

      if (!mounted) {
        return;
      }

      final createdCount =
          result.createdFolders.length + result.createdFiles.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createdCount == 0
                ? 'Treasury structure was already in place.'
                : 'Created $createdCount missing item${createdCount == 1 ? '' : 's'}.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treasury settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColours.darkText,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hayley can check the finance folder link, open the external pack, and repair missing starter files from one calm screen.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusPill(
                label: snapshot.isReady ? 'Ready' : 'Setup needed',
                accent: snapshot.isReady
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
              const _StatusPill(
                label: 'Local-first only',
                accent: AppColours.darkSuccess,
              ),
              const _StatusPill(
                label: 'No finance copy inside repo',
                accent: AppColours.darkSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSetupStateCard extends StatelessWidget {
  const _SettingsSetupStateCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final hasLinkedPath = snapshot.financeRootPath != null;
    final hasMissingFolders = snapshot.missingFolders.isNotEmpty;
    final hasMissingFiles = snapshot.missingFiles.isNotEmpty;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.verified_outlined,
            title: 'Setup state',
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.isReady
                ? 'Treasury is ready. The external finance folder is linked and the required files are in place.'
                : hasLinkedPath
                ? 'Treasury is close. The folder is linked, but a few required items still need attention before the screen becomes fully ready.'
                : 'Treasury is waiting for a saved finance folder path in `config/local_paths.json`.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: hasLinkedPath ? 'Linked path saved' : 'Path missing',
                accent: hasLinkedPath
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
              _StatusPill(
                label: hasMissingFolders
                    ? _pluralCount(
                        snapshot.missingFolders.length,
                        'folder missing',
                        'folders missing',
                      )
                    : 'All folders present',
                accent: hasMissingFolders
                    ? AppColours.darkAmber
                    : AppColours.darkSuccess,
              ),
              _StatusPill(
                label: hasMissingFiles
                    ? _pluralCount(
                        snapshot.missingFiles.length,
                        'file missing',
                        'files missing',
                      )
                    : 'All files present',
                accent: hasMissingFiles
                    ? AppColours.darkAmber
                    : AppColours.darkSuccess,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsPathCard extends StatelessWidget {
  const _SettingsPathCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.link_outlined,
            title: 'Finance folder link',
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.financeRootPath ??
                'No finance folder path has been saved yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.financeRootPath == null
                ? 'Save the external Omega OS finance folder into `config/local_paths.json` so Treasury can read the live folder instead of a local copy.'
                : 'Treasury reads the live finance folder from local config and keeps the data outside the repo.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.configPath,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHealthCard extends StatelessWidget {
  const _SettingsHealthCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.health_and_safety_outlined,
            title: 'Path health',
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.guidanceNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: '${snapshot.requiredFolders.length} folders watched',
                accent: AppColours.darkSecondary,
              ),
              _StatusPill(
                label: '${snapshot.missingFolders.length} missing folders',
                accent: snapshot.missingFolders.isEmpty
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
              _StatusPill(
                label: '${snapshot.missingFiles.length} missing files',
                accent: snapshot.missingFiles.isEmpty
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsActionsCard extends StatelessWidget {
  const _SettingsActionsCard({
    required this.snapshot,
    required this.isCreating,
    required this.isOpeningFolder,
    required this.onOpenFolder,
    required this.onReload,
    required this.onCreateMissingTemplates,
  });

  final TreasuryWorkspaceSnapshot snapshot;
  final bool isCreating;
  final bool isOpeningFolder;
  final VoidCallback onOpenFolder;
  final VoidCallback onReload;
  final VoidCallback onCreateMissingTemplates;

  @override
  Widget build(BuildContext context) {
    final canCreate = snapshot.financeRootPath != null;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.tune_outlined, title: 'Calm actions'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isOpeningFolder ? null : onOpenFolder,
                icon: isOpeningFolder
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.folder_open_outlined),
                label: const Text('Open finance folder'),
              ),
              FilledButton.tonalIcon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload files'),
              ),
              OutlinedButton.icon(
                onPressed: canCreate && !isCreating
                    ? onCreateMissingTemplates
                    : null,
                icon: isCreating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_outlined),
                label: const Text('Create missing templates'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            canCreate
                ? 'The app will create only the missing folders and starter files. Existing finance data stays untouched.'
                : 'The finance folder must be linked before Treasury can create missing templates.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMissingItemsCard extends StatelessWidget {
  const _SettingsMissingItemsCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useTwoColumns = constraints.maxWidth >= 860;

          final folders = _ChecklistPanel(
            title: 'Missing folders',
            items: snapshot.missingFolders,
            emptyText: 'No folders are missing right now.',
          );
          final files = _ChecklistPanel(
            title: 'Missing files',
            items: snapshot.missingFiles,
            emptyText: 'No files are missing right now.',
          );

          if (!useTwoColumns) {
            return Column(
              children: [folders, const SizedBox(height: 14), files],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: folders),
              const SizedBox(width: 14),
              Expanded(child: files),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsFooterCard extends StatelessWidget {
  const _SettingsFooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.9),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        'This screen is reusable for other business areas later, as long as they keep their own local-first source-of-truth folder.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
      ),
    );
  }
}

class _SettingsErrorCard extends StatelessWidget {
  const _SettingsErrorCard({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.info_outline,
            title: 'Treasury settings',
          ),
          const SizedBox(height: 12),
          Text(
            'Treasury could not load the health state right now.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
            label: const Text('Reload'),
          ),
        ],
      ),
    );
  }
}

class _ChecklistPanel extends StatelessWidget {
  const _ChecklistPanel({
    required this.title,
    required this.items,
    required this.emptyText,
  });

  final String title;
  final List<String> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              emptyText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: 16,
                      color: AppColours.darkAmber,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColours.darkText,
                          height: 1.35,
                        ),
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, this.highlighted = false});

  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _pluralCount(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}
