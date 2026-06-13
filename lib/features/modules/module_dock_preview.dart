import 'package:flutter/material.dart';

import '../../core/dock/dock_panel.dart';
import '../../core/dock/dock_position.dart';
import '../../core/modules/module_manifest.dart';

class ModuleDockPreview extends StatefulWidget {
  const ModuleDockPreview({
    super.key,
    required this.module,
    this.initialPosition = DockPosition.right,
    this.showAssistantDockPlaceholder = false,
    this.onPositionChanged,
  });

  final ModuleManifest module;
  final DockPosition initialPosition;
  final bool showAssistantDockPlaceholder;
  final ValueChanged<DockPosition>? onPositionChanged;

  @override
  State<ModuleDockPreview> createState() => _ModuleDockPreviewState();
}

class _ModuleDockPreviewState extends State<ModuleDockPreview> {
  late DockPosition _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DockPosition.values
              .map(
                (position) => ChoiceChip(
                  label: Text(position.label),
                  selected: _position == position,
                  onSelected: (_) {
                    setState(() {
                      _position = position;
                    });
                    widget.onPositionChanged?.call(position);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        DockPanel(
          module: widget.module,
          position: _position,
          showAssistantStats: widget.showAssistantDockPlaceholder,
          actionLabel: 'Start Placeholder',
          onAction: () {},
        ),
      ],
    );
  }
}
