import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard helpers shared by expressive navigation widgets.
abstract final class MEKeyboard {
  /// Returns the delta to apply to a selected index for a vertical arrow key.
  static int? verticalDelta(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) return -1;
    if (key == LogicalKeyboardKey.arrowDown) return 1;
    return null;
  }

  /// Computes the next selected index for vertical navigation keys.
  static int? resolveVerticalSelection({
    required KeyEvent event,
    required int current,
    required int count,
    bool wrap = true,
  }) {
    if (event is! KeyDownEvent || count <= 0) return null;

    if (event.logicalKey == LogicalKeyboardKey.home) return 0;
    if (event.logicalKey == LogicalKeyboardKey.end) return count - 1;

    final delta = verticalDelta(event.logicalKey);
    if (delta == null) return null;

    final next = current + delta;
    if (next >= 0 && next < count) return next;
    if (!wrap) return null;
    return next < 0 ? count - 1 : 0;
  }

  /// Handles vertical navigation keys for a mutually-exclusive group.
  static KeyEventResult handleVerticalSelection({
    required KeyEvent event,
    required int current,
    required int count,
    required ValueChanged<int> onSelected,
    bool wrap = true,
  }) {
    final next = resolveVerticalSelection(
      event: event,
      current: current,
      count: count,
      wrap: wrap,
    );
    if (next == null || next == current) return KeyEventResult.ignored;
    onSelected(next);
    return KeyEventResult.handled;
  }

  /// Returns the delta to apply to a selected index for a horizontal arrow
  /// key, honoring [TextDirection].
  static int? horizontalDelta(LogicalKeyboardKey key, TextDirection direction) {
    final isRtl = direction == TextDirection.rtl;
    if (key == LogicalKeyboardKey.arrowLeft) return isRtl ? 1 : -1;
    if (key == LogicalKeyboardKey.arrowRight) return isRtl ? -1 : 1;
    return null;
  }

  /// Computes the next selected index for horizontal navigation keys.
  ///
  /// Returns `null` when the key is not handled or the selection would not
  /// change (when [wrap] is false and the target is out of range).
  static int? resolveHorizontalSelection({
    required KeyEvent event,
    required int current,
    required int count,
    required TextDirection direction,
    bool wrap = true,
  }) {
    if (event is! KeyDownEvent || count <= 0) return null;

    if (event.logicalKey == LogicalKeyboardKey.home) return 0;
    if (event.logicalKey == LogicalKeyboardKey.end) return count - 1;

    final delta = horizontalDelta(event.logicalKey, direction);
    if (delta == null) return null;

    final next = current + delta;
    if (next >= 0 && next < count) return next;
    if (!wrap) return null;
    return next < 0 ? count - 1 : 0;
  }

  /// Handles horizontal navigation keys for a mutually-exclusive group.
  static KeyEventResult handleHorizontalSelection({
    required KeyEvent event,
    required int current,
    required int count,
    required TextDirection direction,
    required ValueChanged<int> onSelected,
    bool wrap = true,
  }) {
    final next = resolveHorizontalSelection(
      event: event,
      current: current,
      count: count,
      direction: direction,
      wrap: wrap,
    );
    if (next == null || next == current) return KeyEventResult.ignored;
    onSelected(next);
    return KeyEventResult.handled;
  }

  /// Activates a pressable control on Enter / Space.
  static KeyEventResult handleActivation({
    required KeyEvent event,
    required VoidCallback? onActivate,
  }) {
    if (onActivate == null || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      onActivate();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
