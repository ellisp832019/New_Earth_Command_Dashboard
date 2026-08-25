import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_card_layout.dart';
import '../../settings/application/settings_controller.dart';

class DashboardCardPersonalizationSheet extends ConsumerStatefulWidget {
  const DashboardCardPersonalizationSheet({
    super.key,
    required this.initialLayout,
  });

  final DashboardCardLayout initialLayout;

  @override
  ConsumerState<DashboardCardPersonalizationSheet> createState() =>
      _DashboardCardPersonalizationSheetState();
}

class _DashboardCardPersonalizationSheetState
    extends ConsumerState<DashboardCardPersonalizationSheet> {
  late DashboardCardLayout _layout = widget.initialLayout;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Customize Dashboard',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    key: const Key('dashboardCardPersonalizationCloseButton'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              Text(
                'Choose what stays visible and move cards into an order that supports your day.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (var index = 0; index < _layout.orderedIds.length; index++)
                _CardPreferenceRow(
                  id: _layout.orderedIds[index],
                  index: index,
                  total: _layout.orderedIds.length,
                  visible: !_layout.hiddenIds.contains(
                    _layout.orderedIds[index],
                  ),
                  canHide:
                      _layout.orderedIds[index] !=
                      DashboardCardLayout.dailyFlowId,
                  onVisibilityChanged: (visible) =>
                      _setVisibility(_layout.orderedIds[index], visible),
                  onMoveUp: index == 0 ? null : () => _move(index, index - 1),
                  onMoveDown: index == _layout.orderedIds.length - 1
                      ? null
                      : () => _move(index, index + 1),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('dashboardCardPersonalizationResetButton'),
                onPressed: _isSaving ? null : _reset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Restore default layout'),
              ),
              const SizedBox(height: 8),
              Text(
                'Restores card order and visibility only. Your tasks, projects, and dashboard data stay unchanged.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setVisibility(String id, bool visible) {
    final hidden = {..._layout.hiddenIds};
    if (visible) {
      hidden.remove(id);
    } else {
      hidden.add(id);
    }
    _save(_layout.copyWith(hiddenIds: hidden));
  }

  void _move(int oldIndex, int newIndex) {
    final order = [..._layout.orderedIds];
    final id = order.removeAt(oldIndex);
    order.insert(newIndex, id);
    _save(_layout.copyWith(orderedIds: order));
  }

  void _reset() {
    _save(DashboardCardLayout.defaults());
  }

  Future<void> _save(DashboardCardLayout layout) async {
    setState(() {
      _layout = layout;
      _isSaving = true;
    });
    try {
      await ref.read(settingsControllerProvider).setDashboardCardLayout(layout);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _CardPreferenceRow extends StatelessWidget {
  const _CardPreferenceRow({
    required this.id,
    required this.index,
    required this.total,
    required this.visible,
    required this.canHide,
    required this.onVisibilityChanged,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final String id;
  final int index;
  final int total;
  final bool visible;
  final bool canHide;
  final ValueChanged<bool> onVisibilityChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(_labelFor(id)),
        subtitle: Text(_descriptionFor(id)),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('dashboardCardMoveUp-$id'),
              onPressed: onMoveUp,
              icon: const Icon(Icons.keyboard_arrow_up),
              tooltip: 'Move up',
              visualDensity: VisualDensity.compact,
            ),
            Text('${index + 1}/$total'),
            IconButton(
              key: Key('dashboardCardMoveDown-$id'),
              onPressed: onMoveDown,
              icon: const Icon(Icons.keyboard_arrow_down),
              tooltip: 'Move down',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        trailing: Semantics(
          label: canHide
              ? 'Show ${_labelFor(id)}'
              : '${_labelFor(id)} is always visible',
          child: Switch(
            key: Key('dashboardCardVisibility-$id'),
            value: visible,
            onChanged: canHide ? onVisibilityChanged : null,
          ),
        ),
      ),
    );
  }

  String _labelFor(String cardId) {
    switch (cardId) {
      case DashboardCardLayout.dailyFlowId:
        return 'Daily Flow';
      case DashboardCardLayout.nextStepId:
        return 'Next Step';
      case DashboardCardLayout.treasuryId:
        return 'Treasury';
      case DashboardCardLayout.commandCentreId:
        return 'Command Centre';
      case DashboardCardLayout.supportStackId:
        return 'Support Stack';
      default:
        return cardId;
    }
  }

  String _descriptionFor(String cardId) {
    switch (cardId) {
      case DashboardCardLayout.dailyFlowId:
        return 'Always visible - Today Focus, Top 3, projects, capture, and review.';
      case DashboardCardLayout.nextStepId:
        return 'Shows the next practical action that helps move work forward.';
      case DashboardCardLayout.treasuryId:
        return 'Shows key finance and treasury information.';
      case DashboardCardLayout.commandCentreId:
        return 'Provides quick access to core New Earth controls and status.';
      case DashboardCardLayout.supportStackId:
        return 'Shows supporting tools and operational shortcuts.';
      default:
        return 'Dashboard information and shortcuts.';
    }
  }
}
