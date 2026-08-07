import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'company_command_centre_config.dart';

final companyCommandCentreIndexServiceProvider =
    Provider<CompanyCommandCentreIndexService>(
      (ref) => const CompanyCommandCentreIndexService(),
    );

class CompanyCommandCentreIndexService {
  const CompanyCommandCentreIndexService({
    this.moduleRootPath = 'modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE',
    this.moduleConfigPath = companyCommandCentreModuleConfigPath,
    this.omegaOsPath = companyCommandCentreOmegaOsPath,
    this.now,
  });

  final String moduleRootPath;
  final String moduleConfigPath;
  final String omegaOsPath;
  final DateTime Function()? now;

  Future<CompanyCommandCentreIndexSnapshot> scanAndGenerate() async {
    final config = await _readJsonMap(moduleConfigPath);
    final configuredPath = _stringValue(config, const [
      'companyOmegaPath',
      'omegaPath',
      'omega_os_path',
    ]);
    final sourcePath = configuredPath.isNotEmpty ? configuredPath : omegaOsPath;
    final sourceDirectory = Directory(sourcePath);
    final sourceExists = await sourceDirectory.exists();
    final outputDirectory = Directory(
      path.join(moduleRootPath, 'omega_os_bridge', 'indexes'),
    );
    await outputDirectory.create(recursive: true);

    final records = sourceExists
        ? await _scanMarkdownFiles(sourceDirectory)
        : <CompanyCommandCentreMarkdownRecord>[];
    final generatedAt = _now().toUtc();

    final companyIndexPath = await _writeIndexFile(
      outputDirectory,
      'company_index.generated.json',
      sourcePath: sourcePath,
      sourceExists: sourceExists,
      generatedAt: generatedAt,
      records: records,
    );
    final actionItemsPath = await _writeIndexFile(
      outputDirectory,
      'action_items_index.generated.json',
      sourcePath: sourcePath,
      sourceExists: sourceExists,
      generatedAt: generatedAt,
      records: records
          .where((record) => record.checkboxCount > 0)
          .toList(growable: false),
    );
    final deadlinesPath = await _writeIndexFile(
      outputDirectory,
      'deadlines_index.generated.json',
      sourcePath: sourcePath,
      sourceExists: sourceExists,
      generatedAt: generatedAt,
      records: records
          .where((record) => record.dueDates.isNotEmpty)
          .toList(growable: false),
    );
    final productsPath = await _writeIndexFile(
      outputDirectory,
      'products_index.generated.json',
      sourcePath: sourcePath,
      sourceExists: sourceExists,
      generatedAt: generatedAt,
      records: records
          .where((record) => record.labels.contains('product'))
          .toList(growable: false),
    );
    final grantsPath = await _writeIndexFile(
      outputDirectory,
      'grants_index.generated.json',
      sourcePath: sourcePath,
      sourceExists: sourceExists,
      generatedAt: generatedAt,
      records: records
          .where((record) => record.labels.contains('grant'))
          .toList(growable: false),
    );
    final ipAssetsPath = await _writeIndexFile(
      outputDirectory,
      'ip_assets_index.generated.json',
      sourcePath: sourcePath,
      sourceExists: sourceExists,
      generatedAt: generatedAt,
      records: records
          .where((record) => record.labels.contains('ip_asset'))
          .toList(growable: false),
    );
    final evidencePath = await _writeIndexFile(
      outputDirectory,
      'evidence_index.generated.json',
      sourcePath: sourcePath,
      sourceExists: sourceExists,
      generatedAt: generatedAt,
      records: records
          .where((record) => record.isEvidence)
          .toList(growable: false),
    );

    return CompanyCommandCentreIndexSnapshot(
      generatedAt: generatedAt,
      sourcePath: sourcePath,
      sourceExists: sourceExists,
      sourceMarkdownCount: records.length,
      companyIndexPath: companyIndexPath,
      actionItemsIndexPath: actionItemsPath,
      deadlinesIndexPath: deadlinesPath,
      productsIndexPath: productsPath,
      grantsIndexPath: grantsPath,
      ipAssetsIndexPath: ipAssetsPath,
      evidenceIndexPath: evidencePath,
      recentFiles: records.take(8).toList(growable: false),
      records: records,
    );
  }

