import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../containers/me_chip.dart';
import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive tag / chips input.
///
/// Type and press enter (or comma) to commit a tag; backspace on an empty
/// field removes the last tag. New chips pop in with a spatial spring.
/// The container uses the same focus shape-morph as [METextField].
class METagInput extends StatefulWidget {
  const METagInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.label,
    this.hintText,
    this.maxTags,
    this.enabled = true,
  });

  /// Current tags. The widget does not own this list; changes are
  /// reported through [onChanged].
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String? label;
  final String? hintText;
  final int? maxTags;
  final bool enabled;

  @override
  State<METagInput> createState() => _METagInputState();
}

class _METagInputState extends State<METagInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _focusAnim =
      AnimationController.unbounded(vsync: this, value: 0);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    _focusAnim.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    springTo(
      _focusAnim,
      _focusNode.hasFocus ? 1 : 0,
      METheme.of(context).motion.defaultSpatial,
    );
    setState(() {});
  }

  bool get _atCapacity =>
      widget.maxTags != null && widget.tags.length >= widget.maxTags!;

  void _commit(String raw) {
    final tag = raw.trim().replaceAll(',', '');
    if (tag.isEmpty || _atCapacity) return;
    if (widget.tags.contains(tag)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.tags, tag]);
    _controller.clear();
  }

  void _removeAt(int index) {
    final next = [...widget.tags]..removeAt(index);
    widget.onChanged(next);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isEmpty &&
        widget.tags.isNotEmpty) {
      _removeAt(widget.tags.length - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final focused = _focusNode.hasFocus;

    return AnimatedBuilder(
      animation: _focusAnim,
      builder: (context, child) {
        final t = _focusAnim.value.clamp(0.0, 1.0);
        // Focus morph: extra-large resting corners square off slightly,
        // mirroring METextField's shape-as-state behavior.
        final radius =
            MECorners.extraLarge - (MECorners.extraLarge - MECorners.large) * t;
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: focused ? colors.primary : colors.outlineVariant,
              width: focused ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 4),
              child: Text(
                widget.label!,
                style: textTheme.labelMedium!.copyWith(
                  color: focused ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < widget.tags.length; i++)
                _PopIn(
                  key: ValueKey(widget.tags[i]),
                  child: MEChip(
                    label: Text(widget.tags[i]),
                    onPressed: widget.enabled ? () {} : null,
                    onDeleted: widget.enabled ? () => _removeAt(i) : null,
                  ),
                ),
              if (!_atCapacity)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 80),
                  child: IntrinsicWidth(
                    child: Focus(
                      onKeyEvent: _handleKey,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        style: textTheme.bodyLarge,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText:
                              widget.tags.isEmpty ? widget.hintText : null,
                          hintStyle: textTheme.bodyLarge!
                              .copyWith(color: colors.onSurfaceVariant),
                        ),
                        onSubmitted: (v) {
                          _commit(v);
                          _focusNode.requestFocus();
                        },
                        onChanged: (v) {
                          if (v.endsWith(',')) _commit(v);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Scales a newly inserted chip in with the theme's spatial spring.
class _PopIn extends StatefulWidget {
  const _PopIn({super.key, required this.child});

  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController.unbounded(vsync: this, value: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        springTo(_anim, 1, METheme.of(context).motion.defaultSpatial);
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Transform.scale(
        scale: _anim.value.clamp(0.0, 1.1),
        child: child,
      ),
      child: widget.child,
    );
  }
}
