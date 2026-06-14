import 'dock_position.dart';

class DockLayoutState {
  const DockLayoutState({
    this.positionsByModuleId = const <String, DockPosition>{},
    this.floatingAnchorsByModuleId = const <String, DockAnchor>{},
  });

  final Map<String, DockPosition> positionsByModuleId;
  final Map<String, DockAnchor> floatingAnchorsByModuleId;

  DockPosition? positionFor(String moduleId) {
    return positionsByModuleId[moduleId];
  }

  DockAnchor? floatingAnchorFor(String moduleId) {
    return floatingAnchorsByModuleId[moduleId];
  }

  DockLayoutState setPosition(String moduleId, DockPosition position) {
    final next = Map<String, DockPosition>.from(positionsByModuleId);
    next[moduleId] = position;
    return DockLayoutState(
      positionsByModuleId: Map.unmodifiable(next),
      floatingAnchorsByModuleId: floatingAnchorsByModuleId,
    );
  }

  DockLayoutState setFloatingAnchor(String moduleId, DockAnchor anchor) {
    final next = Map<String, DockAnchor>.from(floatingAnchorsByModuleId);
    next[moduleId] = anchor;
    return DockLayoutState(
      positionsByModuleId: positionsByModuleId,
      floatingAnchorsByModuleId: Map.unmodifiable(next),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positionsByModuleId': positionsByModuleId.map(
        (moduleId, position) => MapEntry(moduleId, position.name),
      ),
      'floatingAnchorsByModuleId': floatingAnchorsByModuleId.map(
        (moduleId, anchor) => MapEntry(moduleId, anchor.name),
      ),
    };
  }

  factory DockLayoutState.fromJson(Map<String, dynamic> json) {
    final positions = <String, DockPosition>{};
    final rawPositions = json['positionsByModuleId'];
    if (rawPositions is Map) {
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
    }

    final anchors = <String, DockAnchor>{};
    final rawAnchors = json['floatingAnchorsByModuleId'];
    if (rawAnchors is Map) {
      rawAnchors.forEach((key, value) {
        final moduleId = key.toString().trim();
        if (moduleId.isEmpty) {
          return;
        }
        final anchor = _parseDockAnchor(value);
        if (anchor != null) {
          anchors[moduleId] = anchor;
        }
      });
    }

    if (positions.isEmpty && anchors.isEmpty) {
      return const DockLayoutState();
    }

    return DockLayoutState(
      positionsByModuleId: Map.unmodifiable(positions),
      floatingAnchorsByModuleId: Map.unmodifiable(anchors),
    );
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

  static DockAnchor? _parseDockAnchor(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    switch (text) {
      case 'topleft':
      case 'top_left':
      case 'top left':
        return DockAnchor.topLeft;
      case 'topright':
      case 'top_right':
      case 'top right':
        return DockAnchor.topRight;
      case 'bottomleft':
      case 'bottom_left':
      case 'bottom left':
        return DockAnchor.bottomLeft;
      case 'bottomright':
      case 'bottom_right':
      case 'bottom right':
        return DockAnchor.bottomRight;
      default:
        return null;
    }
  }
}
