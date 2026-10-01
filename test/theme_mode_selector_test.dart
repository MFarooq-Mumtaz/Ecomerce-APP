import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_ecommerce_app/core/theme/app_theme.dart';
import 'package:flutter_ecommerce_app/core/theme/theme_controller.dart';
import 'package:flutter_ecommerce_app/data/services/theme_storage_service.dart';
import 'package:flutter_ecommerce_app/modules/profile/widgets/theme_mode_selector.dart';

Widget _app(double width) {
  return GetMaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: Get.find<ThemeController>().themeMode.value,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: const ThemeModeSelector()),
      ),
    ),
  );
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(ThemeController(ThemeStorageService()));
  });

  tearDown(Get.reset);

  testWidgets('3 cards stay in one row without overflow on every width', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;

    for (final scale in [1.0, 1.3]) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      for (final width in [240.0, 288.0, 360.0, 560.0, 900.0]) {
        await tester.pumpWidget(_app(width));
        await tester.pump();

        expect(tester.takeException(), isNull, reason: '$width @ $scale');
        final labels = ['Light', 'Dark', 'System'].map(find.text).toList();
        for (final label in labels) {
          expect(label, findsOneWidget);
        }
        // One row: the 3 cards share the same top and size, left to right.
        final cards = tester
            .widgetList<InkWell>(find.byType(InkWell))
            .map((card) => tester.getRect(find.byWidget(card)))
            .toList();
        expect(cards, hasLength(3));
        for (final card in cards.skip(1)) {
          expect(card.top, closeTo(cards.first.top, 0.5));
          expect(card.width, closeTo(cards.first.width, 0.5));
          expect(card.height, closeTo(cards.first.height, 0.5));
        }
        expect(cards[0].left, lessThan(cards[1].left));
        expect(cards[1].left, lessThan(cards[2].left));
        // Each label sits inside its own card.
        for (var index = 0; index < 3; index += 1) {
          final label = tester.getRect(labels[index]);
          expect(cards[index].contains(label.center), isTrue);
        }
      }
    }
  });

  testWidgets('tapping a card switches the whole app theme', (tester) async {
    await tester.pumpWidget(_app(360));
    final controller = Get.find<ThemeController>();
    expect(controller.themeMode.value, ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(controller.themeMode.value, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Dark'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(controller.themeMode.value, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.text('Light'))).brightness,
      Brightness.light,
    );
  });
}
