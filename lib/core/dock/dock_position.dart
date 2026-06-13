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
