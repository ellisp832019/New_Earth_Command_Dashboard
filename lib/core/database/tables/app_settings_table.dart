import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get settingsId => text().named('settings_id')();
  TextColumn get themeMode =>
      text().named('theme_mode').withDefault(const Constant('System'))();
  TextColumn get defaultDashboardView =>
      text().named('default_dashboard_view').nullable()();
  BoolColumn get showWellbeingCard => boolean()
      .named('show_wellbeing_card')
      .withDefault(const Constant(true))();
  BoolColumn get showBusinessCard =>
      boolean().named('show_business_card').withDefault(const Constant(true))();
  BoolColumn get showLearningCard =>
      boolean().named('show_learning_card').withDefault(const Constant(true))();
  BoolColumn get showContentCard =>
      boolean().named('show_content_card').withDefault(const Constant(true))();
  BoolColumn get showProjectsWorkspaceSnapshot => boolean()
      .named('show_projects_workspace_snapshot')
      .withDefault(const Constant(true))();
  BoolColumn get showDockOverlays =>
      boolean().named('show_dock_overlays').withDefault(const Constant(true))();
  BoolColumn get showBackupGuardianDock => boolean()
      .named('show_backup_guardian_dock')
      .withDefault(const Constant(true))();
  BoolColumn get showTreasuryDock =>
      boolean().named('show_treasury_dock').withDefault(const Constant(true))();
  BoolColumn get showKnowledgeLibraryDock => boolean()
      .named('show_knowledge_library_dock')
      .withDefault(const Constant(true))();
  BoolColumn get showVoiceConversationDock => boolean()
      .named('show_voice_conversation_dock')
      .withDefault(const Constant(true))();
  BoolColumn get showVoicePresenceChip => boolean()
      .named('show_voice_presence_chip')
      .withDefault(const Constant(true))();
  IntColumn get dailyTopTaskLimit =>
      integer().named('daily_top_task_limit').withDefault(const Constant(3))();
  BoolColumn get voiceRepliesEnabled => boolean()
      .named('voice_replies_enabled')
      .withDefault(const Constant(true))();
  BoolColumn get voiceAssistantEnabled => boolean()
      .named('voice_assistant_enabled')
      .withDefault(const Constant(true))();
  BoolColumn get voiceStartupGateEnabled => boolean()
      .named('voice_startup_gate_enabled')
      .withDefault(const Constant(false))();
  TextColumn get preferredTtsVoiceName =>
      text().named('preferred_tts_voice_name').nullable()();
  TextColumn get preferredTtsVoiceLocale =>
      text().named('preferred_tts_voice_locale').nullable()();
  TextColumn get preferredTtsVoiceGender =>
      text().named('preferred_tts_voice_gender').nullable()();
  TextColumn get preferredTtsVoiceIdentifier =>
      text().named('preferred_tts_voice_identifier').nullable()();
  RealColumn get preferredTtsVoiceRate => real()
      .named('preferred_tts_voice_rate')
      .withDefault(const Constant(0.5))();
  RealColumn get preferredTtsVoicePitch => real()
      .named('preferred_tts_voice_pitch')
      .withDefault(const Constant(1.0))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {settingsId};
}
