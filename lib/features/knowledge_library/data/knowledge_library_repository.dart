import 'dart:async';
import 'dart:convert';
import 'dart:io';

class KnowledgeLibraryRepository {
  KnowledgeLibraryRepository({Uri? baseUri})
    : baseUri = baseUri ?? Uri.parse('http://127.0.0.1:8787');

  final Uri baseUri;
  final HttpClient _client = HttpClient()..connectionTimeout = const Duration(seconds: 8);

  void dispose() {
    _client.close(force: true);
  }

  Future<KnowledgeLibraryPage> loadPage({
    int limit = 100,
    int offset = 0,
  }) async {
    final json = await _getJson(
      baseUri.replace(
        path: '/library',
        queryParameters: {
          'limit': '$limit',
          'offset': '$offset',
        },
      ),
    );
    return KnowledgeLibraryPage.fromJson(json);
  }

  Future<KnowledgeLibraryHealth> loadHealth() async {
    final json = await _getJson(baseUri.replace(path: '/health'));
    return KnowledgeLibraryHealth.fromJson(json);
  }

  Future<KnowledgeLibrarySearchResult> search({
    required String query,
    int limit = 200,
  }) async {
    final json = await _getJson(
      baseUri.replace(
        path: '/library/search',
        queryParameters: {
          'q': query,
          'limit': '$limit',
        },
      ),
    );

    final items = json['items'];
    final parsedItems = items is List
        ? items
        .whereType<Map>()
        .map((item) => KnowledgeLibraryItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false)
        : const <KnowledgeLibraryItem>[];

    return KnowledgeLibrarySearchResult(
      query: query,
      totalMatches: _intValue(json['total_matches']),
      items: parsedItems,
    );
  }

  Future<KnowledgeLibraryStats> loadStats() async {
    final json = await _getJson(baseUri.replace(path: '/library/stats'));
    return KnowledgeLibraryStats.fromJson(json);
  }

  Future<KnowledgeLibraryExtractionStatus> loadExtractionStatus() async {
    final json = await _getJson(
      baseUri.replace(path: '/library/extraction/status'),
    );
    return KnowledgeLibraryExtractionStatus.fromJson(json);
  }

  Future<void> revealOriginalFile(String path) async {
    if (path.isEmpty) {
      return;
    }

    if (Platform.isWindows) {
      // Reveal the source PDF in Explorer without moving or renaming it.
      await Process.start('explorer.exe', ['/select,$path']);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [path]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [path]);
    }
  }

  Future<void> openInDefaultApp(String path) async {
    if (path.isEmpty) {
      return;
    }

    if (Platform.isWindows) {
      await Process.start('cmd.exe', ['/c', 'start', '', path]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [path]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [path]);
    }
  }

  Future<void> openContainingFolder(String path) async {
    if (path.isEmpty) {
      return;
    }

    final folderPath = File(path).parent.path;

    if (Platform.isWindows) {
      await Process.start('explorer.exe', [folderPath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [folderPath]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [folderPath]);
    }
  }

  Future<void> openExtractedTextFolder(String path) async {
    if (path.isEmpty) {
      return;
    }

    final extractedPath = File(path);
    final folderPath = extractedPath.parent.path;

    if (Platform.isWindows) {
      await Process.start('explorer.exe', [folderPath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [folderPath]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [folderPath]);
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final request = await _client.getUrl(uri);
    final response = await request.close().timeout(
      const Duration(seconds: 20),
    );

    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Knowledge Library API returned ${response.statusCode} for $uri',
        uri: uri,
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Knowledge Library API response was invalid.');
    }

    return decoded;
  }
}

class KnowledgeLibraryPage {
  const KnowledgeLibraryPage({
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });

  final int total;
  final int limit;
  final int offset;
  final List<KnowledgeLibraryItem> items;

  bool get hasMore => offset + items.length < total;

  factory KnowledgeLibraryPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return KnowledgeLibraryPage(
      total: _intValue(json['total']),
      limit: _intValue(json['limit']),
      offset: _intValue(json['offset']),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) => KnowledgeLibraryItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const [],
    );
  }
}

class KnowledgeLibrarySearchResult {
  const KnowledgeLibrarySearchResult({
    required this.query,
    required this.totalMatches,
    required this.items,
  });

  final String query;
  final int totalMatches;
  final List<KnowledgeLibraryItem> items;

  bool get hasMore => items.length < totalMatches;
}

class KnowledgeLibraryItem {
  const KnowledgeLibraryItem({
    required this.id,
    required this.filename,
    required this.title,
    required this.fullPath,
    required this.relativePath,
    required this.sourceSection,
    required this.category,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.modifiedAt,
    required this.pageCount,
    required this.textExtractable,
    required this.ocrRequired,
    required this.tags,
    required this.summaryStatus,
    required this.audioStatus,
    required this.listenedStatus,
    required this.notesPath,
    required this.extractedTextPath,
    required this.audioManifestPath,
  });

