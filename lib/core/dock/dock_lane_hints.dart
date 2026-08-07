import 'package:flutter/material.dart';

class DockLaneHintsOverlay extends StatelessWidget {
  const DockLaneHintsOverlay({
    super.key,
    required this.intensity,
    required this.accentColor,
  });

  final double intensity;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final opacity = intensity.clamp(0.0, 1.0).toDouble();

    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: 0.985 + (0.015 * opacity),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final verticalInset = constraints.maxHeight.isFinite
                    ? (constraints.maxHeight * 0.16).clamp(72.0, 164.0)
                    : 104.0;

                return Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: verticalInset,
                    bottom: verticalInset,
                  ),
                  child: Row(
                    children: [
                      _LaneRail(accentColor: accentColor),
                      const Spacer(),
                      _LaneRail(accentColor: accentColor, alignRight: true),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LaneRail extends StatelessWidget {
  const _LaneRail({required this.accentColor, this.alignRight = false});

  final Color accentColor;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;

    return SizedBox(
      width: 96,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _LaneMarker(
            label: 'Top',
            accentColor: accentColor,
            emphasis: false,
            textAlign: textAlign,
          ),
          _LaneMarker(
            label: 'Middle',
            accentColor: accentColor,
            emphasis: true,
            textAlign: textAlign,
          ),
          _LaneMarker(
            label: 'Bottom',
            accentColor: accentColor,
            emphasis: false,
            textAlign: textAlign,
          ),
        ],
      ),
    );
  }
}

class _LaneMarker extends StatelessWidget {
  const _LaneMarker({
    required this.label,
    required this.accentColor,
    required this.emphasis,
    required this.textAlign,
  });

  final String label;
  final Color accentColor;
  final bool emphasis;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final fillColor = accentColor.withValues(alpha: emphasis ? 0.20 : 0.10);
    final borderColor = accentColor.withValues(alpha: emphasis ? 0.45 : 0.20);
    final textColor = Colors.white.withValues(alpha: emphasis ? 0.82 : 0.58);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: emphasis ? 0.14 : 0.05),
            blurRadius: emphasis ? 18 : 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: textAlign == TextAlign.right
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!emphasis) ...[
            Icon(
              Icons.circle,
              size: 6,
              color: accentColor.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            textAlign: textAlign,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          if (emphasis) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.drag_indicator_rounded,
              size: 10,
              color: accentColor.withValues(alpha: 0.85),
            ),
          ],
        ],
      ),
    );
  }
}
