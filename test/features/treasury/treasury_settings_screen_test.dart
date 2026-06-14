import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/treasury/application/treasury_controller.dart';
import 'package:new_earth_command_dashboard/features/treasury/data/treasury_folder_service.dart';
import 'package:new_earth_command_dashboard/features/treasury/presentation/treasury_settings_screen.dart';

void main() {
  TreasuryWorkspaceSnapshot buildWorkspace({
    required String? financeRootPath,
    required bool isReady,
    required List<String> missingFolders,
    required List<String> missingFiles,
    required List<String> issues,
  }) {
    return TreasuryWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      financeRootPath: financeRootPath,
      isReady: isReady,
      issues: issues,
      requiredFolders: TreasuryFolderService.requiredFolders,
      missingFolders: missingFolders,
      missingFiles: missingFiles,
      stateSummaries: const [],
      receiptsToSortCount: 0,
      weeklyRitualSteps: TreasuryFolderService.weeklyRitualSteps,
      lowEnergySteps: TreasuryFolderService.lowEnergySteps,
      guidanceNote: 'Calm setup.',
    );
  }

  testWidgets('settings screen explains setup state clearly', (tester) async {
    final workspace = buildWorkspace(
      financeRootPath: null,
      isReady: false,
      missingFolders: const ['00_FINANCE_DASHBOARD'],
      missingFiles: const ['00_FINANCE_DASHBOARD/dashboard_state.json'],
      issues: const [
        'finance_treasury_path is missing from config/local_paths.json.',
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          treasuryWorkspaceProvider.overrideWith((ref) async => workspace),
        ],
        child: const MaterialApp(home: TreasurySettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Setup state'), findsOneWidget);
    expect(find.text('Path missing'), findsOneWidget);
    expect(find.text('1 folder missing'), findsOneWidget);
    expect(find.text('1 file missing'), findsOneWidget);
    expect(find.textContaining('config/local_paths.json'), findsWidgets);
  });
}
