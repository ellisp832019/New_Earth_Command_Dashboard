import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/routing/security_route_policy.dart';
import '../application/users_devices_control_controller.dart';
import '../application/users_devices_pin_registry_controller.dart';
import '../data/users_devices_control_repository.dart';
import '../data/users_devices_pin_registry_service.dart';
import '../../security/application/security_session_controller.dart';

class UsersDevicesPinsScreen extends ConsumerStatefulWidget {
  const UsersDevicesPinsScreen({super.key, this.initialUserId});

  final String? initialUserId;

  @override
  ConsumerState<UsersDevicesPinsScreen> createState() =>
      _UsersDevicesPinsScreenState();
}

class _UsersDevicesPinsScreenState
    extends ConsumerState<UsersDevicesPinsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _userPinsSectionKey = GlobalKey();
  String? _selectedUserId;
  bool _seeded = false;
  bool _busy = false;
  String? _recentRecoveryPin;
  String? _lastAutoScrolledUserId;

  void _seedSelection(UsersDevicesControlSnapshot snapshot) {
    if (_seeded) {
      return;
    }

    if (widget.initialUserId != null &&
        snapshot.users.any((user) => user.id == widget.initialUserId)) {
      _selectedUserId = widget.initialUserId;
    } else {
      _selectedUserId = snapshot.users.isNotEmpty
          ? snapshot.users
                .firstWhere(
                  (user) => user.status == 'active',
                  orElse: () => snapshot.users.first,
                )
                .id
          : null;
    }
    _seeded = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _setPrimaryPin() async {
    final userId = _selectedUserId;
    if (userId == null || _busy) {
      return;
    }

    final controller = TextEditingController();
    final labelController = TextEditingController(text: 'Primary PIN');
    final result = await showDialog<({String pinCode, String label})>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Set primary PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Primary label'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'PIN code',
                  hintText: 'Use 4 to 8 digits',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop((
                  pinCode: controller.text.trim(),
                  label: labelController.text.trim(),
                ));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    labelController.dispose();

    if (result == null || result.pinCode.isEmpty) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final pins = ref.read(usersDevicesPinRegistryProvider);
    await pins.setPrimaryPin(
      userId: userId,
      pinCode: result.pinCode,
      label: result.label.isEmpty ? 'Primary PIN' : result.label,
    );

    await _auditPinChange(
      userId: userId,
      eventType: 'pin_set',
      action: 'set_primary_pin',
      reason: 'Primary PIN updated locally.',
    );

    if (mounted) {
      setState(() {
        _busy = false;
        _recentRecoveryPin = null;
      });
      ref.invalidate(usersDevicesPinRegistrySnapshotProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primary PIN saved for the selected user.'),
        ),
      );
    }
  }

  void _maybeScrollToSelectedUser(String? selectedUserId) {
    if (selectedUserId == null || selectedUserId == _lastAutoScrolledUserId) {
      return;
    }

    _lastAutoScrolledUserId = selectedUserId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final context = _userPinsSectionKey.currentContext;
      if (context == null) {
        return;
      }

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  Future<void> _issueRecoveryPin() async {
    final userId = _selectedUserId;
    if (userId == null || _busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final pins = ref.read(usersDevicesPinRegistryProvider);
    final record = await pins.issueRecoveryPin(userId: userId);
    await _auditPinChange(
      userId: userId,
      eventType: 'pin_recovery_issued',
      action: 'issue_recovery_pin',
      reason: 'Recovery PIN issued locally.',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
      _recentRecoveryPin = record.pinCode;
    });
    ref.invalidate(usersDevicesPinRegistrySnapshotProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recovery PIN issued: ${record.pinCode}')),
    );
  }

  Future<void> _revokeUserPins() async {
    final userId = _selectedUserId;
    if (userId == null || _busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    await ref
        .read(usersDevicesPinRegistryProvider)
        .revokeAllPinsForUser(userId);
    await _auditPinChange(
      userId: userId,
      eventType: 'pin_revoked',
      action: 'revoke_all_pins',
      reason: 'All local PINs revoked for the user.',
    );

    if (mounted) {
      setState(() {
        _busy = false;
        _recentRecoveryPin = null;
      });
      ref.invalidate(usersDevicesPinRegistrySnapshotProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All PINs for this user were revoked.')),
      );
    }
  }

  Future<void> _revokeRecord(UsersDevicesPinRecord record) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    await ref.read(usersDevicesPinRegistryProvider).revokePin(record.pinId);
    await _auditPinChange(
      userId: record.userId,
      eventType: 'pin_revoked',
      action: 'revoke_pin',
      reason: '${record.label} revoked locally.',
    );

    if (mounted) {
      setState(() {
        _busy = false;
      });
      ref.invalidate(usersDevicesPinRegistrySnapshotProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${record.label} was revoked.')));
    }
  }

  Future<void> _auditPinChange({
    required String userId,
    required String eventType,
    required String action,
    required String reason,
  }) async {
    final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);
    final user = snapshot.users.firstWhere(
      (entry) => entry.id == userId,
      orElse: () => snapshot.users.isNotEmpty
          ? snapshot.users.first
          : const UsersDevicesControlUser(
              id: '',
              displayName: '',
              role: '',
              status: 'active',
              permissions: [],
              linkedDevices: [],
            ),
    );
    final deviceId = user.linkedDevices.isNotEmpty
        ? user.linkedDevices.first
        : '';
    if (userId.isEmpty) {
      return;
    }

    await ref
        .read(usersDevicesControlRepositoryProvider)
        .createAuditEvent(
          actorId: userId,
          deviceId: deviceId,
          eventType: eventType,
          targetModule: '01_USERS_AND_DEVICES_CONTROL',
          action: action,
          result: 'allowed',
          reason: reason,
        );
  }

  @override
  Widget build(BuildContext context) {
    final securitySession = ref.watch(securitySessionProvider);
    final isSessionLocked =
        !securitySession.isUnlocked || securitySession.isExpired;
    final usersSnapshot = ref.watch(usersDevicesControlSnapshotProvider);
    final pinsSnapshot = ref.watch(usersDevicesPinRegistrySnapshotProvider);

    if (isSessionLocked) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PIN Registry'),
          leading: IconButton(
            onPressed: () => context.go(RouteNames.usersDevices),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PIN Registry is locked',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Open Security Lock and unlock the local session before managing user PINs.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                context.go(
                                  SecurityRoutePolicy.securityLockFrom(
                                    GoRouterState.of(context).uri,
                                  ),
                                ),
                            icon: const Icon(Icons.lock_outline),
                            label: const Text('Open Security Lock'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.go(RouteNames.usersDevices),
                            icon: const Icon(Icons.shield_outlined),
                            label: const Text('Back to Users & Devices'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PIN Registry'),
        leading: IconButton(
          onPressed: () => context.go(RouteNames.usersDevices),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: usersSnapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('Users & Devices data is not ready right now.'),
        ),
        data: (users) {
          _seedSelection(users);
          final selectedUser = users.users.isEmpty
              ? null
              : users.users.any((user) => user.id == _selectedUserId)
              ? users.users.firstWhere((user) => user.id == _selectedUserId)
              : users.users.first;
          _maybeScrollToSelectedUser(selectedUser?.id);

          return pinsSnapshot.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const Center(
              child: Text('PIN registry is not ready right now.'),
            ),
            data: (pins) {
              final userPins = selectedUser == null
                  ? const <UsersDevicesPinRecord>[]
                  : pins.recordsForUser(selectedUser.id);
              final primaryPins = selectedUser == null
                  ? const <UsersDevicesPinRecord>[]
                  : pins.primaryPinsForUser(selectedUser.id);
              final recoveryPins = selectedUser == null
                  ? const <UsersDevicesPinRecord>[]
                  : pins.recoveryPinsForUser(selectedUser.id);
              final revokedPins = selectedUser == null
                  ? const <UsersDevicesPinRecord>[]
                  : pins.revokedPinsForUser(selectedUser.id);
              final primaryPin = selectedUser == null
                  ? null
                  : pins.primaryPinForUser(selectedUser.id);
              final hasSinglePrimary = primaryPins.length == 1;

              return ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    key: _userPinsSectionKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local PINs',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Each user gets their own primary PIN, plus recovery PINs that can be issued or revoked locally when needed.',
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedUser?.id,
                            decoration: const InputDecoration(
                              labelText: 'User',
                            ),
                            items: [
                              for (final user in users.users)
                                DropdownMenuItem<String>(
                                  value: user.id,
                                  child: Text(
                                    '${user.displayName} (${user.role})',
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedUserId = value;
                                _recentRecoveryPin = null;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedUser == null
                                      ? 'Selected user'
                                      : 'Selected user: ${selectedUser.displayName}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedUser == null
                                      ? 'Pick a local user to view their PINs.'
                                      : 'PINs stay tied to this one person and can be revoked or recovered locally.',
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _CardChip(
                                      label: 'Primary: ${primaryPins.length}',
                                    ),
                                    _CardChip(
                                      label: 'Recovery: ${recoveryPins.length}',
                                    ),
                                    _CardChip(
                                      label: 'Revoked: ${revokedPins.length}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.18),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PIN posture',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedUser == null
                                        ? 'Select a user to see their primary and recovery PIN posture.'
                                        : 'A quick local read on the selected user before you change anything.',
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _CardChip(
                                        label: 'Primary: ${primaryPins.length}',
                                      ),
                                      _CardChip(
                                        label:
                                            'Recovery: ${recoveryPins.length}',
                                      ),
                                      _CardChip(
                                        label: 'Revoked: ${revokedPins.length}',
                                      ),
                                      _CardChip(
                                        label: hasSinglePrimary
                                            ? 'Primary state: clear'
                                            : primaryPins.isEmpty
                                            ? 'Primary state: missing'
                                            : 'Primary state: review',
                                      ),
                                      _CardChip(
                                        label: selectedUser == null
                                            ? 'User: none'
                                            : 'User: ${selectedUser.displayName}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unlock guidance',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    selectedUser == null
                                        ? 'Pick a user to review their unlock posture.'
                                        : primaryPin == null
                                        ? 'This user does not have a primary PIN right now. Issue a recovery PIN if they are locked out, then set a fresh primary PIN after they are back in.'
                                        : 'This user has one active primary PIN. Recovery PINs are temporary and should be revoked after use.',
                                  ),
                                  if (primaryPin != null) ...[
                                    const SizedBox(height: 10),
                                    _CardChip(
                                      label:
                                          'Primary label: ${primaryPin.label}',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: selectedUser == null || _busy
                                    ? null
                                    : _setPrimaryPin,
                                icon: const Icon(Icons.pin_outlined),
                                label: const Text('Set primary PIN'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: selectedUser == null || _busy
                                    ? null
                                    : _issueRecoveryPin,
                                icon: const Icon(Icons.vpn_key_outlined),
                                label: const Text('Issue recovery PIN'),
                              ),
                              OutlinedButton.icon(
                                onPressed: selectedUser == null || _busy
                                    ? null
                                    : _revokeUserPins,
                                icon: const Icon(Icons.remove_circle_outline),
                                label: const Text('Revoke all PINs'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    context.push(
                                      SecurityRoutePolicy.securityLockFrom(
                                        GoRouterState.of(context).uri,
                                      ),
                                    ),
                                icon: const Icon(Icons.lock_outline),
                                label: const Text('Open Security Lock'),
                              ),
                            ],
                          ),
                          if (_recentRecoveryPin != null) ...[
                            const SizedBox(height: 12),
                            _PinRevealCard(
                              pinCode: _recentRecoveryPin!,
                              note:
                                  'Share this generated recovery code with the user, then revoke it after use.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User PINs',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          if (userPins.isEmpty)
                            const Text(
                              'No PINs are configured for this user yet.',
                            )
                          else ...[
                            _PinGroupSection(
                              title: 'Primary PINs',
                              subtitle:
                                  'The main PIN used for day-to-day unlocks.',
                              records: primaryPins,
                              context: context,
                              onRevokeRecord: _revokeRecord,
                            ),
                            const SizedBox(height: 12),
                            _PinGroupSection(
                              title: 'Recovery PINs',
                              subtitle:
                                  'Backup codes that should be shared and then revoked after use.',
                              records: recoveryPins,
                              context: context,
                              onRevokeRecord: _revokeRecord,
                            ),
                            const SizedBox(height: 12),
                            _PinGroupSection(
                              title: 'Revoked PINs',
                              subtitle:
                                  'Historical records kept locally for audit visibility.',
                              records: revokedPins,
                              context: context,
                              onRevokeRecord: _revokeRecord,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

String _maskPin(String pinCode) {
  if (pinCode.length <= 2) {
    return pinCode;
  }

  return '${'*' * (pinCode.length - 2)}${pinCode.substring(pinCode.length - 2)}';
}

class _PinRevealCard extends StatelessWidget {
  const _PinRevealCard({required this.pinCode, required this.note});

  final String pinCode;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recovery PIN issued'),
            const SizedBox(height: 6),
            Text(pinCode, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(note),
          ],
        ),
      ),
    );
  }
}

class _PinGroupSection extends StatelessWidget {
  const _PinGroupSection({
    required this.title,
    required this.subtitle,
    required this.records,
    required this.context,
    required this.onRevokeRecord,
  });

  final String title;
  final String subtitle;
  final List<UsersDevicesPinRecord> records;
  final BuildContext context;
  final Future<void> Function(UsersDevicesPinRecord record) onRevokeRecord;

  @override
  Widget build(BuildContext _) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            if (records.isEmpty)
              Text(
                'No records in this section.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              DataTable(
                columns: const [
                  DataColumn(label: Text('Label')),
                  DataColumn(label: Text('PIN')),
                  DataColumn(label: Text('Source')),
                  DataColumn(label: Text('Updated')),
                  DataColumn(label: Text('Action')),
                ],
                rows: [
                  for (final record in records)
                    DataRow(
                      cells: [
                        DataCell(Text(record.label)),
                        DataCell(Text(_maskPin(record.pinCode))),
                        DataCell(Text(record.sourceLabel)),
                        DataCell(
                          Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatShortDate(record.updatedAt),
                          ),
                        ),
                        DataCell(
                          TextButton(
                            onPressed: record.status == 'revoked'
                                ? null
                                : () => onRevokeRecord(record),
                            child: const Text('Revoke'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.32,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Text(label, style: theme.textTheme.labelMedium),
    );
  }
}
