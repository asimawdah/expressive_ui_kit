import 'package:flutter/material.dart';

/// M3 Expressive Button with spring-based animations, shape morph on press,
/// and vibrant color options.
///
/// Implements Material 3 Expressive design principles:
/// - Spring-based motion (spatial spring with overshoot for scale)
/// - Shape morph: round → square corner radius shift on press
/// - 5 sizes: extra small (32dp), small (40dp), medium (48dp), large (56dp),
///   extra large (64dp) per M3 Expressive spec
/// - 4 color styles: filled, tonal, outlined, text
/// - Rich, vibrant color usage with primary/secondary/tertiary roles
/// - 20dp icon size, 8dp icon-to-label gap
/// Legacy expressive button API.
///
/// Prefer [MEButton] for new code. This widget remains for backward
/// compatibility and uses a slightly different size scale.
@Deprecated(
    'Use MEButton instead. ExpressiveButton will be removed in a future release.')
class ExpressiveButton extends StatefulWidget {
  const ExpressiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.style = ExpressiveButtonStyle.filled,
    this.size = ExpressiveButtonSize.large,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final ExpressiveButtonStyle style;
  final ExpressiveButtonSize size;
  final bool expanded;

  @override
  State<ExpressiveButton> createState() => _ExpressiveButtonState();
}

@Deprecated('Use MEButtonVariant instead.')
enum ExpressiveButtonStyle { filled, tonal, outlined, text }

/// M3 Expressive sizes: XS(32), S(40), M(48), L(56), XL(64)
@Deprecated('Use MEButtonSize instead.')
enum ExpressiveButtonSize { extraSmall, small, medium, large, extraLarge }

class _ExpressiveButtonState extends State<ExpressiveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    // M3 Expressive spatial spring: overshoot on scale
    _scaleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.94), weight: 35),
        TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.03), weight: 35),
        TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 30),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    // M3 Expressive shape morph: round → square on press
    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  // M3 Expressive spec heights
  double get _height => switch (widget.size) {
        ExpressiveButtonSize.extraSmall => 32,
        ExpressiveButtonSize.small => 40,
        ExpressiveButtonSize.medium => 48,
        ExpressiveButtonSize.large => 56,
        ExpressiveButtonSize.extraLarge => 64,
      };

  double get _fontSize => switch (widget.size) {
        ExpressiveButtonSize.extraSmall => 12,
        ExpressiveButtonSize.small => 14,
        ExpressiveButtonSize.medium => 15,
        ExpressiveButtonSize.large => 16,
        ExpressiveButtonSize.extraLarge => 18,
      };

  // Round shape: fully rounded per M3 spec
  double get _roundRadius => _height / 2;

  // Square shape: M3 spec corner radius scales with size
  double get _squareRadius => switch (widget.size) {
        ExpressiveButtonSize.extraSmall => 8, // M3 small
        ExpressiveButtonSize.small => 12, // M3 medium
        ExpressiveButtonSize.medium => 16, // M3 large
        ExpressiveButtonSize.large => 20, // M3 large increased
        ExpressiveButtonSize.extraLarge => 24,
      };

  // M3 Expressive recommends 16dp for small sizes
  double get _horizontalPadding => switch (widget.size) {
        ExpressiveButtonSize.extraSmall => 12,
        ExpressiveButtonSize.small => 16,
        ExpressiveButtonSize.medium => 24,
        ExpressiveButtonSize.large => 32,
        ExpressiveButtonSize.extraLarge => 36,
      };

  double get _iconSize => switch (widget.size) {
        ExpressiveButtonSize.extraSmall => 16,
        ExpressiveButtonSize.small => 18,
        ExpressiveButtonSize.medium => 20,
        ExpressiveButtonSize.large => 20,
        ExpressiveButtonSize.extraLarge => 24,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bgColor, fgColor, borderSide) = switch (widget.style) {
      ExpressiveButtonStyle.filled => (
          cs.primary,
          cs.onPrimary,
          BorderSide.none,
        ),
      ExpressiveButtonStyle.tonal => (
          cs.secondaryContainer,
          cs.onSecondaryContainer,
          BorderSide.none,
        ),
      ExpressiveButtonStyle.outlined => (
          Colors.transparent,
          cs.onSurface,
          BorderSide(color: cs.outline, width: 1.5),
        ),
      ExpressiveButtonStyle.text => (
          Colors.transparent,
          cs.primary,
          BorderSide.none,
        ),
    };

    final isEnabled = widget.onPressed != null;
    final effectiveBgColor =
        isEnabled ? bgColor : bgColor.withValues(alpha: 0.38);
    final effectiveFgColor =
        isEnabled ? fgColor : fgColor.withValues(alpha: 0.38);

    return GestureDetector(
      onTapDown: isEnabled ? _onTapDown : null,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final morphValue = _morphAnimation.value;
          final currentRadius =
              _roundRadius + (_squareRadius - _roundRadius) * morphValue;
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: _height,
              padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
              decoration: BoxDecoration(
                color: effectiveBgColor,
                borderRadius: BorderRadius.circular(currentRadius),
                border: borderSide != BorderSide.none
                    ? Border.fromBorderSide(borderSide)
                    : null,
              ),
              constraints: widget.expanded
                  ? const BoxConstraints(minWidth: double.infinity)
                  : null,
              child: Row(
                mainAxisSize:
                    widget.expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: effectiveFgColor,
                        size: _iconSize,
                      ),
                      child: widget.icon!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: effectiveFgColor,
                          fontSize: _fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
