import 'dock_layout_state.dart';
import 'dock_position.dart';

class DockManager {
  const DockManager({this.state = const DockLayoutState()});

  final DockLayoutState state;

  DockPosition? positionFor(String moduleId) {
    return state.positionFor(moduleId);
  }

  DockManager mount(String moduleId, DockPosition position) {
    return DockManager(state: state.setPosition(moduleId, position));
  }
}
