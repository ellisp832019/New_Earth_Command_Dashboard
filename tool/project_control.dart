import 'dart:io';

import 'project_control/command_runner.dart';

Future<void> main(List<String> args) async {
  exitCode = await runProjectControl(args, workingDirectory: Directory.current);
}
