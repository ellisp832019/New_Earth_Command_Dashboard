import 'dart:convert';
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
  late final TextEditingController _profileEditorPathController =
      TextEditingController();
  late final TextEditingController _profileEditorController =
      TextEditingController();
  late final TextEditingController _profileCompareLeftPathController =
      TextEditingController();
  late final TextEditingController _profileCompareRightPathController =
      TextEditingController();
  late final TextEditingController _profileCompareLeftController =
      TextEditingController();
  late final TextEditingController _profileCompareRightController =
      TextEditingController();
  late final TextEditingController _profileCompareSummaryController =
      TextEditingController();
  late final TextEditingController _logController = TextEditingController();
  late final TextEditingController _reportPreviewController =
      TextEditingController();
  late final TextEditingController _securityPreviewController =
      TextEditingController();
  late final TextEditingController _comparisonPreviewController =
      TextEditingController();
  late final TextEditingController _recentRunsSearchController =
      TextEditingController();
  late final TextEditingController _reportHistorySearchController =
      TextEditingController();
  late final TextEditingController _exportHistorySearchController =
      TextEditingController();

  bool _graphExport = true;
  bool _isRunning = false;
  List<String> _outputFiles = const [];
  List<RepoResearchRunRecord> _recentRuns = const [];
  List<RepoResearchExportRecord> _exportHistory = const [];
  bool _loadingRecentRuns = true;
  bool _loadingExportHistory = true;
  bool _loadingProfileEditor = true;
  bool _loadingProfileComparison = true;
  String _recentRunsFilter = 'all';
  String _lastRunLabel = 'No run yet';
  String _lastRunTimestampLabel = 'Not captured yet';
  String _mainReportPath = '';
  String _securityReportPath = '';
  String _comparisonReportPath = '';
  String _profileEditorStatus = 'Profile editor not loaded';
  String _profileComparisonStatus = 'Profile comparison not loaded';
  String _selectedTemplateSet = 'Generic';

  String get _defaultOutputDirectory {
    final moduleRoot = _service.moduleRootDirectory();
    return '${moduleRoot.path}${Platform.pathSeparator}reports';
  }

  String get _defaultProfilesDirectory {
    final moduleRoot = _service.moduleRootDirectory();
    return '${moduleRoot.path}${Platform.pathSeparator}profiles';
  }

  String get _defaultProfilePath {
    return pathJoin(_defaultProfilesDirectory, 'generic.profile.json');
  }

  @override
  void initState() {
    super.initState();
    _loadRecentRuns();
    _loadExportHistory();
    _loadProfileEditor();
    _loadProfileComparison();
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
    _profileEditorPathController.dispose();
    _profileEditorController.dispose();
    _profileCompareLeftPathController.dispose();
    _profileCompareRightPathController.dispose();
    _profileCompareLeftController.dispose();
    _profileCompareRightController.dispose();
    _profileCompareSummaryController.dispose();
    _logController.dispose();
    _reportPreviewController.dispose();
    _securityPreviewController.dispose();
    _comparisonPreviewController.dispose();
    _recentRunsSearchController.dispose();
    _reportHistorySearchController.dispose();
    _exportHistorySearchController.dispose();
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
            _profileEditorCard(context),
            const SizedBox(height: 16),
            _profileComparisonCard(context),
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
            _bundlePreviewsCard(context),
            const SizedBox(height: 16),
            _reportHistoryCard(context),
            const SizedBox(height: 16),
            _exportHistoryCard(context),
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
          _profilePresetsBlock(context),
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

  Widget _profileEditorCard(BuildContext context) {
    return _panel(
      context,
      title: 'Profile Manager',
      subtitle:
          'Load, review, and save local profile JSON without leaving the dashboard.',
      child: _loadingProfileEditor
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(
                  controller: _profileEditorPathController,
                  label: 'Profile JSON path',
                  hint: _defaultProfilePath,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _profileEditorController,
                  minLines: 10,
                  maxLines: 18,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkText,
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Profile JSON',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _profileEditorStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTemplateSet,
                  decoration: const InputDecoration(
                    labelText: 'Report template set',
                  ),
                  items: _templateSets
                      .map(
                        (preset) => DropdownMenuItem<String>(
                          value: preset.name,
                          child: Text(preset.name),
                        ),
                      )
                      .toList(),
                  onChanged: _isRunning
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedTemplateSet = value;
                          });
                        },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _isRunning ? null : _loadProfileEditor,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Load Profile'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isRunning ? null : _saveProfileEditor,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Profile'),
                    ),
                    TextButton.icon(
                      onPressed: _isRunning
                          ? null
                          : () => _service.openFolder(_defaultProfilesDirectory),
                      icon: const Icon(Icons.folder),
                      label: const Text('Open Profiles Folder'),
                    ),
                    TextButton.icon(
                      onPressed: _isRunning
                          ? null
                          : () => _loadProfileEditorPath(_defaultProfilePath),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Load Generic'),
                    ),
                    TextButton.icon(
                      onPressed: _isRunning
                          ? null
                          : () => _applyTemplateSet(_selectedTemplateSet),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Apply Template Set'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _profileComparisonCard(BuildContext context) {
    return _panel(
      context,
      title: 'Profile Comparison',
      subtitle:
          'Compare two local profile JSON files side by side and review the differences.',
      child: _loadingProfileComparison
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(
                  controller: _profileCompareLeftPathController,
                  label: 'Left profile path',
                  hint: _defaultProfilePath,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _profileCompareRightPathController,
                  label: 'Right profile path',
                  hint: pathJoin(_defaultProfilesDirectory, 'microgrow.profile.json'),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final leftPane = _comparisonPane(
                      context,
                      title: 'Left profile',
                      controller: _profileCompareLeftController,
                    );
                    final rightPane = _comparisonPane(
                      context,
                      title: 'Right profile',
                      controller: _profileCompareRightController,
                    );
                    if (!wide) {
                      return Column(
                        children: [
                          leftPane,
                          const SizedBox(height: 12),
                          rightPane,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: leftPane),
                        const SizedBox(width: 12),
                        Expanded(child: rightPane),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _profileComparisonStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _profileCompareSummaryController,
                  readOnly: true,
                  minLines: 4,
                  maxLines: 8,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkText,
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Comparison summary',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _isRunning ? null : _loadProfileComparison,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Load Profiles'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isRunning ? null : _compareProfiles,
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('Compare Profiles'),
                    ),
                    TextButton.icon(
                      onPressed: _isRunning
                          ? null
                          : () => _service.openFolder(_defaultProfilesDirectory),
                      icon: const Icon(Icons.folder),
                      label: const Text('Open Profiles Folder'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _comparisonPane(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: SingleChildScrollView(
              child: TextField(
                controller: controller,
                readOnly: true,
                maxLines: null,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkText,
                  fontFamily: 'monospace',
                ),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outputsCard(BuildContext context) {
    final outputDirectory = _outputController.text.trim().isEmpty
        ? _defaultOutputDirectory
        : _outputController.text.trim();
    return _panel(
      context,
      title: 'Research Reports',
      subtitle: 'Latest generated files inside the selected output folder.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bundleMetadataBlock(context, outputDirectory: outputDirectory),
          const SizedBox(height: 14),
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

  Widget _profilePresetsBlock(BuildContext context) {
    const presets = [
      _ProfilePreset(
        label: 'MicroGrow',
        profile: 'MicroGrow',
        outputFolder: 'microgrow',
      ),
      _ProfilePreset(
        label: 'New Earth Dashboard',
        profile: 'New Earth Dashboard',
        outputFolder: 'new_earth_dashboard',
      ),
      _ProfilePreset(
        label: 'New Earth Living',
        profile: 'New Earth Living',
        outputFolder: 'new_earth_living',
      ),
      _ProfilePreset(
        label: 'BioCalm',
        profile: 'BioCalm',
        outputFolder: 'biocalm',
      ),
      _ProfilePreset(
        label: 'Rehabilitation',
        profile: 'New Earth Rehabilitation',
        outputFolder: 'rehabilitation',
      ),
      _ProfilePreset(
        label: 'Generic',
        profile: 'Generic',
        outputFolder: 'general',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick-start presets',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColours.darkSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in presets)
              OutlinedButton(
                onPressed: _isRunning
                    ? null
                    : () => _applyProfilePreset(preset),
                child: Text(preset.label),
              ),
          ],
        ),
      ],
    );
  }

  Widget _bundleMetadataBlock(
    BuildContext context, {
    required String outputDirectory,
  }) {
    final rows = [
      _MetadataRow(label: 'Output directory', value: outputDirectory),
      _MetadataRow(label: 'Last run status', value: _lastRunLabel),
      _MetadataRow(label: 'Last run time', value: _lastRunTimestampLabel),
      _MetadataRow(
        label: 'Loaded files',
        value: _outputFiles.isEmpty
            ? 'No files loaded'
            : '${_outputFiles.length} file(s)',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bundle metadata',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < rows.length; index++) ...[
            rows[index],
            if (index != rows.length - 1) const SizedBox(height: 8),
          ],
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

  Widget _reportHistoryCard(BuildContext context) {
    final visibleRuns = _recentRuns
        .where((run) {
          final search = _reportHistorySearchController.text
              .trim()
              .toLowerCase();
          if (search.isEmpty) {
            return true;
          }
          return run.outputDirectory.toLowerCase().contains(search) ||
              run.repoPath.toLowerCase().contains(search) ||
              run.profile.toLowerCase().contains(search) ||
              run.reportFiles.any(
                (file) => file.toLowerCase().contains(search),
              );
        })
        .toList(growable: false);
    final displayRuns = visibleRuns.take(6).toList(growable: false);

    return _panel(
      context,
      title: 'Report History',
      subtitle:
          'Browse recent report bundles, current output paths, and report indices.',
      child: _loadingRecentRuns
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          : _recentRuns.isEmpty
          ? Text(
              'No report bundles have been recorded yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          : Column(
              children: [
                TextField(
                  controller: _reportHistorySearchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Search report history',
                    hintText: 'Output path, repo, profile, or file name',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                if (visibleRuns.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No report bundles match the current search.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  )
                else
                  for (final run in displayRuns) ...[
                    _ReportHistoryTile(
                      run: run,
                      onOpenBundle: run.outputDirectory.isEmpty
                          ? null
                          : () => _service.openFolder(run.outputDirectory),
                      onOpenIndex:
                          run.outputDirectory.isEmpty ||
                              !run.reportFiles.contains(
                                'report_search_index.md',
                              )
                          ? null
                          : () => _service.openPath(
                              pathJoin(
                                run.outputDirectory,
                                'report_search_index.md',
                              ),
                            ),
                    ),
                    if (run != displayRuns.last) const SizedBox(height: 10),
                  ],
              ],
            ),
    );
  }

  Widget _exportHistoryCard(BuildContext context) {
    final visibleExports = _exportHistory
        .where((record) {
          final search = _exportHistorySearchController.text
              .trim()
              .toLowerCase();
          if (search.isEmpty) {
            return true;
          }
          return record.repoName.toLowerCase().contains(search) ||
              record.repoPath.toLowerCase().contains(search) ||
              record.profileName.toLowerCase().contains(search) ||
              record.exportedTo.toLowerCase().contains(search) ||
              record.exportedFiles.any(
                (file) => file.toLowerCase().contains(search),
              );
        })
        .toList(growable: false);
    final displayExports = visibleExports.take(6).toList(growable: false);

    return _panel(
      context,
      title: 'Export History',
      subtitle:
          'Browse the latest Omega OS exports, their manifest path, and copied report files.',
      child: _loadingExportHistory
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          : _exportHistory.isEmpty
          ? Text(
              'No export history has been recorded yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          : Column(
              children: [
                TextField(
                  controller: _exportHistorySearchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Search export history',
                    hintText: 'Repo, profile, export path, or file name',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                if (visibleExports.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No exports match the current search.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  )
                else
                  for (final record in displayExports) ...[
                    _ExportHistoryTile(
                      record: record,
                      onOpenExport: record.exportedTo.isEmpty
                          ? null
                          : () => _service.openFolder(record.exportedTo),
                      onOpenManifest: record.exportedTo.isEmpty
                          ? null
                          : () => _service.openPath(
                              pathJoin(
                                record.exportedTo,
                                'export_manifest.json',
                              ),
                            ),
                    ),
                    if (record != displayExports.last)
                      const SizedBox(height: 10),
                  ],
              ],
            ),
    );
  }

  Widget _bundlePreviewsCard(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1100;
    final previews = [
      _PreviewPanel(
        title: 'Main report',
        controller: _reportPreviewController,
        onOpen: _mainReportPath.isNotEmpty
            ? () => _openReportFile(_mainReportPath)
            : null,
      ),
      _PreviewPanel(
        title: 'Security report',
        controller: _securityPreviewController,
        onOpen: _securityReportPath.isNotEmpty
            ? () => _openReportFile(_securityReportPath)
            : null,
      ),
      _PreviewPanel(
        title: 'Comparison summary',
        controller: _comparisonPreviewController,
        onOpen: _comparisonReportPath.isNotEmpty
            ? () => _openReportFile(_comparisonReportPath)
            : null,
      ),
    ];

    return _panel(
      context,
      title: 'Bundle Previews',
      subtitle:
          'Read the latest generated report set without leaving the dashboard.',
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < previews.length; index++) ...[
                  Expanded(child: previews[index]),
                  if (index != previews.length - 1) const SizedBox(width: 12),
                ],
              ],
            )
          : Column(
              children: [
                for (var index = 0; index < previews.length; index++) ...[
                  previews[index],
                  if (index != previews.length - 1) const SizedBox(height: 12),
                ],
              ],
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

  Future<void> _loadProfileEditor() async {
    await _loadProfileEditorPath(
      _profileEditorPathController.text.trim().isEmpty
          ? _defaultProfilePath
          : _profileEditorPathController.text.trim(),
    );
  }

  Future<void> _loadProfileComparison() async {
    final leftPath = _profileCompareLeftPathController.text.trim().isEmpty
        ? _defaultProfilePath
        : _profileCompareLeftPathController.text.trim();
    final rightPath = _profileCompareRightPathController.text.trim().isEmpty
        ? pathJoin(_defaultProfilesDirectory, 'microgrow.profile.json')
        : _profileCompareRightPathController.text.trim();

    if (mounted) {
      setState(() {
        _loadingProfileComparison = true;
      });
    }

    try {
      final leftResult = await _readProfileFile(leftPath);
      final rightResult = await _readProfileFile(rightPath);
      if (!mounted) {
        return;
      }
      setState(() {
        _profileCompareLeftPathController.text = leftPath;
        _profileCompareRightPathController.text = rightPath;
        _profileCompareLeftController.text = leftResult.prettyJson;
        _profileCompareRightController.text = rightResult.prettyJson;
        _profileCompareSummaryController.text = _renderProfileComparisonSummary(
          leftPath: leftPath,
          rightPath: rightPath,
          leftJson: leftResult.decoded,
          rightJson: rightResult.decoded,
        );
        _profileComparisonStatus = rightResult.exists && leftResult.exists
            ? 'Compared $leftPath with $rightPath.'
            : 'One or both profile files were missing, so a starter template was used.';
      });
      _setMessage('Profile comparison loaded.');
    } catch (error) {
      _setMessage('Could not compare profile JSON: $error');
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfileComparison = false;
        });
      }
    }
  }

  Future<void> _compareProfiles() async {
    await _loadProfileComparison();
  }

  Future<void> _loadProfileEditorPath(String profilePath) async {
    if (profilePath.isEmpty) {
      _setMessage('Enter a profile JSON path first.');
      return;
    }

    if (mounted) {
      setState(() {
        _loadingProfileEditor = true;
      });
    }

    try {
      final file = File(profilePath);
      final exists = await file.exists();
      final text = exists
          ? await file.readAsString()
          : jsonEncode(
              {
                'profile_name': 'Generic',
                'project_type': 'generic local-first repository',
                'priority_keywords': [],
                'ignore_keywords': [],
                'useful_file_patterns': [],
                'risk_keywords': [],
                'output_focus': [],
                'export_targets': [],
                'export_locations': [],
                'report_templates': {},
              },
            );
      final pretty = _prettyJson(text);
      if (!mounted) {
        return;
      }
      setState(() {
        _profileEditorPathController.text = profilePath;
        _profileEditorController.text = pretty;
        _profileEditorStatus = exists
            ? 'Loaded profile JSON from $profilePath.'
            : 'Profile file not found, so a local template was loaded instead.';
      });
      _setMessage(exists ? 'Profile loaded.' : 'Loaded a starter profile template.');
    } catch (error) {
      _setMessage('Could not load profile JSON: $error');
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfileEditor = false;
        });
      }
    }
  }

  Future<void> _saveProfileEditor() async {
    final profilePath = _profileEditorPathController.text.trim();
    if (profilePath.isEmpty) {
      _setMessage('Enter a profile JSON path first.');
      return;
    }

    try {
      final decoded = jsonDecode(_profileEditorController.text);
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      final file = File(profilePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(pretty, flush: true);
      if (mounted) {
        setState(() {
          _profileEditorController.text = pretty;
          _profileEditorStatus = 'Saved profile JSON to $profilePath.';
        });
      }
      _setMessage('Profile saved.');
    } catch (error) {
      _setMessage('Could not save profile JSON: $error');
    }
  }

  void _applyTemplateSet(String templateSetName) {
    final preset = _templateSets.firstWhere(
      (item) => item.name == templateSetName,
      orElse: () => _templateSets.first,
    );
    try {
      final decoded = jsonDecode(_profileEditorController.text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Profile JSON must be an object');
      }
      decoded['report_templates'] = preset.templates;
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      setState(() {
        _profileEditorController.text = pretty;
        _profileEditorStatus = 'Applied ${preset.name} template set.';
      });
      _setMessage('Applied ${preset.name} template set.');
    } catch (error) {
      _setMessage('Could not apply template set: $error');
    }
  }

  void _applyProfilePreset(_ProfilePreset preset) {
    final currentOutput = _outputController.text.trim();
    final defaultOutput = _defaultOutputDirectory;
    final outputLooksDefault =
        currentOutput.isEmpty || currentOutput == defaultOutput;
    setState(() {
      _profileController.text = preset.profile;
      _compareProfileController.text = preset.profile;
      if (outputLooksDefault) {
        _outputController.text = pathJoin(defaultOutput, preset.outputFolder);
      }
    });
    _setMessage('Applied ${preset.label} preset.');
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
      final securityPreview = await _service.readFile(
        pathJoin(output, 'security_report.md'),
      );
      final comparisonPreview = await _service.readFile(
        pathJoin(output, 'repo_comparison.md'),
      );

      setState(() {
        _outputFiles = files;
        _reportPreviewController.text = preview;
        _securityPreviewController.text = securityPreview;
        _comparisonPreviewController.text = comparisonPreview;
        _mainReportPath = previewPath;
        _securityReportPath = pathJoin(output, 'security_report.md');
        _comparisonReportPath = pathJoin(output, 'repo_comparison.md');
        _logController.text = _renderLog(result);
        _lastRunLabel = result.succeeded
            ? 'Completed with exit code ${result.exitCode}'
            : 'Finished with exit code ${result.exitCode}';
        _lastRunTimestampLabel = _formatDateTime(DateTime.now());
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
        _lastRunTimestampLabel = _formatDateTime(DateTime.now());
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

  Future<void> _loadExportHistory() async {
    if (mounted) {
      setState(() {
        _loadingExportHistory = true;
      });
    }

    final exports = await _service.loadExportHistory();
    if (!mounted) {
      return;
    }
    setState(() {
      _exportHistory = exports;
      _loadingExportHistory = false;
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
        _lastRunLabel = run.succeeded
            ? 'Completed with exit code ${run.exitCode}'
            : 'Finished with exit code ${run.exitCode}';
        _lastRunTimestampLabel = run.parsedTimestamp == null
            ? run.timestamp
            : _formatDateTime(run.parsedTimestamp!);
        _mainReportPath = pathJoin(
          run.outputDirectory,
          'repo_research_report.md',
        );
        _securityReportPath = pathJoin(
          run.outputDirectory,
          'security_report.md',
        );
        _comparisonReportPath = pathJoin(
          run.outputDirectory,
          'repo_comparison.md',
        );
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

  Future<void> _openReportFile(String filePath) async {
    try {
      await _service.openPath(filePath);
    } catch (error) {
      _setMessage('Could not open report file: $error');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _prettyJson(String text) {
    try {
      final decoded = jsonDecode(text);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return text;
    }
  }

  Future<_ProfileReadResult> _readProfileFile(String profilePath) async {
    final file = File(profilePath);
    final exists = await file.exists();
    final text = exists
        ? await file.readAsString()
        : jsonEncode(
            {
              'profile_name': 'Generic',
              'project_type': 'generic local-first repository',
              'priority_keywords': [],
              'ignore_keywords': [],
              'useful_file_patterns': [],
              'risk_keywords': [],
              'output_focus': [],
              'export_targets': [],
              'export_locations': [],
              'report_templates': {},
            },
          );
    dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      decoded = {};
    }
    return _ProfileReadResult(
      exists: exists,
      prettyJson: _prettyJson(text),
      decoded: decoded,
    );
  }

  String _renderProfileComparisonSummary({
    required String leftPath,
    required String rightPath,
    required dynamic leftJson,
    required dynamic rightJson,
  }) {
    final differences = <String>[];
    _collectProfileDifferences(
      differences,
      leftJson,
      rightJson,
    );
    final summary = StringBuffer()
      ..writeln('Left: $leftPath')
      ..writeln('Right: $rightPath')
      ..writeln('Differences found: ${differences.length}')
      ..writeln('');
    if (differences.isEmpty) {
      summary.writeln('No structural differences were detected.');
    } else {
      for (final difference in differences.take(24)) {
        summary.writeln('- $difference');
      }
    }
    return summary.toString().trimRight();
  }

  void _collectProfileDifferences(
    List<String> differences,
    dynamic left,
    dynamic right, [
    String path = '',
  ]) {
    if (left is Map && right is Map) {
      final leftKeys = left.keys.map((key) => key.toString()).toSet();
      final rightKeys = right.keys.map((key) => key.toString()).toSet();
      for (final key in leftKeys.difference(rightKeys)) {
        differences.add('${_differencePath(path, key)} removed from left');
      }
      for (final key in rightKeys.difference(leftKeys)) {
        differences.add('${_differencePath(path, key)} added on right');
      }
      for (final key in leftKeys.intersection(rightKeys)) {
        _collectProfileDifferences(
          differences,
          left[key],
          right[key],
          _differencePath(path, key),
        );
      }
      return;
    }
    if (left is List && right is List) {
      if (left.length != right.length) {
        differences.add(
          '${path.isEmpty ? "root" : path}: list length ${left.length} vs ${right.length}',
        );
      }
      final shortest = left.length < right.length ? left.length : right.length;
      for (var index = 0; index < shortest; index++) {
        _collectProfileDifferences(
          differences,
          left[index],
          right[index],
          '$path[$index]',
        );
      }
      return;
    }
    if (left.toString() != right.toString()) {
      differences.add(
        '${path.isEmpty ? "root" : path}: ${left.toString()} vs ${right.toString()}',
      );
    }
  }

  String _differencePath(String prefix, String key) {
    if (prefix.isEmpty) {
      return key;
    }
    return '$prefix.$key';
  }

  String pathJoin(String left, String right) {
    if (left.endsWith(Platform.pathSeparator)) {
      return '$left$right';
    }
    return '$left${Platform.pathSeparator}$right';
  }
}

const List<_TemplateSetPreset> _templateSets = [
  _TemplateSetPreset(
    name: 'Generic',
    templates: {
      'main_report': 'repo_research_report.md',
      'summary': 'repo_summary.md',
      'security': 'security_report.md',
      'risk': 'risk_report.md',
      'knowledge': 'knowledge_report.md',
      'implementation_opportunities': 'implementation_opportunities.md',
      'learning_notes': 'learning_notes.md',
    },
  ),
  _TemplateSetPreset(
    name: 'New Earth Dashboard',
    templates: {
      'main_report': 'repo_research_report.md',
      'summary': 'repo_summary.md',
      'security': 'security_report.md',
      'risk': 'risk_report.md',
      'knowledge': 'knowledge_report.md',
      'implementation_opportunities': 'implementation_opportunities.md',
      'learning_notes': 'learning_notes.md',
    },
  ),
  _TemplateSetPreset(
    name: 'MicroGrow',
    templates: {
      'main_report': 'repo_research_report.md',
      'summary': 'repo_summary.md',
      'security': 'security_report.md',
      'risk': 'risk_report.md',
      'knowledge': 'knowledge_report.md',
      'implementation_opportunities': 'implementation_opportunities.md',
      'learning_notes': 'learning_notes.md',
    },
  ),
  _TemplateSetPreset(
    name: 'BioCalm',
    templates: {
      'main_report': 'repo_research_report.md',
      'summary': 'repo_summary.md',
      'security': 'security_report.md',
      'risk': 'risk_report.md',
      'knowledge': 'knowledge_report.md',
      'implementation_opportunities': 'implementation_opportunities.md',
      'learning_notes': 'learning_notes.md',
    },
  ),
];

class _TemplateSetPreset {
  const _TemplateSetPreset({
    required this.name,
    required this.templates,
  });

  final String name;
  final Map<String, String> templates;
}

class _ProfileReadResult {
  const _ProfileReadResult({
    required this.exists,
    required this.prettyJson,
    required this.decoded,
  });

  final bool exists;
  final String prettyJson;
  final dynamic decoded;
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

class _ProfilePreset {
  const _ProfilePreset({
    required this.label,
    required this.profile,
    required this.outputFolder,
  });

  final String label;
  final String profile;
  final String outputFolder;
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkText),
          ),
        ),
      ],
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

class _ReportHistoryTile extends StatelessWidget {
  const _ReportHistoryTile({
    required this.run,
    required this.onOpenBundle,
    required this.onOpenIndex,
  });

  final RepoResearchRunRecord run;
  final VoidCallback? onOpenBundle;
  final VoidCallback? onOpenIndex;

  @override
  Widget build(BuildContext context) {
    final timestamp = run.parsedTimestamp;
    final timestampLabel = timestamp == null
        ? run.timestamp
        : '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    final reportCount = run.reportFiles.length;
    final reportIndexPresent = run.reportFiles.contains(
      'report_search_index.md',
    );

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
                  run.outputDirectory.isEmpty
                      ? 'Unknown bundle'
                      : run.outputDirectory,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(label: reportIndexPresent ? 'Indexed' : 'No index'),
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
            'Files: $reportCount - Repo: ${run.repoPath}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final file in run.reportFiles.take(6))
                _StatusChip(label: file, muted: false),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onOpenBundle,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Bundle'),
              ),
              if (onOpenIndex != null)
                FilledButton.tonalIcon(
                  onPressed: onOpenIndex,
                  icon: const Icon(Icons.search),
                  label: const Text('Open Index'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportHistoryTile extends StatelessWidget {
  const _ExportHistoryTile({
    required this.record,
    required this.onOpenExport,
    required this.onOpenManifest,
  });

  final RepoResearchExportRecord record;
  final VoidCallback? onOpenExport;
  final VoidCallback? onOpenManifest;

  @override
  Widget build(BuildContext context) {
    final timestampLabel = record.exportedAt.isNotEmpty
        ? record.exportedAt
        : record.timestamp;
    final fileCount = record.exportedFiles.length;
    final promptCount = record.promptFiles.length;

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
                  record.exportedTo.isEmpty
                      ? 'Unknown export destination'
                      : record.exportedTo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(label: record.profileFolder, muted: false),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Profile: ${record.profileName} - $timestampLabel',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 4),
          Text(
            'Repo: ${record.repoName} - Files: $fileCount - Prompts: $promptCount',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final file in record.exportedFiles.take(6))
                _StatusChip(label: file, muted: false),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onOpenExport,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Export'),
              ),
              if (onOpenManifest != null)
                FilledButton.tonalIcon(
                  onPressed: onOpenManifest,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Open Manifest'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.title,
    required this.controller,
    this.onOpen,
  });

  final String title;
  final TextEditingController controller;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onOpen != null)
                TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Open'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              child: TextField(
                controller: controller,
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
        ],
      ),
    );
  }
}
