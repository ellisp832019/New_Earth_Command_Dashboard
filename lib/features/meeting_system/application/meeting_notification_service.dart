import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../data/meeting_folder_service.dart';

abstract class MeetingNotificationClient {
  Future<void> initialize();

  Future<void> show(MeetingNotificationRecord notification);
}

class MeetingNotificationHistoryStore {
  MeetingNotificationHistoryStore(this.file);

  final File file;

  static Future<MeetingNotificationHistoryStore> openDefault() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(
      path.join(directory.path, 'meeting_notification_history.json'),
    );
    return MeetingNotificationHistoryStore(file);
  }

  Future<Set<String>> loadShownIds() async {
    if (!await file.exists()) {
      return <String>{};
    }

    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return <String>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return <String>{};
      }

      final entries = decoded['sent_notifications'];
      if (entries is! List) {
        return <String>{};
      }

      final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
      final kept = <Map<String, String>>[];
      final shownIds = <String>{};

      for (final entry in entries) {
        if (entry is! Map) {
          continue;
        }

        final id = entry['id']?.toString().trim() ?? '';
        if (id.isEmpty) {
          continue;
        }

        final sentAt = DateTime.tryParse(entry['sent_at']?.toString() ?? '');
        if (sentAt != null && sentAt.isBefore(cutoff)) {
          continue;
        }

        shownIds.add(id);
        kept.add(<String, String>{
          'id': id,
          'sent_at': (sentAt ?? DateTime.now().toUtc()).toIso8601String(),
        });
      }

      if (kept.length != entries.length) {
        await _writeEntries(kept);
      }

      return shownIds;
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> markShown(String id) async {
    if (id.trim().isEmpty) {
      return;
    }

    final entries = await _readEntries();
    final updated = <Map<String, String>>[
      ...entries.where((entry) => entry['id'] != id),
      <String, String>{
        'id': id,
        'sent_at': DateTime.now().toUtc().toIso8601String(),
      },
    ];
    await _writeEntries(updated);
  }

  Future<List<Map<String, String>>> _readEntries() async {
    if (!await file.exists()) {
      return <Map<String, String>>[];
    }

    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return <Map<String, String>>[];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return <Map<String, String>>[];
      }

      final entries = decoded['sent_notifications'];
      if (entries is! List) {
        return <Map<String, String>>[];
      }

      return entries
          .whereType<Map>()
          .map(
            (entry) => <String, String>{
              'id': entry['id']?.toString() ?? '',
              'sent_at': entry['sent_at']?.toString() ?? '',
            },
          )
          .where((entry) => entry['id']?.isNotEmpty ?? false)
          .toList(growable: true);
    } catch (_) {
      return <Map<String, String>>[];
    }
  }

  Future<void> _writeEntries(List<Map<String, String>> entries) async {
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode(<String, dynamic>{'sent_notifications': entries}),
    );
  }
}

class MeetingNotificationService {
  MeetingNotificationService({
    MeetingNotificationClient? client,
    MeetingNotificationHistoryStore? historyStore,
    bool? enabled,
  }) : _client = client ?? _SystemPopupMeetingNotificationClient(),
       _historyStore = historyStore,
       _enabled = enabled ?? _defaultEnabled;

  final MeetingNotificationClient _client;
  MeetingNotificationHistoryStore? _historyStore;
  final bool _enabled;

  bool _initialized = false;
  Future<void>? _initializing;
  Future<void> _syncQueue = Future<void>.value();

  static bool get _defaultEnabled =>
      !kIsWeb &&
      Platform.isWindows &&
      Platform.environment['FLUTTER_TEST'] != 'true';

  Future<void> ensureInitialized() {
    if (_initialized) {
      return Future<void>.value();
    }

    return _initializing ??= _initialize();
  }

  Future<void> syncNotifications(
    List<MeetingNotificationRecord> notifications,
  ) {
    _syncQueue = _syncQueue
        .then((_) => _syncNotifications(notifications))
        .catchError((_) {});
    return _syncQueue;
  }

  Future<void> _initialize() async {
    if (!_enabled) {
      _initialized = true;
      _initializing = null;
      return;
    }

    _historyStore ??= await MeetingNotificationHistoryStore.openDefault();
    await _client.initialize();
    _initialized = true;
    _initializing = null;
  }

  Future<void> _syncNotifications(
    List<MeetingNotificationRecord> notifications,
  ) async {
    if (!_enabled || notifications.isEmpty) {
      return;
    }

    await ensureInitialized();
    if (!_enabled || _historyStore == null) {
      return;
    }

    final shownIds = await _historyStore!.loadShownIds();
    for (final notification in notifications) {
      if (shownIds.contains(notification.id)) {
        continue;
      }

      await _client.show(notification);
      await _historyStore!.markShown(notification.id);
      shownIds.add(notification.id);
    }
  }
}

class _SystemPopupMeetingNotificationClient
    implements MeetingNotificationClient {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
  }

  @override
  Future<void> show(MeetingNotificationRecord notification) async {
    if (!_initialized || !Platform.isWindows) {
      return;
    }

    final title = _escapePowerShellSingleQuoted(notification.title);
    final body = _escapePowerShellSingleQuoted(
      '${notification.message}\nMy time: ${notification.myTimeLabel}\nAttendee time: ${notification.meetingTime} ${notification.timezoneLabel}',
    );
    final script =
        '''
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
\$notify = New-Object System.Windows.Forms.NotifyIcon
\$notify.Icon = [System.Drawing.SystemIcons]::Information
\$notify.Visible = \$true
\$notify.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
\$notify.BalloonTipTitle = '$title'
\$notify.BalloonTipText = '$body'
\$notify.ShowBalloonTip(5000)
Start-Sleep -Seconds 6
\$notify.Dispose()
''';

    try {
      await Process.run('powershell.exe', <String>[
        '-NoProfile',
        '-STA',
        '-WindowStyle',
        'Hidden',
        '-Command',
        script,
      ], runInShell: false);
    } catch (_) {
      // Best-effort desktop alert. The in-app notification feed still shows it.
    }
  }
}

String _escapePowerShellSingleQuoted(String value) {
  return value.replaceAll("'", "''").replaceAll('\r', '').replaceAll('\n', ' ');
}
