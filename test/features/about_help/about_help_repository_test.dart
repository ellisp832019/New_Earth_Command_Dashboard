import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/about_help/data/about_help_repository.dart';

void main() {
  test('about help repository loads markdown and folder entries', () async {
    final tempRoot = Directory.systemTemp.createTempSync('about-help-repo-');
    final aboutHelpRoot = Directory(path.join(tempRoot.path, 'ABOUT_AND_HELP'))
      ..createSync(recursive: true);

    File(path.join(aboutHelpRoot.path, '00_OVERVIEW.md')).writeAsStringSync(
      '# About the Dashboard\n\nThis is the dashboard overview.',
    );
    final moduleDirectory = Directory(
      path.join(aboutHelpRoot.path, '04_MODULE_DIRECTORY'),
    )..createSync(recursive: true);
    File(path.join(moduleDirectory.path, '00_MODULE_DIRECTORY_INDEX.md'))
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '# Module Directory Index\n\nBrowse all module profile markdown files.',
      );

    final repository = AboutHelpRepository(workingDirectory: tempRoot);
    final sections = repository.loadSections();
    final overview = sections.firstWhere((section) => section.id == 'overview');
    final moduleDirectorySection = sections.firstWhere(
      (section) => section.id == 'module-directory',
    );

    final overviewSnapshot = await repository.loadSectionSnapshot(overview);
    final moduleDirectorySnapshot = await repository.loadSectionSnapshot(
      moduleDirectorySection,
    );

    expect(overviewSnapshot.hasMarkdown, isTrue);
    expect(
      overviewSnapshot.markdown,
      contains('This is the dashboard overview.'),
    );
    expect(moduleDirectorySnapshot.isFolder, isTrue);
    expect(moduleDirectorySnapshot.entries, isNotEmpty);
    expect(
      moduleDirectorySnapshot.entries.first.relativePath,
      contains('MODULE_DIRECTORY'),
    );
    expect(
      repository
          .sectionForRelativePath(
            'ABOUT_AND_HELP/04_MODULE_DIRECTORY/PROJECT_COMMAND_CENTRE_MODULE.md',
          )
          ?.id,
      'module-directory',
    );
    expect(
      RouteNames.aboutHelpSection(
        'module-directory',
        documentPath:
            'ABOUT_AND_HELP/04_MODULE_DIRECTORY/PROJECT_COMMAND_CENTRE_MODULE.md',
      ),
      allOf(
        contains('section=module-directory'),
        contains(
          'doc=ABOUT_AND_HELP%2F04_MODULE_DIRECTORY%2FPROJECT_COMMAND_CENTRE_MODULE.md',
        ),
      ),
    );
  });
}
