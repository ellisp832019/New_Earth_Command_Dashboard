import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/repo_research_engine_controller.dart';

class RepoResearchEngineScreen extends StatefulWidget {
  const RepoResearchEngineScreen({super.key, this.initialSection = 'home'});

  final String initialSection;

  @override
  State<RepoResearchEngineScreen> createState() =>
      _RepoResearchEngineScreenState();
}

class _RepoResearchEngineScreenState extends State<RepoResearchEngineScreen> {
  late final RepoResearchEngineRuntime _runtime =
      RepoResearchEngineRuntime.local();
  late final RepoResearchEngineController _service = _runtime.controller;
  late final ScrollController _scrollController = ScrollController();
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
  late final TextEditingController _cloneSourceController =
      TextEditingController();
  late final TextEditingController _workspaceRootController =
      TextEditingController(text: _defaultWorkspaceRoot);
  late final TextEditingController _cloneBranchController =
      TextEditingController();
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
  late final TextEditingController _knowledgePreviewController =
      TextEditingController();
  late final TextEditingController _releaseNotesPreviewController =
      TextEditingController();
  late final TextEditingController _bundleDeltaPreviewController =
      TextEditingController();
  late final TextEditingController _reportIndexPreviewController =
      TextEditingController();
  late final TextEditingController _changeTrackingPreviewController =
      TextEditingController();
  late final TextEditingController _dependencyGraphPreviewController =
      TextEditingController();
  late final TextEditingController _architectureGraphPreviewController =
      TextEditingController();
  late final TextEditingController _documentIndexPreviewController =
      TextEditingController();
  late final TextEditingController _riskPreviewController =
      TextEditingController();
  late final TextEditingController _licenseReviewPreviewController =
      TextEditingController();
  late final TextEditingController _vaultNotePreviewController =
      TextEditingController();
  late final TextEditingController _recentRunsSearchController =
      TextEditingController();
  late final TextEditingController _changeHistorySearchController =
      TextEditingController();
  late final TextEditingController _exportHistoryPreviewController =
      TextEditingController();
  late final TextEditingController _reportHistorySearchController =
      TextEditingController();
  late final TextEditingController _exportHistorySearchController =
      TextEditingController();
  late final TextEditingController _repositoryTreeSearchController =
      TextEditingController();

  bool _graphExport = true;
  bool _isCloning = false;
  bool _isRunning = false;
  List<String> _outputFiles = const [];
  List<RepoResearchCloneHistoryRecord> _recentClones = const [];
  List<RepoResearchRunRecord> _recentRuns = const [];
  List<RepoResearchChangeHistoryRecord> _changeHistory = const [];
  List<RepoResearchExportRecord> _exportHistory = const [];
  List<_TemplateSetPreset> _templateSets = const [];
  bool _loadingCloneHistory = true;
  bool _loadingRecentRuns = true;
  bool _loadingChangeHistory = true;
  bool _loadingExportHistory = true;
  bool _loadingProfileEditor = true;
  bool _loadingProfileComparison = true;
  bool _loadingTemplateSets = true;
  String _recentRunsFilter = 'all';
  String _exportHistoryFilter = 'all';
  String _reportHistoryFilter = 'all';
  String _lastRunLabel = 'No run yet';
  String _lastRunTimestampLabel = 'Not captured yet';
  String _dependencyGraphFilter = 'all';
  String _architectureGraphFilter = 'all';
  String _mainReportPath = '';
  String _securityReportPath = '';
  String _comparisonReportPath = '';
  String _knowledgeReportPath = '';
  String _releaseNotesPath = '';
  String _bundleDeltaPath = '';
  String _reportIndexPath = '';
  String _changeTrackingPath = '';
  String _dependencyGraphPath = '';
  String _architectureGraphPath = '';
  String _documentIndexPath = '';
  String _riskReportPath = '';
  String _exportHistoryPath = '';
  String _profileEditorStatus = 'Profile editor not loaded';
  String _profileComparisonStatus = 'Profile comparison not loaded';
  String _selectedTemplateSet = 'Generic';
  String _lastCloneStatus = 'No workspace clone yet';
  String _lastCloneSourcePath = '';
  late String _activeSection;
  Map<String, dynamic> _latestAnalysis = {};
  Map<String, dynamic> _latestComparison = {};
  Map<String, dynamic> _latestChangeTracking = {};
  Map<String, dynamic> _latestReleaseNotes = {};
  Map<String, dynamic> _latestBundleDelta = {};
  Map<String, dynamic> _latestReportIndex = {};
  Map<String, dynamic> _latestDependencyGraph = {};
  Map<String, dynamic> _latestArchitectureGraph = {};
  Map<String, dynamic> _latestRepositoryInventory = {};
  Map<String, dynamic> _latestRepositoryTree = {};

  final GlobalKey _heroSectionKey = GlobalKey();
  final GlobalKey _scannerSectionKey = GlobalKey();
  final GlobalKey _reportsSectionKey = GlobalKey();
  final GlobalKey _profilesSectionKey = GlobalKey();
  final GlobalKey _exportsSectionKey = GlobalKey();
  final GlobalKey _promptsSectionKey = GlobalKey();
  final GlobalKey _settingsSectionKey = GlobalKey();
  final GlobalKey _reportIndexSectionKey = GlobalKey();
  final GlobalKey _aiRagSectionKey = GlobalKey();
  final GlobalKey _bundlePreviewsSectionKey = GlobalKey();
  final GlobalKey _comparisonDrilldownSectionKey = GlobalKey();
  final GlobalKey _knowledgeSectionKey = GlobalKey();
  final GlobalKey _documentDiscoverySectionKey = GlobalKey();
  final GlobalKey _assetReviewSectionKey = GlobalKey();
  final GlobalKey _repositoryTreeSectionKey = GlobalKey();
  final GlobalKey _releaseNotesSectionKey = GlobalKey();
  final GlobalKey _bundleDeltaSectionKey = GlobalKey();
  final GlobalKey _changeTimelineSectionKey = GlobalKey();
  final GlobalKey _changeHistorySectionKey = GlobalKey();
  final GlobalKey _riskReviewSectionKey = GlobalKey();
  final GlobalKey _exportReviewSectionKey = GlobalKey();
  final GlobalKey _exportHistorySectionKey = GlobalKey();
  GlobalKey? _pendingSectionAnchorKey;

  String get _defaultOutputDirectory {
    final moduleRoot = _service.moduleRootDirectory();
    return '${moduleRoot.path}${Platform.pathSeparator}reports';
  }

  String get _defaultProfilesDirectory {
    final moduleRoot = _service.moduleRootDirectory();
    return '${moduleRoot.path}${Platform.pathSeparator}profiles';
  }

  String get _defaultWorkspaceRoot {
    final moduleRoot = _service.moduleRootDirectory();
    return '${moduleRoot.path}${Platform.pathSeparator}workspaces${Platform.pathSeparator}imports';
  }

  String get _defaultProfilePath {
    return pathJoin(_defaultProfilesDirectory, 'generic.profile.json');
  }

  String get _templateSetsPath {
    final moduleRoot = _service.moduleRootDirectory();
    return pathJoin(pathJoin(moduleRoot.path, 'config'), 'template_sets.json');
  }

  _TemplateSetPreset? get _selectedTemplateSetPreset {
    for (final preset in _templateSets) {
      if (preset.name == _selectedTemplateSet) {
        return preset;
      }
    }
    return _templateSets.isNotEmpty ? _templateSets.first : null;
  }

  String get _exportHistoryMarkdownPath {
    final moduleRoot = _service.moduleRootDirectory();
    return pathJoin(pathJoin(moduleRoot.path, 'reports'), 'export_history.md');
  }

