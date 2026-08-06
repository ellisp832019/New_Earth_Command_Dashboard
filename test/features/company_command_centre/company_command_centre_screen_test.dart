import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/company_command_centre/data/company_command_centre_repository.dart';
import 'package:new_earth_command_dashboard/features/company_command_centre/data/company_command_centre_index_service.dart';
import 'package:new_earth_command_dashboard/features/company_command_centre/presentation/company_command_centre_screen.dart';

void main() {
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxIterations = 50,
    Duration step = const Duration(milliseconds: 100),
  }) async {
    for (var i = 0; i < maxIterations; i++) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(step);
    }
  }

  Future<void> scrollToVisible(WidgetTester tester, Finder finder) async {
    final verticalScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: verticalScrollable.first,
    );
    await tester.pump();
  }

  Future<void> revealTab(WidgetTester tester, Finder finder) async {
    final horizontalScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.right,
    );
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: horizontalScrollable.first,
    );
    await tester.pump();
  }

  testWidgets('company command centre shows the read-only shell', (
    tester,
  ) async {
    final snapshot = CompanyCommandCentreSnapshot(
      overview: CompanyOverviewData(
        companyName: 'New Earth Advanced Technologies Ltd',
        companyNumber: '00000000',
        domain: 'newearth.global',
        bank: 'To be linked',
        omegaOsPath: r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY',
        status: 'Active',
        focus: <String>[
          'Website clarity',
          'LinkedIn presence',
          'Grant readiness',
        ],
        nextMilestone: 'Stabilise founder ops',
        omegaOsPathExists: true,
      ),
      actionBoard: <CompanyActionItemData>[
        CompanyActionItemData(
          id: 'action-today',
          title: 'Confirm bank account details',
          lane: 'Today',
          area: 'Finance',
          priority: 'High',
        ),
        CompanyActionItemData(
          id: 'action-week',
          title: 'Create Technologies page',
          lane: 'This Week',
          area: 'Marketing',
          priority: 'High',
        ),
        CompanyActionItemData(
          id: 'action-month',
          title: 'Review VAT / PAYE timing',
          lane: 'This Month',
          area: 'Finance',
          priority: 'Medium',
        ),
        CompanyActionItemData(
          id: 'action-waiting',
          title: 'Wait for partnership reply',
          lane: 'Waiting',
          area: 'Partnerships',
          priority: 'Low',
        ),
      ],
      productPortfolio: <CompanyProductItemData>[
        CompanyProductItemData(
          name: 'New Earth Dashboard',
          type: 'Platform',
          status: 'Active',
          commercialReadiness: 'Pilot',
        ),
      ],
      grantsPipeline: <CompanyGrantItemData>[
        CompanyGrantItemData(
          id: 'grant-1',
          name: 'Innovate UK',
          stage: 'Research',
          fit: 'Strong fit for local-first tooling',
          nextAction: 'Prepare scope note',
        ),
      ],
      moduleConfigPath:
          'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/config/module_config.json',
      moduleConfigExists: true,
      configuredOmegaPath: r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY',
      moduleReadOnly: true,
      moduleBackupBeforeWrite: true,
      backupRootPath:
          r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY\backups\company_command_centre',
      auditLogPath:
          r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY\audit\company_command_centre_write_audit.jsonl',
      indexSnapshot: CompanyCommandCentreIndexSnapshot(
        generatedAt: DateTime(2026, 6, 25, 6),
        sourcePath: r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY',
        sourceExists: true,
        sourceMarkdownCount: 7,
        companyIndexPath: 'company_index.generated.json',
        actionItemsIndexPath: 'action_items_index.generated.json',
        deadlinesIndexPath: 'deadlines_index.generated.json',
        productsIndexPath: 'products_index.generated.json',
        grantsIndexPath: 'grants_index.generated.json',
        ipAssetsIndexPath: 'ip_assets_index.generated.json',
        evidenceIndexPath: 'evidence_index.generated.json',
        recentFiles: <CompanyCommandCentreMarkdownRecord>[
          CompanyCommandCentreMarkdownRecord(
            title: 'UK company admin checklist',
            relativePath:
                'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
            sourcePath:
                r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY\docs\legal_finance\UK_COMPANY_ADMIN_CHECKLIST.md',
            checkboxCount: 3,
            openCheckboxCount: 2,
            closedCheckboxCount: 1,
            dueDates: <String>['2026-06-30'],
            frontmatter: <String, String>{},
            labels: <String>['action', 'deadline', 'evidence'],
            excerpt: 'Core admin checklist.',
          ),
        ],
        records: <CompanyCommandCentreMarkdownRecord>[
          CompanyCommandCentreMarkdownRecord(
            title: 'UK company admin checklist',
            relativePath:
                'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md',
            sourcePath:
                r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY\docs\legal_finance\UK_COMPANY_ADMIN_CHECKLIST.md',
            checkboxCount: 3,
            openCheckboxCount: 2,
            closedCheckboxCount: 1,
            dueDates: <String>['2026-06-30'],
            frontmatter: <String, String>{},
            labels: <String>['action', 'deadline', 'evidence'],
            excerpt: 'Core admin checklist.',
          ),
          CompanyCommandCentreMarkdownRecord(
            title: 'Product portfolio',
            relativePath:
                'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/product_portfolio.json',
            sourcePath:
                r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY\data\mock\product_portfolio.json',
            checkboxCount: 0,
            openCheckboxCount: 0,
            closedCheckboxCount: 0,
            dueDates: <String>[],
            frontmatter: <String, String>{},
            labels: <String>['product'],
            excerpt: 'Product board.',
          ),
          CompanyCommandCentreMarkdownRecord(
            title: 'Grants pipeline',
            relativePath:
                'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/mock/grants_pipeline.json',
            sourcePath:
                r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY\data\mock\grants_pipeline.json',
            checkboxCount: 0,
            openCheckboxCount: 0,
            closedCheckboxCount: 0,
            dueDates: <String>[],
            frontmatter: <String, String>{},
            labels: <String>['grant'],
            excerpt: 'Grant board.',
          ),
          CompanyCommandCentreMarkdownRecord(
            title: 'IP register',
            relativePath:
                'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/templates/company_overview_template.md',
            sourcePath:
                r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY\data\templates\company_overview_template.md',
            checkboxCount: 0,
            openCheckboxCount: 0,
            closedCheckboxCount: 0,
            dueDates: <String>[],
            frontmatter: <String, String>{},
            labels: <String>['ip_asset'],
            excerpt: 'Asset evidence.',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          companyCommandCentreSnapshotProvider.overrideWithValue(
            AsyncData(snapshot),
          ),
          assetWorkspaceProvider.overrideWithValue(
            const AsyncData(
              AssetWorkspaceSnapshot(
                configPath: 'config/local_paths.json',
                assetsRootPath: r'D:\NEW_EARTH_ASSETS',
                isReady: true,
                issues: <String>[],
                requiredFolders: <String>[],
                missingFolders: <String>[],
                missingFiles: <String>[],
                summaryCards: <AssetSummaryCard>[],
                equipmentCount: 8,
                partsCount: 14,
                guidanceNote: 'Ready',
              ),
            ),
          ),
          assetProjectSummaryProvider.overrideWithValue(
            const AsyncData(<AssetProjectSummary>[
              AssetProjectSummary(
                projectName: 'New Earth Dashboard',
                equipmentCount: 4,
                partsCount: 7,
                availableCount: 4,
                brokenCount: 0,
                lowStockCount: 1,
                needsDecisionCount: 0,
                isMixedProject: false,
              ),
            ]),
          ),
          assetValuationOverviewProvider.overrideWithValue(
            const AsyncData(
              AssetValuationOverview(
                purchaseCostTotal: 1000,
                replacementValueTotal: 1200,
                currentEstimatedValueTotal: 900,
                brokenLostValueTotal: 0,
                projectTotals: <AssetValuationProjectTotal>[],
                valuationRowCount: 3,
              ),
            ),
          ),
          assetSyncStatusProvider.overrideWithValue(
            const AsyncData(
              AssetSyncStatus(
                isConnected: true,
                entryCount: 4,
                conflictCount: 0,
                lastChangeAt: null,
                lastWriterLabel: 'tester',
                statusLabel: 'Connected',
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: CompanyCommandCentreScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntilFound(tester, find.text('Company Command Centre'));

    expect(find.text('Company Command Centre'), findsAtLeastNWidgets(1));
    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(
      find.text('New Earth Advanced Technologies Ltd'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.text(r'D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY'),
      findsAtLeastNWidgets(1),
    );

    await scrollToVisible(tester, find.text('Today at a glance'));
    expect(find.text('Today at a glance'), findsOneWidget);
    expect(find.text('Open LinkedIn'), findsWidgets);
    expect(find.text('Founder Pack PDF'), findsWidgets);

    await scrollToVisible(tester, find.text('IP & Asset Register'));
    expect(find.text('IP & Asset Register'), findsOneWidget);
    expect(find.text('Open Assets'), findsOneWidget);

    await scrollToVisible(tester, find.text('Generated indexes'));
    expect(find.text('Generated indexes'), findsOneWidget);
    expect(find.text('company_index.generated.json'), findsOneWidget);

    await revealTab(tester, find.text('Compliance & Deadlines').last);
    await tester.tap(find.text('Compliance & Deadlines').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntilFound(tester, find.text('Compliance & deadlines'));

    expect(find.text('Compliance & deadlines'), findsOneWidget);

    await revealTab(tester, find.text('Finance Snapshot').last);
    await tester.tap(find.text('Finance Snapshot').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntilFound(tester, find.text('Finance task tracker'));

    expect(find.text('Finance task tracker'), findsOneWidget);
    expect(find.text('Confirm bank account details'), findsOneWidget);
    expect(find.text('Review VAT / PAYE timing'), findsOneWidget);

    await revealTab(tester, find.text('Settings').last);
    await tester.tap(find.text('Settings').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntilFound(tester, find.text('Backup root'));

    expect(find.text('Backup root'), findsOneWidget);
    expect(find.text('Audit log'), findsOneWidget);
    expect(find.text('Copy first, then overwrite'), findsOneWidget);

    await revealTab(tester, find.text('Index Explorer').last);
    await tester.tap(find.text('Index Explorer').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await pumpUntilFound(tester, find.text('Search indexes'));

    expect(find.text('Search indexes'), findsOneWidget);
    expect(find.text('Source available'), findsWidgets);
    expect(find.text('All'), findsWidgets);
  });
}
