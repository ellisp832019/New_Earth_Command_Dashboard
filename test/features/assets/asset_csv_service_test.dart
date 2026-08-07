import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';

void main() {
  test(
    'AssetCsvService preserves unknown columns when reading and writing',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'asset_csv_service_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final file = File(
        p.join(
          tempRoot.path,
          '01_EQUIPMENT_REGISTER',
          'equipment_register.csv',
        ),
      );
      await file.parent.create(recursive: true);
      await file.writeAsString(
        'asset_id,name,custom_field\nNE-EQ-0001,Drill,Keep local\n',
      );

      final service = AssetCsvService();
      final table = await service.readTable(
        file,
        expectedHeaders: AssetRegisterRepository.equipmentHeaders,
      );

      expect(
        table.headers,
        containsAllInOrder(<String>['asset_id', 'name', 'custom_field']),
      );
      expect(table.rows.first['custom_field'], 'Keep local');

      final updatedTable = AssetCsvTable(
        headers: table.headers,
        rows: [
          ...table.rows,
          {
            'asset_id': 'NE-EQ-0002',
            'name': 'Saw',
            'custom_field': 'Needs review',
          },
        ],
      );
      await service.writeTable(file, updatedTable);

      final writtenText = await file.readAsString();
      expect(writtenText, contains('custom_field'));
      expect(writtenText, contains('NE-EQ-0002'));
    },
  );

  test(
    'AssetCsvService writes a backup before replacing an existing file',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'asset_csv_backup_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final file = File(
        p.join(tempRoot.path, '02_PARTS_INVENTORY', 'parts_inventory.csv'),
      );
      await file.parent.create(recursive: true);
      await file.writeAsString('part_id,name\nPART-001,Legacy part\n');

      final service = AssetCsvService();
      await service.writeTable(
        file,
        AssetCsvTable(
          headers: <String>['part_id', 'name', 'status'],
          rows: <Map<String, String>>[
            {
              'part_id': 'PART-002',
              'name': 'Replacement part',
              'status': 'available',
            },
          ],
        ),
      );

      expect(await file.readAsString(), contains('status'));
      expect(
        await File('${file.path}.bak').readAsString(),
        contains('Legacy part'),
      );
    },
  );

  test(
    'AssetRegisterRepository appends to equipment and parts registers',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'asset_register_repository_test_',
      );
      addTearDown(() async {
        if (await tempRoot.exists()) {
          await tempRoot.delete(recursive: true);
        }
      });

      final assetsRoot = Directory(
        p.join(tempRoot.path, '18_ASSETS_EQUIPMENT_AND_PARTS'),
      );
      await assetsRoot.create(recursive: true);

      final repository = AssetRegisterRepository(workingDirectory: tempRoot);
      await repository.appendEquipmentRecord(assetsRoot.path, {
        'asset_id': 'NE-EQ-0001',
        'name': 'Cordless drill',
        'type': 'Tool',
        'status': 'available',
      });
      await repository.appendPartRecord(assetsRoot.path, {
        'part_id': 'NE-PART-0001',
        'name': 'M3 screws',
        'quantity': '12',
        'min_quantity': '10',
        'status': 'low_stock',
      });

      final equipmentText = await File(
        p.join(
          assetsRoot.path,
          '01_EQUIPMENT_REGISTER',
          'equipment_register.csv',
        ),
      ).readAsString();
      final partsText = await File(
        p.join(assetsRoot.path, '02_PARTS_INVENTORY', 'parts_inventory.csv'),
      ).readAsString();

      expect(equipmentText, contains('NE-EQ-0001'));
      expect(partsText, contains('NE-PART-0001'));
      expect(partsText, contains('low_stock'));
    },
  );
}
