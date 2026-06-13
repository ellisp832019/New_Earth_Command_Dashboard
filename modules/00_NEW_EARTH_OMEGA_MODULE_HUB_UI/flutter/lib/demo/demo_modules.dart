import '../core/dock/dock_position.dart';
import '../core/modules/module_manifest.dart';
import '../core/modules/module_permission.dart';
import '../core/modules/module_status.dart';

class DemoModules {
  static const List<ModuleManifest> all = [
ModuleManifest(
      id: 'newearth.ai_assistant_dock',
      name: 'AI Assistant Dock',
      version: '0.1.0',
      category: 'AI & Automation',
      description: 'Local J.A.R.V.I.S-style dock for voice, local LLM, automation and hands-free control.',
      status: ModuleStatus.proposed,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.right,
      omegaOsPath: 'OMEGA_OS/MODULES/AI_ASSISTANT_DOCK',
      permissions: [
        ModulePermission(key: 'microphone', label: 'Microphone'),
        ModulePermission(key: 'speaker', label: 'Speaker'),
        ModulePermission(key: 'screen_capture', label: 'Screen capture'),
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'file_write_project_only', label: 'Project-only file write'),
        ModulePermission(key: 'browser_control', label: 'Browser control'),
        ModulePermission(key: 'app_launch', label: 'App launch'),
        ModulePermission(key: 'shell_commands_approval', label: 'Shell commands with approval'),
        ModulePermission(key: 'keyboard_mouse_approval', label: 'Keyboard/mouse with approval'),
        ModulePermission(key: 'local_network', label: 'Local network'),
        ModulePermission(key: 'internet_access_optional', label: 'Optional internet access')
      ],
    ),
ModuleManifest(
      id: 'newearth.alexa_voice_gateway',
      name: 'Alexa Voice Gateway',
      version: '0.1.0',
      category: 'Voice & Hardware',
      description: 'Secure bridge for using existing Alexa hardware as a gated voice trigger into the dashboard.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.right,
      omegaOsPath: 'OMEGA_OS/MODULES/ALEXA_VOICE_GATEWAY',
      permissions: [
        ModulePermission(key: 'voice_trigger', label: 'Voice trigger'),
        ModulePermission(key: 'local_api_access', label: 'Local API access'),
        ModulePermission(key: 'network_access', label: 'Network access'),
        ModulePermission(key: 'audit_log', label: 'Audit log')
      ],
    ),
ModuleManifest(
      id: 'newearth.obsidian_sync',
      name: 'Obsidian Sync',
      version: '0.1.0',
      category: 'Knowledge & Research',
      description: 'Connects project folders and Omega OS records into an Obsidian vault workflow.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.bottom,
      omegaOsPath: 'OMEGA_OS/MODULES/OBSIDIAN_SYNC',
      permissions: [
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'file_write_project_only', label: 'Project-only file write'),
        ModulePermission(key: 'vault_access', label: 'Obsidian vault access'),
        ModulePermission(key: 'scheduled_sync', label: 'Scheduled sync')
      ],
    ),
ModuleManifest(
      id: 'newearth.repo_research_engine',
      name: 'Repo Research Engine',
      version: '0.1.0',
      category: 'Knowledge & Research',
      description: 'Scans repositories, extracts context, indexes docs and creates research-ready knowledge packs.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.bottom,
      omegaOsPath: 'OMEGA_OS/MODULES/REPO_RESEARCH_ENGINE',
      permissions: [
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'repo_access', label: 'Repository access'),
        ModulePermission(key: 'knowledge_export', label: 'Knowledge export'),
        ModulePermission(key: 'local_index', label: 'Local index')
      ],
    ),
ModuleManifest(
      id: 'newearth.grants_tracker',
      name: 'Grants Tracker',
      version: '0.1.0',
      category: 'Project Management',
      description: 'Tracks innovation grants, applications, deadlines, evidence packs and Omega OS exports.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.left,
      omegaOsPath: 'OMEGA_OS/MODULES/GRANTS_TRACKER',
      permissions: [
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'file_write_project_only', label: 'Project-only file write'),
        ModulePermission(key: 'calendar_optional', label: 'Optional calendar access'),
        ModulePermission(key: 'web_search_optional', label: 'Optional web search')
      ],
    ),
