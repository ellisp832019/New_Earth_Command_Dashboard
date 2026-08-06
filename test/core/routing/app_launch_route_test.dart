import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/core/routing/app_launch_route.dart';

void main() {
  test('launch route parser reads explicit launch route arguments', () {
    expect(
      AppLaunchRoute.parse(const ['--launch-route=/modules/alpha']),
      '/modules/alpha',
    );
    expect(
      AppLaunchRoute.parse(const ['--route=/modules/beta/projects']),
      '/modules/beta/projects',
    );
    expect(AppLaunchRoute.parse(const ['/modules/gamma']), '/modules/gamma');
  });

  test('launch route parser ignores unrelated arguments', () {
    expect(AppLaunchRoute.parse(const ['--debug', '--profile']), isNull);
  });
}
