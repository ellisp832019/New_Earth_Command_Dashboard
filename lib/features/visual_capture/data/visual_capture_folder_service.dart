import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../core/constants/omega_os_folder_registry.dart';
import '../../../core/utils/folder_bootstrap_result.dart';
import '../../assets/data/asset_csv_service.dart';

class VisualCaptureInboxItem {
  const VisualCaptureInboxItem({
    required this.captureId,
    required this.sourcePath,
    required this.filePath,
    required this.captureType,
    required this.linkedDomain,
    required this.linkedId,
    required this.project,
    required this.status,
    required this.dateAdded,
    required this.notes,
  });

  final String captureId;
  final String sourcePath;
  final String filePath;
  final String captureType;
  final String linkedDomain;
  final String linkedId;
  final String project;
  final String status;
  final String dateAdded;
  final String notes;
}

class VisualCaptureInboxSnapshot {
  const VisualCaptureInboxSnapshot({
    required this.inboxPath,
    required this.indexPath,
    required this.items,
    required this.queuedFileCount,
    required this.issues,
  });

  final String? inboxPath;
  final String? indexPath;
  final List<VisualCaptureInboxItem> items;
  final int queuedFileCount;
  final List<String> issues;
}

class VisualCaptureImportResult {
  const VisualCaptureImportResult({
    required this.captureId,
    required this.copiedFilePath,
    required this.indexPath,
  });

  final String captureId;
  final String copiedFilePath;
  final String indexPath;
}

class VisualCaptureWorkspaceSnapshot {
  const VisualCaptureWorkspaceSnapshot({
    required this.configPath,
    required this.visualCaptureRootPath,
    required this.isReady,
    required this.issues,
    required this.requiredFolders,
    required this.missingFolders,
    required this.missingFiles,
    required this.guidanceNote,
  });

  final String configPath;
  final String? visualCaptureRootPath;
  final bool isReady;
  final List<String> issues;
  final List<String> requiredFolders;
  final List<String> missingFolders;
  final List<String> missingFiles;
  final String guidanceNote;
}

