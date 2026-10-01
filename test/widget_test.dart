import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce_app/core/app.dart';

void main() {
  testWidgets('Avero app shows the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AveroApp());

    expect(find.text('Avero'), findsOneWidget);
  });
}
