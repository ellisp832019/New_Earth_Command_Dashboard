import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class QrLabelHistoryScreen extends ConsumerWidget {
  const QrLabelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(assetWorkspaceProvider);
    final labelsAsync = ref.watch(assetQrLabelTemplateRegisterProvider);
    final queueAsync = ref.watch(assetQrPrintQueueProvider);

    return workspaceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _HistoryError(
        message: 'The asset workspace is not ready for label history yet.',
        onBack: () => context.go(RouteNames.assets),
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspace) {
        return labelsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _HistoryError(
            message: 'The label register could not load right now.',
            onBack: () => context.go(RouteNames.assetQrLabelRegister),
            onReload: () =>
                ref.invalidate(assetQrLabelTemplateRegisterProvider),
          ),
          data: (labelTable) {
            return queueAsync.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _HistoryError(
                message: 'The print queue could not load right now.',
                onBack: () => context.go(RouteNames.assetQrLabelStudio),
                onReload: () => ref.invalidate(assetQrPrintQueueProvider),
              ),
              data: (queueTable) {
                final labels = _sortedLabelRows(labelTable.rows);
                final retryRows = _rowsByStatus(queueTable.rows, {
                  'reprint_needed',
                });
                final printedRows = _rowsByStatus(queueTable.rows, {'printed'});
                final appliedRows = _rowsByStatus(queueTable.rows, {'applied'});
                final recentCount = math.min(labels.length, 12);

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
                                _HistoryHero(
                                  workspacePath: workspace.assetsRootPath,
                                  labelCount: labels.length,
                                  printedCount: printedRows.length,
                                  appliedCount: appliedRows.length,
                                  retryCount: retryRows.length,
                                  onBackToAssets: () =>
                                      context.go(RouteNames.assets),
                                  onBackToStudio: () =>
                                      context.go(RouteNames.assetQrLabelStudio),
                                  onBackToRegister: () => context.go(
                                    RouteNames.assetQrLabelRegister,
                                  ),
                                  onOpenQueue: () => context.push(
                                    RouteNames.assetQrPrintQueue,
                                  ),
                                  onRefresh: () {
                                    ref.invalidate(
                                      assetQrLabelTemplateRegisterProvider,
                                    );
                                    ref.invalidate(assetQrPrintQueueProvider);
                                  },
                                ),
                                const SizedBox(height: 20),
                                _HistoryExportCard(
                                  onExportRecent: () => _exportRecentHistory(
                                    context,
                                    ref,
                                    workspace.assetsRootPath!,
                                  ),
                                  onPrintRecent: () => _printRecentHistory(
                                    context,
                                    ref,
                                    workspace.assetsRootPath!,
                                  ),
                                  onOpenExportFolder: () => _openExportFolder(
                                    workspace.assetsRootPath!,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _HistorySection(
                                  title: 'Recent label records',
                                  subtitle:
                                      'The calm audit trail for generated labels, printed status, and applied status.',
                                  rows: labels
                                      .take(recentCount)
                                      .toList(growable: false),
                                  accent: AppColours.darkSecondary,
                                  emptyText: 'No label records yet.',
                                  itemBuilder: (row) => _LabelRecordCard(
                                    row: row,
                                    onOpenFile: () => _openGeneratedFile(
                                      row['generated_file'],
                                    ),
                                    onOpenFolder: () => _openParentFolder(
                                      row['generated_file'],
                                    ),
                                    onOpenManifest: () => _openGeneratedFile(
                                      row['manifest_file'],
                                    ),
                                    onCopyPath: () => _copyToClipboard(
                                      context,
                                      row['generated_file'] ?? '',
                                      'Copied generated file path.',
                                    ),
                                    onMarkPrinted: () => _markLabelPrinted(
                                      ref,
                                      workspace.assetsRootPath!,
                                      row['label_id'] ?? '',
                                    ),
                                    onMarkApplied: () => _markLabelApplied(
                                      ref,
                                      workspace.assetsRootPath!,
                                      row['label_id'] ?? '',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _HistorySection(
                                  title: 'Failed / retry queue',
                                  subtitle:
                                      'Labels marked for reprint can be moved back to the ready queue when you are ready to try again.',
                                  rows: retryRows,
                                  accent: AppColours.darkAmber,
                                  emptyText: 'No retry items right now.',
                                  itemBuilder: (row) => _RetryQueueCard(
                                    row: row,
                                    onRetry: () => _retryQueueItem(
                                      ref,
                                      workspace.assetsRootPath!,
                                      row['queue_id'] ?? '',
                                    ),
                                    onOpenManifest: () => _openGeneratedFile(
                                      row['manifest_file'],
                                    ),
                                    onMarkPrinted: () => _markQueueStatus(
                                      ref,
                                      workspace.assetsRootPath!,
                                      row['queue_id'] ?? '',
                                      'printed',
                                    ),
                                    onMarkApplied: () => _markQueueStatus(
                                      ref,
                                      workspace.assetsRootPath!,
                                      row['queue_id'] ?? '',
                                      'applied',
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
                );
              },
            );
          },
        );
      },
    );
  }

  List<Map<String, String>> _sortedLabelRows(List<Map<String, String>> rows) {
    final sorted = [...rows];
    sorted.sort((a, b) {
      final aId = (a['label_id'] ?? '').trim().toLowerCase();
      final bId = (b['label_id'] ?? '').trim().toLowerCase();
      return bId.compareTo(aId);
    });
    return sorted;
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

  Future<void> _markLabelPrinted(
    WidgetRef ref,
    String assetsRootPath,
    String labelId,
  ) async {
    if (labelId.trim().isEmpty) {
      return;
    }

    await ref
        .read(assetQrLabelPrintServiceProvider)
        .markLabelPrinted(assetsRootPath, labelId);
    ref.invalidate(assetQrLabelTemplateRegisterProvider);
  }

  Future<void> _markLabelApplied(
    WidgetRef ref,
    String assetsRootPath,
    String labelId,
  ) async {
    if (labelId.trim().isEmpty) {
      return;
    }

    await ref
        .read(assetQrLabelPrintServiceProvider)
        .markLabelApplied(assetsRootPath, labelId);
    ref.invalidate(assetQrLabelTemplateRegisterProvider);
  }

  Future<void> _retryQueueItem(
    WidgetRef ref,
    String assetsRootPath,
    String queueId,
  ) async {
    if (queueId.trim().isEmpty) {
      return;
    }

    await ref
        .read(assetQrLabelPrintServiceProvider)
        .markQueueQueued(assetsRootPath, queueId);
    ref.invalidate(assetQrPrintQueueProvider);
  }

  Future<void> _markQueueStatus(
    WidgetRef ref,
    String assetsRootPath,
    String queueId,
    String status,
  ) async {
    if (queueId.trim().isEmpty) {
      return;
    }

    final service = ref.read(assetQrLabelPrintServiceProvider);
    switch (status) {
      case 'printed':
        await service.markQueuePrinted(assetsRootPath, queueId);
        break;
      case 'applied':
        await service.markQueueApplied(assetsRootPath, queueId);
        break;
    }
    ref.invalidate(assetQrPrintQueueProvider);
  }

  Future<void> _exportRecentHistory(
    BuildContext context,
    WidgetRef ref,
    String assetsRootPath,
  ) async {
    final service = ref.read(assetQrLabelPrintServiceProvider);
    final file = await service.exportRecentLabelHistory(assetsRootPath);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported history CSV to ${file.path}')),
    );
  }

  Future<void> _printRecentHistory(
    BuildContext context,
    WidgetRef ref,
    String assetsRootPath,
  ) async {
    final service = ref.read(assetQrLabelPrintServiceProvider);
    final file = await service.exportRecentLabelHistoryPdf(assetsRootPath);
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opened recent history print for ${file.path}')),
    );
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    String value,
    String message,
  ) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: trimmed));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _openGeneratedFile(String? filePath) async {
    final trimmed = (filePath ?? '').trim();
    if (trimmed.isEmpty) {
      return;
    }

    final file = File(trimmed);
    if (!await file.exists()) {
      return;
    }

    if (Platform.isWindows) {
      await Process.start('cmd.exe', ['/c', 'start', '', file.path]);
    } else if (Platform.isMacOS) {
      await Process.start('open', [file.path]);
    } else {
      await Process.start('xdg-open', [file.path]);
    }
  }

  Future<void> _openParentFolder(String? filePath) async {
    final trimmed = (filePath ?? '').trim();
    if (trimmed.isEmpty) {
      return;
    }

    final file = File(trimmed);
    if (!await file.exists()) {
      return;
    }

    final folderPath = file.parent.path;
    if (Platform.isWindows) {
      await Process.start('explorer.exe', [folderPath]);
    } else if (Platform.isMacOS) {
      await Process.start('open', [folderPath]);
    } else {
      await Process.start('xdg-open', [folderPath]);
    }
  }

  Future<void> _openExportFolder(String assetsRootPath) async {
    final folder = Directory(
      path.join(
        assetsRootPath,
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '03_PRINT_QUEUE',
        'history_exports',
      ),
    );
    await folder.create(recursive: true);

    if (Platform.isWindows) {
      await Process.start('explorer.exe', [folder.path]);
    } else if (Platform.isMacOS) {
      await Process.start('open', [folder.path]);
    } else {
      await Process.start('xdg-open', [folder.path]);
    }
  }
}