  final String id;
  final String filename;
  final String title;
  final String fullPath;
  final String relativePath;
  final String sourceSection;
  final String category;
  final int fileSizeBytes;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final int? pageCount;
  final bool textExtractable;
  final bool ocrRequired;
  final List<String> tags;
  final String summaryStatus;
  final String audioStatus;
  final String listenedStatus;
  final String? notesPath;
  final String? extractedTextPath;
  final String? audioManifestPath;

  bool get hasExtractedText =>
      extractedTextPath != null && extractedTextPath!.trim().isNotEmpty;

  factory KnowledgeLibraryItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeLibraryItem(
      id: json['id']?.toString() ?? '',
      filename: json['filename']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      fullPath: json['full_path']?.toString() ?? '',
      relativePath: json['relative_path']?.toString() ?? '',
      sourceSection: json['source_section']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      fileSizeBytes: _intValue(json['file_size_bytes']),
      createdAt: _dateValue(json['created_at']),
      modifiedAt: _dateValue(json['modified_at']),
      pageCount: _nullableIntValue(json['page_count']),
      textExtractable: _boolValue(json['text_extractable']),
      ocrRequired: _boolValue(json['ocr_required']),
      tags: (json['tags'] as List? ?? const [])
          .map((tag) => tag.toString())
          .toList(growable: false),
      summaryStatus: json['summary_status']?.toString() ?? 'unknown',
      audioStatus: json['audio_status']?.toString() ?? 'unknown',
      listenedStatus: json['listened_status']?.toString() ?? 'unknown',
      notesPath: json['notes_path']?.toString(),
      extractedTextPath: json['extracted_text_path']?.toString(),
      audioManifestPath: json['audio_manifest_path']?.toString(),
    );
  }
}

class KnowledgeLibraryStats {
  const KnowledgeLibraryStats({
    required this.totalPdfs,
    required this.bySourceSection,
    required this.byCategory,
    required this.textExtractable,
    required this.ocrRequired,
    required this.audioGenerated,
  });

  final int totalPdfs;
  final Map<String, int> bySourceSection;
  final Map<String, int> byCategory;
  final int textExtractable;
  final int ocrRequired;
  final int audioGenerated;

  factory KnowledgeLibraryStats.fromJson(Map<String, dynamic> json) {
    return KnowledgeLibraryStats(
      totalPdfs: _intValue(json['total_pdfs']),
      bySourceSection: _mapOfInts(json['by_source_section']),
      byCategory: _mapOfInts(json['by_category']),
      textExtractable: _intValue(json['text_extractable']),
      ocrRequired: _intValue(json['ocr_required']),
      audioGenerated: _intValue(json['audio_generated']),
    );
  }
}

class KnowledgeLibraryHealth {
  const KnowledgeLibraryHealth({
    required this.status,
    required this.module,
    required this.message,
  });

  final String status;
  final String module;
  final String message;

  bool get isHealthy => status.toLowerCase() == 'ok';

  factory KnowledgeLibraryHealth.fromJson(Map<String, dynamic> json) {
    return KnowledgeLibraryHealth(
      status: json['status']?.toString() ?? 'unknown',
      module: json['module']?.toString() ?? 'knowledge_library',
      message: json['message']?.toString() ?? '',
    );
  }
}

class KnowledgeLibraryExtractionStatus {
  const KnowledgeLibraryExtractionStatus({
    required this.totalPdfs,
    required this.textExtractable,
    required this.ocrRequired,
    required this.extracted,
    required this.failed,
    required this.pending,
    required this.lastRunAt,
    required this.statePath,
    required this.reportPath,
  });

  final int totalPdfs;
  final int textExtractable;
  final int ocrRequired;
  final int extracted;
  final int failed;
  final int pending;
  final DateTime? lastRunAt;
  final String statePath;
  final String reportPath;

  bool get hasFailures => failed > 0;

  factory KnowledgeLibraryExtractionStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    return KnowledgeLibraryExtractionStatus(
      totalPdfs: _intValue(json['total_pdfs']),
      textExtractable: _intValue(json['text_extractable']),
      ocrRequired: _intValue(json['ocr_required']),
      extracted: _intValue(json['extracted']),
      failed: _intValue(json['failed']),
      pending: _intValue(json['pending']),
      lastRunAt: _dateValue(json['last_run_at']),
      statePath: json['state_path']?.toString() ?? '',
      reportPath: json['report_path']?.toString() ?? '',
    );
  }
}

int _intValue(Object? value) => int.tryParse(value?.toString() ?? '') ?? 0;

int? _nullableIntValue(Object? value) =>
    value == null ? null : int.tryParse(value.toString());

bool _boolValue(Object? value) => value == true || value?.toString() == 'true';

DateTime? _dateValue(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) {
    return null;
  }

  return DateTime.tryParse(text);
}

Map<String, int> _mapOfInts(Object? value) {
  if (value is! Map) {
    return const {};
  }

  return {
    for (final entry in value.entries)
      entry.key.toString(): int.tryParse(entry.value.toString()) ?? 0,
  };
}
