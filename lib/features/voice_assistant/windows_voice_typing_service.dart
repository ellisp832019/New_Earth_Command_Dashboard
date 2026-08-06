import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WindowsVoiceTypingService {
  WindowsVoiceTypingService._();

  static const MethodChannel _channel = MethodChannel(
    'new_earth/windows_voice_typing',
  );

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static Future<bool> startVoiceTyping() async {
    if (!isSupported) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('startVoiceTyping');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> stopVoiceTyping() async {
    if (!isSupported) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('stopVoiceTyping');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> cancelVoiceTyping() async {
    if (!isSupported) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('cancelVoiceTyping');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
