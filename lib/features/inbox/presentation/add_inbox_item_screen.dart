import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../projects/application/projects_controller.dart';
import '../application/inbox_controller.dart';

class AddInboxItemScreen extends ConsumerStatefulWidget {
  const AddInboxItemScreen({super.key});

  @override
  ConsumerState<AddInboxItemScreen> createState() => _AddInboxItemScreenState();
}

class _AddInboxItemScreenState extends ConsumerState<AddInboxItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  String? _type;
  String? _projectId;
  String _status = 'New';
  bool _isSaving = false;

  static const _typeOptions = [
    'Task',
    'Idea',
    'Journal Note',
    'Content Idea',
    'Learning Note',
    'Business Opportunity',
    'Future Idea',
  ];

  static const _statusOptions = ['New', 'Processed', 'Parked'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final theme = Theme.of(context);

    return projects.when(
      data: (projectItems) => WorkspaceShell(
        title: 'Add Inbox Item',
        subtitle: 'Local inbox intake form',
        onBack: () => context.go(RouteNames.inbox),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                key: const Key('inboxTitleField'),
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('inboxBodyField'),
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 6,
                validator: (value) {
                  final title = _titleController.text.trim();
                  final body = value?.trim() ?? '';
                  if (title.isEmpty && body.isEmpty) {
                    return 'Please enter a title or body.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const Key('inboxTypeField'),
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No type selected'),
                  ),
                  ..._typeOptions.map(
                    (type) => DropdownMenuItem<String?>(
                      value: type,
                      child: Text(type),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _type = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const Key('inboxProjectField'),
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
              DropdownButtonFormField<String>(
                key: const Key('inboxStatusField'),
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
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('saveInboxButton'),
                onPressed: _isSaving ? null : () => _save(context),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Create Inbox Item'),
              ),
            ],
          ),
        ),
      ),
      loading: () => WorkspaceShell(
        title: 'Add Inbox Item',
        subtitle: 'Local inbox intake form',
        onBack: () => context.go(RouteNames.inbox),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WorkspaceShell(
        title: 'Add Inbox Item',
        subtitle: 'Local inbox intake form',
        onBack: () => context.go(RouteNames.inbox),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Inbox options could not be loaded right now.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final item = await ref
          .read(inboxActionsControllerProvider)
          .createItem(
            title: _optionalText(_titleController.text),
            body: _optionalText(_bodyController.text),
            type: _type,
            projectId: _projectId,
            status: _status,
          );

      if (!context.mounted) {
        return;
      }

      context.go(RouteNames.inbox);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(item.title ?? item.body ?? 'Inbox item created.'),
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
