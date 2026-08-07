import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colours.dart';
import '../data/repo_intelligence_bridge_models.dart';

Future<void> showRepoIntelligenceBridgeSyncTerminalDialog({
  required BuildContext context,
  required String title,
  required Future<RepoIntelligenceBridgeSyncResult> Function(
    void Function(String line) onOutputLine,
  )
  run,
  VoidCallback? onOpenLog,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _RepoIntelligenceBridgeSyncTerminalDialog(
      title: title,
      run: run,
      onOpenLog: onOpenLog,
    ),
  );
}

class _RepoIntelligenceBridgeSyncTerminalDialog extends StatefulWidget {
  const _RepoIntelligenceBridgeSyncTerminalDialog({
    required this.title,
    required this.run,
    required this.onOpenLog,
  });

  final String title;
  final Future<RepoIntelligenceBridgeSyncResult> Function(
    void Function(String line) onOutputLine,
  )
  run;
  final VoidCallback? onOpenLog;

  @override
  State<_RepoIntelligenceBridgeSyncTerminalDialog> createState() =>
      _RepoIntelligenceBridgeSyncTerminalDialogState();
}

class _RepoIntelligenceBridgeSyncTerminalDialogState
    extends State<_RepoIntelligenceBridgeSyncTerminalDialog> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _lines = [];
  RepoIntelligenceBridgeSyncResult? _result;
  Object? _error;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final result = await widget.run(_appendLine);
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _running = false;
        _lines.add(
          result.success
              ? 'Sync finished successfully.'
              : 'Sync finished with exit code ${result.exitCode}.',
        );
      });
      _scrollToEnd();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _running = false;
        _lines.add('Sync failed: $error');
      });
      _scrollToEnd();
    }
  }

  void _appendLine(String line) {
    if (!mounted) {
      return;
    }
    setState(() {
      _lines.add(line);
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return AlertDialog(
      backgroundColor: AppColours.darkSurface,
      title: Row(
        children: [
          const Icon(Icons.terminal_outlined, color: AppColours.darkSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.title)),
          if (_running)
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 760,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _running
                  ? 'The sync is running. Live lines will appear below.'
                  : _error != null
                  ? 'The sync stopped with an error.'
                  : 'The sync finished. Review the terminal output and summary below.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColours.darkOutline),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _lines.length,
                    itemBuilder: (context, index) {
                      final line = _lines[index];
                      final accent = line.startsWith('[stderr]')
                          ? AppColours.darkAmber
                          : AppColours.darkText;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SelectableText(
                          line,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: accent,
                                fontFamily: 'monospace',
                                height: 1.35,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SummaryPanel(result: result, error: _error),
            const SizedBox(height: 12),
            if (result != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.onOpenLog != null)
                    TextButton.icon(
                      onPressed: widget.onOpenLog,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Open sync log'),
                    ),
                  TextButton.icon(
                    onPressed: () async {
                      final text = _lines.join('\n');
                      await Clipboard.setData(ClipboardData(text: text));
                    },
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy terminal output'),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _running ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.result, required this.error});

  final RepoIntelligenceBridgeSyncResult? result;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final summaryTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColours.darkMutedText,
      height: 1.35,
    );

    if (error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColours.darkAmber.withValues(alpha: 0.3),
          ),
        ),
        child: Text(error.toString(), style: summaryTextStyle),
      );
    }

    if (result == null) {
      return const SizedBox.shrink();
    }

    final syncResult = result!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            syncResult.success ? 'Sync summary' : 'Sync summary with warnings',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: syncResult.success
                  ? AppColours.darkSuccess
                  : AppColours.darkAmber,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            'Exit code: ${syncResult.exitCode}\n'
            'Duration: ${syncResult.duration.inSeconds}s\n'
            'Log file: ${syncResult.logPath}\n'
            'Stdout lines: ${syncResult.stdoutLines.length}\n'
            'Stderr lines: ${syncResult.stderrLines.length}',
            style: summaryTextStyle,
          ),
        ],
      ),
    );
  }
}
