import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce_app/core/widgets/avero_logo.dart';
import 'package:flutter_ecommerce_app/modules/splash/view/splash_view.dart';

void main() {
  // The full AveroApp needs Firebase, so this checks the splash view itself.
  testWidgets('Splash screen shows the Avero logo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashView()));

    expect(find.byType(AveroLogo), findsOneWidget);
  });
}
