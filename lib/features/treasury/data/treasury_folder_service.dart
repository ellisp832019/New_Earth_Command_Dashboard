import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../core/utils/folder_bootstrap_result.dart';

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

class TreasurySubscriptionSaveResult {
  const TreasurySubscriptionSaveResult({required this.subscriptionTrackerPath});

  final String subscriptionTrackerPath;
}

class TreasuryDecisionRecord {
  const TreasuryDecisionRecord({
    required this.date,
    required this.decisionNeeded,
    required this.amount,
    required this.status,
    required this.decision,
    required this.owner,
    required this.notes,
  });

  final String date;
  final String decisionNeeded;
  final String amount;
  final String status;
  final String decision;
  final String owner;
  final String notes;
}

class TreasuryDecisionSaveResult {
  const TreasuryDecisionSaveResult({required this.decisionsRegisterPath});

  final String decisionsRegisterPath;
}

class TreasuryMonthlyProjectSpendEntry {
  const TreasuryMonthlyProjectSpendEntry({
    required this.date,
    required this.project,
    required this.item,
    required this.supplier,
    required this.amount,
    required this.category,
    required this.receiptSaved,
    required this.status,
    required this.notes,
  });

  final String date;
  final String project;
  final String item;
  final String supplier;
  final String amount;
  final String category;
  final String receiptSaved;
  final String status;
  final String notes;
}

class TreasuryMonthlyProjectSpendTotal {
  const TreasuryMonthlyProjectSpendTotal({
    required this.project,
    required this.total,
    required this.entries,
  });

  final String project;
  final double total;
  final int entries;
}

class TreasuryMonthlySubscriptionEntry {
  const TreasuryMonthlySubscriptionEntry({
    required this.serviceName,
    required this.purpose,
    required this.cost,
    required this.renewalDate,
    required this.paymentSource,
    required this.status,
    required this.keepCancelReview,
    required this.notes,
  });

  final String serviceName;
  final String purpose;
  final String cost;
  final String renewalDate;
  final String paymentSource;
  final String status;
  final String keepCancelReview;
  final String notes;
}

class TreasuryMonthlySummarySnapshot {
  const TreasuryMonthlySummarySnapshot({
    required this.workspace,
    required this.generatedAt,
    required this.projectSpendTotal,
    required this.topProjectSpends,
    required this.subscriptionTotal,
    required this.upcomingSubscriptions,
    required this.recentProjectSpendEntries,
    required this.recentDecisions,
    required this.weeklyReviewDate,
    required this.weeklyReviewNote,
    required this.issues,
  });

