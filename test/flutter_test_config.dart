import 'dart:async';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final testView = binding.platformDispatcher.implicitView!;
  testView.physicalSize = const Size(1600, 1200);
  testView.devicePixelRatio = 1.0;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
