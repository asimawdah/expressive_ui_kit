import 'package:flutter/material.dart';

import '../communication/me_number_ticker.dart';
import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';

/// A Material 3 Expressive quantity stepper (- value +).
///
/// A connected pill with decrement and increment segments flanking a
/// rolling value readout ([MENumberTicker]). The segment buttons use the
/// M3E press-morph: they square up while pressed and bounce back on
/// release. Buttons disable automatically at [min]/[max].
class MEQuantityStepper extends StatelessWidget {
  const MEQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.step = 1,
    this.height = 48,
    this.semanticLabel,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;
  final int step;
  final double height;
  final String? semanticLabel;

  bool get _canDecrement => onChanged != null && value - step >= min;
  bool get _canIncrement => onChanged != null && value + step <= max;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticLabel ?? 'Quantity',
      value: '$value',
      child: Container(
        height: height,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment(
              context,
              icon: Icons.remove,
              enabled: _canDecrement,
              onPressed: () => onChanged!(value - step),
              tooltip: 'Decrease',
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: height * 0.9),
              child: Center(
                child: MENumberTicker(
                  value: value,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            _segment(
              context,
              icon: Icons.add,
              enabled: _canIncrement,
              onPressed: () => onChanged!(value + step),
              tooltip: 'Increase',
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment(
    BuildContext context, {
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: height - 8,
        height: height - 8,
        child: MEPressable(
          onPressed: enabled ? onPressed : null,
          enabled: enabled,
          shape: const StadiumBorder(),
          pressedShape: MEShapeScheme.fromCorner(MECorners.medium),
          color: enabled ? scheme.primary : Colors.transparent,
          overlayColor: scheme.onPrimary.withValues(alpha: 0.1),
          semanticLabel: tooltip,
          haptics: true,
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? scheme.onPrimary
                : scheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }
}
