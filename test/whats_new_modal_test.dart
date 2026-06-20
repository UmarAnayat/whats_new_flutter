import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whats_new_flutter/whats_new_flutter.dart';

void main() {
  group('WhatsNewConfig', () {
    test('creates valid config with required fields', () {
      const config = WhatsNewConfig(
        version: '2.0.0',
        title: "What's New",
        subtitle: 'Welcome to the latest update',
        features: [
          WhatsNewFeatureItem(
            icon: Icons.bolt_rounded,
            title: 'Faster checkout',
            description: 'Complete purchases in fewer steps.',
          ),
        ],
      );

      expect(config.version, '2.0.0');
      expect(config.title, "What's New");
      expect(config.subtitle, 'Welcome to the latest update');
      expect(config.features, hasLength(1));
      expect(config.continueLabel, 'Continue');
    });
  });

  group('WhatsNewModal', () {
    testWidgets('show renders title and three features', (tester) async {
      const config = WhatsNewConfig(
        version: '2.0.0',
        title: "What's New",
        subtitle: 'Welcome to the latest update',
        features: [
          WhatsNewFeatureItem(
            icon: Icons.bolt_rounded,
            title: 'Faster checkout',
            description: 'Complete purchases in fewer steps.',
          ),
          WhatsNewFeatureItem(
            icon: Icons.dark_mode_rounded,
            title: 'Dark mode',
            description: 'Easier on your eyes at night.',
          ),
          WhatsNewFeatureItem(
            icon: Icons.security_rounded,
            title: 'Security boost',
            description: 'Enhanced account protection.',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => WhatsNewModal.show(
                      context,
                      config: config,
                    ),
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.text("What's New").evaluate().isNotEmpty &&
            find.text('Continue').evaluate().isNotEmpty) {
          break;
        }
      }

      expect(find.text("What's New"), findsOneWidget);
      expect(find.text('Faster checkout'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Security boost'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('primary action dismisses modal', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const config = WhatsNewConfig(
        version: '2.0.0',
        title: "What's New",
        features: [
          WhatsNewFeatureItem(
            icon: Icons.bolt_rounded,
            title: 'Faster checkout',
            description: 'Complete purchases in fewer steps.',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => WhatsNewModal.show(
                      context,
                      config: config,
                    ),
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.text("What's New").evaluate().isNotEmpty) {
          final continueRect = tester.getRect(find.text('Continue'));
          if (continueRect.center.dy < tester.view.physicalSize.height) {
            break;
          }
        }
      }

      expect(find.text("What's New"), findsOneWidget);

      await tester.tap(find.text('Continue'), warnIfMissed: false);
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.text("What's New").evaluate().isEmpty) {
          break;
        }
      }

      expect(find.text("What's New"), findsNothing);
    });
  });
}
