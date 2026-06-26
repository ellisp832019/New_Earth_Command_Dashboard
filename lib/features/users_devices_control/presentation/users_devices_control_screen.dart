// ignore_for_file: use_build_context_synchronously

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../application/users_devices_control_controller.dart';
import '../application/users_devices_pin_registry_controller.dart';
import '../data/users_devices_control_repository.dart';
import '../data/users_devices_pin_registry_service.dart';
import '../../security/application/security_session_controller.dart';

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
          final pending = data.approvalQueue
              .where((request) => request.status == 'pending')
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
                    data.devices
                        .where((device) => device.trustLevel >= 3)
                        .length,
                  ),
                  (
                    'Critical',
                    data.devices
                        .where((device) => device.status == 'critical')
                        .length,
                  ),
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
                              '${device.trustPostureSummary}\nTrust T${device.trustLevel} - ${device.allowedActions.length} allowed action${device.allowedActions.length == 1 ? '' : 's'}',
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
                            if (device.needsOnboardingReview)
                              const _CardChip(label: 'Review onboarding'),
                          ],
                          actions: [
                            FilledButton.tonal(
                              onPressed: () => _openDeviceEditor(
                                context,
                                ref,
                                device: device,
                              ),
                              child: const Text('Edit'),
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
            .where((device) => device.trustLevel >= 3 && device.status != 'blocked')
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
                      accentColor: accessReady
                          ? const Color(0xFF7EE6C5)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => context.go(RouteNames.usersDevicesUsers),
                          icon: const Icon(Icons.people_outline),
                          label: const Text('Open Users'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go(RouteNames.usersDevicesPins),
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
                          onPressed: () => context.go(RouteNames.usersDevicesAccessMatrix),
                          icon: const Icon(Icons.grid_view_outlined),
                          label: const Text('Open Access Matrix'),
                        ),
                        FilledButton.icon(
                          onPressed: accessReady
                              ? () => context.go(
                                    RouteNames.securityLock,
                                  )
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
                                          onPressed: () => _openOnboardingWizard(
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
            );
    });
  }

  List<String> _blockedHintsFor({
    required String reason,
    required String nextStep,
    required String userId,
    required String deviceId,
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
    if (lowerReason.contains('trust must be at least level')) {
      hints.add(
        'Choose a higher-trust device, or raise trust during onboarding.',
      );
      hints.add('Open Device Onboarding to review the pairing history.');
    }
    if (lowerReason.contains('missing required permission')) {
      hints.add(
        'Use the recommended user if one is shown, or grant the missing permission from the Access Matrix.',
      );
      hints.add('Check the selected role for the expected capability.');
    }
    if (lowerReason.contains('requires approval')) {
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

  @override
  Widget build(BuildContext context) {
    if (_unlocked) {
      return widget.child;
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
        .where((request) => request.status == 'pending')
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
    if (request.status == 'pending') {
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
            .where((request) => request.status == 'pending')
            .length;
        final filteredRequests = data.approvalQueue
            .where((request) {
              if (_statusFilter != 'all' && request.status != _statusFilter) {
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
                request.status,
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
              _SummaryRow(
                items: [
                  ('All', data.approvalQueue.length),
                  (
                    'Pending',
                    data.approvalQueue
                        .where((request) => request.status == 'pending')
                        .length,
                  ),
                  (
                    'Allowed',
                    data.approvalQueue
                        .where((request) => request.status == 'allowed')
                        .length,
                  ),
                  (
                    'Denied',
                    data.approvalQueue
                        .where((request) => request.status == 'denied')
                        .length,
                  ),
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
                    label: const Text('Allowed'),
                    selected: _statusFilter == 'allowed',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'allowed'),
                  ),
                  _SoftChoiceChip(
                    label: const Text('Denied'),
                    selected: _statusFilter == 'denied',
                    onSelected: (_) => setState(() => _statusFilter = 'denied'),
                  ),
                ],
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
                          request: request,
                          onApprove: request.status == 'pending'
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
                          onDeny: request.status == 'pending'
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
      if (request.status == 'pending') {
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
  final pending = matches
      .where((request) => request.status == 'pending')
      .length;
  final allowed = matches
      .where((request) => request.status == 'allowed')
      .length;
  final denied = matches.where((request) => request.status == 'denied').length;
  return '$pending pending, $allowed allowed, $denied denied';
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
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
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

class _UsersDevicesPageScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
        children: [child],
      ),
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
    required this.request,
    required this.onApprove,
    required this.onDeny,
    this.onOpenAuditLog,
  });

  final UsersDevicesControlApprovalRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onOpenAuditLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.action,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${request.targetModule} - ${request.riskLevel} risk',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: [
                      _CardChip(label: request.status.toUpperCase()),
                      _CardChip(label: request.riskLevel.toUpperCase()),
                      if (request.status == 'pending')
                        const _CardChip(label: 'Waiting for reviewer'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(request.reason, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _CardChip(label: 'Requester ${request.requestedBy}'),
                  _CardChip(label: 'Device ${request.deviceId}'),
                  _CardChip(label: 'Module ${request.targetModule}'),
                  _CardChip(label: 'Action ${request.action}'),
                  _CardChip(label: 'Time ${request.timestamp}'),
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
    (request) => request.status == 'pending',
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