  Future<List<CompanyCommandCentreMarkdownRecord>> _scanMarkdownFiles(
    Directory sourceDirectory,
  ) async {
    final files =
        sourceDirectory
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.md'))
            .toList(growable: false)
          ..sort((a, b) => a.path.compareTo(b.path));

    final records = <CompanyCommandCentreMarkdownRecord>[];
    for (final file in files) {
      final text = await _readTextFile(file);
      final relativePath = path.relative(file.path, from: sourceDirectory.path);
      final title =
          _firstHeading(text) ?? path.basenameWithoutExtension(file.path);
      final frontmatter = _parseFrontmatter(text);
      final checkboxItems = _checkboxItems(text);
      final dueDates = _dueDates(text);
      final labels = _classifyLabels(
        relativePath: relativePath,
        title: title,
        text: text,
        frontmatter: frontmatter,
        checkboxCount: checkboxItems.length,
        dueDates: dueDates,
      );

      records.add(
        CompanyCommandCentreMarkdownRecord(
          title: title,
          relativePath: relativePath,
          sourcePath: file.path,
          checkboxCount: checkboxItems.length,
          openCheckboxCount: checkboxItems
              .where((item) => !item.completed)
              .length,
          closedCheckboxCount: checkboxItems
              .where((item) => item.completed)
              .length,
          dueDates: dueDates,
          frontmatter: frontmatter,
          labels: labels,
          excerpt: _excerpt(text),
        ),
      );
    }
    return records;
  }

  Future<String> _writeIndexFile(
    Directory outputDirectory,
    String fileName, {
    required String sourcePath,
    required bool sourceExists,
    required DateTime generatedAt,
    required List<CompanyCommandCentreMarkdownRecord> records,
  }) async {
    final file = File(path.join(outputDirectory.path, fileName));
    final payload = <String, dynamic>{
      'generated_at': generatedAt.toIso8601String(),
      'source_path': sourcePath,
      'source_exists': sourceExists,
      'record_count': records.length,
      'records': records
          .map((record) => record.toJson())
          .toList(growable: false),
    };
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    return file.path;
  }

  Future<String> _readTextFile(File file) async {
    try {
      return await file.readAsString();
    } catch (_) {
      return '';
    }
  }

  String? _firstHeading(String text) {
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        return trimmed.substring(2).trim();
      }
    }
    return null;
  }

  Map<String, String> _parseFrontmatter(String text) {
    final lines = text.split('\n');
    if (lines.isEmpty || lines.first.trim() != '---') {
      return const <String, String>{};
    }

    final frontmatter = <String, String>{};
    for (var index = 1; index < lines.length; index++) {
      final line = lines[index].trim();
      if (line == '---') {
        break;
      }
      final separatorIndex = line.indexOf(':');
      if (separatorIndex <= 0) {
        continue;
      }
      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        frontmatter[key] = value;
      }
    }
    return frontmatter;
  }

  List<CompanyCommandCentreCheckboxItem> _checkboxItems(String text) {
    final items = <CompanyCommandCentreCheckboxItem>[];
    final checkboxPattern = RegExp(
      r'^\s*[-*]\s+\[( |x|X)\]\s+(.*)$',
      multiLine: true,
    );

    for (final match in checkboxPattern.allMatches(text)) {
      final completed = match.group(1)?.trim().toLowerCase() == 'x';
      final label = (match.group(2) ?? '').trim();
      if (label.isEmpty) {
        continue;
      }
      items.add(
        CompanyCommandCentreCheckboxItem(label: label, completed: completed),
      );
    }
    return items;
  }

  List<String> _dueDates(String text) {
    final dates = <String>{};
    final pattern = RegExp(r'\b\d{4}-\d{2}-\d{2}\b');
    for (final match in pattern.allMatches(text)) {
      dates.add(match.group(0)!);
    }
    final sorted = dates.toList(growable: false)..sort();
    return sorted;
  }

  List<String> _classifyLabels({
    required String relativePath,
    required String title,
    required String text,
    required Map<String, String> frontmatter,
    required int checkboxCount,
    required List<String> dueDates,
  }) {
    final labels = <String>{'company'};
    final combined =
        '$relativePath $title ${frontmatter.values.join(' ')} $text'
            .toLowerCase();

    if (checkboxCount > 0) {
      labels.add('action');
    }
    if (dueDates.isNotEmpty) {
      labels.add('deadline');
    }
    if (_containsAny(combined, const [
      'product',
      'microgrow',
      'biocalm',
      'omega dashboard',
      'field scanner',
    ])) {
      labels.add('product');
    }
    if (_containsAny(combined, const [
      'grant',
      'funding',
      'award',
      'application',
      'uk research',
      'innovation',
    ])) {
      labels.add('grant');
    }
    if (_containsAny(combined, const [
      'asset',
      'assets',
      'equipment',
      'valuation',
      'qr',
      'ip',
      'intellectual property',
    ])) {
      labels.add('ip_asset');
    }
    if (_containsAny(combined, const [
      'checklist',
      'template',
      'guide',
      'doc',
      'evidence',
      'record',
    ])) {
      labels.add('evidence');
    }

    return labels.toList(growable: false);
  }

  bool _containsAny(String value, List<String> terms) {
    for (final term in terms) {
      if (value.contains(term)) {
        return true;
      }
    }
    return false;
  }

  String _excerpt(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('# '))
        .take(2)
        .toList(growable: false);
    return lines.isEmpty ? '' : lines.join(' ');
  }

  Future<Map<String, dynamic>> _readJsonMap(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  String _stringValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  DateTime _now() => now?.call() ?? DateTime.now();
}

