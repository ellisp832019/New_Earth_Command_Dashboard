import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/omega_os_folder_registry.dart';
import '../../../core/services/omega_os_folder_health_service.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/omega_os_folder_health_controller.dart';

class OmegaOsFolderHealthScreen extends ConsumerStatefulWidget {
  const OmegaOsFolderHealthScreen({super.key});

  @override
  ConsumerState<OmegaOsFolderHealthScreen> createState() =>
      _OmegaOsFolderHealthScreenState();
}

class _OmegaOsFolderHealthScreenState
    extends ConsumerState<OmegaOsFolderHealthScreen> {
  bool _isRepairing = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(omegaOsFolderHealthSnapshotProvider);

    return snapshot.when(
      loading: () => WorkspaceShell(
        title: 'Omega OS Folder Health',
        subtitle: 'Checking local folder health.',
        onBack: () => context.pop(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WorkspaceShell(
        title: 'Omega OS Folder Health',
        subtitle: 'Local folder health unavailable',
        onBack: () => context.pop(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Omega OS Folder Health could not load right now.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () =>
                      ref.invalidate(omegaOsFolderHealthSnapshotProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (data) {
        return WorkspaceShell(
          title: 'Omega OS Folder Health',
          subtitle: 'Checking reserved and active Omega OS folders.',
          onBack: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _HeroCard(
                  snapshot: data,
                  isRepairing: _isRepairing,
                  onRepair: _handleRepairStructure,
                  onReload: () =>
                      ref.invalidate(omegaOsFolderHealthSnapshotProvider),
                ),
                const SizedBox(height: 16),
                _SummaryStrip(snapshot: data),
                const SizedBox(height: 16),
                const _RoleCard(),
                const SizedBox(height: 16),
                const _SectionTitle(
                  icon: Icons.check_circle_outline,
                  title: 'Active systems',
                ),
                const SizedBox(height: 12),
                _SystemGrid(records: data.activeSystems, active: true),
                const SizedBox(height: 16),
                const _SectionTitle(
                  icon: Icons.radio_button_unchecked,
                  title: 'Reserved systems',
                ),
                const SizedBox(height: 12),
                _SystemGrid(records: data.reservedSystems, active: false),
                const SizedBox(height: 16),
                _FooterCard(snapshot: data),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRepairStructure() async {
    if (_isRepairing) {
      return;
    }

    setState(() => _isRepairing = true);
    try {
      final result = await ref
          .read(omegaOsFolderHealthServiceProvider)
          .repairActiveSystems();

      if (!mounted) {
        return;
      }

      ref.invalidate(omegaOsFolderHealthSnapshotProvider);

      final createdCount =
          result.createdFolders.length + result.createdFiles.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createdCount == 0
                ? 'Everything is already in place.'
                : 'Repair Structure created $createdCount starter item${createdCount == 1 ? '' : 's'}.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRepairing = false);
      }
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.snapshot,
    required this.isRepairing,
    required this.onRepair,
    required this.onReload,
  });

  final OmegaOsFolderHealthSnapshot snapshot;
  final bool isRepairing;
  final VoidCallback onRepair;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEEE, d MMMM y').format(DateTime.now());
    final allActiveHealthy =
        snapshot.missingFolderCount == 0 && snapshot.missingTemplatesCount == 0;
    final headline = allActiveHealthy
        ? 'Omega OS is calm and linked'
        : 'Omega OS needs a gentle repair pass';
    final body = snapshot.issues.isEmpty
        ? 'config/local_paths.json is the source of truth for the active systems. Reserved folders 20-23 stay visible but inactive.'
        : 'Some Omega OS paths still need attention, but the dashboard will keep the checks calm and local-first.';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                label: '🟢 Healthy ${snapshot.healthyCount}',
                accent: AppColours.darkSuccess,
              ),
              _StatusChip(
                label: '🟡 Missing templates ${snapshot.missingTemplatesCount}',
                accent: AppColours.darkAmber,
              ),
              _StatusChip(
                label: '🔴 Missing folder ${snapshot.missingFolderCount}',
                accent: const Color(0xFFE26B6B),
              ),
              _StatusChip(
                label: '⚪ Reserved ${snapshot.reservedCount}',
                accent: AppColours.darkMutedText,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Omega OS Folder Health Manager',
            style: theme.textTheme.displaySmall?.copyWith(
              color: AppColours.darkText,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: isRepairing ? null : onRepair,
                icon: isRepairing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.build_outlined),
                label: Text(
                  isRepairing ? 'Repairing structure' : 'Repair Structure',
                ),
              ),
              TextButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Source path: ${snapshot.configPath}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Omega OS root: ${snapshot.omegaOsRootPath ?? 'Not linked yet'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.snapshot});

  final OmegaOsFolderHealthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 920;
    final note = snapshot.issues.isEmpty
        ? '${OmegaOsFolderRegistry.reservedSystemsNote} QR Labels stay inside Assets. Visual Capture is active.'
        : 'The manager keeps checking the active systems and reserved folders from the same local config.';

    final chips = [
      _TinyMetricChip(
        label: 'Active systems',
        value: snapshot.activeSystems.length.toString(),
        accent: AppColours.darkSecondary,
      ),
      _TinyMetricChip(
        label: 'Reserved systems',
        value: snapshot.reservedSystems.length.toString(),
        accent: AppColours.darkMutedText,
      ),
      _TinyMetricChip(
        label: 'Config issues',
        value: snapshot.issues.length.toString(),
        accent: AppColours.darkAmber,
      ),
    ];

    if (isWide) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _panelDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                note,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: chips,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: chips),
        ],
      ),
    );
  }
}

