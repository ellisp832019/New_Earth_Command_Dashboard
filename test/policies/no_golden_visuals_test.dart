import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String token(String first, String second, [String? third]) {
  return third == null ? '$first$second' : '$first$second$third';
}

void main() {
  test('repo does not use golden visual snapshot tests', () async {
    final repoRoot = Directory.current;
    final forbidden = <String>[
      token('matches', 'Golden', 'File'),
      token('--update', '-goldens'),
    ];

    final offenders = <String>[];
    await for (final entity in repoRoot.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }

      final path = entity.path.replaceAll('\\', '/');
      if (!path.endsWith('.dart')) {
        continue;
      }
      if (path.contains('/.git/') ||
          path.contains('/.dart_tool/') ||
          path.contains('/build/') ||
          path.contains('/windows/flutter/ephemeral/')) {
        continue;
      }

      final contents = await entity.readAsString();
      if (forbidden.any(contents.contains)) {
        offenders.add(path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Golden snapshot tooling is retired. Use rendered PNG assets instead: ${offenders.join(', ')}',
    );
  });
}
