enum DockPosition { left, right, bottom, floating, fullscreen }

extension DockPositionLabel on DockPosition {
  String get label {
    switch (this) {
      case DockPosition.left:
        return 'Left';
      case DockPosition.right:
        return 'Right';
      case DockPosition.bottom:
        return 'Bottom';
      case DockPosition.floating:
        return 'Floating';
      case DockPosition.fullscreen:
        return 'Fullscreen';
    }
  }
}

enum DockAnchor { topLeft, topRight, bottomLeft, bottomRight }

extension DockAnchorLabel on DockAnchor {
  String get label {
    switch (this) {
      case DockAnchor.topLeft:
        return 'Top left';
      case DockAnchor.topRight:
        return 'Top right';
      case DockAnchor.bottomLeft:
        return 'Bottom left';
      case DockAnchor.bottomRight:
        return 'Bottom right';
    }
  }
}
