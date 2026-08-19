import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_database.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';

void main() {
  test('persists the engineering snapshot across database reopen', () async {
    final tempDir = Directory.systemTemp.createTempSync(
      'omega_engineering_database_test_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final dbFile = File(path.join(tempDir.path, 'engineering.db'));

    Future<LocalEngineeringRepository> openRepository() async {
      final database = EngineeringLocalDatabase(
        NativeDatabase.createInBackground(dbFile),
      );
      addTearDown(database.close);
      return LocalEngineeringRepository(
        moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
        database: database,
      );
    }

    final firstRepository = await openRepository();
    final firstSnapshot = await firstRepository.loadSnapshot();
    await firstRepository.createProject(
      title: 'Migration Check',
      summary: 'Persisted during a database reopen test.',
      status: 'Active',
      priority: 'Medium',
      progressPercent: 42,
      milestone: 'Confirm persistence',
      nextAction: 'Reopen the database file.',
      system: 'Omega Dashboard',
      tags: const ['migration', 'persistence'],
    );

    final secondRepository = await openRepository();
    final secondSnapshot = await secondRepository.loadSnapshot();

    expect(firstSnapshot.projectCount, greaterThan(0));
    expect(
      secondSnapshot.projects.any(
        (project) => project.title == 'Migration Check',
      ),
      isTrue,
    );
    expect(secondSnapshot.attachmentCount, greaterThan(0));
  });

  test(
    'resetLocalState clears the singleton row and bootstrap restores the seeded snapshot',
    () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'omega_engineering_database_reset_test_',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final dbFile = File(path.join(tempDir.path, 'engineering.db'));
      late final EngineeringLocalDatabase database;

      Future<LocalEngineeringRepository> openRepository() async {
        database = EngineeringLocalDatabase(
          NativeDatabase.createInBackground(dbFile),
        );
        addTearDown(database.close);
        return LocalEngineeringRepository(
          moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
          database: database,
        );
      }

      final repository = await openRepository();

      final initial = await repository.loadSnapshot();
      expect(
        await database.select(database.engineeringSnapshotRecords).get(),
        hasLength(1),
      );

      await repository.resetLocalState();

      expect(
        await database.select(database.engineeringSnapshotRecords).get(),
        isEmpty,
      );

      final reloaded = await repository.loadSnapshot();
      expect(reloaded.projectCount, initial.projectCount);
      expect(reloaded.projects.first.title, initial.projects.first.title);
      expect(
        await database.select(database.engineeringSnapshotRecords).get(),
        hasLength(1),
      );
    },
  );
}
