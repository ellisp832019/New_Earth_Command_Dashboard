import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../projects/application/projects_controller.dart';
import '../application/content_controller.dart';

class AddContentItemScreen extends ConsumerStatefulWidget {
  const AddContentItemScreen({
    super.key,
    this.contentItemId,
    this.projectId,
    this.initialTitle,
    this.initialDraftText,
    this.initialImagePrompt,
    this.initialNotes,
  });

  final String? contentItemId;
  final String? projectId;
  final String? initialTitle;
  final String? initialDraftText;
  final String? initialImagePrompt;
  final String? initialNotes;

  bool get isEditing => contentItemId != null;

  @override
  ConsumerState<AddContentItemScreen> createState() =>
      _AddContentItemScreenState();
}

class _AddContentItemScreenState extends ConsumerState<AddContentItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _draftTextController;
  late final TextEditingController _imagePromptController;
  late final TextEditingController _notesController;

  String? _projectId;
  String? _platform;
  String? _contentType;
  String _status = 'Idea';
  bool _imageNeeded = false;
  bool _didLoadInitialData = false;
  bool _isSaving = false;

  static const _platformOptions = [
    'LinkedIn',
    'Website',
    'YouTube',
    'Book',
    'Newsletter',
    'Other',
  ];

  static const _contentTypeOptions = [
    'LinkedIn Post',
    'Website Journal',
    'Video Script',
    'Image Prompt',
    'Book Section',
    'Project Update',
    'Founder Journey',
    'Technical Update',
    'Awareness Post',
  ];

  static const _statusOptions = ['Idea', 'Drafting', 'Ready', 'Published'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _draftTextController = TextEditingController(
      text: widget.initialDraftText ?? '',
    );
    _imagePromptController = TextEditingController(
      text: widget.initialImagePrompt ?? '',
    );
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
    _projectId = widget.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _draftTextController.dispose();
    _imagePromptController.dispose();
    _notesController.dispose();
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

        final item = ref.watch(contentItemProvider(widget.contentItemId!));
        return item.when(
          data: (contentItem) {
            _loadInitialValues(contentItem);
            return _buildScaffold(context, projectItems);
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Edit Content Idea')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Content item data could not be loaded for editing.',
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
            widget.isEditing ? 'Edit Content Idea' : 'Add Content Idea',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Content options could not be loaded right now.',
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
          widget.isEditing ? 'Edit Content Idea' : 'Add Content Idea',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const Key('contentTitleField'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Please enter a content title.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('contentProjectField'),
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
            DropdownButtonFormField<String?>(
              key: const Key('contentPlatformField'),
              initialValue: _platform,
              decoration: const InputDecoration(
                labelText: 'Platform',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No platform selected'),
                ),
                ..._platformOptions.map(
                  (platform) => DropdownMenuItem<String?>(
                    value: platform,
                    child: Text(platform),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _platform = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('contentTypeField'),
              initialValue: _contentType,
              decoration: const InputDecoration(
                labelText: 'Content Type',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No content type selected'),
                ),
                ..._contentTypeOptions.map(
                  (contentType) => DropdownMenuItem<String?>(
                    value: contentType,
                    child: Text(contentType),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _contentType = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('contentStatusField'),
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
            TextFormField(
              key: const Key('contentDraftTextField'),
              controller: _draftTextController,
              decoration: const InputDecoration(
                labelText: 'Draft Text',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            Card(
              child: CheckboxListTile(
                key: const Key('contentImageNeededField'),
                value: _imageNeeded,
                onChanged: (value) =>
                    setState(() => _imageNeeded = value ?? false),
                title: const Text('Image Needed'),
                subtitle: const Text(
                  'Mark this when the content needs a supporting visual.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('contentImagePromptField'),
              controller: _imagePromptController,
              decoration: const InputDecoration(
                labelText: 'Image Prompt',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('contentNotesField'),
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
              key: const Key('saveContentButton'),
              onPressed: _isSaving ? null : () => _save(context),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                widget.isEditing ? 'Save Content Idea' : 'Create Content Idea',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadInitialValues(ContentItem item) {
    if (_didLoadInitialData) {
      return;
    }

    _titleController.text = item.title;
    _draftTextController.text = item.draftText ?? '';
    _imagePromptController.text = item.imagePrompt ?? '';
    _notesController.text = item.notes ?? '';
    _projectId = item.projectId;
    _platform = item.platform;
    _contentType = item.contentType;
    _status = item.status;
    _imageNeeded = item.imageNeeded;
    _didLoadInitialData = true;
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(contentActionsControllerProvider);
      final item = widget.isEditing
          ? await controller.updateItem(
              contentItemId: widget.contentItemId!,
              title: _titleController.text.trim(),
              projectId: _projectId,
              platform: _platform,
              contentType: _contentType,
              status: _status,
              draftText: _optionalText(_draftTextController.text),
              imageNeeded: _imageNeeded,
              imagePrompt: _optionalText(_imagePromptController.text),
              notes: _optionalText(_notesController.text),
            )
          : await controller.createItem(
              title: _titleController.text.trim(),
              projectId: _projectId,
              platform: _platform,
              contentType: _contentType,
              status: _status,
              draftText: _optionalText(_draftTextController.text),
              imageNeeded: _imageNeeded,
              imagePrompt: _optionalText(_imagePromptController.text),
              notes: _optionalText(_notesController.text),
            );

      if (!context.mounted) {
        return;
      }

      context.go(RouteNames.content);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? '${item.title} saved.'
                : '${item.title} created.',
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
