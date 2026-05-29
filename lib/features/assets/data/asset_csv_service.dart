import 'dart:io';

import 'asset_change_journal.dart';

class AssetCsvTable {
  const AssetCsvTable({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<Map<String, String>> rows;
}

class AssetCsvService {
  Future<AssetCsvTable> readTable(
    File file, {
    List<String> expectedHeaders = const <String>[],
  }) async {
    if (!await file.exists()) {
      return AssetCsvTable(
        headers: expectedHeaders,
        rows: <Map<String, String>>[],
      );
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return AssetCsvTable(
        headers: expectedHeaders,
        rows: <Map<String, String>>[],
      );
    }

    final parsedHeaders = _parseCsvLine(lines.first)
        .map((header) => header.trim())
        .where((header) => header.isNotEmpty)
        .toList(growable: false);
    final headers = parsedHeaders.isNotEmpty
        ? parsedHeaders
        : List<String>.from(expectedHeaders);
    final rows = <Map<String, String>>[];

    for (final rawLine in lines.skip(1)) {
      if (rawLine.trim().isEmpty) {
        continue;
      }

      final values = _parseCsvLine(rawLine);
      final row = <String, String>{};
      for (var index = 0; index < headers.length; index++) {
        final header = headers[index];
        row[header] = index < values.length ? values[index] : '';
      }

      rows.add(row);
    }

    return AssetCsvTable(headers: headers, rows: rows);
  }

  Future<void> writeTable(File file, AssetCsvTable table) async {
    if (await file.exists()) {
      final backupFile = File('${file.path}.bak');
      await file.copy(backupFile.path);
    } else {
      await file.parent.create(recursive: true);
    }

    final headers = _mergeHeaders(table.headers, table.rows);
    final lines = <String>[
      headers.join(','),
      ...table.rows.map((row) => _encodeRow(headers, row)),
    ];

    await file.writeAsString('${lines.join('\n')}\n');
  }

  Future<AssetCsvTable> replaceRows(
    File file,
    List<Map<String, String>> rows, {
    List<String> expectedHeaders = const <String>[],
  }) async {
    final existing = await readTable(
      file,
      expectedHeaders: expectedHeaders,
    );
    final table = AssetCsvTable(
      headers: _mergeHeaders(existing.headers, rows),
      rows: rows,
    );
    await writeTable(file, table);
    return table;
  }

  Future<AssetCsvTable> appendRow(
    File file,
    Map<String, String> row, {
    List<String> expectedHeaders = const <String>[],
  }) async {
    final existing = await readTable(
      file,
      expectedHeaders: expectedHeaders,
    );
    final rows = <Map<String, String>>[
      ...existing.rows,
      row,
    ];
    final table = AssetCsvTable(
      headers: _mergeHeaders(existing.headers, rows),
      rows: rows,
    );
    await writeTable(file, table);
    return table;
  }

  Future<AssetCsvTable> appendJournalEntry(
    File file,
    AssetChangeJournalEntry entry,
  ) {
    return appendRow(
      file,
      entry.toCsvRow(),
      expectedHeaders: AssetChangeJournalEntry.headers,
    );
  }

  Future<List<AssetChangeJournalEntry>> readJournalEntries(File file) async {
    final table = await readTable(
      file,
      expectedHeaders: AssetChangeJournalEntry.headers,
    );
    return table.rows
        .map(AssetChangeJournalEntry.fromCsvRow)
        .toList(growable: false);
  }

  List<AssetChangeJournalEntry> compactJournalEntries(
    Iterable<AssetChangeJournalEntry> entries,
  ) {
    final latestByRecord = <String, AssetChangeJournalEntry>{};

    for (final entry in entries) {
      final recordKey =
          '${entry.recordType.trim().toLowerCase()}::${entry.recordId.trim()}';
      final existing = latestByRecord[recordKey];
      if (existing == null ||
          entry.timestamp.isAfter(existing.timestamp) ||
          entry.timestamp.isAtSameMomentAs(existing.timestamp)) {
        latestByRecord[recordKey] = entry;
      }
    }

    final compacted = latestByRecord.values.toList(growable: false);
    compacted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return compacted;
  }

  Future<AssetCsvTable> writeJournalSnapshot(
    File file,
    Iterable<AssetChangeJournalEntry> entries,
  ) async {
    final compacted = compactJournalEntries(entries);
    final table = AssetCsvTable(
      headers: AssetChangeJournalEntry.headers,
      rows: compacted.map((entry) => entry.toCsvRow()).toList(growable: false),
    );
    await writeTable(file, table);
    return table;
  }

  List<String> _mergeHeaders(
    List<String> headers,
    Iterable<Map<String, String>> rows,
  ) {
    final merged = <String>[];
    for (final header in headers) {
      final trimmed = header.trim();
      if (trimmed.isNotEmpty && !merged.contains(trimmed)) {
        merged.add(trimmed);
      }
    }

    for (final row in rows) {
      for (final key in row.keys) {
        final trimmed = key.trim();
        if (trimmed.isNotEmpty && !merged.contains(trimmed)) {
          merged.add(trimmed);
        }
      }
    }

    return merged;
  }

  String _encodeRow(List<String> headers, Map<String, String> row) {
    return headers.map((header) => _csvCell(row[header] ?? '')).join(',');
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      if (char == '"') {
        if (inQuotes && index + 1 < line.length && line[index + 1] == '"') {
          buffer.write('"');
          index++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (char == ',' && !inQuotes) {
        values.add(buffer.toString());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    values.add(buffer.toString());
    return values;
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
