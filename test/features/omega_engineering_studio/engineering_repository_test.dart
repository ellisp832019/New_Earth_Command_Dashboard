import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/application/engineering_services.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';

void main() {
  group('LocalEngineeringRepository', () {
    test('loads seeded engineering data', () async {
      final repository = LocalEngineeringRepository(
        moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
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

    test('searches across the engineering workspace', () async {
      final repository = LocalEngineeringRepository(
        moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
      );
      final snapshot = await repository.loadSnapshot();
      final search = EngineeringSearchService(snapshot);

      final hits = search.search('MicroGrow');

      expect(hits, isNotEmpty);
      expect(hits.any((hit) => hit.title.contains('MicroGrow')), isTrue);
    });

    test('filters low stock components', () async {
      final repository = LocalEngineeringRepository(
        moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
      );
      final snapshot = await repository.loadSnapshot();
      final service = ComponentInventoryService(snapshot);

      final components = service.components(status: 'Blocked');

      expect(components, isNotEmpty);
      expect(components.any((component) => component.isLowStock), isTrue);
    });
  });
}
