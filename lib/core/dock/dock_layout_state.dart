import 'dock_position.dart';

class DockLayoutState {
  const DockLayoutState({
    this.positionsByModuleId = const <String, DockPosition>{},
  });

  final Map<String, DockPosition> positionsByModuleId;

  DockPosition? positionFor(String moduleId) {
    return positionsByModuleId[moduleId];
  }

  DockLayoutState setPosition(String moduleId, DockPosition position) {
    final next = Map<String, DockPosition>.from(positionsByModuleId);
    next[moduleId] = position;
    return DockLayoutState(positionsByModuleId: Map.unmodifiable(next));
  }

  Map<String, dynamic> toJson() {
    return {
      'positionsByModuleId': positionsByModuleId.map(
        (moduleId, position) => MapEntry(moduleId, position.name),
      ),
    };
  }

  factory DockLayoutState.fromJson(Map<String, dynamic> json) {
    final rawPositions = json['positionsByModuleId'];
    if (rawPositions is Map) {
      final positions = <String, DockPosition>{};
      rawPositions.forEach((key, value) {
        final moduleId = key.toString().trim();
        if (moduleId.isEmpty) {
          return;
        }
        final position = _parseDockPosition(value);
        if (position != null) {
          positions[moduleId] = position;
        }
      });
      return DockLayoutState(positionsByModuleId: Map.unmodifiable(positions));
    }

    return const DockLayoutState();
  }

  static DockPosition? _parseDockPosition(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    switch (text) {
      case 'left':
        return DockPosition.left;
      case 'right':
        return DockPosition.right;
      case 'bottom':
        return DockPosition.bottom;
      case 'floating':
        return DockPosition.floating;
      case 'fullscreen':
        return DockPosition.fullscreen;
      default:
        return null;
    }
  }
}
