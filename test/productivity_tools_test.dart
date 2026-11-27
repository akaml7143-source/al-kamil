import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_kamil/productivity_tools.dart';

void main() {
  test('Hijri civil date formatter marks its result as approximate', () {
    final value = approximateHijriDate(DateTime(2026, 11, 27));
    expect(value, contains('هـ (تقريبي)'));
    expect(value, contains('جمادى'));
  });

  testWidgets('reminders are empty on first install and are not auto-created', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ProductivityToolsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد تذكيرات بعد.'), findsOneWidget);
    expect(find.textContaining('ليست إشعارات نظام'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('local_reminders_v1'), isNull);
  });

  testWidgets('Quran plan exposes daily goal and bookmark tools', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ProductivityToolsScreen(initialTab: 1)));
    await tester.pumpAndSettle();
    expect(find.text('الورد اليومي وخطة الختمة'), findsOneWidget);
    expect(find.text('حفظ آخر صفحة'), findsOneWidget);
  });
}