class CompanyCommandCentreIndexSnapshot {
  const CompanyCommandCentreIndexSnapshot({
    required this.generatedAt,
    required this.sourcePath,
    required this.sourceExists,
    required this.sourceMarkdownCount,
    required this.companyIndexPath,
    required this.actionItemsIndexPath,
    required this.deadlinesIndexPath,
    required this.productsIndexPath,
    required this.grantsIndexPath,
    required this.ipAssetsIndexPath,
    required this.evidenceIndexPath,
    required this.recentFiles,
    required this.records,
  });

  final DateTime generatedAt;
  final String sourcePath;
  final bool sourceExists;
  final int sourceMarkdownCount;
  final String companyIndexPath;
  final String actionItemsIndexPath;
  final String deadlinesIndexPath;
  final String productsIndexPath;
  final String grantsIndexPath;
  final String ipAssetsIndexPath;
  final String evidenceIndexPath;
  final List<CompanyCommandCentreMarkdownRecord> recentFiles;
  final List<CompanyCommandCentreMarkdownRecord> records;
}

class CompanyCommandCentreMarkdownRecord {
  const CompanyCommandCentreMarkdownRecord({
    required this.title,
    required this.relativePath,
    required this.sourcePath,
    required this.checkboxCount,
    required this.openCheckboxCount,
    required this.closedCheckboxCount,
    required this.dueDates,
    required this.frontmatter,
    required this.labels,
    required this.excerpt,
  });

  final String title;
  final String relativePath;
  final String sourcePath;
  final int checkboxCount;
  final int openCheckboxCount;
  final int closedCheckboxCount;
  final List<String> dueDates;
  final Map<String, String> frontmatter;
  final List<String> labels;
  final String excerpt;

  bool get isEvidence =>
      labels.contains('evidence') ||
      labels.contains('action') ||
      labels.contains('deadline');

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'relative_path': relativePath,
      'source_path': sourcePath,
      'checkbox_count': checkboxCount,
      'open_checkbox_count': openCheckboxCount,
      'closed_checkbox_count': closedCheckboxCount,
      'due_dates': dueDates,
      'frontmatter': frontmatter,
      'labels': labels,
      'excerpt': excerpt,
    };
  }
}

class CompanyCommandCentreCheckboxItem {
  const CompanyCommandCentreCheckboxItem({
    required this.label,
    required this.completed,
  });

  final String label;
  final bool completed;
}
