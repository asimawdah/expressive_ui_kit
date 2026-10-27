import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expressive_ui_kit/expressive_ui_kit.dart';

void main() {
  group('MEPinPad', () {
    testWidgets('completes when length digits are entered', (tester) async {
      String? completed;

      await tester.pumpWidget(
        _host(
          MEPinPad(
            length: 4,
            onCompleted: (pin) => completed = pin,
          ),
        ),
      );

      for (final digit in ['1', '2', '3', '4']) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }

      expect(completed, '1234');
    });
  });

  group('MEReceipt', () {
    testWidgets('renders line items', (tester) async {
      await tester.pumpWidget(
        _host(
          const MEReceipt(
            lines: [
              MEReceiptLine('Coffee', '4.50'),
              MEReceiptLine('Total', '4.50', emphasized: true),
            ],
          ),
        ),
      );

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('4.50'), findsWidgets);
    });
  });

  group('MESplashScreen', () {
    testWidgets('renders logo without auto-dismiss', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            height: 400,
            child: MESplashScreen(
              autoDismiss: false,
              logo: Icon(Icons.eco, size: 48),
              title: Text('Gallery'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byIcon(Icons.eco), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
    });
  });

  group('MEVinyl', () {
    testWidgets('toggles playback on tap', (tester) async {
      var playing = false;

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return MEVinyl(
                playing: playing,
                onChanged: (value) => setState(() => playing = value),
              );
            },
          ),
        ),
      );

      expect(playing, isFalse);

      await tester.tap(find.byType(MEVinyl));
      await tester.pump();

      expect(playing, isTrue);
    });
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    builder: (context, child) => METheme(
      data: METhemeData.expressive,
      child: child!,
    ),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}
