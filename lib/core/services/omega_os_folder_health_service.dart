import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../features/assets/data/assets_folder_service.dart';
import '../../features/treasury/data/treasury_folder_service.dart';
import '../../features/visual_capture/data/visual_capture_folder_service.dart';

enum OmegaOsFolderHealthState {
  healthy,
  missingTemplates,
  missingFolder,
  reserved,
}

class OmegaOsPathConfig {
  const OmegaOsPathConfig({
    required this.configPath,
    required this.omegaOsRootPath,
    required this.financeTreasuryPath,
    required this.assetsEquipmentPath,
    required this.visualCapturePath,
    required this.issues,
  });

  final String configPath;
  final String? omegaOsRootPath;
  final String? financeTreasuryPath;
  final String? assetsEquipmentPath;
  final String? visualCapturePath;
  final List<String> issues;
}

class OmegaOsFolderHealthRecord {
  const OmegaOsFolderHealthRecord({
    required this.folderName,
    required this.title,
    required this.path,
    required this.state,
    required this.isActive,
    required this.pathExists,
    required this.missingFolders,
    required this.missingFiles,
    required this.note,
  });

  final String folderName;
  final String title;
  final String path;
  final OmegaOsFolderHealthState state;
  final bool isActive;
  final bool pathExists;
  final List<String> missingFolders;
  final List<String> missingFiles;
  final String note;
}

class OmegaOsFolderHealthSnapshot {
  const OmegaOsFolderHealthSnapshot({
    required this.configPath,
    required this.omegaOsRootPath,
    required this.activeSystems,
    required this.reservedSystems,
    required this.issues,
    required this.healthyCount,
    required this.missingTemplatesCount,
    required this.missingFolderCount,
    required this.reservedCount,
  });

  final String configPath;
  final String? omegaOsRootPath;
  final List<OmegaOsFolderHealthRecord> activeSystems;
  final List<OmegaOsFolderHealthRecord> reservedSystems;
  final List<String> issues;
  final int healthyCount;
  final int missingTemplatesCount;
  final int missingFolderCount;
  final int reservedCount;
}

class OmegaOsFolderHealthRepairResult {
  const OmegaOsFolderHealthRepairResult({
    required this.createdFolders,
    required this.createdFiles,
    required this.repairedSystems,
  });

  final List<String> createdFolders;
  final List<String> createdFiles;
  final List<String> repairedSystems;
}

