import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class BinMapScreen extends ConsumerWidget {
  const BinMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final locations = ref.watch(assetLocationRegisterProvider);

    return workspace.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          _BinMapError(onReload: () => ref.invalidate(assetWorkspaceProvider)),
      data: (workspaceData) {
        return locations.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _BinMapError(
            onReload: () => ref.invalidate(assetLocationRegisterProvider),
          ),
          data: (table) {
            final groups = _groupLocations(table.rows);
            final totalAssets = _distinctAssetCount(table.rows);
            final photoLinkedCount = _countWithValue(table.rows, 'photo_link');
            final noteLinkedCount = _countWithValue(table.rows, 'notes');

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
                            _BinMapHeader(
                              assetPath: workspaceData.assetsRootPath,
                              locationCount: groups.length,
                              assetCount: totalAssets,
                            ),
                            const SizedBox(height: 20),
                            _BinMapSummaryRow(
                              locationCount: groups.length,
                              assetCount: totalAssets,
                              photoLinkedCount: photoLinkedCount,
                              noteLinkedCount: noteLinkedCount,
                            ),
                            const SizedBox(height: 20),
                            _BinMapActionStrip(
                              onOpenLocationRegister: () => context.push(
                                RouteNames.assetLocationRegister,
                              ),
                              onOpenEvidenceLibrary: () =>
                                  context.push(RouteNames.assetEvidenceLibrary),
                              onOpenEquipmentRegister: () =>
                                  context.push(RouteNames.assetEquipment),
                            ),
                            const SizedBox(height: 20),
                            if (groups.isEmpty)
                              _EmptyBinMapState(
                                onOpenLocationRegister: () => context.push(
                                  RouteNames.assetLocationRegister,
                                ),
                              )
                            else
                              Column(
                                children: [
                                  for (
                                    var index = 0;
                                    index < groups.length;
                                    index++
                                  ) ...[
                                    _BinGroupCard(group: groups[index]),
                                    if (index != groups.length - 1)
                                      const SizedBox(height: 12),
                                  ],
                                ],
                              ),
                            const SizedBox(height: 20),
                            const _BinMapFooter(),
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
  }
}

class _BinMapHeader extends StatelessWidget {
  const _BinMapHeader({
    required this.assetPath,
    required this.locationCount,
    required this.assetCount,
  });

  final String? assetPath;
  final int locationCount;
  final int assetCount;

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
                'Location / Bin Map',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'See where things are parked so equipment and parts stay easy to find without making the page feel busy.',
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
              _InfoChip(label: '$locationCount bins'),
              _InfoChip(label: '$assetCount assets referenced'),
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
                child: Align(alignment: Alignment.topRight, child: chips),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BinMapSummaryRow extends StatelessWidget {
  const _BinMapSummaryRow({
    required this.locationCount,
    required this.assetCount,
    required this.photoLinkedCount,
    required this.noteLinkedCount,
  });

  final int locationCount;
  final int assetCount;
  final int photoLinkedCount;
  final int noteLinkedCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final cards = [
          _MetricCard(
            label: 'Bins',
            value: locationCount,
            accent: AppColours.darkSecondary,
          ),
          _MetricCard(
            label: 'Assets referenced',
            value: assetCount,
            accent: AppColours.darkSuccess,
          ),
          _MetricCard(
            label: 'Photo links',
            value: photoLinkedCount,
            accent: AppColours.darkPurple,
          ),
          _MetricCard(
            label: 'Note links',
            value: noteLinkedCount,
            accent: AppColours.darkAmber,
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
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          );
        }

        return Column(
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              cards[index],
              if (index != cards.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _BinMapActionStrip extends StatelessWidget {
  const _BinMapActionStrip({
    required this.onOpenLocationRegister,
    required this.onOpenEvidenceLibrary,
    required this.onOpenEquipmentRegister,
  });

  final VoidCallback onOpenLocationRegister;
  final VoidCallback onOpenEvidenceLibrary;
  final VoidCallback onOpenEquipmentRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 860;
          final actions = [
            FilledButton.icon(
              onPressed: onOpenLocationRegister,
              icon: const Icon(Icons.place_outlined),
              label: const Text('Open Location Register'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenEvidenceLibrary,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Open Evidence Library'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenEquipmentRegister,
              icon: const Icon(Icons.precision_manufacturing_outlined),
              label: const Text('Open Equipment'),
            ),
          ];

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: AppColours.darkSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Quick links',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Use these when you want to review the source register or jump back to the evidence that supports each bin.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 14),
                Wrap(spacing: 10, runSpacing: 10, children: actions),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 16),
              SizedBox(
                width: 520,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(spacing: 10, runSpacing: 10, children: actions),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BinGroupCard extends StatelessWidget {
  const _BinGroupCard({required this.group});

  final _BinGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhotoLink = group.photoLinkedCount > 0;
    final hasNotes = group.noteLinkedCount > 0;
    final accent = hasPhotoLink
        ? AppColours.darkSuccess
        : AppColours.darkSecondary;

    return Container(
      padding: const EdgeInsets.all(18),
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
                  group.locationName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(
                label: group.assetIds.length == 1
                    ? '1 asset'
                    : '${group.assetIds.length} assets',
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Photo ${group.photoLinkedCount}'),
              _InfoChip(label: 'Notes ${group.noteLinkedCount}'),
              _InfoChip(label: hasPhotoLink ? 'Photo linked' : 'No photo link'),
              _InfoChip(label: hasNotes ? 'Notes linked' : 'No notes'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final assetId in group.assetIds.take(6))
                _InfoChip(label: assetId),
              if (group.assetIds.length > 6)
                _InfoChip(label: '+${group.assetIds.length - 6} more'),
            ],
          ),
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              group.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          if (group.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              group.notes,
              style: theme.textTheme.bodyMedium?.copyWith(
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

class _EmptyBinMapState extends StatelessWidget {
  const _EmptyBinMapState({required this.onOpenLocationRegister});

  final VoidCallback onOpenLocationRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(title: 'No bins yet', icon: Icons.map_outlined),
          const SizedBox(height: 10),
          Text(
            'Add a few locations first and the map will start to feel useful very quickly.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onOpenLocationRegister,
            icon: const Icon(Icons.place_outlined),
            label: const Text('Open Location Register'),
          ),
        ],
      ),
    );
  }
}

class _BinMapFooter extends StatelessWidget {
  const _BinMapFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColours.darkSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Keep the map calm and linked to real labels so bins stay easy to review later.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class _BinGroup {
  const _BinGroup({
    required this.locationName,
    required this.assetIds,
    required this.photoLinkedCount,
    required this.noteLinkedCount,
    required this.description,
    required this.notes,
  });

  final String locationName;
  final List<String> assetIds;
  final int photoLinkedCount;
  final int noteLinkedCount;
  final String description;
  final String notes;
}

List<_BinGroup> _groupLocations(List<Map<String, String>> rows) {
  final grouped = <String, List<Map<String, String>>>{};
  for (final row in rows) {
    final locationName = (row['location_name'] ?? '').trim().isNotEmpty
        ? row['location_name']!.trim()
        : 'Unnamed location';
    grouped.putIfAbsent(locationName, () => <Map<String, String>>[]).add(row);
  }

  final groups =
      grouped.entries.map((entry) {
        final locationRows = entry.value;
        final assetIds = <String>[];
        var photoLinkedCount = 0;
        var noteLinkedCount = 0;
        final descriptions = <String>{};
        final notes = <String>{};

        for (final row in locationRows) {
          final assetId = (row['asset_id'] ?? '').trim();
          if (assetId.isNotEmpty) {
            assetIds.add(assetId);
          }
          if ((row['photo_link'] ?? '').trim().isNotEmpty) {
            photoLinkedCount += 1;
          }
          if ((row['notes'] ?? '').trim().isNotEmpty) {
            noteLinkedCount += 1;
            notes.add(row['notes']!.trim());
          }
          if ((row['description'] ?? '').trim().isNotEmpty) {
            descriptions.add(row['description']!.trim());
          }
        }

        assetIds.sort();
        final description = descriptions.isEmpty
            ? ''
            : descriptions.join(' • ');
        final notesText = notes.isEmpty ? '' : notes.join(' • ');

        return _BinGroup(
          locationName: entry.key,
          assetIds: assetIds,
          photoLinkedCount: photoLinkedCount,
          noteLinkedCount: noteLinkedCount,
          description: description,
          notes: notesText,
        );
      }).toList()..sort((a, b) {
        final countCompare = b.assetIds.length.compareTo(a.assetIds.length);
        if (countCompare != 0) {
          return countCompare;
        }
        return a.locationName.toLowerCase().compareTo(
          b.locationName.toLowerCase(),
        );
      });

  return groups;
}

int _distinctAssetCount(List<Map<String, String>> rows) {
  final assetIds = <String>{};
  for (final row in rows) {
    final assetId = (row['asset_id'] ?? '').trim();
    if (assetId.isNotEmpty) {
      assetIds.add(assetId);
    }
  }
  return assetIds.length;
}

int _countWithValue(List<Map<String, String>> rows, String key) {
  var count = 0;
  for (final row in rows) {
    if ((row[key] ?? '').trim().isNotEmpty) {
      count += 1;
    }
  }
  return count;
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
            '$value',
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

class _BinMapError extends StatelessWidget {
  const _BinMapError({required this.onReload});

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
                'Bin map could not load right now.',
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

BoxDecoration _panelDecoration(
  BuildContext context, {
  bool highlighted = false,
}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurface.withValues(alpha: 0.95)
        : AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
