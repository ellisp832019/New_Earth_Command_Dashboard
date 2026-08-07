import 'package:flutter/material.dart';

import '../theme/app_colours.dart';

class WorkspaceFrame extends StatelessWidget {
  const WorkspaceFrame({
    required this.header,
    required this.child,
    super.key,
    this.maxWidth = 1560,
    this.outerPadding = const EdgeInsets.all(16),
  });

  final Widget header;
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry outerPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shellHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height;

            return Padding(
              padding: outerPadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SizedBox(
                    height: shellHeight - outerPadding.vertical,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColours.darkBackground.withValues(
                          alpha: 0.72,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColours.darkText.withValues(alpha: 0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          header,
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.04,
                                ),
                              ),
                              child: child,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
