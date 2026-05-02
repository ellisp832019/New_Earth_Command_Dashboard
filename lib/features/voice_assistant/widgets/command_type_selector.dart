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
    return SegmentedButton<VoiceCommandType>(
      multiSelectionEnabled: false,
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: VoiceCommandType.values.map((type) {
        return ButtonSegment<VoiceCommandType>(
          value: type,
          label: Text(type.label),
        );
      }).toList(),
      selected: {selectedType},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}
