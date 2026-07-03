import 'package:flutter/material.dart';

import 'me_motion.dart';
import 'me_shapes.dart';

/// Theme data for Material 3 Expressive widgets.
///
/// Provided to the tree with [METheme]. All `ME*` widgets read their motion
/// scheme and shape scheme from here, falling back to
/// [METhemeData.expressive] when no theme is present.
@immutable
class METhemeData {
  const METhemeData({
    this.motion = MEMotionScheme.expressive,
    this.shapes = const MEShapeScheme(),
  });

  final MEMotionScheme motion;
  final MEShapeScheme shapes;

  static const METhemeData expressive = METhemeData();

  static const METhemeData standard =
      METhemeData(motion: MEMotionScheme.standard);

  METhemeData copyWith({MEMotionScheme? motion, MEShapeScheme? shapes}) {
    return METhemeData(
      motion: motion ?? this.motion,
      shapes: shapes ?? this.shapes,
    );
  }
}

/// Provides an [METhemeData] to descendant Material 3 Expressive widgets.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => METheme(
///     data: METhemeData.expressive,
///     child: child!,
///   ),
/// )
/// ```
class METheme extends InheritedWidget {
  const METheme({super.key, required this.data, required super.child});

  final METhemeData data;

  static METhemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<METheme>();
    return theme?.data ?? METhemeData.expressive;
  }

  @override
  bool updateShouldNotify(METheme oldWidget) => data != oldWidget.data;
}

/// Emphasized text styles introduced by Material 3 Expressive.
///
/// Apply on top of the standard [TextTheme] for hero moments — large
/// headlines, display text and prominent labels.
abstract final class METypography {
  static TextStyle emphasize(TextStyle base) => base.copyWith(
        fontWeight: _bumpWeight(base.fontWeight ?? FontWeight.w400),
        letterSpacing: (base.letterSpacing ?? 0) - 0.1,
      );

  static FontWeight _bumpWeight(FontWeight w) {
    final index = FontWeight.values.indexOf(w);
    return FontWeight
        .values[(index + 2).clamp(0, FontWeight.values.length - 1)];
  }
}
