import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class ScanLookupScreen extends ConsumerStatefulWidget {
  const ScanLookupScreen({super.key});

  @override
  ConsumerState<ScanLookupScreen> createState() => _ScanLookupScreenState();
}

class _ScanLookupScreenState extends ConsumerState<ScanLookupScreen> {
  final TextEditingController _scanController = TextEditingController();
  String? _lastLookup;
  ScanLookupMatch? _bestMatch;

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipmentAsync = ref.watch(assetEquipmentRegisterProvider);
    final partsAsync = ref.watch(assetPartsRegisterProvider);
    final labelsAsync = ref.watch(assetQrLabelTemplateRegisterProvider);

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
                    _HeroCard(
                      onBackToStudio: () =>
                          context.go(RouteNames.assetQrLabelStudio),
                      onBackToAssets: () => context.go(RouteNames.assets),
                      onSearch: _runLookup,
                      controller: _scanController,
                    ),
                    const SizedBox(height: 20),
                    equipmentAsync.when(
                      loading: () => const _LoadingCard(label: 'Equipment'),
                      error: (error, stackTrace) => _ErrorCard(
                        label: 'Equipment',
                        onReload: () =>
                            ref.invalidate(assetEquipmentRegisterProvider),
                      ),
                      data: (equipment) {
                        return partsAsync.when(
                          loading: () =>
                              const _LoadingCard(label: 'Parts'),
                          error: (error, stackTrace) => _ErrorCard(
                            label: 'Parts',
                            onReload: () =>
                                ref.invalidate(assetPartsRegisterProvider),
                          ),
                          data: (parts) {
                            return labelsAsync.when(
                              loading: () =>
                                  const _LoadingCard(label: 'QR Labels'),
                              error: (error, stackTrace) => _ErrorCard(
                                label: 'QR Labels',
                                onReload: () => ref.invalidate(
                                  assetQrLabelTemplateRegisterProvider,
                                ),
                              ),
                              data: (labels) {
                                final matches = _buildMatches(
                                  _scanController.text,
                                  equipment.rows,
                                  parts.rows,
                                  labels.rows,
                                );
                                _maybeSetBestMatch(matches);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _LookupSummary(
                                      lookupText: _lastLookup,
                                      bestMatch: _bestMatch,
                                      onOpenBestMatch: _openBestMatch,
                                    ),
                                    const SizedBox(height: 20),
                                    _ResultsCard(matches: matches),
                                  ],
                                );
                              },
                            );
                          },
                        );
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
  }

  void _runLookup() {
    setState(() {
      _lastLookup = _scanController.text.trim();
      _bestMatch = null;
    });
  }

  void _maybeSetBestMatch(List<ScanLookupMatch> matches) {
    if (_lastLookup == null || _lastLookup!.isEmpty) {
      return;
    }
    if (_bestMatch != null) {
      return;
    }
    final exactEquipment = matches.firstWhere(
      (match) => match.kind == ScanLookupKind.equipment && match.isExact,
      orElse: () => const ScanLookupMatch.none(),
    );
    final exactPart = matches.firstWhere(
      (match) => match.kind == ScanLookupKind.part && match.isExact,
      orElse: () => const ScanLookupMatch.none(),
    );
    final fallback = matches.isNotEmpty ? matches.first : const ScanLookupMatch.none();
    final selected = exactEquipment.isPresent
        ? exactEquipment
        : exactPart.isPresent
        ? exactPart
        : fallback.isPresent
        ? fallback
        : const ScanLookupMatch.none();

    if (selected.isPresent) {
      _bestMatch = selected;
    }
  }

  Future<void> _openBestMatch() async {
    final match = _bestMatch;
    if (match == null || !match.isPresent) {
      return;
    }

    switch (match.kind) {
      case ScanLookupKind.equipment:
        context.push(
          Uri(
            path: RouteNames.assetEquipment,
            queryParameters: {'assetId': match.primaryId},
          ).toString(),
        );
        break;
      case ScanLookupKind.part:
        context.push(
          Uri(
            path: RouteNames.assetParts,
            queryParameters: {'q': match.primaryId},
          ).toString(),
        );
        break;
      case ScanLookupKind.label:
        context.go(RouteNames.assetQrLabelRegister);
        break;
      case ScanLookupKind.none:
        break;
    }
  }

  List<ScanLookupMatch> _buildMatches(
    String query,
    List<Map<String, String>> equipmentRows,
    List<Map<String, String>> partsRows,
    List<Map<String, String>> labelRows,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const <ScanLookupMatch>[];
    }

    final matches = <ScanLookupMatch>[];

    for (final row in equipmentRows) {
      final assetId = (row['asset_id'] ?? '').trim();
      if (assetId.isEmpty) {
        continue;
      }

      final haystack = [
        row['asset_id'],
        row['name'],
        row['type'],
        row['project'],
        row['location'],
        row['notes'],
      ].whereType<String>().join(' ').toLowerCase();
      if (haystack.contains(normalized)) {
        matches.add(
          ScanLookupMatch.equipment(
            primaryId: assetId,
            title: row['name']?.trim().isNotEmpty == true
                ? row['name']!.trim()
                : assetId,
            subtitle: row['location']?.trim().isNotEmpty == true
                ? row['location']!.trim()
                : (row['project'] ?? '').trim(),
            isExact: assetId.toLowerCase() == normalized,
          ),
        );
      }
    }

    for (final row in partsRows) {
      final partId = (row['part_id'] ?? '').trim();
      if (partId.isEmpty) {
        continue;
      }

      final haystack = [
        row['part_id'],
        row['name'],
        row['category'],
        row['project'],
        row['location'],
        row['supplier'],
        row['notes'],
      ].whereType<String>().join(' ').toLowerCase();
      if (haystack.contains(normalized)) {
        matches.add(
          ScanLookupMatch.part(
            primaryId: partId,
            title: row['name']?.trim().isNotEmpty == true
                ? row['name']!.trim()
                : partId,
            subtitle: row['category']?.trim().isNotEmpty == true
                ? row['category']!.trim()
                : (row['project'] ?? '').trim(),
            isExact: partId.toLowerCase() == normalized,
          ),
        );
      }
    }

    for (final row in labelRows) {
      final assetId = (row['asset_id'] ?? '').trim();
      if (assetId.isEmpty) {
        continue;
      }

      final haystack = [
        row['label_id'],
        row['asset_id'],
        row['label_type'],
        row['label_text'],
        row['location'],
        row['notes'],
      ].whereType<String>().join(' ').toLowerCase();
      if (haystack.contains(normalized)) {
        matches.add(
          ScanLookupMatch.label(
            primaryId: assetId,
            title: row['label_text']?.trim().isNotEmpty == true
                ? row['label_text']!.trim()
                : assetId,
            subtitle: row['label_type']?.trim().isNotEmpty == true
                ? row['label_type']!.trim()
                : 'QR label',
            isExact: assetId.toLowerCase() == normalized,
          ),
        );
      }
    }

    return matches;
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.onBackToStudio,
    required this.onBackToAssets,
    required this.onSearch,
    required this.controller,
  });

  final VoidCallback onBackToStudio;
  final VoidCallback onBackToAssets;
  final VoidCallback onSearch;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan Lookup',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paste or type a QR value, then jump straight to the matching asset, part, or label record.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: onBackToStudio,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Back to Studio'),
              ),
              OutlinedButton.icon(
                onPressed: onBackToAssets,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Assets'),
              ),
              TextButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search),
                label: const Text('Lookup'),
              ),
            ],
          );

          final field = TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onChanged: (_) => onSearch(),
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              labelText: 'Enter scanned code',
              hintText: 'NE-EQ-0001',
              prefixIcon: const Icon(Icons.qr_code_scanner_outlined),
              suffixIcon: IconButton(
                onPressed: onSearch,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 16),
                field,
                const SizedBox(height: 16),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 14), field],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(width: 360, child: Align(alignment: Alignment.topRight, child: actions)),
            ],
          );
        },
      ),
    );
  }
}

