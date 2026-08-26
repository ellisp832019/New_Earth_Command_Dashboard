import 'dart:io';

import 'package:path/path.dart' as p;

const _defaultEnvironmentKey = 'NEW_EARTH_PLATFORM_CORE_ROOT';

typedef PlatformCoreRootCanonicalizer =
    Future<String?> Function(String normalizedRoot);

enum PlatformCoreRuntimeConfigurationStatus {
  configured,
  notConfigured,
  invalidRoot,
  unavailable,
}

/// The single production input used to locate the local Platform Core root.
class PlatformCoreRuntimeConfiguration {
  const PlatformCoreRuntimeConfiguration({
    required this.status,
    this.canonicalRoot,
    this.configurationSource,
  });

  final PlatformCoreRuntimeConfigurationStatus status;
  final String? canonicalRoot;
  final String? configurationSource;

  bool get isConfigured =>
      status == PlatformCoreRuntimeConfigurationStatus.configured &&
      canonicalRoot != null;

  String get reason => status.name;
}

/// Resolves the Platform Core root without adding a fallback chain.
class PlatformCoreRuntimeConfigurationResolver {
  static const defaultEnvironmentKey = _defaultEnvironmentKey;

  PlatformCoreRuntimeConfigurationResolver({
    Map<String, String?>? environment,
    PlatformCoreRootCanonicalizer? canonicalizeRoot,
    this.environmentKey = _defaultEnvironmentKey,
  }) : _environment = environment ?? Platform.environment,
       _canonicalizeRoot = canonicalizeRoot ?? _canonicalizeDirectory;

  final Map<String, String?> _environment;
  final PlatformCoreRootCanonicalizer _canonicalizeRoot;
  final String environmentKey;

  Future<PlatformCoreRuntimeConfiguration> resolve() async {
    final rawConfigured = _environment[environmentKey];
    if (rawConfigured == null) {
      return const PlatformCoreRuntimeConfiguration(
        status: PlatformCoreRuntimeConfigurationStatus.unavailable,
      );
    }
    final configured = rawConfigured.trim();
    if (configured.isEmpty || !_isAbsolutePath(configured)) {
      return const PlatformCoreRuntimeConfiguration(
        status: PlatformCoreRuntimeConfigurationStatus.invalidRoot,
      );
    }

    final normalized = p.normalize(configured);
    if (normalized.isEmpty || !_isAbsolutePath(normalized)) {
      return const PlatformCoreRuntimeConfiguration(
        status: PlatformCoreRuntimeConfigurationStatus.invalidRoot,
      );
    }

    try {
      final canonical = await _canonicalizeRoot(normalized);
      if (canonical == null || canonical.isEmpty) {
        return PlatformCoreRuntimeConfiguration(
          status: PlatformCoreRuntimeConfigurationStatus.unavailable,
          configurationSource: environmentKey,
        );
      }
      final canonicalRoot = p.normalize(canonical);
      if (!_isAbsolutePath(canonicalRoot)) {
        return const PlatformCoreRuntimeConfiguration(
          status: PlatformCoreRuntimeConfigurationStatus.invalidRoot,
        );
      }
      return PlatformCoreRuntimeConfiguration(
        status: PlatformCoreRuntimeConfigurationStatus.configured,
        canonicalRoot: canonicalRoot,
        configurationSource: environmentKey,
      );
    } catch (_) {
      return PlatformCoreRuntimeConfiguration(
        status: PlatformCoreRuntimeConfigurationStatus.unavailable,
        configurationSource: environmentKey,
      );
    }
  }

  static Future<String?> _canonicalizeDirectory(String normalizedRoot) async {
    try {
      final directory = Directory(normalizedRoot);
      final stat = await directory.stat();
      if (stat.type != FileSystemEntityType.directory) return null;
      return p.normalize(await directory.resolveSymbolicLinks());
    } catch (_) {
      return null;
    }
  }

  static bool _isAbsolutePath(String value) {
    return p.isAbsolute(value) ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value) ||
        value.startsWith('/');
  }
}
