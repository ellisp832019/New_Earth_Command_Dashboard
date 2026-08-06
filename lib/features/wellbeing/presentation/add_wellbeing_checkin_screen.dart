import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/wellbeing_controller.dart';

class AddWellbeingCheckinScreen extends ConsumerStatefulWidget {
  const AddWellbeingCheckinScreen({super.key});

  @override
  ConsumerState<AddWellbeingCheckinScreen> createState() =>
      _AddWellbeingCheckinScreenState();
}

class _AddWellbeingCheckinScreenState
    extends ConsumerState<AddWellbeingCheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('d MMM yyyy');
  late final TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  String? _energyLevel;
  String? _mood;
  String? _sleepQuality;
  String? _stressLevel;
  bool _movementDone = false;
  bool _foodWaterOk = false;
  bool _meditationReflectionDone = false;
  bool _isSaving = false;

  static const _levelOptions = ['Low', 'Medium', 'High'];
  static const _moodOptions = [
    'Focused',
    'Calm',
    'Scattered',
    'Tired',
    'Motivated',
    'Stressed',
    'Inspired',
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceShell(
      title: 'Add Check-In',
      subtitle: 'Local wellbeing check-in form',
      onBack: () => context.go(RouteNames.wellbeing),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: ListTile(
                key: const Key('wellbeingDateField'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: const Text('Check-In Date'),
                subtitle: Text(_dateFormat.format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(context),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('wellbeingEnergyField'),
              initialValue: _energyLevel,
              decoration: const InputDecoration(
                labelText: 'Energy',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No energy level selected'),
                ),
                ..._levelOptions.map(
                  (option) => DropdownMenuItem<String?>(
                    value: option,
                    child: Text(option),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _energyLevel = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('wellbeingMoodField'),
              initialValue: _mood,
              decoration: const InputDecoration(
                labelText: 'Mood',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No mood selected'),
                ),
                ..._moodOptions.map(
                  (option) => DropdownMenuItem<String?>(
                    value: option,
                    child: Text(option),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _mood = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('wellbeingSleepQualityField'),
              initialValue: _sleepQuality,
              decoration: const InputDecoration(
                labelText: 'Sleep Quality',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No sleep quality selected'),
                ),
                ..._levelOptions.map(
                  (option) => DropdownMenuItem<String?>(
                    value: option,
                    child: Text(option),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _sleepQuality = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('wellbeingStressField'),
              initialValue: _stressLevel,
              decoration: const InputDecoration(
                labelText: 'Stress',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No stress level selected'),
                ),
                ..._levelOptions.map(
                  (option) => DropdownMenuItem<String?>(
                    value: option,
                    child: Text(option),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _stressLevel = value),
            ),
            const SizedBox(height: 12),
            Card(
              child: CheckboxListTile(
                key: const Key('wellbeingMovementField'),
                value: _movementDone,
                onChanged: (value) =>
                    setState(() => _movementDone = value ?? false),
                title: const Text('Movement Done'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: CheckboxListTile(
                key: const Key('wellbeingFoodWaterField'),
                value: _foodWaterOk,
                onChanged: (value) =>
                    setState(() => _foodWaterOk = value ?? false),
                title: const Text('Food and Water OK'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: CheckboxListTile(
                key: const Key('wellbeingReflectionField'),
                value: _meditationReflectionDone,
                onChanged: (value) =>
                    setState(() => _meditationReflectionDone = value ?? false),
                title: const Text('Meditation or Reflection Done'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('wellbeingNotesField'),
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
              key: const Key('saveWellbeingButton'),
              onPressed: _isSaving ? null : () => _save(context),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save Check-In'),
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

  Future<void> _save(BuildContext context) async {
    setState(() => _isSaving = true);

    try {
      final checkin = await ref
          .read(wellbeingActionsControllerProvider)
          .createCheckin(
            date: _selectedDate,
            energyLevel: _energyLevel,
            mood: _mood,
            sleepQuality: _sleepQuality,
            stressLevel: _stressLevel,
            movementDone: _movementDone,
            foodWaterOk: _foodWaterOk,
            meditationReflectionDone: _meditationReflectionDone,
            notes: _optionalText(_notesController.text),
          );

      if (!context.mounted) {
        return;
      }

      context.go(RouteNames.wellbeing);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-in saved for ${_dateFormat.format(checkin.date)}.',
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
