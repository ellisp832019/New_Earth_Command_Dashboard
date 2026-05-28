import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class LocationRegisterScreen extends ConsumerStatefulWidget {
  const LocationRegisterScreen({super.key});

  @override
  ConsumerState<LocationRegisterScreen> createState() =>
      _LocationRegisterScreenState();
}

class _LocationRegisterScreenState extends ConsumerState<LocationRegisterScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final locations = ref.watch(assetLocationRegisterProvider);

    return workspace.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _LocationRegisterError(
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return locations.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _LocationRegisterError(
            onReload: () => ref.invalidate(assetLocationRegisterProvider),
          ),
          data: (table) {
            final uniqueAssets = _distinctValues(table.rows, 'asset_id');
            final uniqueLocations = _distinctValues(table.rows, 'location_name');
            final photoLinkedCount = _countWithValue(table.rows, 'photo_link');

            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: _isSaving || workspaceData.assetsRootPath == null
                    ? null
                    : () => _addRecord(workspaceData.assetsRootPath!),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_isSaving ? 'Saving' : 'Add Location'),
              ),
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LocationHeader(
                              assetPath: workspaceData.assetsRootPath,
                              locationCount: table.rows.length,
                              uniqueAssets: uniqueAssets.length,
                            ),
                            const SizedBox(height: 20),
                            _LocationSummaryRow(
                              locationCount: table.rows.length,
                              uniqueAssets: uniqueAssets.length,
                              uniqueLocations: uniqueLocations.length,
                              photoLinkedCount: photoLinkedCount,
                            ),
                            const SizedBox(height: 20),
                            if (table.rows.isEmpty)
                              _EmptyLocationState(
                                onAdd: workspaceData.assetsRootPath == null
                                    ? null
                                    : () => _addRecord(workspaceData.assetsRootPath!),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: table.rows.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _LocationCard(row: table.rows[index]);
                                },
                              ),
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

  Future<void> _addRecord(String assetsRootPath) async {
    if (_isSaving) {
      return;
    }

    final draft = await showDialog<_LocationDraft>(
      context: context,
      builder: (context) => const _LocationDialog(),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(assetRegisterRepositoryProvider).appendLocationRecord(
            assetsRootPath,
            draft.toRow(),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(assetLocationRegisterProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location saved.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({
    required this.assetPath,
    required this.locationCount,
    required this.uniqueAssets,
  });

  final String? assetPath;
  final int locationCount;
  final int uniqueAssets;

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
                'Location Register',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep the friendly location list clear so equipment and parts are easy to find later.',
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
              _InfoChip(label: '$locationCount locations'),
              _InfoChip(label: '$uniqueAssets assets referenced'),
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

class _LocationSummaryRow extends StatelessWidget {
  const _LocationSummaryRow({
    required this.locationCount,
    required this.uniqueAssets,
    required this.uniqueLocations,
    required this.photoLinkedCount,
  });

  final int locationCount;
  final int uniqueAssets;
  final int uniqueLocations;
  final int photoLinkedCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final cards = [
          _MetricCard(
            label: 'Locations',
            value: locationCount,
            accent: AppColours.darkSecondary,
          ),
          _MetricCard(
            label: 'Assets referenced',
            value: uniqueAssets,
            accent: AppColours.darkSuccess,
          ),
          _MetricCard(
            label: 'Named locations',
            value: uniqueLocations,
            accent: AppColours.darkAmber,
          ),
          _MetricCard(
            label: 'Photo links',
            value: photoLinkedCount,
            accent: AppColours.darkPurple,
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.row});

  final Map<String, String> row;

  @override
  Widget build(BuildContext context) {
    final assetId = row['asset_id']?.trim().isNotEmpty == true
        ? row['asset_id']!.trim()
        : 'No asset ID';
    final locationName = row['location_name']?.trim().isNotEmpty == true
        ? row['location_name']!.trim()
        : 'Unnamed location';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  locationName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _StatusPill(label: assetId, accent: AppColours.darkSecondary),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: row['description'] ?? 'No description'),
              _InfoChip(label: row['photo_link']?.trim().isNotEmpty == true ? 'Photo linked' : 'No photo link'),
            ],
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

class _EmptyLocationState extends StatelessWidget {
  const _EmptyLocationState({required this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'No locations yet',
            icon: Icons.place_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Add a friendly location so items are easier to find and keep tidy.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Location'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationRegisterError extends StatelessWidget {
  const _LocationRegisterError({required this.onReload});

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
                'Location register could not load right now.',
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

class _LocationDialog extends StatefulWidget {
  const _LocationDialog();

  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  late final TextEditingController _assetIdController;
  late final TextEditingController _locationNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _photoLinkController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _assetIdController = TextEditingController();
    _locationNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _photoLinkController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _assetIdController.dispose();
    _locationNameController.dispose();
    _descriptionController.dispose();
    _photoLinkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Location'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _assetIdController,
              decoration: const InputDecoration(labelText: 'Asset ID'),
            ),
            TextField(
              controller: _locationNameController,
              decoration: const InputDecoration(labelText: 'Location name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _photoLinkController,
              decoration: const InputDecoration(labelText: 'Photo link'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _LocationDraft(
                assetId: _assetIdController.text.trim(),
                locationName: _locationNameController.text.trim(),
                description: _descriptionController.text.trim(),
                photoLink: _photoLinkController.text.trim(),
                notes: _notesController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _LocationDraft {
  const _LocationDraft({
    required this.assetId,
    required this.locationName,
    required this.description,
    required this.photoLink,
    required this.notes,
  });

  final String assetId;
  final String locationName;
  final String description;
  final String photoLink;
  final String notes;

  Map<String, String> toRow() {
    return {
      'asset_id': assetId,
      'location_name': locationName,
      'description': description,
      'photo_link': photoLink,
      'notes': notes,
    };
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

List<String> _distinctValues(List<Map<String, String>> rows, String key) {
  final values = <String>{};
  for (final row in rows) {
    final value = (row[key] ?? '').trim();
    if (value.isNotEmpty) {
      values.add(value);
    }
  }
  return values.toList(growable: false);
}

int _countWithValue(List<Map<String, String>> rows, String key) {
  return rows.where((row) => (row[key] ?? '').trim().isNotEmpty).length;
}
