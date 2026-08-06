import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class LocalPdfScreen extends StatelessWidget {
  const LocalPdfScreen({super.key, required this.title, required this.pdfPath});

  final String title;
  final String pdfPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(title)),
      body: PdfViewer.file(pdfPath, params: const PdfViewerParams()),
    );
  }
}

Future<void> openLocalPdfDocument(
  BuildContext context, {
  required String title,
  required String pdfPath,
}) async {
  final file = File(pdfPath);
  if (!await file.exists()) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title not found at ${file.path}')));
    return;
  }

  if (!context.mounted) {
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LocalPdfScreen(title: title, pdfPath: file.path),
    ),
  );
}
