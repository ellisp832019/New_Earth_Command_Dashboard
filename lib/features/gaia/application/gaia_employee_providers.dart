import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaia_dashboard_module/gaia_dashboard_module.dart';
import 'package:gaia_integration_client/gaia_integration_client.dart';
import 'package:http/http.dart' as http;

import '../../settings/application/settings_controller.dart';

final gaiaEmployeeFeatureEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsSnapshotProvider);

  return settings.maybeWhen(
    data: (snapshot) => snapshot.settings.showGaiaEmployeeSurface,
    orElse: () => false,
  );
});

final gaiaEmployeeBackendUriProvider = Provider<Uri>((ref) {
  final fallback = Uri.parse('http://127.0.0.1:8765');
  const rawBaseUrl = String.fromEnvironment(
    'GAIA_BACKEND_URL',
    defaultValue: 'http://127.0.0.1:8765',
  );
  final candidate = Uri.tryParse(rawBaseUrl.trim());
  if (candidate == null || !_isSafeLoopbackUri(candidate)) {
    return fallback;
  }

  return candidate;
});

final gaiaEmployeeHttpClientProvider = Provider.autoDispose<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final gaiaEmployeeIntegrationClientProvider =
    Provider.autoDispose<GaiaIntegrationClient?>((ref) {
      if (!ref.watch(gaiaEmployeeFeatureEnabledProvider)) {
        return null;
      }

      final baseUri = ref.watch(gaiaEmployeeBackendUriProvider);
      return GaiaIntegrationClient(
        baseUri: baseUri,
        client: ref.watch(gaiaEmployeeHttpClientProvider),
      );
    });

final gaiaEmployeeControllerProvider =
    Provider.autoDispose<GaiaDashboardController?>((ref) {
      final client = ref.watch(gaiaEmployeeIntegrationClientProvider);
      if (client == null) {
        return null;
      }

      final controller = GaiaDashboardController(client: client);
      ref.onDispose(controller.dispose);
      unawaited(controller.refresh());
      return controller;
    });

bool _isSafeLoopbackUri(Uri uri) {
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return false;
  }

  final host = uri.host.trim().toLowerCase();
  return host == 'localhost' || host == '127.0.0.1' || host == '::1';
}
