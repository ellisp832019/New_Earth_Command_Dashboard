import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../data/repo_research_engine_service.dart';

class RepoResearchEngineScreen extends StatefulWidget {
  const RepoResearchEngineScreen({super.key});

  @override
  State<RepoResearchEngineScreen> createState() =>
      _RepoResearchEngineScreenState();
}

class _RepoResearchEngineScreenState extends State<RepoResearchEngineScreen> {
  late final RepoResearchEngineService _service = RepoResearchEngineService();
  late final TextEditingController _repoPathController =
      TextEditingController();
  late final TextEditingController _profileController = TextEditingController(
    text: 'Generic',
  );
  late final TextEditingController _outputController = TextEditingController(
    text: _defaultOutputDirectory,
  );
  late final TextEditingController _omegaRootController = TextEditingController(
    text:
        'D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/GIT_RESEARCH_LIBRARY',
  );
  late final TextEditingController _compareWithController =
      TextEditingController();
  late final TextEditingController _baselineController =
      TextEditingController();
  late final TextEditingController _compareProfileController =
      TextEditingController(text: 'Generic');
  late final TextEditingController _logController = TextEditingController();
  late final TextEditingController _reportPreviewController =
      TextEditingController();
  late final TextEditingController _recentRunsSearchController =
      TextEditingController();

  bool _graphExport = true;
  bool _isRunning = false;
  List<String> _outputFiles = const [];
  List<RepoResearchRunRecord> _recentRuns = const [];
  bool _loadingRecentRuns = true;
  String _recentRunsFilter = 'all';
  String _lastRunLabel = 'No run yet';

  String get _defaultOutputDirectory {
    final moduleRoot = _service.moduleRootDirectory();
    return '${moduleRoot.path}${Platform.pathSeparator}reports';
  }

  @override
  void initState() {
    super.initState();
    _loadRecentRuns();
  }

