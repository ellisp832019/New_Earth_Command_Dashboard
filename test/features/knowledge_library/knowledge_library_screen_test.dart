import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/knowledge_library/data/knowledge_library_repository.dart';
import 'package:new_earth_command_dashboard/features/knowledge_library/presentation/knowledge_library_screen.dart';

void main() {
  testWidgets('knowledge library search and filters stay easy to follow', (
    tester,
  ) async {
    final repository = _FakeKnowledgeLibraryRepository();
    tester.view.physicalSize = const Size(1600, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: KnowledgeLibraryScreen(repository: repository),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(
        'Search reaches across titles, filenames, tags, folders, and extracted text.',
      ),
      findsOneWidget,
    );
    expect(find.text('Guide One'), findsWidgets);
    expect(find.text('Manifest review'), findsOneWidget);
    expect(find.text('Retry extraction'), findsOneWidget);
    expect(find.text('Open failure report'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Guides (2)'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Operations (2)'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'guide two');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.textContaining('Found 1 result for "guide two".'), findsWidgets);
    expect(find.text('Guide Two'), findsWidgets);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Guides (2)'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Operations (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Guide One'), findsWidgets);
    expect(find.text('Guide Two'), findsNothing);
    expect(find.text('Archive Note'), findsNothing);
  });
}

class _FakeKnowledgeLibraryRepository extends KnowledgeLibraryRepository {
  _FakeKnowledgeLibraryRepository() : super(baseUri: Uri.parse('http://fake'));

  final List<KnowledgeLibraryItem> _items = [
    KnowledgeLibraryItem(
      id: 'guide-one',
      filename: 'guide_one.pdf',
      title: 'Guide One',
      fullPath: 'D:/Omega/Guide One.pdf',
      relativePath: 'Reference/Guide One.pdf',
      sourceSection: 'Operations',
      category: 'Guides',
      fileSizeBytes: 1200,
      createdAt: DateTime(2026, 5, 2),
      modifiedAt: DateTime(2026, 5, 4),
      pageCount: 8,
      textExtractable: true,
      ocrRequired: false,
      tags: const ['guide', 'workflow'],
      summaryStatus: 'ready',
      audioStatus: 'generated',
      listenedStatus: 'not_started',
      notesPath: null,
      extractedTextPath: 'D:/Omega/Guide One.txt',
      audioManifestPath: 'D:/Omega/manifests/guide_one_manifest.json',
    ),
    KnowledgeLibraryItem(
      id: 'guide-two',
      filename: 'guide_two.pdf',
      title: 'Guide Two',
      fullPath: 'D:/Omega/Guide Two.pdf',
      relativePath: 'Reference/Guide Two.pdf',
      sourceSection: 'Research',
      category: 'Guides',
      fileSizeBytes: 2400,
      createdAt: DateTime(2026, 5, 5),
      modifiedAt: DateTime(2026, 5, 6),
      pageCount: 12,
      textExtractable: true,
      ocrRequired: false,
      tags: const ['guide'],
      summaryStatus: 'ready',
      audioStatus: 'missing',
      listenedStatus: 'not_started',
      notesPath: null,
      extractedTextPath: 'D:/Omega/Guide Two.txt',
      audioManifestPath: null,
    ),
    KnowledgeLibraryItem(
      id: 'archive-note',
      filename: 'archive_note.pdf',
      title: 'Archive Note',
      fullPath: 'D:/Omega/Archive Note.pdf',
      relativePath: 'Archive/Archive Note.pdf',
      sourceSection: 'Operations',
      category: 'Notes',
      fileSizeBytes: 800,
      createdAt: DateTime(2026, 5, 8),
      modifiedAt: DateTime(2026, 5, 9),
      pageCount: 3,
      textExtractable: false,
      ocrRequired: true,
      tags: const ['archive'],
      summaryStatus: 'pending',
      audioStatus: 'unknown',
      listenedStatus: 'not_started',
      notesPath: null,
      extractedTextPath: null,
      audioManifestPath: null,
    ),
  ];

  @override
  Future<KnowledgeLibraryPage> loadPage({
    int limit = 100,
    int offset = 0,
  }) async {
    return KnowledgeLibraryPage(
      total: _items.length,
      limit: limit,
      offset: offset,
      items: _items.skip(offset).take(limit).toList(growable: false),
    );
  }

  @override
  Future<KnowledgeLibraryHealth> loadHealth() async {
    return const KnowledgeLibraryHealth(
      status: 'ok',
      module: 'knowledge_library',
      message: 'Ready',
    );
  }

  @override
  Future<KnowledgeLibrarySearchResult> search({
    required String query,
    int limit = 200,
  }) async {
    final lowered = query.toLowerCase();
    final matches = _items
        .where(
          (item) =>
              item.title.toLowerCase().contains(lowered) ||
              item.filename.toLowerCase().contains(lowered) ||
              item.relativePath.toLowerCase().contains(lowered) ||
              item.tags.any((tag) => tag.toLowerCase().contains(lowered)),
        )
        .take(limit)
        .toList(growable: false);

    return KnowledgeLibrarySearchResult(
      query: query,
      totalMatches: matches.length,
      items: matches,
    );
  }

  @override
  Future<KnowledgeLibraryStats> loadStats() async {
    return const KnowledgeLibraryStats(
      totalPdfs: 3,
      bySourceSection: <String, int>{
        'Operations': 2,
        'Research': 1,
      },
      byCategory: <String, int>{
        'Guides': 2,
        'Notes': 1,
      },
      textExtractable: 2,
      ocrRequired: 1,
      audioGenerated: 1,
    );
  }

  @override
  Future<KnowledgeLibraryExtractionStatus> loadExtractionStatus() async {
    return KnowledgeLibraryExtractionStatus(
      totalPdfs: 3,
      textExtractable: 2,
      ocrRequired: 1,
      extracted: 2,
      failed: 1,
      pending: 1,
      lastRunAt: DateTime(2026, 5, 30, 10, 45),
      statePath: 'D:/Omega/library_state.json',
      reportPath: 'D:/Omega/library_failure_report.md',
    );
  }

  @override
  Future<void> openInDefaultApp(String path) async {}

  @override
  Future<void> openContainingFolder(String path) async {}

  @override
  Future<void> openExtractedTextFolder(String path) async {}

  @override
  Future<void> openFailureReport(String path) async {}

  @override
  Future<void> revealOriginalFile(String path) async {}
}
