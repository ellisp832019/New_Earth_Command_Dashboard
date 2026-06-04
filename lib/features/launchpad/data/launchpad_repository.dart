import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'launchpad_phase2_models.dart';
import 'launchpad_models.dart';

class LaunchpadRepository {
  LaunchpadRepository({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current;

  static const _runtimeStateRelativePath =
      'modules/new_earth_launchpad_module/dashboard_module/data/runtime/launchpad_state.json';
  static const _seedCampaignsRootRelativePath =
      'modules/new_earth_launchpad_module/dashboard_module/data/campaigns';
  static const _exportsRelativePath =
      'modules/new_earth_launchpad_module/dashboard_module/exports';

  final Directory _workingDirectory;
  final Uuid _uuid = const Uuid();

  Future<LaunchpadWorkspace> loadWorkspace() async {
    final runtimeFile = File(
      path.join(_workingDirectory.path, _runtimeStateRelativePath),
    );
    final seedRoot = Directory(
      path.join(_workingDirectory.path, _seedCampaignsRootRelativePath),
    );
    final exportRoot = Directory(
      path.join(_workingDirectory.path, _exportsRelativePath),
    );
    final issues = <String>[];

    if (!await exportRoot.exists()) {
      await exportRoot.create(recursive: true);
    }

    if (await runtimeFile.exists()) {
      try {
        final decoded = jsonDecode(await runtimeFile.readAsString());
        if (decoded is Map<String, dynamic>) {
          final campaigns = _campaignsFromWorkspaceJson(decoded);
          final seedCampaigns = await _loadSeedCampaigns(seedRoot, issues);
          final mergedCampaigns = campaigns.map((campaign) {
            final seedCampaign = seedCampaigns.firstWhere(
              (seed) => seed.id == campaign.id,
              orElse: () => campaign,
            );
            return _mergeSeedPhase2Data(campaign, seedCampaign);
          }).toList(growable: false);
          return LaunchpadWorkspace(
            configPath: runtimeFile.path,
            runtimePath: runtimeFile.path,
            seedRootPath: seedRoot.path,
            exportRootPath: exportRoot.path,
            campaigns: mergedCampaigns.isNotEmpty
                ? mergedCampaigns
                : seedCampaigns,
            issues: issues,
            updatedAt: _parseDate(decoded['updated_at']),
          );
        }
        issues.add('Launchpad state should contain a JSON object.');
      } on FormatException {
        issues.add('Launchpad state file could not be read as JSON.');
      } on FileSystemException {
        issues.add('Launchpad state file could not be opened.');
      }
    }

    final seedCampaigns = await _loadSeedCampaigns(seedRoot, issues);
    final workspace = LaunchpadWorkspace(
      configPath: runtimeFile.path,
      runtimePath: runtimeFile.path,
      seedRootPath: seedRoot.path,
      exportRootPath: exportRoot.path,
      campaigns: seedCampaigns,
      issues: issues,
      updatedAt: DateTime.now(),
    );
    await saveWorkspace(workspace);
    return workspace;
  }

  Future<LaunchpadWorkspace> saveWorkspace(LaunchpadWorkspace workspace) async {
    final runtimeFile = File(workspace.runtimePath);
    await runtimeFile.parent.create(recursive: true);

    final payload = workspace
        .copyWith(updatedAt: DateTime.now(), issues: workspace.issues)
        .toPrettyJson();
    await _writeTextFileWithBackup(runtimeFile, payload);

    return workspace.copyWith(updatedAt: DateTime.now());
  }

  Future<LaunchpadCampaignRecord> upsertCampaign(
    LaunchpadCampaignRecord campaign,
  ) async {
    final workspace = await loadWorkspace();
    final updatedCampaigns = <LaunchpadCampaignRecord>[];
    var replaced = false;

    for (final existing in workspace.campaigns) {
      if (existing.id == campaign.id) {
        updatedCampaigns.add(campaign.copyWith(updatedAt: DateTime.now()));
        replaced = true;
      } else {
        updatedCampaigns.add(existing);
      }
    }

    if (!replaced) {
      updatedCampaigns.add(campaign.copyWith(updatedAt: DateTime.now()));
    }

    await saveWorkspace(workspace.copyWith(campaigns: updatedCampaigns));
    return campaign.copyWith(updatedAt: DateTime.now());
  }

  Future<void> deleteCampaign(String campaignId) async {
    final workspace = await loadWorkspace();
    final updatedCampaigns = workspace.campaigns
        .where((campaign) => campaign.id != campaignId)
        .toList(growable: false);
    await saveWorkspace(workspace.copyWith(campaigns: updatedCampaigns));
  }

  Future<LaunchpadCampaignRecord> saveStoryBlocks(
    String campaignId,
    List<LaunchpadStoryBlock> blocks,
  ) async {
    return _updateCampaign(
      campaignId,
      (campaign) => campaign.copyWith(storyBlocks: _sortedStoryBlocks(blocks)),
    );
  }

  Future<LaunchpadCampaignRecord> saveRewards(
    String campaignId,
    List<LaunchpadRewardTier> rewards,
  ) async {
    return _updateCampaign(
      campaignId,
      (campaign) => campaign.copyWith(rewards: rewards),
    );
  }

  Future<LaunchpadCampaignRecord> saveReadinessItems(
    String campaignId,
    List<LaunchpadReadinessItem> items,
  ) async {
    return _updateCampaign(
      campaignId,
      (campaign) => campaign.copyWith(readinessItems: items),
    );
  }

  Future<LaunchpadCampaignRecord> saveRisks(
    String campaignId,
    List<LaunchpadRiskRecord> risks,
  ) async {
    return _updateCampaign(
      campaignId,
      (campaign) => campaign.copyWith(risks: risks),
    );
  }

  Future<LaunchpadCampaignRecord> savePhase2Records(
    String campaignId,
    List<LaunchpadPhase2Record> records,
  ) async {
    return _updateCampaign(
      campaignId,
      (campaign) => campaign.copyWith(phase2Records: records),
    );
  }

  Future<LaunchpadCampaignRecord> saveFinanceModel(
    String campaignId,
    LaunchpadCampaignFinanceModel finance,
  ) async {
    return _updateCampaign(
      campaignId,
      (campaign) => campaign.copyWith(
        finance: finance,
        fundingGoalGbp: finance.fundingGoalGbp,
      ),
    );
  }

  Future<LaunchpadCampaignRecord> updateCampaign(
    LaunchpadCampaignRecord campaign,
  ) async {
    return upsertCampaign(campaign);
  }

  Future<LaunchpadCampaignRecord> createCampaign({
    required String name,
    required String project,
    required String owner,
    required String summary,
    required double fundingGoalGbp,
    String type = 'kickstarter',
  }) async {
    final now = DateTime.now();
    final campaign = LaunchpadCampaignRecord(
      id: _uuid.v4(),
      name: name,
      project: project,
      type: type,
      status: LaunchpadCampaignStatus.idea,
      fundingGoalGbp: fundingGoalGbp,
      launchDate: null,
      owner: owner,
      summary: summary,
      createdAt: now,
      updatedAt: now,
      progressPercentage: 0,
      rewards: const <LaunchpadRewardTier>[],
      storyBlocks: _defaultStoryBlocks(name, project, ''),
      readinessItems: _defaultReadinessItems(),
      risks: _defaultRiskItems(project),
      phase2Records: const <LaunchpadPhase2Record>[],
      finance: LaunchpadCampaignFinanceModel(
        fundingGoalGbp: fundingGoalGbp,
        manufacturingCostsGbp: 0,
        shippingGbp: 0,
        vatPercent: 0,
        kickstarterFeePercent: 5,
        paymentFeePercent: 3,
        contingencyPercent: 10,
        fixedCostsGbp: 0,
      ),
    );
    await upsertCampaign(campaign);
    return campaign;
  }

  Future<String> exportStoryMarkdown(String campaignId) async {
    final workspace = await loadWorkspace();
    final campaign = workspace.campaignById(campaignId);
    if (campaign == null) {
      throw StateError('Campaign not found: $campaignId');
    }

    final exportFile = File(
      path.join(
        workspace.exportRootPath,
        '${_safeFileName(campaignId)}_story.md',
      ),
    );
    await exportFile.parent.create(recursive: true);
    await _writeTextFileWithBackup(exportFile, buildCampaignStoryMarkdown(campaign));
    return exportFile.path;
  }

  String buildCampaignStoryMarkdown(LaunchpadCampaignRecord campaign) {
    final blocks = [...campaign.storyBlocks]
      ..sort((a, b) => a.order.compareTo(b.order));
    final buffer = StringBuffer()
      ..writeln('# ${campaign.name}')
      ..writeln()
      ..writeln('## Campaign Summary')
      ..writeln(campaign.summary)
      ..writeln();

    for (final block in blocks) {
      buffer
        ..writeln('## ${block.section}')
        ..writeln()
        ..writeln('### ${block.title}')
        ..writeln()
        ..writeln(block.body.trim())
        ..writeln();
    }

    return buffer.toString().trimRight();
  }

  Future<LaunchpadCampaignRecord> archiveCampaign(String campaignId) async {
    return _updateCampaign(
      campaignId,
      (campaign) => campaign.copyWith(status: LaunchpadCampaignStatus.archived),
    );
  }

  Future<LaunchpadCampaignRecord> restoreCampaign(String campaignId) async {
    return _updateCampaign(
      campaignId,
      (campaign) => campaign.copyWith(status: LaunchpadCampaignStatus.prototype),
    );
  }

  Future<LaunchpadCampaignRecord> _updateCampaign(
    String campaignId,
    LaunchpadCampaignRecord Function(LaunchpadCampaignRecord campaign)
    updater,
  ) async {
    final workspace = await loadWorkspace();
    final updatedCampaigns = workspace.campaigns.map((campaign) {
      if (campaign.id != campaignId) {
        return campaign;
      }

      return updater(campaign).copyWith(updatedAt: DateTime.now());
    }).toList(growable: false);

    final updatedCampaign = updatedCampaigns.firstWhere(
      (campaign) => campaign.id == campaignId,
      orElse: () => throw StateError('Campaign not found: $campaignId'),
    );

    await saveWorkspace(workspace.copyWith(campaigns: updatedCampaigns));
    return updatedCampaign;
  }

  Future<List<LaunchpadCampaignRecord>> _loadSeedCampaigns(
    Directory seedRoot,
    List<String> issues,
  ) async {
    if (!await seedRoot.exists()) {
      issues.add(
        'Launchpad seed folder was not found at ${seedRoot.path}.',
      );
      return <LaunchpadCampaignRecord>[
        _defaultCampaign(),
      ];
    }

    final campaigns = <LaunchpadCampaignRecord>[];
    final campaignFolders = await seedRoot
        .list()
        .where((entity) => entity is Directory)
        .cast<Directory>()
        .toList();

    if (campaignFolders.isEmpty) {
      issues.add('Launchpad seed folder does not contain any campaign seeds.');
      return <LaunchpadCampaignRecord>[_defaultCampaign()];
    }

    for (final campaignFolder in campaignFolders) {
      final campaignFile = File(path.join(campaignFolder.path, 'campaign.json'));
      if (!await campaignFile.exists()) {
        continue;
      }

      try {
        final decoded = jsonDecode(await campaignFile.readAsString());
        if (decoded is! Map<String, dynamic>) {
          continue;
        }

        final campaign = LaunchpadCampaignRecord.fromJson(decoded);
        final rewardsFile = File(path.join(campaignFolder.path, 'rewards.json'));
        final readinessFile = File(path.join(campaignFolder.path, 'readiness.csv'));
        final phase2File = File(path.join(campaignFolder.path, 'phase2.json'));
        campaigns.add(
          campaign.copyWith(
            rewards: await _loadRewardSeed(rewardsFile, campaign.id),
            readinessItems: await _loadReadinessSeed(readinessFile, campaign.id),
            phase2Records: await _loadPhase2Seed(phase2File, campaign.id),
            storyBlocks: _defaultStoryBlocks(
              campaign.name,
              campaign.project,
              campaign.summary,
            ),
            risks: _defaultRiskItems(campaign.project),
            finance: _defaultFinanceFromCampaign(campaign),
          ),
        );
      } on FormatException {
        issues.add('Seed campaign data could not be parsed for ${campaignFolder.path}.');
      } on FileSystemException {
        issues.add('Seed campaign data could not be opened for ${campaignFolder.path}.');
      }
    }

    if (campaigns.isEmpty) {
      campaigns.add(_defaultCampaign());
    }

    return campaigns;
  }

  Future<List<LaunchpadRewardTier>> _loadRewardSeed(
    File file,
    String campaignId,
  ) async {
    if (!await file.exists()) {
      return const <LaunchpadRewardTier>[];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return const <LaunchpadRewardTier>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (entry) => LaunchpadRewardTier.fromJson(
              entry.cast<String, dynamic>(),
              campaignIdFallback: campaignId,
            ),
          )
          .toList(growable: false);
    } on FormatException {
      return const <LaunchpadRewardTier>[];
    }
  }

  Future<List<LaunchpadReadinessItem>> _loadReadinessSeed(
    File file,
    String campaignId,
  ) async {
    if (!await file.exists()) {
      return _defaultReadinessItems();
    }

    try {
      final lines = await file.readAsLines();
      if (lines.length <= 1) {
        return _defaultReadinessItems();
      }

      final rows = <LaunchpadReadinessItem>[];
      for (final line in lines.skip(1)) {
        if (line.trim().isEmpty) {
          continue;
        }
        final cells = _parseCsvLine(line);
        if (cells.length < 4) {
          continue;
        }
        rows.add(
          LaunchpadReadinessItem(
            id: _safeFileName('${cells[0]}-${cells[1]}'),
            campaignId: campaignId,
            category: cells[0].trim(),
            title: cells[1].trim(),
            status: cells[2].trim().isEmpty ? 'Todo' : cells[2].trim(),
            proofLink: '',
            notes: cells[3].trim(),
          ),
        );
      }
      return rows.isEmpty ? _defaultReadinessItems() : rows;
    } on FileSystemException {
      return _defaultReadinessItems();
    }
  }

  List<LaunchpadCampaignRecord> _campaignsFromWorkspaceJson(
    Map<String, dynamic> json,
  ) {
    final rawCampaigns = json['campaigns'];
    if (rawCampaigns is! List) {
      return <LaunchpadCampaignRecord>[];
    }

    return rawCampaigns
        .whereType<Map>()
        .map((item) => LaunchpadCampaignRecord.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  LaunchpadCampaignRecord _mergeSeedPhase2Data(
    LaunchpadCampaignRecord runtimeCampaign,
    LaunchpadCampaignRecord seedCampaign,
  ) {
    if (runtimeCampaign.phase2Records.isNotEmpty ||
        seedCampaign.phase2Records.isEmpty) {
      return runtimeCampaign;
    }

    return runtimeCampaign.copyWith(phase2Records: seedCampaign.phase2Records);
  }

  LaunchpadCampaignRecord _defaultCampaign() {
    final now = DateTime.now();
    return LaunchpadCampaignRecord(
      id: 'MICROGROW_KICKSTARTER_2026',
      name: 'MicroGrow Kickstarter 2026',
      project: 'MicroGrow',
      type: 'kickstarter',
      status: LaunchpadCampaignStatus.prototype,
      fundingGoalGbp: 35000,
      launchDate: null,
      owner: 'Peter Ellis',
      summary:
          'Local-first grow automation ecosystem using ESP32 nodes, sensors, relay control, a hub architecture, and Flutter app.',
      createdAt: now,
      updatedAt: now,
      progressPercentage: 28,
      rewards: _defaultRewardSeed(),
      storyBlocks: _defaultStoryBlocks(
        'MicroGrow Kickstarter 2026',
        'MicroGrow',
        'Local-first grow automation ecosystem using ESP32 nodes, sensors, relay control, a hub architecture, and Flutter app.',
      ),
      readinessItems: _defaultReadinessItems(),
      risks: _defaultRiskItems('MicroGrow'),
      phase2Records: _defaultPhase2Records(),
      finance: _defaultFinanceFromCampaign(
        LaunchpadCampaignRecord(
          id: 'MICROGROW_KICKSTARTER_2026',
          name: 'MicroGrow Kickstarter 2026',
          project: 'MicroGrow',
          type: 'kickstarter',
          status: LaunchpadCampaignStatus.prototype,
          fundingGoalGbp: 35000,
          launchDate: null,
          owner: 'Peter Ellis',
          summary:
              'Local-first grow automation ecosystem using ESP32 nodes, sensors, relay control, a hub architecture, and Flutter app.',
          createdAt: now,
          updatedAt: now,
          progressPercentage: 28,
          rewards: _defaultRewardSeed(),
          storyBlocks: const <LaunchpadStoryBlock>[],
          readinessItems: const <LaunchpadReadinessItem>[],
          risks: const <LaunchpadRiskRecord>[],
          phase2Records: const <LaunchpadPhase2Record>[],
          finance: const LaunchpadCampaignFinanceModel(
            fundingGoalGbp: 35000,
            manufacturingCostsGbp: 15000,
            shippingGbp: 7000,
            vatPercent: 20,
            kickstarterFeePercent: 5,
            paymentFeePercent: 3,
            contingencyPercent: 12,
            fixedCostsGbp: 0,
          ),
        ),
      ),
    );
  }

  LaunchpadCampaignFinanceModel _defaultFinanceFromCampaign(
    LaunchpadCampaignRecord campaign,
  ) {
    return LaunchpadCampaignFinanceModel(
      fundingGoalGbp: campaign.fundingGoalGbp,
      manufacturingCostsGbp: 15000,
      shippingGbp: 7000,
      vatPercent: 20,
      kickstarterFeePercent: 5,
      paymentFeePercent: 3,
      contingencyPercent: 12,
      fixedCostsGbp: 0,
    );
  }

  Future<List<LaunchpadPhase2Record>> _loadPhase2Seed(
    File file,
    String campaignId,
  ) async {
    if (!await file.exists()) {
      return _defaultPhase2Records();
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return _defaultPhase2Records();
      }

      final records = decoded
          .whereType<Map>()
          .map(
            (entry) => LaunchpadPhase2Record.fromJson(
              entry.cast<String, dynamic>(),
              campaignIdFallback: campaignId,
              sectionFallback: '',
            ),
          )
          .toList(growable: false);
      return records.isEmpty ? _defaultPhase2Records() : records;
    } on FormatException {
      return _defaultPhase2Records();
    } on FileSystemException {
      return _defaultPhase2Records();
    }
  }

  List<LaunchpadRewardTier> _defaultRewardSeed() {
    return <LaunchpadRewardTier>[
      const LaunchpadRewardTier(
        id: 'SUPPORTER_10',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        name: 'Supporter',
        priceGbp: 10,
        quantityLimit: null,
        estimatedCogsGbp: 0,
        estimatedShippingGbp: 0,
        deliveryEstimate: 'Digital',
        notes: 'Digital thank you and campaign updates.',
      ),
      const LaunchpadRewardTier(
        id: 'FOUNDER_25',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        name: 'Founding Supporter',
        priceGbp: 25,
        quantityLimit: 500,
        estimatedCogsGbp: 2,
        estimatedShippingGbp: 0,
        deliveryEstimate: 'Campaign period',
        notes: 'Name on founder wall / website.',
      ),
      const LaunchpadRewardTier(
        id: 'COMMUNITY_50',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        name: 'Early Community Access',
        priceGbp: 50,
        quantityLimit: 300,
        estimatedCogsGbp: 5,
        estimatedShippingGbp: 0,
        deliveryEstimate: 'During campaign',
        notes:
            'Private build updates, voting on grow profiles, early docs.',
      ),
      const LaunchpadRewardTier(
        id: 'DEV_KIT_149',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        name: 'MicroGrow Developer Kit',
        priceGbp: 149,
        quantityLimit: 100,
        estimatedCogsGbp: 65,
        estimatedShippingGbp: 8,
        deliveryEstimate: '8-10 weeks after campaign',
        notes:
            'ESP32 dev kit, sensor bundle, low-voltage relay board, docs.',
      ),
      const LaunchpadRewardTier(
        id: 'STARTER_299',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        name: 'MicroGrow Starter Kit',
        priceGbp: 299,
        quantityLimit: 75,
        estimatedCogsGbp: 145,
        estimatedShippingGbp: 15,
        deliveryEstimate: '10-14 weeks after campaign',
        notes:
            'Pre-assembled starter prototype kit subject to final scope.',
      ),
      const LaunchpadRewardTier(
        id: 'PARTNER_499',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        name: 'Founding Partner Edition',
        priceGbp: 499,
        quantityLimit: 25,
        estimatedCogsGbp: 220,
        estimatedShippingGbp: 20,
        deliveryEstimate: 'Priority delivery',
        notes:
            'Limited founding edition, deeper onboarding and recognition.',
      ),
    ];
  }

  List<LaunchpadStoryBlock> _defaultStoryBlocks(
    String campaignName,
    String project,
    String summary,
  ) {
    final intro = summary.isNotEmpty
        ? summary
        : '$campaignName is the next calm step for $project.';

    return <LaunchpadStoryBlock>[
      LaunchpadStoryBlock(
        id: 'vision',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'Vision',
        title: 'What we are building',
        body: intro,
        order: 0,
      ),
      const LaunchpadStoryBlock(
        id: 'problem',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'Problem',
        title: 'Why this matters',
        body:
            'Growing food consistently is still fragile, time-consuming, and hard to monitor without the right low-cost tools.',
        order: 1,
      ),
      const LaunchpadStoryBlock(
        id: 'solution',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'Solution',
        title: 'How MicroGrow helps',
        body:
            'A local-first system with ESP32 nodes, sensors, relay control, and a Flutter dashboard keeps the loop simple and visible.',
        order: 2,
      ),
      const LaunchpadStoryBlock(
        id: 'founder_story',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'Founder Story',
        title: 'Why Peter is building this',
        body:
            'MicroGrow reflects a calm, mission-driven approach to rebuilding resilience through practical tools that people can actually use.',
        order: 3,
      ),
      const LaunchpadStoryBlock(
        id: 'prototype',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'Prototype',
        title: 'What already exists',
        body:
            'The current prototype includes live sensor data, relay control, and a working dashboard foundation.',
        order: 4,
      ),
      const LaunchpadStoryBlock(
        id: 'roadmap',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'Roadmap',
        title: 'What comes next',
        body:
            'Funding supports PCB refinement, packaging, media, manufacturing preparation, and a careful launch plan.',
        order: 5,
      ),
      const LaunchpadStoryBlock(
        id: 'risks',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'Risks',
        title: 'Risks to be honest about',
        body:
            'Delivery timing, certification, and fulfilment cost need to stay visible so the campaign stays realistic.',
        order: 6,
      ),
      const LaunchpadStoryBlock(
        id: 'rewards',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'Rewards',
        title: 'Why supporters can back it',
        body:
            'Reward tiers are designed to start simple, keep margins visible, and avoid overpromising on physical fulfilment.',
        order: 7,
      ),
    ];
  }

  List<LaunchpadReadinessItem> _defaultReadinessItems() {
    return <LaunchpadReadinessItem>[
      const LaunchpadReadinessItem(
        id: 'hardware-node',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Hardware',
        title: 'One ESP32 node demo',
        status: 'In Progress',
        proofLink: '',
        notes: 'Frankenstein prototype box',
      ),
      const LaunchpadReadinessItem(
        id: 'hardware-sensors',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Hardware',
        title: 'Sensors integrated',
        status: 'In Progress',
        proofLink: '',
        notes: 'Temperature and humidity first',
      ),
      const LaunchpadReadinessItem(
        id: 'hardware-relay',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Hardware',
        title: 'Relay control demo',
        status: 'In Progress',
        proofLink: '',
        notes: 'Low-voltage demo only',
      ),
      const LaunchpadReadinessItem(
        id: 'firmware-data',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Firmware',
        title: 'Live /data endpoint',
        status: 'Done',
        proofLink: '',
        notes: 'Current firmware foundation',
      ),
      const LaunchpadReadinessItem(
        id: 'firmware-relay',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Firmware',
        title: 'POST /relay control',
        status: 'Done',
        proofLink: '',
        notes: 'Current firmware foundation',
      ),
      const LaunchpadReadinessItem(
        id: 'software-dashboard',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Software',
        title: 'Flutter dashboard reads node',
        status: 'Done',
        proofLink: '',
        notes: 'Existing app foundation',
      ),
      const LaunchpadReadinessItem(
        id: 'software-manual-control',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Software',
        title: 'Manual relay control',
        status: 'Done',
        proofLink: '',
        notes: 'Existing app foundation',
      ),
      const LaunchpadReadinessItem(
        id: 'software-grow-profile',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Software',
        title: 'One working grow profile',
        status: 'Todo',
        proofLink: '',
        notes: 'Seedling/herbs demo',
      ),
      const LaunchpadReadinessItem(
        id: 'manufacturing-pcb',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Manufacturing',
        title: 'PCB V0.1 plan',
        status: 'Draft',
        proofLink: '',
        notes: 'Low-voltage dev-board carrier',
      ),
      const LaunchpadReadinessItem(
        id: 'manufacturing-samples',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Manufacturing',
        title: 'Prototype production route',
        status: 'Draft',
        proofLink: '',
        notes: 'Keep the first hardware run tiny',
      ),
      const LaunchpadReadinessItem(
        id: 'documentation-risk',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Documentation',
        title: 'Risk disclosure drafted',
        status: 'Todo',
        proofLink: '',
        notes: 'Especially delivery and certification',
      ),
      const LaunchpadReadinessItem(
        id: 'documentation-launch',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Documentation',
        title: 'Launch checklist created',
        status: 'Todo',
        proofLink: '',
        notes: 'Keep the campaign operating manual calm',
      ),
      const LaunchpadReadinessItem(
        id: 'marketing-video',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Marketing',
        title: '3-5 minute demo video',
        status: 'Todo',
        proofLink: '',
        notes: 'Kickstarter proof asset',
      ),
      const LaunchpadReadinessItem(
        id: 'marketing-graphics',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        category: 'Marketing',
        title: 'Campaign graphics pack',
        status: 'Todo',
        proofLink: '',
        notes: 'Hero images, diagrams, and reward visuals',
      ),
    ];
  }

  List<LaunchpadRiskRecord> _defaultRiskItems(String project) {
    return <LaunchpadRiskRecord>[
      LaunchpadRiskRecord(
        id: 'certification-delay',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        title: 'Certification preparation may take longer than expected',
        severity: 'Medium',
        likelihood: 'Medium',
        mitigation:
            'Keep V1 low-voltage and avoid mains switching inside the product.',
        publicNote: '$project will launch with a careful, low-risk scope.',
      ),
      LaunchpadRiskRecord(
        id: 'fulfilment-costs',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        title: 'Shipping and fulfilment can damage margins',
        severity: 'High',
        likelihood: 'Medium',
        mitigation:
            'Keep physical rewards limited and check shipping assumptions early.',
        publicNote: 'Reward delivery costs are tracked in the finance model.',
      ),
      LaunchpadRiskRecord(
        id: 'scope-creep',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        title: 'The campaign could promise too much too soon',
        severity: 'High',
        likelihood: 'Medium',
        mitigation:
            'Separate working prototype proof from future vision clearly in the story.',
        publicNote: 'The launch plan keeps future ideas parked, not promised.',
      ),
    ];
  }

  List<LaunchpadPhase2Record> _defaultPhase2Records() {
    return <LaunchpadPhase2Record>[
      const LaunchpadPhase2Record(
        id: 'media-hero-image',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'media-studio',
        title: 'Hero image set',
        status: 'Draft',
        primaryLabel: 'Asset type',
        primaryValue: 'Graphic',
        secondaryLabel: 'Path',
        secondaryValue: 'Omega OS export pending',
        notes: 'Hero image, product shot, and banner crop set.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'media-demo-video',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'media-studio',
        title: 'Demo video outline',
        status: 'In Progress',
        primaryLabel: 'Asset type',
        primaryValue: 'Video',
        secondaryLabel: 'Length',
        secondaryValue: '3-5 minutes',
        notes: 'Show the node, app, and relay loop calmly.',
        order: 1,
      ),
      const LaunchpadPhase2Record(
        id: 'grant-shortlist',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'grant-centre',
        title: 'Grant shortlist',
        status: 'Research',
        primaryLabel: 'Funder',
        primaryValue: 'Innovation grants',
        secondaryLabel: 'Deadline',
        secondaryValue: 'Rolling',
        notes: 'Keep a shortlist of suitable local and mission-led grants.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'investor-intros',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'investor-crm',
        title: 'Warm investor intros',
        status: 'Draft',
        primaryLabel: 'Organisation',
        primaryValue: 'Mission-aligned angels',
        secondaryLabel: 'Target',
        secondaryValue: 'Initial outreach',
        notes: 'Track introductions and follow-up timing gently.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'partner-pilots',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'community-builder',
        title: 'Community pilot circles',
        status: 'Draft',
        primaryLabel: 'Channel',
        primaryValue: 'Community group',
        secondaryLabel: 'Audience',
        secondaryValue: 'Growers and early supporters',
        notes: 'Keep the first pilot community small and helpful.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'manufacturing-quote',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'manufacturing-planner',
        title: 'PCB quote request',
        status: 'Draft',
        primaryLabel: 'Supplier',
        primaryValue: 'Prototype board house',
        secondaryLabel: 'Lead time',
        secondaryValue: '2-3 weeks',
        notes: 'Compare sample order, panelisation, and shipping.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'timeline-launch-window',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'timeline-planner',
        title: 'Launch window',
        status: 'Draft',
        primaryLabel: 'Milestone',
        primaryValue: 'Prototype freeze',
        secondaryLabel: 'Target',
        secondaryValue: 'Before launch page goes live',
        notes: 'Use this to anchor the campaign preparation sequence.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'analytics-baseline',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'analytics',
        title: 'Baseline signals',
        status: 'Draft',
        primaryLabel: 'Metric',
        primaryValue: 'Readiness and margin',
        secondaryLabel: 'Focus',
        secondaryValue: 'Track weekly',
        notes: 'Keep the dashboard focused on action, not noise.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'launch-checklist-topline',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'launch-checklist',
        title: 'Pre-launch checklist',
        status: 'Draft',
        primaryLabel: 'Area',
        primaryValue: 'Readiness and assets',
        secondaryLabel: 'Due',
        secondaryValue: 'Before go-live',
        notes: 'Confirm story, rewards, proof, and finance are all reviewed.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'backer-update-1',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'backer-updates',
        title: 'Launch preparation update',
        status: 'Draft',
        primaryLabel: 'Audience',
        primaryValue: 'Early supporters',
        secondaryLabel: 'Tone',
        secondaryValue: 'Calm and transparent',
        notes: 'Use this to keep backers informed before the campaign opens.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'fulfilment-first-batch',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'fulfilment-tracker',
        title: 'First fulfilment batch',
        status: 'Draft',
        primaryLabel: 'Batch',
        primaryValue: 'MicroGrow starter kits',
        secondaryLabel: 'Status',
        secondaryValue: 'Planning',
        notes: 'Map the first shipment wave and keep the volume realistic.',
        order: 0,
      ),
      const LaunchpadPhase2Record(
        id: 'impact-baseline',
        campaignId: 'MICROGROW_KICKSTARTER_2026',
        section: 'impact-tracker',
        title: 'Impact baseline',
        status: 'Draft',
        primaryLabel: 'Measure',
        primaryValue: 'Community resilience',
        secondaryLabel: 'Review',
        secondaryValue: 'Post-campaign',
        notes: 'Capture the mission outcome we want to report back on later.',
        order: 0,
      ),
    ];
  }

  List<LaunchpadStoryBlock> _sortedStoryBlocks(List<LaunchpadStoryBlock> blocks) {
    final copy = [...blocks];
    copy.sort((a, b) => a.order.compareTo(b.order));
    return copy;
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      if (char == '"') {
        if (inQuotes && index + 1 < line.length && line[index + 1] == '"') {
          buffer.write('"');
          index++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (char == ',' && !inQuotes) {
        values.add(buffer.toString());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    values.add(buffer.toString());
    return values;
  }

  Future<void> _writeTextFileWithBackup(File file, String contents) async {
    if (await file.exists()) {
      await file.copy('${file.path}.bak');
    } else {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(contents);
  }

  String _safeFileName(String value) {
    final buffer = StringBuffer();
    var previousDash = false;
    for (final codeUnit in value.trim().toLowerCase().codeUnits) {
      final char = String.fromCharCode(codeUnit);
      final isAlphaNumeric = RegExp(r'[a-z0-9]').hasMatch(char);
      if (isAlphaNumeric) {
        buffer.write(char);
        previousDash = false;
      } else if (!previousDash) {
        buffer.write('-');
        previousDash = true;
      }
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }
}
