import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/presentation/engineering_studio_screen.dart';

import 'engineering_studio_test_fixtures.dart';

void main() {
  final cases = <({EngineeringSection section, String fileName})>[
    (section: EngineeringSection.dashboard, fileName: 'dashboard.png'),
    (section: EngineeringSection.projects, fileName: 'projects.png'),
    (
      section: EngineeringSection.circuitLibrary,
      fileName: 'circuit_library.png',
    ),
    (section: EngineeringSection.pcbManager, fileName: 'pcb_manager.png'),
    (
      section: EngineeringSection.firmwareCentre,
      fileName: 'firmware_centre.png',
    ),
    (section: EngineeringSection.deviceFleet, fileName: 'device_fleet.png'),
    (
      section: EngineeringSection.componentInventory,
      fileName: 'component_inventory.png',
    ),
    (section: EngineeringSection.experimentLab, fileName: 'experiment_lab.png'),
    (
      section: EngineeringSection.testValidation,
      fileName: 'test_validation.png',
    ),
    (section: EngineeringSection.manufacturing, fileName: 'manufacturing.png'),
    (section: EngineeringSection.documentation, fileName: 'documentation.png'),
    (section: EngineeringSection.settings, fileName: 'settings.png'),
  ];

  for (final item in cases) {
    testWidgets('renders ${item.section.label}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: EngineeringStudioScreen(
            repository: EngineeringStudioFakeRepository(
              buildEngineeringStudioSnapshot(),
            ),
            initialSection: item.section,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EngineeringStudioScreen),
        matchesGoldenFile('goldens/sections/${item.fileName}'),
      );
    });
  }
}