class _SystemGrid extends StatelessWidget {
  const _SystemGrid({required this.records, required this.active});

  final List<OmegaOsFolderHealthRecord> records;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 960;
        final cardWidth = useTwoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final record in records)
              SizedBox(
                width: useTwoColumns ? cardWidth : constraints.maxWidth,
                child: _SystemCard(record: record, active: active),
              ),
          ],
        );
      },
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.record, required this.active});

  final OmegaOsFolderHealthRecord record;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _paletteFor(record.state);
    final statusLabel = switch (record.state) {
      OmegaOsFolderHealthState.healthy => 'Healthy',
      OmegaOsFolderHealthState.missingTemplates => 'Missing templates',
      OmegaOsFolderHealthState.missingFolder => 'Missing folder',
      OmegaOsFolderHealthState.reserved => 'Reserved',
    };

    final chips = <Widget>[
      _StatusChip(label: statusLabel, accent: palette),
      if (record.state == OmegaOsFolderHealthState.reserved)
        _StatusChip(
          label: record.pathExists ? 'Path ready' : 'Path missing',
          accent: record.pathExists
              ? AppColours.darkSuccess
              : AppColours.darkAmber,
        ),
      if (record.state == OmegaOsFolderHealthState.missingTemplates)
        _StatusChip(
          label: '${record.missingFiles.length} starter files missing',
          accent: AppColours.darkAmber,
        ),
      if (record.state == OmegaOsFolderHealthState.missingFolder)
        _StatusChip(
          label: '${record.missingFolders.length} folders missing',
          accent: const Color(0xFFE26B6B),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(
        highlighted: record.state == OmegaOsFolderHealthState.healthy,
      ),
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
                      record.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.folderName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(_iconFor(record.state), color: palette),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.path,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            record.note,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: chips),
          if (active) ...[
            const SizedBox(height: 12),
            Text(
              record.state == OmegaOsFolderHealthState.healthy
                  ? 'Ready for calm use.'
                  : 'Repair Structure can create only the missing starter files and folders.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  const _FooterCard({required this.snapshot});

  final OmegaOsFolderHealthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Text(
        snapshot.issues.isEmpty
            ? 'QR Labels stay as an Asset Intelligence sub-system. Visual Capture is active. Reserved systems 20-23 stay parked until their future builds begin.'
            : 'The health manager will keep using config/local_paths.json as the source of truth while the active systems and reserved folders are checked calmly.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColours.darkMutedText,
          height: 1.4,
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System roles',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _RoleLine(
            icon: Icons.payments_outlined,
            iconColor: AppColours.darkSuccess,
            title: 'Treasury',
            text: 'Money, budgets, receipts, and spending decisions.',
          ),
          const SizedBox(height: 10),
          const _RoleLine(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColours.darkSecondary,
            title: 'Assets',
            text:
                'Equipment, parts, stock, location, valuation, and QR Labels.',
          ),
          const SizedBox(height: 10),
          const _RoleLine(
            icon: Icons.photo_library_outlined,
            iconColor: AppColours.darkAmber,
            title: 'Visual Capture',
            text:
                'Receipt photos, asset photos, repair photos, and OCR queues.',
          ),
          const SizedBox(height: 10),
          const _RoleLine(
            icon: Icons.radio_button_unchecked,
            iconColor: AppColours.darkMutedText,
            title: 'Reserved systems',
            text: 'Folders 20-23 are parked for later and stay inactive.',
          ),
        ],
      ),
    );
  }
}

class _RoleLine extends StatelessWidget {
  const _RoleLine({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TinyMetricChip extends StatelessWidget {
  const _TinyMetricChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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

Color _paletteFor(OmegaOsFolderHealthState state) {
  return switch (state) {
    OmegaOsFolderHealthState.healthy => AppColours.darkSuccess,
    OmegaOsFolderHealthState.missingTemplates => AppColours.darkAmber,
    OmegaOsFolderHealthState.missingFolder => const Color(0xFFE26B6B),
    OmegaOsFolderHealthState.reserved => AppColours.darkMutedText,
  };
}

IconData _iconFor(OmegaOsFolderHealthState state) {
  return switch (state) {
    OmegaOsFolderHealthState.healthy => Icons.check_circle_outline,
    OmegaOsFolderHealthState.missingTemplates => Icons.description_outlined,
    OmegaOsFolderHealthState.missingFolder => Icons.folder_off_outlined,
    OmegaOsFolderHealthState.reserved => Icons.radio_button_unchecked,
  };
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
