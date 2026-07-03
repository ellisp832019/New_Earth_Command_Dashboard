import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colours.dart';
import '../data/omega_knowledge_engine_service.dart';

Future<OmegaKnowledgeEngineRunResult?> showOmegaKnowledgeEngineTerminalDialog({
  required BuildContext context,
  required OmegaKnowledgeEngineService service,
  required OmegaKnowledgeEngineSnapshot snapshot,
  bool autoStartScan = false,
}) {
  return showDialog<OmegaKnowledgeEngineRunResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _OmegaKnowledgeEngineTerminalDialog(
      service: service,
      snapshot: snapshot,
      autoStartScan: autoStartScan,
    ),
  );
}

class _OmegaKnowledgeEngineTerminalDialog extends StatefulWidget {
  const _OmegaKnowledgeEngineTerminalDialog({
    required this.service,
    required this.snapshot,
    required this.autoStartScan,
  });

  final OmegaKnowledgeEngineService service;
  final OmegaKnowledgeEngineSnapshot snapshot;
  final bool autoStartScan;

  @override
  State<_OmegaKnowledgeEngineTerminalDialog> createState() =>
      _OmegaKnowledgeEngineTerminalDialogState();
}

class _OmegaKnowledgeEngineTerminalDialogState
    extends State<_OmegaKnowledgeEngineTerminalDialog> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _lines = [];
  String _latestLine = '';
  OmegaKnowledgeEngineRunResult? _result;
  Object? _error;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _seedIdleTerminal();
    if (widget.autoStartScan) {
      unawaited(_runScan());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _seedIdleTerminal() {
    _latestLine = 'Idle and stable.';
    _lines
      ..clear()
      ..add('> ${widget.snapshot.scanCommand}')
      ..add('Idle and stable.')
      ..add('Ready for the next scan.')
      ..add('Generated at: ${widget.snapshot.generatedAt}')
      ..add('Repositories: ${widget.snapshot.repositoryCount}')
      ..add('Files scanned: ${widget.snapshot.filesScanned}')
      ..add('Output root: ${widget.snapshot.settings.outputDir}');
  }

  Future<void> _runScan() async {
    if (_running) {
      return;
    }

    setState(() {
      _running = true;
      _error = null;
      _result = null;
      _latestLine = 'Scan starting...';
      _lines
        ..clear()
        ..add('Scan starting...');
    });
    _scrollToEnd();

    try {
      final result = await widget.service.runScan(onOutputLine: _appendLine);
      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
        _running = false;
        _latestLine = result.succeeded
            ? 'Idle and stable.'
            : 'Idle, but review the summary before the next scan.';
        _lines.add(
          result.succeeded ? 'Scan complete.' : 'Scan finished with warnings.',
        );
        _lines.add(
          result.succeeded
              ? 'Idle and stable.'
              : 'Idle, but review the summary before the next scan.',
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
        _latestLine = 'Idle and stable.';
        _lines.add('Scan failed to start: $error');
        _lines.add('Idle and stable.');
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
      _latestLine = line.replaceFirst('[stderr] ', '');
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  String _statusLabel() {
    if (_running) {
      return 'Scanning';
    }
    if (_error != null) {
      return 'Idle with error';
    }
    if (_result?.succeeded == true) {
      return 'Idle and stable';
    }
    return 'Idle and stable';
  }

  String _statusCopy() {
    if (_running) {
      return 'The scan is running. Live terminal lines appear below while the dashboard stays readable.';
    }
    if (_error != null) {
      return 'The terminal is idle again, but the scan start failed. Review the summary and retry when ready.';
    }
    if (_result?.succeeded == true) {
      return 'The scan finished cleanly. The dashboard can stay calm while this terminal remains stable.';
    }
    return 'The terminal is idle and stable. Run a scan when you want fresh outputs.';
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
          const Expanded(child: Text('Omega Knowledge Engine terminal')),
          const SizedBox(width: 12),
          _TerminalStateChip(
            label: _statusLabel(),
            accent: _running
                ? AppColours.darkSecondary
                : _error != null
                ? AppColours.darkAmber
                : AppColours.darkSuccess,
          ),
        ],
      ),
      content: SizedBox(
        width: 900,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _statusCopy(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceAlt.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColours.darkOutline.withValues(alpha: 0.75),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest line',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColours.darkSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _latestLine,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColours.darkText,
                          fontFamily: 'monospace',
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 280,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColours.darkBackground.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColours.darkSecondary.withValues(alpha: 0.24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Terminal',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColours.darkSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Read-only, local, and calm.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColours.darkMutedText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _lines.length,
                          itemBuilder: (context, index) {
                            final line = _lines[index];
                            final isErrorLine = line.startsWith('[stderr]');
                            final displayLine = isErrorLine
                                ? line.replaceFirst('[stderr] ', '')
                                : line;
                            final colour = isErrorLine
                                ? AppColours.darkAmber
                                : AppColours.darkText;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: SelectableText(
                                displayLine,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colour,
                                      fontFamily: 'monospace',
                                      height: 1.35,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _TerminalSummary(
                snapshot: widget.snapshot,
                result: result,
                error: _error,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _running ? null : _runScan,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: Text(_result == null ? 'Run scan' : 'Run again'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: _lines.join('\n')),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy terminal output'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _running ? null : () => Navigator.of(context).pop(_result),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _TerminalSummary extends StatelessWidget {
  const _TerminalSummary({
    required this.snapshot,
    required this.result,
    required this.error,
  });

  final OmegaKnowledgeEngineSnapshot snapshot;
  final OmegaKnowledgeEngineRunResult? result;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = [
      _TerminalSummaryCard(
        label: 'Generated',
        value: snapshot.generatedAt,
        accent: AppColours.darkSecondary,
      ),
      _TerminalSummaryCard(
        label: 'Repositories',
        value: snapshot.repositoryCount.toString(),
        accent: AppColours.darkSuccess,
      ),
      _TerminalSummaryCard(
        label: 'Files scanned',
        value: snapshot.filesScanned.toString(),
        accent: AppColours.darkPrimary,
      ),
      _TerminalSummaryCard(
        label: 'Output dir',
        value: snapshot.settings.outputDir,
        accent: AppColours.darkAmber,
      ),
    ];

    final summaryText = error != null
        ? 'Scan start failed: $error'
        : result == null
        ? 'Idle and stable. The terminal is ready for the next scan.'
        : result!.succeeded
        ? 'The last scan completed cleanly and the dashboard can keep working from the refreshed outputs.'
        : 'The last scan completed with warnings. Review the output before scanning again.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summaryText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColours.darkMutedText,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final useTwoColumns = constraints.maxWidth >= 640;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: useTwoColumns
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth,
                    child: card,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TerminalSummaryCard extends StatelessWidget {
  const _TerminalSummaryCard({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalStateChip extends StatelessWidget {
  const _TerminalStateChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
