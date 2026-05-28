import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

enum TreasuryStatusKind { safe, watch, pause, decision, future, archived }

class TreasuryStateSummary {
  const TreasuryStateSummary({
    required this.kind,
    required this.title,
    required this.count,
    required this.items,
    required this.subtitle,
  });

  final TreasuryStatusKind kind;
  final String title;
  final int count;
  final List<String> items;
  final String subtitle;
}

class TreasuryWorkspaceSnapshot {
  const TreasuryWorkspaceSnapshot({
    required this.configPath,
    required this.financeRootPath,
    required this.isReady,
    required this.issues,
    required this.requiredFolders,
    required this.missingFolders,
    required this.missingFiles,
    required this.stateSummaries,
    required this.receiptsToSortCount,
    required this.weeklyRitualSteps,
    required this.lowEnergySteps,
    required this.guidanceNote,
  });

  final String configPath;
  final String? financeRootPath;
  final bool isReady;
  final List<String> issues;
  final List<String> requiredFolders;
  final List<String> missingFolders;
  final List<String> missingFiles;
  final List<TreasuryStateSummary> stateSummaries;
  final int receiptsToSortCount;
  final List<String> weeklyRitualSteps;
  final List<String> lowEnergySteps;
  final String guidanceNote;
}

class TreasuryWeeklyReviewSaveResult {
  const TreasuryWeeklyReviewSaveResult({
    required this.reviewPath,
    required this.weeklyStatusPath,
    required this.dashboardStatePath,
  });

  final String reviewPath;
  final String weeklyStatusPath;
  final String dashboardStatePath;
}

class TreasuryReceiptSaveResult {
  const TreasuryReceiptSaveResult({required this.receiptIndexPath});

  final String receiptIndexPath;
}

class TreasuryProjectSpendSaveResult {
  const TreasuryProjectSpendSaveResult({required this.projectSpendTrackerPath});

  final String projectSpendTrackerPath;
}