class _LookupSummary extends StatelessWidget {
  const _LookupSummary({
    required this.lookupText,
    required this.bestMatch,
    required this.onOpenBestMatch,
  });

  final String? lookupText;
  final ScanLookupMatch? bestMatch;
  final VoidCallback onOpenBestMatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(title: 'Lookup result', icon: Icons.search),
          const SizedBox(height: 10),
          Text(
            lookupText == null || lookupText!.isEmpty
                ? 'Paste a QR payload to begin.'
                : 'Searching for "$lookupText".',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
          ),
          const SizedBox(height: 12),
          if (bestMatch == null || !bestMatch!.isPresent)
            Text(
              'No exact match yet. Check the results below or try a different code.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkAmber,
                    fontWeight: FontWeight.w600,
                  ),
            )
          else ...[
            _MatchBadge(match: bestMatch!),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onOpenBestMatch,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open best match'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.matches});

  final List<ScanLookupMatch> matches;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PanelTitle(title: 'Matches', icon: Icons.view_list_outlined),
              const Spacer(),
              _InlineBadge(count: matches.length, accent: AppColours.darkSecondary),
            ],
          ),
          const SizedBox(height: 10),
          if (matches.isEmpty)
            Text(
              'No matches yet. Try scanning a different code or paste a full asset ID.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
            )
          else
            Column(
              children: [
                for (final match in matches.take(12))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MatchCard(match: match),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final ScanLookupMatch match;

  @override
  Widget build(BuildContext context) {
    final accent = switch (match.kind) {
      ScanLookupKind.equipment => AppColours.darkSuccess,
      ScanLookupKind.part => AppColours.darkSecondary,
      ScanLookupKind.label => AppColours.darkAmber,
      ScanLookupKind.none => AppColours.darkMutedText,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  match.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  match.primaryId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          _InlineBadge(
            count: 1,
            accent: accent,
            label: match.kind.name,
          ),
        ],
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.match});

  final ScanLookupMatch match;

  @override
  Widget build(BuildContext context) {
    final accent = switch (match.kind) {
      ScanLookupKind.equipment => AppColours.darkSuccess,
      ScanLookupKind.part => AppColours.darkSecondary,
      ScanLookupKind.label => AppColours.darkAmber,
      ScanLookupKind.none => AppColours.darkMutedText,
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _InlineBadge(count: 1, accent: accent, label: match.kind.name),
        _InlineBadge(count: 1, accent: AppColours.darkSecondary, label: match.primaryId),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text('Loading $label...'),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.label, required this.onReload});

  final String label;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Row(
        children: [
          Text('$label could not load right now.'),
          const Spacer(),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
            label: const Text('Reload'),
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
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({
    required this.count,
    required this.accent,
    this.label,
  });

  final int count;
  final Color accent;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Text(
        label ?? '$count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class ScanLookupMatch {
  const ScanLookupMatch({
    required this.kind,
    required this.primaryId,
    required this.title,
    required this.subtitle,
    required this.isExact,
  });

  const ScanLookupMatch.none()
      : kind = ScanLookupKind.none,
        primaryId = '',
        title = '',
        subtitle = '',
        isExact = false;

  factory ScanLookupMatch.equipment({
    required String primaryId,
    required String title,
    required String subtitle,
    required bool isExact,
  }) {
    return ScanLookupMatch(
      kind: ScanLookupKind.equipment,
      primaryId: primaryId,
      title: title,
      subtitle: subtitle,
      isExact: isExact,
    );
  }

  factory ScanLookupMatch.part({
    required String primaryId,
    required String title,
    required String subtitle,
    required bool isExact,
  }) {
    return ScanLookupMatch(
      kind: ScanLookupKind.part,
      primaryId: primaryId,
      title: title,
      subtitle: subtitle,
      isExact: isExact,
    );
  }

  factory ScanLookupMatch.label({
    required String primaryId,
    required String title,
    required String subtitle,
    required bool isExact,
  }) {
    return ScanLookupMatch(
      kind: ScanLookupKind.label,
      primaryId: primaryId,
      title: title,
      subtitle: subtitle,
      isExact: isExact,
    );
  }

  final ScanLookupKind kind;
  final String primaryId;
  final String title;
  final String subtitle;
  final bool isExact;

  bool get isPresent => kind != ScanLookupKind.none;
}

enum ScanLookupKind { none, equipment, part, label }

BoxDecoration _panelDecoration(
  BuildContext context, {
  bool highlighted = false,
}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurfaceAlt.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.93),
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
