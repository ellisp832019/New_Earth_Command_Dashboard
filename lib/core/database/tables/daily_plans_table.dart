import 'package:drift/drift.dart';

class DailyPlans extends Table {
  TextColumn get dailyPlanId => text().named('daily_plan_id')();
  DateTimeColumn get date => dateTime().unique()();
  TextColumn get mainFocus => text().named('main_focus').nullable()();
  TextColumn get focusReason => text().named('focus_reason').nullable()();
  TextColumn get morningIntention =>
      text().named('morning_intention').nullable()();
  TextColumn get topTask1Id => text().named('top_task_1_id').nullable()();
  TextColumn get topTask2Id => text().named('top_task_2_id').nullable()();
  TextColumn get topTask3Id => text().named('top_task_3_id').nullable()();
  TextColumn get learningFocusId =>
      text().named('learning_focus_id').nullable()();
  TextColumn get contentFocusId =>
      text().named('content_focus_id').nullable()();
  TextColumn get businessFocusId =>
      text().named('business_focus_id').nullable()();
  TextColumn get wellbeingCheckinId =>
      text().named('wellbeing_checkin_id').nullable()();
  TextColumn get eveningReview => text().named('evening_review').nullable()();
  TextColumn get whatMovedForward =>
      text().named('what_moved_forward').nullable()();
  TextColumn get whatWasCompleted =>
      text().named('what_was_completed').nullable()();
  TextColumn get whatWasLearned =>
      text().named('what_was_learned').nullable()();
  TextColumn get blockers => text().nullable()();
  TextColumn get carryForwardNotes =>
      text().named('carry_forward_notes').nullable()();
  TextColumn get tomorrowFocus => text().named('tomorrow_focus').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {dailyPlanId};
}