ModuleManifest(
      id: 'newearth.backup_system',
      name: 'Backup System',
      version: '0.1.0',
      category: 'Backup & Recovery',
      description: 'Daily/weekly backup command centre with restore points, logs and target checks.',
      status: ModuleStatus.installed,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.bottom,
      omegaOsPath: 'OMEGA_OS/MODULES/BACKUP_SYSTEM',
      permissions: [
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'file_write_backup_target', label: 'Backup target write'),
        ModulePermission(key: 'scheduled_tasks', label: 'Scheduled tasks'),
        ModulePermission(key: 'system_health', label: 'System health')
      ],
    ),
ModuleManifest(
      id: 'newearth.microgrow_control',
      name: 'MicroGrow Control',
      version: '0.1.0',
      category: 'MicroGrow',
      description: 'Dashboard control and diagnostics shell for MicroGrow nodes, sensors, relays and firmware status.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.right,
      omegaOsPath: 'OMEGA_OS/MODULES/MICROGROW_CONTROL',
      permissions: [
        ModulePermission(key: 'local_network', label: 'Local network'),
        ModulePermission(key: 'device_control', label: 'Device control'),
        ModulePermission(key: 'firmware_status', label: 'Firmware status'),
        ModulePermission(key: 'audit_log', label: 'Audit log')
      ],
    ),
ModuleManifest(
      id: 'newearth.xr_workspace',
      name: 'XR Workspace',
      version: '0.1.0',
      category: 'XR & Visual Systems',
      description: 'Visual workspace hub for VR development, Quest setup, asset packs and immersive dashboards.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.left,
      omegaOsPath: 'OMEGA_OS/MODULES/XR_WORKSPACE',
      permissions: [
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'asset_library', label: 'Asset library'),
        ModulePermission(key: 'device_notes', label: 'Device notes')
      ],
    ),
ModuleManifest(
      id: 'newearth.finance_treasury',
      name: 'Finance & Treasury',
      version: '0.1.0',
      category: 'Finance & Treasury',
      description: 'Omega OS finance and treasury module linked to the locked finance folder path.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.left,
      omegaOsPath: 'OMEGA_OS/MODULES/FINANCE_&_TREASURY',
      permissions: [
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'file_write_project_only', label: 'Project-only file write'),
        ModulePermission(key: 'finance_records', label: 'Finance records'),
        ModulePermission(key: 'audit_log', label: 'Audit log')
      ],
    ),
ModuleManifest(
      id: 'newearth.project_command_centre',
      name: 'Project Command Centre',
      version: '0.1.0',
      category: 'Project Management',
      description: 'Unified hub for active projects, build phases, task lists and decision logs.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.left,
      omegaOsPath: 'OMEGA_OS/MODULES/PROJECT_COMMAND_CENTRE',
      permissions: [
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'file_write_project_only', label: 'Project-only file write'),
        ModulePermission(key: 'dashboard_context', label: 'Dashboard context')
      ],
    ),
ModuleManifest(
      id: 'newearth.visual_asset_index',
      name: 'Visual Asset Index',
      version: '0.1.0',
      category: 'XR & Visual Systems',
      description: 'Indexes images, prompts, diagrams, visual packs and dashboard design references.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.bottom,
      omegaOsPath: 'OMEGA_OS/MODULES/VISUAL_ASSET_INDEX',
      permissions: [
        ModulePermission(key: 'file_read', label: 'File read'),
        ModulePermission(key: 'asset_library', label: 'Asset library'),
        ModulePermission(key: 'metadata_write', label: 'Metadata write')
      ],
    ),
ModuleManifest(
      id: 'newearth.local_ai_runtime',
      name: 'Local AI Runtime',
      version: '0.1.0',
      category: 'AI & Automation',
      description: 'Ollama/local model runtime monitor for local-first AI services and model profiles.',
      status: ModuleStatus.disabled,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.right,
      omegaOsPath: 'OMEGA_OS/MODULES/LOCAL_AI_RUNTIME',
      permissions: [
        ModulePermission(key: 'local_network', label: 'Local network'),
        ModulePermission(key: 'model_registry', label: 'Model registry'),
        ModulePermission(key: 'system_health', label: 'System health')
      ],
    )
  ];
}
