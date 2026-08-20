import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_expressive/material3_expressive.dart';
import 'package:material3_expressive_example/gallery/catalog.dart';
import 'package:material3_expressive_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('gallery home lists every catalog entry', (tester) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pump();

    expect(kCatalog, isNotEmpty);
    expect(find.text('Widget gallery'), findsWidgets);
    expect(
      find.textContaining('${kCatalog.length} components'),
      findsWidgets,
    );
  });

  testWidgets('every catalog playground builds without throwing',
      (tester) async {
    final failures = <String>[];

    for (final entry in kCatalog) {
      await tester.pumpWidget(_PlaygroundHost(entry: entry));
      await tester.pump(const Duration(milliseconds: 16));
      if (find.text(entry.name).evaluate().isEmpty) {
        failures.add('${entry.name}: missing app bar title');
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 5));
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}

class _PlaygroundHost extends StatelessWidget {
  const _PlaygroundHost({required this.entry});

  final CatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D6B35)),
        useMaterial3: true,
      ),
      builder: (context, child) => METheme(
        data: METhemeData.expressive,
        child: child!,
      ),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            MEAppBar(title: Text(entry.name)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  width: 400,
                  child: entry.demo(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
