import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class RepairSummaryScreen extends ConsumerWidget {
  const RepairSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final equipment = ref.watch(assetEquipmentRegisterProvider);
    final repairItems = ref.watch(assetBrokenRepairEquipmentProvider);

    return workspace.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _RepairSummaryError(
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return equipment.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _RepairSummaryError(
            onReload: () => ref.invalidate(assetEquipmentRegisterProvider),
          ),
          data: (equipmentTable) {
            return repairItems.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _RepairSummaryError(
                onReload: () => ref.invalidate(assetBrokenRepairEquipmentProvider),
              ),
              data: (rows) {
                final brokenCount = rows.where((row) {
                  final status = (row['status'] ?? '').trim().toLowerCase();
                  final condition = (row['condition'] ?? '').trim().toLowerCase();
                  return status == 'broken' || condition == 'broken';
                }).length;
                final repairingCount = rows.length - brokenCount;
                final projectCount = _distinctProjects(rows).length;

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _RepairHeader(
                                  assetPath: workspaceData.assetsRootPath,
                                  brokenCount: brokenCount,
                                  repairingCount: repairingCount,
                                  projectCount: projectCount,
                                ),
                                const SizedBox(height: 20),
                                _RepairSummaryRow(
                                  brokenCount: brokenCount,
                                  repairingCount: repairingCount,
                                  totalEquipment: equipmentTable.rows.length,
                                ),
                                const SizedBox(height: 20),
                                _RepairListCard(rows: rows),
                                const SizedBox(height: 20),
                                _RepairNotesCard(rows: rows),
                                const SizedBox(height: 20),
                                _RepairFooter(itemCount: equipmentTable.rows.length),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RepairHeader extends StatelessWidget {
  const _RepairHeader({
    required this.assetPath,
    required this.brokenCount,
    required this.repairingCount,
    required this.projectCount,
  });

  final String? assetPath;
  final int brokenCount;
  final int repairingCount;
  final int projectCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Broken / Repair',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep the repair queue clear, visible, and calm so decisions stay easy to make.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(label: assetPath ?? 'Asset folder not linked'),
              _InfoChip(label: '$brokenCount broken'),
              _InfoChip(label: '$repairingCount repairing'),
              _InfoChip(label: '$projectCount projects'),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), chips],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(
                width: 420,
                child: Align(
                  alignment: Alignment.topRight,
                  child: chips,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RepairSummaryRow extends StatelessWidget {
  const _RepairSummaryRow({
    required this.brokenCount,
    required this.repairingCount,
    required this.totalEquipment,
  });

  final int brokenCount;
  final int repairingCount;
  final int totalEquipment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final cards = [
          _MetricCard(
            label: 'Broken',
            value: brokenCount,
            accent: const Color(0xFFE26B6B),
          ),
          _MetricCard(
            label: 'Repairing',
            value: repairingCount,
            accent: AppColours.darkAmber,
          ),
          _MetricCard(
            label: 'Equipment Total',
            value: totalEquipment,
            accent: AppColours.darkSecondary,
          ),
        ];

        if (wide) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
              const SizedBox(width: 12),
              Expanded(child: cards[2]),
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              cards[i],
              if (i != cards.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _RepairListCard extends StatelessWidget {
  const _RepairListCard({required this.rows});

  final List<Map<String, String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Broken / repair items',
            icon: Icons.build_circle_outlined,
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text(
              'Nothing needs repair attention right now. The list stays quiet and manageable.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  _RepairItemCard(row: rows[index]),
                  if (index != rows.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _RepairItemCard extends StatelessWidget {
  const _RepairItemCard({required this.row});

  final Map<String, String> row;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? '').trim().toLowerCase();
    final condition = (row['condition'] ?? '').trim().toLowerCase();
    final isBroken = status == 'broken' || condition == 'broken';
    final accent = isBroken ? const Color(0xFFE26B6B) : AppColours.darkAmber;
    final displayStatus = status.isEmpty ? 'broken / repair' : status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row['name']?.trim().isNotEmpty == true
                      ? row['name']!.trim()
                      : 'Unnamed equipment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _StatusPill(label: displayStatus, accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: row['asset_id'] ?? 'No ID'),
              _InfoChip(label: row['type'] ?? 'No type'),
              _InfoChip(label: row['project'] ?? 'No project'),
              _InfoChip(label: row['location'] ?? 'No location'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Condition ${row['condition'] ?? 'unknown'} • Status ${row['status'] ?? 'unknown'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
          ),
          if ((row['notes'] ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              row['notes']!.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RepairNotesCard extends StatelessWidget {
  const _RepairNotesCard({required this.rows});

  final List<Map<String, String>> rows;

  @override
  Widget build(BuildContext context) {
    final broken = rows.where((row) {
      final status = (row['status'] ?? '').trim().toLowerCase();
      final condition = (row['condition'] ?? '').trim().toLowerCase();
      return status == 'broken' || condition == 'broken';
    }).length;
    final repairing = rows.length - broken;
    final projects = _distinctProjects(rows).length;

    final hints = [
      'Check the repair note first before making a new purchase.',
      'Confirm the project owner and current location.',
      'Link any repair spend back to Treasury when it matters.',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Repair notes',
            icon: Icons.notes_outlined,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: '$broken broken'),
              _InfoChip(label: '$repairing repairing'),
              _InfoChip(label: '$projects projects'),
            ],
          ),
          const SizedBox(height: 12),
          for (final hint in hints) ...[
            _HintRow(text: hint),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _RepairFooter extends StatelessWidget {
  const _RepairFooter({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColours.darkSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$itemCount equipment items are in the current register. Keep the repair queue short, useful, and easy to act on.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.arrow_right_alt,
          size: 18,
          color: AppColours.darkSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.decimalPattern().format(value),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RepairSummaryError extends StatelessWidget {
  const _RepairSummaryError({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Broken / repair view could not load right now.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
              ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              fontWeight: FontWeight.w600,
            ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
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

BoxDecoration _panelDecoration(BuildContext context, {bool highlighted = false}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurfaceAlt.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.93),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? AppColours.darkSecondary.withValues(alpha: 0.28)
          : AppColours.darkOutline,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x20000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  );
}

List<String> _distinctProjects(List<Map<String, String>> rows) {
  final projects = <String>{};
  for (final row in rows) {
    final project = (row['project'] ?? '').trim();
    if (project.isNotEmpty) {
      projects.add(project);
    }
  }
  return projects.toList(growable: false);
}
