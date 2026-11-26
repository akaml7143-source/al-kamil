import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_kamil/main.dart';
import 'package:al_kamil/qibla_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> tapHomeSection(WidgetTester tester, String title) async {
  final target = find.text(title).first;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

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
    await tapHomeSection(tester, 'المسبحة الإلكترونية');
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

    await tapHomeSection(tester, 'الزيارات');
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
    await tapHomeSection(tester, 'الأدعية العامة');
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
    await tapHomeSection(tester, 'الأدعية العامة');
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
    await tapHomeSection(tester, 'الأدعية العامة');
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
    await tapHomeSection(tester, 'الزيارات');
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
    await tapHomeSection(tester, 'الزيارات');
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
    await tapHomeSection(tester, 'تعقيبات الصلوات');
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
    await tapHomeSection(tester, 'مواقيت الصلاة');
    await tester.pumpAndSettle();

    expect(find.text('الصلاة القادمة'), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_fajr')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_sunrise')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_dhuhr')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_asr')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_maghrib')), findsOneWidget);
    expect(find.byKey(const Key('prayer_time_isha')), findsOneWidget);

    final cityButton = find.byKey(const Key('prayer_city_dropdown'));
    await tester.scrollUntilVisible(
      cityButton,
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(cityButton);
    await tester.pumpAndSettle();
    final basraOption = find.byKey(const Key('prayer_city_basra'));
    await tester.ensureVisible(basraOption);
    await tester.pumpAndSettle();
    await tester.tap(basraOption);
    await tester.pumpAndSettle();

    expect(find.text('اختيار المدينة: البصرة'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance())
          .getString('prayer_times_city'),
      'basra',
    );

    final methodButton = find.byKey(const Key('prayer_method_dropdown'));
    await tester.scrollUntilVisible(
      methodButton,
      400,
      scrollable: find.byType(Scrollable).last,
    );
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
    await tapHomeSection(tester, 'تعليم صلاة الليل');
    await tester.pumpAndSettle();

    expect(find.text('صلاة الليل ١١ ركعة: ٨ ركعات نافلة الليل، وركعتا الشفع، وركعة الوتر.'), findsOneWidget);
    final thirdSection = find.text('ثالثاً: ركعة الوتر');
    await tester.ensureVisible(thirdSection);
    await tester.pumpAndSettle();
    expect(thirdSection, findsOneWidget);
    expect(find.byKey(const Key('night_counter_forty')), findsOneWidget);
    expect(find.byKey(const Key('night_counter_istighfar')), findsOneWidget);
    expect(find.byKey(const Key('night_counter_aidh')), findsOneWidget);
    expect(find.byKey(const Key('night_counter_afw')), findsOneWidget);

    final firstLesson = find.byKey(const Key('night_prayer_step_0'));
    await tester.ensureVisible(firstLesson);
    await tester.pumpAndSettle();
    await tester.tap(firstLesson);
    await tester.pumpAndSettle();

    // All lesson widgets are mounted in the scroll view; bring the counter
    // back into the viewport before tapping it.
    await tester.ensureVisible(thirdSection);
    await tester.pumpAndSettle();
    final istighfarButton = find.byKey(const Key('night_prayer_counter_istighfar_increment'));
    expect(istighfarButton, findsOneWidget);
    await tester.ensureVisible(istighfarButton);
    await tester.pumpAndSettle();
    await tester.tap(istighfarButton);
    await tester.pumpAndSettle();
    expect(find.text('1 / 70'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getInt('night_prayer_counter_istighfar'),
      1,
    );
    expect(
      (await SharedPreferences.getInstance())
          .getStringList('night_prayer_completed_steps'),
      contains('0'),
    );
  });



  testWidgets('global offline search finds a verified dua by title and opens its text',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tapHomeSection(tester, 'البحث الشامل');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('global_local_search')),
      'دعاء العهد',
    );
    await tester.pumpAndSettle();
    expect(find.text('دعاء العهد'), findsNWidgets(3));
    expect(find.textContaining('عدد النتائج: 1'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'دعاء العهد').first);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('اللّهُمَّ رَبَّ النُّورِ العَظِيمِ'),
      findsOneWidget,
    );
    expect(
      (await SharedPreferences.getInstance()).getString('library_last_read'),
      'dua_ahd',
    );
  });

  test('Qibla bearing is normalized and points southwest from Iraqi cities', () {
    final baghdadBearing = calculateQiblaBearing(33.3152, 44.3661);
    final basraBearing = calculateQiblaBearing(30.5085, 47.7804);
    expect(baghdadBearing, inInclusiveRange(180, 260));
    expect(basraBearing, inInclusiveRange(180, 260));
    expect(baghdadBearing, lessThan(360));
    expect(basraBearing, greaterThanOrEqualTo(0));
  });

  testWidgets('Qibla screen calculates direction offline and saves selected city',
      (tester) async {
    // Show all home-grid rows so the Qibla tile is built in this widget test.
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlKamilApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفضّل بالدخول'));
    await tester.pumpAndSettle();
    await tapHomeSection(tester, 'القبلة');
    await tester.pumpAndSettle();

    expect(find.text('اتجاه القبلة'), findsOneWidget);
    expect(find.text('بغداد'), findsOneWidget);
    expect(find.byKey(const Key('qibla_bearing')), findsOneWidget);

    await tester.tap(find.byKey(const Key('qibla_city_picker')));
    await tester.pumpAndSettle();
    final basra = find.byKey(const Key('qibla_city_basra'));
    await tester.ensureVisible(basra);
    await tester.pumpAndSettle();
    await tester.tap(basra);
    await tester.pumpAndSettle();

    expect(find.text('البصرة'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getString('qibla_city'),
      'basra',
    );
    expect(find.byKey(const Key('qibla_bearing')), findsOneWidget);
  });

}
