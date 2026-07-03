import 'package:flutter/material.dart';

import '../theme/me_theme.dart';

/// A single candle in an [MECandlestickChart].
@immutable
class MECandle {
  const MECandle({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    this.label,
  })  : assert(high >= low, 'high must be >= low');

  final double open;
  final double close;
  final double high;
  final double low;

  /// Optional axis label under the candle (e.g. a date).
  final String? label;

  bool get bullish => close >= open;
}

/// An animated candlestick (OHLC) chart.
///
/// Candles grow from their midpoint with left-to-right staggered spatial
/// springs: wicks stretch vertically and bodies inflate, overshooting
/// slightly before settling. Bullish candles use the primary color,
/// bearish candles the error color.
class MECandlestickChart extends StatefulWidget {
  const MECandlestickChart({
    super.key,
    required this.candles,
    this.height = 200,
    this.candleWidth = 10,
    this.semanticLabel,
  });

  final List<MECandle> candles;
  final double height;
  final double candleWidth;
  final String? semanticLabel;

  @override
  State<MECandlestickChart> createState() => _MECandlestickChartState();
}

class _MECandlestickChartState extends State<MECandlestickChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
  }

  @override
  void didUpdateWidget(MECandlestickChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candles.length != widget.candles.length) {
      _enter.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;

    return Semantics(
      label: widget.semanticLabel ??
          'Candlestick chart with ${widget.candles.length} candles',
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _enter,
          builder: (context, _) {
            return CustomPaint(
              painter: _CandlePainter(
                candles: widget.candles,
                progress: _enter.value,
                curve: motion.defaultSpatial.curve,
                candleWidth: widget.candleWidth,
                bullColor: scheme.primary,
                bearColor: scheme.error,
                gridColor: scheme.outlineVariant.withValues(alpha: 0.4),
                labelStyle: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  _CandlePainter({
    required this.candles,
    required this.progress,
    required this.curve,
    required this.candleWidth,
    required this.bullColor,
    required this.bearColor,
    required this.gridColor,
    required this.labelStyle,
  });

  final List<MECandle> candles;
  final double progress;
  final Curve curve;
  final double candleWidth;
  final Color bullColor;
  final Color bearColor;
  final Color gridColor;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    const labelSpace = 18.0;
    final chartHeight = size.height - labelSpace;

    var min = candles.first.low;
    var max = candles.first.high;
    for (final c in candles) {
      if (c.low < min) min = c.low;
      if (c.high > max) max = c.high;
    }
    final range = (max - min).abs() < 1e-9 ? 1.0 : max - min;

    double toY(double v) => chartHeight * (1 - (v - min) / range);

    // Horizontal grid lines.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final slot = size.width / candles.length;

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final delay = candles.length <= 1 ? 0.0 : i / (candles.length * 1.6);
      final local = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      final t = curve.transform(local);
      if (t <= 0.001) continue;

      final cx = slot * (i + 0.5);
      final color = candle.bullish ? bullColor : bearColor;

      final bodyTop = toY(candle.bullish ? candle.close : candle.open);
      final bodyBottom = toY(candle.bullish ? candle.open : candle.close);
      final mid = (bodyTop + bodyBottom) / 2;

      // Wick stretches from the midpoint.
      final wickTop = mid + (toY(candle.high) - mid) * t;
      final wickBottom = mid + (toY(candle.low) - mid) * t;
      canvas.drawLine(
        Offset(cx, wickTop),
        Offset(cx, wickBottom),
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );

      // Body inflates from the midpoint.
      final halfBody = (bodyBottom - bodyTop) / 2 * t;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          cx - candleWidth / 2,
          mid - halfBody,
          cx + candleWidth / 2,
          mid + halfBody,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, Paint()..color = color);

      final label = candle.label;
      if (label != null && t > 0.5) {
        final painter = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        painter.paint(
          canvas,
          Offset(cx - painter.width / 2, chartHeight + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CandlePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.candles != candles;
}
