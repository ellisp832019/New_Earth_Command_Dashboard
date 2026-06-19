import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecuritySessionState {
  const SecuritySessionState({
    required this.isUnlocked,
    required this.timeout,
    required this.lastActivityAt,
    required this.expiresAt,
    required this.activeUserLabel,
    required this.activeUserOnline,
  });

  const SecuritySessionState.locked({
    this.timeout = const Duration(minutes: 15),
  })  : isUnlocked = false,
        lastActivityAt = null,
        expiresAt = null,
        activeUserLabel = null,
        activeUserOnline = false;

  final bool isUnlocked;
  final Duration timeout;
  final DateTime? lastActivityAt;
  final DateTime? expiresAt;
  final String? activeUserLabel;
  final bool activeUserOnline;

  bool get isExpired {
    if (!isUnlocked) {
      return true;
    }

    final expiry = expiresAt;
    if (expiry == null) {
      return true;
    }

    return DateTime.now().isAfter(expiry);
  }

  Duration? get remaining {
    final expiry = expiresAt;
    if (!isUnlocked || expiry == null) {
      return null;
    }

    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative) {
      return Duration.zero;
    }

    return remaining;
  }

  SecuritySessionState copyWith({
    bool? isUnlocked,
    Duration? timeout,
    DateTime? lastActivityAt,
    DateTime? expiresAt,
    String? activeUserLabel,
    bool? activeUserOnline,
  }) {
    return SecuritySessionState(
      isUnlocked: isUnlocked ?? this.isUnlocked,
      timeout: timeout ?? this.timeout,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      expiresAt: expiresAt ?? this.expiresAt,
      activeUserLabel: activeUserLabel ?? this.activeUserLabel,
      activeUserOnline: activeUserOnline ?? this.activeUserOnline,
    );
  }
}

class SecuritySessionNotifier extends Notifier<SecuritySessionState> {
  Timer? _expiryTimer;

  @override
  SecuritySessionState build() {
    ref.onDispose(_cancelTimer);
    return const SecuritySessionState.locked();
  }

  void unlock({
    Duration? timeout,
    String? activeUserLabel,
    bool activeUserOnline = false,
  }) {
    final resolvedTimeout = timeout ?? state.timeout;
    final now = DateTime.now();
    state = SecuritySessionState(
      isUnlocked: true,
      timeout: resolvedTimeout,
      lastActivityAt: now,
      expiresAt: now.add(resolvedTimeout),
      activeUserLabel: activeUserLabel,
      activeUserOnline: activeUserOnline,
    );
    _scheduleExpiry();
  }

  void recordActivity() {
    if (!state.isUnlocked) {
      return;
    }

    final now = DateTime.now();
    state = state.copyWith(
      lastActivityAt: now,
      expiresAt: now.add(state.timeout),
    );
    _scheduleExpiry();
  }

  void lockNow() {
    _cancelTimer();
    state = const SecuritySessionState.locked();
  }

  void _scheduleExpiry() {
    _cancelTimer();
    final expiresAt = state.expiresAt;
    if (expiresAt == null) {
      return;
    }

    final delay = expiresAt.difference(DateTime.now());
    _expiryTimer = Timer(delay.isNegative ? Duration.zero : delay, lockNow);
  }

  void _cancelTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
  }
}

final securitySessionProvider =
    NotifierProvider<SecuritySessionNotifier, SecuritySessionState>(
      SecuritySessionNotifier.new,
    );
