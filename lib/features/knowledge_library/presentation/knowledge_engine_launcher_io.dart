import 'dart:io';

Future<bool> isKnowledgeEngineRunning() async {
  final client = HttpClient();
  try {
    final request = await client
        .getUrl(Uri.parse('http://127.0.0.1:8787/health'))
        .timeout(const Duration(seconds: 2));
    final response = await request.close().timeout(const Duration(seconds: 2));
    final isRunning = response.statusCode == HttpStatus.ok;
    await response.drain<void>();
    return isRunning;
  } catch (_) {
    return false;
  } finally {
    client.close(force: true);
  }
}

Future<String?> launchKnowledgeEngine() async {
  final moduleRoot = _findRepoRoot();
  if (moduleRoot == null) {
    return 'Could not find the repository root for the Knowledge Engine launcher.';
  }

  final scriptPath =
      '${moduleRoot.path}\\modules\\knowledge_engine\\start_knowledge_engine.ps1';
  final scriptFile = File(scriptPath);

  if (!await scriptFile.exists()) {
    return 'Could not find the Knowledge Engine launcher at $scriptPath.';
  }

  try {
    await Process.start('powershell.exe', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      scriptPath,
    ], mode: ProcessStartMode.detached);
    return null;
  } catch (error) {
    return 'Could not start the Knowledge Engine: $error';
  }
}

Directory? _findRepoRoot() {
  var current = Directory.current;
  while (true) {
    final scriptFile = File(
      '${current.path}\\modules\\knowledge_engine\\start_knowledge_engine.ps1',
    );
    final taskFile = File('${current.path}\\TASK.md');
    if (scriptFile.existsSync() || taskFile.existsSync()) {
      return current;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }
    current = parent;
  }
}
