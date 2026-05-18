import 'package:flutter_test/flutter_test.dart';
import 'package:project_aether/main.dart';

void main() {
  testWidgets('Aether app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const AetherApp());
    expect(find.text('PROJECT AETHER'), findsOneWidget);
  });
}
