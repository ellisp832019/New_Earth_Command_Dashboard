import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../services/seed_data_service.dart';
import '../services/daily_plan_service.dart';
import 'tables/app_settings_table.dart';
import 'tables/business_opportunities_table.dart';
import 'tables/content_items_table.dart';
import 'tables/daily_plans_table.dart';
import 'tables/inbox_items_table.dart';
import 'tables/journal_entries_table.dart';
import 'tables/learning_items_table.dart';
import 'tables/projects_table.dart';
import 'tables/users_devices_control_access_rules_table.dart';
import 'tables/users_devices_control_approvals_table.dart';
import 'tables/users_devices_control_audit_events_table.dart';
import 'tables/users_devices_control_devices_table.dart';
import 'tables/users_devices_control_permissions_table.dart';
import 'tables/users_devices_control_roles_table.dart';
import 'tables/users_devices_control_users_table.dart';
import 'tables/users_devices_control_trust_levels_table.dart';
import 'tables/tasks_table.dart';
import 'tables/wellbeing_checkins_table.dart';
import 'tables/voice_audit_logs_table.dart';
import 'tables/voice_conversation_threads_table.dart';
import 'tables/voice_module_preferences_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Projects,
    Tasks,
    DailyPlans,
    JournalEntries,
    LearningItems,
    ContentItems,
    BusinessOpportunities,
    WellbeingCheckins,
    InboxItems,
    AppSettings,
    UsersDevicesControlUsers,
    UsersDevicesControlDevices,
    UsersDevicesControlApprovalRequests,
    UsersDevicesControlAuditEvents,
    UsersDevicesControlRoles,
    UsersDevicesControlPermissions,
    UsersDevicesControlTrustLevels,
    UsersDevicesControlAccessRules,
    VoiceAuditLogs,
    VoiceConversationThreads,
    VoiceModulePreferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (migrator) async {
          await migrator.createAll();
          await migrator.database.customStatement('''
            CREATE TABLE IF NOT EXISTS users_devices_control_pin_records (
              pin_id TEXT PRIMARY KEY NOT NULL,
              user_id TEXT NOT NULL,
              label TEXT NOT NULL,
              pin_code TEXT NOT NULL,
              status TEXT NOT NULL,
              source_label TEXT NOT NULL,
              notes TEXT NOT NULL DEFAULT '',
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await migrator.database.customStatement('''
            CREATE TABLE IF NOT EXISTS users_devices_control_pin_lockouts (
              user_id TEXT PRIMARY KEY NOT NULL,
              failed_attempts INTEGER NOT NULL DEFAULT 0,
              locked_until TEXT,
              last_failed_at TEXT,
              updated_at TEXT NOT NULL
            )
          ''');
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'voice_replies_enabled',
              appSettings.voiceRepliesEnabled,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'voice_assistant_enabled',
              appSettings.voiceAssistantEnabled,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'preferred_tts_voice_name',
              appSettings.preferredTtsVoiceName,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'preferred_tts_voice_locale',
              appSettings.preferredTtsVoiceLocale,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'preferred_tts_voice_gender',
              appSettings.preferredTtsVoiceGender,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'preferred_tts_voice_identifier',
              appSettings.preferredTtsVoiceIdentifier,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'preferred_tts_voice_rate',
              appSettings.preferredTtsVoiceRate,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'preferred_tts_voice_pitch',
              appSettings.preferredTtsVoicePitch,
            );
          }

          if (from < 13) {
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'voice_startup_gate_enabled',
              appSettings.voiceStartupGateEnabled,
            );
          }

          if (from < 14) {
            await migrator.database.customStatement('''
              CREATE TABLE IF NOT EXISTS users_devices_control_pin_records (
                pin_id TEXT PRIMARY KEY NOT NULL,
                user_id TEXT NOT NULL,
                label TEXT NOT NULL,
                pin_code TEXT NOT NULL,
                status TEXT NOT NULL,
                source_label TEXT NOT NULL,
                notes TEXT NOT NULL DEFAULT '',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');
          }

          if (from < 15) {
            await migrator.database.customStatement('''
              CREATE TABLE IF NOT EXISTS users_devices_control_pin_lockouts (
                user_id TEXT PRIMARY KEY NOT NULL,
                failed_attempts INTEGER NOT NULL DEFAULT 0,
                locked_until TEXT,
                last_failed_at TEXT,
                updated_at TEXT NOT NULL
              )
            ''');
          }

          if (from < 4) {
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'show_projects_workspace_snapshot',
              appSettings.showProjectsWorkspaceSnapshot,
            );
          }

          if (from < 5) {
            await migrator.createTable(voiceConversationThreads);
          }

          if (from < 6) {
            await migrator.createTable(voiceAuditLogs);
          }

          if (from < 7) {
            await migrator.createTable(voiceModulePreferences);
          }

          if (from < 8) {
            await _createTableIfMissing(
              migrator,
              usersDevicesControlUsers,
              'users_devices_control_users',
            );
            await _createTableIfMissing(
              migrator,
              usersDevicesControlDevices,
              'users_devices_control_devices',
            );
            await _createTableIfMissing(
              migrator,
              usersDevicesControlApprovalRequests,
              'users_devices_control_approval_requests',
            );
            await _createTableIfMissing(
              migrator,
              usersDevicesControlAuditEvents,
              'users_devices_control_audit_events',
            );
          }

          if (from < 9) {
            await _createTableIfMissing(
              migrator,
              usersDevicesControlRoles,
              'users_devices_control_roles',
            );
            await _createTableIfMissing(
              migrator,
              usersDevicesControlPermissions,
              'users_devices_control_permissions',
            );
            await _createTableIfMissing(
              migrator,
              usersDevicesControlTrustLevels,
              'users_devices_control_trust_levels',
            );
            await _createTableIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'users_devices_control_access_rules',
            );
          }

          if (from < 10) {
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlRoles,
              'permissions_json',
              usersDevicesControlRoles.permissionsJson,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlPermissions,
              'description',
              usersDevicesControlPermissions.description,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlTrustLevels,
              'name',
              usersDevicesControlTrustLevels.name,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlTrustLevels,
              'description',
              usersDevicesControlTrustLevels.description,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'view_permission',
              usersDevicesControlAccessRules.viewPermission,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'edit_permission',
              usersDevicesControlAccessRules.editPermission,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'admin_permission',
              usersDevicesControlAccessRules.adminPermission,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'request_permission',
              usersDevicesControlAccessRules.requestPermission,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'execute_permission',
              usersDevicesControlAccessRules.executePermission,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'control_permission',
              usersDevicesControlAccessRules.controlPermission,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'requires_trust_level',
              usersDevicesControlAccessRules.requiresTrustLevel,
            );
            await _addColumnIfMissing(
              migrator,
              usersDevicesControlAccessRules,
              'requires_approval_for_json',
              usersDevicesControlAccessRules.requiresApprovalForJson,
            );
          }

          if (from < 11) {
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'show_dock_overlays',
              appSettings.showDockOverlays,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'show_backup_guardian_dock',
              appSettings.showBackupGuardianDock,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'show_treasury_dock',
              appSettings.showTreasuryDock,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'show_knowledge_library_dock',
              appSettings.showKnowledgeLibraryDock,
            );
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'show_voice_conversation_dock',
              appSettings.showVoiceConversationDock,
            );
          }

          if (from < 12) {
            await _addColumnIfMissing(
              migrator,
              appSettings,
              'show_voice_presence_chip',
              appSettings.showVoicePresenceChip,
            );
          }
        },
      );
}

