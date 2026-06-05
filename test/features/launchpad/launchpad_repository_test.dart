import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/launchpad/data/launchpad_calculator.dart';
import 'package:new_earth_command_dashboard/features/launchpad/data/launchpad_phase2_models.dart';
import 'package:new_earth_command_dashboard/features/launchpad/data/launchpad_models.dart';
import 'package:new_earth_command_dashboard/features/launchpad/data/launchpad_repository.dart';

void main() {
  test('loadWorkspace imports the MicroGrow seed campaign and exports markdown', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'launchpad_repo_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    await _writeLaunchpadSeedPack(tempRoot);

    final repository = LaunchpadRepository(workingDirectory: tempRoot);
    final workspace = await repository.loadWorkspace();

    expect(workspace.campaigns, isNotEmpty);
    final campaign = workspace.campaignById('MICROGROW_KICKSTARTER_2026');
    expect(campaign, isNotNull);
    expect(campaign!.rewards, hasLength(2));
    expect(campaign.readinessItems, isNotEmpty);
    expect(campaign.phase2Records, isNotEmpty);

    final exportPath = await repository.exportStoryMarkdown(campaign.id);
    final exportText = await File(exportPath).readAsString();
    expect(exportText, contains('# MicroGrow Kickstarter 2026'));
    expect(exportText, contains('Campaign Summary'));
  });

  test('exportCampaignPack writes a complete campaign pack', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'launchpad_pack_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    await _writeLaunchpadSeedPack(tempRoot);

    final repository = LaunchpadRepository(workingDirectory: tempRoot);
    final packPath = await repository.exportCampaignPack(
      'MICROGROW_KICKSTARTER_2026',
    );

    final packDir = Directory(packPath);
    expect(await packDir.exists(), isTrue);
    expect(await File(p.join(packPath, 'campaign.json')).exists(), isTrue);
    expect(await File(p.join(packPath, 'story.md')).exists(), isTrue);
    expect(await File(p.join(packPath, 'rewards.json')).exists(), isTrue);
    expect(await File(p.join(packPath, 'readiness.json')).exists(), isTrue);
    expect(await File(p.join(packPath, 'risks.json')).exists(), isTrue);
    expect(await File(p.join(packPath, 'phase2.json')).exists(), isTrue);
    expect(await File(p.join(packPath, 'finance.json')).exists(), isTrue);

    final manifest = await File(p.join(packPath, 'pack-manifest.md')).readAsString();
    expect(manifest, contains('MicroGrow Kickstarter 2026 Pack'));
    expect(manifest, contains('Phase 2 Sections'));
  });

  test('loadWorkspace merges missing Phase 2 seed records into runtime state', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'launchpad_merge_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    await _writeLaunchpadSeedPack(tempRoot);
    await _writeRuntimeStateWithoutPhase2(tempRoot);

    final repository = LaunchpadRepository(workingDirectory: tempRoot);
    final workspace = await repository.loadWorkspace();
    final campaign = workspace.campaignById('MICROGROW_KICKSTARTER_2026');

    expect(campaign, isNotNull);
    expect(campaign!.phase2Records, isNotEmpty);
    expect(
      campaign.phase2Records.any((record) => record.section == 'launch-checklist'),
      isTrue,
    );
  });

  test('repository resolves the workspace root instead of the current folder', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'launchpad_root_test_',
    );
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    await _writeLaunchpadSeedPack(tempRoot);

    final nestedWorkingDir = Directory(
      p.join(
        tempRoot.path,
        'apps',
        'launchpad',
        'scratch',
      ),
    );
    await nestedWorkingDir.create(recursive: true);

    final previousCurrent = Directory.current;
    Directory.current = nestedWorkingDir;
    addTearDown(() {
      Directory.current = previousCurrent;
    });

    final repository = LaunchpadRepository();
    final workspace = await repository.loadWorkspace();
    final campaign = workspace.campaignById('MICROGROW_KICKSTARTER_2026');
    expect(campaign, isNotNull);

    await repository.updateCampaign(
      campaign!.copyWith(
        fundingGoalGbp: 50000,
        finance: campaign.finance.copyWith(fundingGoalGbp: 50000),
      ),
    );

    final runtimePath = p.join(
      tempRoot.path,
      'modules',
      'new_earth_launchpad_module',
      'dashboard_module',
      'data',
      'runtime',
      'launchpad_state.json',
    );
    expect(await File(runtimePath).exists(), isTrue);

    final runtimeJson = jsonDecode(await File(runtimePath).readAsString()) as Map<String, dynamic>;
    final savedCampaigns = (runtimeJson['campaigns'] as List).cast<Map>();
    final savedCampaign = savedCampaigns.cast<Map<String, dynamic>>().firstWhere(
      (entry) => entry['id'] == 'MICROGROW_KICKSTARTER_2026',
    );
    expect(savedCampaign['funding_goal_gbp'], 50000);
    expect(savedCampaign['finance']['funding_goal_gbp'], 50000);
  });

  test('financial and readiness calculators return calm launch summaries', () {
    final campaign = LaunchpadCampaignRecord(
      id: 'MICROGROW_KICKSTARTER_2026',
      name: 'MicroGrow Kickstarter 2026',
      project: 'MicroGrow',
      type: 'kickstarter',
      status: LaunchpadCampaignStatus.prototype,
      fundingGoalGbp: 35000,
      launchDate: null,
      owner: 'Peter Ellis',
      summary: 'Local-first grow automation ecosystem.',
      createdAt: DateTime(2026, 6, 4),
      updatedAt: DateTime(2026, 6, 4),
      progressPercentage: 28,
      rewards: const [
        LaunchpadRewardTier(
          id: 'SUPPORTER_10',
          campaignId: 'MICROGROW_KICKSTARTER_2026',
          name: 'Supporter',
          priceGbp: 10,
          quantityLimit: null,
          estimatedCogsGbp: 0,
          estimatedShippingGbp: 0,
          deliveryEstimate: 'Digital',
          notes: '',
        ),
        LaunchpadRewardTier(
          id: 'DEV_KIT_149',
          campaignId: 'MICROGROW_KICKSTARTER_2026',
          name: 'MicroGrow Developer Kit',
          priceGbp: 149,
          quantityLimit: 100,
          estimatedCogsGbp: 65,
          estimatedShippingGbp: 8,
          deliveryEstimate: '8-10 weeks after campaign',
          notes: '',
        ),
      ],
      storyBlocks: const <LaunchpadStoryBlock>[],
      readinessItems: const [
        LaunchpadReadinessItem(
          id: 'hardware-node',
          campaignId: 'MICROGROW_KICKSTARTER_2026',
          category: 'Hardware',
          title: 'One ESP32 node demo',
          status: 'In Progress',
          proofLink: '',
          notes: '',
        ),
        LaunchpadReadinessItem(
          id: 'firmware-data',
          campaignId: 'MICROGROW_KICKSTARTER_2026',
          category: 'Firmware',
          title: 'Live /data endpoint',
          status: 'Done',
          proofLink: '',
          notes: '',
        ),
        LaunchpadReadinessItem(
          id: 'software-dashboard',
          campaignId: 'MICROGROW_KICKSTARTER_2026',
          category: 'Software',
          title: 'Flutter dashboard reads node',
          status: 'Done',
          proofLink: '',
          notes: '',
        ),
        LaunchpadReadinessItem(
          id: 'manufacturing-pcb',
          campaignId: 'MICROGROW_KICKSTARTER_2026',
          category: 'Manufacturing',
          title: 'PCB V0.1 plan',
          status: 'Draft',
          proofLink: '',
          notes: '',
        ),
        LaunchpadReadinessItem(
          id: 'documentation-risk',
          campaignId: 'MICROGROW_KICKSTARTER_2026',
          category: 'Documentation',
          title: 'Risk disclosure drafted',
          status: 'Todo',
          proofLink: '',
          notes: '',
        ),
        LaunchpadReadinessItem(
          id: 'marketing-video',
          campaignId: 'MICROGROW_KICKSTARTER_2026',
          category: 'Marketing',
          title: '3-5 minute demo video',
          status: 'Todo',
          proofLink: '',
          notes: '',
        ),
      ],
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
    );

    final readiness = calculateLaunchpadReadinessSummary(campaign.readinessItems);
    final finance = calculateLaunchpadFinancialSummary(campaign);

    expect(readiness.overallPercent, greaterThan(0));
    expect(finance.grossFundingGbp, 35000);
    expect(finance.breakEvenBackers, greaterThan(0));
    expect(finance.riskIndicators, isNotEmpty);
  });
}

