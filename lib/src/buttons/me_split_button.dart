import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../lists/me_menu.dart';
import '../theme/me_shapes.dart';
import 'me_button.dart';

/// A Material 3 Expressive split button.
///
/// A connected pair: a leading primary action and a trailing menu toggle.
/// The trailing segment morphs fully round while its [MEMenu] is open.
class MESplitButton extends StatefulWidget {
  const MESplitButton({
    super.key,
    required this.child,
    required this.menu,
    this.icon,
    this.onPressed,
    this.onSelected,
    this.variant = MEButtonVariant.filled,
    this.size = MEButtonSize.small,
  });

  final Widget child;
  final Widget? icon;
  final VoidCallback? onPressed;

  /// Menu tree shown from the trailing chevron. Typically [MEMenuEntry]s.
  final List<MEMenuNode> menu;

  /// Called with the selected [MEMenuEntry.value].
  final ValueChanged<Object?>? onSelected;

  final MEButtonVariant variant;
  final MEButtonSize size;

  @override
  State<MESplitButton> createState() => _MESplitButtonState();
}

class _MESplitButtonState extends State<MESplitButton> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final height = widget.size.height;

    final (Color bg, Color fg) = switch (widget.variant) {
      MEButtonVariant.filled => (colors.primary, colors.onPrimary),
      MEButtonVariant.tonal => (
          colors.secondaryContainer,
          colors.onSecondaryContainer
        ),
      MEButtonVariant.elevated => (colors.surfaceContainerLow, colors.primary),
      MEButtonVariant.outlined => (Colors.transparent, colors.onSurfaceVariant),
      MEButtonVariant.text => (
          colors.surfaceContainerHighest,
          colors.onSurface
        ),
    };

    final r = height / 2;
    const inner = Radius.circular(MECorners.extraSmall);
    final side = widget.variant == MEButtonVariant.outlined
        ? BorderSide(color: colors.outlineVariant)
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MEPressable(
          onPressed: widget.onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.horizontal(
              start: Radius.circular(r),
              end: inner,
            ),
          ),
          pressedShape: widget.size.pressedContainerShape,
          color: bg,
          side: side,
          overlayColor: fg.withValues(alpha: 0.1),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(size: 20, color: fg),
                    child: widget.icon!,
                  ),
                  const SizedBox(width: 8),
                ],
                DefaultTextStyle.merge(
                  style: textTheme.labelLarge!.copyWith(color: fg),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 2),
        MEMenu(
          position: MEMenuAnchorPosition.bottomEnd,
          children: widget.menu,
          onSelected: widget.onSelected,
          onOpenChanged: (open) {
            if (mounted) setState(() => _menuOpen = open);
          },
          anchorBuilder: (context, open) {
            return MEPressable(
              onPressed: open,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: inner,
                  end: Radius.circular(r),
                ),
              ),
              selectedShape: const StadiumBorder(),
              selected: _menuOpen,
              pressedShape: const StadiumBorder(),
              color: bg,
              side: side,
              overlayColor: fg.withValues(alpha: 0.1),
              semanticLabel: 'More options',
              child: SizedBox(
                width: height,
                height: height,
                child: Center(
                  child: Icon(
                    _menuOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 22,
                    color: fg,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
