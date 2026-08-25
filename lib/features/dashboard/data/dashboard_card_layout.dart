import 'dart:convert';

class DashboardCardLayout {
  const DashboardCardLayout({
    required this.orderedIds,
    required this.hiddenIds,
  });

  static const dailyFlowId = 'daily_flow';
  static const nextStepId = 'next_step';
  static const treasuryId = 'treasury';
  static const commandCentreId = 'command_centre';
  static const supportStackId = 'support_stack';

  static const defaultOrder = <String>[
    dailyFlowId,
    nextStepId,
    treasuryId,
    commandCentreId,
    supportStackId,
  ];

  final List<String> orderedIds;
  final Set<String> hiddenIds;

  factory DashboardCardLayout.defaults() {
    return const DashboardCardLayout(
      orderedIds: defaultOrder,
      hiddenIds: <String>{},
    );
  }

  factory DashboardCardLayout.fromJson(String? encoded) {
    if (encoded == null || encoded.trim().isEmpty) {
      return DashboardCardLayout.defaults();
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        return DashboardCardLayout.defaults();
      }

      final savedOrder = decoded['orderedIds'];
      final savedHidden = decoded['hiddenIds'];
      final order = <String>[];
      if (savedOrder is List) {
        for (final value in savedOrder) {
          if (value is String &&
              defaultOrder.contains(value) &&
              !order.contains(value)) {
            order.add(value);
          }
        }
      }
      for (final id in defaultOrder) {
        if (!order.contains(id)) {
          order.add(id);
        }
      }

      final hidden = <String>{};
      if (savedHidden is List) {
        for (final value in savedHidden) {
          if (value is String &&
              defaultOrder.contains(value) &&
              value != dailyFlowId) {
            hidden.add(value);
          }
        }
      }

      return DashboardCardLayout(orderedIds: order, hiddenIds: hidden);
    } catch (_) {
      return DashboardCardLayout.defaults();
    }
  }

  DashboardCardLayout copyWith({
    List<String>? orderedIds,
    Set<String>? hiddenIds,
  }) {
    return DashboardCardLayout(
      orderedIds: orderedIds ?? this.orderedIds,
      hiddenIds: hiddenIds ?? this.hiddenIds,
    );
  }

  String toJson() {
    return jsonEncode({
      'orderedIds': orderedIds,
      'hiddenIds': hiddenIds.toList(),
    });
  }

  List<String> get visibleOrderedIds {
    return orderedIds.where((id) => !hiddenIds.contains(id)).toList();
  }
}
