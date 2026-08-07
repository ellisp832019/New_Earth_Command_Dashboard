import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/launchpad/data/launchpad_calculator.dart';
import 'package:new_earth_command_dashboard/features/launchpad/data/launchpad_repository.dart';

Future<void> main() async {
  final tempRoot = await Directory.systemTemp.createTemp('launchpad_smoke_');
  try {
    await _writeLaunchpadSeedPack(tempRoot);

    final repository = LaunchpadRepository(workingDirectory: tempRoot);
    final workspace = await repository.loadWorkspace();
    final campaign = workspace.campaignById('MICROGROW_KICKSTARTER_2026');
    if (campaign == null) {
      throw StateError('Seed campaign did not load.');
    }

    final readiness = calculateLaunchpadReadinessSummary(
      campaign.readinessItems,
    );
    final finance = calculateLaunchpadFinancialSummary(campaign);
    final exportPath = await repository.exportStoryMarkdown(campaign.id);
    final exportText = await File(exportPath).readAsString();

    if (!exportText.contains('# MicroGrow Kickstarter 2026')) {
      throw StateError('Story export did not contain the expected title.');
    }
    if (readiness.overallPercent <= 0) {
      throw StateError('Readiness score did not calculate.');
    }
    if (finance.breakEvenBackers <= 0) {
      throw StateError('Finance break-even did not calculate.');
    }

    stdout.writeln('Launchpad smoke test passed.');
    stdout.writeln('Campaigns: ${workspace.campaigns.length}');
    stdout.writeln(
      'Readiness: ${readiness.overallPercent.toStringAsFixed(0)}%',
    );
    stdout.writeln(
      'Net funds: £${finance.netAvailableFundsGbp.toStringAsFixed(0)}',
    );
  } finally {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  }
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

  await File(p.join(campaignDir.path, 'readiness.csv')).writeAsString(
    '''category,title,status,notes
Hardware,One ESP32 node demo,In Progress,Frankenstein prototype box
Firmware,Live /data endpoint,Done,Current firmware foundation
Software,Flutter dashboard reads node,Done,Existing app foundation
Manufacturing,PCB V0.1 plan,Draft,Low-voltage dev-board carrier
Documentation,Risk disclosure drafted,Todo,Especially delivery/certification
Marketing,3-5 minute demo video,Todo,Kickstarter proof asset
''',
  );
}
