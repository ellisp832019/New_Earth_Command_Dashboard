import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/database/app_database.dart';
import '../../projects/application/projects_controller.dart';
import '../application/business_controller.dart';

class AddBusinessOpportunityScreen extends ConsumerStatefulWidget {
  const AddBusinessOpportunityScreen({super.key, this.businessId});

  final String? businessId;

  @override
  ConsumerState<AddBusinessOpportunityScreen> createState() =>
      _AddBusinessOpportunityScreenState();
}

class _AddBusinessOpportunityScreenState
    extends ConsumerState<AddBusinessOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('d MMM yyyy');
  late final TextEditingController _nameController;
  late final TextEditingController _companyOrContactController;
  late final TextEditingController _nextActionController;
  late final TextEditingController _relatedDocumentLinkController;
  late final TextEditingController _notesController;

  String? _projectId;
            ),
          ],
        ),
      ),
    );
                }

                setState(() => _status = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('businessCompanyOrContactField'),
              controller: _companyOrContactController,
              decoration: const InputDecoration(
                labelText: 'Company or Contact',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                key: const Key('businessDeadlineField'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: const Text('Deadline'),
                subtitle: Text(
                  _deadline == null
                      ? 'No deadline selected'
                      : _dateFormat.format(_deadline!),
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(
                  context,
                  initialDate: _deadline,
                  onSelected: (value) => setState(() => _deadline = value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('businessNextActionField'),
              controller: _nextActionController,
              decoration: const InputDecoration(
                labelText: 'Next Step',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                key: const Key('businessFollowUpDateField'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: const Text('Follow-Up Date'),
                subtitle: Text(
                  _followUpDate == null
                      ? 'No follow-up date selected'
                      : _dateFormat.format(_followUpDate!),
                ),
                trailing: const Icon(Icons.event_repeat_outlined),
                onTap: () => _pickDate(
                  context,
                  initialDate: _followUpDate ?? _deadline,
                  onSelected: (value) => setState(() => _followUpDate = value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('businessRelatedDocumentLinkField'),
              controller: _relatedDocumentLinkController,
              decoration: const InputDecoration(
                labelText: 'Related Document Link',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('businessNotesField'),
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
              key: const Key('saveBusinessButton'),
              onPressed: _isSaving ? null : () => _save(context),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(isEditing ? 'Save Changes' : 'Create Opportunity'),
            ),
          ],
        ),
      ),
    );
              TextFormField(
                key: const Key('businessNameField'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Opportunity Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Please enter an opportunity name.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const Key('businessProjectField'),
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
                key: const Key('businessTypeField'),
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
              DropdownButtonFormField<String>(
                key: const Key('businessStatusField'),
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
                key: const Key('businessCompanyOrContactField'),
                controller: _companyOrContactController,
                decoration: const InputDecoration(
                  labelText: 'Company or Contact',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  key: const Key('businessDeadlineField'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: const Text('Deadline'),
                  subtitle: Text(
                    _deadline == null
                        ? 'No deadline selected'
                        : _dateFormat.format(_deadline!),
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickDate(
                    context,
                    initialDate: _deadline,
                    onSelected: (value) => setState(() => _deadline = value),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('businessNextActionField'),
                controller: _nextActionController,
                decoration: const InputDecoration(
                  labelText: 'Next Step',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  key: const Key('businessFollowUpDateField'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: const Text('Follow-Up Date'),
                  subtitle: Text(
                    _followUpDate == null
                        ? 'No follow-up date selected'
                        : _dateFormat.format(_followUpDate!),
                  ),
                  trailing: const Icon(Icons.event_repeat_outlined),
                  onTap: () => _pickDate(
                    context,
                    initialDate: _followUpDate ?? _deadline,
                    onSelected: (value) =>
                        setState(() => _followUpDate = value),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('businessRelatedDocumentLinkField'),
                controller: _relatedDocumentLinkController,
                decoration: const InputDecoration(
                  labelText: 'Related Document Link',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('businessNotesField'),
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
                key: const Key('saveBusinessButton'),
                onPressed: _isSaving ? null : () => _save(context),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Save Changes' : 'Create Opportunity'),
              ),
            ],
          ),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Add Opportunity')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Business options could not be loaded right now.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _loadInitialValues(BusinessOpportunity item) {
    if (_didLoadInitialData) return;

    _nameController.text = item.name;
    _companyOrContactController.text = item.companyOrContact ?? '';
    _nextActionController.text = item.nextAction ?? '';
    _relatedDocumentLinkController.text = item.relatedDocumentLink ?? '';
    _notesController.text = item.notes ?? '';
    _projectId = item.projectId;
    _type = item.type;
    _status = item.status;
    _deadline = item.deadline;
    _followUpDate = item.followUpDate;

    _didLoadInitialData = true;
  }

  Future<void> _pickDate(
    BuildContext context, {
    required DateTime? initialDate,
    required ValueChanged<DateTime?> onSelected,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    onSelected(pickedDate);
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.businessId == null) {
        final item = await ref
            .read(businessActionsControllerProvider)
            .createItem(
              name: _nameController.text.trim(),
              projectId: _projectId,
              type: _type,
              status: _status,
              companyOrContact: _optionalText(_companyOrContactController.text),
              deadline: _deadline,
              nextAction: _optionalText(_nextActionController.text),
              followUpDate: _followUpDate,
              relatedDocumentLink: _optionalText(
                _relatedDocumentLinkController.text,
              ),
              notes: _optionalText(_notesController.text),
            );

        if (!context.mounted) {
          return;
        }

        context.go(RouteNames.business);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${item.name} created.')));
      } else {
        final updated = await ref
            .read(businessActionsControllerProvider)
            .updateItem(
              businessOpportunityId: widget.businessId!,
              name: _nameController.text.trim(),
              projectId: _projectId,
              type: _type,
              status: _status,
              companyOrContact: _optionalText(_companyOrContactController.text),
              deadline: _deadline,
              nextAction: _optionalText(_nextActionController.text),
              followUpDate: _followUpDate,
              relatedDocumentLink: _optionalText(
                _relatedDocumentLinkController.text,
              ),
              notes: _optionalText(_notesController.text),
            );

        if (!context.mounted) return;

        context.go(RouteNames.business);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${updated.name} saved.')),
        );
      }
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
