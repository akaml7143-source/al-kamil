import 'package:flutter_test/flutter_test.dart';
import 'package:al_kamil/main.dart';

void main() {
  testWidgets('shows Al-Kamil home screen', (tester) async {
    await tester.pumpWidget(const AlKamilApp());
    expect(find.text('الكامل'), findsWidgets);
    expect(find.text('القرآن الكريم'), findsOneWidget);
  });
}
