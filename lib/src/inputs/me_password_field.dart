import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/me_motion.dart';
import '../theme/me_theme.dart';
import 'me_text_field.dart';

/// A Material 3 Expressive password field.
///
/// Composes [METextField] with a visibility toggle and an optional
/// spring-animated strength meter whose segments fill and recolor as the
/// password improves.
class MEPasswordField extends StatefulWidget {
  const MEPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.label = 'Password',
    this.hintText,
    this.helperText,
    this.errorText,
    this.showStrengthMeter = false,
    this.strengthEvaluator,
    this.strengthLabel,
    this.trailingActions,
    this.showPasswordTooltip,
    this.hidePasswordTooltip,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  /// Show the animated strength meter below the field while focused.
  final bool showStrengthMeter;

  /// Returns strength 0.0-1.0. Defaults to a simple length/variety score.
  final double Function(String password)? strengthEvaluator;

  /// Optional label beside the meter (e.g. Weak / Strong).
  final String? Function(double strength)? strengthLabel;

  /// Extra trailing controls shown before the visibility toggle
  /// (for example a tools menu anchored to this field).
  final Widget? trailingActions;

  final String? showPasswordTooltip;
  final String? hidePasswordTooltip;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<MEPasswordField> createState() => _MEPasswordFieldState();
}

class _MEPasswordFieldState extends State<MEPasswordField> {
  bool _obscured = true;
  double _strength = 0;
  bool _focused = false;
  FocusNode? _focusNode;
  bool _ownsFocusNode = false;

  FocusNode get _effectiveFocusNode => _focusNode!;

  static double _defaultStrength(String password) {
    if (password.isEmpty) return 0;
    double score = (password.length / 12).clamp(0.0, 0.5);
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.125;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.125;
    if (RegExp(r'\d').hasMatch(password)) score += 0.125;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 0.125;
    return score.clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _effectiveFocusNode.addListener(_handleFocusChange);
    _focused = _effectiveFocusNode.hasFocus;
    widget.controller?.addListener(_syncStrengthFromController);
    _syncStrengthFromController();
  }

  @override
  void didUpdateWidget(covariant MEPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_syncStrengthFromController);
      widget.controller?.addListener(_syncStrengthFromController);
      _syncStrengthFromController();
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode?.removeListener(_handleFocusChange);
      if (_ownsFocusNode) _focusNode?.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _effectiveFocusNode.addListener(_handleFocusChange);
      _focused = _effectiveFocusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_syncStrengthFromController);
    final focusNode = _focusNode;
    if (focusNode != null) {
      focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    final next = _effectiveFocusNode.hasFocus;
    if (next == _focused) return;
    setState(() => _focused = next);
  }

  void _syncStrengthFromController() {
    if (!widget.showStrengthMeter) return;
    final text = widget.controller?.text ?? '';
    final next = (widget.strengthEvaluator ?? _defaultStrength)(text);
    if (next == _strength) return;
    setState(() => _strength = next);
  }

  void _handleChanged(String value) {
    if (widget.showStrengthMeter) {
      setState(() {
        _strength = (widget.strengthEvaluator ?? _defaultStrength)(value);
      });
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;
    final showMeter = widget.showStrengthMeter && _focused;

    Color strengthColor(double s) {
      if (s < 0.35) return scheme.error;
      if (s < 0.7) return scheme.tertiary;
      return scheme.primary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        METextField(
          controller: widget.controller,
          focusNode: _effectiveFocusNode,
          label: widget.label,
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          leadingIcon: const Icon(Icons.lock_outline),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.trailingActions != null) widget.trailingActions!,
              IconButton(
                tooltip: _obscured
                    ? (widget.showPasswordTooltip ?? 'Show password')
                    : (widget.hidePasswordTooltip ?? 'Hide password'),
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              ),
            ],
          ),
          onChanged: _handleChanged,
          onSubmitted: widget.onSubmitted,
        ),
        MEMotionReveal(
          visible: showMeter,
          spec: motion.defaultEffects,
          axis: Axis.vertical,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 4,
              end: 4,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      for (var i = 0; i < 4; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(
                          child: MEMotionBuilder(
                            value: (_strength * 4 - i).clamp(0.0, 1.0),
                            spec: motion.defaultEffects,
                            builder: (context, fill, _) => Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  scheme.surfaceContainerHighest,
                                  strengthColor(_strength),
                                  fill.clamp(0.0, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.strengthLabel != null && _strength > 0) ...[
                  const SizedBox(width: 10),
                  AnimatedDefaultTextStyle(
                    duration: motion.defaultEffects.approximateDuration,
                    curve: motion.defaultEffects.curve,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: strengthColor(_strength),
                          fontWeight: FontWeight.w600,
                        ),
                    child: Text(widget.strengthLabel!(_strength) ?? ''),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
