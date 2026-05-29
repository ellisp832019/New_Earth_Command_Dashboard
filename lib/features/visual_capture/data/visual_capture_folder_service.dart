import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../core/constants/omega_os_folder_registry.dart';
import '../../../core/utils/folder_bootstrap_result.dart';

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
    : _workingDirectory = workingDirectory ?? Directory.current;

  static const _configRelativePath = 'config/local_paths.json';
  static const _visualCaptureRootKey = 'visual_capture_path';

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
}