class TreasuryFolderService {
  TreasuryFolderService({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current;

  static const _configRelativePath = 'config/local_paths.json';
  static const _financeRootKey = 'finance_treasury_path';

  static const requiredFolders = <String>[
    '00_FINANCE_DASHBOARD',
    '01_HAYLEY_FINANCE_QUEEN_GUIDE',
    '04_PROJECT_SPEND_TRACKERS',
    '05_RECEIPTS_AND_INVOICES',
    '06_SUBSCRIPTIONS_AND_RECURRING_COSTS',
    '10_FINANCE_MEETING_NOTES',
    '15_TEMPLATES',
  ];

  static const requiredFiles = <String>[
    '00_FINANCE_DASHBOARD/dashboard_state.json',
    '00_FINANCE_DASHBOARD/weekly_status.json',
    '04_PROJECT_SPEND_TRACKERS/project_spend_tracker.csv',
    '05_RECEIPTS_AND_INVOICES/receipt_index.csv',
    '06_SUBSCRIPTIONS_AND_RECURRING_COSTS/subscription_tracker.csv',
    '10_FINANCE_MEETING_NOTES/decisions_register.csv',
  ];

  static const weeklyRitualSteps = <String>[
    'Check balances',
    'Sort receipts',
    'Review subscriptions',
    'Review project spending',
    'Mark safe / watch / pause / decision',
    'Save the review',
  ];

  static const lowEnergySteps = <String>[
    'Safe',
    'Watch',
    'Needs decision',
    'One short note',
  ];

  final Directory _workingDirectory;

  Future<TreasuryWorkspaceSnapshot> loadWorkspace() async {
    final configFile = File(
      path.join(_workingDirectory.path, _configRelativePath),
    );
    final issues = <String>[];
    String? financeRootPath;

    if (!await configFile.exists()) {
      issues.add(
        'config/local_paths.json was not found in the dashboard repo.',
      );
    } else {
      try {
        final decoded = jsonDecode(await configFile.readAsString());
        if (decoded is Map<String, dynamic>) {
          final value = decoded[_financeRootKey];
          if (value is String && value.trim().isNotEmpty) {
            financeRootPath = value.trim();
          } else {
            issues.add(
              'finance_treasury_path is missing from config/local_paths.json.',
            );
          }
        } else {
          issues.add('config/local_paths.json should contain a JSON object.');
        }
      } on FormatException {
        issues.add('config/local_paths.json could not be read as JSON.');
      } on FileSystemException {
        issues.add('config/local_paths.json could not be opened.');
      }
    }

    Directory? financeRoot;
    if (financeRootPath != null) {
      financeRoot = Directory(financeRootPath);
      if (!await financeRoot.exists()) {
        issues.add('The finance folder does not exist at the configured path.');
      }
    }

    final missingFolders = <String>[];
    if (financeRoot != null && await financeRoot.exists()) {
      for (final relativeFolder in requiredFolders) {
        final candidate = Directory(
          path.join(financeRoot.path, relativeFolder),
        );
        if (!await candidate.exists()) {
          missingFolders.add(relativeFolder);
        }
      }
    }

    final missingFiles = <String>[];
    if (financeRoot != null && await financeRoot.exists()) {
      for (final relativeFile in requiredFiles) {
        final candidate = File(path.join(financeRoot.path, relativeFile));
        if (!await candidate.exists()) {
          missingFiles.add(relativeFile);
        }
      }
    }

    final stateMap = await _readStateMap(financeRoot);
    final receiptsToSortCount = await _countReceiptsToSort(financeRoot);

    final stateSummaries = <TreasuryStateSummary>[
      _buildSummary(
        kind: TreasuryStatusKind.safe,
        title: 'Safe to Spend',
        items: stateMap[TreasuryStatusKind.safe] ?? const <String>[],
        subtitle: 'Everything here is calm and clear enough to move ahead.',
      ),
      _buildSummary(
        kind: TreasuryStatusKind.watch,
        title: 'Watch Areas',
        items: stateMap[TreasuryStatusKind.watch] ?? const <String>[],
        subtitle: 'Keep an eye on these before they become noisy.',
      ),
      _buildSummary(
        kind: TreasuryStatusKind.pause,
        title: 'Pause Spending',
        items: stateMap[TreasuryStatusKind.pause] ?? const <String>[],
        subtitle: 'Hold here until the money picture feels steadier.',
      ),
      _buildSummary(
        kind: TreasuryStatusKind.decision,
        title: 'Needs Decision',
        items: stateMap[TreasuryStatusKind.decision] ?? const <String>[],
        subtitle: 'These items are waiting for a clear choice together.',
      ),
      _buildSummary(
        kind: TreasuryStatusKind.future,
        title: 'Future Investment',
        items: stateMap[TreasuryStatusKind.future] ?? const <String>[],
        subtitle: 'Useful ideas that can wait until the timing is right.',
      ),
      _buildSummary(
        kind: TreasuryStatusKind.archived,
        title: 'Archived',
        items: stateMap[TreasuryStatusKind.archived] ?? const <String>[],
        subtitle: 'Older notes kept for reference, not daily attention.',
      ),
    ];

    final guidanceNote = financeRoot == null
        ? 'The Treasury area will calm down once the external Omega OS folder is linked.'
        : missingFolders.isEmpty
        ? 'The external finance folder is connected. Keep the system local-first and only write with care.'
        : 'The finance folder is present, but a few expected Omega OS folders still need attention.';

    return TreasuryWorkspaceSnapshot(
      configPath: configFile.path,
      financeRootPath: financeRootPath,
      isReady:
          issues.isEmpty &&
          financeRootPath != null &&
          missingFolders.isEmpty &&
          missingFiles.isEmpty,
      issues: issues,
      requiredFolders: requiredFolders,
      missingFolders: missingFolders,
      missingFiles: missingFiles,
      stateSummaries: stateSummaries,
      receiptsToSortCount: receiptsToSortCount,
      weeklyRitualSteps: weeklyRitualSteps,
      lowEnergySteps: lowEnergySteps,
      guidanceNote: guidanceNote,
    );
  }

  Future<List<String>> createMissingRequiredFiles() async {
    final snapshot = await loadWorkspace();
    final financeRootPath = snapshot.financeRootPath;
    if (financeRootPath == null) {
      return <String>[];
    }

    final financeRoot = Directory(financeRootPath);
    if (!await financeRoot.exists()) {
      return <String>[];
    }

    final createdFiles = <String>[];
    for (final relativeFile in requiredFiles) {
      final candidate = File(path.join(financeRoot.path, relativeFile));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.parent.create(recursive: true);
      await candidate.writeAsString(_templateForRequiredFile(relativeFile));
      createdFiles.add(relativeFile);
    }

    return createdFiles;
  }

  Future<void> writeTextFileWithBackup(File file, String contents) async {
    if (await file.exists()) {
      final backupFile = File('${file.path}.bak');
      await file.copy(backupFile.path);
    } else {
      await file.parent.create(recursive: true);
    }

    await file.writeAsString(contents);
  }

  Future<TreasuryWeeklyReviewSaveResult> saveWeeklyReview({
    required String financeRootPath,
    required List<String> safeItems,
    required List<String> watchItems,
    required List<String> pauseItems,
    required List<String> decisionItems,
    required String closingNote,
    required DateTime reviewedAt,
  }) async {
    final financeRoot = Directory(financeRootPath);
    final reviewFolder = Directory(
      path.join(
        financeRoot.path,
        '10_FINANCE_MEETING_NOTES',
        'Weekly_Finance_Queen_Reviews',
      ),
    );
    await reviewFolder.create(recursive: true);

    final dayStamp = _dateStamp(reviewedAt);
    final reviewFile = File(
      path.join(reviewFolder.path, '${dayStamp}_weekly_finance_review.md'),
    );
    final weeklyStatusFile = File(
      path.join(financeRoot.path, '00_FINANCE_DASHBOARD', 'weekly_status.json'),
    );
    final dashboardStateFile = File(
      path.join(
        financeRoot.path,
        '00_FINANCE_DASHBOARD',
        'dashboard_state.json',
      ),
    );

    final reviewContent = _buildWeeklyReviewMarkdown(
      reviewedAt: reviewedAt,
      safeItems: safeItems,
      watchItems: watchItems,
      pauseItems: pauseItems,
      decisionItems: decisionItems,
      closingNote: closingNote,
    );
    await writeTextFileWithBackup(reviewFile, reviewContent);

    final weeklyStatusContent = const JsonEncoder.withIndent('  ').convert({
      'review_date': dayStamp,
      'balance_checked': true,
      'receipts_sorted': true,
      'subscriptions_reviewed': true,
      'project_spend_reviewed': true,
      'notes': closingNote,
      'safe_count': safeItems.length,
      'watch_count': watchItems.length,
      'pause_count': pauseItems.length,
      'decision_count': decisionItems.length,
    });
    await writeTextFileWithBackup(weeklyStatusFile, weeklyStatusContent);

    final dashboardStateContent = const JsonEncoder.withIndent('  ').convert({
      'updated_at': reviewedAt.toIso8601String(),
      'weekly_review_file': path.join(
        '10_FINANCE_MEETING_NOTES',
        'Weekly_Finance_Queen_Reviews',
        '${dayStamp}_weekly_finance_review.md',
      ),
      'safe': safeItems,
      'watch': watchItems,
      'pause': pauseItems,
      'decision': decisionItems,
      'notes': closingNote,
    });
    await writeTextFileWithBackup(dashboardStateFile, dashboardStateContent);

    return TreasuryWeeklyReviewSaveResult(
      reviewPath: reviewFile.path,
      weeklyStatusPath: weeklyStatusFile.path,
      dashboardStatePath: dashboardStateFile.path,
    );
  }

  TreasuryStateSummary _buildSummary({
    required TreasuryStatusKind kind,
    required String title,
    required List<String> items,
    required String subtitle,
  }) {
    return TreasuryStateSummary(
      kind: kind,
      title: title,
      count: items.length,
      items: items,
      subtitle: items.isEmpty ? '$subtitle No items are listed yet.' : subtitle,
    );
  }

  Future<Map<TreasuryStatusKind, List<String>>> _readStateMap(
    Directory? financeRoot,
  ) async {
    final map = <TreasuryStatusKind, List<String>>{
      TreasuryStatusKind.safe: <String>[],
      TreasuryStatusKind.watch: <String>[],
      TreasuryStatusKind.pause: <String>[],
      TreasuryStatusKind.decision: <String>[],
      TreasuryStatusKind.future: <String>[],
      TreasuryStatusKind.archived: <String>[],
    };

    if (financeRoot == null) {
      return map;
    }

    final boardFile = File(
      path.join(
        financeRoot.path,
        '00_FINANCE_DASHBOARD',
        'SAFE_WATCH_STOP_DECISION_BOARD.md',
      ),
    );

    if (!await boardFile.exists()) {
      return map;
    }

    TreasuryStatusKind? currentKind;
    for (final rawLine in await boardFile.readAsLines()) {
      final line = rawLine.trim();
      if (line.startsWith('## ')) {
        currentKind = _kindFromHeading(line);
        continue;
      }

      if (currentKind == null) {
        continue;
      }

      if (line == '-' || line == '- ' || line.isEmpty) {
        continue;
      }

      if (line.startsWith('- ')) {
        map[currentKind]!.add(line.substring(2).trim());
      }
    }

    return map;
  }

  TreasuryStatusKind? _kindFromHeading(String heading) {
    final lower = heading.toLowerCase();
    if (lower.contains('safe')) {
      return TreasuryStatusKind.safe;
    }
    if (lower.contains('watch')) {
      return TreasuryStatusKind.watch;
    }
    if (lower.contains('stop')) {
      return TreasuryStatusKind.pause;
    }
    if (lower.contains('decision')) {
      return TreasuryStatusKind.decision;
    }
    if (lower.contains('future')) {
      return TreasuryStatusKind.future;
    }
    if (lower.contains('archived')) {
      return TreasuryStatusKind.archived;
    }
    return null;
  }

  Future<int> _countReceiptsToSort(Directory? financeRoot) async {
    if (financeRoot == null) {
      return 0;
    }

    final receiptsFolder = Directory(
      path.join(financeRoot.path, '05_RECEIPTS_AND_INVOICES', '00_TO_SORT'),
    );

    if (await receiptsFolder.exists()) {
      final entries = await receiptsFolder.list(followLinks: false).toList();
      return entries.where((entry) {
        final name = path.basename(entry.path).toLowerCase();
        return name != 'readme.md' &&
            name != '_folder_icon.ico' &&
            name != 'desktop.ini';
      }).length;
    }

    final receiptIndex = File(
      path.join(
        financeRoot.path,
        '05_RECEIPTS_AND_INVOICES',
        'receipt_index.csv',
      ),
    );

    if (!await receiptIndex.exists()) {
      return 0;
    }

    final lines = await receiptIndex.readAsLines();
    return lines.where((line) => line.trim().isNotEmpty).length > 1
        ? lines.length - 1
        : 0;
  }

  String _templateForRequiredFile(String relativePath) {
    switch (relativePath) {
      case '00_FINANCE_DASHBOARD/dashboard_state.json':
        return const JsonEncoder.withIndent('  ').convert({
          'updated_at': null,
          'safe': <String>[],
          'watch': <String>[],
          'pause': <String>[],
          'decision': <String>[],
          'future': <String>[],
          'archived': <String>[],
        });
      case '00_FINANCE_DASHBOARD/weekly_status.json':
        return const JsonEncoder.withIndent('  ').convert({
          'review_date': null,
          'balance_checked': false,
          'receipts_sorted': false,
          'subscriptions_reviewed': false,
          'project_spend_reviewed': false,
          'notes': '',
        });
      case '04_PROJECT_SPEND_TRACKERS/project_spend_tracker.csv':
        return 'date,project,item,supplier,amount,category,receipt_saved,status,notes\n';
      case '05_RECEIPTS_AND_INVOICES/receipt_index.csv':
        return 'Date,Item,Supplier,Amount,PersonalOrNewEarth,Project,FileLocation,Notes\n';
      case '06_SUBSCRIPTIONS_AND_RECURRING_COSTS/subscription_tracker.csv':
        return 'service,purpose,cost,renewal_date,payment_source,status,keep_cancel_review,notes\n';
      case '10_FINANCE_MEETING_NOTES/decisions_register.csv':
        return 'date,decision_needed,amount,status,decision,owner,notes\n';
      default:
        return '';
    }
  }

  String _buildWeeklyReviewMarkdown({
    required DateTime reviewedAt,
    required List<String> safeItems,
    required List<String> watchItems,
    required List<String> pauseItems,
    required List<String> decisionItems,
    required String closingNote,
  }) {
    final dateLabel = _dateStamp(reviewedAt);
    return [
      '# Weekly Finance Review',
      '',
      'Date: $dateLabel',
      'Reviewed by: Hayley',
      '',
      '## 🟢 Safe',
      ..._markdownBullets(safeItems),
      '',
      '## 🟡 Watch',
      ..._markdownBullets(watchItems),
      '',
      '## 🔴 Pause',
      ..._markdownBullets(pauseItems),
      '',
      '## 🔵 Needs decision',
      ..._markdownBullets(decisionItems),
      '',
      '## This week, money is telling us',
      closingNote.trim().isEmpty ? '- ' : closingNote.trim(),
      '',
    ].join('\n');
  }

  Future<TreasuryReceiptSaveResult> saveReceiptRecord({
    required String financeRootPath,
    required String item,
    required String supplier,
    required String amount,
    required String personalOrNewEarth,
    required String project,
    required String fileLocation,
    required String notes,
    required DateTime recordedAt,
  }) async {
    final receiptIndexFile = File(
      path.join(
        financeRootPath,
        '05_RECEIPTS_AND_INVOICES',
        'receipt_index.csv',
      ),
    );
    await receiptIndexFile.parent.create(recursive: true);

    final existingLines = await receiptIndexFile.exists()
        ? await receiptIndexFile.readAsLines()
        : <String>[];
    final header =
        'Date,Item,Supplier,Amount,PersonalOrNewEarth,Project,FileLocation,Notes';
    final rows = <String>[
      if (existingLines.isEmpty) header,
      if (existingLines.isNotEmpty) ...existingLines,
      _csvJoin([
        _dateStamp(recordedAt),
        item,
        supplier,
        amount,
        personalOrNewEarth,
        project,
        fileLocation,
        notes,
      ]),
    ];

    await writeTextFileWithBackup(receiptIndexFile, '${rows.join('\n')}\n');

    return TreasuryReceiptSaveResult(receiptIndexPath: receiptIndexFile.path);
  }

  Future<TreasuryProjectSpendSaveResult> saveProjectSpendRecord({
    required String financeRootPath,
    required String project,
    required String item,
    required String supplier,
    required String amount,
    required String category,
    required String receiptSaved,
    required String status,
    required String notes,
    required DateTime recordedAt,
  }) async {
    final spendTrackerFile = File(
      path.join(
        financeRootPath,
        '04_PROJECT_SPEND_TRACKERS',
        'project_spend_tracker.csv',
      ),
    );
    await spendTrackerFile.parent.create(recursive: true);

    final existingLines = await spendTrackerFile.exists()
        ? await spendTrackerFile.readAsLines()
        : <String>[];
    final header =
        'Date,Project,Item,Supplier,Amount,Category,ReceiptSaved,Status,Notes';
    final rows = <String>[
      if (existingLines.isEmpty) header,
      if (existingLines.isNotEmpty) ...existingLines,
      _csvJoin([
        _dateStamp(recordedAt),
        project,
        item,
        supplier,
        amount,
        category,
        receiptSaved,
        status,
        notes,
      ]),
    ];

    await writeTextFileWithBackup(spendTrackerFile, '${rows.join('\n')}\n');

    return TreasuryProjectSpendSaveResult(
      projectSpendTrackerPath: spendTrackerFile.path,
    );
  }

  List<String> _markdownBullets(List<String> items) {
    if (items.isEmpty) {
      return const ['- '];
    }

    return items.map((item) {
      final text = item.trim();
      return text.isEmpty ? '- ' : '- $text';
    }).toList();
  }

  String _dateStamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _csvJoin(List<String> values) {
    return values.map(_csvCell).join(',');
  }

  String _csvCell(String value) {
    final trimmed = value.trim();
    final escaped = trimmed.replaceAll('"', '""');
    return '"$escaped"';
  }
}
