import 'package:flutter_test/flutter_test.dart';
import 'package:fluxshop/main.dart';

void main() {
  testWidgets('FluxShop app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('FluxShop'), findsWidgets);
  });
}
