import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colours.dart';
import '../data/alexa_voice_gateway_adapter.dart';
import '../data/alexa_voice_gateway_models.dart';

class AlexaVoiceGatewayScreen extends StatefulWidget {
  const AlexaVoiceGatewayScreen({
    super.key,
    this.adapter = const MockAlexaVoiceGatewayAdapter(),
    this.enableAutoRefresh = true,
  });

  final AlexaVoiceGatewayAdapter adapter;
  final bool enableAutoRefresh;

  @override
  State<AlexaVoiceGatewayScreen> createState() =>
      _AlexaVoiceGatewayScreenState();
}

class _AlexaVoiceGatewayScreenState extends State<AlexaVoiceGatewayScreen> {
  late Future<List<_EndpointHealth>> _healthFuture;
  late Future<String> _selectedLogFuture;
  Timer? _healthRefreshTimer;
  bool _launchingGateway = false;
  bool _stoppingGateway = false;
  bool _smokeTestRunning = false;
  DateTime? _lastHealthCheckAt;
  String? _gatewayStatusNotice;
  bool? _expectedGatewayRunning;
  _SmokeTestResult? _lastSmokeTestResult;
  String _selectedLogKey = 'launcher';

  static const _modulePath = 'modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE';
  static const _moduleFolderPath =
      r'D:\Dev\Projects\New Earth - Command Dashboard\modules\NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE';
  static const _scriptsFolderPath =
      r'D:\Dev\Projects\New Earth - Command Dashboard\modules\NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE\scripts';
  static const _launcherPath =
      r'D:\Dev\Projects\New Earth - Command Dashboard\modules\NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE\scripts\launch_voice_gateway.cmd';
  static const _stopLauncherPath =
      r'D:\Dev\Projects\New Earth - Command Dashboard\modules\NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE\scripts\stop_voice_gateway.cmd';
  static const _mockDashboardCommand =
      'python examples/dashboard_mock/mock_dashboard_api.py';
  static const _gatewayCommand = 'python -m src.voice_gateway.app';
  static const _gatewayTestCommand = 'bash scripts/test_gateway.sh';
  static const _launcherCommand = 'scripts\\launch_voice_gateway.cmd';
  static const _stopLauncherCommand = 'scripts\\stop_voice_gateway.cmd';
  static const _logsFolderPath =
      r'D:\Dev\Projects\New Earth - Command Dashboard\modules\NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE\logs';

