import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../data/omega_knowledge_engine_service.dart';

class OmegaKnowledgeEngineScreen extends StatefulWidget {
  const OmegaKnowledgeEngineScreen({super.key});

  @override
  State<OmegaKnowledgeEngineScreen> createState() =>
      _OmegaKnowledgeEngineScreenState();
}

class _OmegaKnowledgeEngineScreenState extends State<OmegaKnowledgeEngineScreen>
    with SingleTickerProviderStateMixin {
  final OmegaKnowledgeEngineService _service = OmegaKnowledgeEngineService();
  final Map<String, TextEditingController> _repoControllers = {};
  final Map<String, FocusNode> _repoFocusNodes = {};
  TabController? _tabController;
  late final TextEditingController _repoRootController;
  late final TextEditingController _outputDirController;
  late final TextEditingController _obsidianExportController;
  late final TextEditingController _omegaOsRootController;
  late final TextEditingController _obsidianVaultController;
  List<OmegaKnowledgeEngineRepoProfile> _repoProfilesDraft = [];
  OmegaKnowledgeEngineSnapshot? _snapshot;
  String? _loadError;
  bool _loading = true;
  bool _saving = false;
  bool _runningScan = false;
  int _initialTabIndex = 0;
  bool _resolvedInitialTabIndex = false;

  @override
  void initState() {
    super.initState();
    _repoRootController = TextEditingController();
    _outputDirController = TextEditingController();
    _obsidianExportController = TextEditingController();
    _omegaOsRootController = TextEditingController();
    _obsidianVaultController = TextEditingController();
    _loadSnapshot();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedInitialTabIndex) {
      return;
    }

    final tabName = GoRouterState.of(context).uri.queryParameters['tab'];
    _initialTabIndex = _tabIndexFor(tabName);
    _resolvedInitialTabIndex = true;
    _ensureTabController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    for (final controller in _repoControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _repoFocusNodes.values) {
      focusNode.dispose();
    }
    _repoRootController.dispose();
    _outputDirController.dispose();
    _obsidianExportController.dispose();
    _omegaOsRootController.dispose();
    _obsidianVaultController.dispose();
    super.dispose();
  }

  Future<void> _loadSnapshot() async {
    try {
      final snapshot = await _service.loadSnapshot();
      if (!mounted) {
        return;
      }

      _seedControllers(snapshot.settings);
      setState(() {
        _snapshot = snapshot;
        _loadError = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  void _seedControllers(OmegaKnowledgeEngineSettings settings) {
    _repoRootController.text = settings.repoRootPath;
    _outputDirController.text = settings.outputDir;
    _obsidianExportController.text = settings.obsidianExportDir;
    _omegaOsRootController.text = settings.omegaOsRootWindows;
    _obsidianVaultController.text = settings.obsidianVaultWindows;
    _repoProfilesDraft = settings.repoProfiles.toList(growable: true);

    _syncRepoControllers(_repoProfilesDraft);

    for (final profile in _repoProfilesDraft) {
      final controller = _repoControllers.putIfAbsent(
        profile.key,
        () => TextEditingController(),
      );
      controller.text = profile.pathWindows;
    }
  }

  Future<void> _saveSettings() async {
    final snapshot = _snapshot;
    if (snapshot == null || _saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final updatedSettings = snapshot.settings.copyWith(
      repoRootPath: _repoRootController.text.trim(),
      outputDir: _outputDirController.text.trim(),
      obsidianExportDir: _obsidianExportController.text.trim(),
      omegaOsRootWindows: _omegaOsRootController.text.trim(),
      obsidianVaultWindows: _obsidianVaultController.text.trim(),
      repoProfiles: [
        for (final profile in _repoProfilesDraft)
          OmegaKnowledgeEngineRepoProfile(
            key: profile.key,
            name: profile.name,
            pathWindows: _repoControllers[profile.key]?.text.trim() ?? profile.pathWindows,
            type: profile.type,
          ),
      ],
    );

    try {
      await _service.saveSettings(updatedSettings);
      final reloaded = await _service.loadSnapshot();
      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = reloaded;
        _loadError = null;
        _seedControllers(reloaded.settings);
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Omega Knowledge Engine settings saved locally.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save Omega settings: $error')),
      );
    }
  }

  Future<void> _resetSettings() async {
    setState(() {
      _saving = true;
    });

    try {
      await _service.saveSettings(
        OmegaKnowledgeEngineSettings.defaults(
          moduleRootPath: _service.moduleRootPath,
        ),
      );
      await _loadSnapshot();

      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Knowledge Engine settings reset.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not reset Omega settings: $error')),
      );
    }
  }

  Future<void> _copyScanCommand() async {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: snapshot.scanCommand));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan command copied.')),
    );
  }

  Future<void> _runScan() async {
    if (_runningScan) {
      return;
    }

    setState(() {
      _runningScan = true;
    });

    try {
      final result = await _service.runScan();
      final reloaded = await _service.loadSnapshot();

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = reloaded;
        _loadError = null;
        _seedControllers(reloaded.settings);
        _runningScan = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.succeeded
                ? 'Omega scan completed and outputs refreshed.'
                : 'Omega scan did not complete: ${result.summary}',
          ),
        ),
      );

      if (result.succeeded) {
        _openScanResults();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _runningScan = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Omega scan failed to start: $error')),
      );
    }
  }

  void _openScanResults() {
    _openTab(2);
  }

  void _openSettings() {
    _openTab(8);
  }

  void _openTab(int index) {
    _tabController?.animateTo(index);
  }

  Future<OmegaKnowledgeEngineRepoProfile?> _showRepoProfileDialog(
    BuildContext context,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final pathController = TextEditingController();
    final typeController = TextEditingController(text: 'custom');
    final presets = _repoProfilePresets();
    var selectedPresetKey = 'custom';

    void applyPreset(_RepoProfilePreset preset) {
      selectedPresetKey = preset.key;
      nameController.text = preset.name;
      pathController.text = preset.pathWindows;
      typeController.text = preset.type;
    }

    applyPreset(presets.firstWhere((preset) => preset.key == 'custom'));

    try {
      return await showDialog<OmegaKnowledgeEngineRepoProfile>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Add repository target'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: StatefulBuilder(
                  builder: (dialogContext, setDialogState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Presets',
                          style: Theme.of(dialogContext).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final preset in presets)
                              ChoiceChip(
                                label: Text(preset.label),
                                selected: selectedPresetKey == preset.key,
                                onSelected: (_) {
                                  setDialogState(() {
                                    applyPreset(preset);
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          onChanged: (_) {
                            setDialogState(() {
                              selectedPresetKey = 'custom';
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Repo name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter a repo name.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: pathController,
                          onChanged: (_) {
                            setDialogState(() {
                              selectedPresetKey = 'custom';
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Windows path',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Enter a local path.';
                            }
                            if (!_isWindowsAbsolutePath(trimmed)) {
                              return 'Use an absolute Windows path like D:\\Repo.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: typeController,
                          onChanged: (_) {
                            setDialogState(() {
                              selectedPresetKey = 'custom';
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Repo type',
                            helperText:
                                'Examples: flutter_app, firmware_flutter, custom',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter a repo type.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'The path is only stored locally. Nothing is written to the repo itself.',
                          style: Theme.of(dialogContext).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final form = formKey.currentState;
                  if (form == null || !form.validate()) {
                    return;
                  }
                  final name = nameController.text.trim();
                  final path = pathController.text.trim();
                  final type = typeController.text.trim();
                  Navigator.of(dialogContext).pop(
                    OmegaKnowledgeEngineRepoProfile(
                      key: _repoProfileKeyFromName(name),
                      name: name,
                      pathWindows: path,
                      type: type,
                    ),
                  );
                },
                child: const Text('Add repo'),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
      pathController.dispose();
      typeController.dispose();
    }
  }

  Future<void> _addRepoProfile() async {
    final profile = await _showRepoProfileDialog(context);
    if (!mounted || profile == null) {
      return;
    }

    setState(() {
      _repoProfilesDraft = [..._repoProfilesDraft, profile];
      _syncRepoControllers(_repoProfilesDraft);
      _repoControllers[profile.key]?.text = profile.pathWindows;
    });
  }

  void _removeRepoProfile(String key) {
    setState(() {
      _repoProfilesDraft = _repoProfilesDraft.where((profile) => profile.key != key).toList(growable: true);
      final controller = _repoControllers.remove(key);
      controller?.dispose();
      final focusNode = _repoFocusNodes.remove(key);
      focusNode?.dispose();
    });
  }

  void _syncRepoControllers(List<OmegaKnowledgeEngineRepoProfile> profiles) {
    final activeKeys = profiles.map((profile) => profile.key).toSet();
    final staleKeys = _repoControllers.keys.where((key) => !activeKeys.contains(key)).toList();
    for (final key in staleKeys) {
      _repoControllers.remove(key)?.dispose();
      _repoFocusNodes.remove(key)?.dispose();
    }
    for (final profile in profiles) {
      _repoControllers.putIfAbsent(profile.key, () => TextEditingController());
      _repoFocusNodes.putIfAbsent(profile.key, () => FocusNode());
    }
  }

  void _ensureTabController() {
    _tabController ??= TabController(
      length: 9,
      vsync: this,
      initialIndex: _initialTabIndex,
    );
  }

  int _tabIndexFor(String? tabName) {
    return switch (tabName) {
      'repositories' => 1,
      'scan-results' => 2,
      'learning-notes' => 3,
      'architecture-map' => 4,
      'comment-suggestions' => 5,
      'project-memory' => 6,
      'obsidian-export' => 7,
      'settings' => 8,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go(RouteNames.moduleHub)),
          title: const Text('Omega Knowledge Engine'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && _snapshot == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go(RouteNames.moduleHub)),
          title: const Text('Omega Knowledge Engine'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Omega Knowledge Engine could not load',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _loadError!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                _loading = true;
                                _loadError = null;
                              });
                              unawaited(_loadSnapshot());
                            },
                            icon: const Icon(Icons.refresh_outlined),
                            label: const Text('Try again'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _openSettings,
                            icon: const Icon(Icons.settings_outlined),
                            label: const Text('Open settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final snapshot = _snapshot!;
    final theme = Theme.of(context);
    _ensureTabController();
    final repoHealth = _buildRepoHealth(snapshot);
    final outputHealth = _buildOutputHealth();
    final outputPreviews = _buildOutputPreviews(snapshot);
    final healthWarnings = _buildHealthWarnings(
      snapshot: snapshot,
      repoHealth: repoHealth,
      outputHealth: outputHealth,
    );
    final tabs = const [
      Tab(text: 'Overview'),
      Tab(text: 'Repositories'),
      Tab(text: 'Scan Results'),
      Tab(text: 'Learning Notes'),
      Tab(text: 'Architecture Map'),
      Tab(text: 'Comment Suggestions'),
      Tab(text: 'Project Memory'),
      Tab(text: 'Obsidian Export'),
      Tab(text: 'Settings'),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RouteNames.moduleHub)),
        title: const Text('Omega Knowledge Engine'),
        actions: [
          TextButton.icon(
            onPressed: _openScanResults,
            icon: const Icon(Icons.table_view_outlined),
            label: const Text('Scan outputs'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _runningScan ? null : _runScan,
            icon: _runningScan
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_outlined),
            label: Text(_runningScan ? 'Scanning' : 'Run scan'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _copyScanCommand,
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy command'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(
            snapshot: snapshot,
            theme: theme,
            repoHealth: repoHealth,
            outputHealth: outputHealth,
            outputPreviews: outputPreviews,
            onRunScan: _runScan,
            onOpenScanResults: _openScanResults,
            onOpenLearningNotes: () => _openTab(3),
            onOpenArchitectureMap: () => _openTab(4),
            onOpenCommentSuggestions: () => _openTab(5),
            onOpenProjectMemory: () => _openTab(6),
            onOpenObsidianExport: () => _openTab(7),
            onOpenSettings: _openSettings,
            healthWarnings: healthWarnings,
            onOpenOutputFolder: () => _openLocalPath(snapshot.settings.outputDir),
            onOpenObsidianExportFolder: () =>
                _openLocalPath(snapshot.settings.obsidianExportDir),
            onCopyOutputPath: () => _copyText(snapshot.settings.outputDir),
          ),
          _RepositoriesTab(
            snapshot: snapshot,
            theme: theme,
            repoProfiles: _repoProfilesDraft,
          ),
          _DocumentTab(
            title: 'Scan Results',
            subtitle: 'Repository index and generated scan snapshot.',
            documents: [
              _DocumentSource(
                label: 'repository_index.json',
                path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/repository_index.json',
                content: snapshot.repositoryIndexText.isEmpty
                    ? 'No repository index found yet.'
                    : const JsonEncoder.withIndent('  ').convert(
                        snapshot.repositoryIndexJson,
                      ),
              ),
              _DocumentSource(
                label: 'repository_index.md',
                path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/repository_index.md',
                content: snapshot.repositoryIndexText,
              ),
            ],
          ),
          _DocumentTab(
            title: 'Learning Notes',
            subtitle: 'First-pass explanations for the codebase.',
            documents: [
              _DocumentSource(
                label: 'code_learning_notes.md',
                path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/code_learning_notes.md',
                content: snapshot.learningNotesText,
              ),
            ],
          ),
          _DocumentTab(
            title: 'Architecture Map',
            subtitle: 'Folder-level structure and safety boundaries.',
            documents: [
              _DocumentSource(
                label: 'architecture_map.md',
                path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/architecture_map.md',
                content: snapshot.architectureMapText,
              ),
            ],
          ),
          _CommentSuggestionsTab(
            text: snapshot.commentSuggestionsText,
          ),
          _DocumentTab(
            title: 'Project Memory',
            subtitle: 'Decisions, lessons, and next steps.',
            documents: [
              _DocumentSource(
                label: 'project_memory.md',
                path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/project_memory.md',
                content: snapshot.projectMemoryText,
              ),
            ],
          ),
          _ObsidianExportTab(
            snapshot: snapshot,
            theme: theme,
            onOpenExportFolder: () =>
                _openLocalPath(snapshot.settings.obsidianExportDir),
            onCopyExportPath: () => _copyText(snapshot.settings.obsidianExportDir),
          ),
          _SettingsTab(
            snapshot: snapshot,
            repoProfiles: _repoProfilesDraft,
            repoRootController: _repoRootController,
            outputDirController: _outputDirController,
            obsidianExportController: _obsidianExportController,
            omegaOsRootController: _omegaOsRootController,
            obsidianVaultController: _obsidianVaultController,
            repoControllers: _repoControllers,
            repoFocusNodes: _repoFocusNodes,
            onAddRepo: _addRepoProfile,
            onRemoveRepo: _removeRepoProfile,
            onSave: _saveSettings,
            onReset: _resetSettings,
            saving: _saving,
          ),
        ],
      ),
    );
  }

  List<_PathHealth> _buildRepoHealth(OmegaKnowledgeEngineSnapshot snapshot) {
    return [
      for (final profile in snapshot.settings.repoProfiles)
        _PathHealth(
          label: profile.name,
          path: profile.pathWindows,
          exists: Directory(profile.pathWindows).existsSync(),
          kind: profile.type,
        ),
    ];
  }

  List<_PathHealth> _buildOutputHealth() {
    return [
      _PathHealth(
        label: 'repository_index.json',
        path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/repository_index.json',
        exists: _entityExists('modules/26_OMEGA_KNOWLEDGE_ENGINE/output/repository_index.json'),
        kind: 'scan result',
      ),
      _PathHealth(
        label: 'repository_index.md',
        path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/repository_index.md',
        exists: _entityExists('modules/26_OMEGA_KNOWLEDGE_ENGINE/output/repository_index.md'),
        kind: 'scan result',
      ),
      _PathHealth(
        label: 'code_learning_notes.md',
        path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/code_learning_notes.md',
        exists: _entityExists('modules/26_OMEGA_KNOWLEDGE_ENGINE/output/code_learning_notes.md'),
        kind: 'learning notes',
      ),
      _PathHealth(
        label: 'architecture_map.md',
        path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/architecture_map.md',
        exists: _entityExists('modules/26_OMEGA_KNOWLEDGE_ENGINE/output/architecture_map.md'),
        kind: 'architecture',
      ),
      _PathHealth(
        label: 'comment_suggestions.md',
        path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/comment_suggestions.md',
        exists: _entityExists('modules/26_OMEGA_KNOWLEDGE_ENGINE/output/comment_suggestions.md'),
        kind: 'suggestions',
      ),
      _PathHealth(
        label: 'project_memory.md',
        path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/project_memory.md',
        exists: _entityExists('modules/26_OMEGA_KNOWLEDGE_ENGINE/output/project_memory.md'),
        kind: 'memory',
      ),
      _PathHealth(
        label: 'obsidian_export/',
        path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/obsidian_export',
        exists: _entityExists('modules/26_OMEGA_KNOWLEDGE_ENGINE/output/obsidian_export'),
        kind: 'vault export',
      ),
    ];
  }

  List<_OutputPreview> _buildOutputPreviews(OmegaKnowledgeEngineSnapshot snapshot) {
    return [
      _OutputPreview(
        label: 'Scan results',
        subtitle: 'repository_index.json and repository_index.md',
        snippet: snapshot.repositoryIndexText.isEmpty
            ? 'No repository index exists yet.'
            : snapshot.repositoryIndexText.split('\n').first,
        open: _openScanResults,
        tabLabel: 'Scan Results',
        sourceLabel: 'repository_index.*',
      ),
      _OutputPreview(
        label: 'Learning notes',
        subtitle: 'code_learning_notes.md',
        snippet: snapshot.learningNotesText.isEmpty
            ? 'No learning notes exist yet.'
            : snapshot.learningNotesText.split('\n').first,
        open: () => _openTab(3),
        tabLabel: 'Learning Notes',
        sourceLabel: 'code_learning_notes.md',
      ),
      _OutputPreview(
        label: 'Architecture map',
        subtitle: 'architecture_map.md',
        snippet: snapshot.architectureMapText.isEmpty
            ? 'No architecture map exists yet.'
            : snapshot.architectureMapText.split('\n').first,
        open: () => _openTab(4),
        tabLabel: 'Architecture Map',
        sourceLabel: 'architecture_map.md',
      ),
      _OutputPreview(
        label: 'Comment suggestions',
        subtitle: 'comment_suggestions.md',
        snippet: snapshot.commentSuggestionsText.isEmpty
            ? 'No comment suggestions exist yet.'
            : snapshot.commentSuggestionsText.split('\n').first,
        open: () => _openTab(5),
        tabLabel: 'Comment Suggestions',
        sourceLabel: 'comment_suggestions.md',
      ),
      _OutputPreview(
        label: 'Project memory',
        subtitle: 'project_memory.md',
        snippet: snapshot.projectMemoryText.isEmpty
            ? 'No project memory exists yet.'
            : snapshot.projectMemoryText.split('\n').first,
        open: () => _openTab(6),
        tabLabel: 'Project Memory',
        sourceLabel: 'project_memory.md',
      ),
      _OutputPreview(
        label: 'Obsidian export',
        subtitle: 'obsidian_export/',
        snippet: snapshot.obsidianExportFiles.isEmpty
            ? 'No export files are staged yet.'
            : '${snapshot.obsidianExportFiles.length} staged file(s) ready for review.',
        open: () => _openTab(7),
        tabLabel: 'Obsidian Export',
        sourceLabel: 'obsidian_export/',
      ),
    ];
  }

  List<String> _buildHealthWarnings({
    required OmegaKnowledgeEngineSnapshot snapshot,
    required List<_PathHealth> repoHealth,
    required List<_PathHealth> outputHealth,
  }) {
    final warnings = <String>[];
    final missingRepos = repoHealth.where((item) => !item.exists).toList();
    final missingOutputs = outputHealth.where((item) => !item.exists).toList();

    if (snapshot.settings.safetyMode != 'scan_report_only') {
      warnings.add(
        'Safety mode is set to ${snapshot.settings.safetyMode}; the module is designed to stay in scan/report mode by default.',
      );
    }

    if (missingRepos.isNotEmpty) {
      warnings.add(
        'Missing repo target(s): ${missingRepos.map((item) => item.label).join(', ')}.',
      );
    }

    if (missingOutputs.isNotEmpty) {
      warnings.add(
        'Missing output file(s): ${missingOutputs.map((item) => item.label).join(', ')}.',
      );
    }

    if (!Directory(snapshot.settings.outputDir).existsSync()) {
      warnings.add(
        'The configured output directory does not exist yet: ${snapshot.settings.outputDir}',
      );
    }

    return warnings;
  }

  bool _entityExists(String relativePath) {
    return FileSystemEntity.typeSync(relativePath) != FileSystemEntityType.notFound;
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Path copied to clipboard.')),
    );
  }

  Future<void> _openLocalPath(String localPath) async {
    final trimmed = localPath.trim();
    if (trimmed.isEmpty) {
      return;
    }

    try {
      if (Platform.isWindows) {
        await Process.start('explorer', [trimmed], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.start('open', [trimmed], runInShell: true);
      } else {
        await Process.start('xdg-open', [trimmed], runInShell: true);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open path: $trimmed')),
      );
    }
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.snapshot,
    required this.theme,
    required this.repoHealth,
    required this.outputHealth,
    required this.outputPreviews,
    required this.onRunScan,
    required this.onOpenScanResults,
    required this.onOpenLearningNotes,
    required this.onOpenArchitectureMap,
    required this.onOpenCommentSuggestions,
    required this.onOpenProjectMemory,
    required this.onOpenObsidianExport,
    required this.onOpenSettings,
    required this.healthWarnings,
    required this.onOpenOutputFolder,
    required this.onOpenObsidianExportFolder,
    required this.onCopyOutputPath,
  });

  final OmegaKnowledgeEngineSnapshot snapshot;
  final ThemeData theme;
  final List<_PathHealth> repoHealth;
  final List<_PathHealth> outputHealth;
  final List<_OutputPreview> outputPreviews;
  final VoidCallback onRunScan;
  final VoidCallback onOpenScanResults;
  final VoidCallback onOpenLearningNotes;
  final VoidCallback onOpenArchitectureMap;
  final VoidCallback onOpenCommentSuggestions;
  final VoidCallback onOpenProjectMemory;
  final VoidCallback onOpenObsidianExport;
  final VoidCallback onOpenSettings;
  final List<String> healthWarnings;
  final VoidCallback onOpenOutputFolder;
  final VoidCallback onOpenObsidianExportFolder;
  final VoidCallback onCopyOutputPath;

  @override
  Widget build(BuildContext context) {
    final readyRepoCount = repoHealth.where((item) => item.exists).length;
    final missingRepoCount = repoHealth.length - readyRepoCount;
    final readyOutputCount = outputHealth.where((item) => item.exists).length;
    final missingOutputCount = outputHealth.length - readyOutputCount;
    final scanReadiness = missingRepoCount == 0 && missingOutputCount == 0
        ? 'Ready to scan'
        : missingRepoCount < repoHealth.length && missingOutputCount < outputHealth.length
            ? 'Partially ready'
            : 'Needs attention';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BannerCard(
          title: 'Scan first. Report first. Learn first.',
          subtitle:
              'The Omega Knowledge Engine stays read-only by default and keeps the source tree untouched unless a future manual approval path is added.',
          actions: [
            FilledButton.tonalIcon(
              onPressed: onRunScan,
              icon: const Icon(Icons.play_arrow_outlined),
              label: const Text('Run scan'),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: onOpenScanResults,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('View scan results'),
            ),
            FilledButton.tonalIcon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open settings'),
            ),
          ],
          chips: [
            'Safe default',
            snapshot.settings.safetyMode,
            'No mass edits',
            'Backup first later',
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: onOpenLearningNotes,
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Learning notes'),
            ),
            TextButton.icon(
              onPressed: onOpenArchitectureMap,
              icon: const Icon(Icons.account_tree_outlined),
              label: const Text('Architecture map'),
            ),
            TextButton.icon(
              onPressed: onOpenCommentSuggestions,
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Comment suggestions'),
            ),
            TextButton.icon(
              onPressed: onOpenProjectMemory,
              icon: const Icon(Icons.memory_outlined),
              label: const Text('Project memory'),
            ),
            TextButton.icon(
              onPressed: onOpenObsidianExport,
              icon: const Icon(Icons.auto_stories_outlined),
              label: const Text('Obsidian export'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatCard(label: 'Repositories', value: '${snapshot.repositoryCount}'),
            _StatCard(label: 'Files scanned', value: '${snapshot.filesScanned}'),
            _StatCard(label: 'Obsidian files', value: '${snapshot.obsidianExportFiles.length}'),
            _StatCard(label: 'Generated at', value: snapshot.generatedAt),
          ],
        ),
        const SizedBox(height: 16),
        _PanelCard(
          title: 'Repository validation',
          subtitle:
              'A calm readout of repository targets, generated outputs, and scan readiness.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(label: 'Scan readiness', value: scanReadiness),
                  _StatCard(
                    label: 'Repos ready',
                    value: '$readyRepoCount/${repoHealth.length}',
                  ),
                  _StatCard(
                    label: 'Outputs ready',
                    value: '$readyOutputCount/${outputHealth.length}',
                  ),
                  _StatCard(label: 'Last generated', value: snapshot.generatedAt),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    label: scanReadiness,
                    tone: scanReadiness == 'Ready'
                        ? _ChipTone.success
                        : scanReadiness == 'Partially ready'
                            ? _ChipTone.info
                            : _ChipTone.danger,
                  ),
                  _StatusChip(
                    label:
                        '$readyRepoCount/${repoHealth.length} repos present',
                    tone: _ChipTone.info,
                  ),
                  _StatusChip(
                    label:
                        '$readyOutputCount/${outputHealth.length} outputs present',
                    tone: _ChipTone.info,
                  ),
                  _StatusChip(
                    label: snapshot.settings.safetyMode.replaceAll('_', ' '),
                    tone: _ChipTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Repository checks', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              for (final item in repoHealth) ...[
                _PathHealthRow(item: item),
                if (item != repoHealth.last) const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              Text('Output checks', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              for (final item in outputHealth) ...[
                _PathHealthRow(item: item),
                if (item != outputHealth.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        if (healthWarnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _PanelCard(
            title: 'Health notes',
            subtitle: 'These are the items worth checking before the next scan.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final warning in healthWarnings) ...[
                  _BulletLine(text: warning),
                  if (warning != healthWarnings.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _PanelCard(
          title: 'Output previews',
          subtitle:
              'Quick previews with one-click jumps into the detailed tabs and a clear view of what is already generated.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    label:
                        '${outputHealth.where((item) => item.exists).length}/${outputHealth.length} outputs ready',
                    tone: _ChipTone.success,
                  ),
                  _StatusChip(
                    label:
                        '${outputHealth.where((item) => !item.exists).length} missing',
                    tone: outputHealth.any((item) => !item.exists)
                        ? _ChipTone.info
                        : _ChipTone.neutral,
                  ),
                  const _StatusChip(
                    label: 'Review-first',
                    tone: _ChipTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final preview in outputPreviews) ...[
                _OutputPreviewCard(preview: preview),
                if (preview != outputPreviews.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PanelCard(
          title: 'Output health',
          subtitle:
              'A simple check of the files the engine expects to find in the output folder.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onOpenOutputFolder,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Open output folder'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onOpenObsidianExportFolder,
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: const Text('Open export folder'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onCopyOutputPath,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy output path'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final item in outputHealth) ...[
                _PathHealthRow(item: item),
                if (item != outputHealth.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PanelCard(
          title: 'Scan command',
          subtitle: 'Manual local command kept visible for later safe execution.',
          child: SelectableText(snapshot.scanCommand, style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(height: 16),
        _PanelCard(
          title: 'How it works',
          subtitle: 'The module is designed around review-first learning.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletLine(text: 'Scan the local repositories and index files.'),
              _BulletLine(text: 'Generate notes, architecture maps, and comment suggestions.'),
              _BulletLine(text: 'Review outputs before any future source modification path is enabled.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _RepositoriesTab extends StatelessWidget {
  const _RepositoriesTab({
    required this.snapshot,
    required this.theme,
    required this.repoProfiles,
  });

  final OmegaKnowledgeEngineSnapshot snapshot;
  final ThemeData theme;
  final List<OmegaKnowledgeEngineRepoProfile> repoProfiles;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PanelCard(
          title: 'Configured repositories',
          subtitle: 'These scan targets are stored locally and stay read-only.',
          child: Column(
            children: [
              for (final profile in repoProfiles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RepoProfileCard(profile: profile),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PanelCard(
          title: 'Backed-up intent',
          subtitle: 'The repository list can grow safely as more New Earth repos arrive.',
          child: Text(
            'Dashboard repo, MicroGrow, BioCalm, New Earth Living, and future repos are all preloaded as scan targets. The live draft currently tracks ${repoProfiles.length} target(s).',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _DocumentTab extends StatelessWidget {
  const _DocumentTab({
    required this.title,
    required this.subtitle,
    required this.documents,
  });

  final String title;
  final String subtitle;
  final List<_DocumentSource> documents;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PanelCard(
          title: title,
          subtitle: subtitle,
          child: Column(
            children: [
              for (final document in documents) ...[
                _SourceDocumentCard(document: document),
                if (document != documents.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentSuggestionsTab extends StatelessWidget {
  const _CommentSuggestionsTab({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PanelCard(
          title: 'Comment Suggestions',
          subtitle: 'Review-only output. Nothing is applied automatically.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BulletLine(
                text: 'Suggestions are for learning and review, not auto-editing.',
              ),
              const _BulletLine(
                text: 'Any future patch flow must include backup-first approval.',
              ),
              const SizedBox(height: 12),
              _SourceTextBlock(
                path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/comment_suggestions.md',
                content: text,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ObsidianExportTab extends StatelessWidget {
  const _ObsidianExportTab({
    required this.snapshot,
    required this.theme,
    required this.onOpenExportFolder,
    required this.onCopyExportPath,
  });

  final OmegaKnowledgeEngineSnapshot snapshot;
  final ThemeData theme;
  final VoidCallback onOpenExportFolder;
  final VoidCallback onCopyExportPath;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PanelCard(
          title: 'Obsidian Export',
          subtitle: 'A local staging area for vault-ready notes.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KeyValueRow(
                label: 'Export directory',
                value: snapshot.settings.obsidianExportDir,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                    for (final file in snapshot.obsidianExportFiles)
                      Chip(label: Text(file)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onOpenExportFolder,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Open export folder'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onCopyExportPath,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy export path'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SourceTextBlock(
                path: 'modules/26_OMEGA_KNOWLEDGE_ENGINE/output/obsidian_export/README.md',
                content: snapshot.obsidianExportFiles.isEmpty
                    ? 'No export files are present yet.'
                    : _obsidianExportNote(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PanelCard(
          title: 'Export posture',
          subtitle: 'Exported notes stay source-grounded and reviewable.',
          child: Text(
            'The Obsidian bridge should only mirror outputs after the user has reviewed the scan results and learning notes.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _obsidianExportNote() {
    return [
      '# Obsidian Export',
      '',
      'Files staged for the vault are listed above.',
      '',
      'Keep this folder local and review-first.',
    ].join('\n');
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    required this.snapshot,
    required this.repoProfiles,
    required this.repoRootController,
    required this.outputDirController,
    required this.obsidianExportController,
    required this.omegaOsRootController,
    required this.obsidianVaultController,
    required this.repoControllers,
    required this.repoFocusNodes,
    required this.onAddRepo,
    required this.onRemoveRepo,
    required this.onSave,
    required this.onReset,
    required this.saving,
  });

  final OmegaKnowledgeEngineSnapshot snapshot;
  final List<OmegaKnowledgeEngineRepoProfile> repoProfiles;
  final TextEditingController repoRootController;
  final TextEditingController outputDirController;
  final TextEditingController obsidianExportController;
  final TextEditingController omegaOsRootController;
  final TextEditingController obsidianVaultController;
  final Map<String, TextEditingController> repoControllers;
  final Map<String, FocusNode> repoFocusNodes;
  final Future<void> Function() onAddRepo;
  final ValueChanged<String> onRemoveRepo;
  final Future<void> Function() onSave;
  final Future<void> Function() onReset;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PanelCard(
          title: 'Safety posture',
          subtitle: 'This screen only edits local path settings.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletLine(text: 'Scan/report mode stays the default.'),
              _BulletLine(text: 'No automatic code edits or comment writes.'),
              _BulletLine(text: 'Repo paths can be reviewed before the scanner is ever run.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PanelCard(
          title: 'Settings',
          subtitle: 'Local repo paths and export settings only. No source edits.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BulletLine(
                text: 'Repo paths are stored locally in knowledge_engine_settings.json.',
              ),
              const _BulletLine(
                text: 'The scanner is manual and preview-first for now.',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: repoRootController,
                decoration: const InputDecoration(
                  labelText: 'Dashboard repo root',
                  helperText: 'Main repo path used for scans',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: outputDirController,
                decoration: const InputDecoration(
                  labelText: 'Generated output directory',
                  helperText: 'Local index and note files are written here',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: obsidianExportController,
                decoration: const InputDecoration(
                  labelText: 'Obsidian export staging',
                  helperText: 'Review-only export files live here',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: omegaOsRootController,
                decoration: const InputDecoration(
                  labelText: 'Omega OS root (Windows)',
                  helperText: 'Used for local export path mapping',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: obsidianVaultController,
                decoration: const InputDecoration(
                  labelText: 'Obsidian vault (Windows)',
                  helperText: 'Vault path for mirrored notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Repository scan targets', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    label: 'Targets',
                    value: '${repoProfiles.length}',
                  ),
                  const _StatCard(
                    label: 'Mode',
                    value: 'Add/remove local',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final profile in repoProfiles) ...[
                _RepoTargetEditorRow(
                  profile: profile,
                  controller: repoControllers[profile.key],
                  focusNode: repoFocusNodes[profile.key],
                  onRemove: () => onRemoveRepo(profile.key),
                ),
                const SizedBox(height: 12),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: saving
                      ? null
                      : () {
                          unawaited(onAddRepo());
                        },
                  icon: const Icon(Icons.add_outlined),
                  label: const Text('Add repo target'),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: saving ? null : onSave,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save local settings'),
                  ),
                  OutlinedButton.icon(
                    onPressed: saving ? null : onReset,
                    icon: const Icon(Icons.restart_alt_outlined),
                    label: const Text('Reset defaults'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PanelCard(
          title: 'Manual command',
          subtitle: 'Scanner command preview',
          child: SelectableText(
            snapshot.scanCommand,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _RepoTargetEditorRow extends StatelessWidget {
  const _RepoTargetEditorRow({
    required this.profile,
    required this.controller,
    required this.focusNode,
    required this.onRemove,
  });

  final OmegaKnowledgeEngineRepoProfile profile;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveController = controller!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: effectiveController,
            builder: (context, value, _) {
              final exists = Directory(value.text.trim().isEmpty
                      ? profile.pathWindows
                      : value.text.trim())
                  .existsSync();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.type} · ${exists ? 'Path ready' : 'Path missing'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Chip(label: Text(exists ? 'Ready' : 'Missing')),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Remove'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: effectiveController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Windows path',
              helperText: 'Local only',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceDocumentCard extends StatelessWidget {
  const _SourceDocumentCard({required this.document});

  final _DocumentSource document;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: document.label,
      subtitle: document.path,
      child: _SourceTextBlock(path: document.path, content: document.content),
    );
  }
}

class _SourceTextBlock extends StatelessWidget {
  const _SourceTextBlock({required this.path, required this.content});

  final String path;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: SelectableText(
        content,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
      ),
    );
  }
}

class _RepoProfileCard extends StatelessWidget {
  const _RepoProfileCard({required this.profile});

  final OmegaKnowledgeEngineRepoProfile profile;

  @override
  Widget build(BuildContext context) {
    final exists = Directory(profile.pathWindows).existsSync();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(profile.type)),
              ],
            ),
            const SizedBox(height: 6),
            Text(profile.pathWindows),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const Chip(label: Text('Scan target')),
                Chip(label: Text(exists ? 'Path ready' : 'Path missing')),
                const Chip(label: Text('Read-only')),
                const Chip(label: Text('Local path')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.chips,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(subtitle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final chip in chips) Chip(label: Text(chip))],
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 12, runSpacing: 12, children: actions),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('-  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PathHealthRow extends StatelessWidget {
  const _PathHealthRow({required this.item});

  final _PathHealth item;

  @override
  Widget build(BuildContext context) {
    final color = item.exists
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(
            item.exists ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(item.path, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusChip(
                label: item.exists ? 'Ready' : 'Missing',
                tone: item.exists ? _ChipTone.success : _ChipTone.danger,
              ),
              const SizedBox(height: 4),
              Text(
                item.kind,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutputPreviewCard extends StatelessWidget {
  const _OutputPreviewCard({required this.preview});

  final _OutputPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMissing = preview.snippet.startsWith('No ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMissing
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMissing
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.28)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(preview.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(preview.subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: isMissing ? 'Missing' : 'Ready',
                tone: isMissing ? _ChipTone.danger : _ChipTone.success,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: preview.tabLabel,
                tone: _ChipTone.neutral,
              ),
              _StatusChip(
                label: preview.sourceLabel,
                tone: _ChipTone.info,
              ),
              TextButton.icon(
                onPressed: preview.open,
                icon: const Icon(Icons.open_in_new_outlined),
                label: Text('Open ${preview.tabLabel}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            preview.snippet,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isMissing
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (tone) {
      _ChipTone.success => colorScheme.primary,
      _ChipTone.info => colorScheme.tertiary,
      _ChipTone.neutral => colorScheme.outline,
      _ChipTone.danger => colorScheme.error,
    };

    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
      backgroundColor: color.withValues(alpha: 0.08),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _DocumentSource {
  const _DocumentSource({
    required this.label,
    required this.path,
    required this.content,
  });

  final String label;
  final String path;
  final String content;
}

class _PathHealth {
  const _PathHealth({
    required this.label,
    required this.path,
    required this.exists,
    required this.kind,
  });

  final String label;
  final String path;
  final bool exists;
  final String kind;

  _PathHealth copyWith({bool? exists}) {
    return _PathHealth(
      label: label,
      path: path,
      exists: exists ?? this.exists,
      kind: kind,
    );
  }
}

class _OutputPreview {
  const _OutputPreview({
    required this.label,
    required this.subtitle,
    required this.snippet,
    required this.open,
    required this.tabLabel,
    required this.sourceLabel,
  });

  final String label;
  final String subtitle;
  final String snippet;
  final VoidCallback open;
  final String tabLabel;
  final String sourceLabel;
}

class _RepoProfilePreset {
  const _RepoProfilePreset({
    required this.key,
    required this.label,
    required this.name,
    required this.pathWindows,
    required this.type,
  });

  final String key;
  final String label;
  final String name;
  final String pathWindows;
  final String type;
}

List<_RepoProfilePreset> _repoProfilePresets() {
  return const [
    _RepoProfilePreset(
      key: 'dashboard',
      label: 'Dashboard',
      name: 'Dashboard repo',
      pathWindows: r'D:\Dev\Projects\New Earth - Command Dashboard',
      type: 'flutter_app',
    ),
    _RepoProfilePreset(
      key: 'microgrow',
      label: 'MicroGrow',
      name: 'MicroGrow repo',
      pathWindows: r'D:\Dev\Projects\MicroGrow',
      type: 'firmware_flutter',
    ),
    _RepoProfilePreset(
      key: 'biocalm',
      label: 'BioCalm',
      name: 'BioCalm repo',
      pathWindows: r'D:\Dev\Projects\BioCalm',
      type: 'wearable_firmware',
    ),
    _RepoProfilePreset(
      key: 'new_earth_living',
      label: 'New Earth Living',
      name: 'New Earth Living repo',
      pathWindows: r'D:\Dev\Projects\New Earth Living',
      type: 'flutter_app',
    ),
    _RepoProfilePreset(
      key: 'custom',
      label: 'Custom',
      name: 'Custom repo',
      pathWindows: r'D:\Dev\Projects\New Earth Repos\Custom',
      type: 'custom',
    ),
  ];
}

String _repoProfileKeyFromName(String name) {
  final normalized = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');
  return 'repo_${trimmed.isEmpty ? 'target' : trimmed}';
}

bool _isWindowsAbsolutePath(String value) {
  return RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value.trim());
}

enum _ChipTone { success, info, neutral, danger }
