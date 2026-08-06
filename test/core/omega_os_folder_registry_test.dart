import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/constants/omega_os_folder_registry.dart';

void main() {
  test('omega os folder registry marks 20-23 as reserved', () {
    expect(
      OmegaOsFolderRegistry.activeSystems,
      contains('18_ASSETS_EQUIPMENT_AND_PARTS'),
    );
    expect(
      OmegaOsFolderRegistry.reservedSystems,
      contains('20_CONTACTS_AND_RELATIONSHIPS'),
    );
    expect(
      OmegaOsFolderRegistry.reservedSystems,
      contains('21_PROJECTS_AND_PROGRAMMES'),
    );
    expect(
      OmegaOsFolderRegistry.reservedSystems,
      contains('22_KNOWLEDGE_AND_LEARNING'),
    );
    expect(
      OmegaOsFolderRegistry.reservedSystems,
      contains('23_AI_AND_AUTOMATION'),
    );
    expect(
      OmegaOsFolderRegistry.isReservedSystem('21_PROJECTS_AND_PROGRAMMES'),
      isTrue,
    );
    expect(
      OmegaOsFolderRegistry.isReservedSystem('18_ASSETS_EQUIPMENT_AND_PARTS'),
      isFalse,
    );
  });
}
