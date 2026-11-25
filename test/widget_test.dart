import 'package:material_ui/material_ui.dart';
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

  testWidgets('Dua al-Ahd is available offline', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الأدعية العامة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دعاء العهد').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('اللّهُمَّ رَبَّ النُّورِ العَظِيمِ'), findsOneWidget);
    expect(find.textContaining('العَجَلَ العَجَلَ يا مَوْلايَ يا صاحِبَ الزَّمانِ'), findsOneWidget);
  });

  testWidgets('Dua al-Iftitah is available offline through its final passage',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الأدعية العامة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دعاء الافتتاح'));
    await tester.pumpAndSettle();

    expect(find.textContaining('اللّهُمَّ إِنِّي أَفْتَتِحُ الثَّناءَ'), findsOneWidget);
    expect(find.textContaining('اللّهُمَّ إِنّا نَشْكُو إِلَيْكَ فَقْدَ نَبِيِّنا'), findsOneWidget);
  });


  testWidgets('reader font size can be increased and persists locally',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الزيارات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('زيارة عاشوراء').first);
    await tester.pumpAndSettle();

    expect(find.text('18'), findsOneWidget);
    await tester.tap(find.byTooltip('تكبير الخط'));
    await tester.pumpAndSettle();
    expect(find.text('19'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getInt('reader_font_size'),
      19,
    );
  });



  testWidgets('reader search highlights matches and bookmark updates immediately',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الزيارات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('زيارة عاشوراء').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('إضافة إلى المفضلة'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('إزالة من المفضلة'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getStringList('library_favorites'),
      contains('visit_ashura'),
    );

    await tester.enterText(
      find.byKey(const Key('reader_text_search')),
      'السَّلامُ عَلَيْكَ',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('النتائج:'), findsOneWidget);
    expect(find.textContaining('النتائج: 0'), findsNothing);
  });



  testWidgets('prayer taqibat show sourced offline text and save progress per prayer',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعقيبات الصلوات'));
    await tester.pumpAndSettle();

    for (final title in [
      'تعقيبات صلاة الفجر',
      'تعقيبات صلاة الظهر',
      'تعقيبات صلاة العصر',
      'تعقيبات صلاة المغرب',
      'تعقيبات صلاة العشاء',
    ]) {
      expect(find.text(title), findsOneWidget);
    }

    await tester.tap(find.text('تعقيبات صلاة الفجر'));
    await tester.pumpAndSettle();
    expect(find.textContaining('تسبيح الزهراء'), findsOneWidget);
    expect(find.textContaining('اللهُ أَكْبَرُ — ٣٤ مرة'), findsOneWidget);
    expect(find.textContaining('إلى طلوع الشمس'), findsAtLeastNWidgets(1));

    await tester.tap(find.byKey(const Key('taqibat_progress_toggle')));
    await tester.pumpAndSettle();
    expect(
      (await SharedPreferences.getInstance())
          .getBool('taqibat_completed_taqib_fajr'),
      isTrue,
    );

    // Scroll from a known point inside the test viewport. The reader uses
    // a lazy ListView, so the source text is created only after scrolling.
    final sourceFinder = find.textContaining('sistani.org/arabic/book/23/1900/');
    for (var attempt = 0; attempt < 20 && sourceFinder.evaluate().isEmpty; attempt++) {
      await tester.dragFrom(
        const Offset(400, 500),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
    }
    expect(sourceFinder, findsOneWidget);
  });

  testWidgets('offline prayer times calculate, change city and persist settings',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مواقيت الصلاة'));
    await tester.pumpAndSettle();

    expect(find.text('الصلاة القادمة'), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_fajr')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_sunrise')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_dhuhr')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_asr')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_maghrib')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_isha')), findsOneWidget);

    final cityButton = find.byKey(const Key('prayer_city_dropdown'));
    await tester.ensureVisible(cityButton);
    await tester.pumpAndSettle();
    await tester.tap(cityButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('البصرة').last);
    await tester.pumpAndSettle();

    expect(find.text('البصرة'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance())
          .getString('prayer_times_city'),
      'basra',
    );

    final methodButton = find.byKey(const Key('prayer_method_dropdown'));
    await tester.ensureVisible(methodButton);
    await tester.pumpAndSettle();
    await tester.tap(methodButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('جامعة طهران').last);
    await tester.pumpAndSettle();
    expect(
      (await SharedPreferences.getInstance())
          .getString('prayer_times_method'),
      'tehran',
    );
  });

  testWidgets('night prayer tutorial explains the rakah structure and saves lesson progress',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعليم صلاة الليل'));
    await tester.pumpAndSettle();

    expect(find.text('الصورة المشهورة: ١١ ركعة؛ ثمانٍ نافلة الليل، ثم ركعتا الشفع، ثم ركعة الوتر.'), findsOneWidget);
    expect(find.text('وقت صلاة الليل'), findsOneWidget);
    await tester.tap(find.text('وقت صلاة الليل'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('night_prayer_step_0')));
    await tester.pumpAndSettle();

    expect(
      (await SharedPreferences.getInstance())
          .getStringList('night_prayer_completed_steps'),
      contains('0'),
    );
  });

}
