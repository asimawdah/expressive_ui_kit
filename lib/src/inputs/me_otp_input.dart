import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// A Material 3 Expressive one-time-code input.
///
/// Renders [length] cells backed by a single invisible text field, so the
/// system keyboard, paste, and autofill all work naturally. The active
/// cell's border springs to the primary color and each cell pops with a
/// small bounce as its digit arrives.
class MEOtpInput extends StatefulWidget {
  const MEOtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.obscure = false,
  });

  /// Number of code cells.
  final int length;

  /// Called with the full code once every cell is filled.
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  /// Show dots instead of digits.
  final bool obscure;

  @override
  State<MEOtpInput> createState() => _MEOtpInputState();
}

class _MEOtpInputState extends State<MEOtpInput> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final List<AnimationController> _pops = List.generate(
    widget.length,
    (i) => AnimationController.unbounded(vsync: this, value: 1),
  );
  String _previous = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleChange);
    _focusNode.addListener(() => setState(() {}));
  }

  void _handleChange() {
    final text = _controller.text;
    // Pop the newly filled cell.
    if (text.length > _previous.length && text.length <= widget.length) {
      final i = text.length - 1;
      _pops[i].value = 0.6;
      springTo(_pops[i], 1, METheme.of(context).motion.fastSpatial);
    }
    _previous = text;
    setState(() {});
    widget.onChanged?.call(text);
    if (text.length == widget.length) {
      widget.onCompleted?.call(text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    for (final c in _pops) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = _controller.text;
    final activeIndex = text.length.clamp(0, widget.length - 1);

    return GestureDetector(
      onTap: widget.enabled
          ? () {
              _focusNode.requestFocus();
              // Keep the caret at the end so cells fill left to right.
              _controller.selection =
                  TextSelection.collapsed(offset: text.length);
            }
          : null,
      child: Stack(
        children: [
          // Invisible backing field: handles keyboard, paste and autofill.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.length, (i) {
              final filled = i < text.length;
              final isActive = _focusNode.hasFocus && i == activeIndex;
              final char = filled ? (widget.obscure ? '\u2022' : text[i]) : '';

              return Padding(
                padding: EdgeInsets.only(right: i < widget.length - 1 ? 8 : 0),
                child: AnimatedBuilder(
                  animation: _pops[i],
                  builder: (context, child) => Transform.scale(
                    scale: _pops[i].value.clamp(0.0, 1.3),
                    child: child,
                  ),
                  child: MEMotionBuilder(
                    value: filled ? 1.0 : 0.0,
                    spec: METheme.of(context).motion.fastEffects,
                    builder: (context, fillT, _) {
                      return MEMotionBuilder(
                        value: isActive ? 1.0 : 0.0,
                        spec: METheme.of(context).motion.fastEffects,
                        builder: (context, activeT, child) {
                          return Container(
                            width: 48,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                scheme.surfaceContainerHigh,
                                scheme.secondaryContainer,
                                fillT.clamp(0.0, 1.0),
                              ),
                              borderRadius: BorderRadius.circular(
                                MECorners.large +
                                    (MECorners.medium - MECorners.large) *
                                        fillT,
                              ),
                              border: Border.all(
                                color: Color.lerp(
                                  Colors.transparent,
                                  scheme.primary,
                                  activeT.clamp(0.0, 1.0),
                                )!,
                                width: 2,
                              ),
                            ),
                            child: child,
                          );
                        },
                        child: Text(
                          char,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: filled
                                        ? scheme.onSecondaryContainer
                                        : scheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
