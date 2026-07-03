import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/modules/module_loader.dart';

void main() {
  test('education learning hub manifest is discoverable from the module tree', () {
    final registry = ModuleLoader().load();
    final manifest = registry.byId('24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB');

    expect(manifest, isNotNull);
    expect(manifest?.name, 'Education & Learning Hub');
    expect(manifest?.routes, contains('/modules/education-learning-hub'));
    expect(manifest?.iconKey, 'school_outlined');
    expect(manifest?.enabled, isTrue);
  });
}
