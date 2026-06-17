import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class UsersDevicesControlUser {
  const UsersDevicesControlUser({
    required this.id,
    required this.displayName,
    required this.role,
    required this.status,
    required this.permissions,
    required this.linkedDevices,
    this.title = '',
    this.notes = '',
  });

  final String id;
  final String displayName;
  final String role;
  final String title;
  final String status;
  final List<String> permissions;
  final List<String> linkedDevices;
  final String notes;

  factory UsersDevicesControlUser.fromJson(Map<String, dynamic> json) {
    return UsersDevicesControlUser(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      permissions: _stringList(json['permissions']),
      linkedDevices: _stringList(json['linked_devices']),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'role': role,
      'title': title,
      'status': status,
      'permissions': permissions,
      'linked_devices': linkedDevices,
      'notes': notes,
    };
  }

  UsersDevicesControlUser copyWith({
    String? displayName,
    String? role,
    String? title,
    String? status,
    List<String>? permissions,
    List<String>? linkedDevices,
    String? notes,
  }) {
    return UsersDevicesControlUser(
      id: id,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      title: title ?? this.title,
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
      linkedDevices: linkedDevices ?? this.linkedDevices,
      notes: notes ?? this.notes,
    );
  }
}

class UsersDevicesControlDevice {
  const UsersDevicesControlDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.trustLevel,
    required this.status,
    required this.ownerId,
    required this.allowedActions,
    this.notes = '',
  });

  final String id;
  final String name;
  final String type;
  final int trustLevel;
  final String status;
  final String ownerId;
  final List<String> allowedActions;
  final String notes;

  factory UsersDevicesControlDevice.fromJson(Map<String, dynamic> json) {
    return UsersDevicesControlDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      trustLevel: json['trust_level'] as int? ?? 0,
      status: json['status'] as String? ?? 'registered',
      ownerId: json['owner_id'] as String? ?? '',
      allowedActions: _stringList(json['allowed_actions']),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'trust_level': trustLevel,
      'status': status,
      'owner_id': ownerId,
      'allowed_actions': allowedActions,
      'notes': notes,
    };
  }

  UsersDevicesControlDevice copyWith({
    String? name,
    String? type,
    int? trustLevel,
    String? status,
    String? ownerId,
    List<String>? allowedActions,
    String? notes,
  }) {
    return UsersDevicesControlDevice(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      trustLevel: trustLevel ?? this.trustLevel,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      allowedActions: allowedActions ?? this.allowedActions,
      notes: notes ?? this.notes,
    );
  }
}

class UsersDevicesControlApprovalRequest {
  const UsersDevicesControlApprovalRequest({
    required this.requestId,
    required this.timestamp,
    required this.requestedBy,
    required this.deviceId,
    required this.targetModule,
    required this.action,
    required this.status,
    required this.riskLevel,
    required this.reason,
    this.reviewedBy,
    this.reviewedAt,
  });

  final String requestId;
  final String timestamp;
  final String requestedBy;
  final String deviceId;
  final String targetModule;
  final String action;
  final String status;
  final String riskLevel;
  final String reason;
  final String? reviewedBy;
  final String? reviewedAt;

  factory UsersDevicesControlApprovalRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return UsersDevicesControlApprovalRequest(
      requestId: json['request_id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      requestedBy: json['requested_by'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      targetModule: json['target_module'] as String? ?? '',
      action: json['action'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      riskLevel: json['risk_level'] as String? ?? 'low',
      reason: json['reason'] as String? ?? '',
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'timestamp': timestamp,
      'requested_by': requestedBy,
      'device_id': deviceId,
      'target_module': targetModule,
      'action': action,
      'status': status,
      'risk_level': riskLevel,
      'reason': reason,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    };
  }
}

class UsersDevicesControlAuditEvent {
  const UsersDevicesControlAuditEvent({
    required this.eventId,
    required this.timestamp,
    required this.actorId,
    required this.deviceId,
    required this.eventType,
    required this.targetModule,
    required this.action,
    required this.result,
    required this.reason,
  });