  @override
  void dispose() {
    _repoPathController.dispose();
    _profileController.dispose();
    _outputController.dispose();
    _omegaRootController.dispose();
    _compareWithController.dispose();
    _baselineController.dispose();
    _compareProfileController.dispose();
    _logController.dispose();
    _reportPreviewController.dispose();
    _recentRunsSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Repo Research Engine'),
        actions: [
          TextButton.icon(
            onPressed: _isRunning ? null : () => context.go(RouteNames.more),
            icon: const Icon(Icons.arrow_back),
            label: const Text('More'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          children: [
            _heroCard(context),
            const SizedBox(height: 16),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _scannerCard(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _comparisonCard(context)),
                ],
              )
            else ...[
              _scannerCard(context),
              const SizedBox(height: 16),
              _comparisonCard(context),
            ],
            const SizedBox(height: 16),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _outputsCard(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _logsCard(context)),
                ],
              )
            else ...[
              _outputsCard(context),
              const SizedBox(height: 16),
              _logsCard(context),
            ],
            const SizedBox(height: 16),
            _reportPreviewCard(context),
            const SizedBox(height: 16),
            _recentRunsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    return _panel(
      context,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _StatusChip(label: 'Local-first'),
              _StatusChip(label: 'Read-only'),
              _StatusChip(label: 'Secrets masked'),
              _StatusChip(label: 'Graph export'),
            ],
          );
          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: _isRunning ? null : _runBundle,
                icon: const Icon(Icons.search),
                label: const Text('Run Scan + Reports'),
              ),
              FilledButton.tonalIcon(
                onPressed: _isRunning ? null : _runComparison,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Compare + Track'),
              ),
              OutlinedButton.icon(
                onPressed: _isRunning ? null : _runGraphExport,
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Export Graphs'),
              ),
              TextButton.icon(
                onPressed: () =>
                    _service.openFolder(_outputController.text.trim()),
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Output Folder'),
              ),
            ],
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safe repo analysis for New Earth projects',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Scan a local repository, compare it with another snapshot or repo, and export research packs without executing unknown code.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              chips,
              const SizedBox(height: 16),
              Text(
                'Last run: $_lastRunLabel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [details, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: 18),
              SizedBox(width: 360, child: actions),
            ],
          );
        },
      ),
    );
  }

  Widget _scannerCard(BuildContext context) {
    return _panel(
      context,
      title: 'Repository Scanner',
      subtitle:
          'Choose a local repo path and generate the safe research bundle.',
      child: Column(
        children: [
          _field(
            controller: _repoPathController,
            label: 'Repository path',
            hint: r'D:\Projects\example-repo',
          ),
          const SizedBox(height: 12),
          _field(
            controller: _profileController,
            label: 'Profile',
            hint: 'MicroGrow, New Earth Dashboard, BioCalm, Generic',
          ),
          const SizedBox(height: 12),
          _field(
            controller: _outputController,
            label: 'Output folder',
            hint: _defaultOutputDirectory,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _omegaRootController,
            label: 'Omega OS export root',
            hint:
                'D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/GIT_RESEARCH_LIBRARY',
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _graphExport,
            onChanged: _isRunning
                ? null
                : (value) => setState(() => _graphExport = value),
            title: const Text('Export graphs with each run'),
            subtitle: const Text(
              'Generates dependency and architecture graph bundles.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonCard(BuildContext context) {
    return _panel(
      context,
      title: 'Repo Comparison',
      subtitle: 'Compare against a second repo or a saved inventory JSON.',
      child: Column(
        children: [
          _field(
            controller: _compareWithController,
            label: 'Compare with',
            hint: r'D:\Projects\other-repo or D:\path\to\inventory.json',
          ),
          const SizedBox(height: 12),
          _field(
            controller: _compareProfileController,
            label: 'Comparison profile',
            hint: 'Generic',
          ),
          const SizedBox(height: 12),
          _field(
            controller: _baselineController,
            label: 'Baseline inventory JSON',
            hint: r'D:\path\to\baseline\repo_inventory.json',
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _isRunning ? null : _runComparison,
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Compare now'),
                ),
                OutlinedButton.icon(
                  onPressed: _isRunning ? null : _runGraphExport,
                  icon: const Icon(Icons.account_tree_outlined),
                  label: const Text('Graphs only'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _outputsCard(BuildContext context) {
    return _panel(
      context,
      title: 'Research Reports',
      subtitle: 'Latest generated files inside the selected output folder.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_outputFiles.isEmpty)
            Text(
              'No output files loaded yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _outputFiles
                  .map((file) => _StatusChip(label: file, muted: false))
                  .toList(),
            ),
          const SizedBox(height: 12),
          Text(
            'Generated report files remain local and can be exported into the Knowledge Vault after review.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
        ],
      ),
    );
  }

  Widget _logsCard(BuildContext context) {
    return _panel(
      context,
      title: 'Run Log',
      subtitle: 'Command and output from the last local run.',
      child: SizedBox(
        height: 250,
        child: SingleChildScrollView(
          child: TextField(
            controller: _logController,
            readOnly: true,
            maxLines: null,
            decoration: const InputDecoration(border: InputBorder.none),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _reportPreviewCard(BuildContext context) {
    return _panel(
      context,
      title: 'Report Preview',
      subtitle: 'Quick glance at the main report after the latest run.',
      child: SizedBox(
        height: 340,
        child: SingleChildScrollView(
          child: TextField(
            controller: _reportPreviewController,
            readOnly: true,
            maxLines: null,
            decoration: const InputDecoration(border: InputBorder.none),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentRunsCard(BuildContext context) {
    final visibleRuns = _filteredRecentRuns();
    return _panel(
      context,
      title: 'Recent Runs',
      subtitle: 'Latest local research jobs captured in the run history file.',
      child: _loadingRecentRuns
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          : _recentRuns.isEmpty
          ? Text(
              'No recent runs are recorded yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _recentRunsSearchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Search recent runs',
                          hintText: 'Repo path or profile',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(value: 'all', label: Text('All')),
                        ButtonSegment<String>(
                          value: 'success',
                          label: Text('Success'),
                        ),
                        ButtonSegment<String>(
                          value: 'needs_review',
                          label: Text('Needs review'),
                        ),
                      ],
                      selected: <String>{_recentRunsFilter},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _recentRunsFilter = selection.first;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (visibleRuns.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No runs match the current filter.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  )
                else
                  for (final run in visibleRuns) ...[
                    _RecentRunTile(
                      run: run,
                      onLoad: () => _loadRecentRunIntoForm(run),
                      onRerun: () => _rerunRecentRun(run),
                      onOpenOutput: run.outputDirectory.isEmpty
                          ? null
                          : () => _service.openFolder(run.outputDirectory),
                    ),
                    if (run != visibleRuns.last) const SizedBox(height: 10),
                  ],
              ],
            ),
    );
  }

  Widget _panel(
    BuildContext context, {
    String? title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.88),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
            ),
            const SizedBox(height: 6),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Future<void> _runBundle() async {
    await _run(mode: _RunMode.bundle);
  }

  Future<void> _runComparison() async {
    await _run(mode: _RunMode.compare);
  }

  Future<void> _runGraphExport() async {
    await _run(mode: _RunMode.graphs);
  }

  Future<void> _run({required _RunMode mode}) async {
    final repoPath = _repoPathController.text.trim();
    if (repoPath.isEmpty) {
      _setMessage('Enter a local repository path first.');
      return;
    }

    final profile = _profileController.text.trim().isEmpty
        ? 'Generic'
        : _profileController.text.trim();
    final output = _outputController.text.trim().isEmpty
        ? _defaultOutputDirectory
        : _outputController.text.trim();
    final omegaRoot = _omegaRootController.text.trim();
    final compareWith = _compareWithController.text.trim();
    final compareProfile = _compareProfileController.text.trim();
    final baselineInventory = _baselineController.text.trim();

    setState(() {
      _isRunning = true;
      _lastRunLabel = 'Running...';
      _logController.text = 'Launching repository research command...';
    });

    try {
      final result = await _service.runResearch(
        repoPath: repoPath,
        profile: profile,
        outDirectory: output,
        omegaRoot: omegaRoot.isEmpty ? null : omegaRoot,
        compareWith: mode == _RunMode.bundle && compareWith.isNotEmpty
            ? compareWith
            : mode == _RunMode.compare
            ? (compareWith.isNotEmpty ? compareWith : null)
            : null,
        baselineInventory:
            mode == _RunMode.bundle && baselineInventory.isNotEmpty
            ? baselineInventory
            : mode == _RunMode.compare
            ? (baselineInventory.isNotEmpty ? baselineInventory : null)
            : mode == _RunMode.graphs
            ? null
            : baselineInventory.isNotEmpty
            ? baselineInventory
            : null,
        compareProfile: compareProfile.isEmpty ? null : compareProfile,
        graphExport: mode != _RunMode.compare || _graphExport,
      );

      final files = await _service.listOutputFiles(output);
      final previewPath = pathJoin(output, 'repo_research_report.md');
      final preview = await _service.readFile(previewPath);

      setState(() {
        _outputFiles = files;
        _reportPreviewController.text = preview;
        _logController.text = _renderLog(result);
        _lastRunLabel = result.succeeded
            ? 'Completed with exit code ${result.exitCode}'
            : 'Finished with exit code ${result.exitCode}';
      });
      await _loadRecentRuns(refreshStateOnly: false);

      _setMessage(
        result.succeeded
            ? 'Repository research bundle generated successfully.'
            : 'The command finished, but returned exit code ${result.exitCode}.',
      );
    } catch (error) {
      setState(() {
        _logController.text = 'Run failed:\n$error';
        _lastRunLabel = 'Failed';
      });
      _setMessage('Repo Research Engine could not run: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  Future<void> _loadRecentRuns({bool refreshStateOnly = true}) async {
    if (refreshStateOnly && mounted) {
      setState(() {
        _loadingRecentRuns = true;
      });
    }

    final runs = await _service.loadRecentRuns();
    if (!mounted) {
      return;
    }
    setState(() {
      _recentRuns = runs;
      _loadingRecentRuns = false;
    });
  }

  List<RepoResearchRunRecord> _filteredRecentRuns() {
    final search = _recentRunsSearchController.text.trim().toLowerCase();
    return _recentRuns
        .where((run) {
          final matchesSearch =
              search.isEmpty ||
              run.repoPath.toLowerCase().contains(search) ||
              run.profile.toLowerCase().contains(search) ||
              run.outputDirectory.toLowerCase().contains(search);
          final matchesStatus = switch (_recentRunsFilter) {
            'success' => run.succeeded,
            'needs_review' => !run.succeeded,
            _ => true,
          };
          return matchesSearch && matchesStatus;
        })
        .toList(growable: false);
  }

  void _loadRecentRunIntoForm(RepoResearchRunRecord run) {
    _repoPathController.text = run.repoPath;
    _profileController.text = run.profile;
    _outputController.text = run.outputDirectory;
    if ((run.compareWith ?? '').isNotEmpty) {
      _compareWithController.text = run.compareWith!;
    }
    if ((run.baselineInventory ?? '').isNotEmpty) {
      _baselineController.text = run.baselineInventory!;
    }
    if ((run.compareProfile ?? '').isNotEmpty) {
      _compareProfileController.text = run.compareProfile!;
    }
    if (mounted) {
      setState(() {
        _graphExport = run.graphExport;
      });
    }
    _setMessage('Loaded the selected run into the form.');
  }

  Future<void> _rerunRecentRun(RepoResearchRunRecord run) async {
    _loadRecentRunIntoForm(run);
    await _run(mode: _RunMode.bundle);
  }

  String _renderLog(RepoResearchEngineRunResult result) {
    final buffer = StringBuffer();
    buffer.writeln('Command: ${result.command.join(' ')}');
    buffer.writeln('Output directory: ${result.outputDirectory}');
    buffer.writeln('Exit code: ${result.exitCode}');
    buffer.writeln('');
    if (result.stdout.trim().isNotEmpty) {
      buffer.writeln('STDOUT:');
      buffer.writeln(result.stdout.trim());
      buffer.writeln('');
    }
    if (result.stderr.trim().isNotEmpty) {
      buffer.writeln('STDERR:');
      buffer.writeln(result.stderr.trim());
    }
    return buffer.toString();
  }

  void _setMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String pathJoin(String left, String right) {
    if (left.endsWith(Platform.pathSeparator)) {
      return '$left$right';
    }
    return '$left${Platform.pathSeparator}$right';
  }
}

enum _RunMode { bundle, compare, graphs }

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, this.muted = true});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final accent = muted ? AppColours.darkMutedText : AppColours.darkSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
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

class _RecentRunTile extends StatelessWidget {
  const _RecentRunTile({
    required this.run,
    required this.onLoad,
    required this.onRerun,
    required this.onOpenOutput,
  });

  final RepoResearchRunRecord run;
  final VoidCallback onLoad;
  final VoidCallback onRerun;
  final VoidCallback? onOpenOutput;

  @override
  Widget build(BuildContext context) {
    final timestamp = run.parsedTimestamp;
    final timestampLabel = timestamp == null
        ? run.timestamp
        : '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  run.repoPath.isEmpty ? 'Unknown repo' : run.repoPath,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(label: run.shortStatus, muted: !run.succeeded),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Profile: ${run.profile} - $timestampLabel',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 4),
          Text(
            'Output: ${run.outputDirectory}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 6),
            collapsedIconColor: AppColours.darkMutedText,
            iconColor: AppColours.darkSecondary,
            title: Text(
              'Details',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Command, flags, and generated files',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            ),
            children: [
              _detailRow('Command', run.command.join(' '), context),
              _detailRow(
                'Graph export',
                run.graphExport ? 'Enabled' : 'Disabled',
                context,
              ),
              _detailRow(
                'Comparison',
                [
                  if ((run.compareWith ?? '').isNotEmpty)
                    'Compare: ${run.compareWith}',
                  if ((run.baselineInventory ?? '').isNotEmpty)
                    'Baseline: ${run.baselineInventory}',
                  if ((run.compareProfile ?? '').isNotEmpty)
                    'Compare profile: ${run.compareProfile}',
                ].join(' • '),
                context,
              ),
              _detailRow(
                'Reports',
                run.reportFiles.isEmpty
                    ? 'No report files captured yet.'
                    : run.reportFiles.join(', '),
                context,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (run.graphExport) const _StatusChip(label: 'Graphs'),
              if ((run.compareWith ?? '').isNotEmpty)
                const _StatusChip(label: 'Compare'),
              if ((run.reportFiles).isNotEmpty)
                _StatusChip(label: '${run.reportFiles.length} files'),
              TextButton.icon(
                onPressed: onLoad,
                icon: const Icon(Icons.tune),
                label: const Text('Load'),
              ),
              FilledButton.tonalIcon(
                onPressed: onRerun,
                icon: const Icon(Icons.replay),
                label: const Text('Rerun'),
              ),
              if (onOpenOutput != null)
                TextButton.icon(
                  onPressed: onOpenOutput,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not set' : value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkText),
          ),
        ],
      ),
    );
  }
}
