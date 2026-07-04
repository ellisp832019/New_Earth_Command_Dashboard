import 'route_names.dart';

abstract final class AppLaunchRoute {
  static String get initialLocation => RouteNames.startup;

  static String? parse(List<String> arguments) {
    final route = arguments
        .where((argument) => argument.startsWith('/'))
        .firstOrNull;
    return route;
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