  final String eventId;
  final String timestamp;
  final String actorId;
  final String deviceId;
  final String eventType;
  final String targetModule;
  final String action;
  final String result;
  final String reason;

  factory UsersDevicesControlAuditEvent.fromJson(Map<String, dynamic> json) {
    return UsersDevicesControlAuditEvent(
      eventId: json['event_id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      actorId: json['actor_id'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      targetModule: json['target_module'] as String? ?? '',
      action: json['action'] as String? ?? '',
      result: json['result'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'timestamp': timestamp,
      'actor_id': actorId,
      'device_id': deviceId,
      'event_type': eventType,
      'target_module': targetModule,
      'action': action,
      'result': result,
      'reason': reason,
    };
  }
}

class UsersDevicesControlRoleDefinition {
  const UsersDevicesControlRoleDefinition({
    required this.role,
    required this.permissions,
  });

  final String role;
  final List<String> permissions;

  factory UsersDevicesControlRoleDefinition.fromJson(
    Map<String, dynamic> json,
  ) {
    return UsersDevicesControlRoleDefinition(
      role: json['role'] as String? ?? '',
      permissions: _stringList(json['permissions']),
    );
  }
}

class UsersDevicesControlPermissionDefinition {
  const UsersDevicesControlPermissionDefinition({
    required this.permission,
    required this.description,
  });

  final String permission;
  final String description;

  factory UsersDevicesControlPermissionDefinition.fromJson(
    Map<String, dynamic> json,
  ) {
    return UsersDevicesControlPermissionDefinition(
      permission: json['permission'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class UsersDevicesControlTrustLevelDefinition {
  const UsersDevicesControlTrustLevelDefinition({
    required this.level,
    required this.name,
    required this.description,
  });

  final int level;
  final String name;
  final String description;

  factory UsersDevicesControlTrustLevelDefinition.fromJson(
    Map<String, dynamic> json,
  ) {
    return UsersDevicesControlTrustLevelDefinition(
      level: json['level'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class UsersDevicesControlAccessRule {
  const UsersDevicesControlAccessRule({
    required this.moduleId,
    required this.requiresTrustLevel,
    required this.requiresApprovalFor,
    this.viewPermission = '',
    this.editPermission = '',
    this.adminPermission = '',
    this.requestPermission = '',
    this.executePermission = '',
    this.controlPermission = '',
  });

  final String moduleId;
  final String viewPermission;
  final String editPermission;
  final String adminPermission;
  final String requestPermission;
  final String executePermission;
  final String controlPermission;
  final int requiresTrustLevel;
  final List<String> requiresApprovalFor;

  factory UsersDevicesControlAccessRule.fromJson(Map<String, dynamic> json) {
    return UsersDevicesControlAccessRule(
      moduleId: json['module_id'] as String? ?? '',
      viewPermission: json['view_permission'] as String? ?? '',
      editPermission: json['edit_permission'] as String? ?? '',
      adminPermission: json['admin_permission'] as String? ?? '',
      requestPermission: json['request_permission'] as String? ?? '',
      executePermission: json['execute_permission'] as String? ?? '',
      controlPermission: json['control_permission'] as String? ?? '',
      requiresTrustLevel: json['requires_trust_level'] as int? ?? 0,
      requiresApprovalFor: _stringList(json['requires_approval_for']),
    );
  }
}

class UsersDevicesControlSnapshot {
  const UsersDevicesControlSnapshot({
    required this.users,
    required this.devices,
    required this.roles,
    required this.permissions,
    required this.trustLevels,
    required this.approvalQueue,
    required this.auditLog,
    required this.accessRules,
  });

  final List<UsersDevicesControlUser> users;
  final List<UsersDevicesControlDevice> devices;
  final List<UsersDevicesControlRoleDefinition> roles;
  final List<UsersDevicesControlPermissionDefinition> permissions;
  final List<UsersDevicesControlTrustLevelDefinition> trustLevels;
  final List<UsersDevicesControlApprovalRequest> approvalQueue;
  final List<UsersDevicesControlAuditEvent> auditLog;
  final List<UsersDevicesControlAccessRule> accessRules;
}

class UsersDevicesControlAccessDecision {
  const UsersDevicesControlAccessDecision({
    required this.allowed,
    required this.requiresApproval,
    required this.reason,
  });

  final bool allowed;
  final bool requiresApproval;
  final String reason;
}

class UsersDevicesControlRepository {
  const UsersDevicesControlRepository({
    this.moduleRootPath = 'modules/01_USERS_AND_DEVICES_CONTROL',
    this.storageNamespace = 'users_devices_control',
  });

  final String moduleRootPath;
  final String storageNamespace;

  Future<UsersDevicesControlSnapshot> loadSnapshot() async {
    return UsersDevicesControlSnapshot(
      users: await _readUsers(),
      devices: await _readDevices(),
      roles: await _readRoles(),
      permissions: await _readPermissions(),
      trustLevels: await _readTrustLevels(),
      approvalQueue: await _readApprovals(),
      auditLog: await _readAuditLog(),
      accessRules: await _readAccessRules(),
    );
  }

  Future<UsersDevicesControlUser?> getUserById(String id) async {
    final users = await _readUsers();
    for (final user in users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  Future<UsersDevicesControlDevice?> getDeviceById(String id) async {
    final devices = await _readDevices();
    for (final device in devices) {
      if (device.id == id) {
        return device;
      }
    }
    return null;
  }

  Future<UsersDevicesControlUser> registerUser(
    UsersDevicesControlUser user,
  ) async {
    final users = await _readUsers();
    final existingIndex = users.indexWhere((item) => item.id == user.id);
    if (existingIndex >= 0) {
      users[existingIndex] = user;
    } else {
      users.add(user);
    }
    await _writeUsers(users);
    await createAuditEvent(
      actorId: user.id,
      deviceId: user.linkedDevices.isNotEmpty ? user.linkedDevices.first : '',
      eventType: 'user_registered',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'register_user',
      result: 'allowed',
      reason: 'User record saved locally.',
    );
    return user;
  }

  Future<UsersDevicesControlDevice> registerDevice(
    UsersDevicesControlDevice device,
  ) async {
    final devices = await _readDevices();
    final existingIndex = devices.indexWhere((item) => item.id == device.id);
    if (existingIndex >= 0) {
      devices[existingIndex] = device;
    } else {
      devices.add(device);
    }
    await _writeDevices(devices);
    await createAuditEvent(
      actorId: device.ownerId,
      deviceId: device.id,
      eventType: 'device_registered',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'register_device',
      result: 'allowed',
      reason: 'Device record saved locally.',
    );
    return device;
  }

  Future<void> archiveDevice(
    String deviceId, {
    String reason = 'Device archived locally.',
  }) async {
    final devices = await _readDevices();
    final index = devices.indexWhere((device) => device.id == deviceId);
    if (index < 0) {
      throw StateError('Device not found: $deviceId');
    }

    final updated = devices[index].copyWith(status: 'archived');
    devices[index] = updated;
    await _writeDevices(devices);
    await createAuditEvent(
      actorId: updated.ownerId,
      deviceId: updated.id,
      eventType: 'device_archived',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'archive_device',
      result: 'allowed',
      reason: reason,
    );
  }

  Future<void> restoreDevice(
    String deviceId, {
    String reason = 'Device restored locally.',
  }) async {
    final devices = await _readDevices();
    final index = devices.indexWhere((device) => device.id == deviceId);
    if (index < 0) {
      throw StateError('Device not found: $deviceId');
    }

    final updated = devices[index].copyWith(status: 'trusted');
    devices[index] = updated;
    await _writeDevices(devices);
    await createAuditEvent(
      actorId: updated.ownerId,
      deviceId: updated.id,
      eventType: 'device_restored',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'restore_device',
      result: 'allowed',
      reason: reason,
    );
  }

  Future<void> deleteDevice(
    String deviceId, {
    String reason = 'Device deleted locally.',
  }) async {
    final devices = await _readDevices();
    final index = devices.indexWhere((device) => device.id == deviceId);
    if (index < 0) {
      throw StateError('Device not found: $deviceId');
    }

    final removed = devices.removeAt(index);
    await _writeDevices(devices);
    await createAuditEvent(
      actorId: removed.ownerId,
      deviceId: removed.id,
      eventType: 'device_deleted',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'delete_device',
      result: 'allowed',
      reason: reason,
    );
  }

  Future<UsersDevicesControlUser> assignRole(
    String userId,
    String role,
  ) async {
    final users = await _readUsers();
    final index = users.indexWhere((user) => user.id == userId);
    if (index < 0) {
      throw StateError('User not found: $userId');
    }

    final updated = users[index].copyWith(role: role);
    users[index] = updated;
    await _writeUsers(users);
    await createAuditEvent(
      actorId: userId,
      deviceId: updated.linkedDevices.isNotEmpty ? updated.linkedDevices.first : '',
      eventType: 'role_assigned',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'assign_role',
      result: 'allowed',
      reason: 'Role updated locally.',
    );
    return updated;
  }

  Future<UsersDevicesControlUser> assignPermission(
    String userId,
    String permission,
  ) async {
    final users = await _readUsers();
    final index = users.indexWhere((user) => user.id == userId);
    if (index < 0) {
      throw StateError('User not found: $userId');
    }

    final existing = users[index].permissions;
    final updatedPermissions = existing.contains(permission)
        ? existing
        : <String>[...existing, permission];
    final updated = users[index].copyWith(permissions: updatedPermissions);
    users[index] = updated;
    await _writeUsers(users);
    await createAuditEvent(
      actorId: userId,
      deviceId: updated.linkedDevices.isNotEmpty ? updated.linkedDevices.first : '',
      eventType: 'permission_assigned',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'assign_permission',
      result: 'allowed',
      reason: 'Permission updated locally.',
    );
    return updated;
  }

  Future<void> archiveUser(
    String userId, {
    String reason = 'User archived locally.',
  }) async {
    final users = await _readUsers();
    final index = users.indexWhere((user) => user.id == userId);
    if (index < 0) {
      throw StateError('User not found: $userId');
    }

    final updated = users[index].copyWith(status: 'archived');
    users[index] = updated;
    await _writeUsers(users);
    await createAuditEvent(
      actorId: userId,
      deviceId:
          updated.linkedDevices.isNotEmpty ? updated.linkedDevices.first : '',
      eventType: 'user_archived',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'archive_user',
      result: 'allowed',
      reason: reason,
    );
  }

  Future<void> restoreUser(
    String userId, {
    String reason = 'User restored locally.',
  }) async {
    final users = await _readUsers();
    final index = users.indexWhere((user) => user.id == userId);
    if (index < 0) {
      throw StateError('User not found: $userId');
    }

    final updated = users[index].copyWith(status: 'active');
    users[index] = updated;
    await _writeUsers(users);
    await createAuditEvent(
      actorId: userId,
      deviceId:
          updated.linkedDevices.isNotEmpty ? updated.linkedDevices.first : '',
      eventType: 'user_restored',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'restore_user',
      result: 'allowed',
      reason: reason,
    );
  }

  Future<void> deleteUser(
    String userId, {
    String reason = 'User deleted locally.',
  }) async {
    final users = await _readUsers();
    final index = users.indexWhere((user) => user.id == userId);
    if (index < 0) {
      throw StateError('User not found: $userId');
    }

    final removed = users.removeAt(index);
    await _writeUsers(users);
    await createAuditEvent(
      actorId: removed.id,
      deviceId:
          removed.linkedDevices.isNotEmpty ? removed.linkedDevices.first : '',
      eventType: 'user_deleted',
      targetModule: '01_USERS_AND_DEVICES_CONTROL',
      action: 'delete_user',
      result: 'allowed',
      reason: reason,
    );
  }

  Future<bool> checkPermission(
    String userId,
    String permission, {
    String? deviceId,
  }) async {
    final user = await getUserById(userId);
    if (user == null) {
      return false;
    }

    if (user.status == 'archived' || user.status == 'disabled') {
      return false;
    }

    if (user.permissions.contains('*') || user.permissions.contains(permission)) {
      return true;
    }

    final roleDefinition = await _roleFor(user.role);
    if (roleDefinition.permissions.contains('*') ||
        roleDefinition.permissions.contains(permission)) {
      return true;
    }

    return false;
  }

  Future<bool> checkDeviceTrust(
    String deviceId,
    int requiredTrustLevel,
  ) async {
    final device = await getDeviceById(deviceId);
    if (device == null) {
      return false;
    }

    if (device.status == 'archived' || device.status == 'blocked') {
      return false;
    }

    return device.trustLevel >= requiredTrustLevel;
  }

  Future<UsersDevicesControlAccessDecision> canOpenModule(
    String userId,
    String deviceId,
    String moduleId,
  ) async {
    return _evaluateAccess(
      userId: userId,
      deviceId: deviceId,
      moduleId: moduleId,
      action: 'view',
    );
  }

  Future<UsersDevicesControlAccessDecision> canPerformAction(
    String userId,
    String deviceId,
    String moduleId,
    String action,
  ) async {
    return _evaluateAccess(
      userId: userId,
      deviceId: deviceId,
      moduleId: moduleId,
      action: action,
    );
  }

  Future<UsersDevicesControlAuditEvent> createAuditEvent({
    required String actorId,
    required String deviceId,
    required String eventType,
    required String targetModule,
    required String action,
    required String result,
    required String reason,
  }) async {
    final log = await _readAuditLog();
    final event = UsersDevicesControlAuditEvent(
      eventId: 'audit_${DateTime.now().microsecondsSinceEpoch}',
      timestamp: DateTime.now().toUtc().toIso8601String(),
      actorId: actorId,
      deviceId: deviceId,
      eventType: eventType,
      targetModule: targetModule,
      action: action,
      result: result,
      reason: reason,
    );
    log.add(event);
    await _writeAuditLog(log);
    return event;
  }

  Future<UsersDevicesControlApprovalRequest> createApprovalRequest({
    required String requestedBy,
    required String deviceId,
    required String targetModule,
    required String action,
    required String riskLevel,
    required String reason,
  }) async {
    final queue = await _readApprovals();
    final request = UsersDevicesControlApprovalRequest(
      requestId: 'approval_${DateTime.now().microsecondsSinceEpoch}',
      timestamp: DateTime.now().toUtc().toIso8601String(),
      requestedBy: requestedBy,
      deviceId: deviceId,
      targetModule: targetModule,
      action: action,
      status: 'pending',
      riskLevel: riskLevel,
      reason: reason,
    );
    queue.add(request);
    await _writeApprovals(queue);
    await createAuditEvent(
      actorId: requestedBy,
      deviceId: deviceId,
      eventType: 'approval_requested',
      targetModule: targetModule,
      action: action,
      result: 'pending',
      reason: reason,
    );
    return request;
  }

  Future<UsersDevicesControlApprovalRequest> approveRequest(
    String requestId, {
    required String reviewedBy,
  }) async {
    return _reviewRequest(
      requestId,
      reviewedBy: reviewedBy,
      status: 'approved',
    );
  }

  Future<UsersDevicesControlApprovalRequest> denyRequest(
    String requestId, {
    required String reviewedBy,
  }) async {
    return _reviewRequest(
      requestId,
      reviewedBy: reviewedBy,
      status: 'denied',
    );
  }

  Future<UsersDevicesControlApprovalRequest> _reviewRequest(
    String requestId, {
    required String reviewedBy,
    required String status,
  }) async {
    final queue = await _readApprovals();
    final index = queue.indexWhere((request) => request.requestId == requestId);
    if (index < 0) {
      throw StateError('Approval request not found: $requestId');
    }

    final request = queue[index];
    final updated = UsersDevicesControlApprovalRequest(
      requestId: request.requestId,
      timestamp: request.timestamp,
      requestedBy: request.requestedBy,
      deviceId: request.deviceId,
      targetModule: request.targetModule,
      action: request.action,
      status: status,
      riskLevel: request.riskLevel,
      reason: request.reason,
      reviewedBy: reviewedBy,
      reviewedAt: DateTime.now().toUtc().toIso8601String(),
    );
    queue[index] = updated;
    await _writeApprovals(queue);
    await createAuditEvent(
      actorId: reviewedBy,
      deviceId: request.deviceId,
      eventType: 'approval_reviewed',
      targetModule: request.targetModule,
      action: request.action,
      result: status,
      reason: request.reason,
    );
    return updated;
  }

  Future<UsersDevicesControlAccessDecision> _evaluateAccess({
    required String userId,
    required String deviceId,
    required String moduleId,
    required String action,
  }) async {
    final user = await getUserById(userId);
    if (user == null) {
      return const UsersDevicesControlAccessDecision(
        allowed: false,
        requiresApproval: false,
        reason: 'Unknown user.',
      );
    }

    final device = await getDeviceById(deviceId);
    if (device == null) {
      return const UsersDevicesControlAccessDecision(
        allowed: false,
        requiresApproval: false,
        reason: 'Unknown device.',
      );
    }

    if (user.status == 'archived' || user.status == 'disabled') {
      final decision = const UsersDevicesControlAccessDecision(
        allowed: false,
        requiresApproval: false,
        reason: 'User is archived or disabled.',
      );
      await createAuditEvent(
        actorId: userId,
        deviceId: deviceId,
        eventType: 'module_access_checked',
        targetModule: moduleId,
        action: action,
        result: 'denied',
        reason: decision.reason,
      );
      return decision;
    }

    if (device.status == 'archived' || device.status == 'blocked') {
      final decision = const UsersDevicesControlAccessDecision(
        allowed: false,
        requiresApproval: false,
        reason: 'Device is archived or blocked.',
      );
      await createAuditEvent(
        actorId: userId,
        deviceId: deviceId,
        eventType: 'module_access_checked',
        targetModule: moduleId,
        action: action,
        result: 'denied',
        reason: decision.reason,
      );
      return decision;
    }

    final rule = await _ruleFor(moduleId);
    if (rule == null) {
      final decision = const UsersDevicesControlAccessDecision(
        allowed: false,
        requiresApproval: true,
        reason: 'No access rule is configured for this module.',
      );
      await createAuditEvent(
        actorId: userId,
        deviceId: deviceId,
        eventType: 'module_access_checked',
        targetModule: moduleId,
        action: action,
        result: 'denied',
        reason: decision.reason,
      );
      return decision;
    }

    final requiredTrust = rule.requiresTrustLevel;
    final trustAllowed = device.trustLevel >= requiredTrust;
    if (!trustAllowed) {
      final decision = UsersDevicesControlAccessDecision(
        allowed: false,
        requiresApproval: true,
        reason: 'Device trust must be at least level $requiredTrust.',
      );
      await createAuditEvent(
        actorId: userId,
        deviceId: deviceId,
        eventType: 'module_access_checked',
        targetModule: moduleId,
        action: action,
        result: 'denied',
        reason: decision.reason,
      );
      return decision;
    }

    final requiredPermission = _requiredPermission(rule, action);
    final hasPermission = requiredPermission.isEmpty
        ? true
        : await checkPermission(userId, requiredPermission, deviceId: deviceId);
    if (!hasPermission) {
      final decision = UsersDevicesControlAccessDecision(
        allowed: false,
        requiresApproval: true,
        reason: 'Missing required permission: $requiredPermission.',
      );
      await createAuditEvent(
        actorId: userId,
        deviceId: deviceId,
        eventType: 'module_access_checked',
        targetModule: moduleId,
        action: action,
        result: 'denied',
        reason: decision.reason,
      );
      return decision;
    }

    if (rule.requiresApprovalFor.contains(action)) {
      final decision = const UsersDevicesControlAccessDecision(
        allowed: false,
        requiresApproval: true,
        reason: 'Action requires approval.',
      );
      await createAuditEvent(
        actorId: userId,
        deviceId: deviceId,
        eventType: 'module_access_checked',
        targetModule: moduleId,
        action: action,
        result: 'pending',
        reason: decision.reason,
      );
      return decision;
    }

    const decision = UsersDevicesControlAccessDecision(
      allowed: true,
      requiresApproval: false,
      reason: 'Identity, role, permission, and trust checks passed.',
    );
    await createAuditEvent(
      actorId: userId,
      deviceId: deviceId,
      eventType: 'module_access_checked',
      targetModule: moduleId,
      action: action,
      result: 'allowed',
      reason: decision.reason,
    );
    return decision;
  }

  String _requiredPermission(
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

  Future<UsersDevicesControlRoleDefinition> _roleFor(String role) async {
    final roles = await _readRoles();
    for (final item in roles) {
      if (item.role.toLowerCase() == role.toLowerCase()) {
        return item;
      }
    }
    return const UsersDevicesControlRoleDefinition(role: '', permissions: []);
  }

  Future<UsersDevicesControlAccessRule?> _ruleFor(String moduleId) async {
    final rules = await _readAccessRules();
    for (final rule in rules) {
      if (rule.moduleId == moduleId) {
        return rule;
      }
    }
    return null;
  }

  Future<List<UsersDevicesControlUser>> _readUsers() async {
    final data = await _readJsonList(_usersStoragePath, _usersExamplePath);
    return data.map(UsersDevicesControlUser.fromJson).toList(growable: false);
  }

  Future<List<UsersDevicesControlDevice>> _readDevices() async {
    final data = await _readJsonList(_devicesStoragePath, _devicesExamplePath);
    return data.map(UsersDevicesControlDevice.fromJson).toList(growable: false);
  }

  Future<List<UsersDevicesControlRoleDefinition>> _readRoles() async {
    final data = await _readJsonList(_rolesStoragePath, _rolesExamplePath);
    return data
        .map(UsersDevicesControlRoleDefinition.fromJson)
        .toList(growable: false);
  }

  Future<List<UsersDevicesControlPermissionDefinition>> _readPermissions() async {
    final data = await _readJsonList(
      _permissionsStoragePath,
      _permissionsExamplePath,
    );
    return data
        .map(UsersDevicesControlPermissionDefinition.fromJson)
        .toList(growable: false);
  }

  Future<List<UsersDevicesControlTrustLevelDefinition>> _readTrustLevels() async {
    final data = await _readJsonList(
      _trustLevelsStoragePath,
      _trustLevelsExamplePath,
    );
    return data
        .map(UsersDevicesControlTrustLevelDefinition.fromJson)
        .toList(growable: false);
  }

  Future<List<UsersDevicesControlApprovalRequest>> _readApprovals() async {
    final data = await _readJsonList(
      _approvalQueueStoragePath,
      _approvalQueueExamplePath,
    );
    return data
        .map(UsersDevicesControlApprovalRequest.fromJson)
        .toList(growable: false);
  }

  Future<List<UsersDevicesControlAuditEvent>> _readAuditLog() async {
    final data = await _readJsonList(
      _auditLogStoragePath,
      _auditLogExamplePath,
    );
    return data
        .map(UsersDevicesControlAuditEvent.fromJson)
        .toList(growable: false);
  }

  Future<List<UsersDevicesControlAccessRule>> _readAccessRules() async {
    final raw = await _readJsonMap(
      _accessRulesStoragePath,
      _accessRulesExamplePath,
    );
    final rules = raw['rules'];
    if (rules is! List) {
      return const <UsersDevicesControlAccessRule>[];
    }
    return rules
        .whereType<Map<String, dynamic>>()
        .map(UsersDevicesControlAccessRule.fromJson)
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _readJsonList(
    Future<String> Function() pathProvider,
    String fallbackPath,
  ) async {
    final file = File(await pathProvider());
    if (!await file.exists()) {
      final fallbackFile = File(fallbackPath);
      if (!await fallbackFile.exists()) {
        return <Map<String, dynamic>>[];
      }
      await file.parent.create(recursive: true);
      await file.writeAsString(await fallbackFile.readAsString());
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> _readJsonMap(
    Future<String> Function() pathProvider,
    String fallbackPath,
  ) async {
    final file = File(await pathProvider());
    if (!await file.exists()) {
      final fallbackFile = File(fallbackPath);
      if (!await fallbackFile.exists()) {
        return <String, dynamic>{};
      }
      await file.parent.create(recursive: true);
      await file.writeAsString(await fallbackFile.readAsString());
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  }

  Future<void> _writeUsers(List<UsersDevicesControlUser> users) async {
    await _writeJsonList(
      _usersStoragePath,
      users.map((user) => user.toJson()).toList(),
    );
  }

  Future<void> _writeDevices(List<UsersDevicesControlDevice> devices) async {
    await _writeJsonList(
      _devicesStoragePath,
      devices.map((device) => device.toJson()).toList(),
    );
  }

  Future<void> _writeApprovals(
    List<UsersDevicesControlApprovalRequest> approvals,
  ) async {
    await _writeJsonList(
      _approvalQueueStoragePath,
      approvals.map((request) => request.toJson()).toList(),
    );
  }

  Future<void> _writeAuditLog(
    List<UsersDevicesControlAuditEvent> events,
  ) async {
    await _writeJsonList(
      _auditLogStoragePath,
      events.map((event) => event.toJson()).toList(),
    );
  }

  Future<void> _writeJsonList(
    Future<String> Function() pathProvider,
    List<Map<String, dynamic>> jsonList,
  ) async {
    final file = File(await pathProvider());
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(jsonList));
  }

  Future<String> _storageBasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, storageNamespace);
  }

  Future<String> _storageDataPath() async {
    return path.join(await _storageBasePath(), 'data');
  }

  Future<String> _storageConfigPath() async {
    return path.join(await _storageBasePath(), 'config');
  }

  Future<String> _usersStoragePath() async {
    return path.join(await _storageDataPath(), 'users.json');
  }

  Future<String> _devicesStoragePath() async {
    return path.join(await _storageDataPath(), 'devices.json');
  }

  Future<String> _rolesStoragePath() async {
    return path.join(await _storageDataPath(), 'roles.json');
  }

  Future<String> _permissionsStoragePath() async {
    return path.join(await _storageDataPath(), 'permissions.json');
  }

  Future<String> _trustLevelsStoragePath() async {
    return path.join(await _storageDataPath(), 'trust_levels.json');
  }

  Future<String> _approvalQueueStoragePath() async {
    return path.join(await _storageDataPath(), 'approval_queue.json');
  }

  Future<String> _auditLogStoragePath() async {
    return path.join(await _storageDataPath(), 'audit_log.json');
  }

  Future<String> _accessRulesStoragePath() async {
    return path.join(await _storageConfigPath(), 'module_access_rules.json');
  }

  String get _basePath => moduleRootPath;
  String get _dataPath => '$_basePath/data';
  String get _configPath => '$_basePath/config';

  String get _usersExamplePath => '$_dataPath/users.example.json';
  String get _devicesExamplePath => '$_dataPath/devices.example.json';
  String get _rolesExamplePath => '$_dataPath/roles.example.json';
  String get _permissionsExamplePath => '$_dataPath/permissions.example.json';
  String get _trustLevelsExamplePath => '$_dataPath/trust_levels.example.json';
  String get _approvalQueueExamplePath => '$_dataPath/approval_queue.example.json';
  String get _auditLogExamplePath => '$_dataPath/audit_log.example.json';
  String get _accessRulesExamplePath => '$_configPath/module_access_rules.json';
}

List<String> _stringList(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }

  return value.whereType<String>().toList(growable: false);
}
