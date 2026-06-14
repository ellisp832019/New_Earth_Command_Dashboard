import '../dock/dock_position.dart';
import 'module_category.dart';
import 'module_health.dart';
import 'module_manifest.dart';
import 'module_permissions.dart';
import 'module_status.dart';

class ModuleManifestParser {
  const ModuleManifestParser();

  ModuleManifest parse(
    Map<String, dynamic> data, {
    required String installPath,
    required String folderName,
  }) {
    final moduleId = _string(data, const [
      'id',
      'module_id',
    ], fallback: folderName);
    final categoryValue = _string(data, const [
      'category',
    ], fallback: _inferCategoryLabel(folderName));
    final rawStatus = _string(data, const ['status'], fallback: 'installed');
    final backend = _map(data['backend']);
    final omegaOsPath = _string(data, const [
      'omegaOsPath',
      'omega_os_path',
      'omega_os_source_path',
    ], fallback: 'OMEGA_OS/MODULES/${_screamingSnake(folderName)}');
    final permissions = _parsePermissions(data['permissions']);
    final status = _parseStatus(rawStatus, backend);
    final enabled = _bool(
      data,
      const ['enabled'],
      fallback:
          status == ModuleStatus.enabled || status == ModuleStatus.installed,
    );
    final dockable = _bool(data, const ['dockable'], fallback: true);

    return ModuleManifest(
      id: moduleId,
      name: _string(data, const [
        'name',
        'module_name',
      ], fallback: _humanize(folderName)),
      description: _string(data, const [
        'description',
        'purpose',
      ], fallback: 'Manifest discovered from $folderName.'),
      category: _parseCategory(categoryValue, folderName),
      version: _string(data, const ['version'], fallback: '0.1.0'),
      status: status,
      enabled: enabled,
      dockable: dockable,
      defaultDockPosition: _parseDockPosition(
        _string(data, const [
          'defaultDockPosition',
          'default_dock_position',
        ], fallback: 'right'),
      ),
      permissions: permissions,
      installPath: installPath,
      omegaOsPath: omegaOsPath,
      health: _parseHealth(data, status, backend),
      source: ModuleManifestSource.manifest,
      tags: _parseTags(data),
      notes: _buildNotes(data, backend),
    );
  }

  ModuleManifest infer({
    required String folderName,
    required String installPath,
  }) {
    return ModuleManifest(
      id: folderName,
      name: _humanize(folderName),
      description:
          'No module_manifest.json file exists yet. This entry was inferred from the folder.',
      category: _parseCategory(_inferCategoryLabel(folderName), folderName),
      version: '0.1.0',
      status: ModuleStatus.scaffold,
      enabled: false,
      dockable: true,
      defaultDockPosition: _inferDockPosition(folderName),
      permissions: const [],
      installPath: installPath,
      omegaOsPath: 'OMEGA_OS/MODULES/${_screamingSnake(folderName)}',
      health: const ModuleHealthSnapshot(
        state: ModuleHealthState.warning,
        lastCheckedLabel: 'Manifest missing',
        backendStatus: 'No manifest file found',
        errors: [],
        warnings: ['Placeholder created from folder structure.'],
        nextAction: 'Add module_manifest.json to formalise this module.',
      ),
      source: ModuleManifestSource.inferred,
      tags: const ['inferred', 'placeholder'],
      notes:
          'Generated because the module folder does not yet contain a manifest.',
    );
  }

  ModuleStatus _parseStatus(String rawStatus, Map<String, dynamic> backend) {
    switch (rawStatus.trim().toLowerCase()) {
      case 'installed':
        return ModuleStatus.installed;
      case 'scaffold_ready':
      case 'bridge_ready':
      case 'ready_for_build':
      case 'scaffold':
        return ModuleStatus.scaffold;
      case 'enabled':
      case 'running':
        return ModuleStatus.enabled;
      case 'disabled':
      case 'archived':
        return ModuleStatus.disabled;
      case 'needs_configuration':
      case 'needsconfiguration':
      case 'needs configuration':
        return ModuleStatus.needsConfiguration;
      case 'error':
      case 'warning':
        return ModuleStatus.error;
      case 'planned':
      case 'proposed':
        return ModuleStatus.planned;
      case 'experimental':
        return ModuleStatus.experimental;
      default:
        if (backend['implemented'] == false) {
          return ModuleStatus.needsConfiguration;
        }
        return ModuleStatus.installed;
    }
  }

