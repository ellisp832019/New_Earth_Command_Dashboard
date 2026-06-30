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

  Future<({String reason, String note})?> _promptAuditDetails({
    required String title,
    required String submitLabel,
    required String reasonLabel,
    String helperText = '',
  }) async {
    final reasonController = TextEditingController();
    final noteController = TextEditingController();

    final result = await showDialog<({String reason, String note})>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: reasonLabel,
                  hintText: 'Short reason for the audit trail',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Operator note',
                  hintText: helperText.isEmpty
                      ? 'Optional extra context'
                      : helperText,
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
                  reason: reasonController.text.trim(),
                  note: noteController.text.trim(),
                ));
              },
              child: Text(submitLabel),
            ),
          ],
        );
      },
    );

    reasonController.dispose();
    noteController.dispose();
    if (result != null && result.reason.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a short reason for the audit trail.'),
        ),
      );
      return null;
    }
    return result;
  }

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

    final snapshot = await ref.read(
      usersDevicesPinRegistrySnapshotProvider.future,
    );
    final existingPins = snapshot.recordsForUser(userId);
    final hasExistingUnlockPath = existingPins.any(
      (pin) => pin.status == 'active' || pin.status == 'recovery',
    );
    if (!mounted) {
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

    final auditDetails = await _promptAuditDetails(
      title: hasExistingUnlockPath
          ? 'Force reset reason'
          : 'Primary PIN reason',
      submitLabel: hasExistingUnlockPath ? 'Force reset' : 'Save',
      reasonLabel: hasExistingUnlockPath
          ? 'Why is the PIN being reset?'
          : 'Why is the PIN being set?',
      helperText:
          'Add any operator note that will help later if this change is reviewed.',
    );
    if (auditDetails == null) {
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
      eventType: hasExistingUnlockPath ? 'pin_reset_forced' : 'pin_set',
      action: hasExistingUnlockPath
          ? 'force_reset_primary_pin'
          : 'set_primary_pin',
      reason: auditDetails.reason,
      note: auditDetails.note,
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

    final auditDetails = await _promptAuditDetails(
      title: 'Issue recovery PIN',
      submitLabel: 'Issue recovery PIN',
      reasonLabel: 'Why is recovery access needed?',
      helperText:
          'Example: primary PIN lost, user locked out, emergency support call.',
    );
    if (auditDetails == null) {
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
      reason: auditDetails.reason,
      note: auditDetails.note,
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

    final auditDetails = await _promptAuditDetails(
      title: 'Revoke all PINs',
      submitLabel: 'Revoke all',
      reasonLabel: 'Why are all PINs being revoked?',
      helperText:
          'Example: user offboarded, compromise suspected, rotate all credentials.',
    );
    if (auditDetails == null) {
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
      reason: auditDetails.reason,
      note: auditDetails.note,
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

  Future<void> _clearUserLockout() async {
    final userId = _selectedUserId;
    if (userId == null || _busy) {
      return;
    }

    final auditDetails = await _promptAuditDetails(
      title: 'Clear lockout timer',
      submitLabel: 'Clear timer',
      reasonLabel: 'Why is the lockout timer being cleared?',
      helperText:
          'Example: identity confirmed by admin, support call completed, or reset drill approved.',
    );
    if (auditDetails == null) {
      return;
    }

    setState(() {
      _busy = true;
    });

    await ref.read(usersDevicesPinRegistryProvider).clearLockoutForUser(userId);
    await _auditPinChange(
      userId: userId,
      eventType: 'pin_lockout_cleared',
      action: 'clear_pin_lockout',
      reason: auditDetails.reason,
      note: auditDetails.note,
    );

    if (mounted) {
      setState(() {
        _busy = false;
      });
      ref.invalidate(usersDevicesPinRegistrySnapshotProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lockout timer cleared for this user.')),
      );
    }
  }

  void _focusUser(String userId) {
    setState(() {
      _selectedUserId = userId;
      _recentRecoveryPin = null;
    });
  }

  Future<void> _revokeRecord(UsersDevicesPinRecord record) async {
    if (_busy) {
      return;
    }

    final auditDetails = await _promptAuditDetails(
      title: 'Revoke ${record.label}',
      submitLabel: 'Revoke PIN',
      reasonLabel: 'Why is this PIN being revoked?',
      helperText:
          'Example: recovery PIN consumed, code exposed, or PIN replaced.',
    );
    if (auditDetails == null) {
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
      reason: auditDetails.reason,
      note: auditDetails.note,
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
    String note = '',
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
          reason: note.isEmpty ? reason : '$reason Note: $note',
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
                            onPressed: () => context.go(
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
              final now = DateTime.now().toUtc();
              final activePinEvents =
                  users.auditLog.where(_isPinAuditEvent).toList(growable: false)
                    ..sort(
                      (left, right) =>
                          right.timestamp.compareTo(left.timestamp),
                    );
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
              final selectedLockout = selectedUser == null
                  ? null
                  : pins.lockoutForUser(selectedUser.id);
              final hasSinglePrimary = primaryPins.length == 1;
              final supportQueue = _buildSupportQueue(users.users, pins, now);
              final staleRecoveryCount = pins.records
                  .where(
                    (record) =>
                        record.status == 'recovery' &&
                        now.difference(record.updatedAt) >=
                            const Duration(hours: 24),
                  )
                  .length;
              final selectedPinEvents = selectedUser == null
                  ? const <UsersDevicesControlAuditEvent>[]
                  : activePinEvents
                        .where((event) => event.actorId == selectedUser.id)
                        .toList(growable: false);
              final recoveryRotationSummary = _buildRecoveryRotationSummary(
                now: now,
                selectedUser: selectedUser,
                recoveryPins: recoveryPins,
                selectedLockout: selectedLockout,
                staleRecoveryCount: staleRecoveryCount,
              );
              final governedResetChecklist = _buildGovernedResetChecklist(
                selectedUser: selectedUser,
                primaryPins: primaryPins,
                recoveryPins: recoveryPins,
                selectedLockout: selectedLockout,
                now: now,
              );
              final lockedOutCount = supportQueue
                  .where((entry) => entry.isLockedOut)
                  .length;
              final missingPrimaryCount = supportQueue
                  .where(
                    (entry) => entry.primaryState == _PrimaryPinState.missing,
                  )
                  .length;
              final recoveryLiveCount = supportQueue
                  .where((entry) => entry.hasRecoveryPin)
                  .length;

              return ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recovery & reset queue',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Surface the users who need PIN help now so operators can move through reset work calmly and in order.',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _CardChip(label: 'Queue: ${supportQueue.length}'),
                              _CardChip(label: 'Locked out: $lockedOutCount'),
                              _CardChip(
                                label: 'Missing primary: $missingPrimaryCount',
                              ),
                              _CardChip(
                                label: 'Recovery live: $recoveryLiveCount',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (supportQueue.isEmpty)
                            const Text(
                              'No users need PIN recovery help right now. Primary and recovery posture looks calm.',
                            )
                          else
                            Column(
                              children: [
                                for (final entry in supportQueue) ...[
                                  _SupportQueueCard(
                                    entry: entry,
                                    isSelected:
                                        selectedUser?.id == entry.user.id,
                                    onFocus: () => _focusUser(entry.user.id),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                                .withValues(alpha: 0.15),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Governed reset checklist',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(governedResetChecklist.summary),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _CardChip(
                                        label: selectedUser == null
                                            ? 'User: none'
                                            : 'User: ${selectedUser.displayName}',
                                      ),
                                      _CardChip(
                                        label: governedResetChecklist
                                            .identityLabel,
                                      ),
                                      _CardChip(
                                        label: governedResetChecklist
                                            .recoveryLabel,
                                      ),
                                      _CardChip(
                                        label:
                                            governedResetChecklist.primaryLabel,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  for (
                                    var i = 0;
                                    i < governedResetChecklist.steps.length;
                                    i++
                                  ) ...[
                                    _ResetChecklistStep(
                                      index: i + 1,
                                      text: governedResetChecklist.steps[i],
                                    ),
                                    if (i !=
                                        governedResetChecklist.steps.length - 1)
                                      const SizedBox(height: 10),
                                  ],
                                ],
                              ),
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
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin reset flow',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    selectedUser == null
                                        ? 'Choose one user, then work through recovery, lockout, and primary reset from this single panel.'
                                        : _resetFlowSummary(
                                            selectedUser: selectedUser,
                                            primaryPins: primaryPins,
                                            recoveryPins: recoveryPins,
                                            lockout: selectedLockout,
                                            now: now,
                                          ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _CardChip(
                                        label: selectedLockout == null
                                            ? 'Lockout: clear'
                                            : selectedLockout.isLockedAt(now)
                                            ? 'Lockout: active'
                                            : 'Lockout: history',
                                      ),
                                      _CardChip(
                                        label: selectedLockout == null
                                            ? 'Failed attempts: 0'
                                            : 'Failed attempts: ${selectedLockout.failedAttempts}',
                                      ),
                                      if (selectedLockout != null &&
                                          selectedLockout.isLockedAt(now) &&
                                          selectedLockout.lockedUntil != null)
                                        _CardChip(
                                          label:
                                              'Cooldown: ${_formatInlineDuration(selectedLockout.lockedUntil!.difference(now))}',
                                        ),
                                      _CardChip(
                                        label: recoveryPins.isEmpty
                                            ? 'Recovery: none'
                                            : 'Recovery: ${recoveryPins.length} live',
                                      ),
                                      _CardChip(
                                        label: primaryPins.isEmpty
                                            ? 'Primary: missing'
                                            : primaryPins.length == 1
                                            ? 'Primary: ready'
                                            : 'Primary: review',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (selectedLockout != null) ...[
                                    Text(
                                      selectedLockout.isLockedAt(now)
                                          ? 'This user is currently in a cooldown window after repeated failed PIN attempts. Clear the timer only after identity has been checked.'
                                          : 'This user has lockout history recorded. Review whether the primary PIN should be rotated or whether recovery access should be revoked.',
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: selectedUser == null || _busy
                                            ? null
                                            : _setPrimaryPin,
                                        icon: const Icon(
                                          Icons.refresh_outlined,
                                        ),
                                        label: Text(
                                          primaryPins.isEmpty
                                              ? 'Set primary PIN'
                                              : 'Force reset primary PIN',
                                        ),
                                      ),
                                      FilledButton.tonalIcon(
                                        onPressed: selectedUser == null || _busy
                                            ? null
                                            : _issueRecoveryPin,
                                        icon: const Icon(
                                          Icons.vpn_key_outlined,
                                        ),
                                        label: const Text('Issue recovery PIN'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed:
                                            selectedUser == null ||
                                                _busy ||
                                                selectedLockout == null
                                            ? null
                                            : _clearUserLockout,
                                        icon: const Icon(
                                          Icons.timer_off_outlined,
                                        ),
                                        label: const Text(
                                          'Clear lockout timer',
                                        ),
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
                                .withValues(alpha: 0.14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recovery rotation guidance',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(recoveryRotationSummary.message),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _CardChip(
                                        label:
                                            'Selected recovery: ${recoveryPins.length}',
                                      ),
                                      _CardChip(
                                        label:
                                            'Queue with recovery: $recoveryLiveCount',
                                      ),
                                      _CardChip(
                                        label:
                                            'Older than 24h: ${recoveryRotationSummary.staleRecoveryCount}',
                                      ),
                                      _CardChip(
                                        label:
                                            'Active lockouts: $lockedOutCount',
                                      ),
                                    ],
                                  ),
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
                                onPressed: () => context.push(
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
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PIN event timeline',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    selectedUser == null
                                        ? 'Choose a user to review their recent PIN, recovery, and lockout events.'
                                        : 'Recent local events for ${selectedUser.displayName} so reset and recovery decisions stay grounded in evidence.',
                                  ),
                                  const SizedBox(height: 12),
                                  if (selectedUser == null)
                                    const Text('No user is selected yet.')
                                  else if (selectedPinEvents.isEmpty)
                                    const Text(
                                      'No PIN-related audit events have been recorded for this user yet.',
                                    )
                                  else
                                    Column(
                                      children: [
                                        for (final event
                                            in selectedPinEvents.take(6)) ...[
                                          _PinAuditEventTile(event: event),
                                          const SizedBox(height: 10),
                                        ],
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
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

bool _isPinAuditEvent(UsersDevicesControlAuditEvent event) {
  return event.eventType.startsWith('pin_') ||
      event.action.contains('pin') ||
      event.action.contains('unlock');
}

({String message, int staleRecoveryCount}) _buildRecoveryRotationSummary({
  required DateTime now,
  required UsersDevicesControlUser? selectedUser,
  required List<UsersDevicesPinRecord> recoveryPins,
  required UsersDevicesPinLockoutState? selectedLockout,
  required int staleRecoveryCount,
}) {
  if (selectedUser == null) {
    return (
      message:
          'Pick a user first to review how recovery PINs and cooldown windows should be handled.',
      staleRecoveryCount: staleRecoveryCount,
    );
  }

  if (selectedLockout != null && selectedLockout.isLockedAt(now)) {
    return (
      message:
          '${selectedUser.displayName} is in an active cooldown window. Use a recovery PIN only after identity has been checked, then rotate back to a fresh primary PIN once support is complete.',
      staleRecoveryCount: staleRecoveryCount,
    );
  }

  if (recoveryPins.isEmpty) {
    return (
      message:
          '${selectedUser.displayName} does not have a live recovery PIN right now. That is the calm default when the primary path is healthy.',
      staleRecoveryCount: staleRecoveryCount,
    );
  }

  final oldestRecovery = recoveryPins
      .map((record) => now.difference(record.updatedAt))
      .reduce((left, right) => left > right ? left : right);
  final oldestLabel = _formatInlineDuration(oldestRecovery);
  return (
    message:
        '${selectedUser.displayName} has ${recoveryPins.length} live recovery PIN${recoveryPins.length == 1 ? '' : 's'}. Revoke recovery access after use, and rotate the user back to one clean primary PIN. Oldest live recovery age: $oldestLabel.',
    staleRecoveryCount: staleRecoveryCount,
  );
}

class _GovernedResetChecklist {
  const _GovernedResetChecklist({
    required this.summary,
    required this.identityLabel,
    required this.recoveryLabel,
    required this.primaryLabel,
    required this.steps,
  });

  final String summary;
  final String identityLabel;
  final String recoveryLabel;
  final String primaryLabel;
  final List<String> steps;
}

_GovernedResetChecklist _buildGovernedResetChecklist({
  required UsersDevicesControlUser? selectedUser,
  required List<UsersDevicesPinRecord> primaryPins,
  required List<UsersDevicesPinRecord> recoveryPins,
  required UsersDevicesPinLockoutState? selectedLockout,
  required DateTime now,
}) {
  if (selectedUser == null) {
    return const _GovernedResetChecklist(
      summary:
          'Choose one user first so recovery issuance, lockout clearance, and forced reset all stay tied to the same identity.',
      identityLabel: 'Identity: choose user',
      recoveryLabel: 'Recovery: pending',
      primaryLabel: 'Primary: pending',
      steps: [
        'Select the local user who needs support.',
        'Review whether they are missing a primary PIN, carrying a live recovery PIN, or sitting inside a cooldown window.',
        'Only then decide whether to set a primary PIN, issue recovery access, or clear a lockout timer.',
      ],
    );
  }

  final isLockedOut = selectedLockout?.isLockedAt(now) ?? false;
  final primaryState = primaryPins.isEmpty
      ? 'Primary: missing'
      : primaryPins.length == 1
      ? 'Primary: ready'
      : 'Primary: review';
  final recoveryState = recoveryPins.isEmpty
      ? 'Recovery: none live'
      : 'Recovery: ${recoveryPins.length} live';
  final identityState = isLockedOut
      ? 'Identity: verify before clear'
      : 'Identity: operator confirmed';

  if (isLockedOut) {
    return _GovernedResetChecklist(
      summary:
          '${selectedUser.displayName} is in an active cooldown window. Treat this as support work: verify identity, decide whether a temporary recovery path is justified, and only clear the timer when you can explain why.',
      identityLabel: identityState,
      recoveryLabel: recoveryState,
      primaryLabel: primaryState,
      steps: [
        'Verify the person and confirm you are working on ${selectedUser.displayName}.',
        'Capture a reason before clearing the timer or issuing a recovery PIN.',
        'If urgent access is needed, issue one fresh recovery PIN and share it through a safe local path.',
        'After the user is back in, set or confirm one clean primary PIN.',
        'Revoke the recovery PIN and review the PIN event timeline so the support path is complete.',
      ],
    );
  }

  if (primaryPins.isEmpty && recoveryPins.isNotEmpty) {
    return _GovernedResetChecklist(
      summary:
          '${selectedUser.displayName} is missing a day-to-day primary PIN but still has recovery access available. Use that as the temporary bridge, then rotate back to one stable primary PIN.',
      identityLabel: identityState,
      recoveryLabel: recoveryState,
      primaryLabel: primaryState,
      steps: [
        'Confirm ${selectedUser.displayName} really needs recovery access instead of a normal unlock.',
        'Use the live recovery PIN, or issue a fresh one if the current path is stale or uncertain.',
        'Once access is restored, force reset a new primary PIN with a clear admin reason.',
        'Retire the temporary recovery path so only the new primary PIN remains active.',
        'Check the audit timeline to confirm issue, reset, and revoke events all landed locally.',
      ],
    );
  }

  if (primaryPins.isEmpty) {
    return _GovernedResetChecklist(
      summary:
          '${selectedUser.displayName} does not have an active primary PIN right now. This is a setup or recovery gap, so the next safe step is to create the normal unlock path first.',
      identityLabel: identityState,
      recoveryLabel: recoveryState,
      primaryLabel: primaryState,
      steps: [
        'Confirm the selected user is correct and that the missing primary PIN is expected.',
        'Set a new primary PIN if the user can resume normally.',
        'If support needs a temporary path first, issue one recovery PIN and then come back to set the primary PIN.',
        'Test the result through Security Lock using the same user and trusted device.',
        'Review the event timeline so the new setup or recovery path is recorded cleanly.',
      ],
    );
  }

  if (recoveryPins.isNotEmpty) {
    return _GovernedResetChecklist(
      summary:
          '${selectedUser.displayName} already has a normal unlock path, but a recovery PIN is still live. That means the support loop is not fully closed yet.',
      identityLabel: identityState,
      recoveryLabel: recoveryState,
      primaryLabel: primaryState,
      steps: [
        'Confirm the primary PIN is working before touching recovery access.',
        'If the primary path is healthy, revoke the live recovery PIN.',
        'If the primary path is not healthy, reset the primary PIN first and only keep recovery access for the shortest useful time.',
        'Test unlock once, then remove the temporary recovery path.',
        'Use the event timeline to confirm the revoke or reset sequence is complete.',
      ],
    );
  }

  return _GovernedResetChecklist(
    summary:
        '${selectedUser.displayName} already has a clean local unlock path. Any reset from here should be a deliberate admin action, not a routine habit.',
    identityLabel: identityState,
    recoveryLabel: recoveryState,
    primaryLabel: primaryState,
    steps: [
      'Use force reset only when the user has genuinely lost the PIN or a rotation is required.',
      'Capture the admin reason before changing the primary PIN.',
      'Test the new primary PIN through Security Lock.',
      'Keep recovery access off unless a real support path is needed.',
      'Review the timeline afterwards so the reset remains auditable.',
    ],
  );
}

enum _PrimaryPinState { missing, ready, review }

class _PinSupportQueueEntry {
  const _PinSupportQueueEntry({
    required this.user,
    required this.primaryCount,
    required this.recoveryCount,
    required this.primaryState,
    required this.isLockedOut,
    required this.summary,
  });

  final UsersDevicesControlUser user;
  final int primaryCount;
  final int recoveryCount;
  final _PrimaryPinState primaryState;
  final bool isLockedOut;
  final String summary;

  bool get hasRecoveryPin => recoveryCount > 0;
}

List<_PinSupportQueueEntry> _buildSupportQueue(
  List<UsersDevicesControlUser> users,
  UsersDevicesPinRegistrySnapshot pins,
  DateTime now,
) {
  final entries = <_PinSupportQueueEntry>[];

  for (final user in users) {
    final primaryPins = pins.primaryPinsForUser(user.id);
    final recoveryPins = pins.recoveryPinsForUser(user.id);
    final lockout = pins.lockoutForUser(user.id);
    final isLockedOut = lockout?.isLockedAt(now) ?? false;
    final primaryState = primaryPins.isEmpty
        ? _PrimaryPinState.missing
        : primaryPins.length == 1
        ? _PrimaryPinState.ready
        : _PrimaryPinState.review;

    if (!isLockedOut &&
        primaryState == _PrimaryPinState.ready &&
        recoveryPins.isEmpty) {
      continue;
    }

    final summary = <String>[
      if (isLockedOut)
        'Locked for ${_formatInlineDuration(lockout!.lockedUntil!.difference(now))}',
      if (primaryState == _PrimaryPinState.missing) 'Primary PIN missing',
      if (primaryState == _PrimaryPinState.review)
        'Primary PIN history needs review',
      if (recoveryPins.isNotEmpty) 'Recovery PIN live',
    ].join(' - ');

    entries.add(
      _PinSupportQueueEntry(
        user: user,
        primaryCount: primaryPins.length,
        recoveryCount: recoveryPins.length,
        primaryState: primaryState,
        isLockedOut: isLockedOut,
        summary: summary,
      ),
    );
  }

  entries.sort((left, right) {
    final leftScore =
        (left.isLockedOut ? 4 : 0) +
        (left.primaryState == _PrimaryPinState.missing ? 2 : 0) +
        (left.hasRecoveryPin ? 1 : 0);
    final rightScore =
        (right.isLockedOut ? 4 : 0) +
        (right.primaryState == _PrimaryPinState.missing ? 2 : 0) +
        (right.hasRecoveryPin ? 1 : 0);
    return rightScore.compareTo(leftScore);
  });
  return entries;
}

String _resetFlowSummary({
  required UsersDevicesControlUser selectedUser,
  required List<UsersDevicesPinRecord> primaryPins,
  required List<UsersDevicesPinRecord> recoveryPins,
  required UsersDevicesPinLockoutState? lockout,
  required DateTime now,
}) {
  if (lockout != null && lockout.isLockedAt(now)) {
    return '${selectedUser.displayName} is currently locked out. Clear the timer only after identity has been confirmed, or issue a recovery PIN if support needs a temporary path back in.';
  }

  if (primaryPins.isEmpty && recoveryPins.isNotEmpty) {
    return '${selectedUser.displayName} has no active primary PIN but does have a live recovery code. Use the recovery path to regain entry, then force reset a fresh primary PIN.';
  }

  if (primaryPins.isEmpty) {
    return '${selectedUser.displayName} has no active primary PIN. Set a new primary PIN, or issue a recovery PIN first if they need help getting back in right now.';
  }

  if (recoveryPins.isNotEmpty) {
    return '${selectedUser.displayName} still has a live recovery PIN. Rotate them back to a clean primary PIN and revoke recovery codes after support is complete.';
  }

  return '${selectedUser.displayName} has a normal unlock path. Use force reset only if the user has lost their PIN, support has verified identity, or a rotation is required.';
}

String _formatInlineDuration(Duration duration) {
  if (duration.isNegative || duration.inSeconds <= 0) {
    return '0s';
  }

  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  if (minutes > 0) {
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
  return '${duration.inSeconds}s';
}

class _SupportQueueCard extends StatelessWidget {
  const _SupportQueueCard({
    required this.entry,
    required this.isSelected,
    required this.onFocus,
  });

  final _PinSupportQueueEntry entry;
  final bool isSelected;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.28)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${entry.user.displayName} (${entry.user.role})',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (isSelected) const _CardChip(label: 'Selected'),
              ],
            ),
            const SizedBox(height: 6),
            Text(entry.summary),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CardChip(label: 'Primary: ${entry.primaryCount}'),
                _CardChip(label: 'Recovery: ${entry.recoveryCount}'),
                _CardChip(
                  label: entry.isLockedOut ? 'Lockout active' : 'Needs review',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onFocus,
                icon: const Icon(Icons.center_focus_strong_outlined),
                label: const Text('Focus user'),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _ResetChecklistStep extends StatelessWidget {
  const _ResetChecklistStep({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('$index', style: theme.textTheme.labelMedium),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

class _PinAuditEventTile extends StatelessWidget {
  const _PinAuditEventTile({required this.event});

  final UsersDevicesControlAuditEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toneColor = switch (event.result.toLowerCase()) {
      'allowed' => const Color(0xFF7EE6C5),
      'approved' => const Color(0xFF7EE6C5),
      'denied' => theme.colorScheme.errorContainer,
      _ => theme.colorScheme.surfaceContainerHighest,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CardChip(label: event.eventType),
              _CardChip(label: event.result),
              _CardChip(label: event.action),
            ],
          ),
          const SizedBox(height: 8),
          Text(event.reason, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            event.timestamp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
