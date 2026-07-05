import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../projects/application/projects_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../application/journal_controller.dart';

class AddEditJournalEntryScreen extends ConsumerStatefulWidget {
  const AddEditJournalEntryScreen({
    super.key,
    this.journalEntryId,
    this.projectId,
    this.initialTitle,
    this.initialWhatIWorkedOn,
    this.initialWhatILearned,
    this.initialNextActions,
  });

  final String? journalEntryId;
  final String? projectId;
  final String? initialTitle;
  final String? initialWhatIWorkedOn;
  final String? initialWhatILearned;
  final String? initialNextActions;

  bool get isEditing => journalEntryId != null;

  @override
  ConsumerState<AddEditJournalEntryScreen> createState() =>
      _AddEditJournalEntryScreenState();
}

class _AddEditJournalEntryScreenState
    extends ConsumerState<AddEditJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('d MMM yyyy');
  late final TextEditingController _titleController;
  late final TextEditingController _whatIWorkedOnController;
  late final TextEditingController _whatILearnedController;
  late final TextEditingController _nextActionsController;

  DateTime _selectedDate = DateTime.now();
  String? _projectId;
  String? _taskId;
  String? _category;
  bool _didLoadInitialData = false;
  bool _isSaving = false;

  static const _categoryOptions = [
    'Build Log',
    'Learning Note',
    'Project Update',
    'Founder Journey',
    'Problem / Fix',
    'Decision Log',
    'Content Seed',
    'Reflection',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _whatIWorkedOnController = TextEditingController(
      text: widget.initialWhatIWorkedOn ?? '',
    );
    _whatILearnedController = TextEditingController(
      text: widget.initialWhatILearned ?? '',
    );
    _nextActionsController = TextEditingController(
      text: widget.initialNextActions ?? '',
    );
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    _projectId = widget.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _whatIWorkedOnController.dispose();
    _whatILearnedController.dispose();
    _nextActionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final tasks = ref.watch(tasksProvider);
    final theme = Theme.of(context);

    return projects.when(
      data: (projectItems) => tasks.when(
        data: (taskItems) {
          if (!widget.isEditing) {
            return _buildScaffold(context, projectItems, taskItems);
          }

          final entry = ref.watch(journalEntryProvider(widget.journalEntryId!));
          return entry.when(
            data: (item) {
              _loadInitialValues(item);
              return _buildScaffold(context, projectItems, taskItems);
            },
            loading: () => WorkspaceShell(
              title: 'Edit Journal Entry',
              subtitle: 'Local journal form',
              onBack: () => context.go(RouteNames.journal),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => WorkspaceShell(
              title: 'Edit Journal Entry',
              subtitle: 'Local journal form',
              onBack: () => context.go(RouteNames.journal),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Journal entry data could not be loaded for editing.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => WorkspaceShell(
          title: widget.isEditing ? 'Edit Journal Entry' : 'New Journal Entry',
          subtitle: 'Local journal form',
          onBack: () => context.go(RouteNames.journal),
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => WorkspaceShell(
          title: widget.isEditing ? 'Edit Journal Entry' : 'New Journal Entry',
          subtitle: 'Local journal form',
          onBack: () => context.go(RouteNames.journal),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Journal entry options could not be loaded right now.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      loading: () => WorkspaceShell(
        title: widget.isEditing ? 'Edit Journal Entry' : 'New Journal Entry',
        subtitle: 'Local journal form',
        onBack: () => context.go(RouteNames.journal),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WorkspaceShell(
        title: widget.isEditing ? 'Edit Journal Entry' : 'New Journal Entry',
        subtitle: 'Local journal form',
        onBack: () => context.go(RouteNames.journal),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Journal entry options could not be loaded right now.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    List<Project> projects,
    List<Task> tasks,
  ) {
    final filteredTasks = _projectId == null
        ? tasks
        : tasks.where((task) => task.projectId == _projectId).toList();

    if (_taskId != null &&
        filteredTasks.every((task) => task.taskId != _taskId)) {
      _taskId = null;
    }

    return WorkspaceShell(
      title: widget.isEditing ? 'Edit Journal Entry' : 'New Journal Entry',
      subtitle: 'Local journal form',
      onBack: () => context.go(RouteNames.journal),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: ListTile(
                key: const Key('journalDatePickerButton'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: const Text('Entry Date'),
                subtitle: Text(_dateFormat.format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(context),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('journalTitleField'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Please enter a journal title.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('journalProjectField'),
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
              onChanged: (value) {
                setState(() {
                  _projectId = value;
                  _taskId = null;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('journalTaskField'),
              initialValue: _taskId,
              decoration: const InputDecoration(
                labelText: 'Related Task',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No task selected'),
                ),
                ...filteredTasks.map(
                  (task) => DropdownMenuItem<String?>(
                    value: task.taskId,
                    child: Text(task.title),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _taskId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('journalCategoryField'),
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
            TextFormField(
              key: const Key('journalWorkedOnField'),
              controller: _whatIWorkedOnController,
              decoration: const InputDecoration(
                labelText: 'What I Worked On',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('journalLearnedField'),
              controller: _whatILearnedController,
              decoration: const InputDecoration(
                labelText: 'What I Learned',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('journalNextActionsField'),
              controller: _nextActionsController,
              decoration: const InputDecoration(
                labelText: 'Next Actions',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('saveJournalButton'),
              onPressed: _isSaving ? null : () => _saveEntry(context),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(widget.isEditing ? 'Save Entry' : 'Create Entry'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadInitialValues(JournalEntry entry) {
    if (_didLoadInitialData) {
      return;
    }

    _selectedDate = entry.date;
    _titleController.text = entry.title;
    _whatIWorkedOnController.text = entry.whatIWorkedOn ?? '';
    _whatILearnedController.text = entry.whatILearned ?? '';
    _nextActionsController.text = entry.nextActions ?? '';
    _projectId = entry.projectId;
    _taskId = entry.taskId;
    _category = entry.category;
    _didLoadInitialData = true;
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() => _selectedDate = pickedDate);
  }

  Future<void> _saveEntry(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(journalActionsControllerProvider);
      final title = _titleController.text.trim();
      final whatIWorkedOn = _optionalText(_whatIWorkedOnController.text);
      final whatILearned = _optionalText(_whatILearnedController.text);
      final nextActions = _optionalText(_nextActionsController.text);

      final entry = widget.isEditing
          ? await controller.updateEntry(
              journalEntryId: widget.journalEntryId!,
              date: _selectedDate,
              title: title,
              projectId: _projectId,
              taskId: _taskId,
              category: _category,
              whatIWorkedOn: whatIWorkedOn,
              whatILearned: whatILearned,
              nextActions: nextActions,
            )
          : await controller.createEntry(
              date: _selectedDate,
              title: title,
              projectId: _projectId,
              taskId: _taskId,
              category: _category,
              whatIWorkedOn: whatIWorkedOn,
              whatILearned: whatILearned,
              nextActions: nextActions,
            );

      if (!context.mounted) {
        return;
      }

      context.go(RouteNames.journal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? '${entry.title} saved.'
                : '${entry.title} created.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