  ModuleCategory _parseCategory(String rawCategory, String folderName) {
    switch (rawCategory.trim().toLowerCase()) {
      case 'ai & automation':
      case 'ai automation':
        return ModuleCategory.aiAutomation;
      case 'voice & hardware':
      case 'voice hardware':
        return ModuleCategory.voiceHardware;
      case 'knowledge & research':
      case 'knowledge research':
        return ModuleCategory.knowledgeResearch;
      case 'project management':
        return ModuleCategory.projectManagement;
      case 'grants funding':
      case 'grants & funding':
        return ModuleCategory.grantsFunding;
      case 'backup & recovery':
        return ModuleCategory.backupRecovery;
      case 'microgrow':
        return ModuleCategory.microGrow;
      case 'xr & visual systems':
      case 'xr visual systems':
        return ModuleCategory.xrVisualSystems;
      case 'finance & treasury':
      case 'finance treasury':
        return ModuleCategory.financeTreasury;
      case 'system core':
        return ModuleCategory.systemCore;
      case 'security':
        return ModuleCategory.security;
      case 'community & outreach':
      case 'community outreach':
        return ModuleCategory.communityOutreach;
      default:
        return _inferCategory(folderName);
    }
  }

  ModuleCategory _inferCategory(String folderName) {
    final lower = folderName.toLowerCase();
    if (lower.contains('voice') || lower.contains('alexa')) {
      return ModuleCategory.voiceHardware;
    }
    if (lower.contains('backup')) {
      return ModuleCategory.backupRecovery;
    }
    if (lower.contains('grant') || lower.contains('fund')) {
      return ModuleCategory.grantsFunding;
    }
    if (lower.contains('microgrow')) {
      return ModuleCategory.microGrow;
    }
    if (lower.contains('repo') || lower.contains('knowledge')) {
      return ModuleCategory.knowledgeResearch;
    }
    if (lower.contains('project') || lower.contains('meeting')) {
      return ModuleCategory.projectManagement;
    }
    if (lower.contains('finance') || lower.contains('treasury')) {
      return ModuleCategory.financeTreasury;
    }
    if (lower.contains('xr') || lower.contains('visual')) {
      return ModuleCategory.xrVisualSystems;
    }
    if (lower.contains('security')) {
      return ModuleCategory.security;
    }
    if (lower.contains('community') || lower.contains('launch')) {
      return ModuleCategory.communityOutreach;
    }
    return ModuleCategory.systemCore;
  }

