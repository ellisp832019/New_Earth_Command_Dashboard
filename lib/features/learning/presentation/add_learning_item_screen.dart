import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../projects/application/projects_controller.dart';
import '../application/learning_controller.dart';

class AddLearningItemScreen extends ConsumerStatefulWidget {
  const AddLearningItemScreen({super.key, this.learningItemId});

  final String? learningItemId;

  bool get isEditing => learningItemId != null;

  @override
  ConsumerState<AddLearningItemScreen> createState() =>
      _AddLearningItemScreenState();
}

class _AddLearningItemScreenState extends ConsumerState<AddLearningItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _topicController;
  late final TextEditingController _reasonController;
  late final TextEditingController _resourceLinkController;
  late final TextEditingController _notesController;
  late final TextEditingController _nextStepController;

  String? _projectId;
  String _status = 'To Learn';
  String? _skillConfidence;
  bool _didLoadInitialData = false;
  bool _isSaving = false;

  static const _statusOptions = [
    'To Learn',
    'Learning',
    'Practicing',
    'Applied',
    'Paused',
  ];

  static const _confidenceOptions = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
    _reasonController = TextEditingController();
    _resourceLinkController = TextEditingController();
    _notesController = TextEditingController();
    _nextStepController = TextEditingController();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _reasonController.dispose();
    _resourceLinkController.dispose();
    _notesController.dispose();
    _nextStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final theme = Theme.of(context);

    return projects.when(
      data: (projectItems) {
        if (!widget.isEditing) {
          return _buildScaffold(context, projectItems);
        }

        final item = ref.watch(learningItemProvider(widget.learningItemId!));
        return item.when(
          data: (learningItem) {
            _loadInitialValues(learningItem);
            return _buildScaffold(context, projectItems);
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Edit Learning Topic')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Learning topic data could not be loaded for editing.',
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
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Edit Learning Topic' : 'Add Learning Topic',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Learning options could not be loaded right now.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Scaffold _buildScaffold(BuildContext context, List<Project> projectItems) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Learning Topic' : 'Add Learning Topic',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const Key('learningTopicField'),
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Please enter a learning topic.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('learningProjectField'),
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
                ...projectItems.map(
                  (project) => DropdownMenuItem<String?>(
                    value: project.projectId,
                    child: Text(project.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _projectId = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('learningReasonField'),
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Learning',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('learningResourceLinkField'),
              controller: _resourceLinkController,
              decoration: const InputDecoration(
                labelText: 'Resource Link',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('learningStatusField'),
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions
                  .map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() => _status = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('learningConfidenceField'),
              initialValue: _skillConfidence,
              decoration: const InputDecoration(
                labelText: 'Skill Confidence',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No confidence selected'),
                ),
                ..._confidenceOptions.map(
                  (confidence) => DropdownMenuItem<String?>(
                    value: confidence,
                    child: Text(confidence),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _skillConfidence = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('learningNotesField'),
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('learningNextStepField'),
              controller: _nextStepController,
              decoration: const InputDecoration(
                labelText: 'Next Step',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('saveLearningButton'),
              onPressed: _isSaving ? null : () => _save(context),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                widget.isEditing
                    ? 'Save Learning Topic'
                    : 'Create Learning Topic',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadInitialValues(LearningItem item) {
    if (_didLoadInitialData) {
      return;
    }

    _topicController.text = item.topic;
    _reasonController.text = item.reasonForLearning ?? '';
    _resourceLinkController.text = item.resourceLink ?? '';
    _notesController.text = item.notes ?? '';
    _nextStepController.text = item.nextStep ?? '';
    _projectId = item.projectId;
    _status = item.status;
    _skillConfidence = item.skillConfidence;
    _didLoadInitialData = true;
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(learningActionsControllerProvider);
      final learningItem = widget.isEditing
          ? await controller.updateItem(
              learningItemId: widget.learningItemId!,
              topic: _topicController.text.trim(),
              projectId: _projectId,
              reasonForLearning: _optionalText(_reasonController.text),
              resourceLink: _optionalText(_resourceLinkController.text),
              status: _status,
              notes: _optionalText(_notesController.text),
              nextStep: _optionalText(_nextStepController.text),
              skillConfidence: _skillConfidence,
            )
          : await controller.createItem(
              topic: _topicController.text.trim(),
              projectId: _projectId,
              reasonForLearning: _optionalText(_reasonController.text),
              resourceLink: _optionalText(_resourceLinkController.text),
              status: _status,
              notes: _optionalText(_notesController.text),
              nextStep: _optionalText(_nextStepController.text),
              skillConfidence: _skillConfidence,
            );

      if (!context.mounted) {
        return;
      }

      context.go(RouteNames.learning);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? '${learningItem.topic} saved.'
                : '${learningItem.topic} created.',
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
