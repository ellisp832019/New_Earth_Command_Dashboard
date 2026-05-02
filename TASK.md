# TASK — Build New Earth Command Dashboard App Shell

## Goal

Create the initial Flutter app shell for the New Earth Command Dashboard.

## Source of Truth

Read this file first:

docs/fsd/new_earth_command_dashboard_fsd.md

Follow the FSD, but only implement the first app shell task. Do not build the database yet.

## Requirements

1. Use Flutter and Material 3.
2. Add a clean New Earth style theme.
3. Create bottom navigation with:
   - Dashboard
   - Projects
   - Tasks
   - Planner
   - More

4. Create placeholder screens:
   - DashboardScreen
   - ProjectsScreen
   - TasksScreen
   - PlannerScreen
   - MoreScreen
   - JournalScreen
   - LearningScreen
   - ContentScreen
   - BusinessScreen
   - WellbeingScreen
   - InboxScreen
   - SettingsScreen

5. The More screen must link to:
   - Journal
   - Learning
   - Content
   - Business
   - Wellbeing
   - Inbox
   - Settings

6. Dashboard screen should show placeholder cards for:
   - Today’s Focus
   - Top 3 Tasks
   - Active Projects
   - Learning Focus
   - Content Focus
   - Business Reminder
   - Wellbeing
   - Quick Capture
   - Evening Review

7. Use a feature-based folder structure:
   - core/
   - features/dashboard/
   - features/projects/
   - features/tasks/
   - features/planner/
   - features/journal/
   - features/learning/
   - features/content/
   - features/business/
   - features/wellbeing/
   - features/inbox/
   - features/settings/

8. Use go_router for routing.
9. Use clear file names and clean structure.
10. Do not add database logic in this task.

## Expected Result

The app should launch to the Dashboard.

Bottom navigation should work.

The More screen should navigate to all supporting screens.

All screens can be placeholders but should have clear titles and descriptions.