Future<void> _createTableIfMissing(
  Migrator migrator,
  TableInfo table,
  String tableName,
) async {
  if (await _tableExists(migrator, tableName)) {
    return;
  }
  await migrator.createTable(table);
}

Future<void> _addColumnIfMissing(
  Migrator migrator,
  TableInfo table,
  String columnName,
  dynamic column,
) async {
  if (await _columnExists(migrator, table.actualTableName, columnName)) {
    return;
  }
  await migrator.addColumn(table, column as dynamic);
}

Future<bool> _tableExists(Migrator migrator, String tableName) async {
  final result = await migrator.database.customSelect(
    "SELECT 1 AS found FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1",
    variables: [Variable<String>(tableName)],
  ).getSingleOrNull();
  return result != null;
}

Future<bool> _columnExists(
  Migrator migrator,
  String tableName,
  String columnName,
) async {
  final rows = await migrator.database.customSelect(
    'PRAGMA table_info($tableName)',
  ).get();
  for (final row in rows) {
    if (row.read<String>('name') == columnName) {
      return true;
    }
  }
  return false;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      path.join(directory.path, 'new_earth_command_dashboard.db'),
    );

    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final databaseReadyProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  await database.customSelect('SELECT 1').getSingle();
  await SeedDataService(database).ensureSeedData();
  await DailyPlanService(database).ensureTodayPlan();
});
