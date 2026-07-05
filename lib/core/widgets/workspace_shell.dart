import 'package:flutter/material.dart';

import '../theme/app_colours.dart';
import 'workspace_frame.dart';

class WorkspaceShell extends StatelessWidget {
  const WorkspaceShell({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.onBack,
    this.trailingActions = const <Widget>[],
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final List<Widget> trailingActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WorkspaceFrame(
      header: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColours.darkBackground.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border(
            bottom: BorderSide(
              color: AppColours.darkOutline.withValues(alpha: 0.9),
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 980;

            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (onBack != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        tooltip: 'Back',
                        onPressed: onBack,
                      )
                    else
                      const SizedBox(width: 8),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColours.darkText,
                          fontWeight: FontWeight.w800,
                          fontSize: 21,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titleBlock,
                  if (trailingActions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: trailingActions,
                    ),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: titleBlock),
                if (trailingActions.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: trailingActions,
                  ),
                ],
              ],
            );
          },
        ),
      ),
      child: child,
    );
  }
}
