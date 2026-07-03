import 'package:flutter/material.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive search bar.
///
/// Replaces [SearchBar]. Fully rounded at rest, it squares off with a
/// spatial spring while focused and raises its tonal elevation, following
/// the expressive shape-as-state pattern.
class MESearchBar extends StatefulWidget {
  const MESearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.leading,
    this.trailing = const <Widget>[],
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String hintText;
  final Widget? leading;
  final List<Widget> trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<MESearchBar> createState() => _MESearchBarState();
}

class _MESearchBarState extends State<MESearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusAnim =
      AnimationController.unbounded(vsync: this, value: 0);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    springTo(
      _focusAnim,
      _focusNode.hasFocus ? 1 : 0,
      METheme.of(context).motion.defaultSpatial,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _focusAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _focusAnim,
      builder: (context, child) {
        final t = _focusAnim.value.clamp(0.0, 1.0);
        final radius = 28.0 + (MECorners.large - 28.0) * t;
        return Material(
          color: Color.lerp(
            scheme.surfaceContainerHigh,
            scheme.surfaceContainerHighest,
            t,
          ),
          elevation: 2.0 * t,
          shadowColor: Colors.transparent,
          surfaceTintColor: scheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 16),
            widget.leading ??
                Icon(Icons.search, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ...widget.trailing,
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
