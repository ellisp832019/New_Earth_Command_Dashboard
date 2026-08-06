import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/education_learning_hub/presentation/education_learning_hub_screen.dart';

void main() {
  testWidgets('education learning hub shows the calm tab shell', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: RouteNames.educationLearningHub,
      routes: [
        GoRoute(
          path: RouteNames.educationLearningHub,
          builder: (context, state) => const EducationLearningHubScreen(),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Education & Learning Hub'), findsWidgets);
    expect(find.text('Education Dashboard'), findsWidgets);
    expect(find.text('Learning Pathways'), findsWidgets);
    expect(find.text('Lesson Library'), findsWidgets);
    expect(find.text('AI Tutor'), findsWidgets);
    expect(find.text('Reports'), findsWidgets);
    expect(find.text('Community / Classroom Mode'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Knowledge Engine'), findsWidgets);
    expect(find.text('GAIA placeholder'), findsWidgets);
    expect(find.text('Role view'), findsWidgets);
    expect(find.text('Badge readiness'), findsWidgets);

    await tester.tap(find.text('Learning Pathways').last);
    await tester.pumpAndSettle();
    expect(find.text('Learning Pathways'), findsWidgets);

    await tester.tap(find.text('Lesson Library').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Open lesson').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open lesson').first);
    await tester.pumpAndSettle();
    expect(find.text('Lesson steps'), findsWidgets);
    expect(find.text('Reflection prompt'), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Mentor Workspace').last);
    await tester.tap(find.text('Mentor Workspace').last);
    await tester.pumpAndSettle();
    expect(find.text('Review workflow'), findsWidgets);
    expect(find.text('Mentor review log'), findsWidgets);
    expect(find.text('Review presets'), findsWidgets);
    expect(find.text('Moderation note'), findsWidgets);

    await tester.ensureVisible(find.text('Assessments').last);
    await tester.tap(find.text('Assessments').last);
    await tester.pumpAndSettle();
    expect(find.text('Score breakdown'), findsWidgets);

    await tester.ensureVisible(find.text('Student Progress').last);
    await tester.tap(find.text('Student Progress').last);
    await tester.pumpAndSettle();
    expect(find.text('Learner score breakdown'), findsWidgets);

    await tester.ensureVisible(find.text('Settings').last);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Latest manifest'), findsWidgets);
  });
}
