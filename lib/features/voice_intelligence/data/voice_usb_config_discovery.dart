import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

class VoiceUsbConfigDiscovery {
  const VoiceUsbConfigDiscovery();

  static Map<String, String> discoverOllamaEnvironment({
    Map<String, String>? environment,
    Iterable<String>? candidateRoots,
  }) {
    final env = environment ?? Platform.environment;
    if (_hasExplicitOllamaConfig(env)) {
      return const <String, String>{};
    }

    for (final root in _candidateRoots(env, candidateRoots)) {
      final configFile = File(
        path.join(
          root,
          'modules',
          'gaia_voice_assistant',
          'config',
          'gaia_config.json',
        ),
      );
      if (!configFile.existsSync()) {
        continue;
      }

      try {
        final decoded = jsonDecode(configFile.readAsStringSync());
        if (decoded is! Map<String, dynamic>) {
          continue;
        }

        final ollamaUrl = _cleanValue(
          decoded['ollama_url'] ?? decoded['VOICE_OLLAMA_URL'],
        );
        final defaultModel = _cleanValue(
          decoded['default_model'] ?? decoded['VOICE_OLLAMA_MODEL'],
        );

        if (ollamaUrl == null && defaultModel == null) {
          continue;
        }

        final result = <String, String>{
          'VOICE_PROVIDER': 'ollama',
          'VOICE_AI_PROVIDER': 'ollama',
          'VOICE_CONFIG_SOURCE': 'gaia_usb',
        };
        if (ollamaUrl != null) {
          result['VOICE_OLLAMA_URL'] = ollamaUrl;
        }
        if (defaultModel != null) {
          result['VOICE_OLLAMA_MODEL'] = defaultModel;
        }
        return result;
      } catch (_) {
        continue;
      }
    }

    return const <String, String>{};
  }

  static bool _hasExplicitOllamaConfig(Map<String, String> env) {
    return env['VOICE_OLLAMA_URL']?.trim().isNotEmpty == true ||
        env['OLLAMA_URL']?.trim().isNotEmpty == true ||
        env['VOICE_OLLAMA_MODEL']?.trim().isNotEmpty == true ||
        env['OLLAMA_MODEL']?.trim().isNotEmpty == true;
  }

  static Iterable<String> _candidateRoots(
    Map<String, String> env,
    Iterable<String>? candidateRoots,
  ) sync* {
    if (candidateRoots != null) {
      for (final root in candidateRoots) {
        final cleaned = root.trim();
        if (cleaned.isNotEmpty) {
          yield cleaned;
        }
      }
      return;
    }

    final hintedRoots = [
      env['GAIA_USB_ROOT'],
      env['GAIA_USB'],
      env['VOICE_USB_ROOT'],
      env['NEW_EARTH_USB_ROOT'],
    ];
    for (final root in hintedRoots) {
      final cleaned = root?.trim();
      if (cleaned != null && cleaned.isNotEmpty) {
        yield cleaned;
      }
    }

    if (!Platform.isWindows) {
      return;
    }

    for (var code = 'A'.codeUnitAt(0); code <= 'Z'.codeUnitAt(0); code++) {
      yield '${String.fromCharCode(code)}:\\GAIA_USB';
    }
  }

  static String? _cleanValue(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }
}
