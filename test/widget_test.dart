import 'package:flutter_test/flutter_test.dart';
import 'package:huaxia_footprint/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HuaxiaFootprintApp());
    // Just verify it builds without crashing
  });
}
