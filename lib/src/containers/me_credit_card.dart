import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A payment-card display that flips in 3D to reveal its back.
///
/// Tap to flip between the front (number, holder, expiry) and the back
/// (magnetic stripe and CVC). The flip is driven by the theme's spatial
/// spring, so it overshoots slightly and is interruptible — tapping
/// mid-flip reverses it from the current angle.
class MECreditCard extends StatefulWidget {
  const MECreditCard({
    super.key,
    required this.number,
    required this.holder,
    required this.expiry,
    this.cvc = '***',
    this.brand,
    this.width = 320,
    this.onFlipped,
  });

  /// Card number; groups of 4 are spaced automatically.
  final String number;

  final String holder;

  /// Expiry string, e.g. '09/28'.
  final String expiry;

  final String cvc;

  /// Optional brand widget shown top-right (e.g. a logo or [Text]).
  final Widget? brand;

  /// Card width; height follows the ISO 7810 aspect ratio.
  final double width;

  /// Called after the card settles, with true when showing the back.
  final ValueChanged<bool>? onFlipped;

  @override
  State<MECreditCard> createState() => _MECreditCardState();
}

class _MECreditCardState extends State<MECreditCard>
    with SingleTickerProviderStateMixin {
  // 0 = front, 1 = back.
  late final AnimationController _flip = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );
  bool _showingBack = false;

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggle() {
    final motion = METheme.of(context).motion;
    _showingBack = !_showingBack;
    HapticFeedback.lightImpact();
    springTo(_flip, _showingBack ? 1 : 0, motion.defaultSpatial);
    widget.onFlipped?.call(_showingBack);
  }

  String get _spacedNumber {
    final digits = widget.number.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Design reference width; layout scales from this size.
  static const double _designWidth = 320;

  double get _scale => (widget.width / _designWidth).clamp(0.55, 1.25);

  @override
  Widget build(BuildContext context) {
    final double height = widget.width / 1.586;
    final scale = _scale;

    return Semantics(
      button: true,
      label: 'Payment card, tap to flip. '
          '${_showingBack ? 'Showing back' : 'Showing front'}',
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedBuilder(
          animation: _flip,
          builder: (context, _) {
            final double t = _flip.value;
            final double angle = t * math.pi;
            // Past the halfway point we render the back, pre-rotated so
            // its content reads correctly.
            final bool backVisible = angle % (2 * math.pi) > math.pi / 2 &&
                angle % (2 * math.pi) < 3 * math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: backVisible
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _back(context, height, scale),
                    )
                  : _front(context, height, scale),
            );
          },
        ),
      ),
    );
  }

  Widget _front(BuildContext context, double height, double scale) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = 20 * scale;
    final chipW = 38 * scale;
    final chipH = 28 * scale;
    final gap = 12 * scale;

    return Container(
      width: widget.width,
      height: height,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(MECorners.large),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: chipW,
                height: chipH,
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(MECorners.extraSmall),
                  border: Border.all(color: scheme.outline),
                ),
              ),
              const Spacer(),
              if (widget.brand != null)
                Flexible(
                  child: DefaultTextStyle(
                    style: textTheme.titleMedium!.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontStyle: FontStyle.italic,
                      fontSize: (textTheme.titleMedium?.fontSize ?? 16) * scale,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    child: widget.brand!,
                  ),
                ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              _spacedNumber,
              maxLines: 1,
              softWrap: false,
              style: textTheme.titleLarge?.copyWith(
                color: scheme.onPrimaryContainer,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 1.2 * scale,
                fontSize: (textTheme.titleLarge?.fontSize ?? 22) * scale,
              ),
            ),
          ),
          SizedBox(height: gap),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.holder.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    letterSpacing: 1.5 * scale,
                    fontSize: (textTheme.labelMedium?.fontSize ?? 12) * scale,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                widget.expiry,
                maxLines: 1,
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: (textTheme.labelMedium?.fontSize ?? 12) * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _back(BuildContext context, double height, double scale) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pad = 20 * scale;

    return Container(
      width: widget.width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(MECorners.large),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: pad),
          Container(
            height: height * 0.22,
            color: scheme.inverseSurface,
          ),
          SizedBox(height: 16 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 32 * scale,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(MECorners.extraSmall),
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 7 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(MECorners.extraSmall),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Text(
                    widget.cvc,
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontSize: (textTheme.labelLarge?.fontSize ?? 14) * scale,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(left: pad, bottom: 14 * scale),
            child: Text(
              'Tap to flip back',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                fontSize: (textTheme.labelSmall?.fontSize ?? 11) * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
