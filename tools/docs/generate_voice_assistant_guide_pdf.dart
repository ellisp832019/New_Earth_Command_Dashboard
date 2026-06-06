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

  final markdown = await sourceFile.readAsString();
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageTheme: const pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.fromLTRB(40, 40, 40, 44),
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ),
      build: (_) => _buildWidgets(markdown),
    ),
  );

  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsBytes(await pdf.save(), flush: true);
  stdout.writeln('Wrote ${outputFile.path}');
}

List<pw.Widget> _buildWidgets(String markdown) {
  final widgets = <pw.Widget>[];
  final lines = markdown.replaceAll('\r\n', '\n').split('\n');
  final paragraph = <String>[];
  int numberIndex = 1;

  void flushParagraph() {
    if (paragraph.isEmpty) {
      return;
    }

    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(
          _cleanInlineText(paragraph.join(' ')),
          style: const pw.TextStyle(fontSize: 11, height: 1.35),
        ),
      ),
    );
    paragraph.clear();
  }

  for (final rawLine in lines) {
    final line = rawLine.trimRight();
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      flushParagraph();
      numberIndex = 1;
      widgets.add(pw.SizedBox(height: 2));
      continue;
    }

    if (trimmed == '---') {
      flushParagraph();
      numberIndex = 1;
      widgets.add(pw.SizedBox(height: 8));
      widgets.add(
        pw.Divider(
          thickness: 0.7,
          color: PdfColors.grey400,
        ),
      );
      widgets.add(pw.SizedBox(height: 8));
      continue;
    }

    if (trimmed.startsWith('```')) {
      flushParagraph();
      continue;
    }

    final headingMatch = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(trimmed);
    if (headingMatch != null) {
      flushParagraph();
      numberIndex = 1;
      final level = headingMatch.group(1)!.length;
      final text = _cleanInlineText(headingMatch.group(2)!);
      widgets.add(_buildHeading(text, level));
      widgets.add(pw.SizedBox(height: 4));
      continue;
    }

    final bulletMatch = RegExp(r'^-\s+(.*)$').firstMatch(trimmed);
    if (bulletMatch != null) {
      flushParagraph();
      numberIndex = 1;
      widgets.add(_buildBullet(_cleanInlineText(bulletMatch.group(1)!)));
      continue;
    }

    final numberedMatch = RegExp(r'^\d+\.\s+(.*)$').firstMatch(trimmed);
    if (numberedMatch != null) {
      flushParagraph();
      widgets.add(
        _buildNumbered(numberIndex, _cleanInlineText(numberedMatch.group(1)!)),
      );
      numberIndex++;
      continue;
    }

    paragraph.add(trimmed);
  }

  flushParagraph();
  return widgets;
}

pw.Widget _buildHeading(String text, int level) {
  final style = switch (level) {
    1 => pw.TextStyle(
        fontSize: 24,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey900,
      ),
    2 => pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey900,
      ),
    _ => pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey800,
      ),
  };

  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
    child: pw.Text(text, style: style),
  );
}

pw.Widget _buildBullet(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('•  ', style: const pw.TextStyle(fontSize: 11, height: 1.35)),
        pw.Expanded(
          child: pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 11, height: 1.35),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildNumbered(int index, String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$index.  ',
          style: const pw.TextStyle(fontSize: 11, height: 1.35),
        ),
        pw.Expanded(
          child: pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 11, height: 1.35),
          ),
        ),
      ],
    ),
  );
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
