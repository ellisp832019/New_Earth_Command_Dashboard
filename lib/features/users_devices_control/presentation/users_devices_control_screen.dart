// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../application/users_devices_control_controller.dart';
import '../data/users_devices_control_repository.dart';

class UsersDevicesControlScreen extends ConsumerWidget {
  const UsersDevicesControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);

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
          final trustedDevices =
              data.devices.where((device) => device.trustLevel >= 3).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroPanel(
                data: data,
                pendingRequests: pending,
                trustedDevices: trustedDevices,
              ),
              const SizedBox(height: 16),
              _ActionStrip(
                title: 'Try it now',
                subtitle:
                    'Seed a sample user, a sample device, or a sample approval.',
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
                    subtitle: '$pending request${pending == 1 ? '' : 's'} pending',
                    icon: Icons.rule_folder_outlined,
                    route: RouteNames.usersDevicesApprovalQueue,
                  ),
                  _NavTile(
                    title: 'Audit Log',
                    subtitle: '${data.auditLog.length} recorded events',
                    icon: Icons.receipt_long_outlined,
                    route: RouteNames.usersDevicesAuditLog,
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

class UsersDevicesUsersScreen extends ConsumerWidget {
  const UsersDevicesUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Users'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Users',
        message: 'The users registry is not ready right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) => _SectionScaffold(
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
                ('Active', data.users.where((user) => user.status == 'active').length),
                ('Templates', data.users.where((user) => user.status == 'template').length),
                ('With devices', data.users.where((user) => user.linkedDevices.isNotEmpty).length),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final user in data.users)
                  SizedBox(
                    width: 360,
                    child: _EntityCard(
                      icon: Icons.person_outline,
                      title: user.displayName,
                      subtitle:
                          '${user.role}${user.title.isNotEmpty ? ' · ${user.title}' : ''}',
                      body:
                          '${user.permissions.length} permissions · ${user.linkedDevices.length} linked devices',
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
                            onArchiveToggle: () => _toggleUserArchive(
                              context,
                              ref,
                              user,
                            ),
                            onDelete: () => _confirmDeleteUser(
                              context,
                              ref,
                              user,
                            ),
                          ),
                        ],
                      ),
                      chips: [
                        _CardChip(label: user.role),
                        if (user.permissions.isNotEmpty)
                          _CardChip(label: user.permissions.first),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UsersDevicesDevicesScreen extends ConsumerWidget {
  const UsersDevicesDevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Devices'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Devices',
        message: 'The device registry is not ready right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) => _SectionScaffold(
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
                  label: 'Seed sample device',
                  icon: Icons.auto_fix_high_outlined,
                  onPressed: () => _registerSampleDevice(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              items: [
                ('Trusted', data.devices.where((device) => device.trustLevel >= 3).length),
                ('Critical', data.devices.where((device) => device.status == 'critical').length),
                ('Owned', data.devices.where((device) => device.ownerId.isNotEmpty).length),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final device in data.devices)
                  SizedBox(
                    width: 360,
                    child: _EntityCard(
                      icon: Icons.devices_outlined,
                      title: device.name,
                      subtitle: device.type,
                      body:
                          'Trust ${device.trustLevel} · ${device.allowedActions.length} allowed action${device.allowedActions.length == 1 ? '' : 's'}',
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
                            onArchiveToggle: () => _toggleDeviceArchive(
                              context,
                              ref,
                              device,
                            ),
                            onDelete: () => _confirmDeleteDevice(
                              context,
                              ref,
                              device,
                            ),
                          ),
                        ],
                      ),
                      chips: [
                        _CardChip(label: 'T${device.trustLevel}'),
                        if (device.ownerId.isNotEmpty)
                          const _CardChip(label: 'Assigned'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UsersDevicesAccessMatrixScreen extends ConsumerWidget {
  const UsersDevicesAccessMatrixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Access Matrix'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Access Matrix',
        message: 'The access matrix could not be loaded right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) => _SectionScaffold(
        title: 'Access Matrix',
        subtitle: 'Role permissions and module gates',
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 430,
                  child: _VisualPanel(
                    title: 'Role permissions',
                    subtitle: 'What each identity can do locally',
                    icon: Icons.badge_outlined,
                    child: Column(
                      children: [
                        for (final role in data.roles)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _EntityCard(
                              icon: Icons.badge_outlined,
                              title: role.role,
                              subtitle:
                                  '${role.permissions.length} permissions',
                              body: role.permissions.join(' · '),
                              chips: [
                                if (role.permissions.isNotEmpty)
                                  _CardChip(label: role.permissions.first),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 430,
                  child: _VisualPanel(
                    title: 'Module rules',
                    subtitle: 'Trust and approval thresholds',
                    icon: Icons.shield_outlined,
                    child: Column(
                      children: [
                        for (final rule in data.accessRules)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _EntityCard(
                              icon: Icons.shield_outlined,
                              title: rule.moduleId,
                              subtitle:
                                  'Trust floor ${rule.requiresTrustLevel}',
                              body:
                                  'View: ${rule.viewPermission.isEmpty ? 'none' : rule.viewPermission} · Approvals: ${rule.requiresApprovalFor.length}',
                              trailing: Chip(
                                label: Text(
                                  rule.requiresApprovalFor.isEmpty
                                      ? 'Open'
                                      : 'Gated',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UsersDevicesDeviceOnboardingScreen extends ConsumerWidget {
  const UsersDevicesDeviceOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Device Onboarding'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Device Onboarding',
        message: 'The onboarding flow is not ready right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) => _SectionScaffold(
        title: 'Device Onboarding',
        subtitle: 'Register, verify, trust, and log a new local device',
        onBack: () => context.go(RouteNames.usersDevices),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ActionStrip(
              title: 'Live onboarding demo',
              subtitle:
                  'Create a sample device record and keep the flow local-first.',
              actions: [
                _ActionChip(
                  label: 'Register sample device',
                  icon: Icons.phonelink_setup_outlined,
                  onPressed: () => _registerSampleDevice(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _StepCard(
              step: '1',
              title: 'Register the device',
              body: 'Capture the device name, type, owner, and local purpose.',
            ),
            const SizedBox(height: 12),
            const _StepCard(
              step: '2',
              title: 'Assign a trust level',
              body: 'Use the local trust scale to decide whether the device can view or control sensitive modules.',
            ),
            const SizedBox(height: 12),
            const _StepCard(
              step: '3',
              title: 'Link identity and audit',
              body: 'Attach the owner identity and write an audit event for the onboarding decision.',
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
                  for (final level in data.trustLevels)
                    SizedBox(
                      width: 280,
                      child: _EntityCard(
                        icon: Icons.verified_outlined,
                        title: '${level.level} · ${level.name}',
                        subtitle: 'Trust band',
                        body: level.description,
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

class UsersDevicesApprovalQueueScreen extends ConsumerWidget {
  const UsersDevicesApprovalQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(usersDevicesControlSnapshotProvider);
    return snapshot.when(
      loading: () => const _LoadingScaffold(title: 'Approval Queue'),
      error: (error, stackTrace) => _ErrorScreen(
        title: 'Approval Queue',
        message: 'The approval queue could not be loaded right now.',
        onRetry: () => ref.invalidate(usersDevicesControlSnapshotProvider),
      ),
      data: (data) => _SectionScaffold(
        title: 'Approval Queue',
        subtitle: 'Review actions that need a second look',
        onBack: () => context.go(RouteNames.usersDevices),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final request in data.approvalQueue)
              SizedBox(
                width: 450,
                child: _ApprovalRequestCard(
                  request: request,
                  onApprove: request.status == 'pending'
                      ? () async {
                          await ref
                              .read(usersDevicesControlRepositoryProvider)
                              .approveRequest(
                                request.requestId,
                                reviewedBy: 'user_peter_owner',
                              );
                          ref.invalidate(usersDevicesControlSnapshotProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request approved.')),
                            );
                          }
                        }
                      : null,
                  onDeny: request.status == 'pending'
                      ? () async {
                          await ref
                              .read(usersDevicesControlRepositoryProvider)
                              .denyRequest(
                                request.requestId,
                                reviewedBy: 'user_peter_owner',
                              );
                          ref.invalidate(usersDevicesControlSnapshotProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request denied.')),
                            );
                          }
                        }
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
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
              ],
            ),
            const SizedBox(height: 16),
            ...data.auditLog.map(
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
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.85),
              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.eventType} - ${event.result} - ${event.reason}',
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),
        title: Text(title),
      ),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          child,
        ],
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

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

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
      title: 'Security-first local control',
      subtitle:
          'Identity, device trust, approvals, and audit evidence stay local and calm.',
      icon: Icons.shield_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final stats = [
            _MetricTile(
              label: 'Users',
              value: data.users.length.toString(),
              icon: Icons.people_outline,
            ),
            _MetricTile(
              label: 'Devices',
              value: data.devices.length.toString(),
              icon: Icons.devices_outlined,
            ),
            _MetricTile(
              label: 'Trusted',
              value: trustedDevices.toString(),
              icon: Icons.verified_outlined,
            ),
            _MetricTile(
              label: 'Pending',
              value: pendingRequests.toString(),
              icon: Icons.rule_folder_outlined,
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
                          Chip(label: Text('${data.users.length} users')),
                          Chip(label: Text('${data.devices.length} devices')),
                          Chip(label: Text('$pendingRequests pending approvals')),
                          Chip(label: Text('${data.auditLog.length} audit events')),
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
                  Chip(label: Text('${data.users.length} users')),
                  Chip(label: Text('${data.devices.length} devices')),
                  Chip(label: Text('$pendingRequests pending approvals')),
                  Chip(label: Text('${data.auditLog.length} audit events')),
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
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: actions,
      ),
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
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
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
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: (constraints.maxWidth - (columns - 1) * 12) / columns,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  child: InkWell(
                    onTap: () => context.go(tile.route),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(tile.icon),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tile.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(tile.subtitle),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.arrow_forward_outlined, size: 18),
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
      },
    );
  }
}

class _NavTile {
  const _NavTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
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
  });

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _VisualPanel(
      title: '$step. $title',
      subtitle: body,
      icon: Icons.looks_one_outlined,
      compact: true,
      child: const SizedBox.shrink(),
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
                ),
              ),
          ],
        );
      },
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
    this.chips = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String body;
  final Widget? trailing;
  final List<Widget> chips;

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
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
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
                        Text(subtitle),
                      ],
                    ),
                  ),
                  trailing ?? const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 12),
              Text(body),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: chips),
              ],
            ],
          ),
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
    return Chip(label: Text(label));
  }
}

class _PickerSection extends StatelessWidget {
  const _PickerSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

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
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
        PopupMenuItem<String>(
          value: 'archive',
          child: Text(isArchived ? 'Restore' : 'Archive'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
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
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 36 : 44,
                    height: compact ? 36 : 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: compact ? 18 : 22),
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
    return Chip(label: Text(label));
  }
}

class _ApprovalRequestCard extends StatelessWidget {
  const _ApprovalRequestCard({
    required this.request,
    required this.onApprove,
    required this.onDeny,
  });

  final UsersDevicesControlApprovalRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;

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
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: riskColor, width: 5),
          ),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.action, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text('${request.targetModule} · ${request.riskLevel} risk'),
                      ],
                    ),
                  ),
                  Chip(label: Text(request.status)),
                ],
              ),
              const SizedBox(height: 10),
              Text(request.reason),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CardChip(label: 'Requested by ${request.requestedBy}'),
                  _CardChip(label: 'Device ${request.deviceId}'),
                  _CardChip(label: request.timestamp),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                  OutlinedButton(
                    onPressed: onDeny,
                    child: const Text('Deny'),
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
  const _AuditEventCard({
    required this.event,
    required this.highlighted,
  });

  final UsersDevicesControlAuditEvent event;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: highlighted
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.28)
              : null,
          border: Border.all(
            color: highlighted
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(
            highlighted ? Icons.verified_outlined : Icons.receipt_long_outlined,
          ),
          title: Text(event.eventType),
          subtitle: Text(
            '${event.actorId} · ${event.targetModule} · ${event.reason}',
          ),
          trailing: Chip(label: Text(event.result)),
        ),
      ),
    );
  }
}

