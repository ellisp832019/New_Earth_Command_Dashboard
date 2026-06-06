import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main(List<String> args) async {
  final root = Directory.current.path;
  final sourcePath = args.isNotEmpty
      ? path.normalize(path.absolute(args.first))
      : path.join(root, 'docs', 'user_guide', 'voice_assistant_guide.md');
  final outputPath = args.length > 1
      ? path.normalize(path.absolute(args[1]))
      : path.join(root, 'docs', 'user_guide', 'voice_assistant_guide.pdf');

  final sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) {
    stderr.writeln('Voice guide markdown not found: $sourcePath');
    exitCode = 1;
    return;
  }

  final guide = _parseGuide(await sourceFile.readAsString());
  final pdf = pw.Document();

  pdf.addPage(_buildCoverPage(guide));
  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.fromLTRB(36, 28, 36, 36),
        theme: pw.ThemeData.withFont(
          base: pw.Font.times(),
          bold: pw.Font.timesBold(),
        ),
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 8.5,
            color: PdfColors.grey600,
          ),
        ),
      ),
      build: (_) => _buildBodyWidgets(guide),
    ),
  );

  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsBytes(await pdf.save(), flush: true);
  stdout.writeln('Wrote ${outputFile.path}');
}

pw.Page _buildCoverPage(_GuideDoc guide) {
  return pw.Page(
    pageTheme: pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      theme: pw.ThemeData.withFont(
        base: pw.Font.times(),
        bold: pw.Font.timesBold(),
      ),
    ),
    build: (context) {
      return pw.Container(
        color: const PdfColor(0.97, 0.965, 0.94),
        child: pw.Stack(
          children: [
            pw.Positioned(
              right: -60,
              top: -60,
              child: pw.Container(
                width: 220,
                height: 220,
                decoration: const pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColor(0.89, 0.94, 0.93),
                ),
              ),
            ),
            pw.Positioned(
              left: -80,
              bottom: -60,
              child: pw.Container(
                width: 260,
                height: 260,
                decoration: const pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColor(0.91, 0.92, 0.97),
                ),
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.fromLTRB(54, 72, 54, 54),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildCoverLabel('New Earth User Guide'),
                    pw.SizedBox(height: 18),
                  pw.Text(
                    guide.title,
                    style: pw.TextStyle(
                      fontSize: 30,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                      height: 1.05,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.ConstrainedBox(
                    constraints: const pw.BoxConstraints(maxWidth: 360),
                    child: pw.Text(
                      guide.description,
                      style: const pw.TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildPill('Review first'),
                      _buildPill('Local-first'),
                      _buildPill('Calm capture'),
                      _buildPill('Printable copy'),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(18),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(18),
                      border: pw.Border.all(
                        color: const PdfColor(0.84, 0.86, 0.83),
                        width: 0.8,
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'What this guide covers',
                          style: pw.TextStyle(
                            fontSize: 11.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        ...guide.coverBullets.map(
                          (line) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 4),
                            child: pw.Text(
                              '• $line',
                              style: const pw.TextStyle(
                                fontSize: 10.5,
                                height: 1.35,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 18),
                  pw.Text(
                    'Open the printable guide from Voice Assistant with the button at the top of the screen.',
                    style: const pw.TextStyle(
                      fontSize: 10.5,
                      height: 1.35,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

List<pw.Widget> _buildBodyWidgets(_GuideDoc guide) {
  final widgets = <pw.Widget>[];

  for (final section in guide.sections) {
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        padding: const pw.EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(18),
          border: pw.Border.all(
            color: const PdfColor(0.88, 0.89, 0.87),
            width: 0.8,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 7,
                  height: 7,
                  margin: const pw.EdgeInsets.only(top: 6, right: 10),
                  decoration: const pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: PdfColor(0.34, 0.52, 0.47),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    section.title,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            ...section.blocks.map(_buildBlockWidget),
          ],
        ),
      ),
    );
  }

  return widgets;
}

pw.Widget _buildBlockWidget(_GuideBlock block) {
  return switch (block) {
    _ParagraphBlock(:final text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          text,
          style: const pw.TextStyle(
            fontSize: 11.2,
            height: 1.5,
            color: PdfColors.grey800,
          ),
        ),
      ),
    _BulletListBlock(:final items) => pw.Padding(
        padding: const pw.EdgeInsets.only(left: 2, bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: items
              .map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '•',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          item,
                          style: const pw.TextStyle(
                            fontSize: 11.2,
                            height: 1.5,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    _NumberedListBlock(:final items) => pw.Padding(
        padding: const pw.EdgeInsets.only(left: 2, bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$index.',
                    style: const pw.TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(
                      item,
                      style: const pw.TextStyle(
                        fontSize: 11.2,
                        height: 1.5,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    _DividerBlock() => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Divider(
          thickness: 0.7,
          color: const PdfColor(0.85, 0.86, 0.84),
        ),
      ),
    _HeadingBlock(:final text, :final level) => pw.Padding(
        padding: pw.EdgeInsets.only(
          top: level == 2 ? 10 : 4,
          bottom: 6,
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: level == 2 ? 13.5 : 11.5,
            fontWeight: pw.FontWeight.bold,
            color: level == 2 ? PdfColors.grey900 : PdfColors.grey800,
          ),
        ),
      ),
  };
}

pw.Widget _buildCoverLabel(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: pw.BoxDecoration(
      color: const PdfColor(0.86, 0.92, 0.9),
      borderRadius: pw.BorderRadius.circular(999),
    ),
    child: pw.Text(
      text.toUpperCase(),
      style: const pw.TextStyle(
        fontSize: 9,
        letterSpacing: 0.8,
        color: PdfColors.grey700,
      ),
    ),
  );
}

pw.Widget _buildPill(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(999),
      border: pw.Border.all(color: const PdfColor(0.85, 0.88, 0.86)),
    ),
    child: pw.Text(
      text,
      style: const pw.TextStyle(
        fontSize: 10.5,
        color: PdfColors.grey700,
      ),
    ),
  );
}

_GuideDoc _parseGuide(String markdown) {
  final lines = markdown.replaceAll('\r\n', '\n').split('\n');
  final title = <String>[];
  final description = <String>[];
  final coverBullets = <String>[];
  final sections = <_GuideSection>[];
  _GuideSection? currentSection;
  _GuideBlock? currentBlock;

  void flushSection() {
    if (currentSection != null) {
      sections.add(currentSection!);
    }
    currentSection = null;
    currentBlock = null;
  }

  void ensureSection(String sectionTitle) {
    if (currentSection?.title == sectionTitle) {
      return;
    }
    flushSection();
    currentSection = _GuideSection(title: sectionTitle, blocks: []);
  }

  for (final rawLine in lines) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      currentBlock = null;
      continue;
    }

    if (trimmed.startsWith('# ')) {
      title.add(_cleanInlineText(trimmed.substring(2)));
      continue;
    }

    if (title.isNotEmpty && currentSection == null && !trimmed.startsWith('## ')) {
      final text = _cleanInlineText(trimmed);
      if (text.isNotEmpty) {
        if (description.length < 2) {
          description.add(text);
        }
      }
      continue;
    }

    if (trimmed.startsWith('## ')) {
      ensureSection(_cleanInlineText(trimmed.substring(3)));
      continue;
    }

    if (trimmed == '---') {
      if (currentSection != null) {
        currentSection!.blocks.add(const _DividerBlock());
      }
      continue;
    }

    final headingMatch = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(trimmed);
    if (headingMatch != null) {
      final level = headingMatch.group(1)!.length;
      final text = _cleanInlineText(headingMatch.group(2)!);
      if (currentSection != null) {
        currentSection!.blocks.add(_HeadingBlock(text: text, level: level));
      }
      currentBlock = null;
      continue;
    }

    final bulletMatch = RegExp(r'^-\s+(.*)$').firstMatch(trimmed);
    if (bulletMatch != null) {
      ensureSection(currentSection?.title ?? 'Guide');
      currentBlock = _appendBullet(currentSection!, currentBlock, _cleanInlineText(bulletMatch.group(1)!));
      continue;
    }

    final numberedMatch = RegExp(r'^\d+\.\s+(.*)$').firstMatch(trimmed);
    if (numberedMatch != null) {
      ensureSection(currentSection?.title ?? 'Guide');
      currentBlock = _appendNumbered(currentSection!, currentBlock, _cleanInlineText(numberedMatch.group(1)!));
      continue;
    }

    ensureSection(currentSection?.title ?? 'Guide');
    currentBlock = _appendParagraph(currentSection!, currentBlock, _cleanInlineText(trimmed));
    if (currentSection == null) {
      coverBullets.add(_cleanInlineText(trimmed));
    }
  }

  flushSection();

  final safeTitle = title.isEmpty ? 'Voice Assistant Guide' : title.first;
  final safeDescription = description.isEmpty
      ? 'A calm local-first guide to the Voice Assistant.'
      : description.join(' ');

  final fallbackCoverBullets = coverBullets.isEmpty
      ? [
          'Speak, review, and save with a calm local-first flow.',
          'Use the briefing card and AI preview as a guide, not a decision.',
          'Open the printable PDF from Voice Assistant when you want the clean reading copy.',
        ]
      : coverBullets;

  return _GuideDoc(
    title: safeTitle,
    description: safeDescription,
    coverBullets: fallbackCoverBullets.take(4).toList(),
    sections: sections,
  );
}

_GuideBlock _appendParagraph(
  _GuideSection section,
  _GuideBlock? currentBlock,
  String text,
) {
  if (currentBlock is _ParagraphBlock) {
    currentBlock.parts.add(text);
    return currentBlock;
  }

  final block = _ParagraphBlock(parts: [text]);
  section.blocks.add(block);
  return block;
}

_GuideBlock _appendBullet(
  _GuideSection section,
  _GuideBlock? currentBlock,
  String text,
) {
  if (currentBlock is _BulletListBlock) {
    currentBlock.items.add(text);
    return currentBlock;
  }

  final block = _BulletListBlock(items: [text]);
  section.blocks.add(block);
  return block;
}

_GuideBlock _appendNumbered(
  _GuideSection section,
  _GuideBlock? currentBlock,
  String text,
) {
  if (currentBlock is _NumberedListBlock) {
    currentBlock.items.add(text);
    return currentBlock;
  }

  final block = _NumberedListBlock(items: [text]);
  section.blocks.add(block);
  return block;
}

String _cleanInlineText(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
        (match) => match.group(1) ?? '',
      )
      .replaceAll(r"\'", "'")
      .replaceAll('`', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class _GuideDoc {
  _GuideDoc({
    required this.title,
    required this.description,
    required this.coverBullets,
    required this.sections,
  });

  final String title;
  final String description;
  final List<String> coverBullets;
  final List<_GuideSection> sections;
}

class _GuideSection {
  _GuideSection({required this.title, required this.blocks});

  final String title;
  final List<_GuideBlock> blocks;
}

sealed class _GuideBlock {
  const _GuideBlock();
}

class _ParagraphBlock extends _GuideBlock {
  _ParagraphBlock({required this.parts});

  final List<String> parts;
  String get text => parts.join(' ');
}

class _BulletListBlock extends _GuideBlock {
  _BulletListBlock({required this.items});

  final List<String> items;
}

class _NumberedListBlock extends _GuideBlock {
  _NumberedListBlock({required this.items});

  final List<String> items;
}

class _DividerBlock extends _GuideBlock {
  const _DividerBlock();
}

class _HeadingBlock extends _GuideBlock {
  const _HeadingBlock({required this.text, required this.level});

  final String text;
  final int level;
}
