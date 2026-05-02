import '../../features/tasks/data/task_repository.dart';

class TaskSelectionService {
  const TaskSelectionService(this._taskRepository, {this.topTaskLimit = 3});

  final TaskRepository _taskRepository;
  final int topTaskLimit;

  Future<void> addToTopThree(String taskId) async {
    final selectedTasks = await _taskRepository.getTopThreeTasks();
    final alreadySelected = selectedTasks.any((task) => task.taskId == taskId);
    if (alreadySelected) {
      return;
    }

    if (selectedTasks.length >= topTaskLimit) {
      throw StateError('Top 3 task limit reached.');
    }

    await _taskRepository.setTopThree(taskId, isTopThree: true);
  }

  Future<void> removeFromTopThree(String taskId) async {
    await _taskRepository.setTopThree(taskId, isTopThree: false);
  }
}
