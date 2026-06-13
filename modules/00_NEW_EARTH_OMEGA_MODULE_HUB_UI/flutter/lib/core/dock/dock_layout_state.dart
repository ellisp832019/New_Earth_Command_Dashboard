import 'dock_position.dart';

class DockLayoutState {
  const DockLayoutState({
    this.leftModuleId,
    this.rightModuleId,
    this.bottomModuleId,
    this.fullscreenModuleId,
  });

  final String? leftModuleId;
  final String? rightModuleId;
  final String? bottomModuleId;
  final String? fullscreenModuleId;

  String? moduleFor(DockPosition position) {
    switch (position) {
      case DockPosition.left:
        return leftModuleId;
      case DockPosition.right:
        return rightModuleId;
      case DockPosition.bottom:
        return bottomModuleId;
      case DockPosition.fullscreen:
        return fullscreenModuleId;
    }
  }

  DockLayoutState mount(String moduleId, DockPosition position) {
    switch (position) {
      case DockPosition.left:
        return DockLayoutState(leftModuleId: moduleId, rightModuleId: rightModuleId, bottomModuleId: bottomModuleId, fullscreenModuleId: fullscreenModuleId);
      case DockPosition.right:
        return DockLayoutState(leftModuleId: leftModuleId, rightModuleId: moduleId, bottomModuleId: bottomModuleId, fullscreenModuleId: fullscreenModuleId);
      case DockPosition.bottom:
        return DockLayoutState(leftModuleId: leftModuleId, rightModuleId: rightModuleId, bottomModuleId: moduleId, fullscreenModuleId: fullscreenModuleId);
      case DockPosition.fullscreen:
        return DockLayoutState(leftModuleId: leftModuleId, rightModuleId: rightModuleId, bottomModuleId: bottomModuleId, fullscreenModuleId: moduleId);
    }
  }
}