class OmegaOsFolderHealthService {
  OmegaOsFolderHealthService({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current;

  static const _configRelativePath = 'config/local_paths.json';
  static const _omegaOsRootKey = 'omega_os_root';
  static const _financeTreasuryKey = 'finance_treasury_path';
  static const _assetsEquipmentKey = 'assets_equipment_path';
  static const _visualCaptureKey = 'visual_capture_path';

  final Directory _workingDirectory;

  Future<OmegaOsFolderHealthSnapshot> loadSnapshot() async {
    final config = await _loadPathConfig();
    final treasuryService = TreasuryFolderService(
      workingDirectory: _workingDirectory,
    );
    final assetsService = AssetFolderService(
      workingDirectory: _workingDirectory,
    );
    final visualCaptureService = VisualCaptureFolderService(
      workingDirectory: _workingDirectory,
    );

    final treasurySnapshot = await treasuryService.loadWorkspace();
    final assetsSnapshot = await assetsService.loadWorkspace();
    final visualCaptureSnapshot = await visualCaptureService.loadWorkspace();

    final activeSystems = <OmegaOsFolderHealthRecord>[
      _recordFromTreasurySnapshot(treasurySnapshot, config),
      _recordFromAssetsSnapshot(assetsSnapshot, config),
      _recordFromVisualCaptureSnapshot(visualCaptureSnapshot, config),
    ];

    final reservedSystems = _buildReservedSystems(config);

    final healthyCount = activeSystems
        .where((record) => record.state == OmegaOsFolderHealthState.healthy)
        .length;
    final missingTemplatesCount = activeSystems
        .where(
          (record) => record.state == OmegaOsFolderHealthState.missingTemplates,
        )
        .length;
    final missingFolderCount = activeSystems
        .where(
          (record) => record.state == OmegaOsFolderHealthState.missingFolder,
        )
        .length;

    return OmegaOsFolderHealthSnapshot(
      configPath: config.configPath,
      omegaOsRootPath: config.omegaOsRootPath,
      activeSystems: activeSystems,
      reservedSystems: reservedSystems,
      issues: <String>[
        ...config.issues,
        ...treasurySnapshot.issues,
        ...assetsSnapshot.issues,
        ...visualCaptureSnapshot.issues,
      ],
      healthyCount: healthyCount,
      missingTemplatesCount: missingTemplatesCount,
      missingFolderCount: missingFolderCount,
      reservedCount: reservedSystems.length,
    );
  }

  Future<OmegaOsFolderHealthRepairResult> repairActiveSystems() async {
    final treasuryService = TreasuryFolderService(
      workingDirectory: _workingDirectory,
    );
    final assetsService = AssetFolderService(
      workingDirectory: _workingDirectory,
    );
    final visualCaptureService = VisualCaptureFolderService(
      workingDirectory: _workingDirectory,
    );

    final treasuryResult = await treasuryService
        .createMissingRequiredStructure();
    final assetsResult = await assetsService.createMissingRequiredStructure();
    final visualCaptureResult = await visualCaptureService
        .createMissingRequiredStructure();

    return OmegaOsFolderHealthRepairResult(
      createdFolders: <String>[
        ...treasuryResult.createdFolders,
        ...assetsResult.createdFolders,
        ...visualCaptureResult.createdFolders,
      ],
      createdFiles: <String>[
        ...treasuryResult.createdFiles,
        ...assetsResult.createdFiles,
        ...visualCaptureResult.createdFiles,
      ],
      repairedSystems: <String>[
        if (treasuryResult.createdFolders.isNotEmpty ||
            treasuryResult.createdFiles.isNotEmpty)
          'Treasury',
        if (assetsResult.createdFolders.isNotEmpty ||
            assetsResult.createdFiles.isNotEmpty)
          'Assets',
        if (visualCaptureResult.createdFolders.isNotEmpty ||
            visualCaptureResult.createdFiles.isNotEmpty)
          'Visual Capture',
      ],
    );
  }

  Future<OmegaOsPathConfig> _loadPathConfig() async {
    final configFile = File(
      path.join(_workingDirectory.path, _configRelativePath),
    );

    if (!await configFile.exists()) {
      return OmegaOsPathConfig(
        configPath: configFile.path,
        omegaOsRootPath: null,
        financeTreasuryPath: null,
        assetsEquipmentPath: null,
        visualCapturePath: null,
        issues: <String>[
          'config/local_paths.json was not found in the dashboard repo.',
        ],
      );
    }

    try {
      final decoded = jsonDecode(await configFile.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return OmegaOsPathConfig(
          configPath: configFile.path,
          omegaOsRootPath: null,
          financeTreasuryPath: null,
          assetsEquipmentPath: null,
          visualCapturePath: null,
          issues: <String>[
            'config/local_paths.json should contain a JSON object.',
          ],
        );
      }

      final omegaOsRootPath = _readPathValue(decoded, _omegaOsRootKey);
      final financeTreasuryPath = _readPathValue(decoded, _financeTreasuryKey);
      final assetsEquipmentPath = _readPathValue(decoded, _assetsEquipmentKey);
      final visualCapturePath = _readPathValue(decoded, _visualCaptureKey);
      final issues = <String>[];

      if (omegaOsRootPath == null) {
        issues.add('omega_os_root is missing from config/local_paths.json.');
      }
      if (financeTreasuryPath == null) {
        issues.add(
          'finance_treasury_path is missing from config/local_paths.json.',
        );
      }
      if (assetsEquipmentPath == null) {
        issues.add(
          'assets_equipment_path is missing from config/local_paths.json.',
        );
      }
      if (visualCapturePath == null) {
        issues.add(
          'visual_capture_path is missing from config/local_paths.json.',
        );
      }

      return OmegaOsPathConfig(
        configPath: configFile.path,
        omegaOsRootPath: omegaOsRootPath,
        financeTreasuryPath: financeTreasuryPath,
        assetsEquipmentPath: assetsEquipmentPath,
        visualCapturePath: visualCapturePath,
        issues: issues,
      );
    } on FormatException {
      return OmegaOsPathConfig(
        configPath: configFile.path,
        omegaOsRootPath: null,
        financeTreasuryPath: null,
        assetsEquipmentPath: null,
        visualCapturePath: null,
        issues: <String>['config/local_paths.json could not be read as JSON.'],
      );
    } on FileSystemException {
      return OmegaOsPathConfig(
        configPath: configFile.path,
        omegaOsRootPath: null,
        financeTreasuryPath: null,
        assetsEquipmentPath: null,
        visualCapturePath: null,
        issues: <String>['config/local_paths.json could not be opened.'],
      );
    }
  }

  OmegaOsFolderHealthRecord _recordFromTreasurySnapshot(
    TreasuryWorkspaceSnapshot snapshot,
    OmegaOsPathConfig config,
  ) {
    return _buildActiveRecord(
      folderName: '17_FINANCE_AND_TREASURY',
      title: 'Treasury',
      pathValue: config.financeTreasuryPath ?? snapshot.financeRootPath,
      isPathConfigured: config.financeTreasuryPath != null,
      pathExists: snapshot.financeRootPath != null,
      missingFolders: snapshot.missingFolders,
      missingFiles: snapshot.missingFiles,
      note: snapshot.guidanceNote,
    );
  }

  OmegaOsFolderHealthRecord _recordFromAssetsSnapshot(
    AssetWorkspaceSnapshot snapshot,
    OmegaOsPathConfig config,
  ) {
    return _buildActiveRecord(
      folderName: '18_ASSETS_EQUIPMENT_AND_PARTS',
      title: 'Assets',
      pathValue: config.assetsEquipmentPath ?? snapshot.assetsRootPath,
      isPathConfigured: config.assetsEquipmentPath != null,
      pathExists: snapshot.assetsRootPath != null,
      missingFolders: snapshot.missingFolders,
      missingFiles: snapshot.missingFiles,
      note:
          '${snapshot.guidanceNote} QR Labels stay inside Assets as a calm sub-system.',
    );
  }

  OmegaOsFolderHealthRecord _recordFromVisualCaptureSnapshot(
    VisualCaptureWorkspaceSnapshot snapshot,
    OmegaOsPathConfig config,
  ) {
    return _buildActiveRecord(
      folderName: '19_VISUAL_RECORDS_AND_CAPTURE',
      title: 'Visual Capture',
      pathValue: config.visualCapturePath ?? snapshot.visualCaptureRootPath,
      isPathConfigured: config.visualCapturePath != null,
      pathExists: snapshot.visualCaptureRootPath != null,
      missingFolders: snapshot.missingFolders,
      missingFiles: snapshot.missingFiles,
      note: snapshot.guidanceNote,
    );
  }

  OmegaOsFolderHealthRecord _buildActiveRecord({
    required String folderName,
    required String title,
    required String? pathValue,
    required bool isPathConfigured,
    required bool pathExists,
    required List<String> missingFolders,
    required List<String> missingFiles,
    required String note,
  }) {
    final state = _stateForActiveSystem(
      pathExists: pathValue != null && pathExists,
      missingFolders: missingFolders,
      missingFiles: missingFiles,
    );

    return OmegaOsFolderHealthRecord(
      folderName: folderName,
      title: title,
      path: pathValue ?? 'Not linked yet',
      state: state,
      isActive: true,
      pathExists: pathValue != null && pathExists && isPathConfigured,
      missingFolders: missingFolders,
      missingFiles: missingFiles,
      note: note,
    );
  }

  List<OmegaOsFolderHealthRecord> _buildReservedSystems(
    OmegaOsPathConfig config,
  ) {
    final rootPath = config.omegaOsRootPath;
    final reservedFolders = <MapEntry<String, String>>[
      const MapEntry(
        '20_CONTACTS_AND_RELATIONSHIPS',
        'Contacts & Relationships',
      ),
      const MapEntry('21_PROJECTS_AND_PROGRAMMES', 'Projects & Programmes'),
      const MapEntry('22_KNOWLEDGE_AND_LEARNING', 'Knowledge & Learning'),
      const MapEntry('23_AI_AND_AUTOMATION', 'AI & Automation'),
    ];

    return reservedFolders
        .map((entry) {
          final resolvedPath = rootPath == null
              ? null
              : path.join(rootPath, entry.key);
          final pathExists =
              resolvedPath != null && Directory(resolvedPath).existsSync();
          return OmegaOsFolderHealthRecord(
            folderName: entry.key,
            title: entry.value,
            path: resolvedPath ?? 'Waiting for omega_os_root',
            state: OmegaOsFolderHealthState.reserved,
            isActive: false,
            pathExists: pathExists,
            missingFolders: const <String>[],
            missingFiles: const <String>[],
            note: pathExists
                ? 'Reserved and parked for later. Path ready in Omega OS.'
                : 'Reserved and parked for later. Path not created yet.',
          );
        })
        .toList(growable: false);
  }

  OmegaOsFolderHealthState _stateForActiveSystem({
    required bool pathExists,
    required List<String> missingFolders,
    required List<String> missingFiles,
  }) {
    if (!pathExists || missingFolders.isNotEmpty) {
      return OmegaOsFolderHealthState.missingFolder;
    }

    if (missingFiles.isNotEmpty) {
      return OmegaOsFolderHealthState.missingTemplates;
    }

    return OmegaOsFolderHealthState.healthy;
  }

  String? _readPathValue(Map<String, dynamic> decoded, String key) {
    final value = decoded[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }
}
