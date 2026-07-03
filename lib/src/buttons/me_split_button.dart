import 'package:flutter/material.dart';

import '../internal/me_pressable.dart';
import '../theme/me_shapes.dart';
import 'me_button.dart';

/// A Material 3 Expressive split button.
///
/// A new M3E component: a connected pair made of a leading primary-action
/// button and a trailing menu toggle. The trailing segment morphs to a
/// fully-round shape while its menu is open.
class MESplitButton extends StatefulWidget {
  const MESplitButton({
    super.key,
    required this.child,
    required this.menuItems,
    this.icon,
    this.onPressed,
    this.variant = MEButtonVariant.filled,
    this.height = 48,
  });

  final Widget child;
  final Widget? icon;
  final VoidCallback? onPressed;
  final MEButtonVariant variant;
  final double height;

  /// Items shown in the trailing menu.
  final List<MenuItemButton> menuItems;

  @override
  State<MESplitButton> createState() => _MESplitButtonState();
}

class _MESplitButtonState extends State<MESplitButton> {
  final MenuController _menuController = MenuController();
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (Color bg, Color fg) = switch (widget.variant) {
      MEButtonVariant.filled => (colors.primary, colors.onPrimary),
      MEButtonVariant.tonal => (
          colors.secondaryContainer,
          colors.onSecondaryContainer
        ),
      _ => (colors.primary, colors.onPrimary),
    };

    final r = widget.height / 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Leading: primary action.
        MEPressable(
          onPressed: widget.onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.horizontal(
              start: Radius.circular(r),
              end: const Radius.circular(MECorners.extraSmall),
            ),
          ),
          color: bg,
          overlayColor: fg.withValues(alpha: 0.1),
          child: Container(
            height: widget.height,
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
        // Trailing: menu toggle. Morphs fully round while the menu is open.
        MenuAnchor(
          controller: _menuController,
          menuChildren: widget.menuItems,
          onOpen: () => setState(() => _menuOpen = true),
          onClose: () => setState(() => _menuOpen = false),
          builder: (context, controller, _) {
            return MEPressable(
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: const Radius.circular(MECorners.extraSmall),
                  end: Radius.circular(r),
                ),
              ),
              selectedShape: const StadiumBorder(),
              selected: _menuOpen,
              color: bg,
              overlayColor: fg.withValues(alpha: 0.1),
              semanticLabel: 'More options',
              child: SizedBox(
                width: widget.height,
                height: widget.height,
                child: Center(
                  child: AnimatedRotation(
                    turns: _menuOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 22,
                      color: fg,
                    ),
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
