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
  IntColumn get dailyTopTaskLimit =>
      integer().named('daily_top_task_limit').withDefault(const Constant(3))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {settingsId};
}
