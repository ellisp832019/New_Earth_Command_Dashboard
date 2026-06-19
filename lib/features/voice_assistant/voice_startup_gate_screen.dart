import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/desktop_startup_backdrop.dart';
import '../../core/routing/route_names.dart';
import '../settings/application/settings_controller.dart';
import 'application/voice_startup_gate_controller.dart';
import 'desktop_speech_bridge_service.dart';
import 'voice_speech_diagnostics_service.dart';
import 'voice_startup_gate_service.dart';

class VoiceStartupGateScreen extends ConsumerStatefulWidget {
  const VoiceStartupGateScreen({super.key, required this.result});

  final VoiceStartupGateResult result;

  @override
  ConsumerState<VoiceStartupGateScreen> createState() =>
      _VoiceStartupGateScreenState();
}

class _VoiceStartupGateScreenState
    extends ConsumerState<VoiceStartupGateScreen> {
  static const double _panelMargin = 20;
  static const double _panelMaxWidth = 760;
  static const double _panelMinWidth = 340;
  static const double _panelMaxHeight = 760;

  Timer? _refreshTimer;
  bool _voiceDiagnosticsShown = false;
  Offset _panelOffset = const Offset(_panelMargin, _panelMargin);
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _scheduleRefresh();
    _maybeShowVoiceDiagnostics();
  }

  @override
  void didUpdateWidget(covariant VoiceStartupGateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleRefresh();
    _maybeShowVoiceDiagnostics();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    if (widget.result.isReady) {
      return;
    }

    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        return;
      }

      ref.invalidate(voiceStartupGateProvider);
    });
  }

  void _maybeShowVoiceDiagnostics() {
    if (widget.result.isReady || _voiceDiagnosticsShown) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.result.isReady || _voiceDiagnosticsShown) {
        return;
      }

      _voiceDiagnosticsShown = true;
      unawaited(_showVoiceDiagnostics());
    });
  }

  Future<void> _showVoiceDiagnostics() async {
    final diagnostics = await VoiceSpeechDiagnosticsService().run();
    if (!mounted) {
      return;
    }

    final bridge = diagnostics.bridgeDiagnostics;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Voice diagnostics'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(diagnostics.headsetStatus),
                const SizedBox(height: 12),
                Text(diagnostics.bridgeStatus),
                if (bridge != null) ...[
                  const SizedBox(height: 12),
                  Text('Python: ${bridge.pythonVersion}'),
                  Text('Bridge model: ${bridge.bridgeModel}'),
                  if (bridge.defaultInputDevice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Default input: ${bridge.defaultInputDevice!['name']}',
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                Text(diagnostics.recommendation),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handleDragUpdate({
    required DragUpdateDetails details,
    required Size viewport,
    required double panelWidth,
    required double panelHeight,
  }) {
    final maxX = (viewport.width - panelWidth - _panelMargin)
        .clamp(_panelMargin, double.infinity)
        .toDouble();
    final maxY = (viewport.height - panelHeight - _panelMargin)
        .clamp(_panelMargin, double.infinity)
        .toDouble();

    setState(() {
      _panelOffset = Offset(
        (_panelOffset.dx + details.delta.dx).clamp(_panelMargin, maxX),
        (_panelOffset.dy + details.delta.dy).clamp(_panelMargin, maxY),
      );
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) {
      return;
    }

    setState(() {
      _isDragging = false;
    });
  }

  static String _headlineForResult(VoiceStartupGateResult result) {
    return switch (result.resolvedState) {
      VoiceStartupGateState.ready => 'Headset detected',
      VoiceStartupGateState.noDevices => 'No microphone or headset found',
      VoiceStartupGateState.microphoneOnly =>
        'Microphone found, but not a headset-like device',
      VoiceStartupGateState.checkFailed => 'Could not check audio devices',
      VoiceStartupGateState.bypassed => 'Voice gate bypassed',
    };
  }

  static String _explanationForResult(VoiceStartupGateResult result) {
    return switch (result.resolvedState) {
      VoiceStartupGateState.ready =>
        'The assistant can start hands-free voice with the headset you connected.',
      VoiceStartupGateState.noDevices =>
        'No audio input is showing up yet. Connect a Bluetooth headset or headset microphone, then try again.',
      VoiceStartupGateState.microphoneOnly =>
        'Windows can see a microphone, but not one that looks like a headset. If this is your headset mic, choose Continue with Voice.',
      VoiceStartupGateState.checkFailed =>
        'The assistant could not verify the audio devices from Windows right now. Open diagnostics to check the offline bridge and default input path.',
      VoiceStartupGateState.bypassed =>
        'The startup gate is bypassed on this platform, so the assistant will continue without blocking.',
    };
  }

  static String _nextStepForResult(VoiceStartupGateResult result) {
    return switch (result.resolvedState) {
      VoiceStartupGateState.ready => 'You can continue into the assistant now.',
      VoiceStartupGateState.noDevices =>
        'If a headset is already connected, unplug and reconnect it, then retry.',
      VoiceStartupGateState.microphoneOnly =>
        'Choose Continue with Voice if this microphone is actually the one on your headset.',
      VoiceStartupGateState.checkFailed =>
        'Run diagnostics to see whether the bridge can still reach the input device.',
      VoiceStartupGateState.bypassed =>
        'You can continue to the dashboard without waiting for the gate.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.result;

    return DesktopStartupBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = constraints.biggest;
              final panelWidth = _resolvePanelWidth(viewport.width);
              final panelHeight = _resolvePanelHeight(viewport.height);
              final maxX = (viewport.width - panelWidth - _panelMargin)
                  .clamp(_panelMargin, double.infinity)
                  .toDouble();
              final maxY = (viewport.height - panelHeight - _panelMargin)
                  .clamp(_panelMargin, double.infinity)
                  .toDouble();
              final offset = Offset(
                _panelOffset.dx.clamp(_panelMargin, maxX),
                _panelOffset.dy.clamp(_panelMargin, maxY),
              );

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPositioned(
                    duration: _isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: offset.dx,
                    top: offset.dy,
                    width: panelWidth,
                    height: panelHeight,
                    child: _VoiceGateFloatingPanel(
                      theme: theme,
                      result: result,
                      isDragging: _isDragging,
                      onDragStart: _handleDragStart,
                      onDragUpdate: (details) => _handleDragUpdate(
                        details: details,
                        viewport: viewport,
                        panelWidth: panelWidth,
                        panelHeight: panelHeight,
                      ),
                      onDragEnd: _handleDragEnd,
                      onRetry: () {
                        ref.invalidate(voiceStartupGateProvider);
                      },
                      onCheckAgain: () {
                        ref.invalidate(voiceStartupGateProvider);
                      },
                      onHaveVoice: () {
                        ref
                            .read(settingsControllerProvider)
                            .setVoicePreferences(voiceAssistantEnabled: true);
                        ref
                            .read(voiceStartupGateLandingProvider.notifier)
                            .requestVoiceAssistant();
                        if (mounted) {
                          context.go(RouteNames.voiceAssistant);
                        }
                      },
                      onNoVoice: () {
                        ref
                            .read(settingsControllerProvider)
                            .setVoicePreferences(voiceAssistantEnabled: false);
                        ref
                            .read(voiceStartupGateLandingProvider.notifier)
                            .requestDashboard();
                        if (mounted) {
                          context.go(RouteNames.dashboard);
                        }
                      },
                      onRunDiagnostics: _showVoiceDiagnostics,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _resolvePanelWidth(double viewportWidth) {
    final available = viewportWidth - (_panelMargin * 2);
    if (available < _panelMinWidth) {
      return available.clamp(0.0, _panelMinWidth).toDouble();
    }

    return available.clamp(_panelMinWidth, _panelMaxWidth).toDouble();
  }

  double _resolvePanelHeight(double viewportHeight) {
    final available = viewportHeight - (_panelMargin * 2);
    if (available < 420) {
      return available;
    }

    return available.clamp(420.0, _panelMaxHeight).toDouble();
  }
}

class _VoiceGateFloatingPanel extends StatelessWidget {
  const _VoiceGateFloatingPanel({
    required this.theme,
    required this.result,
    required this.isDragging,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onRetry,
    required this.onCheckAgain,
    required this.onHaveVoice,
    required this.onNoVoice,
    required this.onRunDiagnostics,
  });

  final ThemeData theme;
  final VoiceStartupGateResult result;
  final bool isDragging;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onRetry;
  final VoidCallback onCheckAgain;
  final VoidCallback onHaveVoice;
  final VoidCallback onNoVoice;
  final Future<void> Function() onRunDiagnostics;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF122530).withValues(alpha: 0.96),
                const Color(0xFF0E1D26).withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(
                0xFF294B58,
              ).withValues(alpha: isDragging ? 0.95 : 0.68),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF5CC7F8,
                ).withValues(alpha: isDragging ? 0.22 : 0.1),
                blurRadius: isDragging ? 56 : 34,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDragging ? 0.42 : 0.34),
                blurRadius: isDragging ? 58 : 42,
                offset: Offset(0, isDragging ? 26 : 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _VoiceGateDragBar(
                onDragStart: onDragStart,
                onDragUpdate: onDragUpdate,
                onDragEnd: onDragEnd,
              ),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _VoiceStartupGateScreenState._headlineForResult(
                            result,
                          ),
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(result.message, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text(
                          'The assistant keeps checking while this screen is open, so you can connect the headset and continue without restarting.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 14),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What the assistant sees',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _VoiceStartupGateScreenState._explanationForResult(
                                    result,
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _VoiceStartupGateScreenState._nextStepForResult(
                                    result,
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Capture path',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DesktopSpeechBridgeService.isSupported
                                      ? 'Windows voice capture tries the local bridge first, then falls back to the local microphone recognizer.'
                                      : 'This build falls back to the local microphone recognizer when the bridge is not available.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (result.devices.isNotEmpty) ...[
                          Text(
                            'Detected audio inputs',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ...result.devices.map(
                            (device) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  device.isHeadsetLike
                                      ? Icons.headphones_outlined
                                      : Icons.mic_outlined,
                                ),
                                title: Text(device.name),
                                subtitle: device.identifier.isEmpty
                                    ? null
                                    : Text(device.identifier),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh_outlined),
                              label: const Text('Retry'),
                            ),
                            TextButton.icon(
                              onPressed: onCheckAgain,
                              icon: const Icon(Icons.headset_outlined),
                              label: const Text('Check again'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: onHaveVoice,
                              icon: const Icon(Icons.headset_mic_outlined),
                              label: const Text('Continue with Voice'),
                            ),
                            OutlinedButton.icon(
                              onPressed: onNoVoice,
                              icon: const Icon(Icons.volume_off_outlined),
                              label: const Text('Skip Voice'),
                            ),
                            TextButton.icon(
                              onPressed: onRunDiagnostics,
                              icon: const Icon(
                                Icons.health_and_safety_outlined,
                              ),
                              label: const Text('Run diagnostics'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'The assistant keeps rechecking while this screen is open, and you can still use diagnostics or bypass if your headset mic is the correct input.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'If your headset shows up as a plain microphone, you can still open the assistant and use it as the input device.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'If you prefer, disable the voice assistant now and re-enable it later in Settings.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceGateDragBar extends StatelessWidget {
  const _VoiceGateDragBar({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: onDragStart,
        onPanUpdate: onDragUpdate,
        onPanEnd: onDragEnd,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF294B58).withValues(alpha: 0.6),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF5CC7F8).withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Voice gate',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                'Drag to move',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFA3B3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
