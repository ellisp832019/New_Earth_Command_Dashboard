import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../projects/application/projects_controller.dart';
import '../application/tasks_controller.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  const AddEditTaskScreen({super.key, this.taskId, this.projectId});

  final String? taskId;
  final String? projectId;

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _estimatedMinutesController;
  late final TextEditingController _notesController;

  String? _projectId;
  String? _category;
  String _priority = 'Medium';
  String _status = 'Inbox';
  String? _energyLevel;
  bool _didLoadInitialData = false;
  bool _isSaving = false;

  static const _categoryOptions = [
    'Build',
    'Design',
    'Research',
    'Test',
    'Docs',
    'Planning',
    'Business',
    'Learning',
    'Content',
    'Admin',
    'Wellbeing',
  ];

  static const _priorityOptions = ['High', 'Medium', 'Low', 'Someday'];
  static const _statusOptions = [
    'Inbox',
    'Planned',
    'Today',
    'In Progress',
    'Blocked',
    'Done',
    'Parked',
  ];
  static const _energyOptions = ['Low', 'Medium', 'High'];

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _estimatedMinutesController = TextEditingController();
    _notesController = TextEditingController();
    _projectId = widget.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final theme = Theme.of(context);

    return projects.when(
      data: (projectItems) {
        if (!_isEditing) {
          return _buildScaffold(context, projectItems);
        }

        final task = ref.watch(taskProvider(widget.taskId!));
        return task.when(
          data: (item) {
            _loadInitialValues(item);
            return _buildScaffold(context, projectItems);
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Edit Task')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Task data could not be loaded for editing.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Task')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Task details could not be prepared right now.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Scaffold _buildScaffold(BuildContext context, List<Project> projects) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'New Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const Key('taskTitleField'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Please enter a task title.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('taskDescriptionField'),
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('taskProjectField'),
              initialValue: _projectId,
              decoration: const InputDecoration(
                labelText: 'Related Project',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No project selected'),
                ),
                ...projects.map(
                  (project) => DropdownMenuItem<String?>(
                    value: project.projectId,
                    child: Text(project.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _projectId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('taskCategoryField'),
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No category selected'),
                ),
                ..._categoryOptions.map(
                  (option) => DropdownMenuItem<String?>(
                    value: option,
                    child: Text(option),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _category = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('taskPriorityField'),
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: _priorityOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _priority = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('taskStatusField'),
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _status = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('taskEnergyField'),
              initialValue: _energyLevel,
              decoration: const InputDecoration(
                labelText: 'Energy Level',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No energy selected'),
                ),
                ..._energyOptions.map(
                  (option) => DropdownMenuItem<String?>(
                    value: option,
                    child: Text(option),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _energyLevel = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('taskEstimatedMinutesField'),
              controller: _estimatedMinutesController,
              decoration: const InputDecoration(
                labelText: 'Estimated Minutes',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }

                if (int.tryParse(trimmed) == null) {
                  return 'Enter minutes as a number.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('taskNotesField'),
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('saveTaskButton'),
              onPressed: _isSaving ? null : () => _saveTask(context),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isEditing ? 'Save Task' : 'Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadInitialValues(Task task) {
    if (_didLoadInitialData) {
      return;
    }

    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _estimatedMinutesController.text = task.estimatedMinutes?.toString() ?? '';
    _notesController.text = task.notes ?? '';
    _projectId = task.projectId;
    _category = task.category;
    _priority = task.priority;
    _status = task.status;
    _energyLevel = task.energyLevel;
    _didLoadInitialData = true;
  }

  Future<void> _saveTask(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(tasksControllerProvider);
      final estimatedMinutes = _parseEstimatedMinutes();
      final messenger = ScaffoldMessenger.of(context);
      final title = _titleController.text.trim();
      final description = _optionalText(_descriptionController.text);
      final notes = _optionalText(_notesController.text);

      if (_isEditing) {
        final task = await controller.updateTask(
          taskId: widget.taskId!,
          title: title,
          projectId: _projectId,
          description: description,
          category: _category,
          priority: _priority,
          status: _status,
          energyLevel: _energyLevel,
          estimatedMinutes: estimatedMinutes,
          notes: notes,
        );
        if (!context.mounted) return;
        context.go(RouteNames.tasks);
        messenger.showSnackBar(SnackBar(content: Text('${task.title} saved.')));
        return;
      }

      final task = await controller.createTask(
        title: title,
        projectId: _projectId,
        description: description,
        category: _category,
        priority: _priority,
        status: _status,
        energyLevel: _energyLevel,
        estimatedMinutes: estimatedMinutes,
        notes: notes,
      );
      if (!context.mounted) return;
      context.go(RouteNames.tasks);
      messenger.showSnackBar(SnackBar(content: Text('${task.title} created.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int? _parseEstimatedMinutes() {
    final trimmed = _estimatedMinutesController.text.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return int.tryParse(trimmed);
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