  @override
  void initState() {
    super.initState();
    _activeSection = _normalizeSection(widget.initialSection);
    _loadCloneHistory();
    _loadRecentRuns();
    _loadChangeHistory();
    _loadExportHistory();
    _loadTemplateSets();
    _loadProfileEditor();
    _loadProfileComparison();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveSection();
    });
  }

  @override
  void didUpdateWidget(covariant RepoResearchEngineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextSection = _normalizeSection(widget.initialSection);
    if (nextSection != _activeSection) {
      _activeSection = nextSection;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveSection();
        _scrollToPendingSectionAnchor();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _repoPathController.dispose();
    _profileController.dispose();
    _outputController.dispose();
    _omegaRootController.dispose();
    _compareWithController.dispose();
    _baselineController.dispose();
    _compareProfileController.dispose();
    _cloneSourceController.dispose();
    _workspaceRootController.dispose();
    _cloneBranchController.dispose();
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
    _knowledgePreviewController.dispose();
    _releaseNotesPreviewController.dispose();
    _bundleDeltaPreviewController.dispose();
    _reportIndexPreviewController.dispose();
    _changeTrackingPreviewController.dispose();
    _dependencyGraphPreviewController.dispose();
    _architectureGraphPreviewController.dispose();
    _documentIndexPreviewController.dispose();
    _riskPreviewController.dispose();
    _licenseReviewPreviewController.dispose();
    _vaultNotePreviewController.dispose();
    _recentRunsSearchController.dispose();
    _changeHistorySearchController.dispose();
    _exportHistoryPreviewController.dispose();
    _reportHistorySearchController.dispose();
    _exportHistorySearchController.dispose();
    _repositoryTreeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;

    return WorkspaceShell(
      title: 'Repo Research Engine',
      subtitle: _buildAppBarSubtitle(),
      onBack: _isRunning ? null : () => context.go(RouteNames.more),
      trailingActions: [
        TextButton.icon(
          onPressed: _isRunning ? null : () => context.go(RouteNames.more),
          icon: const Icon(Icons.arrow_back),
          label: const Text('More'),
        ),
      ],
      child: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(isWide ? 24 : 16),
          children: _buildSectionContent(context, isWide),
        ),
      ),
    );
  }

  String _buildAppBarSubtitle() {
    final sectionLabel = switch (_activeSection) {
      'scanner' => 'Repository Scanner',
      'reports' => 'Research Reports',
      'profiles' => 'Profile Manager',
      'exports' => 'Knowledge Vault Exports',
      'prompts' => 'Codex Prompt Generator',
      'settings' => 'Settings',
      _ => 'Home',
    };

    return sectionLabel;
  }

  List<Widget> _buildSectionContent(BuildContext context, bool isWide) {
    return switch (_activeSection) {
      'scanner' => _buildScannerContent(context, isWide),
      'reports' => _buildReportsContent(context, isWide),
      'profiles' => _buildProfilesContent(context),
      'exports' => _buildExportsContent(context, isWide),
      'prompts' => _buildPromptsContent(context),
      'settings' => _buildSettingsContent(context),
      'ai-rag' => _buildSettingsContent(context),
      _ => _buildHomeContent(context, isWide),
    };
  }

  List<Widget> _buildHomeContent(BuildContext context, bool isWide) {
    return [
      _heroCard(context),
      const SizedBox(height: 16),
      _homeSectionLauncherCard(context),
      const SizedBox(height: 16),
      if (isWide)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _recentRunsCard(context)),
            const SizedBox(width: 16),
            Expanded(child: _recentImportsCard(context)),
          ],
        )
      else ...[
        _recentRunsCard(context),
        const SizedBox(height: 16),
        _recentImportsCard(context),
      ],
    ];
  }

  List<Widget> _buildScannerContent(BuildContext context, bool isWide) {
    return [
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
      _workspaceCloneCard(context),
      const SizedBox(height: 16),
      _cloneHistoryCard(context),
      const SizedBox(height: 16),
      _comparisonInsightsCard(context),
      const SizedBox(height: 16),
      _riskReviewCard(context),
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
      _recentRunsCard(context),
    ];
  }

  List<Widget> _buildReportsContent(BuildContext context, bool isWide) {
    return [
      _heroCard(context),
      const SizedBox(height: 16),
      _reportPreviewCard(context),
      const SizedBox(height: 16),
      _reportDeepLinksCard(context),
      const SizedBox(height: 16),
      _bundlePreviewsCard(context, key: _bundlePreviewsSectionKey),
      const SizedBox(height: 16),
      _comparisonDrilldownCard(context, key: _comparisonDrilldownSectionKey),
      const SizedBox(height: 16),
      _knowledgeCard(context, key: _knowledgeSectionKey),
      const SizedBox(height: 16),
      _documentDiscoveryCard(context, key: _documentDiscoverySectionKey),
      const SizedBox(height: 16),
      _assetReviewCard(context, key: _assetReviewSectionKey),
      const SizedBox(height: 16),
      _repositoryTreeCard(context, key: _repositoryTreeSectionKey),
      const SizedBox(height: 16),
      _reportIndexCard(context, key: _reportIndexSectionKey),
      const SizedBox(height: 16),
      _releaseNotesCard(context, key: _releaseNotesSectionKey),
      const SizedBox(height: 16),
      _bundleDeltaCard(context, key: _bundleDeltaSectionKey),
      const SizedBox(height: 16),
      _reportHistoryCard(context),
      const SizedBox(height: 16),
      _recentRunsCard(context),
    ];
  }

  List<Widget> _buildProfilesContent(BuildContext context) {
    return [
      _heroCard(context),
      const SizedBox(height: 16),
      _profileTemplateLibraryCard(context),
      const SizedBox(height: 16),
      _profileEditorCard(context),
      const SizedBox(height: 16),
      _profileComparisonCard(context),
    ];
  }

  List<Widget> _buildExportsContent(BuildContext context, bool isWide) {
    return [
      _heroCard(context),
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
      _bundlePreviewsCard(context, key: _bundlePreviewsSectionKey),
      const SizedBox(height: 16),
      _exportReviewCard(context, key: _exportReviewSectionKey),
      const SizedBox(height: 16),
      _graphReviewCard(context),
      const SizedBox(height: 16),
      _changeTimelineCard(context, key: _changeTimelineSectionKey),
      const SizedBox(height: 16),
      _changeHistoryCard(context, key: _changeHistorySectionKey),
      const SizedBox(height: 16),
      _exportHistoryCard(context, key: _exportHistorySectionKey),
    ];
  }

  List<Widget> _buildPromptsContent(BuildContext context) {
    return [
      _heroCard(context),
      const SizedBox(height: 16),
      _promptsCard(context),
      const SizedBox(height: 16),
      _sourceRegistryCard(context),
      const SizedBox(height: 16),
      _aiRagCard(context),
      const SizedBox(height: 16),
      _reportIndexCard(context),
    ];
  }

  List<Widget> _buildSettingsContent(BuildContext context) {
    return [
      _heroCard(context),
      const SizedBox(height: 16),
      _settingsCard(context),
      const SizedBox(height: 16),
      _sourceRegistryCard(context),
      const SizedBox(height: 16),
      _aiRagCard(context),
    ];
  }

  String _normalizeSection(String section) {
    final lower = section.trim().toLowerCase();
    return switch (lower) {
      'scanner' => 'scanner',
      'reports' => 'reports',
      'profiles' => 'profiles',
      'exports' => 'exports',
      'prompts' => 'prompts',
      'settings' => 'settings',
      'ai-rag' => 'ai-rag',
      _ => 'home',
    };
  }

  GlobalKey _sectionKeyFor(String section) {
    return switch (section) {
      'scanner' => _scannerSectionKey,
      'reports' => _reportsSectionKey,
      'profiles' => _profilesSectionKey,
      'exports' => _exportsSectionKey,
      'prompts' => _promptsSectionKey,
      'settings' => _settingsSectionKey,
      'ai-rag' => _aiRagSectionKey,
      _ => _heroSectionKey,
    };
  }

  void _scrollToActiveSection() {
    final target = _sectionKeyFor(_activeSection);
    final targetContext = target.currentContext;
    if (targetContext == null) {
      return;
    }
    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.05,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToPendingSectionAnchor() {
    final target = _pendingSectionAnchorKey;
    if (target == null) {
      return;
    }
    final targetContext = target.currentContext;
    if (targetContext == null) {
      return;
    }
    _pendingSectionAnchorKey = null;
    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.05,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _navigateToSection(String section, {GlobalKey? anchorKey}) {
    final normalized = _normalizeSection(section);
    final previousSection = _activeSection;
    setState(() {
      _activeSection = normalized;
      _pendingSectionAnchorKey = anchorKey;
    });
    final route = switch (normalized) {
      'scanner' => RouteNames.repoResearchEngineScanner,
      'reports' => RouteNames.repoResearchEngineReports,
      'profiles' => RouteNames.repoResearchEngineProfiles,
      'exports' => RouteNames.repoResearchEngineExports,
      'prompts' => RouteNames.repoResearchEnginePrompts,
      'settings' => RouteNames.repoResearchEngineSettings,
      'ai-rag' => RouteNames.repoResearchEngineSettings,
      _ => RouteNames.repoResearchEngine,
    };
    context.go(route);
    if (anchorKey != null && previousSection == normalized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToPendingSectionAnchor();
      });
    }
  }

  Widget _heroCard(BuildContext context) {
    return _panel(
      context,
      key: _heroSectionKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final sectionNav = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sectionNavButton(
                context,
                'Home',
                'home',
                Icons.dashboard_outlined,
              ),
              _sectionNavButton(
                context,
                'Scanner',
                'scanner',
                Icons.travel_explore_outlined,
              ),
              _sectionNavButton(
                context,
                'Reports',
                'reports',
                Icons.description_outlined,
              ),
              _sectionNavButton(
                context,
                'Profiles',
                'profiles',
                Icons.tune_outlined,
              ),
              _sectionNavButton(
                context,
                'Exports',
                'exports',
                Icons.upload_outlined,
              ),
              _sectionNavButton(
                context,
                'Prompts',
                'prompts',
                Icons.draw_outlined,
              ),
              _sectionNavButton(
                context,
                'Settings',
                'settings',
                Icons.settings_outlined,
              ),
              _sectionNavButton(
                context,
                'AI/RAG',
                'ai-rag',
                Icons.auto_awesome_outlined,
              ),
            ],
          );
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
              const SizedBox(height: 14),
              sectionNav,
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

  Widget _homeSectionLauncherCard(BuildContext context) {
    final sections = [
      _HomeSectionLaunch(
        title: 'Scanner',
        description: 'Clone, scan, and compare local repos safely.',
        icon: Icons.travel_explore_outlined,
        section: 'scanner',
      ),
      _HomeSectionLaunch(
        title: 'Reports',
        description:
            'Review knowledge notes, report previews, and release outputs.',
        icon: Icons.description_outlined,
        section: 'reports',
      ),
      _HomeSectionLaunch(
        title: 'Profiles',
        description: 'Inspect reusable profile JSON and template sets.',
        icon: Icons.tune_outlined,
        section: 'profiles',
      ),
      _HomeSectionLaunch(
        title: 'Exports',
        description: 'Review bundles before they are copied into Omega OS.',
        icon: Icons.upload_outlined,
        section: 'exports',
      ),
      _HomeSectionLaunch(
        title: 'Prompts',
        description: 'Generate Codex prompts and view source registries.',
        icon: Icons.draw_outlined,
        section: 'prompts',
      ),
      _HomeSectionLaunch(
        title: 'Settings',
        description: 'Adjust local paths, templates, and registry notes.',
        icon: Icons.settings_outlined,
        section: 'settings',
      ),
    ];

    return _panel(
      context,
      title: 'Section Launcher',
      subtitle:
          'The home page stays calm and points each detailed workflow to its own page.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          final crossAxisCount = wide ? 3 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sections.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: wide ? 2.8 : 4.2,
            ),
            itemBuilder: (context, index) {
              final item = sections[index];
              return _HomeSectionTile(
                launch: item,
                onTap: () => _navigateToSection(item.section),
              );
            },
          );
        },
      ),
    );
  }

  Widget _recentImportsCard(BuildContext context) {
    final visibleClones = _recentClones.take(4).toList(growable: false);
    return _panel(
      context,
      title: 'Recent Imports',
      subtitle:
          'Recent structured workspace imports stay close to the home overview.',
      child: _loadingCloneHistory
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          : visibleClones.isEmpty
          ? Text(
              'No clone history has been recorded yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          : Column(
              children: [
                for (final record in visibleClones) ...[
                  _CloneHistoryTile(
                    record: record,
                    onLoad: () => _loadCloneIntoForm(record),
                    onOpenSource: record.sourceRoot.isEmpty
                        ? null
                        : () => _service.openFolder(record.sourceRoot),
                    onOpenWorkspace: record.workspaceRoot.isEmpty
                        ? null
                        : () => _service.openFolder(record.workspaceRoot),
                  ),
                  if (record != visibleClones.last) const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Widget _scannerCard(BuildContext context) {
    return _panel(
      context,
      key: _scannerSectionKey,
      title: 'Repository Scanner',
      subtitle:
          'Choose a local repo path and generate the safe research bundle.',
      child: Column(
        children: [
          _field(
            controller: _repoPathController,
            label: 'Repository path',
            hint: r'D:\Projects\example-repo',
            helperText: _repoPathWarning(_repoPathController.text.trim()),
            onChanged: (_) => setState(() {}),
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

  Widget _workspaceCloneCard(BuildContext context) {
    final workspaceRoot = _workspaceRootController.text.trim().isEmpty
        ? _defaultWorkspaceRoot
        : _workspaceRootController.text.trim();
    return _panel(
      context,
      title: 'Clone Into Workspace',
      subtitle:
          'Clone a remote Git source or local repository into a structured local workspace before scanning.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            controller: _cloneSourceController,
            label: 'Source URL or local repo',
            hint: r'https://github.com/owner/repo.git or D:\path\to\repo',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _field(
            controller: _workspaceRootController,
            label: 'Workspace root',
            hint: _defaultWorkspaceRoot,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _field(
            controller: _cloneBranchController,
            label: 'Branch (optional)',
            hint: 'main',
          ),
          const SizedBox(height: 12),
          _MetadataRow(label: 'Workspace layout', value: workspaceRoot),
          const SizedBox(height: 8),
          _MetadataRow(label: 'Last clone', value: _lastCloneStatus),
          if (_lastCloneSourcePath.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MetadataRow(label: 'Source folder', value: _lastCloneSourcePath),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _isCloning ? null : _cloneAndScan,
                  icon: _isCloning
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.file_download_outlined),
                  label: const Text('Clone + Scan'),
                ),
                OutlinedButton.icon(
                  onPressed: _isCloning ? null : _cloneIntoWorkspace,
                  icon: const Icon(Icons.folder_copy),
                  label: const Text('Clone Only'),
                ),
                TextButton.icon(
                  onPressed: workspaceRoot.isEmpty
                      ? null
                      : () => _service.openFolder(workspaceRoot),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open Workspace Root'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cloneHistoryCard(BuildContext context) {
    final visibleClones = _recentClones.take(6).toList(growable: false);
    return _panel(
      context,
      title: 'Recent Imports',
      subtitle:
          'Reopen previously imported workspaces without retyping the source URL.',
      child: _loadingCloneHistory
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          : visibleClones.isEmpty
          ? Text(
              'No clone history has been recorded yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          : Column(
              children: [
                for (final record in visibleClones) ...[
                  _CloneHistoryTile(
                    record: record,
                    onLoad: () => _loadCloneIntoForm(record),
                    onOpenSource: record.sourceRoot.isEmpty
                        ? null
                        : () => _service.openFolder(record.sourceRoot),
                    onOpenWorkspace: record.workspaceRoot.isEmpty
                        ? null
                        : () => _service.openFolder(record.workspaceRoot),
                  ),
                  if (record != visibleClones.last) const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Widget _profileEditorCard(BuildContext context) {
    return _panel(
      context,
      key: _profilesSectionKey,
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
                  initialValue:
                      _templateSets.any(
                        (preset) => preset.name == _selectedTemplateSet,
                      )
                      ? _selectedTemplateSet
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Report template set',
                  ),
                  items: _templateSets
                      .map(
                        (preset) => DropdownMenuItem<String>(
                          value: preset.name,
                          child: Text(
                            preset.description.isNotEmpty
                                ? '${preset.name} - ${preset.description}'
                                : preset.name,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (_isRunning || _loadingTemplateSets)
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
                if (_loadingTemplateSets) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Loading template set registry...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                ],
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
                          : () =>
                                _service.openFolder(_defaultProfilesDirectory),
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
                  hint: pathJoin(
                    _defaultProfilesDirectory,
                    'microgrow.profile.json',
                  ),
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
                          : () =>
                                _service.openFolder(_defaultProfilesDirectory),
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
      key: _exportsSectionKey,
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

  Widget _reportPreviewCard(BuildContext context, {Key? key}) {
    return _panel(
      context,
      key: key ?? _reportsSectionKey,
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
    final search = _reportHistorySearchController.text.trim().toLowerCase();
    final visibleRuns = _recentRuns
        .where((run) => _matchesReportHistoryFilter(run, search))
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
                DropdownButtonFormField<String>(
                  initialValue: _reportHistoryFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter report history by',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Any field')),
                    DropdownMenuItem(
                      value: 'output',
                      child: Text('Output directory'),
                    ),
                    DropdownMenuItem(value: 'repo', child: Text('Repository')),
                    DropdownMenuItem(value: 'profile', child: Text('Profile')),
                    DropdownMenuItem(
                      value: 'files',
                      child: Text('Generated files'),
                    ),
                  ],
                  onChanged: (_isRunning || _loadingRecentRuns)
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _reportHistoryFilter = value;
                          });
                        },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reportHistorySearchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Search report history',
                    hintText: 'Search within the selected field scope',
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

  bool _matchesReportHistoryFilter(RepoResearchRunRecord run, String search) {
    if (search.isEmpty) {
      return true;
    }
    final scope = _reportHistoryFilter;
    return switch (scope) {
      'output' => run.outputDirectory.toLowerCase().contains(search),
      'repo' => run.repoPath.toLowerCase().contains(search),
      'profile' => run.profile.toLowerCase().contains(search),
      'files' => run.reportFiles.any(
        (file) => file.toLowerCase().contains(search),
      ),
      _ =>
        run.outputDirectory.toLowerCase().contains(search) ||
            run.repoPath.toLowerCase().contains(search) ||
            run.profile.toLowerCase().contains(search) ||
            run.reportFiles.any((file) => file.toLowerCase().contains(search)),
    };
  }

  Widget _exportHistoryCard(BuildContext context, {Key? key}) {
    final search = _exportHistorySearchController.text.trim().toLowerCase();
    final visibleExports = _exportHistory
        .where((record) => _matchesExportHistoryFilter(record, search))
        .toList(growable: false);
    final displayExports = visibleExports.take(6).toList(growable: false);

    return _panel(
      context,
      key: key ?? _exportHistorySectionKey,
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
                if (_exportHistory.isNotEmpty) ...[
                  _MetadataRow(
                    label: 'Latest export',
                    value:
                        '${_exportHistory.first.profileName} - ${_exportHistory.first.exportedTo}',
                  ),
                  const SizedBox(height: 8),
                  _MetadataRow(
                    label: 'History file',
                    value: _exportHistoryPath.isEmpty
                        ? 'Export history markdown not loaded'
                        : _exportHistoryPath,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _exportHistoryPreviewController,
                        readOnly: true,
                        maxLines: null,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColours.darkText,
                          fontFamily: 'monospace',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _exportHistoryPath.isEmpty
                        ? null
                        : () => _service.openPath(_exportHistoryPath),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open export history'),
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  initialValue: _exportHistoryFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter export history by',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Any field')),
                    DropdownMenuItem(
                      value: 'profile',
                      child: Text('Profile name'),
                    ),
                    DropdownMenuItem(
                      value: 'repo',
                      child: Text('Repository path'),
                    ),
                    DropdownMenuItem(
                      value: 'folder',
                      child: Text('Export folder'),
                    ),
                    DropdownMenuItem(
                      value: 'files',
                      child: Text('Copied files'),
                    ),
                  ],
                  onChanged: (_isRunning || _loadingExportHistory)
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _exportHistoryFilter = value;
                          });
                        },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _exportHistorySearchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Search export history',
                    hintText: 'Search within the selected field scope',
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

  bool _matchesExportHistoryFilter(
    RepoResearchExportRecord record,
    String search,
  ) {
    if (search.isEmpty) {
      return true;
    }
    final scope = _exportHistoryFilter;
    return switch (scope) {
      'profile' => record.profileName.toLowerCase().contains(search),
      'repo' => record.repoPath.toLowerCase().contains(search),
      'folder' => record.exportedTo.toLowerCase().contains(search),
      'files' => record.exportedFiles.any(
        (file) => file.toLowerCase().contains(search),
      ),
      _ =>
        record.repoName.toLowerCase().contains(search) ||
            record.repoPath.toLowerCase().contains(search) ||
            record.profileName.toLowerCase().contains(search) ||
            record.exportedTo.toLowerCase().contains(search) ||
            record.exportedFiles.any(
              (file) => file.toLowerCase().contains(search),
            ),
    };
  }

  Widget _bundlePreviewsCard(BuildContext context, {Key? key}) {
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
      key: key ?? _bundlePreviewsSectionKey,
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

  Widget _reportDeepLinksCard(BuildContext context) {
    return _panel(
      context,
      title: 'Report Deep Links',
      subtitle:
          'Jump directly to the exact report card or bundle view without losing your place.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetadataRow(
            label: 'Report views',
            value:
                'Main report, knowledge extraction, document discovery, report index, release notes, bundle delta, change timeline, change history, and risk review.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _deepLinkButton(
                context,
                label: 'Main report',
                icon: Icons.description_outlined,
                section: 'reports',
                anchorKey: _reportsSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Bundle views',
                icon: Icons.view_carousel_outlined,
                section: 'reports',
                anchorKey: _bundlePreviewsSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Comparison drilldown',
                icon: Icons.compare_arrows,
                section: 'reports',
                anchorKey: _comparisonDrilldownSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Knowledge',
                icon: Icons.auto_awesome_outlined,
                section: 'reports',
                anchorKey: _knowledgeSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Documents',
                icon: Icons.folder_copy_outlined,
                section: 'reports',
                anchorKey: _documentDiscoverySectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Report index',
                icon: Icons.search,
                section: 'reports',
                anchorKey: _reportIndexSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Release notes',
                icon: Icons.article_outlined,
                section: 'exports',
                anchorKey: _releaseNotesSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Bundle delta',
                icon: Icons.swap_horiz_outlined,
                section: 'exports',
                anchorKey: _bundleDeltaSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Change timeline',
                icon: Icons.timeline_outlined,
                section: 'exports',
                anchorKey: _changeTimelineSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Change history',
                icon: Icons.history_outlined,
                section: 'exports',
                anchorKey: _changeHistorySectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Risk review',
                icon: Icons.privacy_tip_outlined,
                section: 'exports',
                anchorKey: _riskReviewSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Export review',
                icon: Icons.upload_outlined,
                section: 'exports',
                anchorKey: _exportReviewSectionKey,
              ),
              _deepLinkButton(
                context,
                label: 'Export history',
                icon: Icons.folder_open_outlined,
                section: 'exports',
                anchorKey: _exportHistorySectionKey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _markdownPreviewCard(
    BuildContext context, {
    Key? key,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    String? openPath,
    String openLabel = 'Open file',
  }) {
    return _panel(
      context,
      key: key,
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (openPath != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _openReportFile(openPath),
              icon: const Icon(Icons.open_in_new),
              label: Text(openLabel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _deepLinkButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String section,
    required GlobalKey anchorKey,
  }) {
    return TextButton.icon(
      onPressed: _isRunning
          ? null
          : () => _navigateToSection(section, anchorKey: anchorKey),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _knowledgeCard(BuildContext context, {Key? key}) {
    final knowledge = _latestAnalysis['knowledge'] is Map<String, dynamic>
        ? _latestAnalysis['knowledge'] as Map<String, dynamic>
        : <String, dynamic>{};
    final reusableComponents = _stringList(knowledge['reusable_components']);
    final risks = _stringList(knowledge['risks']);
    final recommendations = _stringList(knowledge['recommendations']);
    final implementationIdeas = _stringList(
      _latestAnalysis['implementation_ideas'],
    );
    final learningNotes = _stringList(_latestAnalysis['learning_notes']);
    final projectSummary = _latestAnalysis['project_summary']
        ?.toString()
        .trim();
    final architectureSummary = _latestAnalysis['architecture_summary']
        ?.toString()
        .trim();

    return _panel(
      context,
      key: key ?? _knowledgeSectionKey,
      title: 'Knowledge Extraction',
      subtitle:
          'Summaries, reusable components, risks, recommendations, and learning notes from the latest local analysis.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: '${reusableComponents.length} reusable components',
                muted: false,
              ),
              _StatusChip(label: '${risks.length} risks', muted: false),
              _StatusChip(
                label: '${recommendations.length} recommendations',
                muted: false,
              ),
              _StatusChip(
                label: '${implementationIdeas.length} implementation ideas',
                muted: false,
              ),
              _StatusChip(
                label: '${learningNotes.length} learning notes',
                muted: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _knowledgeInsightBlock(
            context,
            title: 'Project Summary',
            subtitle: 'A concise overview of the repository focus and scope.',
            body: projectSummary?.isNotEmpty == true
                ? projectSummary!
                : 'No summary loaded',
          ),
          const SizedBox(height: 12),
          _knowledgeInsightBlock(
            context,
            title: 'Architecture Summary',
            subtitle:
                'A reviewable snapshot of the system structure and shape.',
            body: architectureSummary?.isNotEmpty == true
                ? architectureSummary!
                : 'No architecture summary loaded',
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Reusable Components',
            leftItems: reusableComponents,
            rightTitle: 'Implementation Ideas',
            rightItems: implementationIdeas,
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Risks',
            leftItems: risks,
            rightTitle: 'Recommendations',
            rightItems: recommendations,
          ),
          const SizedBox(height: 12),
          _knowledgeInsightBlock(
            context,
            title: 'Learning Notes',
            subtitle: 'Working notes captured from the latest local analysis.',
            body: learningNotes.isEmpty
                ? 'No learning notes were captured.'
                : learningNotes.map((item) => '- $item').join('\n'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              child: TextField(
                controller: _knowledgePreviewController,
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
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _knowledgeReportPath.isEmpty
                ? null
                : () => _openReportFile(_knowledgeReportPath),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open knowledge report'),
          ),
        ],
      ),
    );
  }

  Widget _knowledgeInsightBlock(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentDiscoveryCard(BuildContext context, {Key? key}) {
    final documentIndex = _latestAnalysis['document_index'] is List
        ? List<Map<String, dynamic>>.from(
            (_latestAnalysis['document_index'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final imageAssets = _latestAnalysis['image_assets'] is List
        ? List<Map<String, dynamic>>.from(
            (_latestAnalysis['image_assets'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final diagramFiles = _latestAnalysis['diagram_files'] is List
        ? List<Map<String, dynamic>>.from(
            (_latestAnalysis['diagram_files'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];

    return _panel(
      context,
      key: key ?? _documentDiscoverySectionKey,
      title: 'Document Index Review',
      subtitle:
          'Review indexed documents, headings, links, tables, and notes discovered during the safe scan.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: '${documentIndex.length} documents',
                muted: false,
              ),
              _StatusChip(
                label:
                    '${_documentIndexFieldCount(documentIndex, 'headings')} headings',
                muted: false,
              ),
              _StatusChip(
                label:
                    '${_documentIndexFieldCount(documentIndex, 'links')} links',
                muted: false,
              ),
              _StatusChip(
                label:
                    '${_documentIndexFieldCount(documentIndex, 'tables')} tables',
                muted: false,
              ),
              _StatusChip(
                label:
                    '${_documentIndexFieldCount(documentIndex, 'notes')} notes',
                muted: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bulletSection(
            context,
            'Indexed Documents',
            documentIndex
                .take(8)
                .map((item) => _renderDocumentIndexSummary(item))
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Headings',
            leftItems: _documentIndexFieldPreview(documentIndex, 'headings'),
            rightTitle: 'Links',
            rightItems: _documentIndexFieldPreview(documentIndex, 'links'),
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Tables',
            leftItems: _documentIndexFieldPreview(documentIndex, 'tables'),
            rightTitle: 'Notes',
            rightItems: _documentIndexFieldPreview(documentIndex, 'notes'),
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Image Assets',
            leftItems: imageAssets
                .take(8)
                .map(
                  (item) =>
                      '${item['path']} - ${item['asset_type'] ?? 'image'}',
                )
                .toList(growable: false),
            rightTitle: 'Diagram Files',
            rightItems: diagramFiles
                .take(8)
                .map(
                  (item) =>
                      '${item['path']} - ${item['diagram_type'] ?? 'diagram'}',
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              child: TextField(
                controller: _documentIndexPreviewController,
                readOnly: true,
                maxLines: null,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkText,
                  fontFamily: 'monospace',
                ),
                decoration: const InputDecoration(
                  labelText: 'Document index report preview',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _documentIndexPath.isEmpty
                ? null
                : () => _openReportFile(_documentIndexPath),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open document index report'),
          ),
        ],
      ),
    );
  }

  int _documentIndexFieldCount(
    List<Map<String, dynamic>> documents,
    String field,
  ) {
    var count = 0;
    for (final document in documents) {
      final values = document[field];
      if (values is List) {
        count += values
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .length;
      }
    }
    return count;
  }

  List<String> _documentIndexFieldPreview(
    List<Map<String, dynamic>> documents,
    String field,
  ) {
    final results = <String>[];
    for (final document in documents) {
      final source = document['title']?.toString().isNotEmpty == true
          ? document['title'].toString()
          : document['path']?.toString().isNotEmpty == true
          ? document['path'].toString()
          : 'Unknown document';
      final values = document[field];
      if (values is List) {
        for (final value in values) {
          final text = _documentIndexValueText(value);
          if (text.isEmpty) {
            continue;
          }
          results.add('$source - $text');
        }
      }
    }
    if (results.isEmpty) {
      return const ['No items discovered.'];
    }
    return results.take(8).toList(growable: false);
  }

  String _documentIndexValueText(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final path = map['path']?.toString().isNotEmpty == true
          ? map['path'].toString()
          : map['text']?.toString().isNotEmpty == true
          ? map['text'].toString()
          : map['label']?.toString().isNotEmpty == true
          ? map['label'].toString()
          : '';
      if (path.isNotEmpty) {
        return path;
      }
      final entries = map.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .toList(growable: false);
      return entries.join(', ');
    }
    return value?.toString().trim() ?? '';
  }

  String _renderDocumentIndexSummary(Map<String, dynamic> document) {
    final path = document['path']?.toString().isNotEmpty == true
        ? document['path'].toString()
        : 'Unknown document';
    final title = document['title']?.toString().isNotEmpty == true
        ? document['title'].toString()
        : '';
    final headings = _stringList(document['headings']);
    final links = _stringList(document['links']);
    final tables = _stringList(document['tables']);
    final notes = _stringList(document['notes']);
    final pieces = <String>[
      if (title.isNotEmpty) title,
      if (headings.isNotEmpty) '${headings.length} headings',
      if (links.isNotEmpty) '${links.length} links',
      if (tables.isNotEmpty) '${tables.length} tables',
      if (notes.isNotEmpty) '${notes.length} notes',
    ];
    if (pieces.isEmpty) {
      return path;
    }
    return '$path - ${pieces.join(' - ')}';
  }

  Widget _assetReviewCard(BuildContext context, {Key? key}) {
    final imageAssets = _latestAnalysis['image_assets'] is List
        ? List<Map<String, dynamic>>.from(
            (_latestAnalysis['image_assets'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final diagramFiles = _latestAnalysis['diagram_files'] is List
        ? List<Map<String, dynamic>>.from(
            (_latestAnalysis['diagram_files'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final screenshotAssets = _assetFilter(imageAssets, [
      'screenshot',
      'screen',
      'capture',
    ]);
    final iconAssets = _assetFilter(imageAssets, ['icon', 'glyph', 'symbol']);
    final designAssets = _assetFilter(imageAssets, [
      'design',
      'mockup',
      'layout',
      'ui',
    ]);
    final flaggedAssets = [
      ...imageAssets.where(_assetIsFlagged),
      ...diagramFiles.where(_assetIsFlagged),
    ];

    return _panel(
      context,
      key: key ?? _assetReviewSectionKey,
      title: 'Image and Diagram Asset Review',
      subtitle:
          'Review screenshots, icons, design assets, and diagram files without parsing binaries.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(label: '${imageAssets.length} images', muted: false),
              _StatusChip(
                label: '${diagramFiles.length} diagrams',
                muted: false,
              ),
              _StatusChip(
                label: '${screenshotAssets.length} screenshots',
                muted: false,
              ),
              _StatusChip(label: '${iconAssets.length} icons', muted: false),
              _StatusChip(
                label: '${designAssets.length} design assets',
                muted: false,
              ),
              _StatusChip(
                label: '${flaggedAssets.length} flagged',
                muted: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Screenshots',
            leftItems: _assetPreviewItems(
              screenshotAssets,
              defaultLabel: 'screenshot',
            ),
            rightTitle: 'Icons',
            rightItems: _assetPreviewItems(iconAssets, defaultLabel: 'icon'),
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Design Assets',
            leftItems: _assetPreviewItems(
              designAssets,
              defaultLabel: 'design asset',
            ),
            rightTitle: 'Diagrams',
            rightItems: _assetPreviewItems(
              diagramFiles,
              defaultLabel: 'diagram',
              typeField: 'diagram_type',
            ),
          ),
          const SizedBox(height: 12),
          _bulletSection(
            context,
            'Flagged Binaries',
            flaggedAssets.isEmpty
                ? const ['No flagged binaries were discovered.']
                : flaggedAssets
                      .take(8)
                      .map(_assetPreviewSummary)
                      .toList(growable: false),
          ),
          const SizedBox(height: 12),
          Text(
            'Binaries are listed for review only; the module does not parse them.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
        ],
      ),
    );
  }

  bool _assetIsFlagged(Map<String, dynamic> item) {
    final values = [
      item['binary'],
      item['is_binary'],
      item['flagged'],
      item['suspicious'],
      item['flagged_as_binary'],
      item['binary_file'],
    ];
    for (final value in values) {
      if (value is bool && value) {
        return true;
      }
      final text = value?.toString().trim().toLowerCase() ?? '';
      if ([
        'true',
        'yes',
        '1',
        'flagged',
        'binary',
        'suspicious',
      ].contains(text)) {
        return true;
      }
    }
    final summary = _assetSearchText(item);
    return summary.contains('binary') || summary.contains('suspicious');
  }

  List<Map<String, dynamic>> _assetFilter(
    List<Map<String, dynamic>> assets,
    List<String> keywords,
  ) {
    if (assets.isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    return assets
        .where((asset) {
          final haystack = _assetSearchText(asset);
          return keywords.any((keyword) => haystack.contains(keyword));
        })
        .toList(growable: false);
  }

  List<String> _assetPreviewItems(
    List<Map<String, dynamic>> assets, {
    required String defaultLabel,
    String typeField = 'asset_type',
  }) {
    if (assets.isEmpty) {
      return const ['No items discovered.'];
    }
    return assets
        .take(8)
        .map((item) {
          final path = item['path']?.toString().isNotEmpty == true
              ? item['path'].toString()
              : 'Unknown asset';
          final type = item[typeField]?.toString().isNotEmpty == true
              ? item[typeField].toString()
              : defaultLabel;
          return '$path - $type';
        })
        .toList(growable: false);
  }

  String _assetPreviewSummary(Map<String, dynamic> item) {
    final path = item['path']?.toString().isNotEmpty == true
        ? item['path'].toString()
        : 'Unknown asset';
    final type = item['asset_type']?.toString().isNotEmpty == true
        ? item['asset_type'].toString()
        : item['diagram_type']?.toString().isNotEmpty == true
        ? item['diagram_type'].toString()
        : 'binary asset';
    final notes = <String>[];
    if (item['notes']?.toString().isNotEmpty == true) {
      notes.add(item['notes'].toString());
    }
    if (item['category']?.toString().isNotEmpty == true) {
      notes.add(item['category'].toString());
    }
    if (notes.isEmpty) {
      return '$path - $type';
    }
    return '$path - $type - ${notes.join(' - ')}';
  }

  String _assetSearchText(Map<String, dynamic> item) {
    return [
      item['path'],
      item['title'],
      item['asset_type'],
      item['diagram_type'],
      item['category'],
      item['kind'],
      item['notes'],
      item['label'],
    ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');
  }

  Widget _repositoryTreeCard(BuildContext context, {Key? key}) {
    final tree = _latestRepositoryTree;
    final inventory = _latestRepositoryInventory;
    final search = _repositoryTreeSearchController.text.trim().toLowerCase();
    final topLevel = _repositoryTreeNodeChildren(tree);
    final visibleTopLevel = search.isEmpty
        ? topLevel
        : topLevel
              .where((node) => _repositoryTreeNodeVisible(node, search))
              .toList(growable: false);
    final languageCounts = inventory['language_counts'] is Map
        ? Map<String, dynamic>.from(inventory['language_counts'] as Map)
        : <String, dynamic>{};
    final categoryCounts = inventory['category_counts'] is Map
        ? Map<String, dynamic>.from(inventory['category_counts'] as Map)
        : <String, dynamic>{};

    return _panel(
      context,
      key: key ?? _repositoryTreeSectionKey,
      title: 'Repository Tree Explorer',
      subtitle:
          'Search the local repository tree by folder, file, language, or category and expand only the matching branches.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: '${_comparisonCount(inventory['file_count'])} files',
                muted: false,
              ),
              _StatusChip(
                label:
                    '${_comparisonCount(inventory['directory_count'])} folders',
                muted: false,
              ),
              _StatusChip(
                label: '${_comparisonCount(languageCounts)} languages',
                muted: false,
              ),
              _StatusChip(
                label: '${_comparisonCount(categoryCounts)} categories',
                muted: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _repositoryTreeSearchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Search repository tree',
              hintText: 'Folder, file, language, or category',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Top-Level Nodes',
            leftItems: visibleTopLevel.isEmpty
                ? const ['No tree nodes match the current search.']
                : visibleTopLevel
                      .take(8)
                      .map(_repositoryTreeSummary)
                      .toList(growable: false),
            rightTitle: 'Languages / Categories',
            rightItems: _repositoryTreeSummaryPairs(
              languageCounts,
              categoryCounts,
            ),
          ),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'Repository root',
            value: tree['name']?.toString().isNotEmpty == true
                ? tree['name'].toString()
                : 'No repository tree loaded',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 460,
            child: SingleChildScrollView(
              child: tree.isEmpty
                  ? Text(
                      'No repository tree JSON has been loaded yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    )
                  : _repositoryTreeNodeView(
                      context,
                      tree,
                      search: search,
                      depth: 0,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _repositoryTreeNodeChildren(
    Map<String, dynamic> node,
  ) {
    final children = node['children'] is List
        ? (node['children'] as List).whereType<Map>().toList()
        : <Map>[];
    return children
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  bool _repositoryTreeNodeVisible(Map<String, dynamic> node, String search) {
    if (search.isEmpty) {
      return true;
    }
    if (_repositoryTreeNodeSearchText(node).contains(search)) {
      return true;
    }
    for (final child in _repositoryTreeNodeChildren(node)) {
      if (_repositoryTreeNodeVisible(child, search)) {
        return true;
      }
    }
    return false;
  }

  String _repositoryTreeNodeSearchText(Map<String, dynamic> node) {
    return [
      node['name'],
      node['path'],
      node['kind'],
      node['language'],
      node['category'],
      node['suffix'],
      node['flags'],
    ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');
  }

  Widget _repositoryTreeNodeView(
    BuildContext context,
    Map<String, dynamic> node, {
    required String search,
    required int depth,
  }) {
    final children = _repositoryTreeNodeChildren(node)
        .where((child) => _repositoryTreeNodeVisible(child, search))
        .toList(growable: false);
    final isDirectory = node['kind']?.toString() == 'directory';
    final nodeName = node['name']?.toString().isNotEmpty == true
        ? node['name'].toString()
        : 'Unknown node';
    final nodePath = node['path']?.toString().isNotEmpty == true
        ? node['path'].toString()
        : nodeName;
    final fileCount = _comparisonCount(node['file_count']);
    final directoryCount = _comparisonCount(node['directory_count']);
    if (search.isNotEmpty &&
        !_repositoryTreeNodeSearchText(node).contains(search) &&
        children.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!isDirectory) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 12.0),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.insert_drive_file_outlined, size: 18),
          title: Text(nodeName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '$nodePath - ${node['language'] ?? node['category'] ?? 'file'}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _StatusChip(
            label: '${node['suffix'] ?? 'file'}',
            muted: false,
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(left: depth == 0 ? 0 : 8),
      child: ExpansionTile(
        key: PageStorageKey<String>(nodePath),
        initiallyExpanded: depth < 1 || search.isNotEmpty,
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        childrenPadding: const EdgeInsets.only(left: 8),
        leading: const Icon(Icons.folder_open_outlined),
        title: Text(nodeName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '$nodePath - $fileCount files, $directoryCount folders',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: children.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    search.isNotEmpty
                        ? 'No matching children found.'
                        : 'No child nodes recorded.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                ),
              ]
            : [
                for (final child in children)
                  _repositoryTreeNodeView(
                    context,
                    child,
                    search: search,
                    depth: depth + 1,
                  ),
              ],
      ),
    );
  }

  List<String> _repositoryTreeSummaryPairs(
    Map<String, dynamic> languageCounts,
    Map<String, dynamic> categoryCounts,
  ) {
    final entries = <MapEntry<String, int>>[];
    for (final entry in languageCounts.entries) {
      entries.add(MapEntry(entry.key, _comparisonCount(entry.value)));
    }
    entries.sort((left, right) => right.value.compareTo(left.value));
    final languages = entries.take(4).map((entry) {
      final value = entry.value;
      return '${entry.key} - $value files';
    });

    final categoryEntries = <MapEntry<String, int>>[];
    for (final entry in categoryCounts.entries) {
      categoryEntries.add(MapEntry(entry.key, _comparisonCount(entry.value)));
    }
    categoryEntries.sort((left, right) => right.value.compareTo(left.value));
    final categories = categoryEntries.take(4).map((entry) {
      final value = entry.value;
      return '${entry.key} - $value files';
    });

    final results = <String>[...languages, ...categories];
    if (results.isEmpty) {
      return const ['No summary data available.'];
    }
    return results.toList(growable: false);
  }

  String _repositoryTreeSummary(Map<String, dynamic> node) {
    final name = node['name']?.toString().isNotEmpty == true
        ? node['name'].toString()
        : 'Unknown node';
    final path = node['path']?.toString().isNotEmpty == true
        ? node['path'].toString()
        : name;
    final fileCount = _comparisonCount(node['file_count']);
    final directoryCount = _comparisonCount(node['directory_count']);
    final kind = node['kind']?.toString().isNotEmpty == true
        ? node['kind'].toString()
        : 'node';
    return '$path - $kind - $fileCount files, $directoryCount folders';
  }

  Widget _reportIndexCard(BuildContext context, {Key? key}) {
    return _panel(
      context,
      key: key ?? _reportIndexSectionKey,
      title: 'Report Search Index',
      subtitle: 'Searchable index of the generated report bundle.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetadataRow(
            label: 'Report count',
            value:
                _latestReportIndex['report_count']?.toString().isNotEmpty ==
                    true
                ? _latestReportIndex['report_count'].toString()
                : 'No index loaded',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: SingleChildScrollView(
              child: TextField(
                controller: _reportIndexPreviewController,
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
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _reportIndexPath.isEmpty
                ? null
                : () => _openReportFile(_reportIndexPath),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open report index'),
          ),
        ],
      ),
    );
  }

  Widget _releaseNotesCard(BuildContext context, {Key? key}) {
    return _panel(
      context,
      key: key ?? _releaseNotesSectionKey,
      title: 'Release Notes',
      subtitle: 'Roll-up of comparison, change tracking, and release checks.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetadataRow(
            label: 'Comparison summary',
            value:
                _latestReleaseNotes['comparison_summary']
                        ?.toString()
                        .isNotEmpty ==
                    true
                ? _latestReleaseNotes['comparison_summary'].toString()
                : 'No comparison summary loaded',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              child: TextField(
                controller: _releaseNotesPreviewController,
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
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _releaseNotesPath.isEmpty
                ? null
                : () => _openReportFile(_releaseNotesPath),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open release notes'),
          ),
        ],
      ),
    );
  }

  Widget _bundleDeltaCard(BuildContext context, {Key? key}) {
    return _panel(
      context,
      key: key ?? _bundleDeltaSectionKey,
      title: 'Bundle Delta Summary',
      subtitle: 'What changed between the latest bundle and the previous run.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetadataRow(
            label: 'Summary',
            value: _latestBundleDelta['summary']?.toString().isNotEmpty == true
                ? _latestBundleDelta['summary'].toString()
                : 'No bundle delta loaded',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              child: TextField(
                controller: _bundleDeltaPreviewController,
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
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _bundleDeltaPath.isEmpty
                ? null
                : () => _openReportFile(_bundleDeltaPath),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open bundle delta'),
          ),
        ],
      ),
    );
  }

  Widget _changeTimelineCard(BuildContext context, {Key? key}) {
    return _panel(
      context,
      key: key ?? _changeTimelineSectionKey,
      title: 'Change Tracking Timeline',
      subtitle:
          'File additions, removals, modifications, and risk shifts across the latest baseline comparison.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetadataRow(
            label: 'Summary',
            value:
                _latestChangeTracking['summary']?.toString().isNotEmpty == true
                ? _latestChangeTracking['summary'].toString()
                : 'No change tracking loaded',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: SingleChildScrollView(
              child: TextField(
                controller: _changeTrackingPreviewController,
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
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _changeTrackingPath.isEmpty
                ? null
                : () => _openReportFile(_changeTrackingPath),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open change tracking'),
          ),
        ],
      ),
    );
  }

  Widget _changeHistoryCard(BuildContext context, {Key? key}) {
    final visibleRecords = _changeHistory
        .where((record) {
          final search = _changeHistorySearchController.text
              .trim()
              .toLowerCase();
          if (search.isEmpty) {
            return true;
          }
          return record.currentRepo.toLowerCase().contains(search) ||
              record.baselineRepo.toLowerCase().contains(search) ||
              record.baselineInventoryPath.toLowerCase().contains(search) ||
              record.summary.toLowerCase().contains(search) ||
              record.fileChangeSummary.toLowerCase().contains(search);
        })
        .toList(growable: false);
    final displayRecords = visibleRecords.take(6).toList(growable: false);
    final latestRecord = displayRecords.isNotEmpty
        ? displayRecords.first
        : null;

    return _panel(
      context,
      key: key ?? _changeHistorySectionKey,
      title: 'Change History',
      subtitle:
          'Browse the explicit baseline inventory path and change summary for the latest tracked comparisons.',
      child: _loadingChangeHistory
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          : _changeHistory.isEmpty
          ? Text(
              'No change history has been recorded yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          : Column(
              children: [
                TextField(
                  controller: _changeHistorySearchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Search change history',
                    hintText: 'Current repo, baseline, path, or summary',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                _twoColumnBulletBlock(
                  context,
                  leftTitle: 'Timeline Entries',
                  leftItems: ['${visibleRecords.length} visible records'],
                  rightTitle: 'Latest Baseline',
                  rightItems: [
                    latestRecord?.baselineInventoryPath.isNotEmpty == true
                        ? latestRecord!.baselineInventoryPath
                        : 'No baseline recorded',
                  ],
                ),
                const SizedBox(height: 12),
                if (visibleRecords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No change history entries match the current search.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  )
                else
                  for (
                    var index = 0;
                    index < displayRecords.length;
                    index++
                  ) ...[
                    _ChangeHistoryTile(
                      record: displayRecords[index],
                      isFirst: index == 0,
                      isLast: index == displayRecords.length - 1,
                      onOpenBaseline:
                          displayRecords[index].baselineInventoryPath.isEmpty
                          ? null
                          : () => _service.openPath(
                              displayRecords[index].baselineInventoryPath,
                            ),
                    ),
                    if (index != displayRecords.length - 1)
                      const SizedBox(height: 10),
                  ],
              ],
            ),
    );
  }

  Widget _graphReviewCard(BuildContext context) {
    final dependencyGraph = _latestDependencyGraph;
    final architectureGraph = _latestArchitectureGraph;
    final dependencySummary = _latestAnalysis['dependency_summary'] is Map
        ? Map<String, dynamic>.from(
            _latestAnalysis['dependency_summary'] as Map,
          )
        : <String, dynamic>{};
    final frameworkGroups = dependencySummary['framework_groups'] is List
        ? List<Map<String, dynamic>>.from(
            (dependencySummary['framework_groups'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final manifestDrilldowns = dependencySummary['manifest_drilldowns'] is List
        ? List<Map<String, dynamic>>.from(
            (dependencySummary['manifest_drilldowns'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final dependencyFilterOptions = _graphFilterOptions(dependencyGraph);
    final architectureFilterOptions = _graphFilterOptions(architectureGraph);
    final dependencyFilter =
        dependencyFilterOptions.contains(_dependencyGraphFilter)
        ? _dependencyGraphFilter
        : 'all';
    final architectureFilter =
        architectureFilterOptions.contains(_architectureGraphFilter)
        ? _architectureGraphFilter
        : 'all';

    return _panel(
      context,
      title: 'Graph Review',
      subtitle:
          'Dependency and architecture graph previews from the latest safe run.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Dependency Graph Summary',
            leftItems: _graphSummaryItems(dependencyGraph),
            rightTitle: 'Architecture Graph Summary',
            rightItems: _graphSummaryItems(architectureGraph),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1000;
              final dependencyPanel = _graphDrilldownPanel(
                context,
                title: 'Dependency Drilldown',
                subtitle:
                    'Filter frameworks, manifests, and dependencies by kind.',
                graph: dependencyGraph,
                filterOptions: dependencyFilterOptions,
                selectedFilter: dependencyFilter,
                onFilterChanged: (value) {
                  if (value == null || value == _dependencyGraphFilter) {
                    return;
                  }
                  setState(() {
                    _dependencyGraphFilter = value;
                  });
                },
                nodeSectionTitle: 'Dependency Nodes',
                edgeSectionTitle: 'Dependency Edges',
                includeAnchors: false,
              );
              final architecturePanel = _graphDrilldownPanel(
                context,
                title: 'Architecture Drilldown',
                subtitle:
                    'Filter categories, languages, files, directories, and risk anchors.',
                graph: architectureGraph,
                filterOptions: architectureFilterOptions,
                selectedFilter: architectureFilter,
                onFilterChanged: (value) {
                  if (value == null || value == _architectureGraphFilter) {
                    return;
                  }
                  setState(() {
                    _architectureGraphFilter = value;
                  });
                },
                nodeSectionTitle: 'Architecture Nodes',
                edgeSectionTitle: 'Architecture Edges',
                includeAnchors: true,
              );
              if (!wide) {
                return Column(
                  children: [
                    dependencyPanel,
                    const SizedBox(height: 12),
                    architecturePanel,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: dependencyPanel),
                  const SizedBox(width: 12),
                  Expanded(child: architecturePanel),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _architectureReviewCard(
            context,
            graph: architectureGraph,
            selectedFilter: architectureFilter,
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Framework Groups',
            leftItems: frameworkGroups
                .take(6)
                .map(
                  (item) =>
                      '${item['framework'] ?? 'Unknown'} - ${item['dependency_count'] ?? 0} dependencies',
                )
                .toList(growable: false),
            rightTitle: 'Runtime Drilldowns',
            rightItems: manifestDrilldowns
                .take(6)
                .map(
                  (item) =>
                      '${item['runtime'] ?? 'Unknown'} - ${item['dependency_count'] ?? 0} dependencies',
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          _bulletSection(
            context,
            'Architecture Key Anchors',
            _graphAnchorItems(architectureGraph, kind: architectureFilter),
          ),
          const SizedBox(height: 12),
          _markdownPreviewCard(
            context,
            title: 'Dependency Graph',
            subtitle: 'Graph file generated by the local analysis run.',
            controller: _dependencyGraphPreviewController,
            openPath: _dependencyGraphPath,
            openLabel: 'Open dependency graph',
          ),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'Dependency focus',
            value: dependencyFilter == 'all'
                ? 'Showing all dependency node kinds'
                : 'Showing only $dependencyFilter nodes',
          ),
          const SizedBox(height: 12),
          _markdownPreviewCard(
            context,
            title: 'Architecture Graph',
            subtitle: 'Graph file highlighting node groups and key anchors.',
            controller: _architectureGraphPreviewController,
            openPath: _architectureGraphPath,
            openLabel: 'Open architecture graph',
          ),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'Architecture focus',
            value: architectureFilter == 'all'
                ? 'Showing all architecture node kinds'
                : 'Showing only $architectureFilter nodes',
          ),
        ],
      ),
    );
  }

  Widget _exportReviewCard(BuildContext context, {Key? key}) {
    final outputDirectory = _outputController.text.trim().isEmpty
        ? _defaultOutputDirectory
        : _outputController.text.trim();
    final promptsDirectory = pathJoin(outputDirectory, 'generated_prompts');
    final reportBundle = [
      'repo_research_report.md',
      'repo_summary.md',
      'security_report.md',
      'risk_report.md',
      'knowledge_report.md',
      'implementation_opportunities.md',
      'learning_notes.md',
      'repo_comparison.md',
      'change_tracking.md',
      'change_history.md',
      'dependency_graph.md',
      'architecture_graph.md',
      'release_notes.md',
      'bundle_delta_summary.md',
    ];
    final vaultHandoff = [
      'license_review.md',
      'vault_note.md',
      'export_manifest.json',
    ];
    final structuredOutputs = [
      'analysis.json',
      'scan_manifest.json',
      'repo_inventory.json',
      'repository_tree.json',
      'repo_comparison.json',
      'change_tracking.json',
      'change_history.json',
      'dependency_graph.json',
      'architecture_graph.json',
      'comparison_analysis.json',
      'report_template_selection.json',
      'report_search_index.json',
      'release_notes.json',
      'bundle_delta_summary.json',
    ];
    return _panel(
      context,
      key: key ?? _exportReviewSectionKey,
      title: 'Export Review',
      subtitle:
          'Confirm what will be copied to the Knowledge Vault and review the masked licence notes before export.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _StatusChip(label: 'Review first', muted: false),
              _StatusChip(label: 'Masked output only', muted: false),
              _StatusChip(label: 'Local copy only', muted: false),
              _StatusChip(label: 'No code execution', muted: false),
            ],
          ),
          const SizedBox(height: 12),
          _exportArtifactGroup(
            context,
            title: 'Report bundle',
            subtitle:
                'These markdown reports and review notes are copied into the local export bundle.',
            items: reportBundle,
          ),
          const SizedBox(height: 12),
          _exportArtifactGroup(
            context,
            title: 'Vault handoff',
            subtitle:
                'These files are the explicit Knowledge Vault transfer layer and stay reviewable before copy.',
            items: vaultHandoff,
          ),
          const SizedBox(height: 12),
          _exportArtifactGroup(
            context,
            title: 'Structured outputs',
            subtitle:
                'These JSON manifests and indexes stay local and give the export bundle its traceable shape.',
            items: structuredOutputs,
          ),
          const SizedBox(height: 12),
          _panel(
            context,
            title: 'Export Controls',
            subtitle:
                'Open the exact workspace, prompts folder, or manifest before anything is copied onward.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => _service.openFolder(outputDirectory),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open export folder'),
                ),
                TextButton.icon(
                  onPressed: () => _service.openPath(
                    pathJoin(outputDirectory, 'export_manifest.json'),
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Open export manifest'),
                ),
                TextButton.icon(
                  onPressed: () => _service.openFolder(promptsDirectory),
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Open prompt pack'),
                ),
                if (_omegaRootController.text.trim().isNotEmpty)
                  TextButton.icon(
                    onPressed: () =>
                        _service.openFolder(_omegaRootController.text.trim()),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('Open Omega OS root'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _markdownPreviewCard(
            context,
            title: 'Licence Review',
            subtitle: 'Detected licence candidates and their review status.',
            controller: _licenseReviewPreviewController,
            openPath: pathJoin(outputDirectory, 'license_review.md'),
            openLabel: 'Open licence review',
          ),
          const SizedBox(height: 12),
          _markdownPreviewCard(
            context,
            title: 'Vault Note',
            subtitle: 'Local export note prepared for the Knowledge Vault.',
            controller: _vaultNotePreviewController,
            openPath: pathJoin(outputDirectory, 'vault_note.md'),
            openLabel: 'Open vault note',
          ),
        ],
      ),
    );
  }

  Widget _exportArtifactGroup(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items) _StatusChip(label: item, muted: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comparisonInsightsCard(BuildContext context) {
    final comparison = _latestComparison;
    final dependencyChanges = comparison['dependency_changes'] is Map
        ? Map<String, dynamic>.from(comparison['dependency_changes'] as Map)
        : <String, dynamic>{};
    final frameworkChanges = comparison['framework_changes'] is Map
        ? Map<String, dynamic>.from(comparison['framework_changes'] as Map)
        : <String, dynamic>{};
    final licenseChanges = comparison['license_changes'] is Map
        ? Map<String, dynamic>.from(comparison['license_changes'] as Map)
        : <String, dynamic>{};
    final addedFiles = _comparisonFileSnapshots('added');
    final removedFiles = _comparisonFileSnapshots('removed');
    final modifiedFiles = _comparisonModifiedSummaries();
    final currentRepo =
        comparison['current_repo']?.toString().isNotEmpty == true
        ? comparison['current_repo'].toString()
        : 'Current repo not loaded';
    final otherRepo = comparison['other_repo']?.toString().isNotEmpty == true
        ? comparison['other_repo'].toString()
        : 'Comparison target not loaded';
    final fileDelta =
        _comparisonCount(comparison['files_added']) -
        _comparisonCount(comparison['files_removed']);
    final directoryDelta = _comparisonCount(
      comparison['directory_count_delta'],
    );

    return _panel(
      context,
      title: 'Comparison Insights',
      subtitle:
          'Clear repo-to-repo deltas, dependency changes, and risk shifts from the latest comparison run.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: '${_comparisonCount(comparison['files_added'])} added',
                muted: false,
              ),
              _StatusChip(
                label:
                    '${_comparisonCount(comparison['files_removed'])} removed',
                muted: false,
              ),
              _StatusChip(
                label:
                    '${_comparisonCount(comparison['files_modified'])} modified',
                muted: false,
              ),
              _StatusChip(
                label: '${_comparisonCount(comparison['files_shared'])} shared',
                muted: false,
              ),
              _StatusChip(
                label: '${_comparisonCount(dependencyChanges['added'])} deps +',
                muted: false,
              ),
              _StatusChip(
                label:
                    '${_comparisonCount(dependencyChanges['removed'])} deps -',
                muted: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Compared Repositories',
            leftItems: [currentRepo],
            rightTitle: 'Comparison Target',
            rightItems: [otherRepo],
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'File Delta',
            leftItems: ['${fileDelta >= 0 ? '+' : ''}$fileDelta files'],
            rightTitle: 'Directory Delta',
            rightItems: [
              '${directoryDelta >= 0 ? '+' : ''}$directoryDelta dirs',
            ],
          ),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'Comparison summary',
            value: comparison['summary']?.toString().isNotEmpty == true
                ? comparison['summary'].toString()
                : 'No comparison loaded',
          ),
          const SizedBox(height: 8),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'File Additions',
            leftItems: addedFiles,
            rightTitle: 'File Removals',
            rightItems: removedFiles,
          ),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'Shared / Modified',
            value:
                '${_comparisonCount(comparison['files_shared'])} shared files, '
                '${_comparisonCount(comparison['files_modified'])} modified files',
          ),
          const SizedBox(height: 8),
          _bulletSection(context, 'Modified Files', modifiedFiles),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Dependencies Added',
            leftItems: _stringList(dependencyChanges['added']),
            rightTitle: 'Dependencies Removed',
            rightItems: _stringList(dependencyChanges['removed']),
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Frameworks Added',
            leftItems: _stringList(frameworkChanges['added']),
            rightTitle: 'Frameworks Removed',
            rightItems: _stringList(frameworkChanges['removed']),
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Licences Added',
            leftItems: _stringList(licenseChanges['added']),
            rightTitle: 'Licences Removed',
            rightItems: _stringList(licenseChanges['removed']),
          ),
          const SizedBox(height: 12),
          _bulletSection(
            context,
            'Recommendations',
            _stringList(comparison['recommendations']),
          ),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'Review note',
            value:
                'Treat dependency, framework, and licence deltas as manual review cues before copying anything across.',
          ),
        ],
      ),
    );
  }

  Widget _comparisonDrilldownCard(BuildContext context, {Key? key}) {
    final comparison = _latestComparison;
    final addedItems = _comparisonDetailItems('added');
    final removedItems = _comparisonDetailItems('removed');
    final modifiedItems = _comparisonDetailItems('modified');
    final sharedCount = _comparisonCount(comparison['files_shared']);

    return _panel(
      context,
      key: key ?? _comparisonDrilldownSectionKey,
      title: 'Comparison Drilldown',
      subtitle:
          'Inspect the file-level deltas from the latest comparison report without opening the raw JSON first.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _twoColumnBulletBlock(
            context,
            leftTitle: 'File Additions',
            leftItems: addedItems,
            rightTitle: 'File Removals',
            rightItems: removedItems,
          ),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'Shared Files',
            value: '$sharedCount shared files reviewed in the comparison set.',
          ),
          const SizedBox(height: 8),
          _bulletSection(context, 'Modified File Details', modifiedItems),
          const SizedBox(height: 12),
          _markdownPreviewCard(
            context,
            title: 'Comparison Report',
            subtitle:
                'Local markdown comparison report generated by the last safe run.',
            controller: _comparisonPreviewController,
            openPath: _comparisonReportPath,
            openLabel: 'Open comparison report',
          ),
        ],
      ),
    );
  }

  Widget _sourceRegistryCard(BuildContext context) {
    const repoSources = ['GitHub', 'GitLab', 'Bitbucket'];
    const researchSources = ['PDF', 'Website', 'Transcript', 'Documentation'];

    return _panel(
      context,
      title: 'Source Adapter Registry',
      subtitle:
          'Read-only source contracts stay local-first until a source is explicitly chosen.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bulletSection(context, 'Repository Sources', repoSources),
          const SizedBox(height: 12),
          _bulletSection(context, 'Research Sources', researchSources),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'AI/RAG',
            value:
                'See the dedicated local AI and RAG registry card for the active offline defaults.',
          ),
        ],
      ),
    );
  }

  Widget _aiRagCard(BuildContext context) {
    const providers = ['DeterministicLocal (default)'];
    const indexes = ['InMemoryLocal (default)'];

    return _panel(
      context,
      key: _aiRagSectionKey,
      title: 'Local AI and RAG Registry',
      subtitle:
          'The module exposes explicit local-first extension points while keeping the safe offline defaults in place.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatusChip(label: 'Local-first defaults', muted: false),
          const SizedBox(height: 8),
          const _StatusChip(label: 'No network required', muted: false),
          const SizedBox(height: 12),
          _bulletSection(context, 'Supported AI Providers', providers),
          const SizedBox(height: 12),
          _bulletSection(context, 'Supported RAG Indexes', indexes),
          const SizedBox(height: 8),
          const _MetadataRow(
            label: 'Extension points',
            value:
                'Future providers and indexes stay opt-in, local-first, and registry-backed.',
          ),
        ],
      ),
    );
  }

  Widget _profileTemplateLibraryCard(BuildContext context) {
    final selectedPreset = _selectedTemplateSetPreset;
    return _panel(
      context,
      title: 'Template Library',
      subtitle:
          'Quick-select report template sets and keep the profile format editable as JSON.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: '${_templateSets.length} template sets',
                muted: false,
              ),
              if (selectedPreset != null)
                _StatusChip(
                  label: 'Selected: ${selectedPreset.name}',
                  muted: false,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_templateSets.isEmpty)
            Text(
              'Template families are still loading.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final preset in _templateSets)
                  SizedBox(
                    width: 320,
                    child: _templatePresetCard(context, preset),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _templatePresetCard(BuildContext context, _TemplateSetPreset preset) {
    final isSelected = preset.name == _selectedTemplateSet;
    final templateEntries = preset.templates.entries.toList(growable: false);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColours.darkSurface.withValues(alpha: 0.98)
            : AppColours.darkSurfaceRaised.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? AppColours.darkSecondary.withValues(alpha: 0.8)
              : AppColours.darkOutline.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  preset.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected) const _StatusChip(label: 'Active', muted: false),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            preset.description.isNotEmpty
                ? preset.description
                : 'No description supplied.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in templateEntries.take(4))
                _StatusChip(
                  label: '${entry.key}: ${entry.value}',
                  muted: false,
                ),
            ],
          ),
          if (templateEntries.length > 4) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${templateEntries.length - 4} more templates',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: _isRunning
                    ? null
                    : () {
                        setState(() {
                          _selectedTemplateSet = preset.name;
                        });
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Select'),
              ),
              FilledButton.tonalIcon(
                onPressed: _isRunning
                    ? null
                    : () => _applyTemplateSet(preset.name),
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _riskReviewCard(BuildContext context, {Key? key}) {
    return _markdownPreviewCard(
      context,
      key: key ?? _riskReviewSectionKey,
      title: 'Risk Review',
      subtitle:
          'Security, secret masking, suspicious script review, and licence follow-up notes.',
      controller: _riskPreviewController,
      openPath: _riskReportPath,
    );
  }

  Widget _bulletSection(
    BuildContext context,
    String title,
    List<String> items,
  ) {
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
          if (items.isEmpty)
            Text(
              'No items available.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            for (final item in items.take(8)) ...[
              Text(
                '- $item',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColours.darkText),
              ),
            ],
        ],
      ),
    );
  }

  Widget _twoColumnBulletBlock(
    BuildContext context, {
    required String leftTitle,
    required List<String> leftItems,
    required String rightTitle,
    required List<String> rightItems,
  }) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final left = _bulletSection(context, leftTitle, leftItems);
    final right = _bulletSection(context, rightTitle, rightItems);
    if (!wide) {
      return Column(children: [left, const SizedBox(height: 12), right]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    if (value == null) {
      return const <String>[];
    }
    return <String>[value.toString()];
  }

  List<String> _comparisonFileSnapshots(String bucket) {
    final details = _latestComparison['file_details'] is Map
        ? Map<String, dynamic>.from(_latestComparison['file_details'] as Map)
        : <String, dynamic>{};
    final items = details[bucket] is List
        ? List<Map<String, dynamic>>.from(
            (details[bucket] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    if (items.isEmpty) {
      return const ['No files recorded in this category.'];
    }
    return items
        .take(8)
        .map((item) {
          final path = item['path']?.toString().isNotEmpty == true
              ? item['path'].toString()
              : 'Unknown file';
          final category = item['category']?.toString().isNotEmpty == true
              ? item['category'].toString()
              : 'uncategorised';
          final language = item['language']?.toString().isNotEmpty == true
              ? item['language'].toString()
              : 'unknown language';
          return '$path - $category - $language';
        })
        .toList(growable: false);
  }

  List<String> _comparisonModifiedSummaries() {
    final details = _latestComparison['file_details'] is Map
        ? Map<String, dynamic>.from(_latestComparison['file_details'] as Map)
        : <String, dynamic>{};
    final items = details['modified'] is List
        ? List<Map<String, dynamic>>.from(
            (details['modified'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    if (items.isEmpty) {
      return const ['No modified files were captured.'];
    }
    return items
        .take(8)
        .map((item) {
          final path = item['path']?.toString().isNotEmpty == true
              ? item['path'].toString()
              : 'Unknown file';
          final changes = item['changes'] is List
              ? (item['changes'] as List)
                    .map((entry) => entry.toString())
                    .where((entry) => entry.trim().isNotEmpty)
                    .join('; ')
              : '';
          if (changes.isEmpty) {
            return path;
          }
          return '$path - $changes';
        })
        .toList(growable: false);
  }

  List<String> _comparisonDetailItems(String bucket) {
    final details = _latestComparison['file_details'] is Map
        ? Map<String, dynamic>.from(_latestComparison['file_details'] as Map)
        : <String, dynamic>{};
    final items = details[bucket] is List
        ? List<Map<String, dynamic>>.from(
            (details[bucket] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    if (items.isEmpty) {
      return const ['No items were captured for this comparison bucket.'];
    }

    if (bucket == 'modified') {
      return items
          .take(8)
          .map(_formatModifiedComparisonItem)
          .toList(growable: false);
    }

    return items.take(8).map(_formatComparisonItem).toList(growable: false);
  }

  String _formatComparisonItem(Map<String, dynamic> item) {
    final path = item['path']?.toString().isNotEmpty == true
        ? item['path'].toString()
        : 'Unknown file';
    final category = item['category']?.toString().isNotEmpty == true
        ? item['category'].toString()
        : 'uncategorised';
    final language = item['language']?.toString().isNotEmpty == true
        ? item['language'].toString()
        : 'unknown language';
    final sizeBytes = item['size_bytes'];
    final flags = item['flags'] is List
        ? (item['flags'] as List)
              .map((entry) => entry.toString())
              .where((entry) => entry.trim().isNotEmpty)
              .join(', ')
        : '';
    final parts = [
      path,
      category,
      language,
      if (sizeBytes != null) '$sizeBytes bytes',
      if (flags.isNotEmpty) flags,
    ];
    return parts.join(' - ');
  }

  String _formatModifiedComparisonItem(Map<String, dynamic> item) {
    final path = item['path']?.toString().isNotEmpty == true
        ? item['path'].toString()
        : 'Unknown file';
    final current = item['current'] is Map
        ? Map<String, dynamic>.from(item['current'] as Map)
        : <String, dynamic>{};
    final other = item['other'] is Map
        ? Map<String, dynamic>.from(item['other'] as Map)
        : <String, dynamic>{};
    final changes = item['changes'] is List
        ? (item['changes'] as List)
              .map((entry) => entry.toString())
              .where((entry) => entry.trim().isNotEmpty)
              .join('; ')
        : '';
    final before = _comparisonSnapshotSummary(other);
    final after = _comparisonSnapshotSummary(current);
    final parts = <String>[
      path,
      if (changes.isNotEmpty) changes,
      if (before.isNotEmpty) 'Before: $before',
      if (after.isNotEmpty) 'After: $after',
    ];
    return parts.join(' - ');
  }

  String _comparisonSnapshotSummary(Map<String, dynamic> snapshot) {
    if (snapshot.isEmpty) {
      return '';
    }
    final category = snapshot['category']?.toString().isNotEmpty == true
        ? snapshot['category'].toString()
        : '';
    final language = snapshot['language']?.toString().isNotEmpty == true
        ? snapshot['language'].toString()
        : '';
    final suffix = snapshot['suffix']?.toString().isNotEmpty == true
        ? snapshot['suffix'].toString()
        : '';
    final flags = snapshot['flags'] is List
        ? (snapshot['flags'] as List)
              .map((entry) => entry.toString())
              .where((entry) => entry.trim().isNotEmpty)
              .join(', ')
        : '';
    final parts = <String>[
      if (category.isNotEmpty) category,
      if (language.isNotEmpty) language,
      if (suffix.isNotEmpty) suffix,
      if (flags.isNotEmpty) flags,
    ];
    return parts.join(', ');
  }

  List<String> _graphSummaryItems(Map<String, dynamic> graph) {
    if (graph.isEmpty) {
      return const ['No graph bundle loaded yet.'];
    }
    final summary = graph['summary'] is Map
        ? Map<String, dynamic>.from(graph['summary'] as Map)
        : <String, dynamic>{};
    final kindCounts = summary['kind_counts'] is Map
        ? Map<String, dynamic>.from(summary['kind_counts'] as Map)
        : <String, dynamic>{};
    final lines = <String>[
      'Nodes: ${summary['node_count'] ?? 0}',
      'Edges: ${summary['edge_count'] ?? 0}',
    ];
    if (kindCounts.isNotEmpty) {
      final topKinds = kindCounts.entries.toList()
        ..sort(
          (left, right) => (right.value as num).compareTo(left.value as num),
        );
      lines.add(
        'Top groups: ${topKinds.take(3).map((entry) => '${entry.key} (${entry.value})').join(', ')}',
      );
    }
    return lines;
  }

  List<String> _graphFilterOptions(Map<String, dynamic> graph) {
    if (graph.isEmpty) {
      return const ['all'];
    }
    final nodes = graph['nodes'] is List
        ? List<Map<String, dynamic>>.from(
            (graph['nodes'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final kinds = <String>{'all'};
    for (final node in nodes) {
      final kind = node['kind']?.toString().trim() ?? '';
      if (kind.isNotEmpty) {
        kinds.add(kind);
      }
    }
    return kinds.toList(growable: false)..sort();
  }

  List<String> _graphNodeItems(
    Map<String, dynamic> graph, {
    String kind = 'all',
  }) {
    final nodes = graph['nodes'] is List
        ? List<Map<String, dynamic>>.from(
            (graph['nodes'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final filtered = nodes
        .where((node) {
          final nodeKind = node['kind']?.toString().trim() ?? '';
          return kind == 'all' || nodeKind == kind;
        })
        .toList(growable: false);
    if (filtered.isEmpty) {
      return const ['No graph nodes match the selected filter.'];
    }
    return filtered
        .take(8)
        .map((node) {
          final label = node['label']?.toString().isNotEmpty == true
              ? node['label'].toString()
              : node['id']?.toString() ?? 'Unknown node';
          final nodeKind = node['kind']?.toString().isNotEmpty == true
              ? node['kind'].toString()
              : 'unknown';
          return '$label - $nodeKind';
        })
        .toList(growable: false);
  }

  List<String> _graphEdgeItems(
    Map<String, dynamic> graph, {
    String kind = 'all',
  }) {
    final edges = graph['edges'] is List
        ? List<Map<String, dynamic>>.from(
            (graph['edges'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    final filtered = edges
        .where((edge) {
          final edgeKind = edge['kind']?.toString().trim() ?? '';
          return kind == 'all' || edgeKind == kind;
        })
        .toList(growable: false);
    if (filtered.isEmpty) {
      return const ['No graph edges match the selected filter.'];
    }
    return filtered
        .take(8)
        .map((edge) {
          final from = edge['from']?.toString().isNotEmpty == true
              ? edge['from'].toString()
              : 'Unknown';
          final to = edge['to']?.toString().isNotEmpty == true
              ? edge['to'].toString()
              : 'Unknown';
          final edgeKind = edge['kind']?.toString().isNotEmpty == true
              ? edge['kind'].toString()
              : 'unknown';
          return '$from -> $to - $edgeKind';
        })
        .toList(growable: false);
  }

  List<String> _graphAnchorItems(
    Map<String, dynamic> graph, {
    String kind = 'all',
  }) {
    if (graph.isEmpty) {
      return const ['Architecture anchors appear after a graph export runs.'];
    }
    final summary = graph['summary'] is Map
        ? Map<String, dynamic>.from(graph['summary'] as Map)
        : <String, dynamic>{};
    final anchors = summary['key_anchors'] is List
        ? List<Map<String, dynamic>>.from(
            (summary['key_anchors'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    if (anchors.isEmpty) {
      return const ['No anchor nodes were captured in the graph summary.'];
    }
    final filtered = anchors
        .where((item) {
          if (kind == 'all') {
            return true;
          }
          final anchorType = item['anchor_type']?.toString().trim() ?? '';
          final category = item['category']?.toString().trim() ?? '';
          return anchorType == kind || category == kind;
        })
        .toList(growable: false);
    if (filtered.isEmpty) {
      return const ['No anchors match the selected graph filter.'];
    }
    return filtered
        .take(8)
        .map((item) {
          final path = item['path']?.toString().isNotEmpty == true
              ? item['path'].toString()
              : 'Unknown anchor';
          final anchorType = item['anchor_type']?.toString().isNotEmpty == true
              ? item['anchor_type'].toString()
              : 'file';
          final note = item['note']?.toString().isNotEmpty == true
              ? item['note'].toString()
              : 'anchor';
          return '$path - $anchorType - $note';
        })
        .toList(growable: false);
  }

  Widget _graphDrilldownPanel(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Map<String, dynamic> graph,
    required List<String> filterOptions,
    required String selectedFilter,
    required ValueChanged<String?> onFilterChanged,
    required String nodeSectionTitle,
    required String edgeSectionTitle,
    required bool includeAnchors,
  }) {
    final nodeItems = _graphNodeItems(graph, kind: selectedFilter);
    final edgeItems = _graphEdgeItems(graph, kind: selectedFilter);
    final anchorItems = includeAnchors
        ? _graphAnchorItems(graph, kind: selectedFilter)
        : const <String>[];

    return _panel(
      context,
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedFilter,
            decoration: const InputDecoration(labelText: 'Graph filter'),
            items: filterOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option == 'all' ? 'All kinds' : option),
                  ),
                )
                .toList(growable: false),
            onChanged: onFilterChanged,
          ),
          const SizedBox(height: 12),
          _twoColumnBulletBlock(
            context,
            leftTitle: nodeSectionTitle,
            leftItems: _graphNodeGroupItems(graph),
            rightTitle: edgeSectionTitle,
            rightItems: _graphEdgeGroupItems(graph),
          ),
          const SizedBox(height: 12),
          _bulletSection(context, '$nodeSectionTitle (filtered)', nodeItems),
          const SizedBox(height: 12),
          _bulletSection(context, '$edgeSectionTitle (filtered)', edgeItems),
          if (includeAnchors) ...[
            const SizedBox(height: 12),
            _bulletSection(context, 'Key Anchors', anchorItems),
          ],
        ],
      ),
    );
  }

  List<String> _graphNodeGroupItems(Map<String, dynamic> graph) {
    if (graph.isEmpty) {
      return const ['No node groups available.'];
    }
    final summary = graph['summary'] is Map
        ? Map<String, dynamic>.from(graph['summary'] as Map)
        : <String, dynamic>{};
    final kindCounts = summary['kind_counts'] is Map
        ? Map<String, dynamic>.from(summary['kind_counts'] as Map)
        : <String, dynamic>{};
    if (kindCounts.isEmpty) {
      return const ['No node groups available.'];
    }
    final entries = kindCounts.entries.toList()
      ..sort(
        (left, right) => (right.value as num).compareTo(left.value as num),
      );
    return entries
        .take(8)
        .map((entry) => '${entry.key} - ${entry.value} nodes')
        .toList(growable: false);
  }

  List<String> _graphEdgeGroupItems(Map<String, dynamic> graph) {
    final edges = graph['edges'] is List
        ? List<Map<String, dynamic>>.from(
            (graph['edges'] as List).whereType<Map>(),
          )
        : <Map<String, dynamic>>[];
    if (edges.isEmpty) {
      return const ['No edge groups available.'];
    }
    final counts = <String, int>{};
    for (final edge in edges) {
      final kind = edge['kind']?.toString().trim().isNotEmpty == true
          ? edge['kind'].toString()
          : 'unknown';
      counts[kind] = (counts[kind] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    return entries
        .take(8)
        .map((entry) => '${entry.key} - ${entry.value} edges')
        .toList(growable: false);
  }

  Widget _architectureReviewCard(
    BuildContext context, {
    required Map<String, dynamic> graph,
    required String selectedFilter,
  }) {
    final summary = graph['summary'] is Map
        ? Map<String, dynamic>.from(graph['summary'] as Map)
        : <String, dynamic>{};
    final kindCounts = summary['kind_counts'] is Map
        ? Map<String, dynamic>.from(summary['kind_counts'] as Map)
        : <String, dynamic>{};
    final topKinds = kindCounts.entries.toList()
      ..sort(
        (left, right) => (right.value as num).compareTo(left.value as num),
      );
    final filteredAnchors = _graphAnchorItems(graph, kind: selectedFilter);

    return _panel(
      context,
      title: 'Architecture Review',
      subtitle:
          'Review the architecture graph as a calm summary of node groups, edge groups, and key file anchors.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _twoColumnBulletBlock(
            context,
            leftTitle: 'Architecture Node Groups',
            leftItems: _graphNodeGroupItems(graph),
            rightTitle: 'Architecture Edge Groups',
            rightItems: _graphEdgeGroupItems(graph),
          ),
          const SizedBox(height: 12),
          _MetadataRow(
            label: 'Architecture summary',
            value:
                'Nodes: ${summary['node_count'] ?? 0} | Edges: ${summary['edge_count'] ?? 0}',
          ),
          const SizedBox(height: 8),
          _MetadataRow(
            label: 'Top kinds',
            value: topKinds.isEmpty
                ? 'No node groups available'
                : topKinds
                      .take(4)
                      .map((entry) => '${entry.key} (${entry.value})')
                      .join(' | '),
          ),
          const SizedBox(height: 12),
          _bulletSection(context, 'Architecture Key Anchors', filteredAnchors),
        ],
      ),
    );
  }

  int _comparisonCount(dynamic value) {
    if (value is List) {
      return value.length;
    }
    if (value is Map) {
      return value.length;
    }
    if (value is int) {
      return value;
    }
    return 0;
  }

  Widget _promptsCard(BuildContext context) {
    final outputDirectory = _outputController.text.trim().isEmpty
        ? _defaultOutputDirectory
        : _outputController.text.trim();
    final promptsDirectory = pathJoin(outputDirectory, 'generated_prompts');
    final selectedTemplateSet = _selectedTemplateSetPreset;

    return _panel(
      context,
      key: _promptsSectionKey,
      title: 'Codex Prompt Generator',
      subtitle:
          'Prompt templates are generated alongside the latest research bundle and stay local.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prompt families',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (_templateSets.isEmpty)
            Text(
              'Loading prompt template families...',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            DropdownButtonFormField<String>(
              initialValue:
                  _templateSets.any(
                    (preset) => preset.name == _selectedTemplateSet,
                  )
                  ? _selectedTemplateSet
                  : null,
              decoration: const InputDecoration(
                labelText: 'Prompt template family',
                hintText:
                    'Choose the family that should shape generated prompts',
              ),
              items: _templateSets
                  .map(
                    (preset) => DropdownMenuItem<String>(
                      value: preset.name,
                      child: Text(
                        preset.description.isNotEmpty
                            ? '${preset.name} - ${preset.description}'
                            : preset.name,
                      ),
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
          if (selectedTemplateSet != null) ...[
            _MetadataRow(
              label: 'Selected family',
              value: selectedTemplateSet.name,
            ),
            const SizedBox(height: 8),
            _MetadataRow(
              label: 'Family description',
              value: selectedTemplateSet.description.isNotEmpty
                  ? selectedTemplateSet.description
                  : 'No description supplied for this family.',
            ),
            const SizedBox(height: 8),
            _MetadataRow(
              label: 'Vault note template',
              value:
                  selectedTemplateSet.templates['vault_note'] ??
                  'repo_research_note_template.md',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in selectedTemplateSet.templates.entries)
                  _StatusChip(
                    label: '${entry.key}: ${entry.value}',
                    muted: false,
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          _MetadataRow(label: 'Prompt output', value: promptsDirectory),
          const SizedBox(height: 8),
          _MetadataRow(
            label: 'Prompt status',
            value:
                'Generated from the latest local research bundle and the selected family.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              TextButton.icon(
                onPressed: () => _service.openFolder(promptsDirectory),
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Prompt Folder'),
              ),
              TextButton.icon(
                onPressed: () => _service.openFolder(outputDirectory),
                icon: const Icon(Icons.folder),
                label: const Text('Open Reports Folder'),
              ),
              FilledButton.tonalIcon(
                onPressed: _isRunning || _loadingTemplateSets
                    ? null
                    : () => _applyTemplateSet(_selectedTemplateSet),
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Apply Selected Family'),
              ),
              OutlinedButton.icon(
                onPressed: _isRunning
                    ? null
                    : () => _navigateToSection('settings'),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Review Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(BuildContext context) {
    final outputDirectory = _outputController.text.trim().isEmpty
        ? _defaultOutputDirectory
        : _outputController.text.trim();
    final omegaRoot = _omegaRootController.text.trim();
    final profilesDirectory = _defaultProfilesDirectory;
    final workspaceRoot = _workspaceRootController.text.trim().isEmpty
        ? _defaultWorkspaceRoot
        : _workspaceRootController.text.trim();

    return _panel(
      context,
      key: _settingsSectionKey,
      title: 'Settings',
      subtitle:
          'Review the local paths and defaults used by this module before running a scan.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetadataRow(
            label: 'Module root',
            value: _service.moduleRootDirectory().path,
          ),
          const SizedBox(height: 8),
          _MetadataRow(label: 'Output folder', value: outputDirectory),
          const SizedBox(height: 8),
          _MetadataRow(label: 'Profiles folder', value: profilesDirectory),
          const SizedBox(height: 8),
          _MetadataRow(label: 'Workspace root', value: workspaceRoot),
          const SizedBox(height: 8),
          _MetadataRow(label: 'Omega OS export root', value: omegaRoot),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              TextButton.icon(
                onPressed: () => _service.openFolder(outputDirectory),
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Reports Folder'),
              ),
              TextButton.icon(
                onPressed: () => _service.openFolder(profilesDirectory),
                icon: const Icon(Icons.folder),
                label: const Text('Open Profiles Folder'),
              ),
              TextButton.icon(
                onPressed: () => _service.openFolder(workspaceRoot),
                icon: const Icon(Icons.folder_copy),
                label: const Text('Open Workspace Root'),
              ),
              TextButton.icon(
                onPressed: () => _service.openFolder(omegaRoot),
                icon: const Icon(Icons.cloud_done_outlined),
                label: const Text('Open Omega Root'),
              ),
              OutlinedButton.icon(
                onPressed: _isRunning
                    ? null
                    : () => _navigateToSection('scanner'),
                icon: const Icon(Icons.travel_explore_outlined),
                label: const Text('Back to Scanner'),
              ),
            ],
          ),
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
    Key? key,
    String? title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      key: key,
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

  Widget _sectionNavButton(
    BuildContext context,
    String label,
    String section,
    IconData icon,
  ) {
    final selected = _activeSection == _normalizeSection(section);
    final button = selected
        ? FilledButton.icon(
            onPressed: _isRunning ? null : () => _navigateToSection(section),
            icon: Icon(icon),
            label: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: _isRunning ? null : () => _navigateToSection(section),
            icon: Icon(icon),
            label: Text(label),
          );
    return button;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? helperText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
      ),
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

  Future<void> _cloneAndScan() async {
    await _cloneIntoWorkspace(scanAfterClone: true);
  }

  Future<void> _cloneIntoWorkspace({bool scanAfterClone = false}) async {
    final source = _cloneSourceController.text.trim().isNotEmpty
        ? _cloneSourceController.text.trim()
        : _repoPathController.text.trim();
    if (source.isEmpty) {
      _setMessage('Enter a repository URL or local repo path first.');
      return;
    }

    final workspaceRoot = _workspaceRootController.text.trim().isEmpty
        ? _defaultWorkspaceRoot
        : _workspaceRootController.text.trim();
    final branch = _cloneBranchController.text.trim();

    setState(() {
      _isCloning = true;
      _lastCloneStatus = 'Cloning...';
    });

    try {
      final result = await _service.cloneRepository(
        source: source,
        workspaceRoot: workspaceRoot,
        branch: branch.isEmpty ? null : branch,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _repoPathController.text = result.sourceRoot;
        final commitLabel = result.commit.isEmpty
            ? 'latest'
            : (result.commit.length > 8
                  ? result.commit.substring(0, 8)
                  : result.commit);
        _lastCloneStatus =
            'Cloned ${result.provider}/${result.ownerPath}/${result.repoName} at $commitLabel';
        _lastCloneSourcePath = result.sourceRoot;
      });
      if (result.sourceRoot.isNotEmpty) {
        try {
          await _service.openFolder(result.sourceRoot);
        } catch (error) {
          _setMessage(
            'Cloned repository, but could not open the source folder: $error',
          );
        }
      }
      if (scanAfterClone) {
        final scanSucceeded = await _run(mode: _RunMode.bundle);
        if (mounted) {
          setState(() {
            _lastCloneStatus = scanSucceeded
                ? 'Cloned and scanned ${result.repoName}'
                : 'Cloned ${result.repoName}, scan needs review';
          });
        }
      } else {
        _setMessage('Cloned repository into the structured workspace.');
      }
      await _loadCloneHistory();
    } catch (error) {
      if (mounted) {
        setState(() {
          _lastCloneStatus = 'Clone failed';
        });
      }
      _setMessage('Could not clone repository: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isCloning = false;
        });
      }
    }
  }

  Future<void> _loadCloneIntoForm(RepoResearchCloneHistoryRecord record) async {
    if (mounted) {
      setState(() {
        _cloneSourceController.text = record.source;
        _workspaceRootController.text = record.workspaceRoot.isNotEmpty
            ? record.workspaceRoot
            : _defaultWorkspaceRoot;
        _cloneBranchController.text = record.branch;
        _repoPathController.text = record.sourceRoot.isNotEmpty
            ? record.sourceRoot
            : record.repositoryRoot;
        _lastCloneStatus =
            'Loaded ${record.displayTitle} from history (${record.shortCommit})';
        _lastCloneSourcePath = record.sourceRoot;
      });
    }
    _setMessage('Loaded clone history entry into the form.');
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

  Future<void> _loadCloneHistory() async {
    if (mounted) {
      setState(() {
        _loadingCloneHistory = true;
      });
    }

    final clones = await _service.loadCloneHistory();
    if (!mounted) {
      return;
    }
    setState(() {
      _recentClones = clones;
      _loadingCloneHistory = false;
    });
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
          : jsonEncode({
              'profile_name': 'Generic',
              'project_type': 'generic local-first repository',
              'priority_keywords': [],
              'ignore_keywords': [],
              'useful_file_patterns': [],
              'risk_keywords': [],
              'output_focus': [],
              'export_targets': [],
              'export_locations': [],
              'template_set': _selectedTemplateSet,
              'template_set_description':
                  _selectedTemplateSetPreset?.description ?? '',
              'report_templates': {},
            });
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
      _setMessage(
        exists ? 'Profile loaded.' : 'Loaded a starter profile template.',
      );
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
      orElse: () => _templateSets.isNotEmpty
          ? _templateSets.first
          : const _TemplateSetPreset(
              name: 'Generic',
              description: '',
              templates: {},
            ),
    );
    try {
      final decoded = jsonDecode(_profileEditorController.text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Profile JSON must be an object');
      }
      decoded['template_set'] = preset.name;
      decoded['template_set_description'] = preset.description;
      decoded['report_templates'] = preset.templates;
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      setState(() {
        _profileEditorController.text = pretty;
        _profileEditorStatus = 'Applied ${preset.name} template set.';
        _selectedTemplateSet = preset.name;
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

  Future<bool> _run({required _RunMode mode}) async {
    final repoPath = _repoPathController.text.trim();
    if (repoPath.isEmpty) {
      _setMessage('Enter a local repository path first.');
      return false;
    }
    final repoPathWarning = _repoPathWarning(repoPath);
    if (repoPathWarning.isNotEmpty) {
      _setMessage(repoPathWarning);
      return false;
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
      final artifacts = await _loadRunArtifacts(output);
      final analysis = artifacts['analysis'] is Map
          ? Map<String, dynamic>.from(artifacts['analysis'] as Map)
          : <String, dynamic>{};
      final comparison = artifacts['comparison'] is Map
          ? Map<String, dynamic>.from(artifacts['comparison'] as Map)
          : <String, dynamic>{};
      final changeTracking = artifacts['change_tracking'] is Map
          ? Map<String, dynamic>.from(artifacts['change_tracking'] as Map)
          : <String, dynamic>{};
      final releaseNotes = artifacts['release_notes'] is Map
          ? Map<String, dynamic>.from(artifacts['release_notes'] as Map)
          : <String, dynamic>{};
      final bundleDelta = artifacts['bundle_delta'] is Map
          ? Map<String, dynamic>.from(artifacts['bundle_delta'] as Map)
          : <String, dynamic>{};
      final reportIndex = artifacts['report_index'] is Map
          ? Map<String, dynamic>.from(artifacts['report_index'] as Map)
          : <String, dynamic>{};
      final knowledge = analysis['knowledge'] is Map
          ? Map<String, dynamic>.from(analysis['knowledge'] as Map)
          : <String, dynamic>{};

      setState(() {
        _outputFiles = files;
        _reportPreviewController.text = preview;
        _securityPreviewController.text = securityPreview;
        _comparisonPreviewController.text = comparisonPreview;
        _knowledgePreviewController.text =
            artifacts['knowledge_report.md']?.toString() ?? '';
        _releaseNotesPreviewController.text =
            artifacts['release_notes.md']?.toString() ?? '';
        _bundleDeltaPreviewController.text =
            artifacts['bundle_delta_summary.md']?.toString() ?? '';
        _reportIndexPreviewController.text =
            artifacts['report_search_index.md']?.toString() ?? '';
        _changeTrackingPreviewController.text =
            artifacts['change_tracking.md']?.toString() ?? '';
        _dependencyGraphPreviewController.text =
            artifacts['dependency_graph.md']?.toString() ?? '';
        _architectureGraphPreviewController.text =
            artifacts['architecture_graph.md']?.toString() ?? '';
        _documentIndexPreviewController.text =
            knowledge['document_highlights'] is List
            ? (knowledge['document_highlights'] as List)
                  .map((item) => item.toString())
                  .join('\n')
            : '';
        _riskPreviewController.text =
            artifacts['risk_report.md']?.toString() ?? '';
        _licenseReviewPreviewController.text =
            artifacts['license_review.md']?.toString() ?? '';
        _vaultNotePreviewController.text =
            artifacts['vault_note.md']?.toString() ?? '';
        _latestAnalysis = analysis;
        _latestComparison = comparison;
        _latestChangeTracking = changeTracking;
        _latestReleaseNotes = releaseNotes;
        _latestBundleDelta = bundleDelta;
        _latestReportIndex = reportIndex;
        _latestDependencyGraph = artifacts['dependency_graph.json'] is Map
            ? Map<String, dynamic>.from(
                artifacts['dependency_graph.json'] as Map,
              )
            : <String, dynamic>{};
        _latestArchitectureGraph = artifacts['architecture_graph.json'] is Map
            ? Map<String, dynamic>.from(
                artifacts['architecture_graph.json'] as Map,
              )
            : <String, dynamic>{};
        _latestRepositoryInventory = artifacts['repo_inventory'] is Map
            ? Map<String, dynamic>.from(artifacts['repo_inventory'] as Map)
            : <String, dynamic>{};
        _latestRepositoryTree = artifacts['repository_tree'] is Map
            ? Map<String, dynamic>.from(artifacts['repository_tree'] as Map)
            : <String, dynamic>{};
        _mainReportPath = previewPath;
        _securityReportPath = pathJoin(output, 'security_report.md');
        _comparisonReportPath = pathJoin(output, 'repo_comparison.md');
        _knowledgeReportPath = pathJoin(output, 'knowledge_report.md');
        _releaseNotesPath = pathJoin(output, 'release_notes.md');
        _bundleDeltaPath = pathJoin(output, 'bundle_delta_summary.md');
        _reportIndexPath = pathJoin(output, 'report_search_index.md');
        _changeTrackingPath = pathJoin(output, 'change_tracking.md');
        _dependencyGraphPath = pathJoin(output, 'dependency_graph.md');
        _architectureGraphPath = pathJoin(output, 'architecture_graph.md');
        _documentIndexPath = pathJoin(output, 'repo_research_report.md');
        _riskReportPath = pathJoin(output, 'risk_report.md');
        _logController.text = _renderLog(result);
        _lastRunLabel = result.succeeded
            ? 'Completed with exit code ${result.exitCode}'
            : 'Finished with exit code ${result.exitCode}';
        _lastRunTimestampLabel = _formatDateTime(DateTime.now());
      });
      await _loadRecentRuns(refreshStateOnly: false);
      await _loadChangeHistory(refreshStateOnly: false);
      await _loadExportHistory();

      _setMessage(
        result.succeeded
            ? 'Repository research bundle generated successfully.'
            : 'The command finished, but returned exit code ${result.exitCode}.',
      );
      return result.succeeded;
    } catch (error) {
      setState(() {
        _logController.text = 'Run failed:\n$error';
        _lastRunLabel = 'Failed';
        _lastRunTimestampLabel = _formatDateTime(DateTime.now());
      });
      _setMessage('Repo Research Engine could not run: $error');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _loadRunArtifacts(String outputDirectory) async {
    final analysis = await _readJsonMap(
      pathJoin(outputDirectory, 'analysis.json'),
    );
    final comparison = await _readJsonMap(
      pathJoin(outputDirectory, 'repo_comparison.json'),
    );
    final changeTracking = await _readJsonMap(
      pathJoin(outputDirectory, 'change_tracking.json'),
    );
    final releaseNotes = await _readJsonMap(
      pathJoin(outputDirectory, 'release_notes.json'),
    );
    final bundleDelta = await _readJsonMap(
      pathJoin(outputDirectory, 'bundle_delta_summary.json'),
    );
    final reportIndex = await _readJsonMap(
      pathJoin(outputDirectory, 'report_search_index.json'),
    );

    return {
      'analysis': analysis,
      'comparison': comparison,
      'change_tracking': changeTracking,
      'release_notes': releaseNotes,
      'bundle_delta': bundleDelta,
      'report_index': reportIndex,
      'repo_inventory': await _readJsonMap(
        pathJoin(outputDirectory, 'repo_inventory.json'),
      ),
      'repository_tree': await _readJsonMap(
        pathJoin(outputDirectory, 'repository_tree.json'),
      ),
      'knowledge_report.md': await _service.readFile(
        pathJoin(outputDirectory, 'knowledge_report.md'),
      ),
      'implementation_opportunities.md': await _service.readFile(
        pathJoin(outputDirectory, 'implementation_opportunities.md'),
      ),
      'learning_notes.md': await _service.readFile(
        pathJoin(outputDirectory, 'learning_notes.md'),
      ),
      'release_notes.md': await _service.readFile(
        pathJoin(outputDirectory, 'release_notes.md'),
      ),
      'bundle_delta_summary.md': await _service.readFile(
        pathJoin(outputDirectory, 'bundle_delta_summary.md'),
      ),
      'report_search_index.md': await _service.readFile(
        pathJoin(outputDirectory, 'report_search_index.md'),
      ),
      'change_tracking.md': await _service.readFile(
        pathJoin(outputDirectory, 'change_tracking.md'),
      ),
      'dependency_graph.md': await _service.readFile(
        pathJoin(outputDirectory, 'dependency_graph.md'),
      ),
      'architecture_graph.md': await _service.readFile(
        pathJoin(outputDirectory, 'architecture_graph.md'),
      ),
      'dependency_graph.json': await _readJsonMap(
        pathJoin(outputDirectory, 'dependency_graph.json'),
      ),
      'architecture_graph.json': await _readJsonMap(
        pathJoin(outputDirectory, 'architecture_graph.json'),
      ),
      'risk_report.md': await _service.readFile(
        pathJoin(outputDirectory, 'risk_report.md'),
      ),
      'license_review.md': await _service.readFile(
        pathJoin(outputDirectory, 'license_review.md'),
      ),
      'vault_note.md': await _service.readFile(
        pathJoin(outputDirectory, 'vault_note.md'),
      ),
      'report_template_selection.md': await _service.readFile(
        pathJoin(outputDirectory, 'report_template_selection.md'),
      ),
    };
  }

  Future<Map<String, dynamic>> _readJsonMap(String filePath) async {
    final text = await _service.readFile(filePath);
    if (text.trim().isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
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

  Future<void> _loadChangeHistory({bool refreshStateOnly = true}) async {
    if (refreshStateOnly && mounted) {
      setState(() {
        _loadingChangeHistory = true;
      });
    }

    final history = await _service.loadChangeHistory();
    if (!mounted) {
      return;
    }
    setState(() {
      _changeHistory = history;
      _loadingChangeHistory = false;
    });
  }

  Future<void> _loadExportHistory() async {
    if (mounted) {
      setState(() {
        _loadingExportHistory = true;
      });
    }

    final exports = await _service.loadExportHistory();
    final exportHistoryMarkdown = await _service.readFile(
      _exportHistoryMarkdownPath,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _exportHistory = exports;
      _exportHistoryPreviewController.text = exportHistoryMarkdown;
      _loadingExportHistory = false;
      _exportHistoryPath = _exportHistoryMarkdownPath;
    });
  }

  Future<void> _loadTemplateSets() async {
    if (mounted) {
      setState(() {
        _loadingTemplateSets = true;
      });
    }

    final loadedSets = await _readTemplateSetsRegistry();
    if (!mounted) {
      return;
    }
    setState(() {
      _templateSets = loadedSets;
      final hasSelected = _templateSets.any(
        (preset) => preset.name == _selectedTemplateSet,
      );
      if (_templateSets.isNotEmpty && !hasSelected) {
        _selectedTemplateSet = _templateSets.first.name;
      }
      _loadingTemplateSets = false;
    });
  }

  Future<List<_TemplateSetPreset>> _readTemplateSetsRegistry() async {
    final registryPath = _templateSetsPath;
    final text = await _service.readFile(registryPath);
    if (text.trim().isEmpty) {
      return _defaultTemplateSets();
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return _defaultTemplateSets();
      }
      final items = decoded['template_sets'];
      if (items is! List) {
        return _defaultTemplateSets();
      }

      final presets = <_TemplateSetPreset>[];
      for (final entry in items.whereType<Map>()) {
        final templates = entry['report_templates'] is Map
            ? Map<String, String>.from(
                (entry['report_templates'] as Map).map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              )
            : <String, String>{};
        presets.add(
          _TemplateSetPreset(
            name: entry['name']?.toString().isNotEmpty == true
                ? entry['name'].toString()
                : 'Generic',
            description: entry['description']?.toString() ?? '',
            templates: templates,
          ),
        );
      }
      return presets.isEmpty ? _defaultTemplateSets() : presets;
    } catch (_) {
      return _defaultTemplateSets();
    }
  }

  List<_TemplateSetPreset> _defaultTemplateSets() {
    return const [
      _TemplateSetPreset(
        name: 'Generic',
        description:
            'Balanced local-first research bundle for general repositories.',
        templates: {
          'main_report': 'repo_research_report.md',
          'summary': 'repo_summary.md',
          'security': 'security_report.md',
          'risk': 'risk_report.md',
          'knowledge': 'knowledge_report.md',
          'implementation_opportunities': 'implementation_opportunities.md',
          'learning_notes': 'learning_notes.md',
          'vault_note': 'repo_research_note_template.md',
        },
      ),
      _TemplateSetPreset(
        name: 'MicroGrow',
        description:
            'Focused on firmware, hardware safety, and local automation notes.',
        templates: {
          'main_report': 'repo_research_report.md',
          'summary': 'repo_summary.md',
          'security': 'security_report.md',
          'risk': 'risk_report.md',
          'knowledge': 'knowledge_report.md',
          'implementation_opportunities': 'implementation_opportunities.md',
          'learning_notes': 'learning_notes.md',
          'vault_note': 'microgrow_research_note_template.md',
        },
      ),
      _TemplateSetPreset(
        name: 'New Earth Dashboard',
        description:
            'Optimised for dashboard structure, navigation, and calm UI review.',
        templates: {
          'main_report': 'repo_research_report.md',
          'summary': 'repo_summary.md',
          'security': 'security_report.md',
          'risk': 'risk_report.md',
          'knowledge': 'knowledge_report.md',
          'implementation_opportunities': 'implementation_opportunities.md',
          'learning_notes': 'learning_notes.md',
          'vault_note': 'new_earth_dashboard_research_note_template.md',
        },
      ),
      _TemplateSetPreset(
        name: 'New Earth Living',
        description:
            'Tailored for living systems, routines, and wellbeing-focused projects.',
        templates: {
          'main_report': 'repo_research_report.md',
          'summary': 'repo_summary.md',
          'security': 'security_report.md',
          'risk': 'risk_report.md',
          'knowledge': 'knowledge_report.md',
          'implementation_opportunities': 'implementation_opportunities.md',
          'learning_notes': 'learning_notes.md',
          'vault_note': 'new_earth_living_research_note_template.md',
        },
      ),
      _TemplateSetPreset(
        name: 'BioCalm',
        description:
            'Calm review template for wellbeing and low-friction analysis notes.',
        templates: {
          'main_report': 'repo_research_report.md',
          'summary': 'repo_summary.md',
          'security': 'security_report.md',
          'risk': 'risk_report.md',
          'knowledge': 'knowledge_report.md',
          'implementation_opportunities': 'implementation_opportunities.md',
          'learning_notes': 'learning_notes.md',
          'vault_note': 'biocalm_research_note_template.md',
        },
      ),
      _TemplateSetPreset(
        name: 'New Earth Rehabilitation',
        description:
            'Structured for recovery work, repeatability, and careful safety checks.',
        templates: {
          'main_report': 'repo_research_report.md',
          'summary': 'repo_summary.md',
          'security': 'security_report.md',
          'risk': 'risk_report.md',
          'knowledge': 'knowledge_report.md',
          'implementation_opportunities': 'implementation_opportunities.md',
          'learning_notes': 'learning_notes.md',
          'vault_note': 'rehabilitation_research_note_template.md',
        },
      ),
      _TemplateSetPreset(
        name: 'Omega OS',
        description:
            'General-purpose export template for broader Omega OS research work.',
        templates: {
          'main_report': 'repo_research_report.md',
          'summary': 'repo_summary.md',
          'security': 'security_report.md',
          'risk': 'risk_report.md',
          'knowledge': 'knowledge_report.md',
          'implementation_opportunities': 'implementation_opportunities.md',
          'learning_notes': 'learning_notes.md',
          'vault_note': 'omega_os_research_note_template.md',
        },
      ),
    ];
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

  Future<void> _loadRecentRunIntoForm(RepoResearchRunRecord run) async {
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
        _knowledgeReportPath = pathJoin(
          run.outputDirectory,
          'knowledge_report.md',
        );
        _releaseNotesPath = pathJoin(run.outputDirectory, 'release_notes.md');
        _bundleDeltaPath = pathJoin(
          run.outputDirectory,
          'bundle_delta_summary.md',
        );
        _reportIndexPath = pathJoin(
          run.outputDirectory,
          'report_search_index.md',
        );
        _changeTrackingPath = pathJoin(
          run.outputDirectory,
          'change_tracking.md',
        );
        _dependencyGraphPath = pathJoin(
          run.outputDirectory,
          'dependency_graph.md',
        );
        _architectureGraphPath = pathJoin(
          run.outputDirectory,
          'architecture_graph.md',
        );
        _documentIndexPath = pathJoin(
          run.outputDirectory,
          'repo_research_report.md',
        );
        _riskReportPath = pathJoin(run.outputDirectory, 'risk_report.md');
      });
    }
    final artifacts = await _loadRunArtifacts(run.outputDirectory);
    if (!mounted) {
      return;
    }
    final analysis = artifacts['analysis'] is Map
        ? Map<String, dynamic>.from(artifacts['analysis'] as Map)
        : <String, dynamic>{};
    final comparison = artifacts['comparison'] is Map
        ? Map<String, dynamic>.from(artifacts['comparison'] as Map)
        : <String, dynamic>{};
    final changeTracking = artifacts['change_tracking'] is Map
        ? Map<String, dynamic>.from(artifacts['change_tracking'] as Map)
        : <String, dynamic>{};
    final releaseNotes = artifacts['release_notes'] is Map
        ? Map<String, dynamic>.from(artifacts['release_notes'] as Map)
        : <String, dynamic>{};
    final bundleDelta = artifacts['bundle_delta'] is Map
        ? Map<String, dynamic>.from(artifacts['bundle_delta'] as Map)
        : <String, dynamic>{};
    final reportIndex = artifacts['report_index'] is Map
        ? Map<String, dynamic>.from(artifacts['report_index'] as Map)
        : <String, dynamic>{};
    final knowledge = analysis['knowledge'] is Map
        ? Map<String, dynamic>.from(analysis['knowledge'] as Map)
        : <String, dynamic>{};
    setState(() {
      _reportPreviewController.text =
          analysis['project_summary']?.toString() ?? '';
      _securityPreviewController.text =
          artifacts['risk_report.md']?.toString() ?? '';
      _comparisonPreviewController.text = comparison.isNotEmpty
          ? _formatJsonPreview(comparison)
          : '';
      _knowledgePreviewController.text =
          artifacts['knowledge_report.md']?.toString() ?? '';
      _releaseNotesPreviewController.text =
          artifacts['release_notes.md']?.toString() ?? '';
      _bundleDeltaPreviewController.text =
          artifacts['bundle_delta_summary.md']?.toString() ?? '';
      _reportIndexPreviewController.text =
          artifacts['report_search_index.md']?.toString() ?? '';
      _changeTrackingPreviewController.text =
          artifacts['change_tracking.md']?.toString() ?? '';
      _dependencyGraphPreviewController.text =
          artifacts['dependency_graph.md']?.toString() ?? '';
      _architectureGraphPreviewController.text =
          artifacts['architecture_graph.md']?.toString() ?? '';
      _documentIndexPreviewController.text =
          knowledge['document_highlights'] is List
          ? (knowledge['document_highlights'] as List)
                .map((item) => item.toString())
                .join('\n')
          : '';
      _riskPreviewController.text =
          artifacts['risk_report.md']?.toString() ?? '';
      _licenseReviewPreviewController.text =
          artifacts['license_review.md']?.toString() ?? '';
      _vaultNotePreviewController.text =
          artifacts['vault_note.md']?.toString() ?? '';
      _latestAnalysis = analysis;
      _latestComparison = comparison;
      _latestChangeTracking = changeTracking;
      _latestReleaseNotes = releaseNotes;
      _latestBundleDelta = bundleDelta;
      _latestReportIndex = reportIndex;
      _latestDependencyGraph = artifacts['dependency_graph.json'] is Map
          ? Map<String, dynamic>.from(artifacts['dependency_graph.json'] as Map)
          : <String, dynamic>{};
      _latestArchitectureGraph = artifacts['architecture_graph.json'] is Map
          ? Map<String, dynamic>.from(
              artifacts['architecture_graph.json'] as Map,
            )
          : <String, dynamic>{};
      _latestRepositoryInventory = artifacts['repo_inventory'] is Map
          ? Map<String, dynamic>.from(artifacts['repo_inventory'] as Map)
          : <String, dynamic>{};
      _latestRepositoryTree = artifacts['repository_tree'] is Map
          ? Map<String, dynamic>.from(artifacts['repository_tree'] as Map)
          : <String, dynamic>{};
    });
    _setMessage('Loaded the selected run into the form.');
  }

  Future<void> _rerunRecentRun(RepoResearchRunRecord run) async {
    await _loadRecentRunIntoForm(run);
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

  String _repoPathWarning(String repoPath) {
    if (repoPath.isEmpty) {
      return '';
    }
    if (_looksLikeRemoteRepository(repoPath)) {
      return 'Repository path must be a local folder, not a URL or git remote.';
    }
    return '';
  }

  bool _looksLikeRemoteRepository(String value) {
    final normalized = value.trim().replaceAll('\\', '/').toLowerCase();
    if (normalized.contains('://')) {
      return true;
    }
    if (normalized.startsWith('git@')) {
      return true;
    }
    if (normalized.endsWith('.git')) {
      return true;
    }
    return normalized.contains('github.com/') ||
        normalized.contains('gitlab.com/') ||
        normalized.contains('bitbucket.org/');
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

  String _formatJsonPreview(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return '';
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  Future<_ProfileReadResult> _readProfileFile(String profilePath) async {
    final file = File(profilePath);
    final exists = await file.exists();
    final text = exists
        ? await file.readAsString()
        : jsonEncode({
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
          });
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
    _collectProfileDifferences(differences, leftJson, rightJson);
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

class _TemplateSetPreset {
  const _TemplateSetPreset({
    required this.name,
    required this.description,
    required this.templates,
  });

  final String name;
  final String description;
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

class _HomeSectionLaunch {
  const _HomeSectionLaunch({
    required this.title,
    required this.description,
    required this.icon,
    required this.section,
  });

  final String title;
  final String description;
  final IconData icon;
  final String section;
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

class _HomeSectionTile extends StatelessWidget {
  const _HomeSectionTile({required this.launch, required this.onTap});

  final _HomeSectionLaunch launch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColours.darkSurfaceRaised.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColours.darkOutline.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColours.darkSurface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(launch.icon, color: AppColours.darkSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    launch.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    launch.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColours.darkMutedText),
          ],
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

class _CloneHistoryTile extends StatelessWidget {
  const _CloneHistoryTile({
    required this.record,
    required this.onLoad,
    required this.onOpenSource,
    required this.onOpenWorkspace,
  });

  final RepoResearchCloneHistoryRecord record;
  final VoidCallback onLoad;
  final VoidCallback? onOpenSource;
  final VoidCallback? onOpenWorkspace;

  @override
  Widget build(BuildContext context) {
    final timestampLabel = record.parsedTimestamp == null
        ? record.timestamp
        : '${record.parsedTimestamp!.year}-${record.parsedTimestamp!.month.toString().padLeft(2, '0')}-${record.parsedTimestamp!.day.toString().padLeft(2, '0')} ${record.parsedTimestamp!.hour.toString().padLeft(2, '0')}:${record.parsedTimestamp!.minute.toString().padLeft(2, '0')}';

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
                  record.displayTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(label: record.shortCommit, muted: false),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Source: ${record.source} - $timestampLabel',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Workspace: ${record.workspaceRoot}',
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
              TextButton.icon(
                onPressed: onLoad,
                icon: const Icon(Icons.tune),
                label: const Text('Load'),
              ),
              if (onOpenSource != null)
                TextButton.icon(
                  onPressed: onOpenSource,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open Source'),
                ),
              if (onOpenWorkspace != null)
                FilledButton.tonalIcon(
                  onPressed: onOpenWorkspace,
                  icon: const Icon(Icons.folder_copy),
                  label: const Text('Open Workspace'),
                ),
            ],
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

class _ChangeHistoryTile extends StatelessWidget {
  const _ChangeHistoryTile({
    required this.record,
    required this.isFirst,
    required this.isLast,
    required this.onOpenBaseline,
  });

  final RepoResearchChangeHistoryRecord record;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onOpenBaseline;

  @override
  Widget build(BuildContext context) {
    final timestamp = record.parsedTimestamp;
    final timestampLabel = timestamp == null
        ? record.timestamp
        : '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    final added = record.fileChanges['added'] ?? const <String>[];
    final removed = record.fileChanges['removed'] ?? const <String>[];
    final modified = record.fileChanges['modified'] ?? const <String>[];
    final riskDeltaLabel =
        record.newRiskPaths.isNotEmpty || record.resolvedRiskPaths.isNotEmpty
        ? '${record.newRiskPaths.length} new risk path${record.newRiskPaths.length == 1 ? '' : 's'}, ${record.resolvedRiskPaths.length} resolved'
        : 'No risk shifts recorded';
    final previewFiles = <String>[
      ...added.take(2),
      ...removed.take(2),
      ...modified.take(2),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? AppColours.darkSecondary
                        : AppColours.darkMutedText,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColours.darkOutline.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
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
                          record.currentRepo.isEmpty
                              ? 'Unknown current repo'
                              : record.currentRepo,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColours.darkText,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatusChip(
                        label: record.fileChangeSummary,
                        muted: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(label: timestampLabel, muted: false),
                      _StatusChip(
                        label: record.baselineRepo.isEmpty
                            ? 'Baseline repo not set'
                            : record.baselineRepo,
                        muted: false,
                      ),
                      _StatusChip(label: riskDeltaLabel, muted: false),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Baseline inventory: ${record.baselineInventoryPath}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (record.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      record.summary,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final file in previewFiles.take(6))
                        _StatusChip(label: file, muted: false),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: onOpenBaseline,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Open Baseline'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