  @override
  void initState() {
    super.initState();
    _healthFuture = _probeLocalHealth();
    _selectedLogFuture = _readLogFile(_selectedLogKey);
    if (widget.enableAutoRefresh) {
      _healthRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (!mounted) {
          return;
        }

        _refreshHealth();
      });
    }
  }

  @override
  void dispose() {
    _healthRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshHealth() async {
    final future = _probeLocalHealth();
    setState(() {
      _lastHealthCheckAt = DateTime.now();
      _healthFuture = future;
    });

    final endpoints = await future;
    if (!mounted) {
      return;
    }

    _EndpointHealth? gatewayEndpoint;
    for (final endpoint in endpoints) {
      if (endpoint.label == 'Voice Gateway') {
        gatewayEndpoint = endpoint;
        break;
      }
    }

    String? nextNotice = _gatewayStatusNotice;
    if (_expectedGatewayRunning != null && gatewayEndpoint != null) {
      if (_expectedGatewayRunning == true && gatewayEndpoint.healthy) {
        nextNotice = 'Gateway startup confirmed by local health check.';
        _expectedGatewayRunning = null;
      } else if (_expectedGatewayRunning == false && !gatewayEndpoint.healthy) {
        nextNotice = 'Gateway shutdown confirmed by local health check.';
        _expectedGatewayRunning = null;
      }
    }

    setState(() {
      _gatewayStatusNotice = nextNotice;
    });
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied to clipboard.')));
  }

  Future<void> _openLauncherFolder() async {
    await _openPath(_scriptsFolderPath);
  }

  Future<void> _launchGateway() async {
    if (!Platform.isWindows) {
      await _showMessage(
        'Direct launch is currently wired for Windows. Use the launcher command shown on the page for other systems.',
      );
      return;
    }

    final launcherFile = File(_launcherPath);
    if (!await launcherFile.exists()) {
      await _showMessage('Launcher script not found at $_launcherPath');
      return;
    }

    setState(() {
      _launchingGateway = true;
      _gatewayStatusNotice =
          'Gateway launch requested. Waiting for health confirmation...';
      _expectedGatewayRunning = true;
    });

    try {
      await Process.start(
        'cmd',
        <String>['/c', _launcherPath],
        workingDirectory: _moduleFolderPath,
        mode: ProcessStartMode.detached,
      );
      await _showMessage(
        'Gateway launcher started. Give it a few seconds, then the health panel should turn green.',
      );
      await _refreshHealth();
    } catch (error) {
      await _showMessage('Could not start the gateway launcher: $error');
    } finally {
      if (mounted) {
        setState(() {
          _launchingGateway = false;
        });
      }
    }
  }

  Future<void> _stopGateway() async {
    if (!Platform.isWindows) {
      await _showMessage(
        'Direct stop is currently wired for Windows. Use the local stop command shown on the page for other systems.',
      );
      return;
    }

    final stopLauncherFile = File(_stopLauncherPath);
    if (!await stopLauncherFile.exists()) {
      await _showMessage(
        'Stop launcher script not found at $_stopLauncherPath',
      );
      return;
    }

    setState(() {
      _stoppingGateway = true;
      _gatewayStatusNotice =
          'Gateway stop requested. Waiting for health confirmation...';
      _expectedGatewayRunning = false;
    });

    try {
      await Process.start(
        'cmd',
        <String>['/c', _stopLauncherPath],
        workingDirectory: _moduleFolderPath,
        mode: ProcessStartMode.detached,
      );
      await _showMessage(
        'Gateway stop helper started. The health panel will update on the next refresh cycle.',
      );
      await _refreshHealth();
    } catch (error) {
      await _showMessage('Could not start the gateway stop helper: $error');
    } finally {
      if (mounted) {
        setState(() {
          _stoppingGateway = false;
        });
      }
    }
  }

  Future<void> _copyLauncherFolderPath() async {
    await _copyToClipboard(_scriptsFolderPath, 'Launcher folder path');
  }

  Future<void> _copyModulePath() async {
    await _copyToClipboard(_moduleFolderPath, 'Module path');
  }

  Future<void> _copyLauncherFilenames() async {
    await _copyToClipboard(
      [
        'launch_voice_gateway.ps1',
        'launch_voice_gateway.cmd',
        'launch_voice_gateway.bat',
        'stop_voice_gateway.ps1',
        'stop_voice_gateway.cmd',
        'stop_voice_gateway.bat',
      ].join('\n'),
      'Launcher filenames',
    );
  }

  Future<void> _copyAllSetupInfo() async {
    await _copyToClipboard(
      [
        'Module path: $_moduleFolderPath',
        'Scripts folder: $_scriptsFolderPath',
        'Launcher files:',
        'launch_voice_gateway.ps1',
        'launch_voice_gateway.cmd',
        'launch_voice_gateway.bat',
        'stop_voice_gateway.ps1',
        'stop_voice_gateway.cmd',
        'stop_voice_gateway.bat',
        'Launcher command: $_launcherCommand',
        'Stop command: $_stopLauncherCommand',
      ].join('\n'),
      'All setup info',
    );
  }

  Future<void> _showMessage(String message) async {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyLatestLogIssue() async {
    final logContent = await _readLogFile(_selectedLogKey);
    final lines = logContent
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final issueLine = lines.reversed.firstWhere((line) {
      final lower = line.toLowerCase();
      return lower.contains('error') ||
          lower.contains('exception') ||
          lower.contains('failed') ||
          lower.contains('traceback') ||
          lower.contains('http 4') ||
          lower.contains('http 5');
    }, orElse: () => lines.isNotEmpty ? lines.last : 'No recent issue found.');

    await _copyToClipboard(issueLine, 'Latest log issue');
  }

  Future<void> _refreshSelectedLog() async {
    setState(() {
      _selectedLogFuture = _readLogFile(_selectedLogKey);
    });
  }

  Future<String> _readLogFile(String key) async {
    final path = _logPathForKey(key);
    final file = File(path);
    if (!await file.exists()) {
      return 'No log file found yet at:\n$path';
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return 'Log file is present but currently empty.\n$path';
    }

    final lines = content.trimRight().split('\n');
    final recent = lines.length > 40 ? lines.sublist(lines.length - 40) : lines;
    return recent.join('\n');
  }

  String _logPathForKey(String key) {
    switch (key) {
      case 'mock':
        return '$_logsFolderPath\\mock_dashboard.log';
      case 'gateway':
        return '$_logsFolderPath\\voice_gateway.log';
      case 'launcher':
      default:
        return '$_logsFolderPath\\launcher.log';
    }
  }

  Future<void> _runSmokeTest() async {
    setState(() {
      _smokeTestRunning = true;
    });

    final client = HttpClient();
    final results = <_SmokeTestItem>[];
    final secret = Platform.environment['NEW_EARTH_VOICE_GATEWAY_SECRET'];
    const gatewayUri = 'http://127.0.0.1:8088/voice/command';

    final commands = <Map<String, String>>[
      {
        'label': 'Today summary',
        'intent': 'GetTodaySummaryIntent',
        'command': 'dashboard.summary.today',
        'expectedDecision': 'allowed',
      },
      {
        'label': 'Project status',
        'intent': 'GetProjectStatusIntent',
        'command': 'dashboard.project.status.read',
        'expectedDecision': 'allowed',
      },
      {
        'label': 'Blocked command',
        'intent': 'DeleteFileIntent',
        'command': 'filesystem.delete',
        'expectedDecision': 'blocked',
      },
    ];

    try {
      for (final item in commands) {
        final request = await client.postUrl(Uri.parse(gatewayUri));
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        if (secret != null && secret.isNotEmpty) {
          request.headers.set('x-gateway-secret', secret);
        }

        request.write(
          jsonEncode({
            'source': 'dashboard-smoke-test',
            'intent': item['intent'],
            'command': item['command'],
            'slots': item['command'] == 'filesystem.delete'
                ? {'path': 'D:/NEW_EARTH_OMEGA_OS_PACK'}
                : <String, String>{},
          }),
        );

        final response = await request.close().timeout(
          const Duration(seconds: 4),
        );
        final body = await response.transform(utf8.decoder).join();
        final expectedDecision = item['expectedDecision']!;
        final httpSuccess =
            response.statusCode >= 200 && response.statusCode < 300;
        String? actualDecision;
        var detail = body.trim().isEmpty
            ? 'Gateway responded successfully.'
            : body.trim();

        if (httpSuccess && body.trim().isNotEmpty) {
          try {
            final decoded = jsonDecode(body);
            if (decoded is Map<String, dynamic>) {
              actualDecision = decoded['decision']?.toString();
            }
          } catch (_) {
            // Keep the raw response when JSON parsing is not available.
          }
        }

        final success = httpSuccess && actualDecision == expectedDecision;
        if (!httpSuccess) {
          detail = 'HTTP ${response.statusCode}: ${body.trim()}';
        } else if (actualDecision == null) {
          detail = '$detail\nExpected decision: $expectedDecision';
        } else if (actualDecision != expectedDecision) {
          detail =
              '$detail\nExpected decision: $expectedDecision\nActual decision: $actualDecision';
        }

        results.add(
          _SmokeTestItem(
            label: item['label']!,
            command: item['command']!,
            ok: success,
            detail: detail,
          ),
        );
      }
    } catch (error) {
      results.add(
        _SmokeTestItem(
          label: 'Gateway request',
          command: gatewayUri,
          ok: false,
          detail: 'Smoke test failed before completion: $error',
        ),
      );
    } finally {
      client.close(force: true);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _smokeTestRunning = false;
      _lastSmokeTestResult = _SmokeTestResult(
        ranAt: DateTime.now(),
        usedSecret: secret != null && secret.isNotEmpty,
        items: results,
      );
    });
  }

  Future<void> _openPath(String path) async {
    if (Platform.isWindows) {
      await Process.start('explorer', <String>[path]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', <String>[path]);
      return;
    }

    await Process.start('xdg-open', <String>[path]);
  }

  Future<List<_EndpointHealth>> _probeLocalHealth() async {
    return <_EndpointHealth>[
      await _probeEndpoint(
        label: 'Voice Gateway',
        uri: Uri.parse('http://127.0.0.1:8088/health'),
      ),
      await _probeEndpoint(
        label: 'Mock Dashboard',
        uri: Uri.parse('http://127.0.0.1:8099/health'),
      ),
    ];
  }

  Future<_EndpointHealth> _probeEndpoint({
    required String label,
    required Uri uri,
  }) async {
    final client = HttpClient();

    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 2));
      final response = await request.close().timeout(
        const Duration(seconds: 2),
      );
      final body = await response.transform(utf8.decoder).join();
      final healthy = response.statusCode >= 200 && response.statusCode < 300;

      return _EndpointHealth(
        label: label,
        uri: uri,
        healthy: healthy,
        statusText: healthy ? 'Running' : 'Stopped',
        detail: healthy
            ? body.trim().isEmpty
                  ? 'Health endpoint responded successfully.'
                  : body.trim()
            : 'Health endpoint returned HTTP ${response.statusCode}.',
      );
    } catch (error) {
      return _EndpointHealth(
        label: label,
        uri: uri,
        healthy: false,
        statusText: 'Stopped',
        detail: 'Could not reach the local endpoint: $error',
      );
    } finally {
      client.close(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.adapter.loadStatus();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeaderCard(status: status, theme: theme, modulePath: _modulePath),
          const SizedBox(height: 14),
          _QuickStartCard(
            launcherCommand: _launcherCommand,
            launcherPath: _launcherPath,
            stopLauncherCommand: _stopLauncherCommand,
            launchingGateway: _launchingGateway,
            stoppingGateway: _stoppingGateway,
            onLaunchGateway: _launchGateway,
            onStopGateway: _stopGateway,
            onOpenLauncherFolder: _openLauncherFolder,
            onCopyWindowsStartCommands: () => _copyToClipboard(
              [
                'cd $_moduleFolderPath',
                'python examples/dashboard_mock/mock_dashboard_api.py',
                'python -m src.voice_gateway.app',
              ].join('\n'),
              'Windows launch commands',
            ),
            onCopyStopCommand: () =>
                _copyToClipboard(_stopLauncherCommand, 'Stop launcher command'),
          ),
          const SizedBox(height: 14),
          _SetupActionsCard(
            modulePath: _moduleFolderPath,
            scriptsFolderPath: _scriptsFolderPath,
            launcherCommand: _launcherCommand,
            onCopyWindowsStartCommands: () => _copyToClipboard(
              [
                'cd $_moduleFolderPath',
                'python examples/dashboard_mock/mock_dashboard_api.py',
                'python -m src.voice_gateway.app',
              ].join('\n'),
              'Windows launch commands',
            ),
            onCopyGatewayTestCommand: () =>
                _copyToClipboard(_gatewayTestCommand, 'Gateway test command'),
            onCopyGatewayEnv: () => _copyToClipboard(
              [
                'NEW_EARTH_VOICE_GATEWAY_SECRET=change-this-long-random-secret',
                'ALEXA_GATEWAY_ENABLED=true',
                'NEW_EARTH_GATEWAY_URL=http://127.0.0.1:8088/voice/command',
              ].join('\n'),
              'Gateway env lines',
            ),
            onCopyLauncherCommand: () =>
                _copyToClipboard(_launcherCommand, 'Double-click launcher'),
            onCopyLauncherFolderPath: _copyLauncherFolderPath,
            onCopyModulePath: _copyModulePath,
            onCopyLauncherFilenames: _copyLauncherFilenames,
            onCopyAllSetupInfo: _copyAllSetupInfo,
            onOpenLauncherFolder: _openLauncherFolder,
            onRefreshHealth: _refreshHealth,
          ),
          const SizedBox(height: 14),
          _LaunchCard(
            windowsStartCommand:
                'cd $_moduleFolderPath\npython examples/dashboard_mock/mock_dashboard_api.py\npython -m src.voice_gateway.app',
            mockDashboardCommand: _mockDashboardCommand,
            gatewayCommand: _gatewayCommand,
            testCommand: _gatewayTestCommand,
            launcherCommand: _launcherCommand,
            onCopyBundle: () => _copyToClipboard(
              [
                'cd $_moduleFolderPath',
                'python examples/dashboard_mock/mock_dashboard_api.py',
                'python -m src.voice_gateway.app',
                'bash scripts/test_gateway.sh',
              ].join('\n'),
              'Launch bundle',
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<_EndpointHealth>>(
            future: _healthFuture,
            builder: (context, snapshot) {
              final endpoints = snapshot.data ?? const <_EndpointHealth>[];
              return _HealthPanel(
                endpoints: endpoints,
                loading: snapshot.connectionState == ConnectionState.waiting,
                onRefresh: _refreshHealth,
                lastCheckedAt: _lastHealthCheckAt,
                statusNotice: _gatewayStatusNotice,
              );
            },
          ),
          const SizedBox(height: 14),
          _SmokeTestCard(
            running: _smokeTestRunning,
            result: _lastSmokeTestResult,
            onRunTest: _runSmokeTest,
            testCommand: _gatewayTestCommand,
          ),
          const SizedBox(height: 14),
          _LogViewerCard(
            selectedLogKey: _selectedLogKey,
            selectedLogPath: _logPathForKey(_selectedLogKey),
            logFuture: _selectedLogFuture,
            onSelectLog: (key) {
              setState(() {
                _selectedLogKey = key;
                _selectedLogFuture = _readLogFile(key);
              });
            },
            onRefresh: _refreshSelectedLog,
            onCopyLatestError: _copyLatestLogIssue,
            onOpenLogsFolder: () => _openPath(_logsFolderPath),
          ),
          const SizedBox(height: 14),
          _StatusGrid(status: status),
          const SizedBox(height: 14),
          _CommandSection(
            title: 'Allowed commands',
            subtitle:
                'These are the first read-only and low-risk actions kept behind the permission layer.',
            commands: status.allowedCommands,
            accent: AppColours.darkSecondary,
          ),
          const SizedBox(height: 14),
          _CommandSection(
            title: 'Blocked commands',
            subtitle:
                'These categories stay blocked until a future safety review proves they are safe.',
            commands: status.blockedCommands,
            accent: AppColours.darkPrimary,
          ),
          const SizedBox(height: 14),
          _AuditSection(entries: status.auditLogEntries),
          const SizedBox(height: 14),
          _InfoCard(
            title: 'Local development mode',
            body: status.localModeSummary,
            accent: AppColours.darkGlow,
            icon: Icons.developer_mode_outlined,
            footer: 'Module path: ${status.modulePath}',
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.status,
    required this.theme,
    required this.modulePath,
  });

  final AlexaVoiceGatewayStatusSnapshot status;
  final ThemeData theme;
  final String modulePath;

  @override
  Widget build(BuildContext context) {
    final gatewayEnabled = status.killSwitchEnabled == false;
    final heading = gatewayEnabled
        ? 'Alexa Voice Gateway'
        : 'Alexa Voice Gateway is paused';
    final subtitle = gatewayEnabled
        ? 'The guarded doorway is ready for read-only commands and audit logging.'
        : 'The kill switch is on, so the dashboard rejects Alexa requests.';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: AppColours.darkSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppColours.darkText,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              _Pill(
                label: gatewayEnabled ? 'Enabled' : 'Disabled',
                icon: gatewayEnabled ? Icons.lock_open : Icons.lock,
                accent: gatewayEnabled
                    ? AppColours.darkSecondary
                    : AppColours.darkPrimary,
              ),
            ],
          ),
          SelectableText(
            modulePath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupActionsCard extends StatelessWidget {
  const _SetupActionsCard({
    required this.modulePath,
    required this.scriptsFolderPath,
    required this.launcherCommand,
    required this.onCopyWindowsStartCommands,
    required this.onCopyGatewayTestCommand,
    required this.onCopyGatewayEnv,
    required this.onCopyLauncherCommand,
    required this.onCopyLauncherFolderPath,
    required this.onCopyModulePath,
    required this.onCopyLauncherFilenames,
    required this.onCopyAllSetupInfo,
    required this.onOpenLauncherFolder,
    required this.onRefreshHealth,
  });

  final String modulePath;
  final String scriptsFolderPath;
  final String launcherCommand;
  final VoidCallback onCopyWindowsStartCommands;
  final VoidCallback onCopyGatewayTestCommand;
  final VoidCallback onCopyGatewayEnv;
  final VoidCallback onCopyLauncherCommand;
  final VoidCallback onCopyLauncherFolderPath;
  final VoidCallback onCopyModulePath;
  final VoidCallback onCopyLauncherFilenames;
  final VoidCallback onCopyAllSetupInfo;
  final VoidCallback onOpenLauncherFolder;
  final VoidCallback onRefreshHealth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColours.darkSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Setup actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onRefreshHealth,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh health'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Keep the module path, launcher wrappers, and local commands in one compact place.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onCopyWindowsStartCommands,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy Windows start'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyGatewayTestCommand,
                icon: const Icon(Icons.science_outlined),
                label: const Text('Copy test command'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyGatewayEnv,
                icon: const Icon(Icons.key_outlined),
                label: const Text('Copy env lines'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyLauncherCommand,
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Copy launcher command'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyLauncherFolderPath,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy launcher path'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyModulePath,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy module path'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyLauncherFilenames,
                icon: const Icon(Icons.list_outlined),
                label: const Text('Copy launcher filenames'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyAllSetupInfo,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy all setup info'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLauncherFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open launcher folder'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            modulePath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            scriptsFolderPath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            launcherCommand,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard({
    required this.launcherCommand,
    required this.launcherPath,
    required this.stopLauncherCommand,
    required this.launchingGateway,
    required this.stoppingGateway,
    required this.onLaunchGateway,
    required this.onStopGateway,
    required this.onOpenLauncherFolder,
    required this.onCopyWindowsStartCommands,
    required this.onCopyStopCommand,
  });

  final String launcherCommand;
  final String launcherPath;
  final String stopLauncherCommand;
  final bool launchingGateway;
  final bool stoppingGateway;
  final VoidCallback onLaunchGateway;
  final VoidCallback onStopGateway;
  final VoidCallback onOpenLauncherFolder;
  final VoidCallback onCopyWindowsStartCommands;
  final VoidCallback onCopyStopCommand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(
        borderColor: AppColours.darkSecondary.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick start',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the launcher if you want the easiest Windows flow. It starts the mock dashboard and the gateway together, then this page will keep checking health automatically.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 14),
          const _QuickStartStep(
            number: '1',
            title: 'Start the trusted launcher',
            body:
                'Press the button below, or double-click the launcher script from the scripts folder.',
          ),
          const SizedBox(height: 10),
          const _QuickStartStep(
            number: '2',
            title: 'Wait for health to turn green',
            body:
                'The local health panel refreshes every 10 seconds while this page is open.',
          ),
          const SizedBox(height: 10),
          const _QuickStartStep(
            number: '3',
            title: 'Test an Alexa-safe command',
            body:
                'Use one of the allowed commands first so the audit trail and permission layer are easy to verify.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: launchingGateway ? null : onLaunchGateway,
                icon: launchingGateway
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch_outlined),
                label: Text(
                  launchingGateway
                      ? 'Starting gateway...'
                      : 'Start gateway now',
                ),
              ),
              FilledButton.icon(
                onPressed: stoppingGateway ? null : onStopGateway,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColours.darkPrimary,
                  foregroundColor: AppColours.darkText,
                ),
                icon: stoppingGateway
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.stop_circle_outlined),
                label: Text(
                  stoppingGateway ? 'Stopping gateway...' : 'Stop gateway',
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenLauncherFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open scripts folder'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyWindowsStartCommands,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy manual start'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCopyStopCommand,
                icon: const Icon(Icons.content_copy_outlined),
                label: const Text('Copy stop command'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            launcherCommand,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            launcherPath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stopLauncherCommand,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartStep extends StatelessWidget {
  const _QuickStartStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColours.darkSecondary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            number,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard({
    required this.windowsStartCommand,
    required this.mockDashboardCommand,
    required this.gatewayCommand,
    required this.testCommand,
    required this.launcherCommand,
    required this.onCopyBundle,
  });

  final String windowsStartCommand;
  final String mockDashboardCommand;
  final String gatewayCommand;
  final String testCommand;
  final String launcherCommand;
  final VoidCallback onCopyBundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.play_circle_outline,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Launch helper',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onCopyBundle,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy full bundle'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use this card to keep the gateway startup, mock dashboard, and test flow in one place.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 14),
          _CodeBlock(title: 'Windows start bundle', value: windowsStartCommand),
          const SizedBox(height: 12),
          _CodeBlock(title: 'Mock dashboard', value: mockDashboardCommand),
          const SizedBox(height: 12),
          _CodeBlock(title: 'Voice gateway', value: gatewayCommand),
          const SizedBox(height: 12),
          _CodeBlock(title: 'Gateway tests', value: testCommand),
          const SizedBox(height: 12),
          _CodeBlock(title: 'Trusted launcher', value: launcherCommand),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontFamily: 'monospace',
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthPanel extends StatelessWidget {
  const _HealthPanel({
    required this.endpoints,
    required this.loading,
    required this.onRefresh,
    required this.lastCheckedAt,
    required this.statusNotice,
  });

  final List<_EndpointHealth> endpoints;
  final bool loading;
  final VoidCallback onRefresh;
  final DateTime? lastCheckedAt;
  final String? statusNotice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final healthyCount = endpoints.where((endpoint) => endpoint.healthy).length;
    final allHealthy = endpoints.isNotEmpty && healthyCount == endpoints.length;
    final summaryAccent = allHealthy
        ? AppColours.darkSecondary
        : AppColours.darkPrimary;
    final summaryText = allHealthy
        ? 'All local gateway services are responding.'
        : healthyCount == 0
        ? 'The local services are currently offline.'
        : '$healthyCount of ${endpoints.length} local services are responding.';
    final checkedLabel = lastCheckedAt == null
        ? 'Health check starts when this page loads.'
        : 'Last checked at ${_formatLocalClock(lastCheckedAt!)}';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(
        borderColor: summaryAccent.withValues(alpha: 0.28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Local health check',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: loading ? null : onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The dashboard can quickly check whether the mock dashboard and voice gateway are actually running on your machine.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: summaryAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: summaryAccent.withValues(alpha: 0.24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      allHealthy
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      color: summaryAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summaryText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColours.darkText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  checkedLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                if (statusNotice != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    statusNotice!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: summaryAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (loading)
            const LinearProgressIndicator()
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: endpoints
                  .map((endpoint) => _EndpointCard(endpoint: endpoint))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _SmokeTestCard extends StatelessWidget {
  const _SmokeTestCard({
    required this.running,
    required this.result,
    required this.onRunTest,
    required this.testCommand,
  });

  final bool running;
  final _SmokeTestResult? result;
  final VoidCallback onRunTest;
  final String testCommand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final successCount = result?.items.where((item) => item.ok).length ?? 0;
    final totalCount = result?.items.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gateway smoke test',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: running ? null : onRunTest,
                icon: running
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow_outlined),
                label: Text(running ? 'Running test...' : 'Run gateway test'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This runs a few safe requests directly against the local gateway so you can confirm allowed and blocked behavior without leaving the dashboard.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Shell helper: $testCommand',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontFamily: 'monospace',
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color:
                      (successCount == totalCount
                              ? AppColours.darkSecondary
                              : AppColours.darkPrimary)
                          .withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$successCount of $totalCount requests succeeded',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ran at ${_formatLocalClock(result!.ranAt)}${result!.usedSecret ? ' using the shared secret from the app environment.' : ' without a shared secret in the app environment.'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...result!.items.map(
              (item) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        (item.ok
                                ? AppColours.darkSecondary
                                : AppColours.darkPrimary)
                            .withValues(alpha: 0.26),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColours.darkText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _Pill(
                          label: item.ok ? 'Passed' : 'Needs attention',
                          icon: item.ok
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          accent: item.ok
                              ? AppColours.darkSecondary
                              : AppColours.darkPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.command,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      item.detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogViewerCard extends StatelessWidget {
  const _LogViewerCard({
    required this.selectedLogKey,
    required this.selectedLogPath,
    required this.logFuture,
    required this.onSelectLog,
    required this.onRefresh,
    required this.onCopyLatestError,
    required this.onOpenLogsFolder,
  });

  final String selectedLogKey;
  final String selectedLogPath;
  final Future<String> logFuture;
  final ValueChanged<String> onSelectLog;
  final VoidCallback onRefresh;
  final VoidCallback onCopyLatestError;
  final VoidCallback onOpenLogsFolder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const options = <MapEntry<String, String>>[
      MapEntry('launcher', 'Launcher log'),
      MapEntry('mock', 'Mock dashboard log'),
      MapEntry('gateway', 'Voice gateway log'),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Launcher logs',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh log'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use this panel to quickly inspect the most recent launcher output without leaving the dashboard.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => ChoiceChip(
                    label: Text(option.value),
                    selected: selectedLogKey == option.key,
                    onSelected: (_) => onSelectLog(option.key),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            selectedLogPath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: onCopyLatestError,
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Copy latest error'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLogsFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open logs folder'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: logFuture,
            builder: (context, snapshot) {
              final value = snapshot.data ?? 'Loading log...';
              return Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 160),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColours.darkOutline.withValues(alpha: 0.8),
                  ),
                ),
                child: SelectableText(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    fontFamily: 'monospace',
                    height: 1.45,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({required this.endpoint});

  final _EndpointHealth endpoint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = endpoint.healthy
        ? AppColours.darkSecondary
        : AppColours.darkPrimary;
    final statusSummary = endpoint.healthy
        ? 'Live signal detected'
        : 'Waiting for local response';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: endpoint.healthy
              ? AppColours.darkSecondary.withValues(alpha: 0.12)
              : AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
          boxShadow: endpoint.healthy
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    endpoint.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _Pill(
                  label: endpoint.statusText,
                  icon: endpoint.healthy
                      ? Icons.check_circle_outline
                      : Icons.pause_circle_outline,
                  accent: accent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              statusSummary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              endpoint.uri.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              endpoint.detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  const _StatusGrid({required this.status});

  final AlexaVoiceGatewayStatusSnapshot status;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 4 ? 1.7 : 1.45,
          children: [
            _StatusTile(
              title: 'Gateway running',
              value: status.gatewayRunning ? 'Running' : 'Stopped',
              icon: status.gatewayRunning
                  ? Icons.play_circle_outline
                  : Icons.pause_circle_outline,
              accent: status.gatewayRunning
                  ? AppColours.darkSecondary
                  : AppColours.darkPrimary,
            ),
            _StatusTile(
              title: 'Alexa skill',
              value: status.skillConfigured ? 'Configured' : 'Not configured',
              icon: status.skillConfigured
                  ? Icons.verified_outlined
                  : Icons.pending_outlined,
              accent: status.skillConfigured
                  ? AppColours.darkSecondary
                  : AppColours.darkPrimary,
            ),
            _StatusTile(
              title: 'Last command received',
              value: status.lastCommandReceived,
              icon: Icons.history_outlined,
              accent: AppColours.darkGlow,
            ),
            _StatusTile(
              title: 'Last command status',
              value: status.lastCommandStatus,
              icon: Icons.policy_outlined,
              accent: AppColours.darkSecondary,
            ),
          ],
        );
      },
    );
  }
}

class _CommandSection extends StatelessWidget {
  const _CommandSection({
    required this.title,
    required this.subtitle,
    required this.commands,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final List<AlexaVoiceGatewayCommandItem> commands;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: commands
                .map(
                  (command) => _CommandChip(command: command, accent: accent),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CommandChip extends StatelessWidget {
  const _CommandChip({required this.command, required this.accent});

  final AlexaVoiceGatewayCommandItem command;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    command.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _Pill(
                  label: command.status,
                  icon: command.status == 'Allowed'
                      ? Icons.check_circle_outline
                      : Icons.block_outlined,
                  accent: accent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              command.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              command.command,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${command.intent} • Level ${command.permissionLevel}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditSection extends StatelessWidget {
  const _AuditSection({required this.entries});

  final List<AlexaVoiceGatewayAuditEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent audit log entries',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 14),
          ...entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColours.darkOutline.withValues(alpha: 0.75),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.command,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColours.darkText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _Pill(
                        label: entry.permissionResult,
                        icon: entry.permissionResult == 'allowed'
                            ? Icons.check_circle_outline
                            : Icons.block_outlined,
                        accent: entry.permissionResult == 'allowed'
                            ? AppColours.darkSecondary
                            : AppColours.darkPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${entry.timestamp} • ${entry.source} • ${entry.actionTaken}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                  if (entry.blockedReason != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      entry.blockedReason!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(borderColor: accent.withValues(alpha: 0.25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const Spacer(),
              _Pill(
                label: title == 'Gateway running'
                    ? (value == 'Running' ? 'Live' : 'Offline')
                    : value,
                icon: icon,
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.accent,
    required this.icon,
    this.footer,
  });

  final String title;
  final String body;
  final Color accent;
  final IconData icon;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(borderColor: accent.withValues(alpha: 0.22)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                if (footer != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    footer!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColours.darkSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon, required this.accent});

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndpointHealth {
  const _EndpointHealth({
    required this.label,
    required this.uri,
    required this.statusText,
    required this.healthy,
    required this.detail,
  });

  final String label;
  final Uri uri;
  final String statusText;
  final bool healthy;
  final String detail;
}

class _SmokeTestResult {
  const _SmokeTestResult({
    required this.ranAt,
    required this.usedSecret,
    required this.items,
  });

  final DateTime ranAt;
  final bool usedSecret;
  final List<_SmokeTestItem> items;
}

class _SmokeTestItem {
  const _SmokeTestItem({
    required this.label,
    required this.command,
    required this.ok,
    required this.detail,
  });

  final String label;
  final String command;
  final bool ok;
  final String detail;
}

String _formatLocalClock(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

BoxDecoration _panelDecoration({Color? borderColor}) {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: borderColor ?? AppColours.darkOutline.withValues(alpha: 0.9),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
