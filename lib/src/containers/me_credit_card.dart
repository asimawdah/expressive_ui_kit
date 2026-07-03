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

  @override
  Widget build(BuildContext context) {
    final double height = widget.width / 1.586;

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
                      child: _back(context, height),
                    )
                  : _front(context, height),
            );
          },
        ),
      ),
    );
  }

  Widget _front(BuildContext context, double height) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: widget.width,
      height: height,
      padding: const EdgeInsets.all(20),
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
              // Chip.
              Container(
                width: 38,
                height: 28,
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(MECorners.extraSmall),
                  border: Border.all(color: scheme.outline),
                ),
              ),
              const Spacer(),
              if (widget.brand != null)
                DefaultTextStyle(
                  style: textTheme.titleMedium!.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontStyle: FontStyle.italic,
                  ),
                  child: widget.brand!,
                ),
            ],
          ),
          const Spacer(),
          Text(
            _spacedNumber,
            style: textTheme.titleLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.holder.toUpperCase(),
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                widget.expiry,
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _back(BuildContext context, double height) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
          const SizedBox(height: 20),
          // Magnetic stripe.
          Container(
            height: height * 0.22,
            color: scheme.inverseSurface,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Signature strip.
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius:
                          BorderRadius.circular(MECorners.extraSmall),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // CVC box.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 14),
            child: Text(
              'Tap to flip back',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
