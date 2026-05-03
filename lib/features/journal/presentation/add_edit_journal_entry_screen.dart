import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../projects/application/projects_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../application/journal_controller.dart';

class AddEditJournalEntryScreen extends ConsumerStatefulWidget {
  const AddEditJournalEntryScreen({super.key});

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
    _whatIWorkedOnController = TextEditingController();
    _whatILearnedController = TextEditingController();
    _nextActionsController = TextEditingController();
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
        data: (taskItems) => _buildScaffold(context, projectItems, taskItems),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(title: const Text('New Journal Entry')),
          body: Center(
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('New Journal Entry')),
        body: Center(
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

  Scaffold _buildScaffold(
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

    return Scaffold(
      appBar: AppBar(title: const Text('New Journal Entry')),
      body: Form(
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
              label: const Text('Create Entry'),
            ),
          ],
        ),
      ),
    );
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
      final entry = await ref
          .read(journalActionsControllerProvider)
          .createEntry(
            date: _selectedDate,
            title: _titleController.text.trim(),
            projectId: _projectId,
            taskId: _taskId,
            category: _category,
            whatIWorkedOn: _optionalText(_whatIWorkedOnController.text),
            whatILearned: _optionalText(_whatILearnedController.text),
            nextActions: _optionalText(_nextActionsController.text),
          );

      if (!context.mounted) {
        return;
      }

      context.go(RouteNames.journal);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${entry.title} created.')));
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
