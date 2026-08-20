import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A receipt-style container that "prints" itself on mount.
///
/// The paper unrolls from the top with a slow spatial spring, revealing [lines]
/// one by one, ending with a zig-zag torn bottom edge. Useful for order
/// confirmations, summaries and playful checkout flows.
class MEReceipt extends StatefulWidget {
  const MEReceipt({
    super.key,
    required this.lines,
    this.header,
    this.width = 280,
    this.printDuration = const Duration(milliseconds: 1400),
  });

  /// The line items printed on the receipt, top to bottom.
  final List<MEReceiptLine> lines;

  /// Optional centered header (e.g. store name).
  final Widget? header;

  /// Paper width.
  final double width;

  /// Kept for API compatibility. Print motion is driven by [METheme]
  /// (`slowSpatial`); a zero duration still snaps the receipt open.
  final Duration printDuration;

  @override
  State<MEReceipt> createState() => _MEReceiptState();
}

/// One printed line: label on the left, value on the right.
/// Use [MEReceiptLine.divider] for a dashed separator row.
class MEReceiptLine {
  const MEReceiptLine(this.label, this.value, {this.emphasized = false})
      : isDivider = false;

  const MEReceiptLine.divider()
      : label = '',
        value = '',
        emphasized = false,
        isDivider = true;

  final String label;
  final String value;
  final bool emphasized;
  final bool isDivider;
}

class _MEReceiptState extends State<MEReceipt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _print = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final motion = METheme.of(context).motion;
    if (widget.printDuration == Duration.zero || motion.slowSpatial.instant) {
      _print.value = 1;
    } else {
      springTo(_print, 1, motion.slowSpatial);
    }
  }

  @override
  void dispose() {
    _print.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mono = textTheme.bodyMedium!.copyWith(
      fontFamily: 'monospace',
      color: scheme.onSurface,
    );

    return AnimatedBuilder(
      animation: _print,
      builder: (context, child) {
        final t = _print.value;
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: t < 0.02 ? 0.02 : t,
            child: child,
          ),
        );
      },
      child: CustomPaint(
        foregroundPainter: _TornEdgePainter(color: scheme.surface),
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header != null) ...[
                Center(
                  child: DefaultTextStyle(
                    style: textTheme.titleMedium!
                        .copyWith(color: scheme.onSurface),
                    child: widget.header!,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              for (final line in widget.lines)
                if (line.isDivider)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: _DashedLinePainter(
                        color: scheme.outlineVariant,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            line.label,
                            style: line.emphasized
                                ? mono.copyWith(fontWeight: FontWeight.bold)
                                : mono,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          line.value,
                          style: line.emphasized
                              ? mono.copyWith(fontWeight: FontWeight.bold)
                              : mono,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the zig-zag torn edge along the bottom by drawing the backdrop
/// color over the receipt's bottom strip.
class _TornEdgePainter extends CustomPainter {
  _TornEdgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const toothWidth = 12.0;
    const toothHeight = 8.0;
    final path = Path()..moveTo(0, size.height);
    final teeth = (size.width / toothWidth).ceil();
    for (int i = 0; i < teeth; i++) {
      final x0 = i * toothWidth;
      path.lineTo(x0 + toothWidth / 2, size.height - toothHeight);
      path.lineTo(math.min(x0 + toothWidth, size.width), size.height);
    }
    path
      ..lineTo(size.width, size.height + 2)
      ..lineTo(0, size.height + 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TornEdgePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 5.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