class _HistoryHero extends StatelessWidget {
  const _HistoryHero({
    required this.workspacePath,
    required this.labelCount,
    required this.printedCount,
    required this.appliedCount,
    required this.retryCount,
    required this.onBackToAssets,
    required this.onBackToStudio,
    required this.onBackToRegister,
    required this.onOpenQueue,
    required this.onRefresh,
  });

  final String? workspacePath;
  final int labelCount;
  final int printedCount;
  final int appliedCount;
  final int retryCount;
  final VoidCallback onBackToAssets;
  final VoidCallback onBackToStudio;
  final VoidCallback onBackToRegister;
  final VoidCallback onOpenQueue;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QR Label History',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'See the calm audit trail for generated labels, queue progress, and retry items without leaving the local workspace.',
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
                  _HistoryPill(
                    label: 'Labels: $labelCount',
                    accent: AppColours.darkSecondary,
                  ),
                  _HistoryPill(
                    label: 'Printed: $printedCount',
                    accent: AppColours.darkAmber,
                  ),
                  _HistoryPill(
                    label: 'Applied: $appliedCount',
                    accent: AppColours.darkSuccess,
                  ),
                  _HistoryPill(
                    label: 'Retry: $retryCount',
                    accent: AppColours.darkAmber,
                  ),
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: onBackToAssets,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Assets'),
              ),
              OutlinedButton.icon(
                onPressed: onBackToStudio,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Back to Studio'),
              ),
              OutlinedButton.icon(
                onPressed: onBackToRegister,
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text('Back to QR Labels'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQueue,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Print Queue'),
              ),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
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

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.accent,
    required this.emptyText,
    required this.itemBuilder,
  });

  final String title;
  final String subtitle;
  final List<Map<String, String>> rows;
  final Color accent;
  final String emptyText;
  final Widget Function(Map<String, String> row) itemBuilder;

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
              _SectionTitle(title: title, icon: Icons.history_outlined),
              const Spacer(),
              _HistoryPill(label: 'Count: ${rows.length}', accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            Text(
              emptyText,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Column(
              children: [
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: itemBuilder(row),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HistoryExportCard extends StatelessWidget {
  const _HistoryExportCard({
    required this.onExportRecent,
    required this.onPrintRecent,
    required this.onOpenExportFolder,
  });

  final VoidCallback onExportRecent;
  final VoidCallback onPrintRecent;
  final VoidCallback onOpenExportFolder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'History exports',
            icon: Icons.download_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Keep the printable history exports together so the recent trail is easy to review or file locally.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onExportRecent,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export recent'),
              ),
              OutlinedButton.icon(
                onPressed: onPrintRecent,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print recent'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenExportFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open export folder'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabelRecordCard extends StatelessWidget {
  const _LabelRecordCard({
    required this.row,
    required this.onOpenFile,
    required this.onOpenFolder,
    required this.onOpenManifest,
    required this.onCopyPath,
    required this.onMarkPrinted,
    required this.onMarkApplied,
  });

  final Map<String, String> row;
  final VoidCallback onOpenFile;
  final VoidCallback onOpenFolder;
  final VoidCallback onOpenManifest;
  final VoidCallback onCopyPath;
  final VoidCallback onMarkPrinted;
  final VoidCallback onMarkApplied;

  @override
  Widget build(BuildContext context) {
    final status = (row['print_status'] ?? '').trim();
    final accent = _statusAccent(status);
    final generatedFile = row['generated_file'] ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row['label_id']?.trim().isNotEmpty == true
                      ? row['label_id']!.trim()
                      : 'Label record',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _HistoryPill(
                label: status.isEmpty ? 'unknown' : status,
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(label: row['asset_id'] ?? 'No asset ID'),
              _MiniChip(label: row['label_type'] ?? 'No label type'),
              _MiniChip(label: row['label_size'] ?? 'No label size'),
              _MiniChip(label: path.basename(generatedFile)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Printed: ${_formatDate(row['printed_date'])}  |  Applied: ${_formatDate(row['applied_date'])}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          if ((row['location'] ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              row['location']!.trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if ((row['notes'] ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              row['notes']!.trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(onPressed: onOpenFile, child: const Text('Open PDF')),
              TextButton(
                onPressed: onOpenFolder,
                child: const Text('Open folder'),
              ),
              TextButton(
                onPressed: onOpenManifest,
                child: const Text('Open manifest'),
              ),
              TextButton(onPressed: onCopyPath, child: const Text('Copy path')),
              TextButton(
                onPressed: onMarkPrinted,
                child: const Text('Mark printed'),
              ),
              TextButton(
                onPressed: onMarkApplied,
                child: const Text('Mark applied'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RetryQueueCard extends StatelessWidget {
  const _RetryQueueCard({
    required this.row,
    required this.onRetry,
    required this.onMarkPrinted,
    required this.onMarkApplied,
    required this.onOpenManifest,
  });

  final Map<String, String> row;
  final VoidCallback onRetry;
  final VoidCallback onMarkPrinted;
  final VoidCallback onMarkApplied;
  final VoidCallback onOpenManifest;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? '').trim();
    final accent = _statusAccent(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row['asset_id']?.trim().isNotEmpty == true
                      ? row['asset_id']!.trim()
                      : 'Unknown asset',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _HistoryPill(
                label: status.isEmpty ? 'unknown' : status,
                accent: accent,
              ),
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
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColours.darkSecondary),
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

class _HistoryPill extends StatelessWidget {
  const _HistoryPill({required this.label, required this.accent});

  final String label;
  final Color accent;

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
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Text(
        label.isEmpty ? '—' : label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColours.darkMutedText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({
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
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
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
  switch (status.toLowerCase()) {
    case 'printed':
      return AppColours.darkAmber;
    case 'applied':
      return AppColours.darkSuccess;
    case 'reprint_needed':
      return const Color(0xFFE26B6B);
    case 'queued':
    case 'generated':
    default:
      return AppColours.darkSecondary;
  }
}

String _formatDate(String? raw) {
  final trimmed = (raw ?? '').trim();
  if (trimmed.isEmpty) {
    return 'Not recorded';
  }

  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return trimmed;
  }

  return DateFormat('d MMM yyyy, HH:mm').format(parsed);
}