Future<void> _writeLaunchpadSeedPack(Directory root) async {
  final campaignDir = Directory(
    p.join(
      root.path,
      'modules',
      'new_earth_launchpad_module',
      'dashboard_module',
      'data',
      'campaigns',
      'MICROGROW_KICKSTARTER_2026',
    ),
  );
  await campaignDir.create(recursive: true);

  await File(p.join(campaignDir.path, 'campaign.json')).writeAsString(
    jsonEncode({
      'id': 'MICROGROW_KICKSTARTER_2026',
      'name': 'MicroGrow Kickstarter 2026',
      'project': 'MicroGrow',
      'type': 'kickstarter',
      'status': 'Prototype',
      'funding_goal_gbp': 35000,
      'launch_date': null,
      'owner': 'Peter Ellis',
      'summary':
          'Local-first grow automation ecosystem using ESP32 nodes, sensors, relay control, a hub architecture, and Flutter app.',
      'created_at': '2026-06-04T00:00:00.000',
      'updated_at': '2026-06-04T00:00:00.000',
      'progress_percentage': 28,
    }),
  );

  await File(p.join(campaignDir.path, 'rewards.json')).writeAsString(
    jsonEncode([
      {
        'id': 'SUPPORTER_10',
        'name': 'Supporter',
        'price_gbp': 10,
        'quantity_limit': null,
        'estimated_cogs_gbp': 0,
        'estimated_shipping_gbp': 0,
        'delivery_estimate': 'Digital',
        'notes': 'Digital thank you and campaign updates.',
      },
      {
        'id': 'DEV_KIT_149',
        'name': 'MicroGrow Developer Kit',
        'price_gbp': 149,
        'quantity_limit': 100,
        'estimated_cogs_gbp': 65,
        'estimated_shipping_gbp': 8,
        'delivery_estimate': '8-10 weeks after campaign',
        'notes': 'ESP32 dev kit, sensor bundle, low-voltage relay board, docs.',
      },
    ]),
  );

  await File(p.join(campaignDir.path, 'readiness.csv')).writeAsString('''category,title,status,notes
Hardware,One ESP32 node demo,In Progress,Frankenstein prototype box
Firmware,Live /data endpoint,Done,Current firmware foundation
Software,Flutter dashboard reads node,Done,Existing app foundation
Manufacturing,PCB V0.1 plan,Draft,Low-voltage dev-board carrier
Documentation,Risk disclosure drafted,Todo,Especially delivery/certification
Marketing,3-5 minute demo video,Todo,Kickstarter proof asset
''');

  await File(p.join(campaignDir.path, 'phase2.json')).writeAsString(
    jsonEncode([
      {
        'id': 'media-hero-image',
        'section': 'media-studio',
        'title': 'Hero image set',
        'status': 'Draft',
        'primary_label': 'Asset type',
        'primary_value': 'Graphic',
        'secondary_label': 'Source',
        'secondary_value': 'Omega OS export pending',
        'notes': 'Hero image, product shot, and banner crop set.',
        'order': 0,
      },
      {
        'id': 'grant-shortlist',
        'section': 'grant-centre',
        'title': 'Grant shortlist',
        'status': 'Research',
        'primary_label': 'Funder',
        'primary_value': 'Innovation grants',
        'secondary_label': 'Deadline',
        'secondary_value': 'Rolling',
        'notes': 'Keep a shortlist of suitable local and mission-led grants.',
        'order': 0,
      },
      {
        'id': 'launch-checklist-topline',
        'section': 'launch-checklist',
        'title': 'Pre-launch checklist',
        'status': 'Draft',
        'primary_label': 'Area',
        'primary_value': 'Readiness and assets',
        'secondary_label': 'Due',
        'secondary_value': 'Before go-live',
        'notes': 'Confirm story, rewards, proof, and finance are all reviewed.',
        'order': 0,
      },
      {
        'id': 'backer-update-1',
        'section': 'backer-updates',
        'title': 'Launch preparation update',
        'status': 'Draft',
        'primary_label': 'Audience',
        'primary_value': 'Early supporters',
        'secondary_label': 'Tone',
        'secondary_value': 'Calm and transparent',
        'notes': 'Use this to keep backers informed before the campaign opens.',
        'order': 0,
      },
      {
        'id': 'fulfilment-first-batch',
        'section': 'fulfilment-tracker',
        'title': 'First fulfilment batch',
        'status': 'Draft',
        'primary_label': 'Batch',
        'primary_value': 'MicroGrow starter kits',
        'secondary_label': 'Status',
        'secondary_value': 'Planning',
        'notes': 'Map the first shipment wave and keep the volume realistic.',
        'order': 0,
      },
      {
        'id': 'impact-baseline',
        'section': 'impact-tracker',
        'title': 'Impact baseline',
        'status': 'Draft',
        'primary_label': 'Measure',
        'primary_value': 'Community resilience',
        'secondary_label': 'Review',
        'secondary_value': 'Post-campaign',
        'notes': 'Capture the mission outcome we want to report back on later.',
        'order': 0,
      },
    ]),
  );
}

