import 'dart:io';

class FolderTemplateService {
  Future<void> createGrantFolder({
    required String targetFolderPath,
    required Map<String, String> templateFiles,
  }) async {
    final folder = Directory(targetFolderPath);
    await folder.create(recursive: true);

    for (final entry in templateFiles.entries) {
      final file = File('${folder.path}${Platform.pathSeparator}${entry.key}');
      await file.parent.create(recursive: true);
      await file.writeAsString(entry.value);
    }

    await Directory('${folder.path}${Platform.pathSeparator}attachments').create(recursive: true);
    await Directory('${folder.path}${Platform.pathSeparator}attachments${Platform.pathSeparator}screenshots').create(recursive: true);
    await Directory('${folder.path}${Platform.pathSeparator}attachments${Platform.pathSeparator}photos').create(recursive: true);
    await Directory('${folder.path}${Platform.pathSeparator}attachments${Platform.pathSeparator}pdfs').create(recursive: true);
  }
}
