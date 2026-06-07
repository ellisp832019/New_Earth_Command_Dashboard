import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class QrPrintQueueScreen extends ConsumerWidget {
  const QrPrintQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(assetWorkspaceProvider);
    final queueAsync = ref.watch(assetQrPrintQueueProvider);

    return workspaceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _ErrorState(
        message: 'The asset folder is not ready for the print queue yet.',
        onBack: () => context.go(RouteNames.assets),
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspace) {
        return queueAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _ErrorState(
            message: 'The print queue could not load right now.',
            onBack: () => context.go(RouteNames.assetQrLabelStudio),
            onReload: () => ref.invalidate(assetQrPrintQueueProvider),
          ),
          data: (table) {
            final readyRows = _rowsByStatus(table.rows, {
              'generated',
              'queued',
            });
            final retryRows = _rowsByStatus(table.rows, {'reprint_needed'});
            final printedRows = _rowsByStatus(table.rows, {'printed'});
            final appliedRows = _rowsByStatus(table.rows, {'applied'});

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
                              onBackToAssets: () =>
                                  context.go(RouteNames.assets),
                              onOpenHistory: () =>
                                  context.push(RouteNames.assetQrLabelHistory),
                              onRefresh: () =>
                                  ref.invalidate(assetQrPrintQueueProvider),
                              readyCount: readyRows.length,
                              retryCount: retryRows.length,
                              printedCount: printedRows.length,
                              appliedCount: appliedRows.length,
                              onExportReadyQueue: () => _exportReadyQueue(
                                context,
                                ref,
                                workspace.assetsRootPath!,
                              ),
                              onPrintReadyQueue: () => _printReadyQueue(
                                context,
                                ref,
                                workspace.assetsRootPath!,
                              ),
                              workspacePath: workspace.assetsRootPath,
                            ),
                            const SizedBox(height: 20),
                            _QueueSection(
                              title: 'Ready to print',
                              subtitle:
                                  'Labels waiting for the PM260 or the Windows print dialog.',
                              rows: readyRows,
                              accent: AppColours.darkSuccess,
                              onMarkPrinted: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'printed',
                              ),
                              onMarkApplied: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'applied',
                              ),
                              onMarkReprintNeeded: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'reprint_needed',
                              ),
                              onOpenManifest: (queueId) =>
                                  _openManifest(context, queueId, readyRows),
                            ),
                            const SizedBox(height: 20),
                            _QueueSection(
                              title: 'Failed / retry',
                              subtitle:
                                  'Labels that need another calm attempt after a printer or paper issue.',
                              rows: retryRows,
                              accent: const Color(0xFFE26B6B),
                              onMarkPrinted: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'printed',
                              ),
                              onMarkApplied: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'applied',
                              ),
                              onMarkReprintNeeded: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'reprint_needed',
                              ),
                              onOpenManifest: (queueId) =>
                                  _openManifest(context, queueId, retryRows),
                              onRetry: (queueId) => _retryQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                              ),
                              showRetryButton: true,
                            ),
                            const SizedBox(height: 20),
                            _QueueSection(
                              title: 'Printed, needs applying',
                              subtitle:
                                  'Printed labels that still need to be placed on the asset or bin.',
                              rows: printedRows,
                              accent: AppColours.darkAmber,
                              onMarkPrinted: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'printed',
                              ),
                              onMarkApplied: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'applied',
                              ),
                              onMarkReprintNeeded: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'reprint_needed',
                              ),
                              onOpenManifest: (queueId) =>
                                  _openManifest(context, queueId, printedRows),
                            ),
                            const SizedBox(height: 20),
                            _QueueSection(
                              title: 'Applied',
                              subtitle:
                                  'Labels already placed on the physical item.',
                              rows: appliedRows,
                              accent: AppColours.darkSecondary,
                              onMarkPrinted: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'printed',
                              ),
                              onMarkApplied: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'applied',
                              ),
                              onMarkReprintNeeded: (queueId) => _markQueue(
                                ref,
                                workspace.assetsRootPath!,
                                queueId,
                                'reprint_needed',
                              ),
                              onOpenManifest: (queueId) =>
                                  _openManifest(context, queueId, appliedRows),
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

  Future<void> _markQueue(
    WidgetRef ref,
    String assetsRootPath,
    String queueId,
    String status,
  ) async {
    final service = ref.read(assetQrLabelPrintServiceProvider);
    switch (status) {
      case 'printed':
        await service.markQueuePrinted(assetsRootPath, queueId);
        break;
      case 'applied':
        await service.markQueueApplied(assetsRootPath, queueId);
        break;
      case 'reprint_needed':
        await service.markQueueReprintNeeded(assetsRootPath, queueId);
        break;
    }

    ref.invalidate(assetQrPrintQueueProvider);
  }

  Future<void> _retryQueue(
    WidgetRef ref,
    String assetsRootPath,
    String queueId,
  ) async {
    final service = ref.read(assetQrLabelPrintServiceProvider);
    await service.markQueueQueued(assetsRootPath, queueId);
    ref.invalidate(assetQrPrintQueueProvider);
  }

  Future<void> _exportReadyQueue(
    BuildContext context,
    WidgetRef ref,
    String assetsRootPath,
  ) async {
    final service = ref.read(assetQrLabelPrintServiceProvider);
    final file = await service.exportReadyQueueCsv(assetsRootPath);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported ready queue CSV to ${file.path}')),
    );
  }

  Future<void> _printReadyQueue(
    BuildContext context,
    WidgetRef ref,
    String assetsRootPath,
  ) async {
    final service = ref.read(assetQrLabelPrintServiceProvider);
    final bytes = await service.buildReadyQueuePdfBytes(assetsRootPath);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opened ready queue print layout.')),
    );
  }

  List<Map<String, String>> _rowsByStatus(
    List<Map<String, String>> rows,
    Set<String> statuses,
  ) {
    return rows
        .where((row) {
          final status = (row['status'] ?? '').trim().toLowerCase();
          return statuses.contains(status);
        })
        .toList(growable: false);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.onBackToStudio,
    required this.onBackToAssets,
    required this.onOpenHistory,
    required this.onRefresh,
    required this.readyCount,
    required this.retryCount,
    required this.printedCount,
    required this.appliedCount,
    required this.onExportReadyQueue,
    required this.onPrintReadyQueue,
    required this.workspacePath,
  });

  final VoidCallback onBackToStudio;
  final VoidCallback onBackToAssets;
  final VoidCallback onOpenHistory;
  final VoidCallback onRefresh;
  final int readyCount;
  final int retryCount;
  final int printedCount;
  final int appliedCount;
  final VoidCallback onExportReadyQueue;
  final VoidCallback onPrintReadyQueue;
  final String? workspacePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
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
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              OutlinedButton.icon(
                onPressed: onExportReadyQueue,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export ready'),
              ),
              OutlinedButton.icon(
                onPressed: onPrintReadyQueue,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print ready'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenHistory,
                icon: const Icon(Icons.history_outlined),
                label: const Text('Open History'),
              ),
            ],
          );

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Print Queue',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep labels calm and trackable while they move from generated to printed and applied.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                workspacePath ?? 'Asset folder not linked',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InlineBadge(
                    count: readyCount,
                    accent: AppColours.darkSuccess,
                    label: 'Ready',
                  ),
                  _InlineBadge(
                    count: retryCount,
                    accent: const Color(0xFFE26B6B),
                    label: 'Retry',
                  ),
                  _InlineBadge(
                    count: printedCount,
                    accent: AppColours.darkAmber,
                    label: 'Printed',
                  ),
                  _InlineBadge(
                    count: appliedCount,
                    accent: AppColours.darkSecondary,
                    label: 'Applied',
                  ),
                ],
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(
                width: 360,
                child: Align(alignment: Alignment.topRight, child: actions),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QueueSection extends StatelessWidget {
  const _QueueSection({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.accent,
    required this.onMarkPrinted,
    required this.onMarkApplied,
    required this.onMarkReprintNeeded,
    required this.onOpenManifest,
    this.onRetry,
    this.showRetryButton = false,
  });

  final String title;
  final String subtitle;
  final List<Map<String, String>> rows;
  final Color accent;
  final Future<void> Function(String queueId) onMarkPrinted;
  final Future<void> Function(String queueId) onMarkApplied;
  final Future<void> Function(String queueId) onMarkReprintNeeded;
  final Future<void> Function(String queueId) onOpenManifest;
  final Future<void> Function(String queueId)? onRetry;
  final bool showRetryButton;

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
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _InlineBadge(count: rows.length, accent: accent),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            Text(
              'Nothing here yet.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Column(
              children: [
                for (final row in rows.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _QueueItemCard(
                      row: row,
                      onMarkPrinted: () => onMarkPrinted(row['queue_id'] ?? ''),
                      onMarkApplied: () => onMarkApplied(row['queue_id'] ?? ''),
                      onMarkReprintNeeded: () =>
                          onMarkReprintNeeded(row['queue_id'] ?? ''),
                      onOpenManifest: () =>
                          onOpenManifest(row['queue_id'] ?? ''),
                      onRetry: showRetryButton && onRetry != null
                          ? () => onRetry!(row['queue_id'] ?? '')
                          : null,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _QueueItemCard extends StatelessWidget {
  const _QueueItemCard({
    required this.row,
    required this.onMarkPrinted,
    required this.onMarkApplied,
    required this.onMarkReprintNeeded,
    required this.onOpenManifest,
    required this.onRetry,
  });

  final Map<String, String> row;
  final VoidCallback onMarkPrinted;
  final VoidCallback onMarkApplied;
  final VoidCallback onMarkReprintNeeded;
  final VoidCallback onOpenManifest;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? '').trim().toLowerCase();
    final accent = _statusAccent(status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row['asset_id'] ?? 'Unknown asset',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _InlineBadge(count: 1, accent: accent, label: status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${row['label_type'] ?? ''} | ${row['label_size'] ?? ''} | ${path.basename(row['generated_file'] ?? '')}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onRetry != null)
                TextButton(onPressed: onRetry, child: const Text('Retry now')),
              TextButton(
                onPressed: onOpenManifest,
                child: const Text('Open manifest'),
              ),
              TextButton(
                onPressed: onMarkPrinted,
                child: const Text('Mark printed'),
              ),
              TextButton(
                onPressed: onMarkApplied,
                child: const Text('Mark applied'),
              ),
              TextButton(
                onPressed: onMarkReprintNeeded,
                child: const Text('Reprint'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({required this.count, required this.accent, this.label});

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

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onBack,
    required this.onReload,
  });

  final String message;
  final VoidCallback onBack;
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
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                  TextButton.icon(
                    onPressed: onReload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reload'),
                  ),
                ],
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

Color _statusAccent(String status) {
  switch (status) {
    case 'printed':
      return AppColours.darkAmber;
    case 'applied':
      return AppColours.darkSuccess;
    case 'reprint_needed':
      return const Color(0xFFE26B6B);
    default:
      return AppColours.darkSecondary;
  }
}

Future<void> _openManifest(
  BuildContext context,
  String queueId,
  List<Map<String, String>> rows,
) async {
  final row = rows.firstWhere(
    (item) => (item['queue_id'] ?? '').trim() == queueId.trim(),
    orElse: () => const <String, String>{},
  );
  final manifestPath = (row['manifest_file'] ?? '').trim();
  if (manifestPath.isEmpty) {
    return;
  }

  final manifestFile = File(manifestPath);
  if (!await manifestFile.exists()) {
    return;
  }

  if (Platform.isWindows) {
    await Process.start('cmd.exe', ['/c', 'start', '', manifestFile.path]);
  } else if (Platform.isMacOS) {
    await Process.start('open', [manifestFile.path]);
  } else {
    await Process.start('xdg-open', [manifestFile.path]);
  }

  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Opened manifest for ${path.basename(manifestFile.path)}'),
    ),
  );
}
