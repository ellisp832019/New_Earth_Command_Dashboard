import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/desktop_startup_backdrop.dart';
import '../application/security_session_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../../users_devices_control/application/users_devices_control_controller.dart';
import '../../users_devices_control/data/users_devices_control_repository.dart';

class SecurityLockScreen extends ConsumerStatefulWidget {
  const SecurityLockScreen({super.key});

  @override
  ConsumerState<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends ConsumerState<SecurityLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _showPin = false;
  String _status = 'Locked';
  String _detail = 'Waiting for local verification.';
  String _auditSummary = 'No audit decision recorded yet.';
  String? _latestAuditEventId;
  bool _busy = false;
  bool _canContinue = false;
  String? _selectedUserId;
  String? _selectedDeviceId;
  bool _seededDefaults = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _seedSelections(UsersDevicesControlSnapshot snapshot) {
    if (_seededDefaults) {
      return;
    }

    _selectedUserId = snapshot.users.firstWhere(
      (user) => user.status == 'active',
      orElse: () => snapshot.users.first,
    ).id;
    _selectedDeviceId = snapshot.devices.firstWhere(
      (device) => device.status == 'trusted' || device.trustLevel >= 3,
      orElse: () => snapshot.devices.first,
    ).id;
    _seededDefaults = true;
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '0s';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }

    if (minutes > 0) {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }

