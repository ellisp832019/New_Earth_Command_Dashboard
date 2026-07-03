import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../application/engineering_services.dart';
import '../data/engineering_repository.dart';
import '../domain/engineering_models.dart';
import 'widgets/engineering_widgets.dart';

class EngineeringStudioScreen extends StatefulWidget {
  const EngineeringStudioScreen({
    super.key,
    this.repository,
    this.initialSection = EngineeringSection.dashboard,
  });

  final EngineeringRepository? repository;
  final EngineeringSection initialSection;

  @override
  State<EngineeringStudioScreen> createState() =>
      _EngineeringStudioScreenState();
}

class _EngineeringStudioScreenState extends State<EngineeringStudioScreen> {
  late final EngineeringRepository _repository =
      widget.repository ?? LocalEngineeringRepository();
  late final TextEditingController _searchController;

  EngineeringSnapshot? _snapshot;
  EngineeringSection _section = EngineeringSection.dashboard;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _searchController = TextEditingController();
    unawaited(_loadSnapshot());
  }

  @override
  void didUpdateWidget(covariant EngineeringStudioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection &&
        widget.initialSection != _section) {
      setState(() {
        _section = widget.initialSection;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSnapshot() async {
    try {
      final snapshot = await _repository.loadSnapshot();
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  EngineeringSnapshot get _snapshotOrThrow {
    final snapshot = _snapshot;
    if (snapshot == null) {
      throw StateError('Engineering snapshot not loaded.');
    }
    return snapshot;
  }

  void _setSection(EngineeringSection section) {
    if (_section == section) {
      return;
    }
    setState(() {
      _section = section;
    });
    context.go(_routeFor(section));
  }

  String _routeFor(EngineeringSection section) {
    return RouteNames.omegaEngineeringStudioSection(section.routeSegment);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: EngineeringLoadingState());
    }

    if (_error != null && _snapshot == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Omega Engineering Studio'),
          leading: BackButton(onPressed: () => context.go(RouteNames.more)),
        ),
        body: EngineeringErrorState(
          message: _error!,
          onRetry: () {
            setState(() {
              _loading = true;
              _error = null;
            });
            unawaited(_loadSnapshot());
          },
        ),
      );
    }

    final snapshot = _snapshotOrThrow;
    final projectService = ProjectService(snapshot);
    final circuitService = CircuitLibraryService(snapshot);
    final pcbService = PCBService(snapshot);
    final firmwareService = FirmwareBuildService(snapshot);
    final deviceService = DeviceFleetService(snapshot);
    final componentService = ComponentInventoryService(snapshot);
    final experimentService = ExperimentService(snapshot);
    final validationService = ValidationService(snapshot);
    final manufacturingService = ManufacturingService(snapshot);
    final searchService = EngineeringSearchService(snapshot);
    final searchHits = searchService.search(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text('Omega Engineering Studio · ${_section.label}'),
        leading: BackButton(onPressed: () => context.go(RouteNames.more)),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(RouteNames.omegaKnowledgeEngine),
            icon: const Icon(Icons.travel_explore_outlined),
            label: const Text('Knowledge Engine'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.push(RouteNames.voiceAssistant),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('GAIA'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeroPanel(
            snapshot: snapshot,
            searchController: _searchController,
            searchQuery: _searchQuery,
            statusFilter: _statusFilter,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onStatusFilterChanged: (value) {
              setState(() {
                _statusFilter = value;
              });
            },
            onClearSearch: _clearSearch,
            onOpenKnowledgeEngine: () =>
                context.push(RouteNames.omegaKnowledgeEngine),
            onOpenGaiaAssistant: () => context.push(RouteNames.voiceAssistant),
          ),
          const SizedBox(height: 14),
          _SectionSelector(currentSection: _section, onSelected: _setSection),
          const SizedBox(height: 16),
          if (_searchQuery.trim().isNotEmpty)
            EngineeringSectionShell(
              title: 'Search results',
              subtitle:
                  'A quiet local scan across projects, circuits, boards, devices, and docs.',
              child: searchHits.isEmpty
                  ? EngineeringEmptyState(
                      title: 'No matches yet',
                      subtitle:
                          'Try a project title, board name, device name, or document keyword.',
                      actionLabel: 'Clear search',
                      onAction: _clearSearch,
                    )
                  : _SearchHitsView(
                      hits: searchHits,
                      onOpenSection: _setSection,
                    ),
            ),
          _buildSection(
            snapshot: snapshot,
            projectService: projectService,
            circuitService: circuitService,
            pcbService: pcbService,
            firmwareService: firmwareService,
            deviceService: deviceService,
            componentService: componentService,
            experimentService: experimentService,
            validationService: validationService,
            manufacturingService: manufacturingService,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required EngineeringSnapshot snapshot,
    required ProjectService projectService,
    required CircuitLibraryService circuitService,
    required PCBService pcbService,
    required FirmwareBuildService firmwareService,
    required DeviceFleetService deviceService,
    required ComponentInventoryService componentService,
    required ExperimentService experimentService,
    required ValidationService validationService,
    required ManufacturingService manufacturingService,
  }) {
    return switch (_section) {
      EngineeringSection.dashboard => _buildDashboardSection(snapshot),
      EngineeringSection.projects => _buildProjectsSection(projectService),
      EngineeringSection.circuitLibrary => _buildCircuitLibrarySection(
        circuitService,
      ),
      EngineeringSection.pcbManager => _buildPcbSection(pcbService),
      EngineeringSection.firmwareCentre => _buildFirmwareSection(
        firmwareService,
      ),
      EngineeringSection.deviceFleet => _buildDeviceFleetSection(deviceService),
      EngineeringSection.componentInventory => _buildComponentSection(
        componentService,
      ),
      EngineeringSection.experimentLab => _buildExperimentSection(
        experimentService,
      ),
      EngineeringSection.testValidation => _buildValidationSection(
        validationService,
      ),
      EngineeringSection.manufacturing => _buildManufacturingSection(
        manufacturingService,
      ),
      EngineeringSection.documentation => _buildDocumentationSection(snapshot),
      EngineeringSection.settings => _buildSettingsSection(snapshot),
    };
  }

  Widget _buildDashboardSection(EngineeringSnapshot snapshot) {
    final topProjects = _topProjects(snapshot);
    final searchService = EngineeringSearchService(snapshot);
    final hooks = snapshot.settings;
    final searchHits = searchService.search(_searchQuery, limit: 6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EngineeringSectionShell(
          title: 'Engineering dashboard',
          subtitle:
              'A calm glance at the build system, with the next useful action surfaced first.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1200
                      ? 4
                      : constraints.maxWidth >= 760
                      ? 2
                      : 1;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Projects',
                          value: '${snapshot.projectCount}',
                          subtitle:
                              '${snapshot.activeProjectCount} active, ${snapshot.blockedProjectCount} parked',
                          icon: Icons.folder_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'PCB readiness',
                          value: '${snapshot.fabReadyPcbCount}',
                          subtitle: 'Boards ready for fabrication',
                          icon: Icons.view_in_ar_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Devices online',
                          value: '${snapshot.liveDeviceCount}',
                          subtitle: 'Fleet nodes reporting locally',
                          icon: Icons.devices_other_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Average progress',
                          value:
                              '${snapshot.averageProjectProgress.toStringAsFixed(0)}%',
                          subtitle: 'Across the active engineering portfolio',
                          icon: Icons.monitor_heart_outlined,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000 ? 2 : 1;
                  final width = _cardWidth(constraints.maxWidth, columns);
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: width,
                        child: EngineeringSectionShell(
                          title: 'Top 3 build priorities',
                          subtitle: 'Keep the mission narrow and visible.',
                          child: Column(
                            children: [
                              for (final project in topProjects)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ProjectCard(project: project),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: EngineeringSectionShell(
                          title: 'Integration hooks',
                          subtitle:
                              'Open the local knowledge engine and GAIA assistant without leaving the workspace.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HookActionCard(
                                title: 'Omega Knowledge Engine',
                                subtitle:
                                    'Read-only search, repository scan, and architecture notes.',
                                icon: Icons.travel_explore_outlined,
                                onOpen: () =>
                                    context.push(hooks.knowledgeEngineRoute),
                              ),
                              const SizedBox(height: 12),
                              _HookActionCard(
                                title: 'GAIA assistant',
                                subtitle:
                                    'Future conversational support stays local and easy to swap later.',
                                icon: Icons.auto_awesome_outlined,
                                onOpen: () =>
                                    context.push(hooks.gaiaAssistantRoute),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Last refreshed: ${hooks.lastRefreshedLabel}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (searchHits.isNotEmpty) ...[
                const SizedBox(height: 16),
                EngineeringSectionShell(
                  title: 'Focused matches',
                  subtitle: 'Quick scan results related to the current search.',
                  child: _SearchHitsView(
                    hits: searchHits,
                    onOpenSection: _setSection,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000 ? 2 : 1;
                  final width = _cardWidth(constraints.maxWidth, columns);
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: width,
                        child: EngineeringSectionShell(
                          title: 'Readiness pulse',
                          subtitle:
                              'What is ready, what is blocked, and what needs review.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SummaryLine(
                                label: 'PCB revs ready',
                                value: '${snapshot.fabReadyPcbCount}',
                              ),
                              _SummaryLine(
                                label: 'Firmware builds ready',
                                value: '${snapshot.firmwareReadyCount}',
                              ),
                              _SummaryLine(
                                label: 'Validation passes',
                                value: '${snapshot.validationPassCount}',
                              ),
                              _SummaryLine(
                                label: 'Manufacturing steps ready',
                                value: '${snapshot.manufacturingReadyCount}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: EngineeringSectionShell(
                          title: 'Design note',
                          subtitle:
                              'Keep the engineering surface calm and reusable.',
                          child: Text(
                            'Use the search bar to jump across projects, boards, firmware, devices, experiments, and documentation. '
                            'Keep the first version intentionally small and easy to connect later.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsSection(ProjectService service) {
    final projects = service.projects(
      query: _searchQuery,
      status: _statusFilter,
    );
    return EngineeringSectionShell(
      title: 'Projects',
      subtitle:
          'MicroGrow, BioCalm, New Earth Living, Omega Dashboard, and future engineering workspaces.',
      child: projects.isEmpty
          ? EngineeringEmptyState(
              title: 'No project matches',
              subtitle: 'Try a different search or clear the current filter.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              projects
                  .map(
                    (project) => _ProjectCard(
                      project: project,
                      onOpen: () => _setSection(EngineeringSection.projects),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildCircuitLibrarySection(CircuitLibraryService service) {
    final blocks = service.blocks(query: _searchQuery, status: _statusFilter);
    return EngineeringSectionShell(
      title: 'Circuit Library',
      subtitle:
          'Reusable circuit blocks, system functions, and integration hooks.',
      child: blocks.isEmpty
          ? EngineeringEmptyState(
              title: 'No circuit blocks match',
              subtitle: 'Try a circuit name, category, or functional keyword.',
              actionLabel: 'Reset search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              blocks
                  .map((block) => _CircuitCard(block: block))
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildPcbSection(PCBService service) {
    final pcbRevisions = service.revisions(
      query: _searchQuery,
      status: _statusFilter,
    );
    return EngineeringSectionShell(
      title: 'PCB Manager',
      subtitle:
          'Track revision state, fabrication readiness, and board-level progress.',
      child: pcbRevisions.isEmpty
          ? EngineeringEmptyState(
              title: 'No PCB revisions match',
              subtitle: 'Check the search term or clear the current filter.',
              actionLabel: 'Clear filter',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              pcbRevisions
                  .map((pcb) => _PcbCard(pcb: pcb))
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildFirmwareSection(FirmwareBuildService service) {
    final builds = service.builds(query: _searchQuery, status: _statusFilter);
    return EngineeringSectionShell(
      title: 'Firmware Centre',
      subtitle: 'Builds, versions, artifacts, and the next release action.',
      child: builds.isEmpty
          ? EngineeringEmptyState(
              title: 'No firmware builds match',
              subtitle: 'Try a device name, version, or build type.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              builds.map((build) => _FirmwareCard(buildModel: build)).toList(),
            ),
    );
  }

  Widget _buildDeviceFleetSection(DeviceFleetService service) {
    final devices = service.devices(query: _searchQuery, status: _statusFilter);
    return EngineeringSectionShell(
      title: 'Device Fleet',
      subtitle:
          'Field nodes, bench boards, health labels, and last-seen status.',
      child: devices.isEmpty
          ? EngineeringEmptyState(
              title: 'No device nodes match',
              subtitle: 'Try a device name, model, or location.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              devices.map((device) => _DeviceCard(device: device)).toList(),
            ),
    );
  }

  Widget _buildComponentSection(ComponentInventoryService service) {
    final items = service.components(
      query: _searchQuery,
      status: _statusFilter,
    );
    return EngineeringSectionShell(
      title: 'Component Inventory',
      subtitle:
          'Stock health, reorder pressure, preferred vendors, and storage locations.',
      child: items.isEmpty
          ? EngineeringEmptyState(
              title: 'No components match',
              subtitle: 'Search by SKU, category, or vendor.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              items.map((item) => _ComponentCard(item: item)).toList(),
            ),
    );
  }

  Widget _buildExperimentSection(ExperimentService service) {
    final experiments = service.experiments(
      query: _searchQuery,
      status: _statusFilter,
    );
    return EngineeringSectionShell(
      title: 'Experiment Lab',
      subtitle:
          'Capture hypothesis, evidence, results, and the next intentional test.',
      child: experiments.isEmpty
          ? EngineeringEmptyState(
              title: 'No experiments match',
              subtitle: 'Search by hypothesis, result summary, or tag.',
              actionLabel: 'Reset search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              experiments
                  .map((experiment) => _ExperimentCard(experiment: experiment))
                  .toList(),
            ),
    );
  }

  Widget _buildValidationSection(ValidationService service) {
    final procedures = service.procedures(
      query: _searchQuery,
      status: _statusFilter,
    );
    final results = service.results(query: _searchQuery, status: _statusFilter);
    return Column(
      children: [
        EngineeringSectionShell(
          title: 'Test & Validation',
          subtitle: 'Procedures, checks, verdicts, and calm evidence review.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveCards(
                procedures
                    .map((procedure) => _ProcedureCard(procedure: procedure))
                    .toList(),
              ),
              const SizedBox(height: 16),
              _responsiveCards(
                results
                    .map((result) => _ValidationCard(result: result))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManufacturingSection(ManufacturingService service) {
    final steps = service.steps(query: _searchQuery, status: _statusFilter);
    return EngineeringSectionShell(
      title: 'Manufacturing',
      subtitle: 'Assembly readiness, station flow, and pack-out status.',
      child: steps.isEmpty
          ? EngineeringEmptyState(
              title: 'No manufacturing steps match',
              subtitle: 'Search by stage, owner, or station.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              steps.map((step) => _ManufacturingCard(step: step)).toList(),
            ),
    );
  }

  Widget _buildDocumentationSection(EngineeringSnapshot snapshot) {
    final docs = snapshot.documents
        .where(
          (document) => _matchesLocalQuery(
            document.title,
            document.documentType,
            document.status,
            document.summary,
            document.filePath,
            document.tags,
          ),
        )
        .toList(growable: false);
    final decisions = snapshot.decisions
        .where(
          (decision) => _matchesLocalQuery(
            decision.title,
            decision.decision,
            decision.status,
            decision.rationale,
            decision.nextAction,
            decision.tags,
          ),
        )
        .toList(growable: false);

    return Column(
      children: [
        EngineeringSectionShell(
          title: 'Documentation',
          subtitle:
              'Architecture notes, guides, checklists, decision logs, and release packs.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveCards(
                docs.map((doc) => _DocumentCard(document: doc)).toList(),
              ),
              const SizedBox(height: 16),
              _responsiveCards(
                decisions
                    .map((decision) => _DecisionCard(decision: decision))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(EngineeringSnapshot snapshot) {
    final settings = snapshot.settings;
    return Column(
      children: [
        EngineeringSectionShell(
          title: 'Engineering settings',
          subtitle:
              'Local storage, integration hooks, and the production hardening note.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveCards([
                _InfoTileCard(
                  title: 'Module root',
                  value: settings.moduleRootPath,
                  subtitle: 'Module source folder and manifest location.',
                  icon: Icons.folder_copy_outlined,
                ),
                _InfoTileCard(
                  title: 'Storage path',
                  value: settings.storagePath,
                  subtitle: 'Local JSON state and future persistence home.',
                  icon: Icons.save_outlined,
                ),
                _InfoTileCard(
                  title: 'Knowledge hook',
                  value: settings.knowledgeEngineRoute,
                  subtitle: 'Omega Knowledge Engine route placeholder.',
                  icon: Icons.travel_explore_outlined,
                ),
                _InfoTileCard(
                  title: 'GAIA hook',
                  value: settings.gaiaAssistantRoute,
                  subtitle: 'Assistant route placeholder for future wiring.',
                  icon: Icons.auto_awesome_outlined,
                ),
              ]),
              const SizedBox(height: 16),
              Text(
                'Production hardening TODO',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const _BulletLine('Move the mock snapshot into Drift tables.'),
              const _BulletLine('Add export and import for offline backups.'),
              const _BulletLine(
                'Persist edit flows for projects, boards, and devices.',
              ),
              const _BulletLine(
                'Add screenshot and golden tests for the finished UI.',
              ),
              const _BulletLine(
                'Keep the integration hooks stable while the backend grows.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<EngineeringProject> _topProjects(EngineeringSnapshot snapshot) {
    final projects = snapshot.projects.toList(growable: false);
    projects.sort((left, right) {
      final priorityLeft = _priorityRank(left.priority);
      final priorityRight = _priorityRank(right.priority);
      if (priorityLeft != priorityRight) {
        return priorityLeft.compareTo(priorityRight);
      }
      return right.progressPercent.compareTo(left.progressPercent);
    });
    return projects.take(3).toList(growable: false);
  }

  int _priorityRank(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 0;
      case 'medium':
        return 1;
      case 'low':
        return 2;
      default:
        return 3;
    }
  }

  bool _matchesLocalQuery(
    String title,
    String a,
    String b,
    String c,
    String d,
    List<String> tags,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    final values = [title, a, b, c, d, ...tags];
    return values.any((value) => value.toLowerCase().contains(query));
  }

  double _cardWidth(double maxWidth, int columns) {
    if (columns <= 1) {
      return maxWidth;
    }
    return (maxWidth - ((columns - 1) * 14)) / columns;
  }

  Widget _responsiveCards(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 2
            : constraints.maxWidth >= 900
            ? 2
            : 1;
        final width = _cardWidth(constraints.maxWidth, columns);
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.snapshot,
    required this.searchController,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onClearSearch,
    required this.onOpenKnowledgeEngine,
    required this.onOpenGaiaAssistant,
  });

  final EngineeringSnapshot snapshot;
  final TextEditingController searchController;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenKnowledgeEngine;
  final VoidCallback onOpenGaiaAssistant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: engineeringPanelDecoration(context),
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
                    Text(
                      'Omega Engineering Studio',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(today, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Build the next useful thing, keep the system calm, and surface only the work that matters most today.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  EngineeringStatusChip(label: 'Offline-first'),
                  const SizedBox(height: 8),
                  EngineeringStatusChip(
                    label: snapshot.settings.lastRefreshedLabel,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final children = [
                TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    labelText: 'Search engineering workspaces',
                    hintText:
                        'Projects, circuits, boards, firmware, devices, docs...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: onClearSearch,
                            icon: const Icon(Icons.clear),
                          ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('engineeringStatusFilter'),
                  initialValue: statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Status filter',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Ready', child: Text('Ready')),
                    DropdownMenuItem(value: 'Blocked', child: Text('Blocked')),
                    DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onStatusFilterChanged(value);
                    }
                  },
                ),
              ];
              if (narrow) {
                return Column(children: children);
              }
              return Row(
                children: [
                  Expanded(flex: 4, child: children[0]),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: children[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onOpenKnowledgeEngine,
                icon: const Icon(Icons.travel_explore_outlined),
                label: const Text('Open Knowledge Engine'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenGaiaAssistant,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Open GAIA'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionSelector extends StatelessWidget {
  const _SectionSelector({
    required this.currentSection,
    required this.onSelected,
  });

  final EngineeringSection currentSection;
  final ValueChanged<EngineeringSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final section in EngineeringSection.values)
          FilterChip(
            label: Text(section.label),
            selected: section == currentSection,
            onSelected: (_) => onSelected(section),
          ),
      ],
    );
  }
}

class _SearchHitsView extends StatelessWidget {
  const _SearchHitsView({required this.hits, required this.onOpenSection});

  final List<EngineeringSearchHit> hits;
  final ValueChanged<EngineeringSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final hit in hits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onOpenSection(hit.section),
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hit.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(hit.subtitle),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        EngineeringStatusChip(label: hit.kind),
                        const SizedBox(height: 4),
                        Text(hit.section.label),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, this.onOpen});

  final EngineeringProject project;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                EngineeringStatusChip(label: project.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(project.summary),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: project.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${project.progressPercent}% complete'),
            const SizedBox(height: 8),
            Text('Milestone: ${project.milestone}'),
            const SizedBox(height: 4),
            Text('Next action: ${project.nextAction}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EngineeringStatusChip(label: project.priority),
                EngineeringStatusChip(label: project.system),
                EngineeringStatusChip(label: '${project.openTaskCount} open'),
              ],
            ),
            if (project.targetDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Target: ${project.targetDate!.toLocal().toIso8601String().split('T').first}',
              ),
            ],
            if (onOpen != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_outlined),
                label: const Text('Open'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CircuitCard extends StatelessWidget {
  const _CircuitCard({required this.block});

  final CircuitBlock block;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    block.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: block.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(block.function),
            const SizedBox(height: 8),
            Text('Next action: ${block.nextAction}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: block.progressPercent / 100),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EngineeringStatusChip(label: block.category),
                for (final tag in block.tags.take(2))
                  EngineeringStatusChip(label: tag),
              ],
            ),
            if (block.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(block.notes, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _PcbCard extends StatelessWidget {
  const _PcbCard({required this.pcb});

  final PCBRevision pcb;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${pcb.boardName} ${pcb.revision}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: pcb.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Layers: ${pcb.layers}'),
            const SizedBox(height: 4),
            Text('Manufacturing partner: ${pcb.manufacturingPartner}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: pcb.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${pcb.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Next action: ${pcb.nextAction}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EngineeringStatusChip(
                  label: pcb.fabReady ? 'Fab ready' : 'Not ready',
                ),
                for (final tag in pcb.tags.take(2))
                  EngineeringStatusChip(label: tag),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FirmwareCard extends StatelessWidget {
  const _FirmwareCard({required this.buildModel});

  final FirmwareBuild buildModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${buildModel.targetDevice} ${buildModel.version}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: buildModel.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Build type: ${buildModel.buildType}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: buildModel.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${buildModel.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Next action: ${buildModel.nextAction}'),
            const SizedBox(height: 4),
            Text(
              'Artifact: ${buildModel.artifactPath}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device});

  final DeviceNode device;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: device.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('${device.model} · ${device.location}'),
            const SizedBox(height: 4),
            Text('Health: ${device.health}'),
            const SizedBox(height: 4),
            Text('Firmware: ${device.firmwareVersion}'),
            const SizedBox(height: 8),
            Text('Next action: ${device.nextAction}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in device.tags.take(3))
                  EngineeringStatusChip(label: tag),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.item});

  final ComponentItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: item.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(item.sku),
            const SizedBox(height: 4),
            Text('Category: ${item.category}'),
            const SizedBox(height: 4),
            Text(
              'Stock: ${item.quantityOnHand} / reorder ${item.reorderLevel}',
            ),
            const SizedBox(height: 8),
            Text('Vendor: ${item.preferredVendor}'),
            const SizedBox(height: 4),
            Text('Next action: ${item.nextAction}'),
            const SizedBox(height: 8),
            EngineeringStatusChip(
              label: item.isLowStock ? 'Needs attention' : 'In stock',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({required this.experiment});

  final ExperimentRecord experiment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    experiment.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: experiment.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(experiment.hypothesis),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: experiment.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${experiment.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Evidence items: ${experiment.evidenceCount}'),
            const SizedBox(height: 4),
            Text('Result: ${experiment.resultSummary}'),
            const SizedBox(height: 4),
            Text('Next action: ${experiment.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  const _ProcedureCard({required this.procedure});

  final TestProcedure procedure;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    procedure.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: procedure.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Stage: ${procedure.stage}'),
            const SizedBox(height: 4),
            Text('Owner: ${procedure.owner}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: procedure.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${procedure.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Next action: ${procedure.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.result});

  final ValidationResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: result.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Verdict: ${result.verdict}'),
            const SizedBox(height: 4),
            Text('Severity: ${result.severity}'),
            const SizedBox(height: 4),
            Text('Evidence items: ${result.evidenceCount}'),
            const SizedBox(height: 4),
            Text('Summary: ${result.summary}'),
            const SizedBox(height: 4),
            Text('Next action: ${result.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _ManufacturingCard extends StatelessWidget {
  const _ManufacturingCard({required this.step});

  final ManufacturingStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: step.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Stage: ${step.stage}'),
            const SizedBox(height: 4),
            Text('Owner: ${step.owner}'),
            const SizedBox(height: 4),
            Text('Station: ${step.station}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: step.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${step.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Due: ${step.dueLabel}'),
            const SizedBox(height: 4),
            Text('Next action: ${step.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final EngineeringDocument document;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    document.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: document.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(document.documentType),
            const SizedBox(height: 4),
            Text(document.summary),
            const SizedBox(height: 4),
            Text(
              document.filePath,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision});

  final EngineeringDecision decision;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    decision.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: decision.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(decision.decision),
            const SizedBox(height: 4),
            Text('Confidence: ${decision.confidence}'),
            const SizedBox(height: 4),
            Text('Rationale: ${decision.rationale}'),
            const SizedBox(height: 4),
            Text('Next action: ${decision.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _HookActionCard extends StatelessWidget {
  const _HookActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.32,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTileCard extends StatelessWidget {
  const _InfoTileCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.30,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
