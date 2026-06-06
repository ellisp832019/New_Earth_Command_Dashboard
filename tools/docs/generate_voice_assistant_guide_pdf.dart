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
  pdf.addPage(_buildContentPages(guide));

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
    build: (_) {
      return pw.Container(
        color: const PdfColor(0.976, 0.972, 0.962),
        child: pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(56, 70, 56, 54),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'New Earth User Guide',
                style: pw.TextStyle(
                  fontSize: 9.8,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.0,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(width: 96, height: 1, color: const PdfColor(0.7, 0.72, 0.7)),
              pw.SizedBox(height: 18),
              pw.Text(
                guide.title,
                style: pw.TextStyle(
                  fontSize: 25,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                  height: 1.08,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.ConstrainedBox(
                constraints: const pw.BoxConstraints(maxWidth: 380),
                child: pw.Text(
                  guide.description,
                  style: const pw.TextStyle(
                    fontSize: 10.4,
                    height: 1.45,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 26),
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPill('Review first'),
                  _buildPill('Local-first'),
                  _buildPill('Printable'),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                'Open the printable guide from the Voice Assistant button at the top of the screen.',
                style: const pw.TextStyle(
                  fontSize: 8.8,
                  height: 1.4,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

pw.MultiPage _buildContentPages(_GuideDoc guide) {
  return pw.MultiPage(
    pageTheme: pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 24, 36, 34),
      theme: pw.ThemeData.withFont(
        base: pw.Font.times(),
        bold: pw.Font.timesBold(),
      ),
    ),
    header: (_) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Voice Assistant Guide',
                style: pw.TextStyle(
                  fontSize: 9.6,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.5,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Container(width: 110, height: 1, color: const PdfColor(0.72, 0.74, 0.72)),
            ],
          ),
          pw.Text(
            'Printable reference',
            style: const pw.TextStyle(
              fontSize: 7.8,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    ),
    footer: (context) => pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 7.8,
          color: PdfColors.grey600,
        ),
      ),
    ),
    build: (_) => _buildBodyWidgets(guide),
  );
}

List<pw.Widget> _buildBodyWidgets(_GuideDoc guide) {
  final widgets = <pw.Widget>[];

  for (final section in guide.sections) {
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(16),
          border: pw.Border.all(
            color: const PdfColor(0.88, 0.89, 0.87),
            width: 0.7,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              section.title,
              style: pw.TextStyle(
                fontSize: 11.8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 8),
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
    _ParagraphBlock(:final parts) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 7),
        child: pw.Text(
          parts.join(' '),
          style: const pw.TextStyle(
            fontSize: 9.4,
            height: 1.42,
            color: PdfColors.grey800,
          ),
        ),
      ),
    _BulletListBlock(:final items) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 7),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: items
              .map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '•',
                        style: const pw.TextStyle(
                          fontSize: 9.4,
                          height: 1.42,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(width: 7),
                      pw.Expanded(
                        child: pw.Text(
                          item,
                          style: const pw.TextStyle(
                            fontSize: 9.4,
                            height: 1.42,
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
        padding: const pw.EdgeInsets.only(bottom: 7),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$index.',
                    style: const pw.TextStyle(
                      fontSize: 9.2,
                      height: 1.42,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(width: 7),
                  pw.Expanded(
                    child: pw.Text(
                      item,
                      style: const pw.TextStyle(
                        fontSize: 9.4,
                        height: 1.42,
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
          thickness: 0.6,
          color: const PdfColor(0.86, 0.87, 0.85),
        ),
      ),
    _HeadingBlock(:final text, :final level) => pw.Padding(
        padding: pw.EdgeInsets.only(
          top: level == 2 ? 8 : 3,
          bottom: 5,
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: level == 2 ? 11.0 : 9.6,
            fontWeight: pw.FontWeight.bold,
            color: level == 2 ? PdfColors.grey900 : PdfColors.grey800,
          ),
        ),
      ),
  };
}

pw.Widget _buildPill(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(999),
      border: pw.Border.all(color: const PdfColor(0.85, 0.88, 0.86), width: 0.7),
    ),
    child: pw.Text(
      text,
      style: const pw.TextStyle(
        fontSize: 8.2,
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
  bool seenBody = false;

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

    if (!seenBody && title.isNotEmpty && !trimmed.startsWith('## ')) {
      final text = _cleanInlineText(trimmed);
      if (text.isNotEmpty) {
        if (description.length < 2) {
          description.add(text);
          continue;
        }
        coverBullets.add(text);
        continue;
      }
    }

    if (trimmed.startsWith('## ')) {
      seenBody = true;
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
      seenBody = true;
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
      seenBody = true;
      final text = _cleanInlineText(bulletMatch.group(1)!);
      if (currentSection == null) {
        coverBullets.add(text);
      } else {
        currentBlock = _appendBullet(currentSection!, currentBlock, text);
      }
      continue;
    }

    final numberedMatch = RegExp(r'^\d+\.\s+(.*)$').firstMatch(trimmed);
    if (numberedMatch != null) {
      seenBody = true;
      ensureSection(currentSection?.title ?? 'Guide');
      currentBlock = _appendNumbered(
        currentSection!,
        currentBlock,
        _cleanInlineText(numberedMatch.group(1)!),
      );
      continue;
    }

    seenBody = true;
    ensureSection(currentSection?.title ?? 'Guide');
    currentBlock = _appendParagraph(
      currentSection!,
      currentBlock,
      _cleanInlineText(trimmed),
    );
  }

  flushSection();

  return _GuideDoc(
    title: title.isEmpty ? 'Voice Assistant Guide' : title.first,
    description: description.isEmpty
        ? 'A calm local-first guide to the Voice Assistant.'
        : description.join(' '),
    coverBullets: coverBullets.isEmpty
        ? const [
            'Speak, review, and save with a calm local-first flow.',
            'Use the briefing card and AI preview as a guide, not a decision.',
            'Open the printable PDF from Voice Assistant when you want the clean reading copy.',
          ]
        : coverBullets.take(3).toList(),
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
