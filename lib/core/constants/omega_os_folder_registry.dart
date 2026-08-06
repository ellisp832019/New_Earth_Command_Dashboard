abstract final class OmegaOsFolderRegistry {
  static const activeSystems = <String>[
    '17_FINANCE_AND_TREASURY',
    '18_ASSETS_EQUIPMENT_AND_PARTS',
    '19_VISUAL_RECORDS_AND_CAPTURE',
  ];

  static const reservedSystems = <String>[
    '20_CONTACTS_AND_RELATIONSHIPS',
    '21_PROJECTS_AND_PROGRAMMES',
    '22_KNOWLEDGE_AND_LEARNING',
    '23_AI_AND_AUTOMATION',
  ];

  static const reservedSystemsNote =
      'Omega OS also has reserved folders 20-23 for future systems. Dashboard recognises them as inactive for now.';

  static const allKnownSystems = <String>[...activeSystems, ...reservedSystems];

  static bool isReservedSystem(String folderName) {
    return reservedSystems.contains(folderName);
  }
}
