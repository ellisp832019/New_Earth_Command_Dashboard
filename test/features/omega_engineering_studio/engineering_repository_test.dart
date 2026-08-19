import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/application/engineering_services.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_database.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';

void main() {
  group('LocalEngineeringRepository', () {
    test('loads seeded engineering data', () async {
      final database = EngineeringLocalDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LocalEngineeringRepository(
        moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
        database: database,
      );

      final snapshot = await repository.loadSnapshot();

      expect(snapshot.projectCount, greaterThanOrEqualTo(5));
      expect(snapshot.circuitBlocks, isNotEmpty);
      expect(snapshot.pcbRevisions, isNotEmpty);
      expect(snapshot.firmwareBuilds, isNotEmpty);
      expect(snapshot.deviceNodes, isNotEmpty);
      expect(snapshot.componentItems, isNotEmpty);
      expect(snapshot.documents, isNotEmpty);
    });

    test(
      'persists user-authored updates across reopen with preserved fields',
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'omega_engineering_repository_update_test_',
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
        final snapshot = await firstRepository.loadSnapshot();
        final firstProject = snapshot.projects.first;
        final updatedProject = EngineeringProject(
          id: firstProject.id,
          title: 'MicroGrow Retuned',
          summary: firstProject.summary,
          status: firstProject.status,
          priority: firstProject.priority,
          progressPercent: firstProject.progressPercent,
          milestone: firstProject.milestone,
          nextAction: firstProject.nextAction,
          system: firstProject.system,
          updatedAt: firstProject.updatedAt,
          openTaskCount: firstProject.openTaskCount,
          blockedTaskCount: firstProject.blockedTaskCount,
          tags: firstProject.tags,
          targetDate: firstProject.targetDate,
        );

        await firstRepository.saveSnapshot(
          snapshot.copyWith(
            projects: [updatedProject, ...snapshot.projects.skip(1)],
          ),
        );

        final secondRepository = await openRepository();
        final reloaded = await secondRepository.loadSnapshot();
        final reloadedProject = reloaded.projects.first;

        expect(reloaded.projectCount, snapshot.projectCount);
        expect(reloadedProject.title, 'MicroGrow Retuned');
        expect(reloadedProject.summary, firstProject.summary);
        expect(reloadedProject.system, firstProject.system);
      },
    );

    test(
      'exports a valid engineering snapshot without mutating repository state',
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'omega_engineering_repository_export_test_',
        );
        addTearDown(() {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });

        final dbFile = File(path.join(tempDir.path, 'engineering.db'));
        final exportFile = File(path.join(tempDir.path, 'export.json'));

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

        final repository = await openRepository();
        final before = await repository.loadSnapshot();

        await repository.exportSnapshot(exportFile);

        final after = await repository.loadSnapshot();
        final exported =
            jsonDecode(await exportFile.readAsString()) as Map<String, dynamic>;
        final snapshot = exported['snapshot'] as Map<String, dynamic>;
        final exportedProjects = snapshot['projects'] as List<dynamic>;

        expect(identical(after, before), isTrue);
        expect(exportedProjects, isNotEmpty);
        expect(
          (exportedProjects.first as Map<String, dynamic>)['title'],
          before.projects.first.title,
        );
        expect(exported['exportedAt'], isNotNull);
      },
    );

    test(
      'imports a valid engineering snapshot and preserves imported fields on reload',
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'omega_engineering_repository_import_test_',
        );
        addTearDown(() {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });

        final dbFile = File(path.join(tempDir.path, 'engineering.db'));
        final importFile = File(path.join(tempDir.path, 'import.json'));

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

        final repository = await openRepository();
        final before = await repository.loadSnapshot();
        await repository.exportSnapshot(importFile);

        final exported =
            jsonDecode(await importFile.readAsString()) as Map<String, dynamic>;
        final snapshot = Map<String, dynamic>.from(
          exported['snapshot'] as Map<String, dynamic>,
        );
        final projects = List<Map<String, dynamic>>.from(
          snapshot['projects'] as List<dynamic>,
        );
        projects[0] = <String, dynamic>{
          ...projects[0],
          'title': 'Imported MicroGrow',
        };
        snapshot['projects'] = projects;
        await importFile.writeAsString(
          jsonEncode(<String, dynamic>{
            'exportedAt': exported['exportedAt'],
            'snapshot': snapshot,
          }),
        );

        final imported = await repository.importSnapshot(importFile);
        final reloaded = await openRepository().then(
          (repo) => repo.loadSnapshot(),
        );

        expect(imported.projects.first.title, 'Imported MicroGrow');
        expect(reloaded.projects.first.title, 'Imported MicroGrow');
        expect(reloaded.projects.first.summary, before.projects.first.summary);
        expect(reloaded.projects.first.system, before.projects.first.system);
      },
    );

    test('importSnapshot rejects invalid JSON and missing files', () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'omega_engineering_repository_import_invalid_test_',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final dbFile = File(path.join(tempDir.path, 'engineering.db'));
      final invalidJsonFile = File(path.join(tempDir.path, 'invalid.json'));
      final missingFile = File(path.join(tempDir.path, 'missing.json'));

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

      final repository = await openRepository();
      await invalidJsonFile.writeAsString('not valid json');

      await expectLater(
        repository.importSnapshot(invalidJsonFile),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        repository.importSnapshot(missingFile),
        throwsA(isA<FileSystemException>()),
      );
    });

    test(
      'keeps cached snapshot stale until reload and falls back from corrupted persisted JSON',
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'omega_engineering_repository_cache_test_',
        );
        addTearDown(() {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });

        final dbFile = File(path.join(tempDir.path, 'engineering.db'));
        final database = EngineeringLocalDatabase(
          NativeDatabase.createInBackground(dbFile),
        );
        addTearDown(database.close);

        final repository = LocalEngineeringRepository(
          moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
          database: database,
        );

        final initial = await repository.loadSnapshot();
        await database
            .into(database.engineeringSnapshotRecords)
            .insertOnConflictUpdate(
              EngineeringSnapshotRecordsCompanion.insert(
                snapshotId: 'default',
                payload: '{not valid json}',
                updatedAt: DateTime.utc(2026, 8, 19, 9, 0, 0),
              ),
            );

        final cached = await repository.loadSnapshot();
        final freshRepository = LocalEngineeringRepository(
          moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
          database: database,
        );
        final fallback = await freshRepository.loadSnapshot();

        expect(identical(cached, initial), isTrue);
        expect(cached.projects.first.title, initial.projects.first.title);
        expect(fallback.projectCount, initial.projectCount);
        expect(fallback.projects.first.title, initial.projects.first.title);
      },
    );

    test('searches across the engineering workspace', () async {
      final database = EngineeringLocalDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LocalEngineeringRepository(
        moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
        database: database,
      );
      final snapshot = await repository.loadSnapshot();
      final search = EngineeringSearchService(snapshot);

      final hits = search.search('MicroGrow');

      expect(hits, isNotEmpty);
      expect(hits.any((hit) => hit.title.contains('MicroGrow')), isTrue);
    });

    test('filters low stock components', () async {
      final database = EngineeringLocalDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LocalEngineeringRepository(
        moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
        database: database,
      );
      final snapshot = await repository.loadSnapshot();
      final service = ComponentInventoryService(snapshot);

      final components = service.components(status: 'Blocked');

      expect(components, isNotEmpty);
      expect(components.any((component) => component.isLowStock), isTrue);
    });
  });
}
