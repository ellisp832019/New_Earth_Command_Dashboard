import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/company_command_centre/data/company_command_centre_index_service.dart';

void main() {
  test('scanner builds linked file indexes from markdown source files', () async {
    final tempRoot = await Directory.systemTemp.createTemp(
      'company_command_index_',
    );
    addTearDown(() => tempRoot.deleteSync(recursive: true));

    final omegaRoot = Directory(path.join(tempRoot.path, 'omega_company'));
    final moduleRoot = Directory(path.join(tempRoot.path, 'module_root'));
    final moduleConfig = File(path.join(tempRoot.path, 'module_config.json'));
    final documentsDir = Directory(path.join(omegaRoot.path, 'docs'));
    final grantsDir = Directory(path.join(omegaRoot.path, 'grants'));

    await documentsDir.create(recursive: true);
    await grantsDir.create(recursive: true);
    await moduleRoot.create(recursive: true);
    await omegaRoot.create(recursive: true);

    await File(path.join(documentsDir.path, 'website_plan.md')).writeAsString('''
---
owner: Peter Ellis
---
# Website Plan

- [ ] Add homepage hero
- [x] Add company footer

Target date 2026-07-01
''');

    await File(path.join(grantsDir.path, 'grant_pitch.md')).writeAsString('''
# Grants Pitch

- [ ] Draft grant summary

Next review: 2026-07-15
''');

    await moduleConfig.writeAsString(
      jsonEncode({
        'companyOmegaPath': omegaRoot.path,
        'readOnly': true,
        'backupBeforeWrite': true,
      }),
    );

    final service = CompanyCommandCentreIndexService(
      moduleRootPath: moduleRoot.path,
      moduleConfigPath: moduleConfig.path,
      omegaOsPath: omegaRoot.path,
      now: () => DateTime.utc(2026, 6, 20, 12, 34, 56),
    );

    final snapshot = await service.scanAndGenerate();
    final indexesDir = Directory(
      path.join(moduleRoot.path, 'omega_os_bridge', 'indexes'),
    );
    final companyIndexFile = File(
      path.join(indexesDir.path, 'company_index.generated.json'),
    );
    final actionItemsFile = File(
      path.join(indexesDir.path, 'action_items_index.generated.json'),
    );
    final deadlinesFile = File(
      path.join(indexesDir.path, 'deadlines_index.generated.json'),
    );
    final grantsFile = File(
      path.join(indexesDir.path, 'grants_index.generated.json'),
    );
    final productsFile = File(
      path.join(indexesDir.path, 'products_index.generated.json'),
    );
    final ipAssetsFile = File(
      path.join(indexesDir.path, 'ip_assets_index.generated.json'),
    );
    final evidenceFile = File(
      path.join(indexesDir.path, 'evidence_index.generated.json'),
    );

    expect(snapshot.sourceExists, isTrue);
    expect(snapshot.sourceMarkdownCount, 2);
    expect(snapshot.recentFiles, hasLength(2));
    expect(snapshot.recentFiles.first.title, 'Website Plan');
    expect(snapshot.recentFiles.first.checkboxCount, 2);
    expect(snapshot.recentFiles.last.labels, contains('grant'));

    expect(await companyIndexFile.exists(), isTrue);
    expect(await actionItemsFile.exists(), isTrue);
    expect(await deadlinesFile.exists(), isTrue);
    expect(await grantsFile.exists(), isTrue);
    expect(await productsFile.exists(), isTrue);
    expect(await ipAssetsFile.exists(), isTrue);
    expect(await evidenceFile.exists(), isTrue);

    final companyIndex = jsonDecode(await companyIndexFile.readAsString()) as Map<String, dynamic>;
    expect(companyIndex['record_count'], 2);
    expect(companyIndex['source_exists'], isTrue);

    final actionIndex = jsonDecode(await actionItemsFile.readAsString()) as Map<String, dynamic>;
    expect(actionIndex['record_count'], 2);

    final deadlineIndex = jsonDecode(await deadlinesFile.readAsString()) as Map<String, dynamic>;
    expect(deadlineIndex['record_count'], 2);

    final grantIndex = jsonDecode(await grantsFile.readAsString()) as Map<String, dynamic>;
    expect(grantIndex['record_count'], 1);

    final productsIndex = jsonDecode(await productsFile.readAsString()) as Map<String, dynamic>;
    expect(productsIndex['record_count'], 0);

    final ipAssetsIndex = jsonDecode(await ipAssetsFile.readAsString()) as Map<String, dynamic>;
    expect(ipAssetsIndex['record_count'], 0);

    final evidenceIndex = jsonDecode(await evidenceFile.readAsString()) as Map<String, dynamic>;
    expect(evidenceIndex['record_count'], 2);
  });
}