Future<void> _registerSampleUser(
  BuildContext context,
  WidgetRef ref,
) async {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample user registered.')),
    );
  }
}

Future<void> _registerSampleDevice(
  BuildContext context,
  WidgetRef ref,
) async {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample device registered.')),
    );
  }
}

Future<void> _createSampleApproval(
  BuildContext context,
  WidgetRef ref,
) async {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample approval created.')),
    );
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
  final displayNameController = TextEditingController(text: user?.displayName ?? '');
  final titleController = TextEditingController(text: user?.title ?? '');
  final notesController = TextEditingController(text: user?.notes ?? '');
  final formKey = GlobalKey<FormState>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  var role = user?.role.isNotEmpty == true
      ? user!.role
      : availableRoles.first;
  var status = user?.status ?? 'active';
  final selectedPermissions = <String>{
    ...(user?.permissions ?? const <String>[]),
  };
  final selectedLinkedDevices = <String>{
    ...(user?.linkedDevices ?? const <String>[]),
  };

  try {
    final result = await showDialog<UsersDevicesControlUser>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(user == null ? 'Add user' : 'Edit user'),
          content: StatefulBuilder(
            builder: (context, setState) {
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
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Enter a user ID'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                          ),
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Enter a display name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: role,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                            ),
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
                            DropdownMenuItem(value: 'active', child: Text('active')),
                            DropdownMenuItem(value: 'template', child: Text('template')),
                            DropdownMenuItem(value: 'disabled', child: Text('disabled')),
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
                          decoration: const InputDecoration(
                            labelText: 'Title',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PickerSection(
                          title: 'Permissions',
                          subtitle: 'Pick local permissions for this identity',
                          children: [
                            if (availablePermissions.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final permission in availablePermissions)
                                    FilterChip(
                                      label: Text(permission),
                                      selected: selectedPermissions.contains(permission),
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            selectedPermissions.add(permission);
                                          } else {
                                            selectedPermissions.remove(permission);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              )
                            else
                              const Text('No permission definitions are available yet.'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PickerSection(
                          title: 'Linked devices',
                          subtitle: 'Connect this user to the trusted devices they use',
                          children: [
                            if (availableDevices.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final device in availableDevices)
                                    FilterChip(
                                      label: Text(device.name),
                                      selected: selectedLinkedDevices.contains(device.id),
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            selectedLinkedDevices.add(device.id);
                                          } else {
                                            selectedLinkedDevices.remove(device.id);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              )
                            else
                              const Text('No devices are available yet.'),
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
                    linkedDevices: selectedLinkedDevices.toList(growable: false),
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
    if (!availableTrustLevels.any((level) => level.level == (device?.trustLevel ?? availableTrustLevels.first.level)))
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
  var ownerId = device?.ownerId ?? (availableUsers.isNotEmpty ? availableUsers.first.id : '');
  var trustLevel = device?.trustLevel ?? availableTrustLevels.first.level;
  final selectedActions = <String>{
    ...(device?.allowedActions ?? const <String>[]),
  };
  final customActionController = TextEditingController();

  try {
    final result = await showDialog<UsersDevicesControlDevice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(device == null ? 'Add device' : 'Edit device'),
          content: StatefulBuilder(
            builder: (context, setState) {
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
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Enter a device ID'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Device name',
                          ),
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Enter a device name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: typeController,
                          decoration: const InputDecoration(
                            labelText: 'Device type',
                          ),
                          validator: (value) => (value == null || value.trim().isEmpty)
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
                            DropdownMenuItem(value: 'registered', child: Text('registered')),
                            DropdownMenuItem(value: 'trusted', child: Text('trusted')),
                            DropdownMenuItem(value: 'critical', child: Text('critical')),
                            DropdownMenuItem(value: 'blocked', child: Text('blocked')),
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
                          decoration: const InputDecoration(
                            labelText: 'Owner',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Unassigned'),
                            ),
                            ...availableUsers.map(
                              (userOption) => DropdownMenuItem<String>(
                                value: userOption.id,
                                child: Text('${userOption.displayName} (${userOption.id})'),
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
                          subtitle: 'Pick known action scopes or add a custom one',
                          children: [
                            if (availableActions.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final action in availableActions)
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
                              )
                            else
                              const Text('No suggested actions are available yet.'),
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
                                    final action = customActionController.text.trim();
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
                          decoration: const InputDecoration(
                            labelText: 'Notes',
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User deleted locally.')),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device deleted locally.')),
    );
  }
}
