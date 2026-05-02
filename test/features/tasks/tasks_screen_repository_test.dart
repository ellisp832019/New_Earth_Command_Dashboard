import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/core/database/app_database.dart';
import 'package:new_earth_command_dashboard/features/tasks/data/task_repository.dart';

void main() {
  test('task repository returns active tasks newest first', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    var minute = 0;
    final repository = TaskRepository(
      database,
      now: () => DateTime(2026, 5, 2, 9, minute++),
    );

    await repository.createTask(title: 'First task');
    await repository.createTask(title: 'Second task');

    final tasks = await repository.getActiveTasks();

    expect(tasks, hasLength(2));
    expect(tasks.first.title, 'Second task');
    expect(tasks.last.title, 'First task');
  });
}
