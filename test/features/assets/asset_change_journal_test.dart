import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_change_journal.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';

void main() {
  test('asset change journal entry round trips through csv rows', () {
    final entry = AssetChangeJournalEntry(
      recordId: 'NE-EQ-0001',
      recordType: 'equipment',
      action: AssetChangeAction.update,
      timestamp: DateTime.utc(2026, 5, 28, 9, 30),
      machineId: 'HAYLEY-LAPTOP',
      userLabel: 'Hayley',
      changedFields: const {
        'status': 'broken',
        'location': 'Workbench B',
      },
      note: 'Moved for repair.',
    );

    final row = entry.toCsvRow();
    final parsed = AssetChangeJournalEntry.fromCsvRow(row);

    expect(AssetChangeJournalEntry.headers, hasLength(8));
    expect(row['record_id'], 'NE-EQ-0001');
    expect(row['action'], 'update');
    expect(parsed.recordId, entry.recordId);
    expect(parsed.recordType, entry.recordType);
    expect(parsed.action, entry.action);
    expect(parsed.timestamp.toUtc(), entry.timestamp.toUtc());
    expect(parsed.machineId, entry.machineId);
    expect(parsed.userLabel, entry.userLabel);
    expect(parsed.changedFields, entry.changedFields);
    expect(parsed.note, entry.note);
  });

  test('asset change journal entry tolerates invalid changed fields', () {
    final parsed = AssetChangeJournalEntry.fromCsvRow(
      const {
        'record_id': 'NE-PART-0001',
        'record_type': 'parts',
        'action': 'create',
        'timestamp': '2026-05-28T09:45:00Z',
        'machine_id': 'HAYLEY-LAPTOP',
        'user_label': 'Hayley',
        'changed_fields': 'not valid json',
        'note': '',
      },
    );

    expect(parsed.changedFields, isEmpty);
    expect(parsed.action, AssetChangeAction.create);
  });

  test('asset register repository appends and reads journal entries', () async {
    final tempRoot = await Directory.systemTemp.createTemp('asset-journal-test-');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final assetsRoot = Directory('${tempRoot.path}/18_ASSETS_EQUIPMENT_AND_PARTS');
    await assetsRoot.create(recursive: true);

    final repository = AssetRegisterRepository(workingDirectory: tempRoot);
    final entry = AssetChangeJournalEntry(
      recordId: 'NE-PART-0001',
      recordType: 'parts',
      action: AssetChangeAction.create,
      timestamp: DateTime.utc(2026, 5, 28, 10, 0),
      machineId: 'HAYLEY-LAPTOP',
      userLabel: 'Hayley',
      changedFields: const {
        'name': 'Cable ties',
        'quantity': '10',
      },
      note: 'Added after delivery.',
    );

    await repository.appendChangeJournalEntry(assetsRoot.path, entry);

    final table = await repository.readChangeJournal(assetsRoot.path);
    final parsed = table.rows.map(AssetChangeJournalEntry.fromCsvRow).toList();

    expect(parsed, hasLength(1));
    expect(parsed.single.recordId, 'NE-PART-0001');
    expect(parsed.single.changedFields['quantity'], '10');
    expect(parsed.single.note, 'Added after delivery.');
  });

  test('asset change journal detects a basic conflict', () async {
    final tempRoot = await Directory.systemTemp.createTemp('asset-conflict-test-');
    addTearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    final assetsRoot = Directory('${tempRoot.path}/18_ASSETS_EQUIPMENT_AND_PARTS');
    await assetsRoot.create(recursive: true);

    final repository = AssetRegisterRepository(workingDirectory: tempRoot);
    await repository.appendChangeJournalEntry(
      assetsRoot.path,
      AssetChangeJournalEntry(
        recordId: 'NE-EQ-0001',
        recordType: 'equipment',
        action: AssetChangeAction.update,
        timestamp: DateTime.utc(2026, 5, 28, 10, 0),
        machineId: 'HAYLEY-LAPTOP',
        userLabel: 'Hayley',
        changedFields: const {'status': 'broken'},
        note: '',
      ),
    );
    await repository.appendChangeJournalEntry(
      assetsRoot.path,
      AssetChangeJournalEntry(
        recordId: 'NE-EQ-0001',
        recordType: 'equipment',
        action: AssetChangeAction.update,
        timestamp: DateTime.utc(2026, 5, 28, 10, 12),
        machineId: 'PETER-DESKTOP',
        userLabel: 'Peter',
        changedFields: const {'location': 'Repair bench'},
        note: '',
      ),
    );

    final container = ProviderContainer(
      overrides: [
        assetWorkspaceProvider.overrideWith(
          (ref) async => AssetWorkspaceSnapshot(
            configPath: 'config/local_paths.json',
            assetsRootPath: assetsRoot.path,
            isReady: true,
            issues: <String>[],
            requiredFolders: AssetFolderService.requiredFolders,
            missingFolders: <String>[],
            missingFiles: <String>[],
            summaryCards: <AssetSummaryCard>[],
            equipmentCount: 0,
            partsCount: 0,
            guidanceNote: 'Connected.',
          ),
        ),
        assetRegisterRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final conflicts = await container.read(assetChangeConflictsProvider.future);

    expect(conflicts, hasLength(1));
    expect(conflicts.single.recordId, 'NE-EQ-0001');
    expect(conflicts.single.entryCount, 2);
    expect(conflicts.single.machineIds, containsAll(['HAYLEY-LAPTOP', 'PETER-DESKTOP']));
  });
}
