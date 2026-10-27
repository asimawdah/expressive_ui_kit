import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expressive_ui_kit/expressive_ui_kit.dart';

/// Pumps [child] inside a fixed-size golden surface with a stable theme.
Future<void> pumpGolden(
  WidgetTester tester,
  Widget child, {
  Size surfaceSize = const Size(320, 200),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D6B35)),
      ),
      home: METheme(
        data: METhemeData.standard,
        child: Scaffold(
          body: Center(child: child),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

/// Pumps [child] with a dark color scheme for golden comparisons.
Future<void> pumpGoldenDark(
  WidgetTester tester,
  Widget child, {
  Size surfaceSize = const Size(320, 200),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D6B35),
          brightness: Brightness.dark,
        ),
      ),
      home: METheme(
        data: METhemeData.standard,
        child: Scaffold(
          body: Center(child: child),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}