    return '${seconds}s';
  }

  Future<void> _attemptUnlock() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _canContinue = false;
      _status = 'Checking local identity';
      _detail = 'Consulting the local access plan in Users & Devices.';
      _auditSummary = 'Writing audit trail...';
      _latestAuditEventId = null;
    });

    final enteredPin = _pinController.text.trim();
    const demoPin = '2468';
    if (_showPin && enteredPin.isNotEmpty && enteredPin != demoPin) {
      setState(() {
        _busy = false;
        _status = 'Locked';
        _detail = 'Demo PIN rejected. Use 2468 for the local demo.';
        _auditSummary = 'PIN check failed before access control.';
        _latestAuditEventId = null;
      });
      return;
    }

    final repository = ref.read(usersDevicesControlRepositoryProvider);
    final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);
    final userId = _selectedUserId ?? (snapshot.users.isNotEmpty ? snapshot.users.first.id : '');
    final deviceId =
        _selectedDeviceId ?? (snapshot.devices.isNotEmpty ? snapshot.devices.first.id : '');
    final selectedUser = snapshot.users.isEmpty
        ? null
        : snapshot.users.firstWhere(
            (user) => user.id == userId,
            orElse: () => snapshot.users.first,
          );
    if (userId.isEmpty || deviceId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _status = 'Locked';
        _detail = 'Pick a local user and device before unlocking.';
        _auditSummary = 'No access check was written because the gate was incomplete.';
        _latestAuditEventId = null;
      });
      return;
    }

    final decision = await repository.canOpenModule(
      userId,
      deviceId,
      '01_USERS_AND_DEVICES_CONTROL',
    );

    if (!mounted) {
      return;
    }

    if (decision.allowed) {
      final updatedSnapshot = await ref.read(
        usersDevicesControlSnapshotProvider.future,
      );
      ref.read(securitySessionProvider.notifier).unlock(
        activeUserLabel: selectedUser?.displayName,
        activeUserOnline: selectedUser?.status == 'active',
      );
      final latestAudit = updatedSnapshot.auditLog.isNotEmpty
          ? updatedSnapshot.auditLog.last
          : null;
      setState(() {
        _busy = false;
        _canContinue = true;
        _status = 'Unlocked locally';
        _detail = decision.nextStep.isNotEmpty
            ? '${decision.reason} ${decision.nextStep}'
            : decision.reason;
        _latestAuditEventId = latestAudit?.eventId;
        _auditSummary = latestAudit == null
            ? 'The access check passed and was recorded locally.'
            : '${latestAudit.eventType} - ${latestAudit.result} - ${latestAudit.reason}';
      });
      return;
    }

    final updatedSnapshot = await ref.read(
      usersDevicesControlSnapshotProvider.future,
    );
    final latestAudit = updatedSnapshot.auditLog.isNotEmpty
        ? updatedSnapshot.auditLog.last
        : null;
    setState(() {
      _busy = false;
      _status = decision.requiresApproval ? 'Approval needed' : 'Locked';
      _detail = decision.nextStep.isNotEmpty
          ? '${decision.reason} ${decision.nextStep}'
          : decision.reason;
      _latestAuditEventId = latestAudit?.eventId;
      _auditSummary = latestAudit == null
          ? 'The access check was denied and should be reviewed.'
          : '${latestAudit.eventType} - ${latestAudit.result} - ${latestAudit.reason}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    final settingsSnapshot = ref.watch(settingsSnapshotProvider);
    final securitySession = ref.watch(securitySessionProvider);
    final sessionCountdownLabel = securitySession.isUnlocked &&
            !securitySession.isExpired &&
            securitySession.remaining != null
        ? 'Session expires in ${_formatDuration(securitySession.remaining!)}'
        : 'Session locked';
    final sessionCountdownAccent =
        securitySession.isUnlocked && !securitySession.isExpired
            ? const Color(0xFF9BE564)
            : theme.colorScheme.outlineVariant;

    return DesktopStartupBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: snapshot.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Security Lock could not load the local registry.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        ref.invalidate(usersDevicesControlSnapshotProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (data) {
            final voiceStartupGateEnabled = settingsSnapshot.maybeWhen(
              data: (snapshot) => snapshot.settings.voiceStartupGateEnabled,
              orElse: () => false,
            );
            _seedSelections(data);
            final selectedUser = data.users.isEmpty
                ? null
                : data.users.firstWhere(
                    (user) => user.id == _selectedUserId,
                    orElse: () => data.users.first,
                  );
            final selectedDevice = data.devices.isEmpty
                ? null
                : data.devices.firstWhere(
                    (device) => device.id == _selectedDeviceId,
                    orElse: () => data.devices.first,
                  );

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.72),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 820;
                              final header = _SecurityHero(
                                status: _status,
                                detail: _detail,
                                auditSummary: _auditSummary,
                                hasLatestAuditEvent:
                                    _latestAuditEventId != null,
                                selectedUserLabel: selectedUser?.displayName ??
                                    'No local user selected',
                                selectedDeviceLabel: selectedDevice?.name ??
                                    'No local device selected',
                                sessionCountdownLabel: sessionCountdownLabel,
                                sessionCountdownAccent:
                                    sessionCountdownAccent,
                                onUnlock: _attemptUnlock,
                                canContinue: _canContinue,
                                continueLabel: voiceStartupGateEnabled
                                    ? 'Continue to voice gate'
                                    : 'Open dashboard',
                                onContinue: _canContinue
                                    ? () => context.go(
                                          voiceStartupGateEnabled
                                              ? RouteNames.voiceStartupGate
                                              : RouteNames.dashboard,
                                        )
                                    : null,
                                onOpenUsersDevices: () => context.push(
                                  RouteNames.usersDevices,
                                ),
                                onOpenAuditLog: () => context.push(
                                  _latestAuditEventId == null
                                      ? RouteNames.usersDevicesAuditLog
                                      : RouteNames.usersDevicesAuditLogFor(
                                          _latestAuditEventId!,
                                        ),
                                ),
                              );
                              final sidePanel = _SecuritySidePanel(
                                showPin: _showPin,
                                pinController: _pinController,
                                selectedUserId: _selectedUserId,
                                selectedDeviceId: _selectedDeviceId,
                                users: data.users,
                                devices: data.devices,
                                onUserChanged: (value) {
                                  setState(() {
                                    _selectedUserId = value;
                                  });
                                },
                                onDeviceChanged: (value) {
                                  setState(() {
                                    _selectedDeviceId = value;
                                  });
                                },
                                onTogglePin: () => setState(() {
                                  _showPin = !_showPin;
                                }),
                                isBusy: _busy,
                                onUnlock: _attemptUnlock,
                              );

                              if (isWide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 3, child: header),
                                    const SizedBox(width: 18),
                                    Expanded(flex: 2, child: sidePanel),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  header,
                                  const SizedBox(height: 18),
                                  sidePanel,
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SecurityHero extends StatelessWidget {
  const _SecurityHero({
    required this.status,
    required this.detail,
    required this.auditSummary,
    required this.hasLatestAuditEvent,
    required this.selectedUserLabel,
    required this.selectedDeviceLabel,
    required this.sessionCountdownLabel,
    required this.sessionCountdownAccent,
    required this.onUnlock,
    required this.canContinue,
    required this.continueLabel,
    required this.onContinue,
    required this.onOpenUsersDevices,
    required this.onOpenAuditLog,
  });

  final String status;
  final String detail;
  final String auditSummary;
  final bool hasLatestAuditEvent;
  final String selectedUserLabel;
  final String selectedDeviceLabel;
  final String sessionCountdownLabel;
  final Color sessionCountdownAccent;
  final VoidCallback onUnlock;
  final bool canContinue;
  final String continueLabel;
  final VoidCallback? onContinue;
  final VoidCallback onOpenUsersDevices;
  final VoidCallback onOpenAuditLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _VisualPanel(
      title: 'Security Lock',
      subtitle:
          'This is the local entry point for the access plan: identity, device trust, approvals, and sensitive module access. Cloud login stays out of V0.1.',
      icon: Icons.lock_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Badge(label: 'Local-first'),
              _Badge(label: 'No cloud login'),
              _Badge(label: 'Audit required'),
              _Badge(label: 'Trust checked'),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              final stats = [
                _MetricTile(
                  label: 'State',
                  value: status,
                  icon: Icons.lock_clock_outlined,
                ),
                _MetricTile(
                  label: 'Audit',
                  value: hasLatestAuditEvent ? 'Recorded' : 'None yet',
                  icon: Icons.receipt_long_outlined,
                ),
                _MetricTile(
                  label: 'Action',
                  value: canContinue ? 'Open' : 'Review',
                  icon: Icons.arrow_forward_outlined,
                ),
              ];

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              Chip(label: Text('User: $selectedUserLabel')),
                              Chip(label: Text('Device: $selectedDeviceLabel')),
                                Chip(
                                  label: Text(sessionCountdownLabel),
                                  side: BorderSide(
                                    color: sessionCountdownAccent
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _VisualPanel(
                            title: 'Current access summary',
                            subtitle:
                                'A quick read on the active local user, trusted device, and gate status.',
                            icon: Icons.person_search_outlined,
                            compact: true,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Badge(label: 'Status: $status'),
                                _Badge(label: 'User: $selectedUserLabel'),
                                _Badge(label: 'Device: $selectedDeviceLabel'),
                                _Badge(
                                  label: hasLatestAuditEvent
                                      ? 'Audit recorded'
                                      : 'No audit yet',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _VisualPanel(
                            title: 'Latest audit event',
                            subtitle: auditSummary,
                            icon: Icons.verified_outlined,
                            compact: true,
                            child: TextButton.icon(
                              onPressed: onOpenAuditLog,
                              icon: const Icon(Icons.receipt_long_outlined),
                              label: const Text('Open audit log'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(children: stats),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(detail, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Chip(label: Text('User: $selectedUserLabel')),
                          Chip(label: Text('Device: $selectedDeviceLabel')),
                          Chip(
                            label: Text(sessionCountdownLabel),
                            side: BorderSide(
                              color:
                                  sessionCountdownAccent.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                  const SizedBox(height: 14),
                  _VisualPanel(
                    title: 'Current access summary',
                    subtitle:
                        'A quick read on the active local user, trusted device, and gate status.',
                    icon: Icons.person_search_outlined,
                    compact: true,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(label: 'Status: $status'),
                        _Badge(label: 'User: $selectedUserLabel'),
                        _Badge(label: 'Device: $selectedDeviceLabel'),
                        _Badge(
                          label: hasLatestAuditEvent
                              ? 'Audit recorded'
                              : 'No audit yet',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _VisualPanel(
                    title: 'Latest audit event',
                    subtitle: auditSummary,
                    icon: Icons.verified_outlined,
                    compact: true,
                    child: TextButton.icon(
                      onPressed: onOpenAuditLog,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Open audit log'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...stats,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _VisualPanel(
            title: 'Access plan',
            subtitle: 'Identity, trust, scope, and audit all stay visible',
            icon: Icons.shield_outlined,
            compact: true,
            child: const Column(
              children: [
                _LayerRow(
                  title: 'Identity',
                  body: 'Who is requesting access?',
                ),
                _LayerRow(
                  title: 'Device trust',
                  body: 'Is this device known and trusted enough?',
                ),
                _LayerRow(
                  title: 'Role + permission',
                  body: 'Does the user have the right scope?',
                ),
                _LayerRow(
                  title: 'Audit trail',
                  body: 'Was the decision written locally?',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onUnlock,
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('Unlock session'),
              ),
              if (canContinue && onContinue != null)
                FilledButton.tonalIcon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_outlined),
                  label: Text(continueLabel),
                ),
              OutlinedButton.icon(
                onPressed: onOpenUsersDevices,
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Open Users & Devices'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecuritySidePanel extends StatelessWidget {
  const _SecuritySidePanel({
    required this.showPin,
    required this.pinController,
    required this.selectedUserId,
    required this.selectedDeviceId,
    required this.users,
    required this.devices,
    required this.onUserChanged,
    required this.onDeviceChanged,
    required this.isBusy,
    required this.onTogglePin,
    required this.onUnlock,
  });

  final bool showPin;
  final TextEditingController pinController;
  final String? selectedUserId;
  final String? selectedDeviceId;
  final List<UsersDevicesControlUser> users;
  final List<UsersDevicesControlDevice> devices;
  final ValueChanged<String?> onUserChanged;
  final ValueChanged<String?> onDeviceChanged;
  final bool isBusy;
  final VoidCallback onTogglePin;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _VisualPanel(
          title: 'Unlock options',
          subtitle:
              'Choose the local user and trusted device that should unlock the session.',
          icon: Icons.login_outlined,
          compact: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: showPin,
                onChanged: (_) => onTogglePin(),
                title: const Text('Show local PIN field'),
                subtitle: const Text('Future PIN/passkey entry'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Local user',
                  border: OutlineInputBorder(),
                ),
                items: users
                    .map(
                      (user) => DropdownMenuItem<String>(
                        value: user.id,
                        child: Text(user.displayName),
                      ),
                    )
                    .toList(),
                onChanged: onUserChanged,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedDeviceId,
                decoration: const InputDecoration(
                  labelText: 'Trusted device',
                  border: OutlineInputBorder(),
                ),
                items: devices
                    .map(
                      (device) => DropdownMenuItem<String>(
                        value: device.id,
                        child: Text('${device.name} (T${device.trustLevel})'),
                      ),
                    )
                    .toList(),
                onChanged: onDeviceChanged,
              ),
              if (showPin) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Local PIN',
                    hintText: 'Demo placeholder only',
                  ),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: isBusy ? null : onUnlock,
                icon: isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_outlined),
                label: Text(isBusy ? 'Checking...' : 'Unlock session'),
              ),
              const SizedBox(height: 8),
              Text(
                'The session will lock itself again after inactivity.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LayerRow extends StatelessWidget {
  const _LayerRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fiber_manual_record, size: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}

class _VisualPanel extends StatelessWidget {
  const _VisualPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.46),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 40 : 46,
                    height: compact ? 40 : 46,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: compact ? 20 : 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(subtitle),
                      ],
                    ),
                  ),
                ],
              ),
              if (!compact) const SizedBox(height: 16),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 3),
                  Text(value, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