  DockPosition _parseDockPosition(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'left':
        return DockPosition.left;
      case 'right':
        return DockPosition.right;
      case 'bottom':
        return DockPosition.bottom;
      case 'floating':
        return DockPosition.floating;
      case 'fullscreen':
        return DockPosition.fullscreen;
      default:
        return DockPosition.right;
    }
  }

  DockPosition _inferDockPosition(String folderName) {
    final lower = folderName.toLowerCase();
    if (lower.contains('backup') ||
        lower.contains('obsidian') ||
        lower.contains('repo')) {
      return DockPosition.bottom;
    }
    if (lower.contains('voice') ||
        lower.contains('alexa') ||
        lower.contains('assistant')) {
      return DockPosition.right;
    }
    if (lower.contains('launch') ||
        lower.contains('fund') ||
        lower.contains('project')) {
      return DockPosition.left;
    }
    return DockPosition.right;
  }

  ModuleHealthSnapshot _parseHealth(
    Map<String, dynamic> data,
    ModuleStatus status,
    Map<String, dynamic> backend,
  ) {
    final backendNotes = _string(backend, const ['notes'], fallback: '');
    final backendType = _string(backend, const ['type'], fallback: '');
    final backendImplemented = backend['implemented'];
    final warnings = <String>[
      if (backendImplemented == false) 'Backend is not implemented yet.',
      if (backendNotes.isNotEmpty) backendNotes,
      if (status == ModuleStatus.scaffold)
        'This module is a scaffold and still needs a manifest.',
      if (status == ModuleStatus.planned)
        'This module is roadmap-only and not yet surfaced in the app.',
      if (status == ModuleStatus.needsConfiguration)
        'This module needs configuration before it can be enabled.',
    ];

    return ModuleHealthSnapshot(
      state: switch (status) {
        ModuleStatus.enabled => ModuleHealthState.healthy,
        ModuleStatus.installed => ModuleHealthState.warning,
        ModuleStatus.disabled => ModuleHealthState.offline,
        ModuleStatus.needsConfiguration => ModuleHealthState.warning,
        ModuleStatus.error => ModuleHealthState.error,
        ModuleStatus.scaffold => ModuleHealthState.unknown,
        ModuleStatus.planned => ModuleHealthState.unknown,
        ModuleStatus.experimental => ModuleHealthState.degraded,
      },
      lastCheckedLabel: _string(data, const [
        'lastChecked',
        'last_checked',
      ], fallback: 'Placeholder: not checked'),
      backendStatus: backendType.isNotEmpty
          ? 'Backend type: $backendType'
          : backendImplemented == false
          ? 'Backend not implemented'
          : 'Backend status unknown',
      errors: const [],
      warnings: warnings,
      nextAction: status == ModuleStatus.enabled
          ? 'Keep monitoring for drift.'
          : 'Review configuration and local readiness.',
    );
  }

  List<ModulePermission> _parsePermissions(dynamic rawPermissions) {
    if (rawPermissions is! List) {
      return const [];
    }

    return rawPermissions
        .whereType<Object?>()
        .map((rawPermission) {
          if (rawPermission is Map<String, dynamic>) {
            final type = _parsePermissionType(
              _string(rawPermission, const [
                'type',
                'name',
                'id',
              ], fallback: ''),
            );
            return ModulePermission(
              type: type,
              state: _parsePermissionState(
                _string(rawPermission, const ['state'], fallback: 'disabled'),
              ),
              notes: _string(rawPermission, const [
                'notes',
                'description',
              ], fallback: ''),
            );
          }

          final rawText = rawPermission.toString();
          return ModulePermission(
            type: _parsePermissionType(rawText),
            state: ModulePermissionState.disabled,
            notes: rawText,
          );
        })
        .toList(growable: false);
  }

  ModulePermissionState _parsePermissionState(String rawState) {
    switch (rawState.trim().toLowerCase()) {
      case 'disabled':
        return ModulePermissionState.disabled;
      case 'ask every time':
      case 'ask_every_time':
      case 'askeverytime':
        return ModulePermissionState.askEveryTime;
      case 'allowed':
        return ModulePermissionState.allowed;
      default:
        return ModulePermissionState.disabled;
    }
  }

  ModulePermissionType _parsePermissionType(String rawPermission) {
    final normalized = rawPermission.trim().toLowerCase();
    switch (normalized) {
      case 'microphone':
      case 'voice_trigger':
        return ModulePermissionType.microphone;
      case 'speaker':
        return ModulePermissionType.speaker;
      case 'screen_capture':
      case 'screencapture':
        return ModulePermissionType.screenCapture;
      case 'file_read':
      case 'file read':
        return ModulePermissionType.fileRead;
      case 'file_write':
      case 'file write':
      case 'file_write_project_only':
      case 'file_write_backup_target':
      case 'metadata_write':
      case 'knowledge_export':
        return ModulePermissionType.fileWrite;
      case 'browser_control':
        return ModulePermissionType.browserControl;
      case 'app_launch':
        return ModulePermissionType.appLaunch;
      case 'shell_commands':
      case 'shell_commands_approval':
      case 'scheduled_tasks':
        return ModulePermissionType.shellCommands;
      case 'keyboard_mouse_approval':
      case 'mouse_keyboard_control':
      case 'device_control':
        return ModulePermissionType.mouseKeyboardControl;
      case 'local_network':
      case 'network_access':
        return ModulePermissionType.localNetwork;
      case 'internet_access':
      case 'internet_access_optional':
      case 'web_search_optional':
        return ModulePermissionType.internetAccess;
      case 'calendar_access':
      case 'calendar_optional':
        return ModulePermissionType.calendarAccess;
      case 'email_access':
        return ModulePermissionType.emailAccess;
      case 'contacts_access':
        return ModulePermissionType.contactsAccess;
      case 'repo_access':
      case 'repository access':
        return ModulePermissionType.repoAccess;
      case 'omega_os_access':
      case 'system_health':
      case 'audit_log':
      case 'dashboard_context':
      case 'firmware_status':
      case 'model_registry':
      case 'local_index':
      case 'vault_access':
      case 'local_api_access':
      case 'device_notes':
      case 'asset_library':
        return ModulePermissionType.omegaOsAccess;
      default:
        return ModulePermissionType.fileRead;
    }
  }

  List<String> _parseTags(Map<String, dynamic> data) {
    final rawTags = data['tags'];
    if (rawTags is List) {
      return rawTags
          .whereType<Object?>()
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false);
    }

    final projectsSupported = data['projects_supported'];
    if (projectsSupported is List) {
      return projectsSupported
          .whereType<Object?>()
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false);
    }

    return const [];
  }

  String _buildNotes(Map<String, dynamic> data, Map<String, dynamic> backend) {
    final notes = <String>[];
    final rawNotes = _string(data, const ['notes'], fallback: '');
    final backendNotes = _string(backend, const ['notes'], fallback: '');
    final owner = _string(data, const ['owner'], fallback: '');
    final created = _string(data, const ['created'], fallback: '');

    if (rawNotes.isNotEmpty) {
      notes.add(rawNotes);
    }
    if (backendNotes.isNotEmpty && backendNotes != rawNotes) {
      notes.add(backendNotes);
    }
    if (owner.isNotEmpty) {
      notes.add('Owner: $owner');
    }
    if (created.isNotEmpty) {
      notes.add('Created: $created');
    }

    return notes.join(' | ');
  }

  String _string(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return fallback;
  }

  bool _bool(
    Map<String, dynamic> data,
    List<String> keys, {
    required bool fallback,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value is bool) {
        return value;
      }
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true') {
          return true;
        }
        if (lower == 'false') {
          return false;
        }
      }
    }
    return fallback;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  String _humanize(String value) {
    return value
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAllMapped(
          RegExp(r'(?<=[a-z0-9])([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String _screamingSnake(String value) {
    final normalized = value
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (normalized.isEmpty) {
      return 'MODULE';
    }
    return normalized.toUpperCase();
  }

  String _inferCategoryLabel(String folderName) {
    return _inferCategory(folderName).label;
  }
}
