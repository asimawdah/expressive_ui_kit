import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_shapes.dart';
import '../theme/me_theme.dart';

/// Visual variant for [METextField].
enum METextFieldVariant { filled, outlined }

/// A Material 3 Expressive text field.
///
/// Replaces [TextField] / [TextFormField]. The container morphs shape and
/// the focus indicator animates with a spatial spring when focus changes:
/// the resting shape is fully rounded and squares off slightly while
/// focused, echoing the shape-as-state language used across M3 Expressive.
class METextField extends StatefulWidget {
  const METextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingIconPressed,
    this.trailing,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.variant = METextFieldVariant.filled,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onTrailingIconPressed;

  /// Custom suffix widget. When set, takes precedence over [trailingIcon].
  final Widget? trailing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final METextFieldVariant variant;

  @override
  State<METextField> createState() => _METextFieldState();
}

class _METextFieldState extends State<METextField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusAnim =
      AnimationController.unbounded(vsync: this, value: 0);
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  MESpringSpec _fastSpatial = MESpringSpec.expressiveSpatialFast;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fastSpatial = METheme.of(context).motion.fastSpatial;
  }

  @override
  void didUpdateWidget(METextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;
    springTo(
      _focusAnim,
      _focusNode.hasFocus ? 1 : 0,
      _fastSpatial,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    _focusAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasError = widget.errorText != null;
    final filled = widget.variant == METextFieldVariant.filled;

    final field = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixIcon: widget.leadingIcon,
        suffixIcon: widget.trailing ??
            (widget.trailingIcon == null
                ? null
                : IconButton(
                    icon: widget.trailingIcon!,
                    onPressed: widget.onTrailingIconPressed,
                  )),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _focusAnim,
          child: field,
          builder: (context, child) {
            final t = _focusAnim.value.clamp(0.0, 1.0);
            // Fully rounded at rest -> largeIncreased corner when focused.
            final radius = 28.0 + (MECorners.largeIncreased - 28.0) * t;
            final borderColor = hasError
                ? scheme.error
                : Color.lerp(scheme.outlineVariant, scheme.primary, t)!;
            final borderWidth = 1.0 + 1.5 * t;

            return Material(
              color: filled ? scheme.surfaceContainerHigh : Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
                side: BorderSide(color: borderColor, width: borderWidth),
              ),
              child: child,
            );
          },
        ),
        if (widget.errorText != null || widget.helperText != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasError ? scheme.error : scheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }
}
