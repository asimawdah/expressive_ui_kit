import 'package:flutter/material.dart';

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
    this.label = 'Password',
    this.hintText,
    this.helperText,
    this.errorText,
    this.showStrengthMeter = false,
    this.strengthEvaluator,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  /// Show the animated strength meter below the field.
  final bool showStrengthMeter;

  /// Returns strength 0.0-1.0. Defaults to a simple length/variety score.
  final double Function(String password)? strengthEvaluator;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<MEPasswordField> createState() => _MEPasswordFieldState();
}

class _MEPasswordFieldState extends State<MEPasswordField> {
  bool _obscured = true;
  double _strength = 0;

  static double _defaultStrength(String password) {
    if (password.isEmpty) return 0;
    double score = (password.length / 12).clamp(0.0, 0.5);
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.125;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.125;
    if (RegExp(r'\d').hasMatch(password)) score += 0.125;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 0.125;
    return score.clamp(0.0, 1.0);
  }

  void _handleChanged(String value) {
    if (widget.showStrengthMeter) {
      setState(() {
        _strength =
            (widget.strengthEvaluator ?? _defaultStrength)(value);
      });
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = METheme.of(context).motion;

    Color strengthColor(double s) {
      if (s < 0.35) return scheme.error;
      if (s < 0.7) return scheme.tertiary;
      return scheme.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        METextField(
          controller: widget.controller,
          label: widget.label,
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          obscureText: _obscured,
          leadingIcon: const Icon(Icons.lock_outline),
          trailingIcon: Icon(
            _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onTrailingIconPressed: () => setState(() => _obscured = !_obscured),
          onChanged: _handleChanged,
          onSubmitted: widget.onSubmitted,
        ),
        if (widget.showStrengthMeter) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        end: (_strength * 4 - i).clamp(0.0, 1.0),
                      ),
                      duration: motion.defaultEffects.approximateDuration,
                      curve: motion.defaultEffects.curve,
                      builder: (context, fill, _) => Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            scheme.surfaceContainerHighest,
                            strengthColor(_strength),
                            fill,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
