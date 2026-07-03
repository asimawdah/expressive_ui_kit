import 'package:flutter/material.dart';

import '../charts/me_charts.dart';
import '../communication/me_number_ticker.dart';
import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive statistic card.
///
/// A dashboard building block composing [MENumberTicker] (the value rolls
/// when it changes) with an optional trend chip and [MESparkline]. The
/// surface press-morphs like every other ME container.
class MEStatCard extends StatelessWidget {
  const MEStatCard({
    super.key,
    required this.label,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.delta,
    this.sparkline,
    this.icon,
    this.onPressed,
  });

  /// Short description of the metric (e.g. "Revenue").
  final Widget label;

  /// The metric value; changes animate with rolling digits.
  final int value;
  final String prefix;
  final String suffix;

  /// Percent change versus the prior period. Positive renders an upward
  /// trend chip in primary tones, negative renders a downward chip in
  /// error tones. Null hides the chip.
  final double? delta;

  /// Recent values rendered as a small sparkline at the card's foot.
  final List<double>? sparkline;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MEPressable(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.extraLarge),
      ),
      color: colors.surfaceContainerLow,
      overlayColor: colors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: colors.onSurfaceVariant),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: textTheme.labelLarge!
                        .copyWith(color: colors.onSurfaceVariant),
                    child: label,
                  ),
                ),
                if (delta != null) _DeltaChip(delta: delta!),
              ],
            ),
            const SizedBox(height: 12),
            MENumberTicker(
              value: value,
              prefix: prefix,
              suffix: suffix,
              style: METypography.emphasize(textTheme.headlineMedium!)
                  .copyWith(color: colors.onSurface),
            ),
            if (sparkline != null) ...[
              const SizedBox(height: 12),
              MESparkline(values: sparkline!, height: 40),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final up = delta >= 0;
    final (Color bg, Color fg) = up
        ? (colors.primaryContainer, colors.onPrimaryContainer)
        : (colors.errorContainer, colors.onErrorContainer);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: bg,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            '${delta.abs().toStringAsFixed(1)}%',
            style: textTheme.labelSmall!.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