  final TreasuryWorkspaceSnapshot workspace;
  final DateTime generatedAt;
  final double projectSpendTotal;
  final List<TreasuryMonthlyProjectSpendTotal> topProjectSpends;
  final double subscriptionTotal;
  final List<TreasuryMonthlySubscriptionEntry> upcomingSubscriptions;
  final List<TreasuryMonthlyProjectSpendEntry> recentProjectSpendEntries;
  final List<TreasuryDecisionRecord> recentDecisions;
  final String? weeklyReviewDate;
  final String? weeklyReviewNote;
  final List<String> issues;
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
    final structure = await createMissingRequiredStructure();
    return structure.createdFiles;
  }

  Future<List<String>> createMissingRequiredFolders() async {
    final snapshot = await loadWorkspace();
    final financeRootPath = snapshot.financeRootPath;
    if (financeRootPath == null) {
      return <String>[];
    }

    final financeRoot = Directory(financeRootPath);
    if (!await financeRoot.exists()) {
      return <String>[];
    }

    final createdFolders = <String>[];
    for (final relativeFolder in requiredFolders) {
      final candidate = Directory(path.join(financeRoot.path, relativeFolder));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.create(recursive: true);
      createdFolders.add(relativeFolder);
    }

    return createdFolders;
  }

  Future<FolderBootstrapCreationResult> createMissingRequiredStructure() async {
    final snapshot = await loadWorkspace();
    final financeRootPath = snapshot.financeRootPath;
    if (financeRootPath == null) {
      return const FolderBootstrapCreationResult(
        createdFolders: <String>[],
        createdFiles: <String>[],
      );
    }

    final financeRoot = Directory(financeRootPath);
    if (!await financeRoot.exists()) {
      return const FolderBootstrapCreationResult(
        createdFolders: <String>[],
        createdFiles: <String>[],
      );
    }

    final createdFolders = <String>[];
    for (final relativeFolder in requiredFolders) {
      final candidate = Directory(path.join(financeRoot.path, relativeFolder));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.create(recursive: true);
      createdFolders.add(relativeFolder);
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

    return FolderBootstrapCreationResult(
      createdFolders: createdFolders,
      createdFiles: createdFiles,
    );
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

  Future<bool> openFinanceFolder(String financeRootPath) async {
    final directory = Directory(financeRootPath);
    if (!await directory.exists()) {
      return false;
    }

    try {
      if (Platform.isWindows) {
        await Process.start('explorer', <String>[
          directory.path,
        ], runInShell: true);
        return true;
      }

      if (Platform.isMacOS) {
        await Process.start('open', <String>[directory.path], runInShell: true);
        return true;
      }

      await Process.start('xdg-open', <String>[
        directory.path,
      ], runInShell: true);
      return true;
    } catch (_) {
      return false;
    }
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
        return 'Service,Purpose,Cost,RenewalDate,PaymentSource,Status,KeepCancelReview,Notes\n';
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

  Future<TreasurySubscriptionSaveResult> saveSubscriptionRecord({
    required String financeRootPath,
    required String serviceName,
    required String purpose,
    required String cost,
    required String renewalDate,
    required String paymentSource,
    required String status,
    required String keepCancelReview,
    required String notes,
    required DateTime recordedAt,
  }) async {
    final subscriptionTrackerFile = File(
      path.join(
        financeRootPath,
        '06_SUBSCRIPTIONS_AND_RECURRING_COSTS',
        'subscription_tracker.csv',
      ),
    );
    await subscriptionTrackerFile.parent.create(recursive: true);

    final existingLines = await subscriptionTrackerFile.exists()
        ? await subscriptionTrackerFile.readAsLines()
        : <String>[];
    final header =
        'Service,Purpose,Cost,RenewalDate,PaymentSource,Status,KeepCancelReview,Notes';
    final rows = <String>[
      if (existingLines.isEmpty) header,
      if (existingLines.isNotEmpty) ...existingLines,
      _csvJoin([
        serviceName,
        purpose,
        cost,
        renewalDate,
        paymentSource,
        status,
        keepCancelReview,
        notes,
      ]),
    ];

    await writeTextFileWithBackup(
      subscriptionTrackerFile,
      '${rows.join('\n')}\n',
    );

    return TreasurySubscriptionSaveResult(
      subscriptionTrackerPath: subscriptionTrackerFile.path,
    );
  }

  Future<List<TreasuryDecisionRecord>> loadDecisionRegister({
    required String financeRootPath,
  }) async {
    final decisionsFile = File(
      path.join(
        financeRootPath,
        '10_FINANCE_MEETING_NOTES',
        'decisions_register.csv',
      ),
    );

    if (!await decisionsFile.exists()) {
      return const <TreasuryDecisionRecord>[];
    }

    final lines = await decisionsFile.readAsLines();
    if (lines.length <= 1) {
      return const <TreasuryDecisionRecord>[];
    }

    final records = <TreasuryDecisionRecord>[];
    for (final rawLine in lines.skip(1)) {
      if (rawLine.trim().isEmpty) {
        continue;
      }

      final cells = _parseCsvLine(rawLine);
      records.add(
        TreasuryDecisionRecord(
          date: _csvCellValue(cells, 0),
          decisionNeeded: _csvCellValue(cells, 1),
          amount: _csvCellValue(cells, 2),
          status: _csvCellValue(cells, 3),
          decision: _csvCellValue(cells, 4),
          owner: _csvCellValue(cells, 5),
          notes: _csvCellValue(cells, 6),
        ),
      );
    }

    return records.reversed.toList(growable: false);
  }

  Future<TreasuryDecisionSaveResult> saveDecisionRecord({
    required String financeRootPath,
    required String date,
    required String decisionNeeded,
    required String amount,
    required String status,
    required String decision,
    required String owner,
    required String notes,
  }) async {
    final decisionsFile = File(
      path.join(
        financeRootPath,
        '10_FINANCE_MEETING_NOTES',
        'decisions_register.csv',
      ),
    );
    await decisionsFile.parent.create(recursive: true);

    final existingLines = await decisionsFile.exists()
        ? await decisionsFile.readAsLines()
        : <String>[];
    final header = 'date,decision_needed,amount,status,decision,owner,notes';
    final rows = <String>[
      if (existingLines.isEmpty) header,
      if (existingLines.isNotEmpty) ...existingLines,
      _csvJoin([date, decisionNeeded, amount, status, decision, owner, notes]),
    ];

    await writeTextFileWithBackup(decisionsFile, '${rows.join('\n')}\n');

    return TreasuryDecisionSaveResult(
      decisionsRegisterPath: decisionsFile.path,
    );
  }

  Future<TreasuryMonthlySummarySnapshot> loadMonthlySummary({
    required TreasuryWorkspaceSnapshot workspace,
  }) async {
    final financeRootPath = workspace.financeRootPath;
    if (financeRootPath == null) {
      return TreasuryMonthlySummarySnapshot(
        workspace: workspace,
        generatedAt: DateTime.now(),
        projectSpendTotal: 0,
        topProjectSpends: const <TreasuryMonthlyProjectSpendTotal>[],
        subscriptionTotal: 0,
        upcomingSubscriptions: const <TreasuryMonthlySubscriptionEntry>[],
        recentProjectSpendEntries: const <TreasuryMonthlyProjectSpendEntry>[],
        recentDecisions: const <TreasuryDecisionRecord>[],
        weeklyReviewDate: null,
        weeklyReviewNote: null,
        issues: workspace.issues.isEmpty
            ? const <String>[
                'Treasury is waiting for the external finance folder.',
              ]
            : workspace.issues,
      );
    }

    final financeRoot = Directory(financeRootPath);
    if (!await financeRoot.exists()) {
      return TreasuryMonthlySummarySnapshot(
        workspace: workspace,
        generatedAt: DateTime.now(),
        projectSpendTotal: 0,
        topProjectSpends: const <TreasuryMonthlyProjectSpendTotal>[],
        subscriptionTotal: 0,
        upcomingSubscriptions: const <TreasuryMonthlySubscriptionEntry>[],
        recentProjectSpendEntries: const <TreasuryMonthlyProjectSpendEntry>[],
        recentDecisions: const <TreasuryDecisionRecord>[],
        weeklyReviewDate: null,
        weeklyReviewNote: null,
        issues: const <String>[
          'The configured Treasury folder does not exist right now.',
        ],
      );
    }

    final projectSpendRecords = await _readCsvRecords(
      File(
        path.join(
          financeRoot.path,
          '04_PROJECT_SPEND_TRACKERS',
          'project_spend_tracker.csv',
        ),
      ),
    );
    final subscriptionRecords = await _readCsvRecords(
      File(
        path.join(
          financeRoot.path,
          '06_SUBSCRIPTIONS_AND_RECURRING_COSTS',
          'subscription_tracker.csv',
        ),
      ),
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

    final projectSpendEntries = projectSpendRecords
        .map(
          (record) => TreasuryMonthlyProjectSpendEntry(
            date: _csvRecordValue(record, 'date'),
            project: _csvRecordValue(record, 'project'),
            item: _csvRecordValue(record, 'item'),
            supplier: _csvRecordValue(record, 'supplier'),
            amount: _csvRecordValue(record, 'amount'),
            category: _csvRecordValue(record, 'category'),
            receiptSaved: _csvRecordValue(record, 'receipt_saved'),
            status: _csvRecordValue(record, 'status'),
            notes: _csvRecordValue(record, 'notes'),
          ),
        )
        .toList(growable: false);

    final topProjectSpends = <String, _ProjectSpendBucket>{};
    for (final entry in projectSpendEntries) {
      final projectName = entry.project.isEmpty
          ? 'Unlabelled project'
          : entry.project;
      final bucket = topProjectSpends.putIfAbsent(
        projectName,
        () => _ProjectSpendBucket(project: projectName),
      );
      bucket.add(_parseMoney(entry.amount));
    }

    final topProjectSpendTotals = topProjectSpends.values.toList()
      ..sort((left, right) {
        final totalCompare = right.total.compareTo(left.total);
        if (totalCompare != 0) {
          return totalCompare;
        }
        return left.project.toLowerCase().compareTo(
          right.project.toLowerCase(),
        );
      });

    final subscriptionEntries = subscriptionRecords
        .map(
          (record) => TreasuryMonthlySubscriptionEntry(
            serviceName: _csvRecordValue(record, 'service'),
            purpose: _csvRecordValue(record, 'purpose'),
            cost: _csvRecordValue(record, 'cost'),
            renewalDate: _csvRecordValue(record, 'renewaldate'),
            paymentSource: _csvRecordValue(record, 'paymentsource'),
            status: _csvRecordValue(record, 'status'),
            keepCancelReview: _csvRecordValue(record, 'keepcancelreview'),
            notes: _csvRecordValue(record, 'notes'),
          ),
        )
        .toList(growable: false);

    final upcomingSubscriptions = [...subscriptionEntries]
      ..sort((left, right) {
        final leftDate = _parseDateValue(left.renewalDate);
        final rightDate = _parseDateValue(right.renewalDate);
        if (leftDate == null && rightDate == null) {
          return left.serviceName.toLowerCase().compareTo(
            right.serviceName.toLowerCase(),
          );
        }
        if (leftDate == null) {
          return 1;
        }
        if (rightDate == null) {
          return -1;
        }
        return leftDate.compareTo(rightDate);
      });

    final recentProjectSpendEntries = [
      ...projectSpendEntries,
    ].reversed.take(5).toList(growable: false);

    final recentDecisions = (await loadDecisionRegister(
      financeRootPath: financeRootPath,
    )).take(5).toList(growable: false);

    String? weeklyReviewDate;
    String? weeklyReviewNote;
    if (await weeklyStatusFile.exists()) {
      try {
        final decoded =
            jsonDecode(await weeklyStatusFile.readAsString())
                as Map<String, dynamic>;
        final reviewDate = decoded['review_date'];
        if (reviewDate is String && reviewDate.trim().isNotEmpty) {
          weeklyReviewDate = reviewDate.trim();
        }
        final notes = decoded['notes'];
        if (notes is String && notes.trim().isNotEmpty) {
          weeklyReviewNote = notes.trim();
        }
      } on FormatException {
        // Keep the calm summary available even when the file is malformed.
      }
    }

    if (weeklyReviewDate == null && await dashboardStateFile.exists()) {
      try {
        final decoded =
            jsonDecode(await dashboardStateFile.readAsString())
                as Map<String, dynamic>;
        final updatedAt = decoded['updated_at'];
        if (updatedAt is String && updatedAt.trim().isNotEmpty) {
          weeklyReviewDate = updatedAt.trim();
        }
        final notes = decoded['notes'];
        if (notes is String && notes.trim().isNotEmpty) {
          weeklyReviewNote = notes.trim();
        }
      } on FormatException {
        // Keep the calm summary available even when the file is malformed.
      }
    }

    return TreasuryMonthlySummarySnapshot(
      workspace: workspace,
      generatedAt: DateTime.now(),
      projectSpendTotal: topProjectSpendTotals.fold<double>(
        0,
        (sum, bucket) => sum + bucket.total,
      ),
      topProjectSpends: topProjectSpendTotals
          .take(3)
          .map(
            (bucket) => TreasuryMonthlyProjectSpendTotal(
              project: bucket.project,
              total: bucket.total,
              entries: bucket.entries,
            ),
          )
          .toList(growable: false),
      subscriptionTotal: subscriptionEntries.fold<double>(
        0,
        (sum, entry) => sum + _parseMoney(entry.cost),
      ),
      upcomingSubscriptions: upcomingSubscriptions
          .take(3)
          .toList(growable: false),
      recentProjectSpendEntries: recentProjectSpendEntries,
      recentDecisions: recentDecisions,
      weeklyReviewDate: weeklyReviewDate,
      weeklyReviewNote: weeklyReviewNote,
      issues: workspace.issues,
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

  String _csvCellValue(List<String> cells, int index) {
    if (index >= cells.length) {
      return '';
    }

    return cells[index].trim();
  }

  Future<List<Map<String, String>>> _readCsvRecords(File file) async {
    if (!await file.exists()) {
      return const <Map<String, String>>[];
    }

    final lines = await file.readAsLines();
    if (lines.length <= 1) {
      return const <Map<String, String>>[];
    }

    final headers = _parseCsvLine(
      lines.first,
    ).map((header) => header.trim().toLowerCase()).toList(growable: false);
    if (headers.isEmpty) {
      return const <Map<String, String>>[];
    }

    final rows = <Map<String, String>>[];
    for (final rawLine in lines.skip(1)) {
      if (rawLine.trim().isEmpty) {
        continue;
      }

      final cells = _parseCsvLine(rawLine);
      final row = <String, String>{};
      for (var index = 0; index < headers.length; index++) {
        row[headers[index]] = _csvCellValue(cells, index);
      }
      rows.add(row);
    }

    return rows;
  }

  String _csvRecordValue(Map<String, String> record, String key) {
    return record[key.toLowerCase()] ?? '';
  }

  double _parseMoney(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.\-]'), '');
    if (cleaned.isEmpty || cleaned == '-' || cleaned == '.') {
      return 0;
    }

    return double.tryParse(cleaned) ?? 0;
  }

  DateTime? _parseDateValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return DateTime.tryParse(trimmed);
  }
}

class _ProjectSpendBucket {
  _ProjectSpendBucket({required this.project});

  final String project;
  double total = 0;
  int entries = 0;

  void add(double amount) {
    total += amount;
    entries += 1;
  }
}