class VisualCaptureFolderService {
  VisualCaptureFolderService({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current,
      _csvService = AssetCsvService();

  static const _configRelativePath = 'config/local_paths.json';
  static const _visualCaptureRootKey = 'visual_capture_path';
  static const _inboxFolderName = '14_TEMP_UPLOADS_AND_INBOX';
  static const _indexFilePath = '00_VISUAL_DASHBOARD/visual_capture_index.csv';
  static const _uuid = Uuid();

  static const inboxCaptureTypes = <String>[
    'receipt',
    'asset',
    'part_bin',
    'qr_proof',
    'serial_warranty',
    'repair_damage',
    'prototype',
    'workbench',
    'project_progress',
  ];

  static const requiredFolders = <String>[
    '00_VISUAL_DASHBOARD',
    '01_RECEIPT_PHOTOS_AND_SCANS',
    '02_ASSET_PHOTOS',
    '06_REPAIR_AND_DAMAGE_RECORDS',
    '12_AI_EXTRACTION_AND_OCR',
    '14_TEMP_UPLOADS_AND_INBOX',
    '16_CAPTURE_STATION_SETUP',
    '17_PRIVACY_REDACTION_AND_SENSITIVE_IMAGES',
  ];

  static const requiredFiles = <String>[
    '00_VISUAL_DASHBOARD/visual_capture_index.csv',
    '01_RECEIPT_PHOTOS_AND_SCANS/receipt_photo_index.csv',
    '02_ASSET_PHOTOS/asset_photo_index.csv',
    '06_REPAIR_AND_DAMAGE_RECORDS/repair_photo_index.csv',
    '12_AI_EXTRACTION_AND_OCR/ocr_extraction_queue.csv',
    '16_CAPTURE_STATION_SETUP/camera_device_profiles.csv',
    '17_PRIVACY_REDACTION_AND_SENSITIVE_IMAGES/sensitive_image_review.csv',
  ];

  final Directory _workingDirectory;
  final AssetCsvService _csvService;

  Future<VisualCaptureWorkspaceSnapshot> loadWorkspace() async {
    final configFile = File(
      path.join(_workingDirectory.path, _configRelativePath),
    );
    final issues = <String>[];
    String? visualCaptureRootPath;

    if (!await configFile.exists()) {
      issues.add(
        'config/local_paths.json was not found in the dashboard repo.',
      );
    } else {
      try {
        final decoded = jsonDecode(await configFile.readAsString());
        if (decoded is Map<String, dynamic>) {
          final value = decoded[_visualCaptureRootKey];
          if (value is String && value.trim().isNotEmpty) {
            visualCaptureRootPath = value.trim();
          } else {
            issues.add(
              'visual_capture_path is missing from config/local_paths.json.',
            );
          }
        } else {
          issues.add('config/local_paths.json should contain a JSON object.');
        }
      } on FormatException {
        issues.add('config/local_paths.json could not be read as JSON.');
      } on FileSystemException {
        issues.add('config/local_paths.json could not be opened.');
      }
    }

    Directory? visualCaptureRoot;
    if (visualCaptureRootPath != null) {
      visualCaptureRoot = Directory(visualCaptureRootPath);
      if (!await visualCaptureRoot.exists()) {
        issues.add(
          'The visual capture folder does not exist at the configured path.',
        );
      }
    }

    final missingFolders = <String>[];
    if (visualCaptureRoot != null && await visualCaptureRoot.exists()) {
      for (final relativeFolder in requiredFolders) {
        final candidate = Directory(
          path.join(visualCaptureRoot.path, relativeFolder),
        );
        if (!await candidate.exists()) {
          missingFolders.add(relativeFolder);
        }
      }
    }

    final missingFiles = <String>[];
    if (visualCaptureRoot != null && await visualCaptureRoot.exists()) {
      for (final relativeFile in requiredFiles) {
        final candidate = File(path.join(visualCaptureRoot.path, relativeFile));
        if (!await candidate.exists()) {
          missingFiles.add(relativeFile);
        }
      }
    }

    final guidanceNote = visualCaptureRoot == null
        ? 'The Visual Capture area will calm down once the external Omega OS folder is linked. ${OmegaOsFolderRegistry.reservedSystemsNote}'
        : missingFolders.isEmpty && missingFiles.isEmpty
        ? 'The external visual capture folder is connected. Capture stays local-first and starter files are in place. ${OmegaOsFolderRegistry.reservedSystemsNote}'
        : 'The visual capture folder is present, but a few expected Omega OS folders or tracker files still need attention. ${OmegaOsFolderRegistry.reservedSystemsNote}';

    return VisualCaptureWorkspaceSnapshot(
      configPath: configFile.path,
      visualCaptureRootPath: visualCaptureRootPath,
      isReady:
          issues.isEmpty &&
          visualCaptureRootPath != null &&
          missingFolders.isEmpty &&
          missingFiles.isEmpty,
      issues: issues,
      requiredFolders: requiredFolders,
      missingFolders: missingFolders,
      missingFiles: missingFiles,
      guidanceNote: guidanceNote,
    );
  }

  Future<FolderBootstrapCreationResult> createMissingRequiredStructure() async {
    final snapshot = await loadWorkspace();
    final visualCaptureRootPath = snapshot.visualCaptureRootPath;
    if (visualCaptureRootPath == null) {
      return const FolderBootstrapCreationResult(
        createdFolders: <String>[],
        createdFiles: <String>[],
      );
    }

    final visualCaptureRoot = Directory(visualCaptureRootPath);
    if (!await visualCaptureRoot.exists()) {
      return const FolderBootstrapCreationResult(
        createdFolders: <String>[],
        createdFiles: <String>[],
      );
    }

    final createdFolders = <String>[];
    for (final relativeFolder in requiredFolders) {
      final candidate = Directory(
        path.join(visualCaptureRoot.path, relativeFolder),
      );
      if (await candidate.exists()) {
        continue;
      }

      await candidate.create(recursive: true);
      createdFolders.add(relativeFolder);
    }

    final createdFiles = <String>[];
    for (final relativeFile in requiredFiles) {
      final candidate = File(path.join(visualCaptureRoot.path, relativeFile));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.parent.create(recursive: true);
      await candidate.writeAsString(_templateForRequiredFile(relativeFile));
      createdFiles.add(relativeFile);
    }

    return FolderBootstrapCreationResult(
      createdFolders: createdFolders,
      createdFiles: createdFiles,
    );
  }

  Future<VisualCaptureInboxSnapshot> loadInbox() async {
    final snapshot = await loadWorkspace();
    final rootPath = snapshot.visualCaptureRootPath;
    if (rootPath == null) {
      return VisualCaptureInboxSnapshot(
        inboxPath: null,
        indexPath: null,
        items: const <VisualCaptureInboxItem>[],
        queuedFileCount: 0,
        issues: snapshot.issues,
      );
    }

    final inboxPath = path.join(rootPath, _inboxFolderName);
    final indexPath = path.join(rootPath, _indexFilePath);
    final inboxDirectory = Directory(inboxPath);
    final queueCount = await _countInboxFiles(inboxDirectory);

    final table = await _csvService.readTable(
      File(indexPath),
      expectedHeaders: const [
        'capture_id',
        'date_added',
        'source',
        'file_path',
        'capture_type',
        'linked_domain',
        'linked_id',
        'project',
        'status',
        'ocr_status',
        'sensitive',
        'notes',
      ],
    );

    final items =
        table.rows
            .map(_inboxItemFromRow)
            .where((item) => item.filePath.contains(_inboxFolderName))
            .toList(growable: false)
          ..sort((left, right) => right.dateAdded.compareTo(left.dateAdded));

    return VisualCaptureInboxSnapshot(
      inboxPath: inboxPath,
      indexPath: indexPath,
      items: items,
      queuedFileCount: queueCount,
      issues: snapshot.issues,
    );
  }

  Future<VisualCaptureImportResult> importImageToInbox({
    required String visualCaptureRootPath,
    required String sourceFilePath,
    required String captureType,
    String project = '',
    String notes = '',
  }) async {
    final sourceFile = File(sourceFilePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException(
        'Selected file could not be found.',
        sourceFilePath,
      );
    }

    final inboxDirectory = Directory(
      path.join(visualCaptureRootPath, _inboxFolderName),
    );
    await inboxDirectory.create(recursive: true);

    final captureId =
        'VC-${_dateStamp(DateTime.now())}-${_uuid.v4().substring(0, 8)}';
    final extension = path.extension(sourceFile.path);
    final destinationFile = File(
      path.join(
        inboxDirectory.path,
        '${captureId.toLowerCase()}${extension.isNotEmpty ? extension : ''}',
      ),
    );
    await sourceFile.copy(destinationFile.path);

    final indexFile = File(path.join(visualCaptureRootPath, _indexFilePath));
    final row = <String, String>{
      'capture_id': captureId,
      'date_added': DateTime.now().toIso8601String(),
      'source': 'local_import',
      'file_path': destinationFile.path,
      'capture_type': captureType,
      'linked_domain': 'visual_capture',
      'linked_id': '',
      'project': project,
      'status': 'inbox',
      'ocr_status': 'pending',
      'sensitive': 'no',
      'notes': notes,
    };
    await _csvService.appendRow(
      indexFile,
      row,
      expectedHeaders: const [
        'capture_id',
        'date_added',
        'source',
        'file_path',
        'capture_type',
        'linked_domain',
        'linked_id',
        'project',
        'status',
        'ocr_status',
        'sensitive',
        'notes',
      ],
    );

    return VisualCaptureImportResult(
      captureId: captureId,
      copiedFilePath: destinationFile.path,
      indexPath: indexFile.path,
    );
  }

  Future<bool> openVisualCaptureFolder(String visualCaptureRootPath) async {
    final directory = Directory(visualCaptureRootPath);
    if (!await directory.exists()) {
      return false;
    }

    try {
      if (Platform.isWindows) {
        await Process.start('explorer', <String>[
          directory.path,
        ], runInShell: true);
        return true;
      }

      if (Platform.isMacOS) {
        await Process.start('open', <String>[directory.path], runInShell: true);
        return true;
      }

      await Process.start('xdg-open', <String>[
        directory.path,
      ], runInShell: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openVisualCaptureInboxFolder(
    String visualCaptureRootPath,
  ) async {
    final inboxDirectory = Directory(
      path.join(visualCaptureRootPath, _inboxFolderName),
    );
    if (!await inboxDirectory.exists()) {
      return false;
    }

    try {
      if (Platform.isWindows) {
        await Process.start('explorer', <String>[
          inboxDirectory.path,
        ], runInShell: true);
        return true;
      }

      if (Platform.isMacOS) {
        await Process.start('open', <String>[
          inboxDirectory.path,
        ], runInShell: true);
        return true;
      }

      await Process.start('xdg-open', <String>[
        inboxDirectory.path,
      ], runInShell: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> writeTextFileWithBackup(File file, String contents) async {
    if (await file.exists()) {
      final backupFile = File('${file.path}.bak');
      await file.copy(backupFile.path);
    } else {
      await file.parent.create(recursive: true);
    }

    await file.writeAsString(contents);
  }

  String _templateForRequiredFile(String relativePath) {
    switch (relativePath) {
      case '00_VISUAL_DASHBOARD/visual_capture_index.csv':
        return 'capture_id,date_added,source,file_path,capture_type,linked_domain,linked_id,project,status,ocr_status,sensitive,notes\n';
      case '01_RECEIPT_PHOTOS_AND_SCANS/receipt_photo_index.csv':
        return 'capture_id,date_added,file_path,supplier,date_on_receipt,amount,linked_finance_record,status,ocr_status,notes\n';
      case '02_ASSET_PHOTOS/asset_photo_index.csv':
        return 'capture_id,date_added,file_path,asset_id,photo_type,location,status,notes\n';
      case '06_REPAIR_AND_DAMAGE_RECORDS/repair_photo_index.csv':
        return 'capture_id,date_added,file_path,asset_id,issue,status,linked_maintenance_record,notes\n';
      case '12_AI_EXTRACTION_AND_OCR/ocr_extraction_queue.csv':
        return 'queue_id,capture_id,file_path,document_type,status,extracted_json_path,reviewed_by,notes\n';
      case '16_CAPTURE_STATION_SETUP/camera_device_profiles.csv':
        return 'profile_id,name,type,connection,default_capture_folder,resolution,notes\n';
      case '17_PRIVACY_REDACTION_AND_SENSITIVE_IMAGES/sensitive_image_review.csv':
        return 'capture_id,file_path,reason,status,action_taken,notes\n';
      default:
        return '';
    }
  }

  VisualCaptureInboxItem _inboxItemFromRow(Map<String, String> row) {
    return VisualCaptureInboxItem(
      captureId: row['capture_id']?.trim() ?? '',
      sourcePath: row['source']?.trim() ?? '',
      filePath: row['file_path']?.trim() ?? '',
      captureType: row['capture_type']?.trim() ?? '',
      linkedDomain: row['linked_domain']?.trim() ?? '',
      linkedId: row['linked_id']?.trim() ?? '',
      project: row['project']?.trim() ?? '',
      status: row['status']?.trim() ?? '',
      dateAdded: row['date_added']?.trim() ?? '',
      notes: row['notes']?.trim() ?? '',
    );
  }

  Future<int> _countInboxFiles(Directory inboxDirectory) async {
    if (!await inboxDirectory.exists()) {
      return 0;
    }

    var count = 0;
    await for (final entity in inboxDirectory.list(
      recursive: false,
      followLinks: false,
    )) {
      if (entity is File) {
        count += 1;
      }
    }

    return count;
  }

  String _dateStamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }
}
