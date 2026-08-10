import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';

/// Pumps [child] inside a fixed-size golden surface with a stable theme.
Future<void> pumpGolden(WidgetTester tester, Widget child) async {
  const surface = Size(320, 200);

  await tester.binding.setSurfaceSize(surface);
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
