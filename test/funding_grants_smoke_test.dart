import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/funding_grants_command_centre/data/funding_grants_paths.dart';
import 'package:new_earth_command_dashboard/features/funding_grants_command_centre/data/funding_grants_repository.dart';
import 'package:new_earth_command_dashboard/features/funding_grants_command_centre/models/grant_record.dart';
import 'package:new_earth_command_dashboard/features/funding_grants_command_centre/models/grant_status.dart';
import 'package:new_earth_command_dashboard/features/funding_grants_command_centre/models/readiness_score.dart';
import 'package:new_earth_command_dashboard/features/funding_grants_command_centre/services/folder_template_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Funding Grants smoke test', () {
    test('loads the live Omega OS tracker and confirms base files', () async {
      final repository = FundingGrantsRepository();
      final grants = await repository.loadGrants();

      expect(grants, isNotEmpty);
      expect(File(FundingGrantsPaths.trackerJsonPath).existsSync(), isTrue);
      expect(File(FundingGrantsPaths.trackerCsvPath).existsSync(), isTrue);
      expect(File(FundingGrantsPaths.dashboardConfigPath).existsSync(), isTrue);

      for (final grant in grants) {
        expect(grant.folderPath, startsWith(FundingGrantsPaths.omegaRoot));
        expect(Directory(grant.folderPath).existsSync(), isTrue);
      }
    });

    test('creates and moves a grant folder with the template pack', () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'funding_grants_smoke_',
      );
      final service = FolderTemplateService();
      final grant = GrantRecord(
        id: 'GRANT-TEST',
        grantName: 'Smoke Test Grant',
        project: 'Smoke Project',
        fundingBody: 'Smoke Fund',
        fundingType: 'Test grant',
        amountRequested: 1234,
        matchFundingRequired: 'TBC',
        status: GrantStatus.drafting,
        deadline: 'TBC',
        submissionDate: null,
        decisionDate: null,
        priority: 'Medium',
        owner: 'Peter Ellis',
        nextAction: 'Check template pack and move flow',
        riskLevel: 'Low',
        readinessScore: const ReadinessScore(
          projectSummary: 1,
          budget: 1,
          evidence: 1,
          partnerSupport: 1,
          impactCase: 1,
          commercialPlan: 1,
          riskManagement: 1,
        ),
        folderPath: '',
        notes: 'Smoke test only.',
        tags: const ['smoke', 'test'],
      );

      final createdPath = await service.createGrantFolder(
        targetFolderPath: path.join(
          tempRoot.path,
          '01_ACTIVE_APPLICATIONS',
          'GRANT-TEST',
        ),
        grant: grant,
      );

      expect(Directory(createdPath).existsSync(), isTrue);
      for (final relative in const [
        'README.md',
        'application.md',
        'budget.md',
        'evidence_pack.md',
        'deadlines.md',
        'submission_notes.md',
        'partner_letters.md',
        'risk_register.md',
        'lessons_learned.md',
        'attachments',
      ]) {
        expect(
          Directory(path.join(createdPath, relative)).existsSync() ||
              File(path.join(createdPath, relative)).existsSync(),
          isTrue,
          reason: 'Expected $relative in the grant folder pack',
        );
      }

      final movedPath = await service.moveGrantFolder(
        sourceFolderPath: createdPath,
        targetFolderPath: path.join(
          tempRoot.path,
          '02_SUBMITTED_APPLICATIONS',
          'GRANT-TEST',
        ),
      );

      expect(Directory(movedPath).existsSync(), isTrue);
      expect(Directory(createdPath).existsSync(), isFalse);
    });
  });
}
