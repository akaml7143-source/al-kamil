import 'package:flutter_test/flutter_test.dart';
import 'package:al_kamil/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('welcome screen enters the Al-Kamil home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    expect(find.text('تفضّل بالدخول'), findsOneWidget);
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    expect(find.text('أقسام الكامل'), findsOneWidget);
    expect(find.text('القرآن الكريم'), findsOneWidget);
  });

  testWidgets('offline tasbeeh counter increments and persists locally',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('المسبحة الإلكترونية'));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    final tasbeehButton = find.text('سبّح');
    await tester.ensureVisible(tasbeehButton);
    await tester.pumpAndSettle();
    await tester.tap(tasbeehButton);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getInt('tasbeeh_count_takbir'),
      1,
    );
  });

  testWidgets('library favorites and last-read item are stored locally',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('الزيارات'));
    await tester.pumpAndSettle();
    expect(find.text('زيارة عاشوراء'), findsOneWidget);
    await tester.tap(find.byTooltip('إضافة إلى المفضلة').first);
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getStringList('library_favorites'), contains('visit_ashura'));

    await tester.tap(find.text('زيارة عاشوراء').first);
    await tester.pumpAndSettle();
    expect(preferences.getString('library_last_read'), 'visit_ashura');
    expect(
      find.textContaining('السَّلامُ عَلَيْكَ يا أَبا عَبْدِ اللهِ'),
      findsOneWidget,
    );
  });

  testWidgets('verified tawassul prayer text is available offline',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الأدعية العامة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دعاء التوسل'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('اللّهُمَّ إِنِّي أَسْأَلُكَ وَأَتَوَجَّهُ إِلَيْكَ'),
      findsOneWidget,
    );
  });
}
