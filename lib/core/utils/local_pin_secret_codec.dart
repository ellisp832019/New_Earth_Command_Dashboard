import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class LocalPinSecretMaterial {
  const LocalPinSecretMaterial({
    required this.algorithm,
    required this.saltBase64,
    required this.hashBase64,
    required this.pinLength,
  });

  final String algorithm;
  final String saltBase64;
  final String hashBase64;
  final int pinLength;
}

class LocalPinSecretCodec {
  LocalPinSecretCodec._();

  static const String algorithm = 'pbkdf2-sha256';
  static final Pbkdf2 _pbkdf2 = Pbkdf2.hmacSha256(
    iterations: 100000,
    bits: 256,
  );
  static final Random _secureRandom = Random.secure();

  static String displayPinFromLength(int pinLength) {
    if (pinLength <= 0) {
      return '';
    }
    return '*' * pinLength;
  }

  static String normalizeStoredDisplay({
    required String storedPinCode,
    required int pinLength,
  }) {
    if (storedPinCode.isNotEmpty && _looksMasked(storedPinCode)) {
      return storedPinCode;
    }
    return displayPinFromLength(
      pinLength > 0 ? pinLength : storedPinCode.length,
    );
  }

  static Future<LocalPinSecretMaterial> hashPinCode(
    String pinCode, {
    List<int>? saltBytes,
  }) async {
    final salt = saltBytes ?? _generateSalt();
    final secretKey = await _pbkdf2.deriveKeyFromPassword(
      password: pinCode,
      nonce: salt,
    );
    final hash = await secretKey.extractBytes();
    return LocalPinSecretMaterial(
      algorithm: algorithm,
      saltBase64: base64Encode(salt),
      hashBase64: base64Encode(hash),
      pinLength: pinCode.length,
    );
  }

  static Future<bool> matchesPinCode({
    required String pinCode,
    required String saltBase64,
    required String hashBase64,
  }) async {
    if (saltBase64.isEmpty || hashBase64.isEmpty) {
      return false;
    }

    final material = await hashPinCode(
      pinCode,
      saltBytes: base64Decode(saltBase64),
    );
    return _constantTimeEquals(
      base64Decode(hashBase64),
      base64Decode(material.hashBase64),
    );
  }

  static Uint8List _generateSalt([int length = 16]) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _secureRandom.nextInt(256)),
    );
  }

  static bool _looksMasked(String value) {
    return value.isNotEmpty && value.runes.every((rune) => rune == 42);
  }

  static bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }

    var diff = 0;
    for (var index = 0; index < left.length; index++) {
      diff |= left[index] ^ right[index];
    }
    return diff == 0;
  }
}