Future<void> _writeRuntimeStateWithoutPhase2(Directory root) async {
  final runtimeFile = File(
    p.join(
      root.path,
      'modules',
      'new_earth_launchpad_module',
      'dashboard_module',
      'data',
      'runtime',
      'launchpad_state.json',
    ),
  );
  await runtimeFile.parent.create(recursive: true);
  await runtimeFile.writeAsString(
    jsonEncode({
      'updated_at': '2026-06-04T19:09:02.389296',
      'campaigns': [
        {
          'id': 'MICROGROW_KICKSTARTER_2026',
          'name': 'MicroGrow Kickstarter 2026',
          'project': 'MicroGrow',
          'type': 'kickstarter',
          'status': 'Prototype',
          'funding_goal_gbp': 35000,
          'launch_date': null,
          'owner': 'Peter Ellis',
          'summary':
              'Local-first grow automation ecosystem using ESP32 nodes, sensors, relay control, a hub architecture, and Flutter app.',
          'created_at': '2026-06-04T00:00:00.000',
          'updated_at': '2026-06-04T00:00:00.000',
          'progress_percentage': 28,
          'rewards': [],
          'story_blocks': [],
          'readiness_items': [],
          'risks': [],
          'finance': {
            'funding_goal_gbp': 35000.0,
            'manufacturing_costs_gbp': 15000.0,
            'shipping_gbp': 7000.0,
            'vat_percent': 20.0,
            'kickstarter_fee_percent': 5.0,
            'payment_fee_percent': 3.0,
            'contingency_percent': 12.0,
            'fixed_costs_gbp': 0.0,
          },
        },
      ],
    }),
  );
}
