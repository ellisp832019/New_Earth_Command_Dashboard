import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/about_help/data/about_help_repository.dart';
import 'package:new_earth_command_dashboard/features/about_help/presentation/about_help_screen.dart';

void main() {
  testWidgets('about help screen shows cards, preview, and folder entries', (
    tester,
  ) async {
    final tempRoot = Directory.systemTemp.createTempSync('about-help-');
    final aboutHelpRoot = Directory(path.join(tempRoot.path, 'ABOUT_AND_HELP'))
      ..createSync(recursive: true);

    File(path.join(aboutHelpRoot.path, '00_OVERVIEW.md')).writeAsStringSync(
      '# About the Dashboard\n\nThis is the dashboard overview.',
    );
    File(path.join(aboutHelpRoot.path, '99_INDEX', 'WHERE_DOES_THIS_BELONG.md'))
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '# Where Does This Belong?\n\nUse this helper to keep files tidy.',
      );
    final moduleDirectory = Directory(
      path.join(aboutHelpRoot.path, '04_MODULE_DIRECTORY'),
    )..createSync(recursive: true);
    File(path.join(moduleDirectory.path, '00_MODULE_DIRECTORY_INDEX.md'))
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '# Module Directory Index\n\nBrowse all module profile markdown files.',
      );
    File(path.join(moduleDirectory.path, 'PROJECT_COMMAND_CENTRE_MODULE.md'))
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '# PROJECT_COMMAND_CENTRE_MODULE\n\nCentral management of projects.',
      );

    await tester.pumpWidget(
      MaterialApp(
        home: AboutHelpScreen(
          repository: AboutHelpRepository(workingDirectory: tempRoot),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('About & Help Centre'), findsOneWidget);
    expect(find.text('About the Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Module Directory'), findsOneWidget);
    expect(find.text('Where Does This Belong?'), findsOneWidget);
  });
}
