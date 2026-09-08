import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// System chrome (status + navigation bars) aligned with [ColorScheme].
abstract final class MESystemUi {
  static SystemUiOverlayStyle overlayFor(
    ColorScheme scheme, {
    Color? navigationBarColor,
    Color? statusBarColor,
  }) {
    final isDark = scheme.brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor ?? Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: navigationBarColor ?? scheme.surface,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
