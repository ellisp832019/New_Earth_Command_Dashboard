import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/projects_controller.dart';

class AddEditProjectScreen extends ConsumerStatefulWidget {
  const AddEditProjectScreen({super.key, this.projectId});

  final String? projectId;

  @override
  ConsumerState<AddEditProjectScreen> createState() =>
      _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends ConsumerState<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _visionController;
  late final TextEditingController _currentMilestoneController;
  late final TextEditingController _nextActionController;
  late final TextEditingController _notesController;

  String _status = 'Idea';
  String _priority = 'Medium';
  double _progressPercentage = 0;
  bool _didLoadInitialData = false;
  bool _isSaving = false;

  static const _statusOptions = [
    'Idea',
    'Active',
    'Paused',
    'Blocked',
    'Completed',
    'Archived',
  ];

  static const _priorityOptions = ['High', 'Medium', 'Low', 'Someday'];

  bool get _isEditing => widget.projectId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _shortDescriptionController = TextEditingController();
    _visionController = TextEditingController();
    _currentMilestoneController = TextEditingController();
    _nextActionController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _visionController.dispose();
    _currentMilestoneController.dispose();
    _nextActionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return _buildScaffold(context);
    }

    final project = ref.watch(projectProvider(widget.projectId!));
    final theme = Theme.of(context);

    return project.when(
      data: (item) {
        _loadInitialValues(item);
        return _buildScaffold(context);
      },
      loading: () => WorkspaceShell(
        title: _isEditing ? 'Edit Project' : 'New Project',
        subtitle: 'Loading project details',
        onBack: () => context.go(RouteNames.projects),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WorkspaceShell(
        title: _isEditing ? 'Edit Project' : 'New Project',
        subtitle: 'Project data unavailable',
        onBack: () => context.go(RouteNames.projects),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Project data could not be loaded for editing.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final theme = Theme.of(context);

    return WorkspaceShell(
      title: _isEditing ? 'Edit Project' : 'New Project',
      subtitle: 'Local project form',
      onBack: () => context.go(RouteNames.projects),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const Key('projectNameField'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Please enter a project name.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('projectShortDescriptionField'),
              controller: _shortDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Short Description',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('projectVisionField'),
              controller: _visionController,
              decoration: const InputDecoration(
                labelText: 'Vision / Purpose',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('projectStatusField'),
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
            DropdownButtonFormField<String>(
              key: const Key('projectPriorityField'),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${_progressPercentage.round()}%',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Slider(
                      key: const Key('projectProgressSlider'),
                      value: _progressPercentage,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${_progressPercentage.round()}%',
                      onChanged: (value) {
                        setState(() => _progressPercentage = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('projectCurrentMilestoneField'),
              controller: _currentMilestoneController,
              decoration: const InputDecoration(
                labelText: 'Current Milestone',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('projectNextActionField'),
              controller: _nextActionController,
              decoration: const InputDecoration(
                labelText: 'Next Action',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('projectNotesField'),
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
              key: const Key('saveProjectButton'),
              onPressed: _isSaving ? null : () => _saveProject(context),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isEditing ? 'Save Project' : 'Create Project'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadInitialValues(Project project) {
    if (_didLoadInitialData) {
      return;
    }

    _nameController.text = project.name;
    _shortDescriptionController.text = project.shortDescription ?? '';
    _visionController.text = project.vision ?? '';
    _currentMilestoneController.text = project.currentMilestone ?? '';
    _nextActionController.text = project.nextAction ?? '';
    _notesController.text = project.notes ?? '';
    _status = project.status;
    _priority = project.priority;
    _progressPercentage = project.progressPercentage.toDouble();
    _didLoadInitialData = true;
  }

  Future<void> _saveProject(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(projectActionsControllerProvider);
      if (_isEditing) {
        final project = await controller.updateProject(
          projectId: widget.projectId!,
          name: _nameController.text,
          shortDescription: _shortDescriptionController.text,
          vision: _visionController.text,
          status: _status,
          priority: _priority,
          progressPercentage: _progressPercentage.round(),
          currentMilestone: _currentMilestoneController.text,
          nextAction: _nextActionController.text,
          notes: _notesController.text,
        );
        if (!context.mounted) return;
        context.go(RouteNames.projectDetail(project.projectId));
        return;
      }

      final project = await controller.createProject(
        name: _nameController.text,
        shortDescription: _shortDescriptionController.text,
        vision: _visionController.text,
        status: _status,
        priority: _priority,
        progressPercentage: _progressPercentage.round(),
        currentMilestone: _currentMilestoneController.text,
        nextAction: _nextActionController.text,
        notes: _notesController.text,
      );
      if (!context.mounted) return;
      context.go(RouteNames.projectDetail(project.projectId));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
