import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive radio button.
///
/// Replaces [Radio]. The inner dot springs in with expressive overshoot
/// when selected.
class MERadio<T> extends StatefulWidget {
  const MERadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.semanticsLabel,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? semanticsLabel;

  bool get selected => value == groupValue;

  @override
  State<MERadio<T>> createState() => _MERadioState<T>();
}

class _MERadioState<T> extends State<MERadio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.selected ? 1 : 0,
  );

  @override
  void didUpdateWidget(MERadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      springTo(
        _controller,
        widget.selected ? 1 : 0,
        METheme.of(context).motion.defaultSpatial,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onChanged != null;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: widget.selected,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => widget.onChanged!(widget.value) : null,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value.clamp(0.0, 1.4);
                final ringColor = widget.selected
                    ? (enabled
                        ? colors.primary
                        : colors.onSurface.withValues(alpha: 0.38))
                    : (enabled
                        ? colors.onSurfaceVariant
                        : colors.onSurface.withValues(alpha: 0.38));
                return Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 11 * t.clamp(0.0, 1.3),
                      height: 11 * t.clamp(0.0, 1.3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: enabled
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.38),
                      ),
                    ),
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
