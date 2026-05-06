import 'package:flutter/material.dart';

import '../voice_command_model.dart';

class CommandTypeSelector extends StatelessWidget {
  const CommandTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final VoiceCommandType selectedType;
  final ValueChanged<VoiceCommandType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VoiceCommandType.values.map((type) {
        return ChoiceChip(
          label: Text(type.label),
          selected: selectedType == type,
          onSelected: (_) => onChanged(type),
        );
      }).toList(),
    );
  }
}
