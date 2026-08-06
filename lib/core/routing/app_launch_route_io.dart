import 'dart:io';

import 'route_names.dart';

abstract final class AppLaunchRoute {
  static String get initialLocation {
    return parse(Platform.executableArguments) ?? RouteNames.dashboard;
  }

  static String? parse(List<String> arguments) {
    for (final argument in arguments) {
      final value = _parseRouteArgument(argument);
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static String? _parseRouteArgument(String argument) {
    final trimmed = argument.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    const prefixes = ['--launch-route=', '--route='];
    for (final prefix in prefixes) {
      if (trimmed.startsWith(prefix)) {
        final value = trimmed.substring(prefix.length).trim();
        return value.isEmpty ? null : value;
      }
    }

    if (!trimmed.startsWith('-') && trimmed.startsWith('/')) {
      return trimmed;
    }

    return null;
  }
}
