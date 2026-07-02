// ignore_for_file: use_build_context_synchronously

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/local_pdf_screen.dart';
import '../../../core/routing/route_names.dart';
import '../application/users_devices_control_controller.dart';
import '../application/users_devices_pin_registry_controller.dart';
import '../data/users_devices_control_repository.dart';
import '../data/users_devices_control_report_service.dart';
import '../data/users_devices_pin_registry_service.dart';
import '../../security/application/security_session_controller.dart';

const _usersDevicesOnboardingPackPdfPath =
    'output/pdf/users_devices_onboarding_pack.pdf';
const _usersDevicesRecoveryDrillsPackPdfPath =
    'output/pdf/users_devices_recovery_drills_pack.pdf';

class UsersDevicesControlScreen extends ConsumerWidget {
  const UsersDevicesControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    final securitySession = ref.watch(securitySessionProvider);
    final isSessionLocked =
        !securitySession.isUnlocked || securitySession.isExpired;

    return _UsersDevicesPageScaffold(
      title: 'Users & Devices Control',
      subtitle: 'Local identity, trust, approvals, and audit trail',
      onBack: () => context.go(RouteNames.moduleHub),
      child: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          message:
              'Users & Devices Control could not load its local registry right now.',
          onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
        ),
        data: (data) {
          final pins = ref
              .watch(usersDevicesPinRegistrySnapshotProvider)
              .maybeWhen(
                data: (snapshot) => snapshot,
                orElse: () => UsersDevicesPinRegistrySnapshot(
                  records: const <UsersDevicesPinRecord>[],
                ),
              );
          final pending = data.approvalQueue
              .where((request) => request.isPending)
              .length;
          final trustedDevices = data.devices
              .where((device) => device.trustLevel >= 3)
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroPanel(
                data: data,
                pendingRequests: pending,
                trustedDevices: trustedDevices,
              ),
              const SizedBox(height: 16),
              _AccessReviewDashboardPanel(data: data, pins: pins),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Access plan',
                subtitle:
                    'Identity, trust, permission, approval, and audit stay in view.',
                icon: Icons.route_outlined,
                compact: true,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: const [
                    _CardChip(label: 'Identity'),
                    _CardChip(label: 'Device trust'),
                    _CardChip(label: 'Permission'),
                    _CardChip(label: 'Approval'),
                    _CardChip(label: 'Audit'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ActionStrip(
                title: 'Try it now',
                subtitle: 'Seed a sample user, device, or approval.',
                actions: [
                  _ActionChip(
                    label: 'Register user',
                    icon: Icons.person_add_alt_1_outlined,
                    onPressed: () => _registerSampleUser(context, ref),
                  ),
                  _ActionChip(
                    label: 'Register device',
                    icon: Icons.devices_outlined,
                    onPressed: () => _registerSampleDevice(context, ref),
                  ),
                  _ActionChip(
                    label: 'Create approval',
                    icon: Icons.rule_folder_outlined,
                    onPressed: () => _createSampleApproval(context, ref),
                  ),
                  _ActionChip(
                    label: 'Open queue',
                    icon: Icons.open_in_new_outlined,
                    onPressed: () =>
                        context.go(RouteNames.usersDevicesApprovalQueue),
                  ),
                  _ActionChip(
                    label: 'Manage PINs',
                    icon: Icons.pin_outlined,
                    onPressed: isSessionLocked
                        ? null
                        : () => context.go(RouteNames.usersDevicesPins),
                  ),
                  _ActionChip(
                    label: 'Migration health',
                    icon: Icons.storage_outlined,
                    onPressed: () =>
                        context.go(RouteNames.usersDevicesMigrationHealth),
                  ),
                  _ActionChip(
                    label: 'Onboarding pack PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: () => openLocalPdfDocument(
                      context,
                      title: 'Users & Devices Onboarding Pack PDF',
                      pdfPath: _usersDevicesOnboardingPackPdfPath,
                    ),
                  ),
                  _ActionChip(
                    label: 'Recovery drills PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: () => openLocalPdfDocument(
                      context,
                      title: 'Users & Devices Recovery Drills PDF',
                      pdfPath: _usersDevicesRecoveryDrillsPackPdfPath,
                    ),
                  ),
                  _ActionChip(
                    label: 'Seed demo path',
                    icon: Icons.playlist_add_check_outlined,
                    onPressed: () => _seedDemoPath(context, ref),
                  ),
                  _ActionChip(
                    label: 'Reset demo data',
                    icon: Icons.restart_alt_outlined,
                    onPressed: () => _confirmResetDemoData(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NavigationGrid(
                tiles: [
                  _NavTile(
                    title: 'Users',
                    subtitle: '${data.users.length} local identities',
                    icon: Icons.people_outline,
                    route: RouteNames.usersDevicesUsers,
                  ),
                  _NavTile(
                    title: 'Devices',
                    subtitle: '${data.devices.length} trusted endpoints',
                    icon: Icons.devices_outlined,
                    route: RouteNames.usersDevicesDevices,
                  ),
                  _NavTile(
                    title: 'Access Matrix',
                    subtitle: '${data.accessRules.length} module rules',
                    icon: Icons.grid_view_outlined,
                    route: RouteNames.usersDevicesAccessMatrix,
                  ),
                  _NavTile(
                    title: 'Onboarding',
                    subtitle: 'Pair and trust new devices',
                    icon: Icons.phonelink_setup_outlined,
                    route: RouteNames.usersDevicesDeviceOnboarding,
                  ),
                  _NavTile(
                    title: 'Onboarding Report',
                    subtitle: 'Readiness, print summary, and admin view',
                    icon: Icons.assignment_outlined,
                    route: RouteNames.usersDevicesOnboardingReport,
                  ),
                  _NavTile(
                    title: 'Approval Queue',
                    subtitle:
                        '$pending request${pending == 1 ? '' : 's'} pending',
                    icon: Icons.rule_folder_outlined,
                    route: RouteNames.usersDevicesApprovalQueue,
                  ),
                  _NavTile(
                    title: 'Audit Log',
                    subtitle: '${data.auditLog.length} recorded events',
                    icon: Icons.receipt_long_outlined,
                    route: RouteNames.usersDevicesAuditLog,
                  ),
                  _NavTile(
                    title: 'PIN Registry',
                    subtitle: isSessionLocked
                        ? 'Unlock session first'
                        : 'Set or recover local PINs',
                    icon: Icons.pin_outlined,
                    route: isSessionLocked ? null : RouteNames.usersDevicesPins,
                  ),
                  _NavTile(
                    title: 'Migration Health',
                    subtitle: 'SQLite, seed, and support posture',
                    icon: Icons.storage_outlined,
                    route: RouteNames.usersDevicesMigrationHealth,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StaticRulePanel(data: data),
            ],
          );
        },
      ),
    );
  }
}

class UsersDevicesUsersScreen extends ConsumerStatefulWidget {
  const UsersDevicesUsersScreen({super.key});

  @override
  ConsumerState<UsersDevicesUsersScreen> createState() =>
      _UsersDevicesUsersScreenState();
}

class _UsersDevicesUsersScreenState
    extends ConsumerState<UsersDevicesUsersScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    final securitySession = ref.watch(securitySessionProvider);
    final isSessionLocked =
        !securitySession.isUnlocked || securitySession.isExpired;
    final pinsSnapshot = ref.watch(usersDevicesPinRegistrySnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Users'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Users',
        message: 'The users registry is not ready right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) {
        final pins = pinsSnapshot.maybeWhen(
          data: (snapshot) => snapshot,
          orElse: () => UsersDevicesPinRegistrySnapshot(
            records: const <UsersDevicesPinRecord>[],
          ),
        );
        final filteredUsers = data.users
            .where((user) {
              if (_statusFilter != 'all' && user.status != _statusFilter) {
                return false;
              }
              final query = _searchQuery.trim().toLowerCase();
              if (query.isEmpty) {
                return true;
              }

              final haystack = [
                user.id,
                user.displayName,
                user.role,
                user.title,
                user.status,
                user.notes,
                ...user.permissions,
                ...user.linkedDevices,
              ].join(' ').toLowerCase();
              return haystack.contains(query);
            })
            .toList(growable: false);

        return _SectionScaffold(
          title: 'Users',
          subtitle: 'People, collaborators, guests, and AI identities',
          onBack: () => context.go(RouteNames.usersDevices),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionStrip(
                title: 'User actions',
                subtitle:
                    'Add or update a local identity and write the audit trail immediately.',
                actions: [
                  _ActionChip(
                    label: 'Add user',
                    icon: Icons.person_add_alt_1_outlined,
                    onPressed: () => _openUserEditor(context, ref),
                  ),
                  _ActionChip(
                    label: 'Seed sample user',
                    icon: Icons.auto_fix_high_outlined,
                    onPressed: () => _registerSampleUser(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SummaryRow(
                items: [
                  (
                    'Active',
                    data.users.where((user) => user.status == 'active').length,
                  ),
                  (
                    'Templates',
                    data.users
                        .where((user) => user.status == 'template')
                        .length,
                  ),
                  (
                    'With devices',
                    data.users
                        .where((user) => user.linkedDevices.isNotEmpty)
                        .length,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SearchFilterPanel(
                title: 'Search users',
                subtitle:
                    'Filter by name, role, notes, permissions, device links, or status.',
                query: _searchQuery,
                onQueryChanged: (value) => setState(() => _searchQuery = value),
                chips: [
                  _SoftChoiceChip(
                    label: const Text('All'),
                    selected: _statusFilter == 'all',
                    onSelected: (_) => setState(() => _statusFilter = 'all'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Active'),
                    selected: _statusFilter == 'active',
                    onSelected: (_) => setState(() => _statusFilter = 'active'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Templates'),
                    selected: _statusFilter == 'template',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'template'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Archived'),
                    selected: _statusFilter == 'archived',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'archived'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filteredUsers.isEmpty)
                _EmptyCollectionState(
                  icon: Icons.person_off_outlined,
                  title: 'No users matched the current filters',
                  body:
                      'Try a broader search term or switch the status filter back to All.',
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final user in filteredUsers)
                      SizedBox(
                        width: 360,
                        child: Builder(
                          builder: (context) {
                            final userPins = pins.recordsForUser(user.id);
                            final primaryPins = userPins
                                .where((pin) => pin.status == 'active')
                                .length;
                            final recoveryPins = userPins
                                .where((pin) => pin.status == 'recovery')
                                .length;

                            return _EntityCard(
                              icon: Icons.person_outline,
                              title: user.displayName,
                              subtitle:
                                  '${user.role}${user.title.isNotEmpty ? ' - ${user.title}' : ''}',
                              body:
                                  '${user.permissions.length} permissions - ${user.linkedDevices.length} linked devices',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(label: Text(user.status)),
                                  const SizedBox(width: 8),
                                  _EntityActionsMenu(
                                    isArchived: user.status == 'archived',
                                    onEdit: () => _openUserEditor(
                                      context,
                                      ref,
                                      user: user,
                                    ),
                                    onArchiveToggle: () =>
                                        _toggleUserArchive(context, ref, user),
                                    onDelete: () =>
                                        _confirmDeleteUser(context, ref, user),
                                  ),
                                ],
                              ),
                              chips: [
                                _CardChip(label: user.role),
                                if (user.permissions.isNotEmpty)
                                  _CardChip(label: user.permissions.first),
                                if (primaryPins > 0)
                                  _CardChip(label: 'Primary PIN $primaryPins'),
                                if (recoveryPins > 0)
                                  _CardChip(
                                    label: 'Recovery PIN $recoveryPins',
                                  ),
                                for (final pinSummary in _pinSummaries(
                                  userPins,
                                ))
                                  _CardChip(
                                    label: pinSummary,
                                    onTap: () =>
                                        _openUserPinsRegistry(context, user.id),
                                  ),
                                if (userPins.isEmpty)
                                  _CardChip(
                                    label: 'No PIN set',
                                    onTap: () =>
                                        _openUserPinsRegistry(context, user.id),
                                  ),
                              ],
                              actions: [
                                OutlinedButton.icon(
                                  onPressed: isSessionLocked
                                      ? null
                                      : () =>
                                            _assignUserPin(context, ref, user),
                                  icon: const Icon(Icons.pin_outlined),
                                  label: Text(
                                    isSessionLocked
                                        ? 'PINs locked'
                                        : 'Assign PIN',
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: isSessionLocked
                                      ? null
                                      : () => _assignUserPin(
                                          context,
                                          ref,
                                          user,
                                          initialRecoveryMode: true,
                                        ),
                                  icon: const Icon(Icons.vpn_key_outlined),
                                  label: Text(
                                    isSessionLocked
                                        ? 'PINs locked'
                                        : 'Recovery PIN',
                                  ),
                                ),
                                FilledButton.tonal(
                                  onPressed: () =>
                                      _openUserEditor(context, ref, user: user),
                                  child: const Text('Edit'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: userPins.isEmpty
                                      ? null
                                      : () => _copyUserPinSummary(
                                          context,
                                          user.displayName,
                                          userPins,
                                        ),
                                  icon: const Icon(Icons.copy_outlined),
                                  label: const Text('Copy PIN summary'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _openUserPinsRegistry(context, user.id),
                                  icon: const Icon(Icons.pin_end_outlined),
                                  label: const Text('Open PIN Registry'),
                                ),
                                OutlinedButton(
                                  onPressed: () =>
                                      _toggleUserArchive(context, ref, user),
                                  child: Text(
                                    user.status == 'archived'
                                        ? 'Restore'
                                        : 'Archive',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class UsersDevicesDevicesScreen extends ConsumerStatefulWidget {
  const UsersDevicesDevicesScreen({super.key});

  @override
  ConsumerState<UsersDevicesDevicesScreen> createState() =>
      _UsersDevicesDevicesScreenState();
}

class _UsersDevicesDevicesScreenState
    extends ConsumerState<UsersDevicesDevicesScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String? _focusedReviewDeviceId;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Devices'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Devices',
        message: 'The device registry is not ready right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) {
        final ownerLabels = {
          for (final user in data.users) user.id: user.displayName,
        };
        final quarantinedDevices = data.devices
            .where((device) => device.status == 'quarantined')
            .toList(growable: false);
        final reviewDevices = data.devices
            .where((device) => device.needsOnboardingReview)
            .toList(growable: false);
        reviewDevices.sort(_compareDeviceReviewPriority);
        final focusedReviewDevice = reviewDevices.isEmpty
            ? null
            : reviewDevices.firstWhere(
                (device) => device.id == _focusedReviewDeviceId,
                orElse: () => reviewDevices.first,
              );
        final filteredDevices = data.devices
            .where((device) {
              if (_statusFilter != 'all' && device.status != _statusFilter) {
                return false;
              }
              final query = _searchQuery.trim().toLowerCase();
              if (query.isEmpty) {
                return true;
              }

              final haystack = [
                device.id,
                device.name,
                device.type,
                device.status,
                device.ownerId,
                device.notes,
                device.trustSource,
                device.trustReviewedBy,
                device.trustReviewedAt ?? '',
                device.lastSeenAt ?? '',
                device.operatorNote,
                device.quarantineReason,
                device.trustLevel.toString(),
                ...device.allowedActions,
              ].join(' ').toLowerCase();
              return haystack.contains(query);
            })
            .toList(growable: false);

        return _SectionScaffold(
          title: 'Devices',
          subtitle: 'Local PCs, assistants, printers, sensors, and gateways',
          onBack: () => context.go(RouteNames.usersDevices),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionStrip(
                title: 'Device actions',
                subtitle:
                    'Add or update a local device and keep the trust trail local.',
                actions: [
                  _ActionChip(
                    label: 'Add device',
                    icon: Icons.devices_outlined,
                    onPressed: () => _openDeviceEditor(context, ref),
                  ),
                  _ActionChip(
                    label: 'Open onboarding',
                    icon: Icons.phonelink_setup_outlined,
                    onPressed: () =>
                        context.go(RouteNames.usersDevicesDeviceOnboarding),
                  ),
                  _ActionChip(
                    label: 'Seed sample device',
                    icon: Icons.auto_fix_high_outlined,
                    onPressed: () => _registerSampleDevice(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SummaryRow(
                items: [
                  (
                    'Trusted',
                    data.devices.where((device) => device.isTrusted).length,
                  ),
                  ('Quarantined', quarantinedDevices.length),
                  (
                    'Owned',
                    data.devices
                        .where((device) => device.ownerId.isNotEmpty)
                        .length,
                  ),
                  (
                    'Needs review',
                    data.devices
                        .where((device) => device.needsOnboardingReview)
                        .length,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Trust posture',
                subtitle:
                    'Read this first when you are deciding whether a device is ready for gated modules.',
                icon: Icons.verified_outlined,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _CardChip(
                      label:
                          'Registered = recorded locally but not ready for sensitive routes',
                    ),
                    _CardChip(
                      label: 'Trusted = ready for normal gated module access',
                    ),
                    _CardChip(
                      label: 'High trust = suitable for stricter trust floors',
                    ),
                    _CardChip(
                      label: 'Blocked = restore or re-onboard before use',
                    ),
                    _CardChip(
                      label:
                          'Quarantined = hold access until the device is reviewed and restored',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Trust evidence queue',
                subtitle:
                    'Use this to see which devices still need operator review and which ones are paused in quarantine.',
                icon: Icons.health_and_safety_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.pause_circle_outline,
                            title: 'Quarantined devices',
                            subtitle:
                                '${quarantinedDevices.length} device${quarantinedDevices.length == 1 ? '' : 's'} paused',
                            body: quarantinedDevices.isEmpty
                                ? 'No local devices are currently quarantined.'
                                : quarantinedDevices
                                      .take(3)
                                      .map((device) => device.name)
                                      .join(', '),
                            chips: [
                              _CardChip(
                                label: '${quarantinedDevices.length} paused',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.fact_check_outlined,
                            title: 'Review queue',
                            subtitle:
                                '${reviewDevices.length} device${reviewDevices.length == 1 ? '' : 's'} still need attention',
                            body: reviewDevices.isEmpty
                                ? 'The device list currently has local trust coverage.'
                                : 'Focus first on registered, blocked, or quarantined devices before raising trust.',
                            chips: [
                              _CardChip(
                                label: '${reviewDevices.length} in review',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (quarantinedDevices.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Quarantine watchlist',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final device in quarantinedDevices.take(3))
                            SizedBox(
                              width: 320,
                              child: _EntityCard(
                                icon: Icons.shield_moon_outlined,
                                title: device.name,
                                subtitle: device.type,
                                body: device.trustEvidenceSummary,
                                chips: [
                                  const _CardChip(label: 'Quarantined'),
                                  _CardChip(label: 'T${device.trustLevel}'),
                                ],
                                actions: [
                                  if (device.needsOnboardingReview)
                                    FilledButton.tonal(
                                      onPressed: () => setState(
                                        () =>
                                            _focusedReviewDeviceId = device.id,
                                      ),
                                      child: const Text('Focus device'),
                                    ),
                                  OutlinedButton.icon(
                                    onPressed: () => _openDeviceEditor(
                                      context,
                                      ref,
                                      device: device,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Review device'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Trust decision checklist',
                subtitle:
                    'Use one focused device at a time so quarantine, restore, and trust changes stay deliberate.',
                icon: Icons.rule_folder_outlined,
                child: focusedReviewDevice == null
                    ? const _EmptyCollectionState(
                        icon: Icons.verified_user_outlined,
                        title: 'No device trust follow-up is waiting',
                        body:
                            'Every active local device already has enough posture for the current trust scope.',
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _CardChip(label: focusedReviewDevice.name),
                              _CardChip(
                                label:
                                    'Owner: ${ownerLabels[focusedReviewDevice.ownerId] ?? focusedReviewDevice.ownerId}',
                              ),
                              _CardChip(
                                label:
                                    'Trust ${focusedReviewDevice.trustLevel}',
                              ),
                              _CardChip(
                                label: 'Status: ${focusedReviewDevice.status}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _buildDeviceTrustChecklistSummary(
                              focusedReviewDevice,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _StepCard(
                            step: '1',
                            title: 'Read the evidence first',
                            body: focusedReviewDevice.trustEvidenceSummary,
                          ),
                          const SizedBox(height: 12),
                          _StepCard(
                            step: '2',
                            title: 'Choose the posture',
                            body: focusedReviewDevice.isQuarantined
                                ? 'Keep the device quarantined until the reason is resolved, or restore it only after the endpoint is safe again.'
                                : focusedReviewDevice.status == 'blocked'
                                ? 'Restore or re-onboard the device before expecting it to satisfy local access checks.'
                                : 'Either raise trust with a clear reason, or keep the device in review until the evidence is stronger.',
                          ),
                          const SizedBox(height: 12),
                          const _StepCard(
                            step: '3',
                            title: 'Write the outcome',
                            body:
                                'Use Review device, Quarantine, Restore trust, or Onboarding, then confirm the audit trail reflects the decision.',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.tonal(
                                onPressed: () => _openDeviceEditor(
                                  context,
                                  ref,
                                  device: focusedReviewDevice,
                                ),
                                child: const Text('Review device'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _toggleDeviceQuarantine(
                                  context,
                                  ref,
                                  focusedReviewDevice,
                                ),
                                icon: Icon(
                                  focusedReviewDevice.isQuarantined
                                      ? Icons.verified_user_outlined
                                      : Icons.pause_circle_outline,
                                ),
                                label: Text(
                                  focusedReviewDevice.isQuarantined
                                      ? 'Restore trust'
                                      : 'Quarantine',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => context.go(
                                  RouteNames.usersDevicesDeviceOnboarding,
                                ),
                                icon: const Icon(
                                  Icons.phonelink_setup_outlined,
                                ),
                                label: const Text('Open onboarding'),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              _SearchFilterPanel(
                title: 'Search devices',
                subtitle:
                    'Filter by name, type, owner, action scope, notes, trust level, or status.',
                query: _searchQuery,
                onQueryChanged: (value) => setState(() => _searchQuery = value),
                chips: [
                  _SoftChoiceChip(
                    label: const Text('All'),
                    selected: _statusFilter == 'all',
                    onSelected: (_) => setState(() => _statusFilter = 'all'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Registered'),
                    selected: _statusFilter == 'registered',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'registered'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Trusted'),
                    selected: _statusFilter == 'trusted',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'trusted'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Critical'),
                    selected: _statusFilter == 'critical',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'critical'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Blocked'),
                    selected: _statusFilter == 'blocked',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'blocked'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Quarantined'),
                    selected: _statusFilter == 'quarantined',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'quarantined'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Archived'),
                    selected: _statusFilter == 'archived',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'archived'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filteredDevices.isEmpty)
                _EmptyCollectionState(
                  icon: Icons.devices_other_outlined,
                  title: 'No devices matched the current filters',
                  body:
                      'Try a broader search term or switch the status filter back to All.',
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final device in filteredDevices)
                      SizedBox(
                        width: 360,
                        child: _EntityCard(
                          icon: Icons.devices_outlined,
                          title: device.name,
                          subtitle: device.type,
                          body:
                              '${device.trustPostureSummary}\nTrust T${device.trustLevel} - ${device.allowedActions.length} allowed action${device.allowedActions.length == 1 ? '' : 's'}\n${device.trustEvidenceSummary}',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(label: Text(device.status)),
                              const SizedBox(width: 8),
                              _EntityActionsMenu(
                                isArchived: device.status == 'archived',
                                onEdit: () => _openDeviceEditor(
                                  context,
                                  ref,
                                  device: device,
                                ),
                                onArchiveToggle: () =>
                                    _toggleDeviceArchive(context, ref, device),
                                onDelete: () =>
                                    _confirmDeleteDevice(context, ref, device),
                              ),
                            ],
                          ),
                          chips: [
                            _CardChip(label: 'T${device.trustLevel}'),
                            _CardChip(label: device.trustPostureLabel),
                            if (device.ownerId.isNotEmpty)
                              _CardChip(
                                label:
                                    'Owner: ${ownerLabels[device.ownerId] ?? device.ownerId}',
                              ),
                            if (device.trustSource.trim().isNotEmpty)
                              _CardChip(label: 'Source: ${device.trustSource}'),
                            if (device.lastSeenAt != null &&
                                device.lastSeenAt!.trim().isNotEmpty)
                              _CardChip(label: 'Seen ${device.lastSeenAt!}'),
                            if (device.needsOnboardingReview)
                              const _CardChip(label: 'Review onboarding'),
                          ],
                          actions: [
                            if (device.needsOnboardingReview)
                              FilledButton.tonal(
                                onPressed: () => setState(
                                  () => _focusedReviewDeviceId = device.id,
                                ),
                                child: const Text('Focus device'),
                              ),
                            FilledButton.tonal(
                              onPressed: () => _openDeviceEditor(
                                context,
                                ref,
                                device: device,
                              ),
                              child: const Text('Edit'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _toggleDeviceQuarantine(context, ref, device),
                              icon: Icon(
                                device.isQuarantined
                                    ? Icons.verified_user_outlined
                                    : Icons.pause_circle_outline,
                              ),
                              label: Text(
                                device.isQuarantined
                                    ? 'Restore trust'
                                    : 'Quarantine',
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  _toggleDeviceArchive(context, ref, device),
                              child: Text(
                                device.status == 'archived'
                                    ? 'Restore'
                                    : 'Archive',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context.go(
                                RouteNames.usersDevicesDeviceOnboarding,
                              ),
                              icon: const Icon(Icons.phonelink_setup_outlined),
                              label: const Text('Onboarding'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class UsersDevicesAccessMatrixScreen extends ConsumerStatefulWidget {
  const UsersDevicesAccessMatrixScreen({super.key});

  @override
  ConsumerState<UsersDevicesAccessMatrixScreen> createState() =>
      _UsersDevicesAccessMatrixScreenState();
}

class _UsersDevicesAccessMatrixScreenState
    extends ConsumerState<UsersDevicesAccessMatrixScreen> {
  String _roleQuery = '';
  String _ruleQuery = '';
  String? _selectedAccessUserId;
  String? _selectedAccessRole;
  String? _selectedAccessPermission;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Access Matrix'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Access Matrix',
        message: 'The access matrix could not be loaded right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) {
        final selectedUser = data.users.isEmpty
            ? null
            : data.users.firstWhere(
                (user) => user.id == _selectedAccessUserId,
                orElse: () => data.users.first,
              );
        final selectedRole = data.roles.isEmpty
            ? ''
            : (_selectedAccessRole ??
                  (selectedUser != null
                      ? selectedUser.role
                      : data.roles.first.role));
        final selectedPermission = data.permissions.isEmpty
            ? ''
            : (_selectedAccessPermission ?? data.permissions.first.permission);
        final filteredRoles = data.roles
            .where((role) {
              final query = _roleQuery.trim().toLowerCase();
              if (query.isEmpty) {
                return true;
              }
              final haystack = [
                role.role,
                ...role.permissions,
              ].join(' ').toLowerCase();
              return haystack.contains(query);
            })
            .toList(growable: false);

        final filteredRules = data.accessRules
            .where((rule) {
              final query = _ruleQuery.trim().toLowerCase();
              if (query.isEmpty) {
                return true;
              }
              final haystack = [
                rule.moduleId,
                rule.viewPermission,
                rule.editPermission,
                rule.adminPermission,
                rule.requestPermission,
                rule.executePermission,
                rule.controlPermission,
                rule.requiresTrustLevel.toString(),
                ...rule.requiresApprovalFor,
              ].join(' ').toLowerCase();
              return haystack.contains(query);
            })
            .toList(growable: false);

        return _SectionScaffold(
          title: 'Access Matrix',
          subtitle: 'Role permissions, trust floors, and module gates',
          onBack: () => context.go(RouteNames.usersDevices),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionStrip(
                title: 'Gatekeeper checks',
                subtitle:
                    'Create a sample approval to watch the audit trail update.',
                actions: [
                  _ActionChip(
                    label: 'Create sample approval',
                    icon: Icons.rule_folder_outlined,
                    onPressed: () => _createSampleApproval(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Access at a glance',
                subtitle:
                    'See the selected identity, role, permission, and current gate shape before making changes.',
                icon: Icons.visibility_outlined,
                compact: true,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CardChip(
                      label: selectedUser == null
                          ? 'No user selected'
                          : selectedUser.displayName,
                    ),
                    if (selectedUser != null)
                      _CardChip(label: selectedUser.role),
                    if (selectedPermission.isNotEmpty)
                      _CardChip(label: selectedPermission),
                    if (selectedRole.isNotEmpty) _CardChip(label: selectedRole),
                    _CardChip(label: '${data.accessRules.length} rules'),
                    _CardChip(
                      label:
                          '${data.accessRules.where((rule) => rule.requiresApprovalFor.isNotEmpty).length} gated rules',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SummaryRow(
                items: [
                  ('Roles', data.roles.length),
                  ('Rules', data.accessRules.length),
                  (
                    'Gated',
                    data.accessRules
                        .where((rule) => rule.requiresApprovalFor.isNotEmpty)
                        .length,
                  ),
                  (
                    'Trust 4+',
                    data.accessRules
                        .where((rule) => rule.requiresTrustLevel >= 4)
                        .length,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 430,
                    child: _VisualPanel(
                      title: 'Access editor',
                      subtitle:
                          'Change one local role or permission without leaving the matrix.',
                      icon: Icons.manage_accounts_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.users.isEmpty ||
                              data.roles.isEmpty ||
                              data.permissions.isEmpty)
                            const _EmptyCollectionState(
                              icon: Icons.manage_accounts_outlined,
                              title: 'Access editing is waiting for seed data',
                              body:
                                  'Roles, permissions, and users need to be present before assignments can be made.',
                            )
                          else ...[
                            _CardChip(
                              label:
                                  'Editing ${selectedUser?.displayName ?? 'selected user'}',
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: selectedUser?.id,
                              decoration: const InputDecoration(
                                labelText: 'User',
                              ),
                              items: [
                                for (final user in data.users)
                                  DropdownMenuItem<String>(
                                    value: user.id,
                                    child: Text(
                                      '${user.displayName} (${user.id})',
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedAccessUserId = value;
                                  final user = data.users.firstWhere(
                                    (item) => item.id == value,
                                    orElse: () => data.users.first,
                                  );
                                  _selectedAccessRole = user.role;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: selectedRole.isEmpty
                                  ? null
                                  : selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Role to assign',
                              ),
                              items: [
                                for (final role in data.roles)
                                  DropdownMenuItem<String>(
                                    value: role.role,
                                    child: Text(role.role),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() => _selectedAccessRole = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: selectedPermission.isEmpty
                                  ? null
                                  : selectedPermission,
                              decoration: const InputDecoration(
                                labelText: 'Permission to grant',
                              ),
                              items: [
                                for (final permission in data.permissions)
                                  DropdownMenuItem<String>(
                                    value: permission.permission,
                                    child: Text(permission.permission),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(
                                  () => _selectedAccessPermission = value,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (selectedUser != null) ...[
                                  _CardChip(label: selectedUser.displayName),
                                  _CardChip(label: selectedUser.role),
                                  _CardChip(
                                    label:
                                        '${selectedUser.permissions.length} permissions',
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilledButton.tonal(
                                  onPressed:
                                      selectedUser == null ||
                                          selectedRole.isEmpty
                                      ? null
                                      : () async {
                                          await ref
                                              .read(
                                                usersDevicesControlRepositoryProvider,
                                              )
                                              .assignRole(
                                                selectedUser.id,
                                                selectedRole,
                                              );
                                          ref.invalidate(
                                            usersDevicesControlSnapshotProvider,
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${selectedUser.displayName} now uses the $selectedRole role.',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  child: const Text('Assign role'),
                                ),
                                OutlinedButton(
                                  onPressed:
                                      selectedUser == null ||
                                          selectedPermission.isEmpty
                                      ? null
                                      : () async {
                                          await ref
                                              .read(
                                                usersDevicesControlRepositoryProvider,
                                              )
                                              .assignPermission(
                                                selectedUser.id,
                                                selectedPermission,
                                              );
                                          ref.invalidate(
                                            usersDevicesControlSnapshotProvider,
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '$selectedPermission granted to ${selectedUser.displayName}.',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  child: const Text('Grant permission'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 430,
                    child: _VisualPanel(
                      title: 'Role permissions',
                      subtitle:
                          'What each identity can do locally and what it currently carries.',
                      icon: Icons.badge_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            onChanged: (value) =>
                                setState(() => _roleQuery = value),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search_outlined),
                              labelText: 'Search roles',
                              hintText: 'Role name or permission',
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (filteredRoles.isEmpty)
                            const _EmptyCollectionState(
                              icon: Icons.badge_outlined,
                              title: 'No roles matched the current filter',
                              body:
                                  'Try a broader search term to bring the role cards back.',
                            )
                          else
                            Column(
                              children: [
                                for (final role in filteredRoles)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _EntityCard(
                                      icon: Icons.badge_outlined,
                                      title: role.role,
                                      subtitle:
                                          '${role.permissions.length} permissions',
                                      body: role.permissions.isEmpty
                                          ? 'No permissions configured.'
                                          : role.permissions.join(' - '),
                                      chips: [
                                        if (role.permissions.isNotEmpty)
                                          _CardChip(
                                            label:
                                                '${role.permissions.length} scopes',
                                          ),
                                        if (role.permissions.isNotEmpty)
                                          _CardChip(
                                            label: role.permissions.first,
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 430,
                    child: _VisualPanel(
                      title: 'Module rules',
                      subtitle:
                          'Trust and approval thresholds for each sensitive module.',
                      icon: Icons.shield_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            onChanged: (value) =>
                                setState(() => _ruleQuery = value),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search_outlined),
                              labelText: 'Search rules',
                              hintText: 'Module, permission, or trust level',
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (filteredRules.isEmpty)
                            const _EmptyCollectionState(
                              icon: Icons.shield_outlined,
                              title: 'No rules matched the current filter',
                              body:
                                  'Try a broader search term to bring the rule cards back.',
                            )
                          else
                            Column(
                              children: [
                                for (final rule in filteredRules)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _EntityCard(
                                      icon: Icons.shield_outlined,
                                      title: rule.moduleId,
                                      subtitle:
                                          'Trust floor ${rule.requiresTrustLevel}',
                                      body:
                                          'View ${rule.viewPermission.isEmpty ? 'none' : rule.viewPermission} - Edit ${rule.editPermission.isEmpty ? 'none' : rule.editPermission} - Approvals ${rule.requiresApprovalFor.length}',
                                      trailing: Chip(
                                        label: Text(
                                          rule.requiresApprovalFor.isEmpty
                                              ? 'Open'
                                              : 'Gated',
                                        ),
                                      ),
                                      chips: [
                                        _CardChip(
                                          label:
                                              'Trust ${rule.requiresTrustLevel}',
                                        ),
                                        if (rule.viewPermission.isNotEmpty)
                                          _CardChip(label: rule.viewPermission),
                                        if (rule.editPermission.isNotEmpty)
                                          _CardChip(label: rule.editPermission),
                                        _CardChip(
                                          label:
                                              rule.requiresApprovalFor.isEmpty
                                              ? 'No approvals'
                                              : '${rule.requiresApprovalFor.length} approvals',
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class UsersDevicesDeviceOnboardingScreen extends ConsumerStatefulWidget {
  const UsersDevicesDeviceOnboardingScreen({super.key});

  @override
  ConsumerState<UsersDevicesDeviceOnboardingScreen> createState() =>
      _UsersDevicesDeviceOnboardingScreenState();
}

class _UsersDevicesDeviceOnboardingScreenState
    extends ConsumerState<UsersDevicesDeviceOnboardingScreen> {
  String _template = 'standard';
  String _historyQuery = '';
  String _historyFilter = 'all';
  String? _selectedOnboardingUserId;

  void _seedOnboardingUser(UsersDevicesControlSnapshot snapshot) {
    if (_selectedOnboardingUserId != null &&
        snapshot.users.any((user) => user.id == _selectedOnboardingUserId)) {
      return;
    }
    _selectedOnboardingUserId = snapshot.users.isEmpty
        ? null
        : snapshot.users
              .firstWhere(
                (user) => user.status == 'active',
                orElse: () => snapshot.users.first,
              )
              .id;
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    final pinsSnapshot = ref.watch(usersDevicesPinRegistrySnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Device Onboarding'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Device Onboarding',
        message: 'The onboarding flow is not ready right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) {
        final trustBands = data.trustLevels;
        final trustedDevices = [...data.devices]
          ..sort((a, b) => b.trustLevel.compareTo(a.trustLevel));
        final highTrustDevices = trustedDevices
            .where((device) => device.isHighTrust)
            .toList(growable: false);
        final reviewDevices = data.devices
            .where((device) => device.needsOnboardingReview)
            .toList(growable: false);
        final trustEvents =
            data.auditLog
                .where((event) => event.eventType == 'device_trust_confirmed')
                .toList(growable: false)
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _seedOnboardingUser(data);
        final pins = pinsSnapshot.maybeWhen(
          data: (snapshot) => snapshot,
          orElse: () => const UsersDevicesPinRegistrySnapshot(
            records: <UsersDevicesPinRecord>[],
          ),
        );
        final selectedUser = _selectedOnboardingUserId == null
            ? null
            : data.users.firstWhere(
                (user) => user.id == _selectedOnboardingUserId,
                orElse: () => data.users.first,
              );
        final selectedPrimaryPin = selectedUser == null
            ? null
            : pins.primaryPinForUser(selectedUser.id);
        final selectedRecoveryPins = selectedUser == null
            ? const <UsersDevicesPinRecord>[]
            : pins.recoveryPinsForUser(selectedUser.id);
        ({
          UsersDevicesControlUser user,
          bool hasRoleAndPermissions,
          bool hasPrimaryPin,
          bool hasTrustedDevice,
          bool accessReady,
          int linkedDeviceCount,
          int trustedDeviceCount,
          int recoveryPinCount,
        })
        readinessForUser(UsersDevicesControlUser user) {
          final userPrimaryPin = pins.primaryPinForUser(user.id);
          final userRecoveryPins = pins.recoveryPinsForUser(user.id);
          final userLinkedDevices = data.devices
              .where(
                (device) =>
                    user.linkedDevices.contains(device.id) ||
                    device.ownerId == user.id,
              )
              .toList(growable: false);
          final userTrustedDevices = userLinkedDevices
              .where(
                (device) =>
                    device.trustLevel >= 3 &&
                    device.status != 'blocked' &&
                    device.status != 'quarantined',
              )
              .toList(growable: false);
          final userHasRoleAndPermissions =
              user.role.trim().isNotEmpty && user.permissions.isNotEmpty;
          final userHasPrimaryPin = userPrimaryPin != null;
          final userHasTrustedDevice = userTrustedDevices.isNotEmpty;
          return (
            user: user,
            hasRoleAndPermissions: userHasRoleAndPermissions,
            hasPrimaryPin: userHasPrimaryPin,
            hasTrustedDevice: userHasTrustedDevice,
            accessReady:
                userHasRoleAndPermissions &&
                userHasPrimaryPin &&
                userHasTrustedDevice,
            linkedDeviceCount: userLinkedDevices.length,
            trustedDeviceCount: userTrustedDevices.length,
            recoveryPinCount: userRecoveryPins.length,
          );
        }

        final linkedDevices = selectedUser == null
            ? const <UsersDevicesControlDevice>[]
            : data.devices
                  .where(
                    (device) =>
                        selectedUser.linkedDevices.contains(device.id) ||
                        device.ownerId == selectedUser.id,
                  )
                  .toList(growable: false);
        final trustedLinkedDevices = linkedDevices
            .where(
              (device) =>
                  device.trustLevel >= 3 &&
                  device.status != 'blocked' &&
                  device.status != 'quarantined',
            )
            .toList(growable: false);
        final quarantinedLinkedDevices = linkedDevices
            .where((device) => device.status == 'quarantined')
            .toList(growable: false);
        final hasRoleAndPermissions =
            selectedUser != null &&
            selectedUser.role.trim().isNotEmpty &&
            selectedUser.permissions.isNotEmpty;
        final hasPrimaryPin = selectedPrimaryPin != null;
        final hasTrustedDevice = trustedLinkedDevices.isNotEmpty;
        final accessReady =
            selectedUser != null &&
            hasRoleAndPermissions &&
            hasPrimaryPin &&
            hasTrustedDevice;
        final roleStepBody = hasRoleAndPermissions
            ? '${selectedUser.role} is assigned and local permissions are present.'
            : 'Open Users to assign the right role and make sure this person carries the permissions they need.';
        final pinStepBody = hasPrimaryPin
            ? 'Primary label: ${selectedPrimaryPin.label}. Recovery PINs live alongside it for support only.'
            : selectedRecoveryPins.isNotEmpty
            ? 'Recovery PIN exists, but this user still needs a fresh primary PIN for normal unlock.'
            : 'Open PIN Registry and assign a primary PIN before this user tries to unlock locally.';
        final nextOperatorStep = selectedUser == null
            ? 'Choose the next local user to start onboarding.'
            : !hasRoleAndPermissions
            ? 'Open Users and assign the correct role and permissions first.'
            : !hasPrimaryPin
            ? 'Open PIN Registry and issue a primary PIN for ${selectedUser.displayName}.'
            : quarantinedLinkedDevices.isNotEmpty
            ? 'Review the quarantined device${quarantinedLinkedDevices.length == 1 ? '' : 's'} linked to ${selectedUser.displayName} before trying to verify access.'
            : !hasTrustedDevice
            ? 'Raise trust on one linked device or complete device onboarding for this user.'
            : 'Open Security Lock or a module gate and verify the live local route.';
        final blockerSummary = selectedUser == null
            ? 'No user is selected yet.'
            : accessReady
            ? '${selectedUser.displayName} has a workable local unlock path right now.'
            : [
                if (!hasRoleAndPermissions) 'role or permission assignment',
                if (!hasPrimaryPin) 'primary PIN setup',
                if (!hasTrustedDevice) 'trusted device coverage',
                if (quarantinedLinkedDevices.isNotEmpty) 'quarantine review',
              ].join(' - ');
        final activeUsers = data.users
            .where((user) => user.status == 'active')
            .toList(growable: false);
        final onboardingStatuses = activeUsers
            .map(readinessForUser)
            .toList(growable: false);
        final readyUsersCount = onboardingStatuses
            .where((status) => status.accessReady)
            .length;
        final missingRoleUsersCount = onboardingStatuses
            .where((status) => !status.hasRoleAndPermissions)
            .length;
        final missingPrimaryPinUsersCount = onboardingStatuses
            .where((status) => !status.hasPrimaryPin)
            .length;
        final missingTrustedDeviceUsersCount = onboardingStatuses
            .where((status) => !status.hasTrustedDevice)
            .length;
        final usersNeedingHelp =
            onboardingStatuses
                .where((status) => !status.accessReady)
                .toList(growable: false)
              ..sort((a, b) {
                final scoreA =
                    (a.hasRoleAndPermissions ? 1 : 0) +
                    (a.hasPrimaryPin ? 1 : 0) +
                    (a.hasTrustedDevice ? 1 : 0);
                final scoreB =
                    (b.hasRoleAndPermissions ? 1 : 0) +
                    (b.hasPrimaryPin ? 1 : 0) +
                    (b.hasTrustedDevice ? 1 : 0);
                return scoreB.compareTo(scoreA);
              });
        final selectedAuditEvents =
            selectedUser == null
                  ? const <UsersDevicesControlAuditEvent>[]
                  : data.auditLog
                        .where(
                          (event) =>
                              event.actorId == selectedUser.id ||
                              linkedDevices.any(
                                (device) => device.id == event.deviceId,
                              ),
                        )
                        .toList(growable: false)
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final latestSelectedAudit = selectedAuditEvents.isEmpty
            ? null
            : selectedAuditEvents.first;
        final completionTone = accessReady
            ? 'Ready to verify locally'
            : 'Still completing this onboarding path';
        final completionBody = selectedUser == null
            ? 'Choose a local user first so this screen can show the completion summary and audit trail for one person.'
            : accessReady
            ? '${selectedUser.displayName} now has local identity, permissions, a primary PIN, and a trusted device. The next calm step is simply to verify the route in Security Lock or a gated module.'
            : '${selectedUser.displayName} is partway through onboarding. Finish the missing checkpoints below, then use the audit trail to confirm the full path is locally recorded.';
        final query = _historyQuery.trim().toLowerCase();
        final filteredTrustEvents = trustEvents
            .where((event) {
              if (_historyFilter != 'all' &&
                  _historyFilter != 'confirmations') {
                return false;
              }
              if (query.isEmpty) {
                return true;
              }
              final haystack = [
                event.eventId,
                event.actorId,
                event.deviceId,
                event.targetModule,
                event.action,
                event.result,
                event.reason,
                event.timestamp,
              ].join(' ').toLowerCase();
              return haystack.contains(query);
            })
            .toList(growable: false);
        final filteredTrustedDevices = trustedDevices
            .where((device) {
              if (_historyFilter != 'all' && _historyFilter != 'devices') {
                return false;
              }
              if (query.isEmpty) {
                return device.trustLevel >= 3;
              }
              final haystack = [
                device.id,
                device.name,
                device.type,
                device.status,
                device.ownerId,
                device.notes,
                device.trustLevel.toString(),
                ...device.allowedActions,
              ].join(' ').toLowerCase();
              return haystack.contains(query) && device.trustLevel >= 3;
            })
            .toList(growable: false);
        String ownerLabelFor(String ownerId) {
          for (final user in data.users) {
            if (user.id == ownerId) {
              return user.displayName;
            }
          }
          return ownerId.isEmpty ? 'Unassigned' : ownerId;
        }

        UsersDevicesControlDevice? deviceForId(String id) {
          for (final device in data.devices) {
            if (device.id == id) {
              return device;
            }
          }
          return null;
        }

        String templateForType(String type) {
          final normalized = type.toLowerCase();
          if (normalized.contains('assistant') ||
              normalized.contains('voice')) {
            return 'assistant';
          }
          if (normalized.contains('gateway') || normalized.contains('bridge')) {
            return 'gateway';
          }
          if (normalized.contains('printer') || normalized.contains('label')) {
            return 'printer';
          }
          return 'standard';
        }

        return _SectionScaffold(
          title: 'Device Onboarding',
          subtitle: 'Register, verify, trust, and log a new local device',
          onBack: () => context.go(RouteNames.usersDevices),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionStrip(
                title: 'Live onboarding demo',
                subtitle:
                    'Create a sample device record or open the guided register flow.',
                actions: [
                  _ActionChip(
                    label: 'Start onboarding',
                    icon: Icons.phonelink_setup_outlined,
                    onPressed: () => _openOnboardingWizard(
                      context,
                      ref,
                      template: _template,
                    ),
                  ),
                  _ActionChip(
                    label: 'Register sample device',
                    icon: Icons.auto_fix_high_outlined,
                    onPressed: () => _registerSampleDevice(context, ref),
                  ),
                  _ActionChip(
                    label: 'Open approvals',
                    icon: Icons.rule_folder_outlined,
                    onPressed: () =>
                        context.go(RouteNames.usersDevicesApprovalQueue),
                  ),
                  _ActionChip(
                    label: 'Open onboarding report',
                    icon: Icons.assignment_outlined,
                    onPressed: () => context.go(
                      RouteNames.usersDevicesOnboardingReportFor(
                        userId: _selectedOnboardingUserId,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'User readiness workspace',
                subtitle:
                    'Guide one person from identity setup through to a trusted, testable local access posture.',
                icon: Icons.assignment_turned_in_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedUser?.id,
                      decoration: const InputDecoration(
                        labelText: 'Selected user',
                      ),
                      items: [
                        for (final user in data.users)
                          DropdownMenuItem<String>(
                            value: user.id,
                            child: Text('${user.displayName} (${user.role})'),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedOnboardingUserId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CardChip(
                          label: selectedUser == null
                              ? 'No user selected'
                              : 'User: ${selectedUser.displayName}',
                        ),
                        _CardChip(
                          label: hasRoleAndPermissions
                              ? 'Role ready'
                              : 'Role needs work',
                        ),
                        _CardChip(
                          label: hasPrimaryPin
                              ? 'Primary PIN set'
                              : 'Primary PIN missing',
                        ),
                        _CardChip(
                          label: hasTrustedDevice
                              ? '${trustedLinkedDevices.length} trusted device${trustedLinkedDevices.length == 1 ? '' : 's'}'
                              : 'Trusted device missing',
                        ),
                        if (quarantinedLinkedDevices.isNotEmpty)
                          _CardChip(
                            label:
                                '${quarantinedLinkedDevices.length} quarantined device${quarantinedLinkedDevices.length == 1 ? '' : 's'}',
                          ),
                        _CardChip(
                          label: accessReady
                              ? 'Access ready'
                              : 'Access not verified',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StepCard(
                      step: '1',
                      title: selectedUser == null
                          ? 'Choose a user'
                          : 'Identity selected',
                      body: selectedUser == null
                          ? 'Pick the local user you want to bring through onboarding.'
                          : '${selectedUser.displayName} is the active onboarding target for this checklist.',
                      accentColor: selectedUser != null
                          ? const Color(0xFF7EE6C5)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _StepCard(
                      step: '2',
                      title: hasRoleAndPermissions
                          ? 'Role and permissions set'
                          : 'Assign role and permissions',
                      body: roleStepBody,
                      accentColor: hasRoleAndPermissions
                          ? const Color(0xFF7EE6C5)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _StepCard(
                      step: '3',
                      title: hasPrimaryPin
                          ? 'Primary PIN is ready'
                          : 'Set a primary PIN',
                      body: pinStepBody,
                      accentColor: hasPrimaryPin
                          ? const Color(0xFF7EE6C5)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _StepCard(
                      step: '4',
                      title: hasTrustedDevice
                          ? 'Trusted device linked'
                          : 'Trust a linked device',
                      body: hasTrustedDevice
                          ? 'Trusted device${trustedLinkedDevices.length == 1 ? '' : 's'}: ${trustedLinkedDevices.map((device) => device.name).join(', ')}.'
                          : quarantinedLinkedDevices.isNotEmpty
                          ? 'A linked device is currently quarantined. Review the device evidence and restore trust before trying to verify access.'
                          : linkedDevices.isNotEmpty
                          ? 'This user has linked devices, but none are trusted enough yet. Use the onboarding wizard to raise the trust posture.'
                          : 'No linked device is ready. Start onboarding to register and pair a device for this user.',
                      accentColor: hasTrustedDevice
                          ? const Color(0xFF7EE6C5)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _StepCard(
                      step: '5',
                      title: accessReady
                          ? 'Ready to verify access'
                          : 'Verify the access path',
                      body: accessReady
                          ? 'This user now has identity, role, PIN, and trusted device coverage. Open Security Lock or an access gate to test the route.'
                          : 'Finish the earlier steps first, then open Security Lock or a gated module to confirm the local route behaves as expected.',
                      accentColor: accessReady ? const Color(0xFF7EE6C5) : null,
                    ),
                    const SizedBox(height: 12),
                    _EntityCard(
                      icon: Icons.route_outlined,
                      title: 'Next operator step',
                      subtitle: selectedUser?.displayName ?? 'No user selected',
                      body: nextOperatorStep,
                    ),
                    const SizedBox(height: 12),
                    _EntityCard(
                      icon: Icons.warning_amber_outlined,
                      title: 'Current blocker summary',
                      subtitle: accessReady
                          ? 'All core checkpoints are green'
                          : 'Still needs operator follow-up',
                      body: blockerSummary,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.go(RouteNames.usersDevicesUsers),
                          icon: const Icon(Icons.people_outline),
                          label: const Text('Open Users'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.go(RouteNames.usersDevicesPins),
                          icon: const Icon(Icons.pin_outlined),
                          label: const Text('Open PIN Registry'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _openOnboardingWizard(
                            context,
                            ref,
                            template: _template,
                          ),
                          icon: const Icon(Icons.phonelink_setup_outlined),
                          label: const Text('Start onboarding'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.go(RouteNames.usersDevicesAccessMatrix),
                          icon: const Icon(Icons.grid_view_outlined),
                          label: const Text('Open Access Matrix'),
                        ),
                        FilledButton.icon(
                          onPressed: accessReady
                              ? () => context.go(RouteNames.securityLock)
                              : null,
                          icon: const Icon(Icons.lock_open_outlined),
                          label: const Text('Verify access'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Operator progress board',
                subtitle:
                    'A calm overview for admins and operators to see who is ready, who is blocked, and where the next onboarding help should go.',
                icon: Icons.monitor_heart_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                      items: [
                        ('Ready', readyUsersCount),
                        ('Need role', missingRoleUsersCount),
                        ('Need PIN', missingPrimaryPinUsersCount),
                        ('Need trust', missingTrustedDeviceUsersCount),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.people_outline,
                            title: 'Active onboarding users',
                            subtitle:
                                '${activeUsers.length} local people in scope',
                            body: readyUsersCount == activeUsers.length
                                ? 'Every active user has a workable local access path right now.'
                                : '${activeUsers.length - readyUsersCount} user${activeUsers.length - readyUsersCount == 1 ? '' : 's'} still need help before they can unlock cleanly.',
                            chips: [
                              _CardChip(label: '$readyUsersCount ready'),
                              _CardChip(
                                label:
                                    '${activeUsers.length - readyUsersCount} still in progress',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.rule_folder_outlined,
                            title: 'Approvals and trust checks',
                            subtitle:
                                '${data.approvalQueue.where((request) => request.isPending).length} pending approvals',
                            body:
                                '${trustEvents.length} trust confirmations are already recorded in the audit trail.',
                            chips: [
                              _CardChip(
                                label:
                                    '${data.approvalQueue.where((request) => request.isPending).length} pending',
                              ),
                              _CardChip(
                                label: '${trustEvents.length} confirmations',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (usersNeedingHelp.isEmpty)
                      const _EmptyCollectionState(
                        icon: Icons.task_alt_outlined,
                        title: 'No onboarding follow-up is waiting',
                        body:
                            'Every active user currently has the basics needed for a local unlock path.',
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next users to help',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final status in usersNeedingHelp.take(3))
                                SizedBox(
                                  width: 320,
                                  child: _EntityCard(
                                    icon: Icons.support_agent_outlined,
                                    title: status.user.displayName,
                                    subtitle: status.user.role,
                                    body:
                                        'Linked devices: ${status.linkedDeviceCount} - Trusted: ${status.trustedDeviceCount} - Recovery PINs: ${status.recoveryPinCount}',
                                    chips: [
                                      _CardChip(
                                        label: status.hasRoleAndPermissions
                                            ? 'Role ready'
                                            : 'Role missing',
                                      ),
                                      _CardChip(
                                        label: status.hasPrimaryPin
                                            ? 'Primary PIN ready'
                                            : 'Primary PIN needed',
                                      ),
                                      _CardChip(
                                        label: status.hasTrustedDevice
                                            ? 'Trusted device ready'
                                            : 'Trusted device needed',
                                      ),
                                    ],
                                    actions: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _selectedOnboardingUserId =
                                                status.user.id;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                        ),
                                        label: const Text('Review here'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => context.go(
                                          RouteNames.usersDevicesUsers,
                                        ),
                                        icon: const Icon(Icons.people_outline),
                                        label: const Text('Open Users'),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Device trust review queue',
                subtitle:
                    'See which endpoints still need review before they should support sensitive local access.',
                icon: Icons.privacy_tip_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                      items: [
                        ('Needs review', reviewDevices.length),
                        (
                          'Quarantined',
                          reviewDevices
                              .where((device) => device.status == 'quarantined')
                              .length,
                        ),
                        (
                          'Blocked',
                          reviewDevices
                              .where((device) => device.status == 'blocked')
                              .length,
                        ),
                        (
                          'Below trust 3',
                          reviewDevices
                              .where((device) => device.trustLevel < 3)
                              .length,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (reviewDevices.isEmpty)
                      const _EmptyCollectionState(
                        icon: Icons.verified_user_outlined,
                        title: 'No device trust follow-up is waiting',
                        body:
                            'Every active local device already has enough posture for the current onboarding scope.',
                      )
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final device in reviewDevices.take(6))
                            SizedBox(
                              width: 320,
                              child: _EntityCard(
                                icon: device.status == 'quarantined'
                                    ? Icons.gpp_bad_outlined
                                    : device.status == 'blocked'
                                    ? Icons.block_outlined
                                    : Icons.devices_outlined,
                                title: device.name,
                                subtitle:
                                    '${ownerLabelFor(device.ownerId)} - ${device.trustPostureLabel}',
                                body:
                                    '${device.trustPostureSummary}\n${device.trustEvidenceSummary}',
                                chips: [
                                  _CardChip(
                                    label: 'Trust ${device.trustLevel}',
                                  ),
                                  _CardChip(label: 'Status: ${device.status}'),
                                  if (device.allowedActions.isNotEmpty)
                                    _CardChip(
                                      label:
                                          '${device.allowedActions.length} local scopes',
                                    ),
                                ],
                                actions: [
                                  OutlinedButton.icon(
                                    onPressed: () => _openDeviceEditor(
                                      context,
                                      ref,
                                      device: device,
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Review device'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _toggleDeviceQuarantine(
                                      context,
                                      ref,
                                      device,
                                    ),
                                    icon: Icon(
                                      device.isQuarantined
                                          ? Icons.verified_user_outlined
                                          : Icons.pause_circle_outline,
                                    ),
                                    label: Text(
                                      device.isQuarantined
                                          ? 'Restore trust'
                                          : 'Quarantine',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.go(RouteNames.usersDevicesDevices),
                          icon: const Icon(Icons.devices_outlined),
                          label: const Text('Open Devices'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _openOnboardingWizard(
                            context,
                            ref,
                            template: _template,
                          ),
                          icon: const Icon(Icons.phonelink_setup_outlined),
                          label: const Text('Run trust drill'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Completion summary',
                subtitle:
                    'When one user is ready, this panel gives a calm handoff summary and the audit evidence behind it.',
                icon: Icons.fact_check_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CardChip(label: completionTone),
                        if (selectedUser != null)
                          _CardChip(label: selectedUser.displayName),
                        if (selectedUser != null)
                          _CardChip(label: selectedUser.role),
                        _CardChip(
                          label: hasPrimaryPin
                              ? 'Primary PIN set'
                              : 'Primary PIN missing',
                        ),
                        _CardChip(
                          label: hasTrustedDevice
                              ? '${trustedLinkedDevices.length} trusted device${trustedLinkedDevices.length == 1 ? '' : 's'}'
                              : 'Trusted device missing',
                        ),
                        _CardChip(
                          label:
                              '${selectedAuditEvents.length} audit event${selectedAuditEvents.length == 1 ? '' : 's'}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(completionBody),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.badge_outlined,
                            title: 'Identity and permissions',
                            subtitle:
                                selectedUser?.displayName ?? 'No user selected',
                            body: hasRoleAndPermissions
                                ? '${selectedUser.role} is assigned and the local permission list is populated.'
                                : 'This user still needs the correct role or permissions before the route should be treated as complete.',
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.devices_outlined,
                            title: 'Device trust posture',
                            subtitle: hasTrustedDevice
                                ? 'Trusted route is present'
                                : 'Trusted route still missing',
                            body: hasTrustedDevice
                                ? trustedLinkedDevices
                                      .map((device) => device.name)
                                      .join(', ')
                                : quarantinedLinkedDevices.isNotEmpty
                                ? 'Quarantined: ${quarantinedLinkedDevices.map((device) => device.name).join(', ')}'
                                : linkedDevices.isEmpty
                                ? 'No device is linked to this user yet.'
                                : 'A device is linked, but it still needs more trust before it should unlock sensitive routes.',
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.verified_user_outlined,
                            title: 'Trust evidence',
                            subtitle: quarantinedLinkedDevices.isNotEmpty
                                ? 'Quarantine review needed'
                                : hasTrustedDevice
                                ? 'Evidence recorded'
                                : 'Evidence still thin',
                            body: linkedDevices.isEmpty
                                ? 'No linked device evidence exists for this user yet.'
                                : linkedDevices.first.trustEvidenceSummary,
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.receipt_long_outlined,
                            title: 'Latest audit evidence',
                            subtitle:
                                latestSelectedAudit?.eventType ??
                                'No audit yet',
                            body: latestSelectedAudit == null
                                ? 'No related audit event has been found for this user or their linked devices yet.'
                                : '${latestSelectedAudit.result} - ${latestSelectedAudit.reason}\n${latestSelectedAudit.timestamp}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () =>
                              context.go(RouteNames.usersDevicesAuditLog),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Open audit log'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go(
                            RouteNames.usersDevicesOnboardingReportFor(
                              userId: selectedUser?.id,
                            ),
                          ),
                          icon: const Icon(Icons.assignment_outlined),
                          label: const Text('Open onboarding report'),
                        ),
                        OutlinedButton.icon(
                          onPressed: accessReady
                              ? () => context.go(RouteNames.securityLock)
                              : null,
                          icon: const Icon(Icons.lock_open_outlined),
                          label: const Text('Verify in Security Lock'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Trust drill checklist',
                subtitle:
                    'Use this when a device still needs review, quarantine follow-up, or a fresh trust confirmation.',
                icon: Icons.checklist_rtl_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          label: linkedDevices.isEmpty
                              ? 'Linked devices: 0'
                              : 'Linked devices: ${linkedDevices.length}',
                        ),
                        _CardChip(
                          label: quarantinedLinkedDevices.isEmpty
                              ? 'Quarantine clear'
                              : 'Quarantine: ${quarantinedLinkedDevices.length}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _StepCard(
                      step: '1',
                      title: 'Confirm the endpoint',
                      body:
                          'Check the device name, owner, purpose, and whether it is still the right endpoint for this person.',
                    ),
                    const SizedBox(height: 12),
                    const _StepCard(
                      step: '2',
                      title: 'Read the trust evidence',
                      body:
                          'Review the trust source, reviewer, last seen signal, and any quarantine note before changing posture.',
                    ),
                    const SizedBox(height: 12),
                    const _StepCard(
                      step: '3',
                      title: 'Resolve the gap',
                      body:
                          'Either raise trust, keep the device quarantined, or replace it with a cleaner endpoint. Record the reason in the local audit trail.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'First-time trust path',
                subtitle:
                    'A new device should be registered, confirmed, and trusted in one calm pass.',
                icon: Icons.verified_user_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StepCard(
                      step: '1',
                      title: 'Register the device',
                      body:
                          'Capture the device name, type, owner, and local purpose.',
                    ),
                    const SizedBox(height: 12),
                    const _StepCard(
                      step: '2',
                      title: 'Confirm the owner and trust',
                      body:
                          'Review the pairing, confirm the owner, and acknowledge any high-trust device before continuing.',
                    ),
                    const SizedBox(height: 12),
                    const _StepCard(
                      step: '3',
                      title: 'Write the trust record',
                      body:
                          'Pick the local scopes, then write the device record and trust audit together.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Onboarding template',
                subtitle: 'Pick a calm starting point before the wizard opens',
                icon: Icons.tune_outlined,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SoftChoiceChip(
                      label: const Text('Standard'),
                      selected: _template == 'standard',
                      onSelected: (_) => setState(() => _template = 'standard'),
                    ),
                    _SoftChoiceChip(
                      label: const Text('Assistant'),
                      selected: _template == 'assistant',
                      onSelected: (_) =>
                          setState(() => _template = 'assistant'),
                    ),
                    _SoftChoiceChip(
                      label: const Text('Gateway'),
                      selected: _template == 'gateway',
                      onSelected: (_) => setState(() => _template = 'gateway'),
                    ),
                    _SoftChoiceChip(
                      label: const Text('Printer'),
                      selected: _template == 'printer',
                      onSelected: (_) => setState(() => _template = 'printer'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _TrustPosturePanel(
                trustBands: trustBands,
                trustedDevices: trustedDevices,
                highTrustDevices: highTrustDevices,
                reviewDevices: reviewDevices,
                template: _template,
              ),
              const SizedBox(height: 16),
              _SummaryRow(
                items: [
                  ('Devices', data.devices.length),
                  (
                    'Trusted',
                    data.devices
                        .where((device) => device.trustLevel >= 3)
                        .length,
                  ),
                  (
                    'Registered',
                    data.devices
                        .where((device) => device.status == 'registered')
                        .length,
                  ),
                  (
                    'Owners',
                    data.devices
                        .where((device) => device.ownerId.isNotEmpty)
                        .length,
                  ),
                  (
                    'Blocked',
                    data.devices
                        .where((device) => device.status == 'blocked')
                        .length,
                  ),
                  (
                    'Quarantined',
                    data.devices
                        .where((device) => device.status == 'quarantined')
                        .length,
                  ),
                  (
                    'Archived',
                    data.devices
                        .where((device) => device.status == 'archived')
                        .length,
                  ),
                  ('Trust bands', trustBands.length),
                ],
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Trust levels',
                subtitle: 'The local scale that shapes access decisions',
                icon: Icons.verified_outlined,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final level in trustBands)
                      SizedBox(
                        width: 280,
                        child: _EntityCard(
                          icon: Icons.verified_outlined,
                          title: '${level.level} - ${level.name}',
                          subtitle: 'Trust band',
                          body: level.description,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SearchFilterPanel(
                title: 'Onboarding history',
                subtitle:
                    'Search recent pairings or trusted devices by id, owner, reason, or action.',
                query: _historyQuery,
                onQueryChanged: (value) =>
                    setState(() => _historyQuery = value),
                chips: [
                  _SoftChoiceChip(
                    label: const Text('All'),
                    selected: _historyFilter == 'all',
                    onSelected: (_) => setState(() => _historyFilter = 'all'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Confirmations'),
                    selected: _historyFilter == 'confirmations',
                    onSelected: (_) =>
                        setState(() => _historyFilter = 'confirmations'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Trusted devices'),
                    selected: _historyFilter == 'devices',
                    onSelected: (_) =>
                        setState(() => _historyFilter = 'devices'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 430,
                    child: _VisualPanel(
                      title: 'Recent trust confirmations',
                      subtitle:
                          'Review the latest pairings and the local confirmation audit.',
                      icon: Icons.history_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (filteredTrustEvents.isEmpty)
                            const _EmptyCollectionState(
                              icon: Icons.history_outlined,
                              title: 'No trust confirmations matched',
                              body:
                                  'Try a broader search term or switch the filter back to All.',
                            )
                          else
                            Column(
                              children: [
                                for (final event in filteredTrustEvents.take(5))
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _EntityCard(
                                      icon: Icons.verified_user_outlined,
                                      title: event.deviceId,
                                      subtitle:
                                          '${event.actorId} confirmed ${event.result}',
                                      body:
                                          '${event.timestamp}\n${event.reason}',
                                      trailing: Chip(label: Text(event.result)),
                                      chips: [
                                        _CardChip(label: event.targetModule),
                                        _CardChip(label: event.action),
                                      ],
                                      onTap: () {
                                        final matchedDevice = deviceForId(
                                          event.deviceId,
                                        );
                                        if (matchedDevice != null) {
                                          _openDeviceEditor(
                                            context,
                                            ref,
                                            device: matchedDevice,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 430,
                    child: _VisualPanel(
                      title: 'Trusted devices',
                      subtitle:
                          'Quick review of higher-trust devices already paired locally.',
                      icon: Icons.devices_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (filteredTrustedDevices.isEmpty)
                            const _EmptyCollectionState(
                              icon: Icons.devices_outlined,
                              title: 'No trusted devices matched',
                              body:
                                  'Try a broader search term or switch the filter back to All.',
                            )
                          else
                            Column(
                              children: [
                                for (final device
                                    in filteredTrustedDevices.take(5))
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _EntityCard(
                                      icon: Icons.devices_outlined,
                                      title: device.name,
                                      subtitle: device.type,
                                      body:
                                          '${device.trustPostureSummary}\nTrust T${device.trustLevel} - ${device.status} - owner ${device.ownerId.isEmpty ? 'unassigned' : device.ownerId}',
                                      chips: [
                                        _CardChip(
                                          label: 'T${device.trustLevel}',
                                        ),
                                        _CardChip(label: device.status),
                                        _CardChip(
                                          label: device.trustPostureLabel,
                                        ),
                                      ],
                                      actions: [
                                        OutlinedButton(
                                          onPressed: () => _openDeviceEditor(
                                            context,
                                            ref,
                                            device: device,
                                          ),
                                          child: const Text('Edit device'),
                                        ),
                                        FilledButton.tonal(
                                          onPressed: () =>
                                              _openOnboardingWizard(
                                                context,
                                                ref,
                                                template: templateForType(
                                                  device.type,
                                                ),
                                              ),
                                          child: const Text('Reopen wizard'),
                                        ),
                                      ],
                                      onTap: () => _openDeviceEditor(
                                        context,
                                        ref,
                                        device: device,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

int _compareDeviceReviewPriority(
  UsersDevicesControlDevice left,
  UsersDevicesControlDevice right,
) {
  int score(UsersDevicesControlDevice device) {
    var value = 0;
    if (device.status == 'quarantined') value += 6;
    if (device.status == 'blocked') value += 5;
    if (device.trustLevel < 3) value += 3;
    if (device.status == 'registered') value += 2;
    if (device.needsOnboardingReview) value += 1;
    return value;
  }

  return score(right).compareTo(score(left));
}

String _buildDeviceTrustChecklistSummary(UsersDevicesControlDevice device) {
  if (device.isQuarantined) {
    return '${device.name} is quarantined right now. Resolve the quarantine reason first, then restore trust only when the endpoint is safe to rejoin gated local work.';
  }
  if (device.status == 'blocked') {
    return '${device.name} is blocked and should not be used for sensitive module access until it is restored or re-onboarded.';
  }
  if (device.trustLevel < 3) {
    return '${device.name} is still below the normal trust floor. Review the endpoint evidence before raising trust or using it for protected routes.';
  }
  return '${device.name} still needs onboarding review. Confirm the owner, trust source, and local purpose before treating it as ready.';
}

class _TrustPosturePanel extends StatelessWidget {
  const _TrustPosturePanel({
    required this.trustBands,
    required this.trustedDevices,
    required this.highTrustDevices,
    required this.reviewDevices,
    required this.template,
  });

  final List<UsersDevicesControlTrustLevelDefinition> trustBands;
  final List<UsersDevicesControlDevice> trustedDevices;
  final List<UsersDevicesControlDevice> highTrustDevices;
  final List<UsersDevicesControlDevice> reviewDevices;
  final String template;

  @override
  Widget build(BuildContext context) {
    final topDevice = trustedDevices.isEmpty ? null : trustedDevices.first;
    return _VisualPanel(
      title: 'Trust posture',
      subtitle:
          'Device onboarding is mostly about choosing the right trust band and recording the pairing cleanly.',
      icon: Icons.verified_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CardChip(label: '${trustBands.length} trust bands'),
              _CardChip(label: '${trustedDevices.length} trusted devices'),
              _CardChip(label: '${highTrustDevices.length} high-trust devices'),
              _CardChip(label: '${reviewDevices.length} devices need review'),
              _CardChip(label: 'Template: ${template.toUpperCase()}'),
              if (topDevice != null)
                _CardChip(label: 'Top trust: ${topDevice.name}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reviewDevices.isEmpty
                ? 'The current device set reads cleanly: every active device is already trusted enough for normal gated routes.'
                : 'Some devices still need onboarding review before they should be used for sensitive access.',
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 54,
                dataRowMaxHeight: 88,
                columns: const [
                  DataColumn(label: Text('Level')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Description')),
                ],
                rows: trustBands
                    .map(
                      (level) => DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 100,
                              child: Text('T${level.level}'),
                            ),
                          ),
                          DataCell(
                            SizedBox(width: 180, child: Text(level.name)),
                          ),
                          DataCell(
                            SizedBox(
                              width: 420,
                              child: Text(level.description),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UsersDevicesOnboardingReportScreen extends ConsumerStatefulWidget {
  const UsersDevicesOnboardingReportScreen({
    super.key,
    this.initialUserId,
    this.initialStatusFilter = 'all',
  });

  final String? initialUserId;
  final String initialStatusFilter;

  @override
  ConsumerState<UsersDevicesOnboardingReportScreen> createState() =>
      _UsersDevicesOnboardingReportScreenState();
}

class _UsersDevicesOnboardingReportScreenState
    extends ConsumerState<UsersDevicesOnboardingReportScreen> {
  String _searchQuery = '';
  late String _statusFilter = widget.initialStatusFilter;
  String? _selectedUserId;

  void _seedSelectedUser(UsersDevicesControlSnapshot snapshot) {
    if (_selectedUserId != null &&
        snapshot.users.any((user) => user.id == _selectedUserId)) {
      return;
    }

    if (widget.initialUserId != null &&
        snapshot.users.any((user) => user.id == widget.initialUserId)) {
      _selectedUserId = widget.initialUserId;
      return;
    }

    _selectedUserId = snapshot.users.isEmpty
        ? null
        : snapshot.users
              .firstWhere(
                (user) => user.status == 'active',
                orElse: () => snapshot.users.first,
              )
              .id;
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    final pinsSnapshot = ref.watch(usersDevicesPinRegistrySnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Onboarding Report'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Onboarding Report',
        message: 'The onboarding report could not load right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) {
        _seedSelectedUser(data);
        final pins = pinsSnapshot.maybeWhen(
          data: (snapshot) => snapshot,
          orElse: () => const UsersDevicesPinRegistrySnapshot(
            records: <UsersDevicesPinRecord>[],
          ),
        );

        ({
          UsersDevicesControlUser user,
          bool hasRoleAndPermissions,
          bool hasPrimaryPin,
          bool hasTrustedDevice,
          bool accessReady,
          int linkedDeviceCount,
          int trustedDeviceCount,
          int recoveryPinCount,
          int deniedAuditCount,
          int pendingAuditCount,
          bool hasBlockedLinkedDevice,
          bool hasQuarantinedLinkedDevice,
          List<UsersDevicesControlDevice> linkedDevices,
          List<UsersDevicesControlDevice> trustedDevices,
          UsersDevicesControlAuditEvent? latestAudit,
        })
        readinessForUser(UsersDevicesControlUser user) {
          final userPrimaryPin = pins.primaryPinForUser(user.id);
          final userRecoveryPins = pins.recoveryPinsForUser(user.id);
          final userLinkedDevices = data.devices
              .where(
                (device) =>
                    user.linkedDevices.contains(device.id) ||
                    device.ownerId == user.id,
              )
              .toList(growable: false);
          final userTrustedDevices = userLinkedDevices
              .where(
                (device) =>
                    device.trustLevel >= 3 &&
                    device.status != 'blocked' &&
                    device.status != 'quarantined',
              )
              .toList(growable: false);
          final relatedAuditEvents =
              data.auditLog
                  .where(
                    (event) =>
                        event.actorId == user.id ||
                        userLinkedDevices.any(
                          (device) => device.id == event.deviceId,
                        ),
                  )
                  .toList(growable: false)
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final userHasRoleAndPermissions =
              user.role.trim().isNotEmpty && user.permissions.isNotEmpty;
          final userHasPrimaryPin = userPrimaryPin != null;
          final userHasTrustedDevice = userTrustedDevices.isNotEmpty;
          return (
            user: user,
            hasRoleAndPermissions: userHasRoleAndPermissions,
            hasPrimaryPin: userHasPrimaryPin,
            hasTrustedDevice: userHasTrustedDevice,
            accessReady:
                userHasRoleAndPermissions &&
                userHasPrimaryPin &&
                userHasTrustedDevice,
            linkedDeviceCount: userLinkedDevices.length,
            trustedDeviceCount: userTrustedDevices.length,
            recoveryPinCount: userRecoveryPins.length,
            deniedAuditCount: relatedAuditEvents
                .where((event) => event.result == 'denied')
                .length,
            pendingAuditCount: relatedAuditEvents
                .where((event) => event.result == 'pending')
                .length,
            hasBlockedLinkedDevice: userLinkedDevices.any(
              (device) => device.status == 'blocked',
            ),
            hasQuarantinedLinkedDevice: userLinkedDevices.any(
              (device) => device.status == 'quarantined',
            ),
            linkedDevices: userLinkedDevices,
            trustedDevices: userTrustedDevices,
            latestAudit: relatedAuditEvents.isEmpty
                ? null
                : relatedAuditEvents.first,
          );
        }

        String statusLabelFor(
          ({
            UsersDevicesControlUser user,
            bool hasRoleAndPermissions,
            bool hasPrimaryPin,
            bool hasTrustedDevice,
            bool accessReady,
            int linkedDeviceCount,
            int trustedDeviceCount,
            int recoveryPinCount,
            int deniedAuditCount,
            int pendingAuditCount,
            bool hasBlockedLinkedDevice,
            bool hasQuarantinedLinkedDevice,
            List<UsersDevicesControlDevice> linkedDevices,
            List<UsersDevicesControlDevice> trustedDevices,
            UsersDevicesControlAuditEvent? latestAudit,
          })
          status,
        ) {
          if (status.user.status == 'archived' ||
              status.user.status == 'disabled') {
            return 'archived';
          }
          if (status.hasBlockedLinkedDevice ||
              status.hasQuarantinedLinkedDevice) {
            return 'blocked';
          }
          if (status.accessReady &&
              (status.deniedAuditCount > 0 ||
                  status.pendingAuditCount > 0 ||
                  status.recoveryPinCount > 0)) {
            return 'exception-only';
          }
          if (status.accessReady) {
            return 'ready';
          }
          if (!status.hasRoleAndPermissions) {
            return 'missing-role';
          }
          if (!status.hasPrimaryPin) {
            return 'missing-pin';
          }
          if (!status.hasTrustedDevice) {
            return 'missing-trust';
          }
          return 'in-progress';
        }

        final statuses = data.users
            .map(readinessForUser)
            .toList(growable: false);
        if (statuses.isEmpty) {
          return _SectionScaffold(
            title: 'Onboarding Report',
            subtitle:
                'Filtered readiness reporting and a print-style handoff sheet',
            onBack: () => context.go(RouteNames.usersDevices),
            child: const _EmptyCollectionState(
              icon: Icons.person_off_outlined,
              title: 'No active onboarding users are available yet',
              body:
                  'Register or restore a local user first, then reopen the onboarding report.',
            ),
          );
        }
        final activeStatuses = statuses
            .where((status) => status.user.status == 'active')
            .toList(growable: false);
        final selectedStatus = statuses.firstWhere(
          (status) => status.user.id == _selectedUserId,
          orElse: () => statuses.first,
        );
        final query = _searchQuery.trim().toLowerCase();
        final filteredStatuses = statuses
            .where((status) {
              final statusLabel = statusLabelFor(status);
              if (_statusFilter != 'all' && statusLabel != _statusFilter) {
                return false;
              }
              if (query.isEmpty) {
                return true;
              }
              final haystack = [
                status.user.displayName,
                status.user.role,
                status.user.title,
                status.user.notes,
                statusLabel,
                ...status.user.permissions,
                ...status.linkedDevices.map((device) => device.name),
                ...status.linkedDevices.map((device) => device.id),
              ].join(' ').toLowerCase();
              return haystack.contains(query);
            })
            .toList(growable: false);
        final blockedCount = statuses
            .where((status) => statusLabelFor(status) == 'blocked')
            .length;
        final archivedCount = statuses
            .where((status) => statusLabelFor(status) == 'archived')
            .length;
        final exceptionOnlyCount = statuses
            .where((status) => statusLabelFor(status) == 'exception-only')
            .length;

        final summaryText = _buildOnboardingReportSummary(
          user: selectedStatus.user,
          hasRoleAndPermissions: selectedStatus.hasRoleAndPermissions,
          hasPrimaryPin: selectedStatus.hasPrimaryPin,
          hasTrustedDevice: selectedStatus.hasTrustedDevice,
          accessReady: selectedStatus.accessReady,
          linkedDevices: selectedStatus.linkedDevices,
          trustedDevices: selectedStatus.trustedDevices,
          recoveryPinCount: selectedStatus.recoveryPinCount,
          latestAudit: selectedStatus.latestAudit,
        );

        return _SectionScaffold(
          title: 'Onboarding Report',
          subtitle:
              'Filtered readiness reporting and a print-style handoff sheet',
          onBack: () => context.go(RouteNames.usersDevices),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionStrip(
                title: 'Report actions',
                subtitle:
                    'Filter the local onboarding picture, then copy or verify one user handoff at a time.',
                actions: [
                  _ActionChip(
                    label: 'Open onboarding',
                    icon: Icons.phonelink_setup_outlined,
                    onPressed: () =>
                        context.go(RouteNames.usersDevicesDeviceOnboarding),
                  ),
                  _ActionChip(
                    label: 'Open audit log',
                    icon: Icons.receipt_long_outlined,
                    onPressed: () =>
                        context.go(RouteNames.usersDevicesAuditLog),
                  ),
                  _ActionChip(
                    label: 'Copy summary',
                    icon: Icons.copy_outlined,
                    onPressed: () => _copyOnboardingReportSummary(
                      context,
                      selectedStatus.user.displayName,
                      summaryText,
                    ),
                  ),
                  _ActionChip(
                    label: 'Export readiness',
                    icon: Icons.file_download_outlined,
                    onPressed: () => _exportReadinessSummary(
                      context: context,
                      ref: ref,
                      snapshot: data,
                      pins: pins,
                      focusedUserId: selectedStatus.user.id,
                      statusFilter: _statusFilter,
                    ),
                  ),
                  _ActionChip(
                    label: 'Readiness PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: () => _exportReadinessSummary(
                      context: context,
                      ref: ref,
                      snapshot: data,
                      pins: pins,
                      focusedUserId: selectedStatus.user.id,
                      statusFilter: _statusFilter,
                      openPdfAfterExport: true,
                    ),
                  ),
                  _ActionChip(
                    label: 'Export review pack',
                    icon: Icons.inventory_2_outlined,
                    onPressed: () => _exportAdminReviewPack(
                      context: context,
                      ref: ref,
                      snapshot: data,
                      pins: pins,
                      focusedUserId: selectedStatus.user.id,
                      statusFilter: _statusFilter,
                    ),
                  ),
                  _ActionChip(
                    label: 'Review pack PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: () => _exportAdminReviewPack(
                      context: context,
                      ref: ref,
                      snapshot: data,
                      pins: pins,
                      focusedUserId: selectedStatus.user.id,
                      statusFilter: _statusFilter,
                      openPdfAfterExport: true,
                    ),
                  ),
                  _ActionChip(
                    label: 'Open exports',
                    icon: Icons.folder_open_outlined,
                    onPressed: () =>
                        _openUsersDevicesExportsFolder(context, ref),
                  ),
                  _ActionChip(
                    label: 'Onboarding pack PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: () => openLocalPdfDocument(
                      context,
                      title: 'Users & Devices Onboarding Pack PDF',
                      pdfPath: _usersDevicesOnboardingPackPdfPath,
                    ),
                  ),
                  _ActionChip(
                    label: 'Recovery drills PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: () => openLocalPdfDocument(
                      context,
                      title: 'Users & Devices Recovery Drills PDF',
                      pdfPath: _usersDevicesRecoveryDrillsPackPdfPath,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SummaryRow(
                items: [
                  (
                    'Ready',
                    activeStatuses.where((status) => status.accessReady).length,
                  ),
                  (
                    'Need role',
                    activeStatuses
                        .where((status) => !status.hasRoleAndPermissions)
                        .length,
                  ),
                  (
                    'Need PIN',
                    activeStatuses
                        .where((status) => !status.hasPrimaryPin)
                        .length,
                  ),
                  (
                    'Need trust',
                    activeStatuses
                        .where((status) => !status.hasTrustedDevice)
                        .length,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Readiness dashboard',
                subtitle:
                    'A broader admin read across active, archived, blocked, and exception-only local onboarding posture.',
                icon: Icons.dashboard_customize_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                      items: [
                        ('Active', activeStatuses.length),
                        ('Blocked', blockedCount),
                        ('Archived', archivedCount),
                        ('Exceptions', exceptionOnlyCount),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.task_alt_outlined,
                            title: 'Ready and active',
                            subtitle:
                                '${activeStatuses.where((status) => status.accessReady).length} user${activeStatuses.where((status) => status.accessReady).length == 1 ? '' : 's'}',
                            body:
                                'These users already have role, PIN, trusted device coverage, and a workable local route.',
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.gpp_bad_outlined,
                            title: 'Blocked trust path',
                            subtitle:
                                '$blockedCount user${blockedCount == 1 ? '' : 's'}',
                            body: blockedCount == 0
                                ? 'No user currently has a blocked or quarantined linked device in report scope.'
                                : 'These users are carrying a blocked or quarantined endpoint and should not be treated as trust-ready.',
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.archive_outlined,
                            title: 'Archived or disabled',
                            subtitle:
                                '$archivedCount user${archivedCount == 1 ? '' : 's'}',
                            body: archivedCount == 0
                                ? 'No archived or disabled users are currently in the local report set.'
                                : 'These records stay visible for local context, but should not be treated as active onboarding work.',
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: _EntityCard(
                            icon: Icons.warning_amber_outlined,
                            title: 'Exception-only follow-up',
                            subtitle:
                                '$exceptionOnlyCount user${exceptionOnlyCount == 1 ? '' : 's'}',
                            body: exceptionOnlyCount == 0
                                ? 'No otherwise-ready user is currently carrying denied, pending, or recovery-only follow-up.'
                                : 'These users look structurally ready, but still have local follow-up signals that deserve a quick review.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PickerSection(
                title: 'Report focus',
                subtitle:
                    'Select one user for the handoff sheet while keeping the admin filter view live below.',
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus.user.id,
                    decoration: const InputDecoration(
                      labelText: 'Selected user for handoff sheet',
                    ),
                    items: [
                      for (final status in statuses)
                        DropdownMenuItem<String>(
                          value: status.user.id,
                          child: Text(
                            '${status.user.displayName} (${status.user.role})',
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUserId = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SearchFilterPanel(
                title: 'Filter onboarding status',
                subtitle:
                    'Search by person, role, linked device, or status to find who needs help first.',
                query: _searchQuery,
                onQueryChanged: (value) => setState(() => _searchQuery = value),
                chips: [
                  _SoftChoiceChip(
                    label: const Text('All'),
                    selected: _statusFilter == 'all',
                    onSelected: (_) => setState(() => _statusFilter = 'all'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Ready'),
                    selected: _statusFilter == 'ready',
                    onSelected: (_) => setState(() => _statusFilter = 'ready'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Need role'),
                    selected: _statusFilter == 'missing-role',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'missing-role'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Need PIN'),
                    selected: _statusFilter == 'missing-pin',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'missing-pin'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Need trust'),
                    selected: _statusFilter == 'missing-trust',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'missing-trust'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Blocked'),
                    selected: _statusFilter == 'blocked',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'blocked'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Archived'),
                    selected: _statusFilter == 'archived',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'archived'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Exceptions'),
                    selected: _statusFilter == 'exception-only',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'exception-only'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Filtered onboarding status',
                subtitle:
                    'This is the admin report view for local user readiness, missing checkpoints, and next support actions.',
                icon: Icons.manage_search_outlined,
                child: filteredStatuses.isEmpty
                    ? const _EmptyCollectionState(
                        icon: Icons.filter_alt_off_outlined,
                        title: 'No users matched the current report filters',
                        body:
                            'Try a broader search or return the status filter to All.',
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final status in filteredStatuses)
                            SizedBox(
                              width: 320,
                              child: _EntityCard(
                                icon: status.accessReady
                                    ? Icons.task_alt_outlined
                                    : Icons.support_agent_outlined,
                                title: status.user.displayName,
                                subtitle:
                                    '${status.user.role} - ${statusLabelFor(status)}',
                                body:
                                    'Linked devices: ${status.linkedDeviceCount} - Trusted devices: ${status.trustedDeviceCount} - Recovery PINs: ${status.recoveryPinCount}',
                                chips: [
                                  _CardChip(label: status.user.status),
                                  _CardChip(
                                    label: status.hasRoleAndPermissions
                                        ? 'Role ready'
                                        : 'Role missing',
                                  ),
                                  _CardChip(
                                    label: status.hasPrimaryPin
                                        ? 'Primary PIN ready'
                                        : 'Primary PIN needed',
                                  ),
                                  _CardChip(
                                    label: status.hasTrustedDevice
                                        ? 'Trusted device ready'
                                        : 'Trusted device needed',
                                  ),
                                  if (status.deniedAuditCount > 0)
                                    _CardChip(
                                      label:
                                          '${status.deniedAuditCount} denied audit${status.deniedAuditCount == 1 ? '' : 's'}',
                                    ),
                                  if (status.pendingAuditCount > 0)
                                    _CardChip(
                                      label:
                                          '${status.pendingAuditCount} pending audit${status.pendingAuditCount == 1 ? '' : 's'}',
                                    ),
                                ],
                                actions: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedUserId = status.user.id;
                                      });
                                    },
                                    icon: const Icon(Icons.visibility_outlined),
                                    label: const Text('Focus sheet'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => context.go(
                                      RouteNames.usersDevicesOnboardingReportFor(
                                        userId: status.user.id,
                                        status: _statusFilter == 'all'
                                            ? null
                                            : _statusFilter,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.open_in_new_outlined,
                                    ),
                                    label: const Text('Open report'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              _VisualPanel(
                title: 'Print-style handoff sheet',
                subtitle:
                    'A calm completion summary for one person that can be copied into the user guide, ops notes, or a printed checklist.',
                icon: Icons.print_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CardChip(label: selectedStatus.user.displayName),
                        _CardChip(label: selectedStatus.user.role),
                        _CardChip(
                          label: selectedStatus.accessReady
                              ? 'Ready to verify locally'
                              : 'Still in progress',
                        ),
                        _CardChip(
                          label: selectedStatus.hasTrustedDevice
                              ? '${selectedStatus.trustedDeviceCount} trusted device${selectedStatus.trustedDeviceCount == 1 ? '' : 's'}'
                              : 'Trusted device missing',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: SelectableText(
                        summaryText,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.45),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => _copyOnboardingReportSummary(
                            context,
                            selectedStatus.user.displayName,
                            summaryText,
                          ),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copy summary'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _exportReadinessSummary(
                            context: context,
                            ref: ref,
                            snapshot: data,
                            pins: pins,
                            focusedUserId: selectedStatus.user.id,
                            statusFilter: _statusFilter,
                          ),
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('Export readiness'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _exportReadinessSummary(
                            context: context,
                            ref: ref,
                            snapshot: data,
                            pins: pins,
                            focusedUserId: selectedStatus.user.id,
                            statusFilter: _statusFilter,
                            openPdfAfterExport: true,
                          ),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Readiness PDF'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _exportAdminReviewPack(
                            context: context,
                            ref: ref,
                            snapshot: data,
                            pins: pins,
                            focusedUserId: selectedStatus.user.id,
                            statusFilter: _statusFilter,
                          ),
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Export review pack'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _exportAdminReviewPack(
                            context: context,
                            ref: ref,
                            snapshot: data,
                            pins: pins,
                            focusedUserId: selectedStatus.user.id,
                            statusFilter: _statusFilter,
                            openPdfAfterExport: true,
                          ),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Review pack PDF'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.go(RouteNames.usersDevicesAuditLog),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Open audit log'),
                        ),
                        OutlinedButton.icon(
                          onPressed: selectedStatus.accessReady
                              ? () => context.go(RouteNames.securityLock)
                              : null,
                          icon: const Icon(Icons.lock_open_outlined),
                          label: const Text('Verify in Security Lock'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UsersDevicesMigrationHealthScreen extends ConsumerWidget {
  const UsersDevicesMigrationHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(usersDevicesControlMigrationHealthProvider);
    return health.when(
      loading: () => const _LoadingScaffold(title: 'Migration Health'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Migration Health',
        message: 'The local migration posture could not be read right now.',
        onRetry: () =>
            ref.invalidate(usersDevicesControlMigrationHealthProvider),
      ),
      data: (data) => _SectionScaffold(
        title: 'Migration Health',
        subtitle: 'SQLite-first support posture for Users & Devices',
        onBack: () => context.go(RouteNames.usersDevices),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ActionStrip(
              title: 'Support actions',
              subtitle:
                  'Use this view when you want one calm read across SQLite, seed files, and support-facing table health.',
              actions: [
                _ActionChip(
                  label: 'Open exports',
                  icon: Icons.folder_open_outlined,
                  onPressed: () => _openUsersDevicesExportsFolder(context, ref),
                ),
                _ActionChip(
                  label: 'Open PIN Registry',
                  icon: Icons.pin_outlined,
                  onPressed: () => context.go(RouteNames.usersDevicesPins),
                ),
                _ActionChip(
                  label: 'Open audit log',
                  icon: Icons.receipt_long_outlined,
                  onPressed: () => context.go(RouteNames.usersDevicesAuditLog),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              items: [
                ('Schema', data.schemaVersion),
                ('Tables', data.tables.length),
                ('Rows', data.totalRows),
                ('Missing seeds', data.missingSeedFileCount),
              ],
            ),
            const SizedBox(height: 16),
            _VisualPanel(
              title: 'SQLite-first posture',
              subtitle:
                  'This view confirms whether the trust layer is living in SQLite and whether the seed fallback still exists for first-run support.',
              icon: Icons.storage_outlined,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 280,
                    child: _EntityCard(
                      icon: Icons.dns_outlined,
                      title: 'Database mode',
                      subtitle: data.usingDatabase
                          ? 'SQLite attached'
                          : 'Fallback-only mode',
                      body: data.usingDatabase
                          ? 'Users & Devices is connected to the local database and can keep trust state inside SQLite.'
                          : 'The repository is not attached to SQLite right now, so support should treat this as a fallback-only state.',
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: _EntityCard(
                      icon: Icons.insert_drive_file_outlined,
                      title: 'Database file',
                      subtitle: data.databaseFileExists
                          ? 'Database file present'
                          : 'Database file missing',
                      body: data.databasePath,
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: _EntityCard(
                      icon: Icons.table_chart_outlined,
                      title: 'Core tables',
                      subtitle:
                          '${data.tables.where((table) => table.exists).length}/${data.tables.length} present',
                      body: data.missingTableCount == 0
                          ? 'All tracked Users & Devices tables are present in the local database.'
                          : '${data.missingTableCount} tracked tables are missing and should be reviewed before deeper support work.',
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: _EntityCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Seed fallback',
                      subtitle:
                          '${data.seedFiles.where((file) => file.exists).length}/${data.seedFiles.length} files present',
                      body: data.missingSeedFileCount == 0
                          ? 'All tracked seed and config files are still available for first-run demo and fallback support.'
                          : '${data.missingSeedFileCount} seed or config files are missing from the tracked local support set.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _VisualPanel(
              title: 'Tracked tables',
              subtitle:
                  'Row counts help confirm whether trust records, approvals, audit entries, and PIN data are living in SQLite as expected.',
              icon: Icons.dataset_outlined,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final table in data.tables)
                    SizedBox(
                      width: 280,
                      child: _EntityCard(
                        icon: table.exists
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        title: table.label,
                        subtitle: table.exists
                            ? '${table.rowCount} row${table.rowCount == 1 ? '' : 's'}'
                            : 'Missing',
                        body: table.tableName,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _VisualPanel(
              title: 'Tracked seed and config files',
              subtitle:
                  'These files stay local and give the module its first-run demo and fallback material.',
              icon: Icons.file_copy_outlined,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final file in data.seedFiles)
                    SizedBox(
                      width: 320,
                      child: _EntityCard(
                        icon: file.exists
                            ? Icons.task_alt_outlined
                            : Icons.warning_amber_outlined,
                        title: file.label,
                        subtitle: file.exists ? 'Present' : 'Missing',
                        body: file.path,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsersDevicesRouteGateScreen extends ConsumerStatefulWidget {
  const UsersDevicesRouteGateScreen({
    super.key,
    required this.child,
    required this.moduleId,
    this.title = 'Users & Devices Access Gate',
    this.subtitle =
        'Confirm local identity and device trust before opening this screen.',
  });

  final Widget child;
  final String moduleId;
  final String title;
  final String subtitle;

  @override
  ConsumerState<UsersDevicesRouteGateScreen> createState() =>
      _UsersDevicesRouteGateScreenState();
}

class _UsersDevicesRouteGateScreenState
    extends ConsumerState<UsersDevicesRouteGateScreen> {
  static String? _rememberedUserId;
  static String? _rememberedDeviceId;

  bool _seededDefaults = false;
  bool _busy = false;
  bool _unlocked = false;
  String _status = 'Locked';
  String _detail = 'Waiting for local verification.';
  String _auditSummary = 'No audit decision recorded yet.';
  String? _latestAuditEventId;
  String? _selectedUserId;
  String? _selectedDeviceId;
  String? _selectedUserLabel;
  String? _selectedUserRole;
  String? _selectedDeviceLabel;
  String? _selectedDeviceStatus;
  int? _selectedDeviceTrustLevel;
  List<String> _blockedHints = const [];

  String get _moduleLabel {
    switch (widget.moduleId) {
      case '01_USERS_AND_DEVICES_CONTROL':
        return 'Users & Devices Control';
      case 'newearth.finance_treasury':
      case '17_FINANCE_AND_TREASURY':
        return 'Finance & Treasury';
      case 'repo_research_engine':
        return 'Repo Research Engine';
      case 'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE':
        return 'Alexa Voice Gateway';
      case 'gaia_voice_assistant':
        return 'GAIA Voice Assistant';
      default:
        return widget.title.replaceAll(' Gate', '');
    }
  }

  String get _moduleFocus {
    switch (widget.moduleId) {
      case '01_USERS_AND_DEVICES_CONTROL':
        return 'Identity, device trust, approval, and audit decisions stay local.';
      case 'newearth.finance_treasury':
      case '17_FINANCE_AND_TREASURY':
        return 'Finance screens stay protected until local identity, role, trust, and audit checks pass.';
      case 'repo_research_engine':
        return 'Repository research stays guarded so evidence and exports remain local and auditable.';
      case 'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE':
        return 'Voice gateway actions stay guarded before anything can reach connected devices.';
      case 'gaia_voice_assistant':
        return 'Voice and AI assistant surfaces stay local, trusted, and recorded in the audit trail.';
      default:
        return 'Sensitive screens stay local, trusted, and recorded in the audit trail.';
    }
  }

  void _seedSelections(UsersDevicesControlSnapshot snapshot) {
    if (_seededDefaults) {
      return;
    }

    final suggestedUser = _bestUserForModule(snapshot, widget.moduleId);

    if (_rememberedUserId != null &&
        snapshot.users.any((user) => user.id == _rememberedUserId)) {
      _selectedUserId = _rememberedUserId;
    } else if (suggestedUser != null) {
      _selectedUserId = suggestedUser.id;
    } else if (snapshot.users.isNotEmpty) {
      _selectedUserId = snapshot.users
          .firstWhere(
            (user) => user.status == 'active',
            orElse: () => snapshot.users.first,
          )
          .id;
    }
    if (_rememberedDeviceId != null &&
        snapshot.devices.any((device) => device.id == _rememberedDeviceId)) {
      _selectedDeviceId = _rememberedDeviceId;
    } else {
      final selectedUser = snapshot.users.firstWhere(
        (user) => user.id == _selectedUserId,
        orElse: () => snapshot.users.first,
      );
      final pairedDevices = _pairedDevicesForUser(
        snapshot.devices,
        selectedUser,
      );
      if (pairedDevices.isNotEmpty) {
        _selectedDeviceId = pairedDevices.first.id;
      } else if (snapshot.devices.isNotEmpty) {
        _selectedDeviceId = snapshot.devices
            .firstWhere(
              (device) => device.status == 'trusted' || device.trustLevel >= 3,
              orElse: () => snapshot.devices.first,
            )
            .id;
      }
    }
    _seededDefaults = true;
  }

  void _selectSuggestedUser(
    UsersDevicesControlSnapshot snapshot,
    UsersDevicesControlUser user,
  ) {
    final pairedDevices = _pairedDevicesForUser(snapshot.devices, user);
    setState(() {
      _selectedUserId = user.id;
      _rememberedUserId = user.id;
      if (pairedDevices.isEmpty) {
        return;
      }

      final currentDeviceMatches = pairedDevices.any(
        (device) => device.id == _selectedDeviceId,
      );
      if (!currentDeviceMatches) {
        _selectedDeviceId = pairedDevices.first.id;
        _rememberedDeviceId = _selectedDeviceId;
      }
    });
  }

  Future<void> _attemptUnlock() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Checking local identity';
      _detail = 'Consulting the local access plan in Users & Devices.';
      _auditSummary = 'Writing audit trail...';
      _latestAuditEventId = null;
      _unlocked = false;
    });

    final repository = ref.read(usersDevicesControlRepositoryProvider);
    final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);
    final userId =
        _selectedUserId ??
        (snapshot.users.isNotEmpty ? snapshot.users.first.id : '');
    final deviceId =
        _selectedDeviceId ??
        (snapshot.devices.isNotEmpty ? snapshot.devices.first.id : '');
    if (userId.isEmpty || deviceId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _status = 'Locked';
        _detail = 'Pick a local user and device before unlocking.';
        _auditSummary =
            'No access check was written because the gate was incomplete.';
        _blockedHints = const [
          'Choose a saved local user from the dropdown.',
          'Choose a trusted local device from the dropdown.',
          'Open Security Lock if the registry still feels incomplete.',
        ];
        _latestAuditEventId = null;
      });
      return;
    }

    final decision = await repository.canOpenModule(
      userId,
      deviceId,
      widget.moduleId,
    );

    if (!mounted) {
      return;
    }

    final updatedSnapshot = await ref.read(
      usersDevicesControlSnapshotProvider.future,
    );
    final unlockedUser = updatedSnapshot.users
        .cast<UsersDevicesControlUser?>()
        .firstWhere((user) => user?.id == userId, orElse: () => null);
    final unlockedDevice = updatedSnapshot.devices
        .cast<UsersDevicesControlDevice?>()
        .firstWhere((device) => device?.id == deviceId, orElse: () => null);
    final latestAudit = updatedSnapshot.auditLog.isNotEmpty
        ? updatedSnapshot.auditLog.last
        : null;
    setState(() {
      _busy = false;
      _unlocked = decision.allowed;
      _status = decision.allowed
          ? 'Unlocked locally'
          : (decision.requiresApproval ? 'Approval needed' : 'Locked');
      _detail = decision.nextStep.isNotEmpty
          ? '${decision.reason} ${decision.nextStep}'
          : decision.reason;
      _latestAuditEventId = latestAudit?.eventId;
      _selectedUserLabel = unlockedUser?.displayName;
      _selectedUserRole = unlockedUser?.role;
      _selectedDeviceLabel = unlockedDevice?.name;
      _selectedDeviceStatus = unlockedDevice?.status;
      _selectedDeviceTrustLevel = unlockedDevice?.trustLevel;
      _auditSummary = latestAudit == null
          ? 'The access check was recorded locally.'
          : '${latestAudit.eventType} - ${latestAudit.result} - ${latestAudit.reason}';
      _blockedHints = decision.allowed
          ? const []
          : _blockedHintsFor(
              reason: decision.reason,
              nextStep: decision.nextStep,
              userId: userId,
              deviceId: deviceId,
              issueCode: decision.issueCode,
              selectedUserRole: unlockedUser?.role ?? '',
              selectedDeviceTrustLevel: unlockedDevice?.trustLevel ?? 0,
              selectedDeviceStatus: unlockedDevice?.status ?? '',
            );
    });
  }

  List<String> _blockedHintsFor({
    required String reason,
    required String nextStep,
    required String userId,
    required String deviceId,
    required String issueCode,
    required String selectedUserRole,
    required int selectedDeviceTrustLevel,
    required String selectedDeviceStatus,
  }) {
    return buildUsersDevicesBlockedHints(
      reason: reason,
      nextStep: nextStep,
      userId: userId,
      deviceId: deviceId,
      issueCode: issueCode,
      selectedUserRole: selectedUserRole,
      selectedDeviceTrustLevel: selectedDeviceTrustLevel,
      selectedDeviceStatus: selectedDeviceStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) {
      if (widget.moduleId == '01_USERS_AND_DEVICES_CONTROL') {
        return widget.child;
      }
      return _ProtectedRouteContextShell(
        moduleLabel: _moduleLabel,
        moduleFocus: _moduleFocus,
        status: _status,
        detail: _detail,
        selectedUserLabel: _selectedUserLabel ?? 'No user selected',
        selectedUserRole: _selectedUserRole ?? 'No role selected',
        selectedDeviceLabel: _selectedDeviceLabel ?? 'No device selected',
        selectedDeviceStatus: _selectedDeviceStatus ?? 'No device selected',
        selectedDeviceTrustLevel: _selectedDeviceTrustLevel ?? 0,
        latestAuditEventId: _latestAuditEventId,
        child: widget.child,
      );
    }

    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Users & Devices access gate could not load the local registry.',
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
      ),
      data: (data) {
        _seedSelections(data);
        final selectedUser = data.users.isEmpty
            ? null
            : (data.users.any((user) => user.id == _selectedUserId)
                  ? data.users.firstWhere((user) => user.id == _selectedUserId)
                  : data.users.first);
        final selectedDevice = data.devices.isEmpty
            ? null
            : (data.devices.any((device) => device.id == _selectedDeviceId)
                  ? data.devices.firstWhere(
                      (device) => device.id == _selectedDeviceId,
                    )
                  : data.devices.first);
        final suggestedUser = _bestUserForModule(
          data,
          widget.moduleId,
          deviceId: selectedDevice?.id,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _VisualPanel(
                              title: widget.title,
                              subtitle: widget.subtitle,
                              icon: Icons.lock_outline,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _Badge(label: _moduleLabel),
                                      const _Badge(label: 'Local gate'),
                                      const _Badge(label: 'Identity checked'),
                                      const _Badge(label: 'Audit required'),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _moduleFocus,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      const _Badge(label: 'Local-first'),
                                      const _Badge(label: 'Identity checked'),
                                      const _Badge(label: 'Trust checked'),
                                      const _Badge(label: 'Audit required'),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Open the screen only after a local user and device pass the module check.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  _SummaryRow(
                                    items: [
                                      ('Users', data.users.length),
                                      ('Devices', data.devices.length),
                                      ('Audit events', data.auditLog.length),
                                      (
                                        'Trusted devices',
                                        data.devices
                                            .where(
                                              (device) =>
                                                  device.trustLevel >= 3,
                                            )
                                            .length,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _Badge(label: _status),
                                      _Badge(
                                        label:
                                            selectedUser?.displayName ??
                                            'No user selected',
                                      ),
                                      _Badge(
                                        label:
                                            selectedDevice?.name ??
                                            'No device selected',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'The selected user must have a matching local PIN and trusted device before this screen opens.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (suggestedUser != null &&
                                suggestedUser.id != selectedUser?.id) ...[
                              const SizedBox(height: 16),
                              _VisualPanel(
                                title: 'Recommended user',
                                subtitle:
                                    'A local identity already satisfies this permission requirement and is paired to a trusted device.',
                                icon: Icons.person_pin_outlined,
                                compact: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _suggestedUserReason(
                                        data: data,
                                        moduleId: widget.moduleId,
                                        user: suggestedUser,
                                        deviceId: selectedDevice?.id,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _Badge(
                                          label: suggestedUser.displayName,
                                        ),
                                        _Badge(label: suggestedUser.role),
                                        _Badge(label: suggestedUser.status),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    FilledButton.tonalIcon(
                                      onPressed: () => _selectSuggestedUser(
                                        data,
                                        suggestedUser,
                                      ),
                                      icon: const Icon(
                                        Icons.switch_account_outlined,
                                      ),
                                      label: const Text('Use suggested user'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _VisualPanel(
                              title: 'Gate check',
                              subtitle:
                                  'Pick the local user and device to verify access.',
                              icon: Icons.verified_user_outlined,
                              compact: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    initialValue: selectedUser?.id,
                                    decoration: const InputDecoration(
                                      labelText: 'User',
                                    ),
                                    items: [
                                      for (final user in data.users)
                                        DropdownMenuItem<String>(
                                          value: user.id,
                                          child: Text(
                                            '${user.displayName} (${user.role})',
                                          ),
                                        ),
                                    ],
                                    onChanged: (value) => setState(() {
                                      _selectedUserId = value;
                                      _rememberedUserId = value;
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    initialValue: selectedDevice?.id,
                                    decoration: const InputDecoration(
                                      labelText: 'Device',
                                    ),
                                    items: [
                                      for (final device in data.devices)
                                        DropdownMenuItem<String>(
                                          value: device.id,
                                          child: Text(
                                            '${device.name} (T${device.trustLevel})',
                                          ),
                                        ),
                                    ],
                                    onChanged: (value) => setState(() {
                                      _selectedDeviceId = value;
                                      _rememberedDeviceId = value;
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      FilledButton(
                                        onPressed: _busy
                                            ? null
                                            : _attemptUnlock,
                                        child: Text(
                                          _busy ? 'Checking...' : 'Open screen',
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () =>
                                            context.go(RouteNames.securityLock),
                                        child: const Text('Open Security Lock'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _latestAuditEventId == null
                                            ? null
                                            : () => context.go(
                                                RouteNames.usersDevicesAuditLogFor(
                                                  _latestAuditEventId!,
                                                ),
                                              ),
                                        icon: const Icon(
                                          Icons.receipt_long_outlined,
                                        ),
                                        label: const Text('Open latest audit'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _seededDefaults = false;
                                            _selectedUserId = null;
                                            _selectedDeviceId = null;
                                            _unlocked = false;
                                            _status = 'Locked';
                                            _detail =
                                                'Waiting for local verification.';
                                            _auditSummary =
                                                'No audit decision recorded yet.';
                                            _blockedHints = const [];
                                            _latestAuditEventId = null;
                                          });
                                        },
                                        child: const Text('Reset selection'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Status: $_status'),
                                  const SizedBox(height: 4),
                                  Text(_detail),
                                  const SizedBox(height: 4),
                                  Text(_auditSummary),
                                  if (_blockedHints.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _VisualPanel(
                                      title: 'Why blocked',
                                      subtitle:
                                          'A short local note on what still needs attention.',
                                      icon: Icons.rule_folder_outlined,
                                      compact: true,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (final hint in _blockedHints)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 6,
                                              ),
                                              child: Text('- $hint'),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (_latestAuditEventId != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Latest audit event: $_latestAuditEventId',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _GatekeeperSnapshotPanel(data: data),
                            const SizedBox(height: 16),
                            _VisualPanel(
                              title: 'Selected access context',
                              subtitle:
                                  'See the active local identity and device before the child route opens.',
                              icon: Icons.person_search_outlined,
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  if (selectedUser != null) ...[
                                    _CardChip(label: selectedUser.displayName),
                                    _CardChip(label: selectedUser.role),
                                    _CardChip(label: selectedUser.status),
                                  ],
                                  if (selectedDevice != null) ...[
                                    _CardChip(label: selectedDevice.name),
                                    _CardChip(
                                      label: 'T${selectedDevice.trustLevel}',
                                    ),
                                    _CardChip(label: selectedDevice.status),
                                  ],
                                  if (_latestAuditEventId != null)
                                    _CardChip(
                                      label: 'Audit: $_latestAuditEventId',
                                    ),
                                ],
                              ),
                            ),
                            if (_latestAuditEventId != null) ...[
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () => context.go(
                                    RouteNames.usersDevicesAuditLogFor(
                                      _latestAuditEventId!,
                                    ),
                                  ),
                                  icon: const Icon(Icons.receipt_long_outlined),
                                  label: const Text('View latest audit'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GatekeeperSnapshotPanel extends StatelessWidget {
  const _GatekeeperSnapshotPanel({required this.data});

  final UsersDevicesControlSnapshot data;

  @override
  Widget build(BuildContext context) {
    final rows = _gatekeeperRows(data);
    final treasuryRule = rows.firstWhere(
      (row) => row.moduleId == 'newearth.finance_treasury',
      orElse: () => rows.first,
    );
    final pendingApprovals = data.approvalQueue
        .where((request) => request.isPending)
        .length;

    return _VisualPanel(
      title: 'Gatekeeper snapshot',
      subtitle:
          'Treasury is the clearest example of the local access plan, with rules and audit state shown together.',
      icon: Icons.fact_check_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CardChip(label: '${data.accessRules.length} module rules'),
              _CardChip(label: '${data.auditLog.length} audit events'),
              _CardChip(label: '$pendingApprovals pending approvals'),
              _CardChip(
                label: 'Treasury trust floor ${treasuryRule.trustFloor}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 54,
                dataRowMaxHeight: 92,
                columns: const [
                  DataColumn(label: Text('Module')),
                  DataColumn(label: Text('Trust floor')),
                  DataColumn(label: Text('View permission')),
                  DataColumn(label: Text('Approvals')),
                  DataColumn(label: Text('Latest audit')),
                ],
                rows: rows
                    .map(
                      (row) => DataRow(
                        cells: [
                          DataCell(
                            SizedBox(width: 240, child: Text(row.label)),
                          ),
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: Text('T${row.trustFloor}'),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text(row.viewPermission),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text(row.approvalSummary),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 320,
                              child: Text(row.latestAuditSummary),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () =>
                    context.go(RouteNames.usersDevicesAccessMatrix),
                icon: const Icon(Icons.grid_view_outlined),
                label: const Text('Open access matrix'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(RouteNames.usersDevicesAuditLog),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Open audit log'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go(RouteNames.usersDevicesApprovalQueue),
                icon: const Icon(Icons.rule_folder_outlined),
                label: const Text('Open approvals'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccessReviewDashboardPanel extends ConsumerWidget {
  const _AccessReviewDashboardPanel({required this.data, required this.pins});

  final UsersDevicesControlSnapshot data;
  final UsersDevicesPinRegistrySnapshot pins;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now().toUtc();
    final activeLockouts = pins.lockouts
        .where(
          (lockout) =>
              lockout.lockedUntil != null && lockout.lockedUntil!.isAfter(now),
        )
        .length;
    final recoveryPins = pins.records
        .where((record) => record.status == 'recovery')
        .length;
    final quarantinedDevices = data.devices
        .where((device) => device.status == 'quarantined')
        .length;
    final pendingApprovals = data.approvalQueue
        .where((request) => request.isPending)
        .length;
    final highRiskPendingApprovals = data.approvalQueue
        .where((request) => request.isPending && request.riskLevel == 'high')
        .length;
    final stalePendingApprovals = data.approvalQueue
        .where(
          (request) => request.isPending && _approvalAgeHours(request) >= 24,
        )
        .length;
    final recentFailedUnlocks = data.auditLog
        .where(
          (event) =>
              event.result == 'denied' &&
              (event.eventType.contains('pin_') ||
                  event.eventType.contains('unlock')),
        )
        .length;

    return _VisualPanel(
      title: 'Access review dashboard',
      subtitle:
          'One calm admin read for lockouts, recovery, quarantine, approvals, and recent denied unlock events.',
      icon: Icons.dashboard_customize_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
            items: [
              ('Lockouts', activeLockouts),
              ('Recovery PINs', recoveryPins),
              ('Quarantined', quarantinedDevices),
              ('Pending approvals', pendingApprovals),
              ('Recent denied unlocks', recentFailedUnlocks),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.lock_clock_outlined,
                  title: 'Session lockouts',
                  subtitle: '$activeLockouts active cooldowns',
                  body: activeLockouts == 0
                      ? 'No user is currently paused by repeated bad PIN attempts.'
                      : 'Open the PIN Registry to review cooldown windows and recovery paths.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.key_outlined,
                  title: 'Recovery coverage',
                  subtitle: '$recoveryPins recovery PINs',
                  body: recoveryPins == 0
                      ? 'No recovery PINs are active right now.'
                      : 'Recovery PINs are available, but should stay secondary to normal unlock.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.shield_moon_outlined,
                  title: 'Device trust pressure',
                  subtitle: '$quarantinedDevices quarantined devices',
                  body: quarantinedDevices == 0
                      ? 'No device is currently paused from trusted use.'
                      : 'Review quarantined devices before troubleshooting module access.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.rule_folder_outlined,
                  title: 'Approval workload',
                  subtitle:
                      '$pendingApprovals pending - $highRiskPendingApprovals high risk',
                  body: pendingApprovals == 0
                      ? 'No approval review is waiting.'
                      : stalePendingApprovals == 0
                      ? 'Open the queue to review the highest-risk requests first.'
                      : 'Open the queue to review the highest-risk requests first and recheck stale context.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VisualPanel(
            title: 'Review pressure points',
            subtitle:
                'Use this to jump straight to the part of the trust system creating the most friction.',
            icon: Icons.insights_outlined,
            compact: true,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CardChip(
                  label: highRiskPendingApprovals == 0
                      ? 'High-risk queue calm'
                      : 'High-risk pending: $highRiskPendingApprovals',
                ),
                _CardChip(
                  label: stalePendingApprovals == 0
                      ? 'No stale approvals'
                      : 'Stale approvals: $stalePendingApprovals',
                ),
                _CardChip(
                  label: recentFailedUnlocks == 0
                      ? 'Denied unlocks calm'
                      : 'Denied unlocks: $recentFailedUnlocks',
                ),
                _CardChip(
                  label: quarantinedDevices == 0
                      ? 'Trust pressure low'
                      : 'Quarantine follow-up: $quarantinedDevices',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () =>
                    context.go(RouteNames.usersDevicesApprovalQueue),
                icon: const Icon(Icons.rule_folder_outlined),
                label: const Text('Open approval queue'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(RouteNames.usersDevicesPins),
                icon: const Icon(Icons.pin_outlined),
                label: const Text('Open PIN Registry'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(RouteNames.usersDevicesDevices),
                icon: const Icon(Icons.devices_outlined),
                label: const Text('Open Devices'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(RouteNames.usersDevicesAuditLog),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Open audit log'),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportIncidentSummary(
                  context: context,
                  ref: ref,
                  snapshot: data,
                  resultFilter: 'all',
                  query: '',
                ),
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Export incident'),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportAdminReviewPack(
                  context: context,
                  ref: ref,
                  snapshot: data,
                  pins: pins,
                ),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Export review pack'),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportAdminReviewPack(
                  context: context,
                  ref: ref,
                  snapshot: data,
                  pins: pins,
                  openPdfAfterExport: true,
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Review pack PDF'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<_GatekeeperModuleRow> _gatekeeperRows(UsersDevicesControlSnapshot data) {
  final auditIndex = <String, UsersDevicesControlAuditEvent>{};
  for (final event in data.auditLog) {
    final current = auditIndex[event.targetModule];
    if (current == null || event.timestamp.compareTo(current.timestamp) >= 0) {
      auditIndex[event.targetModule] = event;
    }
  }

  final approvalCounts = <String, int>{};
  for (final request in data.approvalQueue) {
    if (request.isPending) {
      approvalCounts[request.targetModule] =
          (approvalCounts[request.targetModule] ?? 0) + 1;
    }
  }

  const orderedModules = <String>[
    '17_FINANCE_AND_TREASURY',
    'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE',
    'gaia_voice_assistant',
    'repo_research_engine',
  ];

  return orderedModules
      .map((moduleId) {
        final rule = data.accessRules.firstWhere(
          (item) => item.moduleId == moduleId,
          orElse: () => const UsersDevicesControlAccessRule(
            moduleId: '',
            requiresTrustLevel: 0,
            requiresApprovalFor: [],
          ),
        );
        return _GatekeeperModuleRow(
          moduleId: moduleId,
          label: _gatekeeperModuleLabel(moduleId),
          trustFloor: rule.requiresTrustLevel,
          viewPermission: rule.viewPermission.isEmpty
              ? 'Not set'
              : rule.viewPermission,
          approvalSummary: rule.requiresApprovalFor.isEmpty
              ? '${approvalCounts[moduleId] ?? 0} pending'
              : '${rule.requiresApprovalFor.length} gated action${rule.requiresApprovalFor.length == 1 ? '' : 's'}',
          latestAuditSummary: _gatekeeperAuditSummary(auditIndex[moduleId]),
        );
      })
      .toList(growable: false);
}

String _gatekeeperModuleLabel(String moduleId) {
  switch (moduleId) {
    case '17_FINANCE_AND_TREASURY':
      return 'Treasury';
    case 'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE':
      return 'Alexa Voice Gateway';
    case 'gaia_voice_assistant':
      return 'GAIA Voice Assistant';
    case 'repo_research_engine':
      return 'Repo Research Engine';
    default:
      return moduleId;
  }
}

String _gatekeeperAuditSummary(UsersDevicesControlAuditEvent? event) {
  if (event == null) {
    return 'No audit yet';
  }
  return '${event.result} - ${event.reason}';
}

UsersDevicesControlUser? _bestUserForModule(
  UsersDevicesControlSnapshot data,
  String moduleId, {
  String? deviceId,
  String action = 'view',
}) {
  final rule = data.accessRules.firstWhere(
    (item) => item.moduleId == moduleId,
    orElse: () => const UsersDevicesControlAccessRule(
      moduleId: '',
      requiresTrustLevel: 0,
      requiresApprovalFor: [],
    ),
  );
  final requiredPermission = _requiredPermissionForAction(rule, action);
  if (requiredPermission.isEmpty || data.users.isEmpty) {
    return null;
  }

  final candidates = <UsersDevicesControlUser>[];
  for (final user in data.users) {
    if (user.status != 'active') {
      continue;
    }
    if (!_userHasRequiredPermission(data, user, requiredPermission)) {
      continue;
    }
    if (deviceId != null && deviceId.isNotEmpty) {
      final pairedDevices = _pairedDevicesForUser(data.devices, user);
      if (pairedDevices.isEmpty ||
          !pairedDevices.any((device) => device.id == deviceId)) {
        continue;
      }
    }
    candidates.add(user);
  }

  if (candidates.isEmpty) {
    return null;
  }

  candidates.sort(
    (left, right) => _userSuggestionScore(
      data,
      right,
      requiredPermission,
    ).compareTo(_userSuggestionScore(data, left, requiredPermission)),
  );
  return candidates.first;
}

String _suggestedUserReason({
  required UsersDevicesControlSnapshot data,
  required String moduleId,
  required UsersDevicesControlUser user,
  String? deviceId,
  String action = 'view',
}) {
  final rule = data.accessRules.firstWhere(
    (item) => item.moduleId == moduleId,
    orElse: () => const UsersDevicesControlAccessRule(
      moduleId: '',
      requiresTrustLevel: 0,
      requiresApprovalFor: [],
    ),
  );
  final requiredPermission = _requiredPermissionForAction(rule, action);
  final hasWildcard = _effectivePermissionsForUser(data, user).contains('*');
  final pairedDevices = _pairedDevicesForUser(data.devices, user);
  final pairedDeviceLabel = pairedDevices.isEmpty
      ? 'a paired device'
      : pairedDevices.first.name;
  final selectedDeviceLabel = deviceId != null && deviceId.isNotEmpty
      ? data.devices.any((device) => device.id == deviceId)
            ? data.devices.firstWhere((device) => device.id == deviceId).name
            : 'the selected device'
      : 'the selected device';

  if (hasWildcard) {
    return '${user.displayName} already has owner-level access, so this is the fastest local match for this screen with $pairedDeviceLabel.';
  }

  if (requiredPermission.isEmpty) {
    return '${user.displayName} is already the strongest local match for this screen.';
  }

  return '${user.displayName} already satisfies $requiredPermission and can use $pairedDeviceLabel instead of $selectedDeviceLabel.';
}

List<UsersDevicesControlDevice> _pairedDevicesForUser(
  List<UsersDevicesControlDevice> devices,
  UsersDevicesControlUser user,
) {
  return devices
      .where(
        (device) =>
            user.linkedDevices.contains(device.id) || device.ownerId == user.id,
      )
      .toList(growable: false);
}

Set<String> _effectivePermissionsForUser(
  UsersDevicesControlSnapshot data,
  UsersDevicesControlUser user,
) {
  final permissions = <String>{...user.permissions};
  for (final role in data.roles) {
    if (role.role.toLowerCase() == user.role.toLowerCase()) {
      permissions.addAll(role.permissions);
      break;
    }
  }
  return permissions;
}

bool _userHasRequiredPermission(
  UsersDevicesControlSnapshot data,
  UsersDevicesControlUser user,
  String requiredPermission,
) {
  if (requiredPermission.isEmpty) {
    return true;
  }

  final permissions = _effectivePermissionsForUser(data, user);
  return permissions.contains('*') || permissions.contains(requiredPermission);
}

String _requiredPermissionForAction(
  UsersDevicesControlAccessRule? rule,
  String action,
) {
  switch (action) {
    case 'view':
      return rule?.viewPermission ?? '';
    case 'edit':
      return rule?.editPermission ?? '';
    case 'admin':
      return rule?.adminPermission ?? '';
    case 'request_action':
    case 'request':
      return rule?.requestPermission ?? '';
    case 'execute':
    case 'execute_system_action':
      return rule?.executePermission ?? '';
    case 'control':
      return rule?.controlPermission ?? '';
    default:
      return rule?.viewPermission ?? '';
  }
}

int _userSuggestionScore(
  UsersDevicesControlSnapshot data,
  UsersDevicesControlUser user,
  String requiredPermission,
) {
  final permissions = _effectivePermissionsForUser(data, user);
  var score = permissions.length;
  if (permissions.contains('*')) {
    score += 1000;
  }
  if (permissions.contains(requiredPermission)) {
    score += 300;
  }
  final role = user.role.toLowerCase();
  if (role.contains('owner')) {
    score += 200;
  }
  if (role.contains('admin')) {
    score += 150;
  }
  if (user.status == 'active') {
    score += 100;
  }
  if (user.linkedDevices.isNotEmpty) {
    score += 25;
  }
  return score;
}

class _GatekeeperModuleRow {
  const _GatekeeperModuleRow({
    required this.moduleId,
    required this.label,
    required this.trustFloor,
    required this.viewPermission,
    required this.approvalSummary,
    required this.latestAuditSummary,
  });

  final String moduleId;
  final String label;
  final int trustFloor;
  final String viewPermission;
  final String approvalSummary;
  final String latestAuditSummary;
}

class UsersDevicesApprovalQueueScreen extends ConsumerStatefulWidget {
  const UsersDevicesApprovalQueueScreen({super.key});

  @override
  ConsumerState<UsersDevicesApprovalQueueScreen> createState() =>
      _UsersDevicesApprovalQueueScreenState();
}

class _UsersDevicesApprovalQueueScreenState
    extends ConsumerState<UsersDevicesApprovalQueueScreen> {
  String _query = '';
  String _statusFilter = 'pending';
  String _focusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Approval Queue'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Approval Queue',
        message: 'The approval queue could not be loaded right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) {
        final pendingCount = data.approvalQueue
            .where((request) => request.isPending)
            .length;
        final approvedCount = data.approvalQueue
            .where((request) => request.isApproved)
            .length;
        final deniedCount = data.approvalQueue
            .where((request) => request.isDenied)
            .length;
        final filteredRequests = data.approvalQueue
            .where((request) {
              if (_statusFilter != 'all' &&
                  request.normalizedStatus != _statusFilter) {
                return false;
              }
              if (!_approvalMatchesFocusFilter(data, request, _focusFilter)) {
                return false;
              }
              final query = _query.trim().toLowerCase();
              if (query.isEmpty) {
                return true;
              }
              final haystack = [
                request.requestId,
                request.requestedBy,
                request.deviceId,
                request.targetModule,
                request.action,
                request.normalizedStatus,
                request.riskLevel,
                request.reason,
                request.reviewedBy ?? '',
                request.reviewedAt ?? '',
              ].join(' ').toLowerCase();
              return haystack.contains(query);
            })
            .toList(growable: false);

        return _SectionScaffold(
          title: 'Approval Queue',
          subtitle: 'Review actions that need a second look',
          onBack: () => context.go(RouteNames.usersDevices),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionStrip(
                title: 'Review flow',
                subtitle:
                    'Approve or deny pending requests while the audit trail updates.',
                actions: [
                  _ActionChip(
                    label: 'Create sample approval',
                    icon: Icons.rule_folder_outlined,
                    onPressed: () => _createSampleApproval(context, ref),
                  ),
                  _ActionChip(
                    label: 'Approve next',
                    icon: Icons.check_circle_outline,
                    onPressed: pendingCount == 0
                        ? null
                        : () => _reviewFirstPendingApproval(
                            context,
                            ref,
                            approve: true,
                          ),
                  ),
                  _ActionChip(
                    label: 'Deny next',
                    icon: Icons.block_outlined,
                    onPressed: pendingCount == 0
                        ? null
                        : () => _reviewFirstPendingApproval(
                            context,
                            ref,
                            approve: false,
                          ),
                  ),
                  _ActionChip(
                    label: 'Open matrix',
                    icon: Icons.grid_view_outlined,
                    onPressed: () =>
                        context.go(RouteNames.usersDevicesAccessMatrix),
                  ),
                  _ActionChip(
                    label: 'Open audit log',
                    icon: Icons.receipt_long_outlined,
                    onPressed: () =>
                        context.go(RouteNames.usersDevicesAuditLog),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ApprovalQueueSnapshotPanel(data: data),
              const SizedBox(height: 16),
              _ApprovalTriagePanel(data: data),
              const SizedBox(height: 16),
              _SummaryRow(
                items: [
                  ('All', data.approvalQueue.length),
                  ('Pending', pendingCount),
                  ('Approved', approvedCount),
                  ('Denied', deniedCount),
                ],
              ),
              const SizedBox(height: 16),
              _SearchFilterPanel(
                title: 'Search approvals',
                subtitle:
                    'Search by requester, device, module, action, reason, or risk.',
                query: _query,
                onQueryChanged: (value) => setState(() => _query = value),
                chips: [
                  _SoftChoiceChip(
                    label: const Text('Pending'),
                    selected: _statusFilter == 'pending',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'pending'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('All'),
                    selected: _statusFilter == 'all',
                    onSelected: (_) => setState(() => _statusFilter = 'all'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Approved'),
                    selected: _statusFilter == 'approved',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'approved'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Denied'),
                    selected: _statusFilter == 'denied',
                    onSelected: (_) => setState(() => _statusFilter = 'denied'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _VisualPanel(
                title: 'Review focus',
                subtitle:
                    'Use one narrow lens when you want the queue to answer a very specific support question fast.',
                icon: Icons.filter_list_outlined,
                compact: true,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SoftChoiceChip(
                      label: const Text('All focus'),
                      selected: _focusFilter == 'all',
                      onSelected: (_) => setState(() => _focusFilter = 'all'),
                    ),
                    _SoftChoiceChip(
                      label: const Text('Trust-blocked'),
                      selected: _focusFilter == 'trust-blocked',
                      onSelected: (_) =>
                          setState(() => _focusFilter = 'trust-blocked'),
                    ),
                    _SoftChoiceChip(
                      label: const Text('Matrix review'),
                      selected: _focusFilter == 'matrix-review',
                      onSelected: (_) =>
                          setState(() => _focusFilter = 'matrix-review'),
                    ),
                    _SoftChoiceChip(
                      label: const Text('Stale only'),
                      selected: _focusFilter == 'stale',
                      onSelected: (_) => setState(() => _focusFilter = 'stale'),
                    ),
                    _SoftChoiceChip(
                      label: const Text('High risk'),
                      selected: _focusFilter == 'high-risk',
                      onSelected: (_) =>
                          setState(() => _focusFilter = 'high-risk'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (filteredRequests.isEmpty)
                _EmptyCollectionState(
                  icon: Icons.rule_folder_outlined,
                  title: 'No approvals matched the current filters',
                  body:
                      'Try switching the status chip or widening the search query.',
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final request in filteredRequests)
                      SizedBox(
                        width: 450,
                        child: _ApprovalRequestCard(
                          data: data,
                          request: request,
                          onApprove: request.isPending
                              ? () async {
                                  await ref
                                      .read(
                                        usersDevicesControlRepositoryProvider,
                                      )
                                      .approveRequest(
                                        request.requestId,
                                        reviewedBy: 'user_peter_owner',
                                      );
                                  ref.invalidate(
                                    usersDevicesControlSnapshotProvider,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Request approved.'),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          onDeny: request.isPending
                              ? () async {
                                  await ref
                                      .read(
                                        usersDevicesControlRepositoryProvider,
                                      )
                                      .denyRequest(
                                        request.requestId,
                                        reviewedBy: 'user_peter_owner',
                                      );
                                  ref.invalidate(
                                    usersDevicesControlSnapshotProvider,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Request denied.'),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          onOpenAuditLog: () =>
                              context.go(RouteNames.usersDevicesAuditLog),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ApprovalQueueSnapshotPanel extends StatelessWidget {
  const _ApprovalQueueSnapshotPanel({required this.data});

  final UsersDevicesControlSnapshot data;

  @override
  Widget build(BuildContext context) {
    final pendingByModule = <String, int>{};
    for (final request in data.approvalQueue) {
      if (request.isPending) {
        pendingByModule[request.targetModule] =
            (pendingByModule[request.targetModule] ?? 0) + 1;
      }
    }
    final topModules = pendingByModule.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final topModule = topModules.isEmpty ? null : topModules.first;

    return _VisualPanel(
      title: 'Queue posture',
      subtitle:
          'Pending requests are easier to scan when the module mix and status pressure are shown first.',
      icon: Icons.rule_folder_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CardChip(label: '${data.approvalQueue.length} total requests'),
              _CardChip(
                label:
                    '${pendingByModule.values.fold<int>(0, (a, b) => a + b)} pending',
              ),
              if (topModule != null)
                _CardChip(
                  label: 'Top module: ${_approvalModuleLabel(topModule.key)}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 54,
                dataRowMaxHeight: 88,
                columns: const [
                  DataColumn(label: Text('Module')),
                  DataColumn(label: Text('Pending')),
                  DataColumn(label: Text('Status mix')),
                ],
                rows: pendingByModule.entries.isEmpty
                    ? [
                        const DataRow(
                          cells: [
                            DataCell(Text('No pending approvals')),
                            DataCell(Text('-')),
                            DataCell(Text('-')),
                          ],
                        ),
                      ]
                    : pendingByModule.entries
                          .map(
                            (entry) => DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 250,
                                    child: Text(
                                      _approvalModuleLabel(entry.key),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Text(entry.value.toString()),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 240,
                                    child: Text(
                                      _approvalStatusMix(
                                        data.approvalQueue,
                                        entry.key,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(growable: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalTriagePanel extends StatelessWidget {
  const _ApprovalTriagePanel({required this.data});

  final UsersDevicesControlSnapshot data;

  @override
  Widget build(BuildContext context) {
    final pendingRequests = data.approvalQueue
        .where((request) => request.isPending)
        .toList(growable: false);
    final highRiskPending = pendingRequests
        .where((request) => request.riskLevel == 'high')
        .length;
    final stalePending = pendingRequests
        .where((request) => _approvalAgeHours(request) >= 24)
        .length;
    final trustBlockedPending = pendingRequests
        .where((request) => _approvalHasTrustBlocker(data, request))
        .length;
    final matrixCheckPending = pendingRequests
        .where((request) => _approvalNeedsMatrixReview(data, request))
        .length;
    final modulePressure = _approvalModulePressureRows(data);

    return _VisualPanel(
      title: 'Triage view',
      subtitle:
          'See which approvals are urgent, stale, or blocked by a deeper issue before you review them one by one.',
      icon: Icons.support_agent_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.priority_high_outlined,
                  title: 'High-risk waiting',
                  subtitle:
                      '$highRiskPending request${highRiskPending == 1 ? '' : 's'}',
                  body: highRiskPending == 0
                      ? 'No high-risk requests are currently waiting.'
                      : 'Review the highest-risk requests first so sensitive actions do not sit in limbo.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.timelapse_outlined,
                  title: 'Stale requests',
                  subtitle: '$stalePending older than 24h',
                  body: stalePending == 0
                      ? 'No pending request has gone stale yet. Local v1 does not auto-expire approvals.'
                      : 'These requests have been waiting long enough that the original context should be rechecked.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.shield_moon_outlined,
                  title: 'Trust blockers',
                  subtitle:
                      '$trustBlockedPending request${trustBlockedPending == 1 ? '' : 's'}',
                  body: trustBlockedPending == 0
                      ? 'No pending request is blocked by a risky device right now.'
                      : 'Open Devices before approving these requests so trust posture is fixed first.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.grid_view_outlined,
                  title: 'Matrix check',
                  subtitle:
                      '$matrixCheckPending request${matrixCheckPending == 1 ? '' : 's'}',
                  body: matrixCheckPending == 0
                      ? 'No pending request currently points at a missing or outdated access rule.'
                      : 'Review the Access Matrix before approving these requests.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.rule_folder_outlined,
                  title: 'Module spread',
                  subtitle:
                      '${pendingRequests.map((request) => request.targetModule).toSet().length} module${pendingRequests.map((request) => request.targetModule).toSet().length == 1 ? '' : 's'} involved',
                  body: pendingRequests.isEmpty
                      ? 'The queue is clear right now.'
                      : 'Use the module mix below to decide whether one area needs a focused review sweep.',
                ),
              ),
            ],
          ),
          if (modulePressure.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Module pressure board',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final row in modulePressure.take(3))
                  SizedBox(
                    width: 320,
                    child: _EntityCard(
                      icon: Icons.hub_outlined,
                      title: _approvalModuleLabel(row.moduleId),
                      subtitle:
                          '${row.pendingCount} pending - ${row.highRiskCount} high risk',
                      body:
                          '${row.staleCount} stale, ${row.trustBlockedCount} trust-blocked, ${row.matrixCheckCount} need matrix review.',
                    ),
                  ),
              ],
            ),
          ],
          if (pendingRequests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Requests needing attention first',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final request in _prioritizedApprovalRequests(
                  data,
                ).take(3))
                  SizedBox(
                    width: 320,
                    child: _EntityCard(
                      icon: Icons.fact_check_outlined,
                      title: _approvalModuleLabel(request.targetModule),
                      subtitle: '${request.action} - ${request.riskLevel} risk',
                      body: _approvalPrerequisiteHint(data, request),
                      chips: [
                        _CardChip(label: 'Age ${_approvalAgeLabel(request)}'),
                        _CardChip(label: 'Requester ${request.requestedBy}'),
                      ],
                      actions: [
                        if (_approvalHasTrustBlocker(data, request))
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.go(RouteNames.usersDevicesDevices),
                            icon: const Icon(Icons.devices_outlined),
                            label: const Text('Open Devices'),
                          ),
                        if (_approvalNeedsMatrixReview(data, request))
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.go(RouteNames.usersDevicesAccessMatrix),
                            icon: const Icon(Icons.grid_view_outlined),
                            label: const Text('Open matrix'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.go(RouteNames.usersDevicesAuditLog),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Open audit'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _approvalModuleLabel(String moduleId) {
  switch (moduleId) {
    case '01_USERS_AND_DEVICES_CONTROL':
      return 'Users & Devices Control';
    case '17_FINANCE_AND_TREASURY':
      return 'Treasury';
    case 'repo_research_engine':
      return 'Repo Research Engine';
    case 'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE':
      return 'Alexa Voice Gateway';
    case 'gaia_voice_assistant':
      return 'GAIA Voice Assistant';
    default:
      return moduleId;
  }
}

String _approvalStatusMix(
  List<UsersDevicesControlApprovalRequest> requests,
  String moduleId,
) {
  final matches = requests.where((request) => request.targetModule == moduleId);
  final pending = matches.where((request) => request.isPending).length;
  final approved = matches.where((request) => request.isApproved).length;
  final denied = matches.where((request) => request.isDenied).length;
  return '$pending pending, $approved approved, $denied denied';
}

List<UsersDevicesControlApprovalRequest> _prioritizedApprovalRequests(
  UsersDevicesControlSnapshot data,
) {
  final requests = data.approvalQueue
      .where((request) => request.isPending)
      .toList(growable: false);
  requests.sort((left, right) {
    final riskCompare = _approvalRiskScore(
      right.riskLevel,
    ).compareTo(_approvalRiskScore(left.riskLevel));
    if (riskCompare != 0) {
      return riskCompare;
    }
    return _approvalAgeHours(right).compareTo(_approvalAgeHours(left));
  });
  return requests;
}

int _approvalRiskScore(String riskLevel) {
  switch (riskLevel.trim().toLowerCase()) {
    case 'high':
      return 3;
    case 'medium':
      return 2;
    default:
      return 1;
  }
}

int _approvalAgeHours(UsersDevicesControlApprovalRequest request) {
  final createdAt = DateTime.tryParse(request.timestamp)?.toUtc();
  if (createdAt == null) {
    return 0;
  }
  return DateTime.now().toUtc().difference(createdAt).inHours;
}

String _approvalAgeLabel(UsersDevicesControlApprovalRequest request) {
  final hours = _approvalAgeHours(request);
  if (hours < 1) {
    return '<1h';
  }
  if (hours < 24) {
    return '${hours}h';
  }
  final days = (hours / 24).floor();
  return '${days}d';
}

bool _approvalMatchesFocusFilter(
  UsersDevicesControlSnapshot data,
  UsersDevicesControlApprovalRequest request,
  String focusFilter,
) {
  switch (focusFilter) {
    case 'trust-blocked':
      return _approvalHasTrustBlocker(data, request);
    case 'matrix-review':
      return _approvalNeedsMatrixReview(data, request);
    case 'stale':
      return _approvalAgeHours(request) >= 24;
    case 'high-risk':
      return request.riskLevel.trim().toLowerCase() == 'high';
    default:
      return true;
  }
}

String _approvalPrerequisiteHint(
  UsersDevicesControlSnapshot data,
  UsersDevicesControlApprovalRequest request,
) {
  final requester = data.users.where((user) => user.id == request.requestedBy);
  final device = data.devices.where((item) => item.id == request.deviceId);
  final matchingRule = data.accessRules.where(
    (rule) => rule.moduleId == request.targetModule,
  );
  final user = requester.isEmpty ? null : requester.first;
  final deviceMatch = device.isEmpty ? null : device.first;
  final rule = matchingRule.isEmpty ? null : matchingRule.first;

  if (user == null) {
    return 'Requester is no longer present in the local user registry. Review identity first.';
  }
  if (deviceMatch == null) {
    return 'The linked device is missing from the local registry. Reconfirm the endpoint before approval.';
  }
  if (deviceMatch.status == 'quarantined') {
    return 'This device is quarantined. Restore or replace the device before approving the action.';
  }
  if (deviceMatch.status == 'blocked' || deviceMatch.status == 'archived') {
    return 'The device is not in an active trust state. Fix trust posture before approving.';
  }
  if (rule == null) {
    return 'No matching module rule exists right now. Review the Access Matrix before approving.';
  }
  if (!rule.requiresApprovalFor.contains(request.action)) {
    return 'This action no longer appears in the module approval rule. Sanity-check whether approval is still needed.';
  }
  if (deviceMatch.trustLevel < rule.requiresTrustLevel) {
    return 'The device still sits below this module trust floor. Raise trust or switch device before approval.';
  }
  return 'Prerequisites look healthy. This request mainly needs an operator decision and audit follow-through.';
}

bool _approvalHasTrustBlocker(
  UsersDevicesControlSnapshot data,
  UsersDevicesControlApprovalRequest request,
) {
  final device = data.devices.where((item) => item.id == request.deviceId);
  final rule = data.accessRules.where(
    (entry) => entry.moduleId == request.targetModule,
  );
  final deviceMatch = device.isEmpty ? null : device.first;
  final matchingRule = rule.isEmpty ? null : rule.first;
  if (deviceMatch == null) {
    return false;
  }
  if (deviceMatch.status == 'quarantined' ||
      deviceMatch.status == 'blocked' ||
      deviceMatch.status == 'archived') {
    return true;
  }
  if (matchingRule == null) {
    return false;
  }
  return deviceMatch.trustLevel < matchingRule.requiresTrustLevel;
}

bool _approvalNeedsMatrixReview(
  UsersDevicesControlSnapshot data,
  UsersDevicesControlApprovalRequest request,
) {
  final matchingRule = data.accessRules.where(
    (rule) => rule.moduleId == request.targetModule,
  );
  if (matchingRule.isEmpty) {
    return true;
  }
  return !matchingRule.first.requiresApprovalFor.contains(request.action);
}

class _ApprovalModulePressureRow {
  const _ApprovalModulePressureRow({
    required this.moduleId,
    required this.pendingCount,
    required this.highRiskCount,
    required this.staleCount,
    required this.trustBlockedCount,
    required this.matrixCheckCount,
  });

  final String moduleId;
  final int pendingCount;
  final int highRiskCount;
  final int staleCount;
  final int trustBlockedCount;
  final int matrixCheckCount;
}

List<_ApprovalModulePressureRow> _approvalModulePressureRows(
  UsersDevicesControlSnapshot data,
) {
  final grouped = <String, List<UsersDevicesControlApprovalRequest>>{};
  for (final request in data.approvalQueue.where((entry) => entry.isPending)) {
    grouped.putIfAbsent(request.targetModule, () => []).add(request);
  }

  final rows = grouped.entries
      .map((entry) {
        final requests = entry.value;
        return _ApprovalModulePressureRow(
          moduleId: entry.key,
          pendingCount: requests.length,
          highRiskCount: requests
              .where((item) => item.riskLevel == 'high')
              .length,
          staleCount: requests
              .where((item) => _approvalAgeHours(item) >= 24)
              .length,
          trustBlockedCount: requests
              .where((item) => _approvalHasTrustBlocker(data, item))
              .length,
          matrixCheckCount: requests
              .where((item) => _approvalNeedsMatrixReview(data, item))
              .length,
        );
      })
      .toList(growable: false);

  rows.sort((left, right) {
    final rightScore =
        right.highRiskCount * 5 +
        right.trustBlockedCount * 4 +
        right.staleCount * 3 +
        right.matrixCheckCount * 2 +
        right.pendingCount;
    final leftScore =
        left.highRiskCount * 5 +
        left.trustBlockedCount * 4 +
        left.staleCount * 3 +
        left.matrixCheckCount * 2 +
        left.pendingCount;
    return rightScore.compareTo(leftScore);
  });
  return rows;
}

String _auditActionFamily(UsersDevicesControlAuditEvent event) {
  final eventType = event.eventType.toLowerCase();
  final action = event.action.toLowerCase();

  if (eventType.contains('pin_') || action.contains('pin')) {
    return 'PIN governance';
  }
  if (eventType.contains('unlock') || action.contains('unlock')) {
    return 'Unlock flow';
  }
  if (eventType.contains('approval') || action.contains('approve')) {
    return 'Approval flow';
  }
  if (eventType.contains('trust') || action.contains('trust')) {
    return 'Device trust';
  }
  if (eventType.contains('role') || action.contains('role')) {
    return 'Role assignment';
  }
  if (eventType.contains('permission') || action.contains('permission')) {
    return 'Permission update';
  }
  if (eventType.contains('device') || action.contains('device')) {
    return 'Device lifecycle';
  }
  if (eventType.contains('module_access') || action.contains('open_')) {
    return 'Module access';
  }
  return 'General audit';
}

class UsersDevicesAuditLogScreen extends ConsumerStatefulWidget {
  const UsersDevicesAuditLogScreen({super.key, this.highlightEventId});

  final String? highlightEventId;

  @override
  ConsumerState<UsersDevicesAuditLogScreen> createState() =>
      _UsersDevicesAuditLogScreenState();
}

class _UsersDevicesAuditLogScreenState
    extends ConsumerState<UsersDevicesAuditLogScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _highlightKey = GlobalKey();
  bool _didScrollToHighlight = false;
  String _query = '';
  String _resultFilter = 'all';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightEventId = widget.highlightEventId;
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    final pinsSnapshot = ref.watch(usersDevicesPinRegistrySnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Audit Log'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Audit Log',
        message: 'The audit log could not be loaded right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) => _SectionScaffold(
        title: 'Audit Log',
        subtitle: 'Every sensitive access decision leaves a trail',
        onBack: () => context.go(RouteNames.usersDevices),
        scrollController: _scrollController,
        onBuilt: _scheduleHighlightScroll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlightEventId != null &&
                data.auditLog.any((event) => event.eventId == highlightEventId))
              _HighlightedAuditBanner(
                key: _highlightKey,
                event: data.auditLog.firstWhere(
                  (event) => event.eventId == highlightEventId,
                ),
                sourceLabel: 'From Security Lock',
              ),
            if (highlightEventId != null &&
                data.auditLog.any((event) => event.eventId == highlightEventId))
              const SizedBox(height: 16),
            _SummaryRow(
              items: [
                ('Events', data.auditLog.length),
                (
                  'Allowed',
                  data.auditLog
                      .where((event) => event.result == 'allowed')
                      .length,
                ),
                (
                  'Denied',
                  data.auditLog
                      .where((event) => event.result == 'denied')
                      .length,
                ),
                (
                  'Pending',
                  data.auditLog
                      .where((event) => event.result == 'pending')
                      .length,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActionStrip(
              title: 'Audit actions',
              subtitle:
                  'Export a calmer local incident summary before diving into individual events.',
              actions: [
                _ActionChip(
                  label: 'Export incident',
                  icon: Icons.file_download_outlined,
                  onPressed: () => _exportIncidentSummary(
                    context: context,
                    ref: ref,
                    snapshot: data,
                    resultFilter: _resultFilter,
                    query: _query,
                  ),
                ),
                _ActionChip(
                  label: 'Incident PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: () => _exportIncidentSummary(
                    context: context,
                    ref: ref,
                    snapshot: data,
                    resultFilter: _resultFilter,
                    query: _query,
                    openPdfAfterExport: true,
                  ),
                ),
                _ActionChip(
                  label: 'Export review pack',
                  icon: Icons.inventory_2_outlined,
                  onPressed: () {
                    final pins = pinsSnapshot.maybeWhen(
                      data: (snapshot) => snapshot,
                      orElse: () => const UsersDevicesPinRegistrySnapshot(
                        records: <UsersDevicesPinRecord>[],
                      ),
                    );
                    _exportAdminReviewPack(
                      context: context,
                      ref: ref,
                      snapshot: data,
                      pins: pins,
                      resultFilter: _resultFilter,
                      query: _query,
                    );
                  },
                ),
                _ActionChip(
                  label: 'Review pack PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: () {
                    final pins = pinsSnapshot.maybeWhen(
                      data: (snapshot) => snapshot,
                      orElse: () => const UsersDevicesPinRegistrySnapshot(
                        records: <UsersDevicesPinRecord>[],
                      ),
                    );
                    _exportAdminReviewPack(
                      context: context,
                      ref: ref,
                      snapshot: data,
                      pins: pins,
                      resultFilter: _resultFilter,
                      query: _query,
                      openPdfAfterExport: true,
                    );
                  },
                ),
                _ActionChip(
                  label: 'Open exports',
                  icon: Icons.folder_open_outlined,
                  onPressed: () => _openUsersDevicesExportsFolder(context, ref),
                ),
                _ActionChip(
                  label: 'Open onboarding report',
                  icon: Icons.assignment_outlined,
                  onPressed: () =>
                      context.go(RouteNames.usersDevicesOnboardingReport),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _VisualPanel(
              title: 'Review pack',
              subtitle:
                  'Use one calmer local pack when you need to hand over readiness, approval pressure, and incident posture together.',
              icon: Icons.inventory_2_outlined,
              compact: true,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _CardChip(label: 'Readiness posture'),
                  _CardChip(label: 'Approval pressure'),
                  _CardChip(label: 'Grouped audit pressure'),
                  _CardChip(label: 'Latest matching events'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SearchFilterPanel(
              title: 'Search audit events',
              subtitle:
                  'Search by actor, device, module, result, action, or reason.',
              query: _query,
              onQueryChanged: (value) => setState(() => _query = value),
              chips: [
                _SoftChoiceChip(
                  label: const Text('All'),
                  selected: _resultFilter == 'all',
                  onSelected: (_) => setState(() => _resultFilter = 'all'),
                ),
                _SoftChoiceChip(
                  label: const Text('Allowed'),
                  selected: _resultFilter == 'allowed',
                  onSelected: (_) => setState(() => _resultFilter = 'allowed'),
                ),
                _SoftChoiceChip(
                  label: const Text('Denied'),
                  selected: _resultFilter == 'denied',
                  onSelected: (_) => setState(() => _resultFilter = 'denied'),
                ),
                _SoftChoiceChip(
                  label: const Text('Pending'),
                  selected: _resultFilter == 'pending',
                  onSelected: (_) => setState(() => _resultFilter = 'pending'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AuditSnapshotPanel(events: data.auditLog),
            const SizedBox(height: 16),
            _AuditRiskPanel(data: data),
            const SizedBox(height: 16),
            _AuditGroupingPanel(
              events: data.auditLog,
              onDrillDown: _applyAuditDrillDown,
            ),
            const SizedBox(height: 16),
            if (_filteredAuditEvents(data.auditLog).isEmpty)
              _EmptyCollectionState(
                icon: Icons.receipt_long_outlined,
                title: 'No audit events matched the current filters',
                body:
                    'Try clearing the search box or switching the result filter back to All.',
              )
            else
              ..._filteredAuditEvents(data.auditLog).map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AuditEventCard(
                    event: event,
                    highlighted: event.eventId == highlightEventId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant UsersDevicesAuditLogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _didScrollToHighlight = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleHighlightScroll();
  }

  void _scheduleHighlightScroll() {
    if (_didScrollToHighlight || widget.highlightEventId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _didScrollToHighlight) {
        return;
      }

      final contextForBanner = _highlightKey.currentContext;
      if (contextForBanner == null) {
        return;
      }

      await Scrollable.ensureVisible(
        contextForBanner,
        alignment: 0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      _didScrollToHighlight = true;
    });
  }

  List<UsersDevicesControlAuditEvent> _filteredAuditEvents(
    List<UsersDevicesControlAuditEvent> events,
  ) {
    return events
        .where((event) {
          if (_resultFilter != 'all' && event.result != _resultFilter) {
            return false;
          }
          final query = _query.trim().toLowerCase();
          if (query.isEmpty) {
            return true;
          }
          final haystack = [
            event.eventId,
            event.timestamp,
            event.actorId,
            event.deviceId,
            event.eventType,
            event.targetModule,
            event.action,
            event.result,
            event.reason,
            _auditActionFamily(event),
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  void _applyAuditDrillDown({required String query, String? resultFilter}) {
    setState(() {
      _query = query;
      if (resultFilter != null) {
        _resultFilter = resultFilter;
      }
    });
  }
}

class _AuditSnapshotPanel extends StatelessWidget {
  const _AuditSnapshotPanel({required this.events});

  final List<UsersDevicesControlAuditEvent> events;

  @override
  Widget build(BuildContext context) {
    final sortedEvents = [...events]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final latest = sortedEvents.isNotEmpty ? sortedEvents.first : null;
    final allowed = events.where((event) => event.result == 'allowed').length;
    final denied = events.where((event) => event.result == 'denied').length;
    final pending = events.where((event) => event.result == 'pending').length;
    final moduleCounts = <String, int>{};
    for (final event in events) {
      moduleCounts[event.targetModule] =
          (moduleCounts[event.targetModule] ?? 0) + 1;
    }

    return _VisualPanel(
      title: 'Audit posture',
      subtitle:
          'Recent access decisions are easier to scan when the newest event and result mix stay visible.',
      icon: Icons.receipt_long_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CardChip(label: '${events.length} total events'),
              _CardChip(label: '$allowed allowed'),
              _CardChip(label: '$denied denied'),
              _CardChip(label: '$pending pending'),
              if (latest != null)
                _CardChip(label: 'Latest: ${latest.eventType}'),
            ],
          ),
          const SizedBox(height: 12),
          if (latest != null)
            _VisualPanel(
              title: 'Latest audit event',
              subtitle:
                  '${latest.timestamp} - ${_approvalModuleLabel(latest.targetModule)}',
              icon: Icons.verified_outlined,
              compact: true,
              child: Text(
                '${latest.actorId} / ${latest.deviceId} / ${latest.action} - ${latest.result}',
              ),
            ),
          if (latest != null) const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 54,
                dataRowMaxHeight: 88,
                columns: const [
                  DataColumn(label: Text('Module')),
                  DataColumn(label: Text('Events')),
                  DataColumn(label: Text('Latest result')),
                ],
                rows: moduleCounts.entries.isEmpty
                    ? [
                        const DataRow(
                          cells: [
                            DataCell(Text('No audit events yet')),
                            DataCell(Text('-')),
                            DataCell(Text('-')),
                          ],
                        ),
                      ]
                    : moduleCounts.entries
                          .map(
                            (entry) => DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 250,
                                    child: Text(
                                      _approvalModuleLabel(entry.key),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Text(entry.value.toString()),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 220,
                                    child: Text(
                                      sortedEvents
                                              .where(
                                                (event) =>
                                                    event.targetModule ==
                                                    entry.key,
                                              )
                                              .isEmpty
                                          ? 'No result yet'
                                          : sortedEvents
                                                .firstWhere(
                                                  (event) =>
                                                      event.targetModule ==
                                                      entry.key,
                                                )
                                                .result,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(growable: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditRiskPanel extends StatelessWidget {
  const _AuditRiskPanel({required this.data});

  final UsersDevicesControlSnapshot data;

  @override
  Widget build(BuildContext context) {
    final failedUnlocks = data.auditLog
        .where(
          (event) =>
              event.result == 'denied' &&
              (event.eventType.contains('pin_') ||
                  event.eventType.contains('unlock')),
        )
        .length;
    final deniedByActor = <String, int>{};
    for (final event in data.auditLog.where(
      (event) => event.result == 'denied',
    )) {
      deniedByActor[event.actorId] = (deniedByActor[event.actorId] ?? 0) + 1;
    }
    final repeatedDenialActors = deniedByActor.values
        .where((count) => count >= 2)
        .length;
    final staleTrustDevices = data.devices
        .where((device) => device.needsOnboardingReview)
        .length;
    final pendingApprovals = data.approvalQueue
        .where((request) => request.isPending)
        .length;

    return _VisualPanel(
      title: 'Latest risk panel',
      subtitle:
          'One calm view of the pressure building inside failed unlocks, repeated denials, stale trust, and pending approvals.',
      icon: Icons.warning_amber_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
            items: [
              ('Failed unlocks', failedUnlocks),
              ('Repeat denials', repeatedDenialActors),
              ('Stale trust', staleTrustDevices),
              ('Pending approvals', pendingApprovals),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.lock_person_outlined,
                  title: 'Failed unlocks',
                  subtitle: '$failedUnlocks denied attempts',
                  body: failedUnlocks == 0
                      ? 'No denied PIN or unlock attempts are currently visible in the local audit trail.'
                      : 'Review whether the failures point to a forgotten PIN, wrong identity selection, or a deeper trust problem.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.groups_2_outlined,
                  title: 'Repeated denials',
                  subtitle:
                      '$repeatedDenialActors actor${repeatedDenialActors == 1 ? '' : 's'}',
                  body: repeatedDenialActors == 0
                      ? 'No one is currently showing a repeated denied pattern.'
                      : 'These actors have hit denied flows more than once and may need a calmer support review.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.verified_user_outlined,
                  title: 'Stale trust pressure',
                  subtitle:
                      '$staleTrustDevices device${staleTrustDevices == 1 ? '' : 's'} needing review',
                  body: staleTrustDevices == 0
                      ? 'Every device in the current local set looks healthy enough for the present access model.'
                      : 'These devices still need onboarding review, trust repair, or quarantine follow-up.',
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.rule_folder_outlined,
                  title: 'Approval backlog',
                  subtitle:
                      '$pendingApprovals request${pendingApprovals == 1 ? '' : 's'} pending',
                  body: pendingApprovals == 0
                      ? 'No approval backlog is currently waiting.'
                      : 'Queue pressure is still present, so sensitive actions may need review before the route can finish.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditGroupingPanel extends StatelessWidget {
  const _AuditGroupingPanel({required this.events, required this.onDrillDown});

  final List<UsersDevicesControlAuditEvent> events;
  final void Function({required String query, String? resultFilter})
  onDrillDown;

  @override
  Widget build(BuildContext context) {
    final byActor = _auditGroupSummaryRows(
      events,
      (event) => event.actorId.isEmpty ? 'unknown' : event.actorId,
    );
    final byDevice = _auditGroupSummaryRows(
      events,
      (event) => event.deviceId.isEmpty ? 'unknown' : event.deviceId,
    );
    final byModule = _auditGroupSummaryRows(
      events,
      (event) => event.targetModule,
      labelFor: (value) => _approvalModuleLabel(value),
    );
    final byActionFamily = _auditGroupSummaryRows(
      events,
      (event) => _auditActionFamily(event),
    );
    final topDeniedActor = byActor.where((row) => row.deniedCount > 0).toList();
    final topDeniedDevice = byDevice
        .where((row) => row.deniedCount > 0)
        .toList();
    final topDeniedModule = byModule
        .where((row) => row.deniedCount > 0)
        .toList();
    final topDeniedActionFamily = byActionFamily
        .where((row) => row.deniedCount > 0)
        .toList();

    return _VisualPanel(
      title: 'Grouped audit view',
      subtitle:
          'Read the trail by user, device, module, and action family before diving into individual events.',
      icon: Icons.account_tree_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.person_search_outlined,
                  title: 'Top denied user',
                  subtitle: topDeniedActor.isEmpty
                      ? 'No denied user pressure'
                      : '${topDeniedActor.first.label} - ${topDeniedActor.first.deniedCount} denied',
                  body: topDeniedActor.isEmpty
                      ? 'The current audit slice does not show one actor dominating denied events.'
                      : 'Start here when one person needs the quickest support or identity review.',
                  actions: topDeniedActor.isEmpty
                      ? const []
                      : [
                          OutlinedButton.icon(
                            onPressed: () => onDrillDown(
                              query: topDeniedActor.first.queryValue,
                              resultFilter: 'denied',
                            ),
                            icon: const Icon(Icons.filter_alt_outlined),
                            label: const Text('Filter denied events'),
                          ),
                        ],
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.devices_outlined,
                  title: 'Top denied device',
                  subtitle: topDeniedDevice.isEmpty
                      ? 'No denied device pressure'
                      : '${topDeniedDevice.first.label} - ${topDeniedDevice.first.deniedCount} denied',
                  body: topDeniedDevice.isEmpty
                      ? 'No one endpoint is dominating denied events right now.'
                      : 'Start here when one device keeps surfacing in denied or failed access paths.',
                  actions: topDeniedDevice.isEmpty
                      ? const []
                      : [
                          OutlinedButton.icon(
                            onPressed: () => onDrillDown(
                              query: topDeniedDevice.first.queryValue,
                              resultFilter: 'denied',
                            ),
                            icon: const Icon(Icons.filter_alt_outlined),
                            label: const Text('Filter denied events'),
                          ),
                        ],
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.hub_outlined,
                  title: 'Top denied module',
                  subtitle: topDeniedModule.isEmpty
                      ? 'No denied module pressure'
                      : '${topDeniedModule.first.label} - ${topDeniedModule.first.deniedCount} denied',
                  body: topDeniedModule.isEmpty
                      ? 'No protected module is dominating the denied trail right now.'
                      : 'Use this when one protected route is causing most of the support friction.',
                  actions: topDeniedModule.isEmpty
                      ? const []
                      : [
                          OutlinedButton.icon(
                            onPressed: () => onDrillDown(
                              query: topDeniedModule.first.queryValue,
                              resultFilter: 'denied',
                            ),
                            icon: const Icon(Icons.filter_alt_outlined),
                            label: const Text('Filter denied events'),
                          ),
                        ],
                ),
              ),
              SizedBox(
                width: 260,
                child: _EntityCard(
                  icon: Icons.rule_folder_outlined,
                  title: 'Top denied action family',
                  subtitle: topDeniedActionFamily.isEmpty
                      ? 'No denied family pressure'
                      : '${topDeniedActionFamily.first.label} - ${topDeniedActionFamily.first.deniedCount} denied',
                  body: topDeniedActionFamily.isEmpty
                      ? 'No action family is dominating denied events right now.'
                      : 'This points to the kind of support issue making the most local noise first.',
                  actions: topDeniedActionFamily.isEmpty
                      ? const []
                      : [
                          OutlinedButton.icon(
                            onPressed: () => onDrillDown(
                              query: topDeniedActionFamily.first.queryValue,
                              resultFilter: 'denied',
                            ),
                            icon: const Icon(Icons.filter_alt_outlined),
                            label: const Text('Filter denied events'),
                          ),
                        ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 380,
                child: _AuditGroupCard(
                  title: 'By user',
                  entries: byActor,
                  onDrillDown: onDrillDown,
                ),
              ),
              SizedBox(
                width: 380,
                child: _AuditGroupCard(
                  title: 'By device',
                  entries: byDevice,
                  onDrillDown: onDrillDown,
                ),
              ),
              SizedBox(
                width: 380,
                child: _AuditGroupCard(
                  title: 'By module',
                  entries: byModule,
                  onDrillDown: onDrillDown,
                ),
              ),
              SizedBox(
                width: 380,
                child: _AuditGroupCard(
                  title: 'By action family',
                  entries: byActionFamily,
                  onDrillDown: onDrillDown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditGroupSummaryRow {
  const _AuditGroupSummaryRow({
    required this.label,
    required this.queryValue,
    required this.totalCount,
    required this.allowedCount,
    required this.deniedCount,
    required this.pendingCount,
  });

  final String label;
  final String queryValue;
  final int totalCount;
  final int allowedCount;
  final int deniedCount;
  final int pendingCount;
}

List<_AuditGroupSummaryRow> _auditGroupSummaryRows(
  List<UsersDevicesControlAuditEvent> events,
  String Function(UsersDevicesControlAuditEvent event) keyFor, {
  String Function(String value)? labelFor,
}) {
  final grouped = <String, List<UsersDevicesControlAuditEvent>>{};
  for (final event in events) {
    final key = keyFor(event).trim();
    if (key.isEmpty) {
      continue;
    }
    grouped.putIfAbsent(key, () => []).add(event);
  }

  final rows = grouped.entries
      .map(
        (entry) => _AuditGroupSummaryRow(
          label: labelFor?.call(entry.key) ?? entry.key,
          queryValue: entry.key,
          totalCount: entry.value.length,
          allowedCount: entry.value
              .where((event) => event.result == 'allowed')
              .length,
          deniedCount: entry.value
              .where((event) => event.result == 'denied')
              .length,
          pendingCount: entry.value
              .where((event) => event.result == 'pending')
              .length,
        ),
      )
      .toList(growable: false);

  rows.sort((left, right) {
    final rightScore =
        right.deniedCount * 5 + right.pendingCount * 3 + right.totalCount;
    final leftScore =
        left.deniedCount * 5 + left.pendingCount * 3 + left.totalCount;
    return rightScore.compareTo(leftScore);
  });
  return rows;
}

class _AuditGroupCard extends StatelessWidget {
  const _AuditGroupCard({
    required this.title,
    required this.entries,
    required this.onDrillDown,
  });

  final String title;
  final List<_AuditGroupSummaryRow> entries;
  final void Function({required String query, String? resultFilter})
  onDrillDown;

  @override
  Widget build(BuildContext context) {
    return _EntityCard(
      icon: Icons.stacked_bar_chart_outlined,
      title: title,
      subtitle: entries.isEmpty
          ? 'No events yet'
          : '${entries.length} visible groups',
      body: entries.isEmpty
          ? 'No audit events have been recorded in this group yet.'
          : entries
                .take(4)
                .map(
                  (entry) =>
                      '${entry.label}: ${entry.totalCount} total - ${entry.deniedCount} denied - ${entry.pendingCount} pending',
                )
                .join('\n'),
      actions: entries.isEmpty
          ? const []
          : entries
                .take(3)
                .map(
                  (entry) => OutlinedButton.icon(
                    onPressed: () => onDrillDown(query: entry.queryValue),
                    icon: const Icon(Icons.filter_alt_outlined),
                    label: Text('Filter ${entry.label}'),
                  ),
                )
                .toList(growable: false),
    );
  }
}

class _HighlightedAuditBanner extends StatelessWidget {
  const _HighlightedAuditBanner({
    super.key,
    required this.event,
    required this.sourceLabel,
  });

  final UsersDevicesControlAuditEvent event;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Container(
        color: theme.colorScheme.primaryContainer,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(sourceLabel)),
                  const SizedBox(height: 8),
                  Text(
                    'Latest lock-screen decision',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.eventType} - ${event.result} - ${event.reason}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersDevicesPageScaffold extends ConsumerWidget {
  const _UsersDevicesPageScaffold({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.child,
    this.scrollController,
    this.onBuilt,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget child;
  final ScrollController? scrollController;
  final VoidCallback? onBuilt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (onBuilt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onBuilt?.call());
    }
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(onPressed: onBack),
        title: _HeaderTitle(
          label: 'Users & Devices',
          title: title,
          subtitle: subtitle,
        ),
        toolbarHeight: 72,
      ),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          const _UsersDevicesOperatorSafetyBanner(),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProtectedRouteContextShell extends ConsumerWidget {
  const _ProtectedRouteContextShell({
    required this.moduleLabel,
    required this.moduleFocus,
    required this.status,
    required this.detail,
    required this.selectedUserLabel,
    required this.selectedUserRole,
    required this.selectedDeviceLabel,
    required this.selectedDeviceStatus,
    required this.selectedDeviceTrustLevel,
    required this.latestAuditEventId,
    required this.child,
  });

  final String moduleLabel;
  final String moduleFocus;
  final String status;
  final String detail;
  final String selectedUserLabel;
  final String selectedUserRole;
  final String selectedDeviceLabel;
  final String selectedDeviceStatus;
  final int selectedDeviceTrustLevel;
  final String? latestAuditEventId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(securitySessionProvider);
    final isLocked = !session.isUnlocked || session.isExpired;
    final remaining = session.remaining;

    return Stack(
      children: [
        child,
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Material(
                color: Colors.transparent,
                child: _VisualPanel(
                  title: 'Protected route context',
                  subtitle: isLocked
                      ? 'The local session needs refreshing. This module context stays visible so the next unlock remains deliberate.'
                      : moduleFocus,
                  icon: isLocked
                      ? Icons.lock_outline
                      : Icons.verified_user_outlined,
                  compact: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CardChip(label: moduleLabel),
                          _CardChip(label: status),
                          _CardChip(label: 'User: $selectedUserLabel'),
                          _CardChip(label: 'Role: $selectedUserRole'),
                          _CardChip(label: 'Device: $selectedDeviceLabel'),
                          _CardChip(label: 'Device status: $selectedDeviceStatus'),
                          _CardChip(label: 'Trust: T$selectedDeviceTrustLevel'),
                          _CardChip(
                            label: remaining == null
                                ? 'Expires: -'
                                : 'Expires in ${_formatBannerDuration(remaining)}',
                          ),
                          if (latestAuditEventId != null)
                            _CardChip(label: 'Audit recorded'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        detail,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () => context.go(RouteNames.securityLock),
                        icon: const Icon(Icons.lock_open_outlined),
                        label: Text(
                          isLocked
                              ? 'Refresh Security Lock'
                              : 'Open Security Lock',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionScaffold extends StatelessWidget {
  const _SectionScaffold({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.child,
    this.scrollController,
    this.onBuilt,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget child;
  final ScrollController? scrollController;
  final VoidCallback? onBuilt;

  @override
  Widget build(BuildContext context) {
    return _UsersDevicesPageScaffold(
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      scrollController: scrollController,
      onBuilt: onBuilt,
      child: child,
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _UsersDevicesOperatorSafetyBanner extends ConsumerWidget {
  const _UsersDevicesOperatorSafetyBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(securitySessionProvider);
    final isLocked = !session.isUnlocked || session.isExpired;
    final activeUserLabel = session.activeUserLabel;
    final activeDeviceLabel = session.activeDeviceLabel;
    final remaining = session.remaining;

    return _VisualPanel(
      title: 'Security session',
      subtitle: isLocked
          ? 'Locked. Open Security Lock to start a local session.'
          : 'Unlocked locally. The current local user and device stay visible while you review access, trust, and audit.',
      icon: isLocked ? Icons.lock_outline : Icons.verified_user_outlined,
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CardChip(label: isLocked ? 'Locked' : 'Unlocked'),
              _CardChip(
                label: activeUserLabel == null || activeUserLabel.isEmpty
                    ? 'Active user: none'
                    : 'Active user: $activeUserLabel',
              ),
              _CardChip(
                label: activeDeviceLabel == null || activeDeviceLabel.isEmpty
                    ? 'Active device: none'
                    : 'Active device: $activeDeviceLabel',
              ),
              _CardChip(
                label: remaining == null
                    ? 'Expires: -'
                    : 'Expires in ${_formatBannerDuration(remaining)}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isLocked
                ? 'Open Security Lock to restore the local route, then return here to continue with Users, Devices, PINs, or onboarding.'
                : 'This banner helps operators sanity-check the active route context before changing users, trusting devices, or reviewing onboarding readiness.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => context.go(RouteNames.securityLock),
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('Open Security Lock'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go(RouteNames.usersDevicesOnboardingReport),
                icon: const Icon(Icons.assignment_outlined),
                label: Text(
                  isLocked
                      ? 'Review onboarding report'
                      : 'Open onboarding report',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: _HeaderTitle(
          label: 'Users & Devices',
          title: title,
          subtitle: 'Loading local data',
        ),
        toolbarHeight: 72,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: _HeaderTitle(
          label: 'Users & Devices',
          title: title,
          subtitle: 'Try again in a moment',
        ),
        toolbarHeight: 72,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reload')),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.data,
    required this.pendingRequests,
    required this.trustedDevices,
  });

  final UsersDevicesControlSnapshot data;
  final int pendingRequests;
  final int trustedDevices;

  @override
  Widget build(BuildContext context) {
    return _VisualPanel(
      title: 'Local access control',
      subtitle:
          'Identity, device trust, approvals, and audit evidence stay local, calm, and easy to review.',
      icon: Icons.shield_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final stats = [
            _MetricTile(
              label: 'Users',
              value: data.users.length.toString(),
              icon: Icons.people_outline,
              accentColor: const Color(0xFF5BB7FF),
            ),
            _MetricTile(
              label: 'Devices',
              value: data.devices.length.toString(),
              icon: Icons.devices_outlined,
              accentColor: const Color(0xFF63D0C2),
            ),
            _MetricTile(
              label: 'Trusted',
              value: trustedDevices.toString(),
              icon: Icons.verified_outlined,
              accentColor: const Color(0xFF9BE564),
            ),
            _MetricTile(
              label: 'Pending',
              value: pendingRequests.toString(),
              icon: Icons.rule_folder_outlined,
              accentColor: const Color(0xFFFFC857),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _Badge(label: 'Local-first'),
                          _Badge(label: 'No cloud login'),
                          _Badge(label: 'Audit required'),
                          _Badge(label: 'Trust checked'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Every sensitive action needs identity, role, permission, trust, and audit trail.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SummaryChip(
                            label: '${data.users.length} users',
                            accentColor: const Color(0xFF5BB7FF),
                          ),
                          _SummaryChip(
                            label: '${data.devices.length} devices',
                            accentColor: const Color(0xFF63D0C2),
                          ),
                          _SummaryChip(
                            label: '$pendingRequests pending approvals',
                            accentColor: const Color(0xFFFFC857),
                          ),
                          _SummaryChip(
                            label: '${data.auditLog.length} audit events',
                            accentColor: const Color(0xFF9BE564),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: Column(children: stats)),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _Badge(label: 'Local-first'),
                  _Badge(label: 'No cloud login'),
                  _Badge(label: 'Audit required'),
                  _Badge(label: 'Trust checked'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Every sensitive action needs identity, role, permission, trust, and audit trail.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryChip(
                    label: '${data.users.length} users',
                    accentColor: const Color(0xFF5BB7FF),
                  ),
                  _SummaryChip(
                    label: '${data.devices.length} devices',
                    accentColor: const Color(0xFF63D0C2),
                  ),
                  _SummaryChip(
                    label: '$pendingRequests pending approvals',
                    accentColor: const Color(0xFFFFC857),
                  ),
                  _SummaryChip(
                    label: '${data.auditLog.length} audit events',
                    accentColor: const Color(0xFF9BE564),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...stats,
            ],
          );
        },
      ),
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<_ActionChip> actions;

  @override
  Widget build(BuildContext context) {
    return _VisualPanel(
      title: title,
      subtitle: subtitle,
      icon: Icons.auto_awesome_outlined,
      compact: true,
      child: Wrap(spacing: 10, runSpacing: 10, children: actions),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _SoftChoiceChip extends StatelessWidget {
  const _SoftChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: selected
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
      side: BorderSide(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.7)
            : theme.colorScheme.outlineVariant,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _NavigationGrid extends StatelessWidget {
  const _NavigationGrid({required this.tiles});

  final List<_NavTile> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: (constraints.maxWidth - (columns - 1) * 10) / columns,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  child: InkWell(
                    onTap: tile.route == null
                        ? null
                        : () => context.go(tile.route!),
                    child: Opacity(
                      opacity: tile.route == null ? 0.6 : 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.72),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  tile.icon,
                                  size: 22,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                tile.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tile.subtitle,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_forward_outlined,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NavTile {
  const _NavTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? route;
}

class _StaticRulePanel extends StatelessWidget {
  const _StaticRulePanel({required this.data});

  final UsersDevicesControlSnapshot data;

  @override
  Widget build(BuildContext context) {
    final trustLevel = data.trustLevels.lastWhere(
      (level) => level.level >= 4,
      orElse: () => data.trustLevels.last,
    );

    return _VisualPanel(
      title: 'Core rule',
      subtitle:
          'No user, device, AI agent, script, or voice gateway can reach a sensitive module without identity, role, permission, trust level, and audit trail.',
      icon: Icons.shield_outlined,
      child: Text(
        'Recommended admin trust floor: ${trustLevel.level} (${trustLevel.name})',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.body,
    this.accentColor,
  });

  final String step;
  final String title;
  final String body;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return _VisualPanel(
      title: '$step. $title',
      subtitle: body,
      icon: Icons.looks_one_outlined,
      compact: true,
      child: accentColor == null
          ? const SizedBox.shrink()
          : Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 56,
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.items});

  final List<(String label, int value)> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: (constraints.maxWidth - (columns - 1) * 12) / columns,
                child: _MetricTile(
                  label: item.$1,
                  value: item.$2.toString(),
                  icon: Icons.stacked_line_chart_outlined,
                  accentColor: _metricAccentColor(item.$1),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchFilterPanel extends StatelessWidget {
  const _SearchFilterPanel({
    required this.title,
    required this.subtitle,
    required this.query,
    required this.onQueryChanged,
    required this.chips,
  });

  final String title;
  final String subtitle;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return _VisualPanel(
      title: title,
      subtitle: subtitle,
      icon: Icons.search_outlined,
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_outlined),
              labelText: 'Search',
              hintText: 'Type to narrow the list',
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => onQueryChanged(''),
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }
}

class _EmptyCollectionState extends StatelessWidget {
  const _EmptyCollectionState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _EntityCard extends StatelessWidget {
  const _EntityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
    this.trailing,
    this.onTap,
    this.chips = const [],
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String body;
  final Widget? trailing;
  final VoidCallback? onTap;
  final List<Widget> chips;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(subtitle, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    trailing ?? const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 12),
                Text(body, style: theme.textTheme.bodyMedium),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: chips),
                ],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(spacing: 6, runSpacing: 6, children: actions),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chip = Chip(
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: theme.colorScheme.outlineVariant),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );

    if (onTap == null) {
      return chip;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: chip,
      ),
    );
  }
}

List<String> _pinSummaries(List<UsersDevicesPinRecord> pins) {
  final currentPins = pins
      .where((pin) => pin.status == 'active' || pin.status == 'recovery')
      .toList(growable: false);

  if (currentPins.isEmpty) {
    return const <String>[];
  }

  return currentPins
      .map((pin) => '${pin.label}: ${_maskPinCode(pin.pinCode)}')
      .toList(growable: false);
}

String _maskPinCode(String pinCode) {
  if (pinCode.length <= 2) {
    return pinCode;
  }

  return '${'*' * (pinCode.length - 2)}${pinCode.substring(pinCode.length - 2)}';
}

String _formatBannerDuration(Duration duration) {
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

List<String> buildUsersDevicesBlockedHints({
  required String reason,
  required String nextStep,
  required String userId,
  required String deviceId,
  required String issueCode,
  required String selectedUserRole,
  required int selectedDeviceTrustLevel,
  required String selectedDeviceStatus,
}) {
  final lowerReason = reason.toLowerCase();
  final hints = <String>[];

  if (nextStep.isNotEmpty) {
    hints.add(nextStep);
  }

  if (lowerReason.contains('unknown user')) {
    hints.add('Pick a local user that exists in the registry.');
    hints.add('Seed a sample user if you are just testing the flow.');
  }
  if (lowerReason.contains('unknown device')) {
    hints.add('Pick a local device that exists in the registry.');
    hints.add('Register or seed a device before trying again.');
  }
  if (lowerReason.contains('archived or disabled')) {
    hints.add('Restore the user or select a different active identity.');
    hints.add('Check the Users screen if the account was parked.');
  }
  if (lowerReason.contains('archived or blocked')) {
    hints.add('Use a trusted device or restore the blocked device first.');
    hints.add('Open the Devices screen to review the device state.');
  }
  if (issueCode == 'inactive_user') {
    hints.add('Select another active identity or restore the archived user first.');
  }
  if (issueCode == 'blocked_device') {
    if (selectedDeviceStatus.trim().isNotEmpty) {
      hints.add('Selected device status: $selectedDeviceStatus.');
    }
    hints.add(
      'Restore the device or switch to a trusted device before trying again.',
    );
  }
  if (lowerReason.contains('trust must be at least level')) {
    final match = RegExp(r'level (\d+)').firstMatch(lowerReason);
    final requiredTrust = match?.group(1);
    if (selectedDeviceTrustLevel > 0) {
      hints.add('Selected device trust: T$selectedDeviceTrustLevel.');
    }
    if (requiredTrust != null) {
      hints.add('Required trust floor: T$requiredTrust.');
    }
    hints.add('Choose a higher-trust device, or raise trust during onboarding.');
    hints.add('Open Device Onboarding to review the pairing history.');
  }
  if (lowerReason.contains('missing required permission')) {
    if (selectedUserRole.trim().isNotEmpty) {
      hints.add('Selected role: $selectedUserRole.');
    }
    hints.add(
      'Grant the missing permission from the Access Matrix or switch to a role that already has it.',
    );
    hints.add('Check the selected role for the expected capability.');
  }
  if (issueCode == 'approval_required' || lowerReason.contains('requires approval')) {
    hints.add('This action waits for a reviewer before the route can open.');
    hints.add('Open the Approval Queue and review the pending request.');
    hints.add('A trusted reviewer needs to approve this action first.');
  }
  if (hints.isEmpty) {
    hints.add('Review the selected user and device before trying again.');
    hints.add('Open the latest audit entry for more context.');
  }
  hints.add('Selected user: $userId');
  hints.add('Selected device: $deviceId');
  return hints;
}

void _openUserPinsRegistry(BuildContext context, String userId) {
  context.push(
    Uri(
      path: RouteNames.usersDevicesPins,
      queryParameters: {'userId': userId},
    ).toString(),
  );
}

Future<void> _copyUserPinSummary(
  BuildContext context,
  String userName,
  List<UsersDevicesPinRecord> pins,
) async {
  final summary = [
    'PIN summary for $userName',
    for (final pin in pins.where(
      (pin) => pin.status == 'active' || pin.status == 'recovery',
    ))
      '${pin.label}: ${_maskPinCode(pin.pinCode)} (${pin.status})',
  ].join('\n');

  await Clipboard.setData(ClipboardData(text: summary));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied PIN summary for $userName.')),
    );
  }
}

String _buildOnboardingReportSummary({
  required UsersDevicesControlUser user,
  required bool hasRoleAndPermissions,
  required bool hasPrimaryPin,
  required bool hasTrustedDevice,
  required bool accessReady,
  required List<UsersDevicesControlDevice> linkedDevices,
  required List<UsersDevicesControlDevice> trustedDevices,
  required int recoveryPinCount,
  required UsersDevicesControlAuditEvent? latestAudit,
}) {
  final trustedDeviceNames = trustedDevices.isEmpty
      ? 'None yet'
      : trustedDevices.map((device) => device.name).join(', ');
  final linkedDeviceNames = linkedDevices.isEmpty
      ? 'None linked'
      : linkedDevices.map((device) => device.name).join(', ');
  final auditLine = latestAudit == null
      ? 'No related audit event recorded yet.'
      : '${latestAudit.eventType} - ${latestAudit.result} - ${latestAudit.reason} (${latestAudit.timestamp})';

  return [
    'ONBOARDING HANDOFF SHEET',
    '',
    'User: ${user.displayName}',
    'Role: ${user.role}',
    if (user.title.isNotEmpty) 'Title: ${user.title}',
    'Status: ${accessReady ? 'Ready to verify locally' : 'Still in progress'}',
    '',
    'CHECKPOINTS',
    '- Role and permissions: ${hasRoleAndPermissions ? 'Ready' : 'Needs work'}',
    '- Primary PIN: ${hasPrimaryPin ? 'Ready' : 'Missing'}',
    '- Trusted device: ${hasTrustedDevice ? 'Ready' : 'Missing'}',
    '- Recovery PIN count: $recoveryPinCount',
    '',
    'DEVICES',
    '- Linked devices: $linkedDeviceNames',
    '- Trusted devices: $trustedDeviceNames',
    '',
    'LATEST AUDIT',
    auditLine,
    '',
    'NEXT STEP',
    accessReady
        ? 'Open Security Lock or a gated module and verify the route.'
        : 'Finish the missing checkpoint before treating this user as ready.',
  ].join('\n');
}

Future<void> _copyOnboardingReportSummary(
  BuildContext context,
  String userName,
  String summary,
) async {
  await Clipboard.setData(ClipboardData(text: summary));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied onboarding summary for $userName.')),
    );
  }
}

Future<void> _exportReadinessSummary({
  required BuildContext context,
  required WidgetRef ref,
  required UsersDevicesControlSnapshot snapshot,
  required UsersDevicesPinRegistrySnapshot pins,
  required String? focusedUserId,
  required String statusFilter,
  bool openPdfAfterExport = false,
}) async {
  final result = await ref
      .read(usersDevicesControlReportServiceProvider)
      .exportReadinessSummary(
        snapshot: snapshot,
        pins: pins,
        focusedUserId: focusedUserId,
        statusFilter: statusFilter,
      );

  if (openPdfAfterExport && context.mounted && result.pdfPath != null) {
    await openLocalPdfDocument(
      context,
      title: 'Users & Devices Readiness Summary PDF',
      pdfPath: result.pdfPath!,
    );
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.pdfPath == null
              ? '${result.message} ${result.reportPath}'
              : '${result.message} ${result.reportPath} PDF: ${result.pdfPath}',
        ),
      ),
    );
  }
}

Future<void> _exportIncidentSummary({
  required BuildContext context,
  required WidgetRef ref,
  required UsersDevicesControlSnapshot snapshot,
  required String resultFilter,
  required String query,
  bool openPdfAfterExport = false,
}) async {
  final result = await ref
      .read(usersDevicesControlReportServiceProvider)
      .exportIncidentSummary(
        snapshot: snapshot,
        resultFilter: resultFilter,
        query: query,
      );

  if (openPdfAfterExport && context.mounted && result.pdfPath != null) {
    await openLocalPdfDocument(
      context,
      title: 'Users & Devices Incident Summary PDF',
      pdfPath: result.pdfPath!,
    );
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.pdfPath == null
              ? '${result.message} ${result.reportPath}'
              : '${result.message} ${result.reportPath} PDF: ${result.pdfPath}',
        ),
      ),
    );
  }
}

Future<void> _exportAdminReviewPack({
  required BuildContext context,
  required WidgetRef ref,
  required UsersDevicesControlSnapshot snapshot,
  required UsersDevicesPinRegistrySnapshot pins,
  String? focusedUserId,
  String statusFilter = 'all',
  String resultFilter = 'all',
  String query = '',
  bool openPdfAfterExport = false,
}) async {
  final result = await ref
      .read(usersDevicesControlReportServiceProvider)
      .exportAdminReviewPack(
        snapshot: snapshot,
        pins: pins,
        focusedUserId: focusedUserId,
        statusFilter: statusFilter,
        resultFilter: resultFilter,
        query: query,
      );

  if (openPdfAfterExport && context.mounted && result.pdfPath != null) {
    await openLocalPdfDocument(
      context,
      title: 'Users & Devices Admin Review Pack PDF',
      pdfPath: result.pdfPath!,
    );
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.pdfPath == null
              ? '${result.message} ${result.reportPath}'
              : '${result.message} ${result.reportPath} PDF: ${result.pdfPath}',
        ),
      ),
    );
  }
}

Future<void> _openUsersDevicesExportsFolder(
  BuildContext context,
  WidgetRef ref,
) async {
  await ref.read(usersDevicesControlReportServiceProvider).openExportsFolder();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opened the local Users & Devices export folder.'),
      ),
    );
  }
}

class _PickerSection extends StatelessWidget {
  const _PickerSection({
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return _VisualPanel(
      title: title,
      subtitle: subtitle,
      icon: Icons.tune_outlined,
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailing != null) ...[
            Align(alignment: Alignment.centerRight, child: trailing),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _EntityActionsMenu extends StatelessWidget {
  const _EntityActionsMenu({
    required this.isArchived,
    required this.onEdit,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  final bool isArchived;
  final VoidCallback onEdit;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'archive':
            onArchiveToggle();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
        PopupMenuItem<String>(
          value: 'archive',
          child: Text(isArchived ? 'Restore' : 'Archive'),
        ),
        const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (accentColor ?? theme.colorScheme.primary).withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: accentColor ?? theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Container(
        color: theme.colorScheme.surface,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 34 : 42,
                    height: compact ? 34 : 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: compact ? 18 : 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(subtitle, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              if (!compact) const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: theme.colorScheme.outlineVariant),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, this.accentColor});

  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color effectiveAccent = accentColor ?? theme.colorScheme.surface;
    return Chip(
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: accentColor ?? theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: accentColor == null
          ? theme.colorScheme.surface
          : effectiveAccent.withValues(alpha: 0.14),
      side: BorderSide(
        color: accentColor == null
            ? theme.colorScheme.outlineVariant
            : effectiveAccent.withValues(alpha: 0.4),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

Color _metricAccentColor(String label) {
  switch (label.toLowerCase()) {
    case 'active':
    case 'users':
      return const Color(0xFF5BB7FF);
    case 'devices':
    case 'with devices':
      return const Color(0xFF63D0C2);
    case 'trusted':
    case 'templates':
    case 'audit':
    case 'audit events':
      return const Color(0xFF9BE564);
    case 'pending':
    case 'pending approvals':
      return const Color(0xFFFFC857);
    default:
      return const Color(0xFF5BB7FF);
  }
}

class _ApprovalRequestCard extends StatelessWidget {
  const _ApprovalRequestCard({
    required this.data,
    required this.request,
    required this.onApprove,
    required this.onDeny,
    this.onOpenAuditLog,
  });

  final UsersDevicesControlSnapshot data;
  final UsersDevicesControlApprovalRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onOpenAuditLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prerequisiteHint = _approvalPrerequisiteHint(data, request);
    final riskColor = request.riskLevel == 'high'
        ? theme.colorScheme.error
        : request.riskLevel == 'medium'
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: riskColor, width: 5)),
          color: theme.colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [riskColor, theme.colorScheme.tertiary],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.action, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${_approvalModuleLabel(request.targetModule)} - ${request.riskLevel} risk',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _CardChip(label: request.normalizedStatus.toUpperCase()),
                      _CardChip(label: request.riskLevel.toUpperCase()),
                      if (request.isPending)
                        const _CardChip(label: 'Waiting for reviewer'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(request.reason, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              Text(prerequisiteHint, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _CardChip(label: 'Requester ${request.requestedBy}'),
                  _CardChip(label: 'Device ${request.deviceId}'),
                  _CardChip(
                    label:
                        'Module ${_approvalModuleLabel(request.targetModule)}',
                  ),
                  _CardChip(label: 'Action ${request.action}'),
                  _CardChip(label: 'Age ${_approvalAgeLabel(request)}'),
                ],
              ),
              if (request.reviewedBy != null || request.reviewedAt != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (request.reviewedBy != null)
                      _CardChip(label: 'Reviewed by ${request.reviewedBy}'),
                    if (request.reviewedAt != null)
                      _CardChip(label: 'Reviewed ${request.reviewedAt!}'),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  FilledButton.tonal(
                    onPressed: onApprove,
                    child: const Text('Approve request'),
                  ),
                  OutlinedButton(
                    onPressed: onDeny,
                    child: const Text('Deny request'),
                  ),
                  if (onOpenAuditLog != null)
                    TextButton.icon(
                      onPressed: onOpenAuditLog,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Open Audit Log'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditEventCard extends StatelessWidget {
  const _AuditEventCard({required this.event, required this.highlighted});

  final UsersDevicesControlAuditEvent event;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultColor = switch (event.result) {
      'allowed' => const Color(0xFF9BE564),
      'denied' => theme.colorScheme.error,
      'pending' => theme.colorScheme.tertiary,
      _ => theme.colorScheme.outline,
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: highlighted
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          border: Border.all(
            color: highlighted
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            highlighted ? Icons.verified_outlined : Icons.receipt_long_outlined,
          ),
          title: Text(event.eventType),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${event.actorId} - ${event.targetModule} - ${event.reason}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _CardChip(label: event.timestamp),
                  _CardChip(label: 'Device ${event.deviceId}'),
                  _CardChip(label: 'Action ${event.action}'),
                  Chip(
                    label: Text(
                      event.result.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    side: BorderSide(color: resultColor),
                  ),
                ],
              ),
            ],
          ),
          trailing: highlighted
              ? Chip(
                  label: const Text(
                    'Highlighted',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  side: BorderSide(color: theme.colorScheme.primary),
                )
              : null,
        ),
      ),
    );
  }
}

Future<void> _registerSampleUser(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  await repository.registerUser(
    const UsersDevicesControlUser(
      id: 'user_demo_collaborator',
      displayName: 'Demo Collaborator',
      role: 'Project Contributor',
      title: 'Sample local identity',
      status: 'active',
      permissions: ['projects.view', 'docs.view'],
      linkedDevices: ['device_new_earth_dev'],
      notes: 'Created from the UI demo action.',
    ),
  );
  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample user registered.')));
  }
}

Future<void> _registerSampleDevice(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  await repository.registerDevice(
    const UsersDevicesControlDevice(
      id: 'device_demo_tablet',
      name: 'Demo Tablet',
      type: 'tablet',
      trustLevel: 2,
      status: 'registered',
      ownerId: 'user_peter_owner',
      allowedActions: ['dashboard.view', 'users.view'],
      notes: 'Created from the UI demo action.',
    ),
  );
  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample device registered.')));
  }
}

Future<void> _createSampleApproval(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  await repository.createApprovalRequest(
    requestedBy: 'agent_ai_sandbox',
    deviceId: 'device_gaia_usb_assistant',
    targetModule: 'BACKUP_MODULE',
    action: 'backup.run',
    riskLevel: 'medium',
    reason: 'UI demo approval request.',
  );
  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample approval created.')));
  }
}

Future<void> _reviewFirstPendingApproval(
  BuildContext context,
  WidgetRef ref, {
  required bool approve,
}) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);
  final pending = snapshot.approvalQueue.firstWhere(
    (request) => request.isPending,
    orElse: () => throw StateError('No pending approval requests available.'),
  );

  if (approve) {
    await repository.approveRequest(
      pending.requestId,
      reviewedBy: 'user_peter_owner',
    );
  } else {
    await repository.denyRequest(
      pending.requestId,
      reviewedBy: 'user_peter_owner',
    );
  }

  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approve ? 'Pending approval approved.' : 'Pending approval denied.',
        ),
      ),
    );
  }
}

Future<void> _confirmResetDemoData(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reset demo data?'),
      content: const Text(
        'This clears the local Users & Devices data and restores the seeded demo state. '
        'Any local changes made in the module will be replaced.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Reset'),
        ),
      ],
    ),
  );

  if (confirmed != true) {
    return;
  }

  final repository = ref.read(usersDevicesControlRepositoryProvider);
  final pinRegistry = ref.read(usersDevicesPinRegistryProvider);
  await repository.resetToSeedData();
  await pinRegistry.resetToSeedData();
  ref.invalidate(usersDevicesControlSnapshotProvider);
  ref.invalidate(usersDevicesPinRegistrySnapshotProvider);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo data reset to the seeded state.')),
    );
  }
}

Future<void> _assignUserPin(
  BuildContext context,
  WidgetRef ref,
  UsersDevicesControlUser user, {
  bool initialRecoveryMode = false,
}) async {
  final labelController = TextEditingController(text: 'Primary PIN');
  final pinController = TextEditingController();
  var recoveryMode = initialRecoveryMode;
  if (recoveryMode) {
    labelController.text = 'Recovery PIN';
  }
  final result = await showDialog<({String pinCode, String label, bool recovery})>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text('Assign PIN to ${user.displayName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Primary'),
                      icon: Icon(Icons.pin_outlined),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Recovery'),
                      icon: Icon(Icons.vpn_key_outlined),
                    ),
                  ],
                  selected: {recoveryMode},
                  onSelectionChanged: (selection) {
                    setDialogState(() {
                      recoveryMode = selection.first;
                      if (recoveryMode &&
                          labelController.text.trim() == 'Primary PIN') {
                        labelController.text = 'Recovery PIN';
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: recoveryMode ? 'Recovery label' : 'Label',
                    hintText: recoveryMode
                        ? 'For example: Backup PIN'
                        : 'For example: Primary PIN',
                  ),
                ),
                if (!recoveryMode) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'PIN code',
                      hintText: 'Use 4 to 8 digits',
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Text(
                    'A recovery PIN will be generated automatically when you save.',
                    style: Theme.of(dialogContext).textTheme.bodySmall
                        ?.copyWith(
                          color: Theme.of(
                            dialogContext,
                          ).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: recoveryMode
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop((
                          pinCode: pinController.text.trim(),
                          label: labelController.text.trim(),
                          recovery: false,
                        ));
                      },
                child: const Text('Save primary PIN'),
              ),
              FilledButton.tonal(
                onPressed: !recoveryMode
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop((
                          pinCode: '',
                          label: labelController.text.trim().isEmpty
                              ? 'Recovery PIN'
                              : labelController.text.trim(),
                          recovery: true,
                        ));
                      },
                child: const Text('Generate recovery PIN'),
              ),
            ],
          );
        },
      );
    },
  );

  labelController.dispose();
  pinController.dispose();

  if (result == null || (!result.recovery && result.pinCode.isEmpty)) {
    return;
  }

  final pins = ref.read(usersDevicesPinRegistryProvider);
  if (result.recovery) {
    await pins.issueRecoveryPin(
      userId: user.id,
      label: result.label.isEmpty ? 'Recovery PIN' : result.label,
    );
  } else {
    await pins.setPrimaryPin(
      userId: user.id,
      pinCode: result.pinCode,
      label: result.label.isEmpty ? '${user.displayName} PIN' : result.label,
    );
  }

  final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);
  final auditUser = snapshot.users.firstWhere(
    (entry) => entry.id == user.id,
    orElse: () => user,
  );
  final deviceId = auditUser.linkedDevices.isNotEmpty
      ? auditUser.linkedDevices.first
      : '';
  if (auditUser.id.isNotEmpty) {
    await ref
        .read(usersDevicesControlRepositoryProvider)
        .createAuditEvent(
          actorId: auditUser.id,
          deviceId: deviceId,
          eventType: 'pin_set',
          targetModule: '01_USERS_AND_DEVICES_CONTROL',
          action: 'assign_pin',
          result: 'allowed',
          reason: result.recovery
              ? 'Recovery PIN generated locally for ${auditUser.displayName}.'
              : 'Primary PIN assigned locally for ${auditUser.displayName}.',
        );
  }

  ref.invalidate(usersDevicesPinRegistrySnapshotProvider);
  ref.invalidate(usersDevicesControlSnapshotProvider);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.recovery
              ? 'Recovery PIN generated for ${user.displayName}.'
              : 'PIN assigned to ${user.displayName}.',
        ),
      ),
    );
  }
}

Future<void> _seedDemoPath(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);

  final role = snapshot.roles.isNotEmpty ? snapshot.roles.first.role : 'Guest';
  final permission = snapshot.permissions.isNotEmpty
      ? snapshot.permissions.first.permission
      : 'dashboard.view';
  final trustLevel = snapshot.trustLevels.isNotEmpty
      ? snapshot.trustLevels
            .firstWhere(
              (level) => level.level >= 3,
              orElse: () => snapshot.trustLevels.first,
            )
            .level
      : 3;
  final allowedAction = snapshot.accessRules.isNotEmpty
      ? snapshot.accessRules.first.viewPermission
      : permission;
  final actionScope = allowedAction.isNotEmpty ? allowedAction : permission;

  const userId = 'user_demo_collaborator';
  const deviceId = 'device_demo_tablet';

  await repository.registerUser(
    UsersDevicesControlUser(
      id: userId,
      displayName: 'Demo Collaborator',
      role: role,
      title: 'Seeded from the module hub',
      status: 'active',
      permissions: [permission],
      linkedDevices: [deviceId],
      notes: 'Created from the UI demo path.',
    ),
  );
  await repository.registerDevice(
    UsersDevicesControlDevice(
      id: deviceId,
      name: 'Demo Tablet',
      type: 'tablet',
      trustLevel: trustLevel,
      status: trustLevel >= 3 ? 'trusted' : 'registered',
      ownerId: userId,
      allowedActions: [actionScope],
      notes: 'Created from the UI demo path.',
      trustSource: 'module hub demo',
      trustReviewedBy: 'user_peter_owner',
      trustReviewedAt: DateTime.now().toUtc().toIso8601String(),
      lastSeenAt: DateTime.now().toUtc().toIso8601String(),
      operatorNote: 'Demo onboarding path.',
    ),
  );
  await repository.createApprovalRequest(
    requestedBy: userId,
    deviceId: deviceId,
    targetModule: '01_USERS_AND_DEVICES_CONTROL',
    action: 'assign_role',
    riskLevel: 'high',
    reason: 'Demo review path created from the module hub.',
  );

  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    context.go(RouteNames.usersDevicesApprovalQueue);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo user, device, and approval were seeded.'),
      ),
    );
  }
}

Future<void> _openOnboardingWizard(
  BuildContext context,
  WidgetRef ref, {
  required String template,
}) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);
  final availableUsers = snapshot.users;
  final availableTrustLevels = snapshot.trustLevels.isNotEmpty
      ? snapshot.trustLevels
      : const [
          UsersDevicesControlTrustLevelDefinition(
            level: 0,
            name: 'Unknown',
            description: 'No trust levels are configured yet.',
          ),
        ];
  final availableActions = <String>{
    ...snapshot.permissions.map((permission) => permission.permission),
    ...snapshot.accessRules.expand(
      (rule) => [
        rule.viewPermission,
        rule.editPermission,
        rule.adminPermission,
        rule.requestPermission,
        rule.executePermission,
        rule.controlPermission,
      ],
    ),
  }.where((action) => action.trim().isNotEmpty).toList(growable: false);

  final defaults = switch (template) {
    'assistant' => (
      id: 'device_assistant_new',
      name: 'Local Assistant',
      type: 'assistant',
      trustLevel: 3,
      ownerId: availableUsers.isNotEmpty ? availableUsers.first.id : '',
      allowedActions: <String>['ai.request_action', 'voice.request_action'],
    ),
    'gateway' => (
      id: 'device_gateway_new',
      name: 'Local Gateway',
      type: 'gateway',
      trustLevel: 4,
      ownerId: availableUsers.isNotEmpty ? availableUsers.first.id : '',
      allowedActions: <String>['dashboard.view', 'backup.verify'],
    ),
    'printer' => (
      id: 'device_printer_new',
      name: 'Label Printer',
      type: 'printer',
      trustLevel: 2,
      ownerId: availableUsers.isNotEmpty ? availableUsers.first.id : '',
      allowedActions: <String>['assets.print_label'],
    ),
    _ => (
      id: 'device_new_local',
      name: 'New Local Device',
      type: 'computer',
      trustLevel: 2,
      ownerId: availableUsers.isNotEmpty ? availableUsers.first.id : '',
      allowedActions: <String>['dashboard.view'],
    ),
  };

  final idController = TextEditingController(text: defaults.id);
  final nameController = TextEditingController(text: defaults.name);
  final typeController = TextEditingController(text: defaults.type);
  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var trustLevel = defaults.trustLevel;
  var ownerId = defaults.ownerId;
  final selectedActions = <String>{...defaults.allowedActions};
  final customActionController = TextEditingController();
  final trustAckController = TextEditingController();

  try {
    final result = await showDialog<UsersDevicesControlDevice>(
      context: context,
      builder: (dialogContext) {
        var step = 0;
        var trustConfirmed = trustLevel < 4;
        final onboardingOwnerLabel = ownerId.isEmpty
            ? 'Unassigned'
            : availableUsers
                  .firstWhere(
                    (user) => user.id == ownerId,
                    orElse: () => UsersDevicesControlUser(
                      id: ownerId,
                      displayName: ownerId,
                      role: '',
                      status: 'active',
                      permissions: const [],
                      linkedDevices: const [],
                    ),
                  )
                  .displayName;
        final onboardingTrustLabel = trustLevel >= 4
            ? 'High-trust confirm required'
            : 'Standard pairing';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Device onboarding'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text('Step ${step + 1} of 3')),
                            Chip(label: Text(template)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (step == 0) ...[
                          TextFormField(
                            controller: idController,
                            decoration: const InputDecoration(
                              labelText: 'Device ID',
                              hintText: 'device_unique_id',
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Enter a device ID'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Device name',
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Enter a device name'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: typeController,
                            decoration: const InputDecoration(
                              labelText: 'Device type',
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Enter a device type'
                                : null,
                          ),
                        ] else if (step == 1) ...[
                          DropdownButtonFormField<String>(
                            initialValue: ownerId.isEmpty ? null : ownerId,
                            decoration: const InputDecoration(
                              labelText: 'Owner',
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text('Unassigned'),
                              ),
                              ...availableUsers.map(
                                (user) => DropdownMenuItem<String>(
                                  value: user.id,
                                  child: Text(
                                    '${user.displayName} (${user.id})',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => ownerId = value ?? ''),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: trustLevel,
                            decoration: const InputDecoration(
                              labelText: 'Trust level',
                            ),
                            items: availableTrustLevels
                                .map(
                                  (level) => DropdownMenuItem<int>(
                                    value: level.level,
                                    child: Text(
                                      '${level.level} - ${level.name}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  trustLevel = value;
                                  trustConfirmed = value < 4;
                                  if (value < 4) {
                                    trustAckController.clear();
                                  }
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Higher trust levels unlock more sensitive module access.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          _VisualPanel(
                            title: 'Trust confirmation',
                            subtitle:
                                'Confirm that the device, owner, and trust level are correct before we continue.',
                            icon: Icons.verified_user_outlined,
                            compact: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: trustConfirmed,
                                  onChanged: (value) {
                                    setState(() {
                                      trustConfirmed = value ?? false;
                                    });
                                  },
                                  title: const Text(
                                    'I confirm this pairing locally',
                                  ),
                                  subtitle: Text(
                                    trustLevel >= 4
                                        ? 'High-trust devices need a deliberate confirmation step.'
                                        : 'This keeps the onboarding audit trail explicit.',
                                  ),
                                ),
                                if (trustLevel >= 4) ...[
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: trustAckController,
                                    decoration: const InputDecoration(
                                      labelText: 'Type CONFIRM',
                                      hintText: 'CONFIRM',
                                    ),
                                    validator: (value) {
                                      if (trustLevel < 4) {
                                        return null;
                                      }
                                      return value?.trim().toUpperCase() ==
                                              'CONFIRM'
                                          ? null
                                          : 'Type CONFIRM to approve a high-trust pairing.';
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ] else ...[
                          _VisualPanel(
                            title: 'Onboarding recap',
                            subtitle:
                                'Check the local identity, owner, trust level, and access scope before saving.',
                            icon: Icons.fact_check_outlined,
                            compact: true,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _CardChip(
                                  label: 'ID: ${idController.text.trim()}',
                                ),
                                _CardChip(
                                  label: 'Owner: $onboardingOwnerLabel',
                                ),
                                _CardChip(label: 'Trust: T$trustLevel'),
                                _CardChip(
                                  label: 'Actions: ${selectedActions.length}',
                                ),
                                _CardChip(label: onboardingTrustLabel),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: customActionController,
                            decoration: const InputDecoration(
                              labelText: 'Add custom action',
                              hintText: 'e.g. assets.print_label',
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.tonal(
                            onPressed: () {
                              final action = customActionController.text.trim();
                              if (action.isEmpty) {
                                return;
                              }
                              setState(() {
                                selectedActions.add(action);
                                customActionController.clear();
                              });
                            },
                            child: const Text('Add action'),
                          ),
                          const SizedBox(height: 12),
                          if (availableActions.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final action in availableActions.take(12))
                                  FilterChip(
                                    label: Text(action),
                                    selected: selectedActions.contains(action),
                                    onSelected: (value) {
                                      setState(() {
                                        if (value) {
                                          selectedActions.add(action);
                                        } else {
                                          selectedActions.remove(action);
                                        }
                                      });
                                    },
                                  ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: notesController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: step == 0 ? null : () => setState(() => step -= 1),
                  child: const Text('Back'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (step < 2) {
                      if (step == 0 &&
                          !(formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      if (step == 1 && !trustConfirmed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please confirm the pairing before continuing.',
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => step += 1);
                      return;
                    }

                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    if (!trustConfirmed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please confirm the pairing before finishing.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      UsersDevicesControlDevice(
                        id: idController.text.trim(),
                        name: nameController.text.trim(),
                        type: typeController.text.trim(),
                        trustLevel: trustLevel,
                        status: trustLevel >= 3 ? 'trusted' : 'registered',
                        ownerId: ownerId,
                        allowedActions: selectedActions.toList(growable: false),
                        notes: notesController.text.trim(),
                        trustSource: 'device onboarding',
                        trustReviewedBy: ownerId,
                        trustReviewedAt: DateTime.now()
                            .toUtc()
                            .toIso8601String(),
                        lastSeenAt: DateTime.now().toUtc().toIso8601String(),
                        operatorNote:
                            'Created from the guided onboarding flow.',
                      ),
                    );
                  },
                  child: Text(step < 2 ? 'Next' : 'Finish'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    await repository.registerDevice(result);
    final hasHighTrustAck =
        result.trustLevel >= 4 && trustAckController.text.trim().isNotEmpty;
    final auditReason =
        'Device pairing confirmed locally at trust level ${result.trustLevel} for owner ${result.ownerId} with ${result.allowedActions.length} allowed action(s)'
        '${hasHighTrustAck ? ' and explicit CONFIRM acknowledgement.' : '.'}';
    await repository.createAuditEvent(
      actorId: result.ownerId,
      deviceId: result.id,
      eventType: 'device_trust_confirmed',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'confirm_device_trust',
      result: 'allowed',
      reason: auditReason,
    );
    ref.invalidate(usersDevicesControlSnapshotProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Device onboarded locally at trust level ${result.trustLevel}.',
          ),
        ),
      );
    }
  } finally {
    idController.dispose();
    nameController.dispose();
    typeController.dispose();
    notesController.dispose();
    customActionController.dispose();
    trustAckController.dispose();
  }
}

Future<void> _openUserEditor(
  BuildContext context,
  WidgetRef ref, {
  UsersDevicesControlUser? user,
}) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);
  final roleItems = <String>{
    ...snapshot.roles.map((role) => role.role),
    if (user != null) user.role,
  }.toList(growable: false);
  final availableRoles = roleItems.isNotEmpty ? roleItems : <String>['Guest'];
  final availablePermissions = snapshot.permissions
      .map((permission) => permission.permission)
      .where((permission) => permission.isNotEmpty)
      .toList(growable: false);
  final availableDevices = snapshot.devices;
  final idController = TextEditingController(text: user?.id ?? '');
  final displayNameController = TextEditingController(
    text: user?.displayName ?? '',
  );
  final titleController = TextEditingController(text: user?.title ?? '');
  final notesController = TextEditingController(text: user?.notes ?? '');
  final formKey = GlobalKey<FormState>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  var role = user?.role.isNotEmpty == true ? user!.role : availableRoles.first;
  var status = user?.status ?? 'active';
  final selectedPermissions = <String>{
    ...(user?.permissions ?? const <String>[]),
  };
  final selectedLinkedDevices = <String>{
    ...(user?.linkedDevices ?? const <String>[]),
  };
  var permissionQuery = '';
  var deviceQuery = '';

  try {
    final result = await showDialog<UsersDevicesControlUser>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(user == null ? 'Add user' : 'Edit user'),
          content: StatefulBuilder(
            builder: (context, setState) {
              final filteredPermissions = availablePermissions
                  .where(
                    (permission) => permission.toLowerCase().contains(
                      permissionQuery.trim().toLowerCase(),
                    ),
                  )
                  .toList(growable: false);
              final filteredDevices = availableDevices
                  .where(
                    (device) => '${device.name} ${device.id}'
                        .toLowerCase()
                        .contains(deviceQuery.trim().toLowerCase()),
                  )
                  .toList(growable: false);

              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: idController,
                          readOnly: user != null,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            hintText: 'user_unique_id',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Enter a user ID'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Enter a display name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: role,
                          decoration: const InputDecoration(labelText: 'Role'),
                          items: availableRoles
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => role = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('active'),
                            ),
                            DropdownMenuItem(
                              value: 'template',
                              child: Text('template'),
                            ),
                            DropdownMenuItem(
                              value: 'disabled',
                              child: Text('disabled'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => status = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: 12),
                        _PickerSection(
                          title: 'Permissions',
                          subtitle: 'Pick local permissions for this identity',
                          trailing: TextButton(
                            onPressed: selectedPermissions.isEmpty
                                ? null
                                : () {
                                    setState(() => selectedPermissions.clear());
                                  },
                            child: Text(
                              '${selectedPermissions.length} selected',
                            ),
                          ),
                          children: [
                            TextField(
                              onChanged: (value) {
                                setState(() => permissionQuery = value);
                              },
                              decoration: const InputDecoration(
                                labelText: 'Filter permissions',
                                hintText: 'Search permission scopes',
                                prefixIcon: Icon(Icons.search_outlined),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (filteredPermissions.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final permission in filteredPermissions)
                                    FilterChip(
                                      label: Text(permission),
                                      selected: selectedPermissions.contains(
                                        permission,
                                      ),
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            selectedPermissions.add(permission);
                                          } else {
                                            selectedPermissions.remove(
                                              permission,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                ],
                              )
                            else
                              Text(
                                availablePermissions.isEmpty
                                    ? 'No permission definitions are available yet.'
                                    : 'No permissions matched the current filter.',
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PickerSection(
                          title: 'Linked devices',
                          subtitle:
                              'Connect this user to the trusted devices they use',
                          trailing: TextButton(
                            onPressed: selectedLinkedDevices.isEmpty
                                ? null
                                : () {
                                    setState(
                                      () => selectedLinkedDevices.clear(),
                                    );
                                  },
                            child: Text(
                              '${selectedLinkedDevices.length} selected',
                            ),
                          ),
                          children: [
                            TextField(
                              onChanged: (value) {
                                setState(() => deviceQuery = value);
                              },
                              decoration: const InputDecoration(
                                labelText: 'Filter devices',
                                hintText: 'Search device name or id',
                                prefixIcon: Icon(Icons.search_outlined),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (filteredDevices.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final device in filteredDevices)
                                    FilterChip(
                                      label: Text(device.name),
                                      selected: selectedLinkedDevices.contains(
                                        device.id,
                                      ),
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            selectedLinkedDevices.add(
                                              device.id,
                                            );
                                          } else {
                                            selectedLinkedDevices.remove(
                                              device.id,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                ],
                              )
                            else
                              Text(
                                availableDevices.isEmpty
                                    ? 'No devices are available yet.'
                                    : 'No devices matched the current filter.',
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: 'Notes'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  UsersDevicesControlUser(
                    id: idController.text.trim(),
                    displayName: displayNameController.text.trim(),
                    role: role,
                    title: titleController.text.trim(),
                    status: status,
                    permissions: selectedPermissions.toList(growable: false),
                    linkedDevices: selectedLinkedDevices.toList(
                      growable: false,
                    ),
                    notes: notesController.text.trim(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    await repository.registerUser(result);
    ref.invalidate(usersDevicesControlSnapshotProvider);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          user == null ? 'User added locally.' : 'User updated locally.',
        ),
      ),
    );
  } finally {
    idController.dispose();
    displayNameController.dispose();
    titleController.dispose();
    notesController.dispose();
  }
}

Future<void> _openDeviceEditor(
  BuildContext context,
  WidgetRef ref, {
  UsersDevicesControlDevice? device,
}) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  final snapshot = await ref.read(usersDevicesControlSnapshotProvider.future);
  final availableUsers = snapshot.users;
  final availableTrustLevels = snapshot.trustLevels.isNotEmpty
      ? snapshot.trustLevels
      : const [
          UsersDevicesControlTrustLevelDefinition(
            level: 0,
            name: 'Unknown',
            description: 'No trust levels are configured yet.',
          ),
        ];
  final trustLevelItems = <UsersDevicesControlTrustLevelDefinition>[
    ...availableTrustLevels,
    if (!availableTrustLevels.any(
      (level) =>
          level.level ==
          (device?.trustLevel ?? availableTrustLevels.first.level),
    ))
      UsersDevicesControlTrustLevelDefinition(
        level: device?.trustLevel ?? availableTrustLevels.first.level,
        name: 'Custom',
        description: 'Current device trust level.',
      ),
  ];
  final availableActions = <String>{
    ...snapshot.permissions.map((permission) => permission.permission),
    ...snapshot.accessRules.expand(
      (rule) => [
        rule.viewPermission,
        rule.editPermission,
        rule.adminPermission,
        rule.requestPermission,
        rule.executePermission,
        rule.controlPermission,
      ],
    ),
    ...(device?.allowedActions ?? const <String>[]),
  }.where((action) => action.trim().isNotEmpty).toList(growable: false);
  final idController = TextEditingController(text: device?.id ?? '');
  final nameController = TextEditingController(text: device?.name ?? '');
  final typeController = TextEditingController(text: device?.type ?? '');
  final notesController = TextEditingController(text: device?.notes ?? '');
  final trustSourceController = TextEditingController(
    text: device?.trustSource ?? '',
  );
  final trustReviewedByController = TextEditingController(
    text: device?.trustReviewedBy ?? '',
  );
  final trustReviewedAtController = TextEditingController(
    text: device?.trustReviewedAt ?? '',
  );
  final lastSeenAtController = TextEditingController(
    text: device?.lastSeenAt ?? '',
  );
  final operatorNoteController = TextEditingController(
    text: device?.operatorNote ?? '',
  );
  final quarantineReasonController = TextEditingController(
    text: device?.quarantineReason ?? '',
  );
  final formKey = GlobalKey<FormState>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  var status = device?.status ?? 'registered';
  var ownerId =
      device?.ownerId ??
      (availableUsers.isNotEmpty ? availableUsers.first.id : '');
  var trustLevel = device?.trustLevel ?? availableTrustLevels.first.level;
  final selectedActions = <String>{
    ...(device?.allowedActions ?? const <String>[]),
  };
  final customActionController = TextEditingController();
  var actionQuery = '';

  try {
    final result = await showDialog<UsersDevicesControlDevice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(device == null ? 'Add device' : 'Edit device'),
          content: StatefulBuilder(
            builder: (context, setState) {
              final filteredActions = availableActions
                  .where(
                    (action) => action.toLowerCase().contains(
                      actionQuery.trim().toLowerCase(),
                    ),
                  )
                  .toList(growable: false);

              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: idController,
                          readOnly: device != null,
                          decoration: const InputDecoration(
                            labelText: 'Device ID',
                            hintText: 'device_unique_id',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Enter a device ID'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Device name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Enter a device name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: typeController,
                          decoration: const InputDecoration(
                            labelText: 'Device type',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Enter a device type'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: trustLevel,
                          decoration: const InputDecoration(
                            labelText: 'Trust level',
                          ),
                          items: trustLevelItems
                              .map(
                                (level) => DropdownMenuItem<int>(
                                  value: level.level,
                                  child: Text('${level.level} - ${level.name}'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => trustLevel = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'registered',
                              child: Text('registered'),
                            ),
                            DropdownMenuItem(
                              value: 'trusted',
                              child: Text('trusted'),
                            ),
                            DropdownMenuItem(
                              value: 'critical',
                              child: Text('critical'),
                            ),
                            DropdownMenuItem(
                              value: 'blocked',
                              child: Text('blocked'),
                            ),
                            DropdownMenuItem(
                              value: 'quarantined',
                              child: Text('quarantined'),
                            ),
                            DropdownMenuItem(
                              value: 'archived',
                              child: Text('archived'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => status = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: ownerId.isEmpty ? null : ownerId,
                          decoration: const InputDecoration(labelText: 'Owner'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Unassigned'),
                            ),
                            ...availableUsers.map(
                              (userOption) => DropdownMenuItem<String>(
                                value: userOption.id,
                                child: Text(
                                  '${userOption.displayName} (${userOption.id})',
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => ownerId = value ?? '');
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: trustSourceController,
                          decoration: const InputDecoration(
                            labelText: 'Trust source',
                            hintText: 'e.g. onboarding review',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: trustReviewedByController,
                          decoration: const InputDecoration(
                            labelText: 'Reviewed by',
                            hintText: 'e.g. user_peter_owner',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: trustReviewedAtController,
                          decoration: const InputDecoration(
                            labelText: 'Reviewed at',
                            hintText: '2026-06-29T09:15:00Z',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: lastSeenAtController,
                          decoration: const InputDecoration(
                            labelText: 'Last seen at',
                            hintText: '2026-06-29T08:45:00Z',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PickerSection(
                          title: 'Allowed actions',
                          subtitle:
                              'Pick known action scopes or add a custom one',
                          trailing: TextButton(
                            onPressed: selectedActions.isEmpty
                                ? null
                                : () {
                                    setState(() => selectedActions.clear());
                                  },
                            child: Text('${selectedActions.length} selected'),
                          ),
                          children: [
                            TextField(
                              onChanged: (value) {
                                setState(() => actionQuery = value);
                              },
                              decoration: const InputDecoration(
                                labelText: 'Filter actions',
                                hintText: 'Search action scopes',
                                prefixIcon: Icon(Icons.search_outlined),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (filteredActions.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final action in filteredActions)
                                    FilterChip(
                                      label: Text(action),
                                      selected: selectedActions.contains(
                                        action,
                                      ),
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            selectedActions.add(action);
                                          } else {
                                            selectedActions.remove(action);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              )
                            else
                              Text(
                                availableActions.isEmpty
                                    ? 'No suggested actions are available yet.'
                                    : 'No actions matched the current filter.',
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: customActionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Add custom action',
                                      hintText: 'e.g. assets.print_label',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonal(
                                  onPressed: () {
                                    final action = customActionController.text
                                        .trim();
                                    if (action.isEmpty) {
                                      return;
                                    }
                                    setState(() {
                                      selectedActions.add(action);
                                      customActionController.clear();
                                    });
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (selectedActions.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final action in selectedActions)
                                    InputChip(
                                      label: Text(action),
                                      onDeleted: () {
                                        setState(() {
                                          selectedActions.remove(action);
                                        });
                                      },
                                    ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: 'Notes'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: operatorNoteController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Operator note',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: quarantineReasonController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Quarantine reason',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  UsersDevicesControlDevice(
                    id: idController.text.trim(),
                    name: nameController.text.trim(),
                    type: typeController.text.trim(),
                    trustLevel: trustLevel,
                    status: status,
                    ownerId: ownerId,
                    allowedActions: selectedActions.toList(growable: false),
                    notes: notesController.text.trim(),
                    trustSource: trustSourceController.text.trim(),
                    trustReviewedBy: trustReviewedByController.text.trim(),
                    trustReviewedAt: _normalizedNullableText(
                      trustReviewedAtController.text,
                    ),
                    lastSeenAt: _normalizedNullableText(
                      lastSeenAtController.text,
                    ),
                    operatorNote: operatorNoteController.text.trim(),
                    quarantineReason: quarantineReasonController.text.trim(),
                    quarantinedAt: status == 'quarantined'
                        ? _normalizedNullableText(
                            quarantineReasonController.text.trim().isNotEmpty &&
                                    device?.quarantinedAt == null
                                ? DateTime.now().toUtc().toIso8601String()
                                : device?.quarantinedAt ?? '',
                          )
                        : null,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    await repository.registerDevice(result);
    ref.invalidate(usersDevicesControlSnapshotProvider);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          device == null ? 'Device added locally.' : 'Device updated locally.',
        ),
      ),
    );
  } finally {
    idController.dispose();
    nameController.dispose();
    typeController.dispose();
    notesController.dispose();
    trustSourceController.dispose();
    trustReviewedByController.dispose();
    trustReviewedAtController.dispose();
    lastSeenAtController.dispose();
    operatorNoteController.dispose();
    quarantineReasonController.dispose();
    customActionController.dispose();
  }
}

Future<void> _toggleUserArchive(
  BuildContext context,
  WidgetRef ref,
  UsersDevicesControlUser user,
) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  if (user.status == 'archived') {
    await repository.restoreUser(user.id);
  } else {
    await repository.archiveUser(user.id);
  }
  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user.status == 'archived'
              ? 'User restored locally.'
              : 'User archived locally.',
        ),
      ),
    );
  }
}

Future<void> _toggleDeviceArchive(
  BuildContext context,
  WidgetRef ref,
  UsersDevicesControlDevice device,
) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  if (device.status == 'archived') {
    await repository.restoreDevice(device.id);
  } else {
    await repository.archiveDevice(device.id);
  }
  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          device.status == 'archived'
              ? 'Device restored locally.'
              : 'Device archived locally.',
        ),
      ),
    );
  }
}

String? _normalizedNullableText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

Future<void> _toggleDeviceQuarantine(
  BuildContext context,
  WidgetRef ref,
  UsersDevicesControlDevice device,
) async {
  final repository = ref.read(usersDevicesControlRepositoryProvider);
  if (device.isQuarantined) {
    await repository.restoreDevice(
      device.id,
      reason: 'Device restored from quarantine locally.',
    );
    ref.invalidate(usersDevicesControlSnapshotProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${device.name} restored from quarantine.')),
      );
    }
    return;
  }

  final reasonController = TextEditingController(text: device.quarantineReason);
  final reviewedByController = TextEditingController(
    text: device.trustReviewedBy.isEmpty
        ? 'user_peter_owner'
        : device.trustReviewedBy,
  );

  try {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Quarantine ${device.name}?'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reviewedByController,
                decoration: const InputDecoration(labelText: 'Reviewed by'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Quarantine reason',
                  hintText: 'Why should this device be paused from access?',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Quarantine'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await repository.quarantineDevice(
      device.id,
      reviewedBy: reviewedByController.text.trim().isEmpty
          ? 'user_peter_owner'
          : reviewedByController.text.trim(),
      reason: reasonController.text.trim().isEmpty
          ? 'Operator requested local quarantine review.'
          : reasonController.text.trim(),
    );
    ref.invalidate(usersDevicesControlSnapshotProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${device.name} quarantined locally.')),
      );
    }
  } finally {
    reasonController.dispose();
    reviewedByController.dispose();
  }
}

Future<void> _confirmDeleteUser(
  BuildContext context,
  WidgetRef ref,
  UsersDevicesControlUser user,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete user?'),
      content: Text(
        'Delete ${user.displayName} from the local registry? This also writes an audit event.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) {
    return;
  }

  final repository = ref.read(usersDevicesControlRepositoryProvider);
  await repository.deleteUser(user.id);
  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User deleted locally.')));
  }
}

Future<void> _confirmDeleteDevice(
  BuildContext context,
  WidgetRef ref,
  UsersDevicesControlDevice device,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete device?'),
      content: Text(
        'Delete ${device.name} from the local registry? This also writes an audit event.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) {
    return;
  }

  final repository = ref.read(usersDevicesControlRepositoryProvider);
  await repository.deleteDevice(device.id);
  ref.invalidate(usersDevicesControlSnapshotProvider);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Device deleted locally.')));
  }
}
