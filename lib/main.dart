import 'dart:ui' show ImageFilter;

import 'prayer_times_screen.dart';
import 'qibla_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlKamilApp());
}

// Twilight Glassmorphism design system: deep indigo, misty violet and luminous glass.
const Color royalBlack = Color(0xFF111329);
const Color panelBlack = Color(0xC9252B4A);
const Color gold = Color(0xFFC9B9FF);
const Color turquoise = Color(0xFF9D8CFF);
const Color ivory = Color(0xFFF4F1FF);
const Color mutedIvory = Color(0xFFC6C2DC);
const Color twilightSurface = Color(0xFF202542);
const Color twilightBorder = Color(0x66D5C9FF);

class AlKamilApp extends StatelessWidget {
  const AlKamilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الكامل',
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: royalBlack,
        colorScheme: ColorScheme.fromSeed(
          seedColor: turquoise,
          brightness: Brightness.dark,
          primary: gold,
          secondary: turquoise,
          surface: twilightSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xE6191D38),
          foregroundColor: ivory,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: panelBlack,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: twilightBorder, width: 0.8),
          ),
        ),
        dividerColor: twilightBorder,
        dialogTheme: const DialogThemeData(
          backgroundColor: twilightSurface,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const WelcomeGate(),
    );
  }
}


class WelcomeGate extends StatefulWidget {
  const WelcomeGate({super.key});

  @override
  State<WelcomeGate> createState() => _WelcomeGateState();
}

class _WelcomeGateState extends State<WelcomeGate> {
  bool? _hasEntered;

  @override
  void initState() {
    super.initState();
    _loadEntryState();
  }

  Future<void> _loadEntryState() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() => _hasEntered = preferences.getBool('has_entered_app') ?? false);
      }
    } catch (_) {
      if (mounted) setState(() => _hasEntered = false);
    }
  }

  Future<void> _enter() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('has_entered_app', true);
    } catch (_) {
      // The app remains usable even if local preference storage is unavailable.
    }
    if (mounted) setState(() => _hasEntered = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasEntered == null) {
      return const Scaffold(
        backgroundColor: royalBlack,
        body: Center(child: CircularProgressIndicator(color: gold)),
      );
    }
    if (_hasEntered!) return const HomePage();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: _TwilightGlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                radius: 26,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: panelBlack,
                      border: Border.all(color: gold, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: gold.withValues(alpha: 0.12),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mosque_rounded, color: gold, size: 76),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'تطبيق الكامل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gold,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'موسوعة الأدعية والزيارات وتعاليم أهل البيت (عليهم السلام)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ivory, fontSize: 15, height: 1.9),
                  ),
                  const SizedBox(height: 38),
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: FilledButton(
                      onPressed: _enter,
                      style: FilledButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: royalBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'تفضّل بالدخول',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'يعمل دون الحاجة إلى إنشاء حساب',
                    style: TextStyle(color: mutedIvory, fontSize: 12),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_Section> _sections = [
    _Section('البحث الشامل', Icons.search_rounded),
    _Section('القرآن الكريم', Icons.menu_book_rounded),
    _Section('مواقيت الصلاة', Icons.access_time_rounded),
    _Section('الزيارات', Icons.mosque_rounded),
    _Section('الأدعية العامة', Icons.volunteer_activism_rounded),
    _Section('أدعية الأيام', Icons.today_rounded),
    _Section('تعليم صلاة الليل', Icons.nightlight_round),
    _Section('تعقيبات الصلوات', Icons.self_improvement_rounded),
    _Section('المسبحة الإلكترونية', Icons.grain_rounded),
    _Section('الصحيفة السجادية', Icons.article_rounded),
    _Section('وصايا أهل البيت', Icons.format_quote_rounded),
    _Section('المناسبات الإسلامية', Icons.celebration_rounded),
    _Section('القبلة', Icons.explore_rounded),
    _Section('المفضلة', Icons.bookmark_rounded),
    _Section('التنبيهات', Icons.notifications_active_rounded),
    _Section('الإعدادات', Icons.settings_rounded),
  ];

  void _openSection(BuildContext context, _Section section) {
    final Widget page = switch (section.title) {
      'القرآن الكريم' => const QuranScreen(),
      'مواقيت الصلاة' => const PrayerTimesScreen(),
      'القبلة' => const QiblaScreen(),
      'البحث الشامل' => const GlobalSearchScreen(),
      'تعليم صلاة الليل' => const NightPrayerTutorialScreen(),
      'المسبحة الإلكترونية' => const TasbeehScreen(),
      'المفضلة' => const LibrarySectionScreen(title: 'المفضلة'),
      'الزيارات' ||
      'الأدعية العامة' ||
      'أدعية الأيام' ||
      'تعقيبات الصلوات' ||
      'الصحيفة السجادية' ||
      'وصايا أهل البيت' => LibrarySectionScreen(title: section.title),
      'الإعدادات' => const SettingsScreen(),
      _ => SectionPage(title: section.title),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 700;
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 112),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Row(
                          children: [
                            const _TwilightGlassOrb(
                              icon: Icons.person_rounded,
                              size: 42,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('السلام عليكم', style: TextStyle(color: ivory, fontSize: 19, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 2),
                                  Text('أهلاً بك في تطبيق الكامل', style: TextStyle(color: mutedIvory, fontSize: 11)),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () => _openSection(context, const _Section('البحث الشامل', Icons.search_rounded)),
                                child: _TwilightGlassPanel(
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                                  radius: 22,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('بحث', style: TextStyle(color: mutedIvory, fontSize: 12)),
                                      SizedBox(width: 9),
                                      Icon(Icons.search_rounded, color: ivory, size: 19),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 14 : 19),
                        _TwilightGlassPanel(
                          padding: const EdgeInsets.fromLTRB(17, 16, 17, 15),
                          radius: 25,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text('الصلاة والقبلة', style: TextStyle(color: ivory, fontSize: 21, fontWeight: FontWeight.bold)),
                                  ),
                                  const _TwilightGlassOrb(
                                    icon: Icons.access_time_rounded,
                                    size: 42,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text('تابع أوقات الصلاة حسب مدينتك، وانتقل بسهولة إلى اتجاه القبلة', style: TextStyle(color: mutedIvory, fontSize: 12, height: 1.6)),
                              const SizedBox(height: 13),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => _openSection(context, const _Section('مواقيت الصلاة', Icons.access_time_rounded)),
                                      icon: const Icon(Icons.arrow_back_rounded, size: 17),
                                      label: const Text('عرض المواقيت'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF8069D4),
                                        foregroundColor: ivory,
                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  _HomeRoundAction(
                                    icon: Icons.explore_rounded,
                                    label: 'اتجاه القبلة',
                                    onTap: () => _openSection(context, const _Section('القبلة', Icons.explore_rounded)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        _TwilightGlassPanel(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          radius: 23,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('وردك وقراءتك', style: TextStyle(color: ivory, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    const Text('المصحف الشريف والأذكار والمسبحة الإلكترونية', style: TextStyle(color: mutedIvory, fontSize: 11, height: 1.5)),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 7,
                                      children: [
                                        _HomePillAction(
                                          icon: Icons.menu_book_rounded,
                                          label: 'فتح المصحف',
                                          onTap: () => _openSection(context, const _Section('القرآن الكريم', Icons.menu_book_rounded)),
                                        ),
                                        _HomePillAction(
                                          icon: Icons.grain_rounded,
                                          label: 'الأذكار',
                                          onTap: () => _openSection(context, const _Section('المسبحة الإلكترونية', Icons.grain_rounded)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF45405A), Color(0xFF252943)],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFD8BE83).withValues(alpha: 0.72),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD8BE83).withValues(alpha: 0.13),
                                      blurRadius: 18,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.menu_book_rounded, color: Color(0xFFF1E7D0), size: 37),
                                    Positioned(
                                      top: 9,
                                      right: 12,
                                      child: Icon(Icons.nightlight_round, color: Color(0xFFD8BE83), size: 17),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 13,
                                      child: Icon(Icons.circle, color: Color(0xFFD8BE83), size: 5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 13 : 17),
                        Row(
                          children: [
                            const Text('أقسام الكامل', style: TextStyle(color: ivory, fontSize: 17, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text('${_sections.length} قسماً', style: const TextStyle(color: mutedIvory, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _TwilightGlassPanel(
                          padding: const EdgeInsets.all(10),
                          radius: 24,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _sections.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: constraints.maxWidth >= 560 ? 4 : 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 11,
                              childAspectRatio: compact ? 0.88 : 0.92,
                            ),
                            itemBuilder: (context, index) {
                              final section = _sections[index];
                              return _SectionTile(
                                section: section,
                                compact: true,
                                onTap: () => _openSection(context, section),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Center(
                          child: Text(
                            'الكامل • موسوعة الأدعية والزيارات وتعاليم أهل البيت (عليهم السلام)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFAAA5C8), fontSize: 10, height: 1.5),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(14, 0, 14, 9),
          child: _TwilightGlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
            radius: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HomeNavItem(icon: Icons.home_rounded, label: 'الرئيسية', selected: true, onTap: () {}),
                _HomeNavItem(icon: Icons.menu_book_rounded, label: 'القرآن', onTap: () => _openSection(context, const _Section('القرآن الكريم', Icons.menu_book_rounded))),
                _HomeNavItem(icon: Icons.explore_rounded, label: 'القبلة', onTap: () => _openSection(context, const _Section('القبلة', Icons.explore_rounded))),
                _HomeNavItem(icon: Icons.auto_stories_rounded, label: 'المكتبة', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LibraryHubScreen()))),
                _HomeNavItem(icon: Icons.settings_rounded, label: 'الإعدادات', onTap: () => _openSection(context, const _Section('الإعدادات', Icons.settings_rounded))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryHubScreen extends StatelessWidget {
  const LibraryHubScreen({super.key});

  static const List<_Section> _categories = [
    _Section('القرآن الكريم', Icons.menu_book_rounded),
    _Section('الزيارات', Icons.mosque_rounded),
    _Section('الأدعية العامة', Icons.volunteer_activism_rounded),
    _Section('أدعية الأيام', Icons.today_rounded),
    _Section('تعقيبات الصلوات', Icons.self_improvement_rounded),
    _Section('الصحيفة السجادية', Icons.article_rounded),
    _Section('وصايا أهل البيت', Icons.format_quote_rounded),
    _Section('تعليم صلاة الليل', Icons.nightlight_round),
  ];

  void _openCategory(BuildContext context, _Section section) {
    final Widget page = section.title == 'القرآن الكريم'
        ? const QuranScreen()
        : LibrarySectionScreen(title: section.title);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: _TwilightSubpageAppBar(title: 'المكتبة'),
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _TwilightGlassPanel(
                      padding: const EdgeInsets.all(16),
                      radius: 20,
                      child: Row(
                        children: [
                          const _TwilightGlassOrb(
                            icon: Icons.auto_stories_rounded,
                            size: 54,
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مكتبة الكامل',
                                  style: TextStyle(
                                    color: Color(0xFFF4F0E7),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'تصفّح القرآن والزيارات والأدعية',
                                  style: TextStyle(
                                    color: mutedIvory,
                                    fontSize: 11,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'البحث الشامل',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const GlobalSearchScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFFE8D5A8),
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _SectionTile(
                            section: const _Section(
                              'المفضلة',
                              Icons.bookmark_rounded,
                            ),
                            compact: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const LibrarySectionScreen(
                                  title: 'المفضلة',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SectionTile(
                            section: const _Section(
                              'آخر قراءة',
                              Icons.history_rounded,
                            ),
                            compact: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const LibrarySectionScreen(
                                  title: 'آخر قراءة',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'الأقسام',
                      style: TextStyle(
                        color: Color(0xFFF4F0E7),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 11),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = _categories[index];
                      return _SectionTile(
                        section: section,
                        compact: false,
                        onTap: () => _openCategory(context, section),
                      );
                    },
                    childCount: _categories.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwilightGlassOrb extends StatelessWidget {
  const _TwilightGlassOrb({required this.icon, this.size = 42});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF4E9D2).withValues(alpha: 0.25),
                  const Color(0xFFD8BE83).withValues(alpha: 0.22),
                  const Color(0xFF39364D).withValues(alpha: 0.88),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFD8BE83).withValues(alpha: 0.68),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD8BE83).withValues(alpha: 0.15),
                  blurRadius: 17,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFFF4E9D2), size: size * 0.60),
          ),
        ),
      );
}

class _HomeRoundAction extends StatelessWidget {
  const _HomeRoundAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: _TwilightGlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            radius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: const Color(0xFFE8D5A8), size: 26),
                const SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF4F0E7),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _HomePillAction extends StatelessWidget {
  const _HomePillAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: _TwilightGlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            radius: 18,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: const Color(0xFFE8D5A8), size: 18),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFF4F0E7),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _HomeNavItem extends StatelessWidget {
  const _HomeNavItem({required this.icon, required this.label, required this.onTap, this.selected = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          turquoise.withValues(alpha: 0.24),
                          const Color(0xFF8069D4).withValues(alpha: 0.13),
                        ],
                      )
                    : null,
                border: selected
                    ? Border.all(color: twilightBorder, width: 0.8)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: selected
                        ? const Color(0xFFF4E9D2)
                        : const Color(0xFFD8BE83),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFFF4F0E7)
                          : const Color(0xFFCFC8B8),
                      fontSize: 9.5,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Section {
  const _Section(this.title, this.icon);
  final String title;
  final IconData icon;
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.onTap,
    required this.compact,
  });

  final _Section section;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.white.withValues(alpha: 0.13),
                    turquoise.withValues(alpha: 0.075),
                    panelBlack.withValues(alpha: 0.72),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFD8BE83).withValues(alpha: 0.34),
                  width: 0.95,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD8BE83).withValues(alpha: 0.10),
                    blurRadius: 16,
                    spreadRadius: 0.4,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 51 : 55,
                    height: compact ? 51 : 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x35F1E7D0),
                          Color(0x1FD8BE83),
                          Color(0x222D3152),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFD8BE83).withValues(alpha: 0.58),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD8BE83).withValues(alpha: 0.10),
                          blurRadius: 12,
                          spreadRadius: 0.2,
                        ),
                      ],
                    ),
                    child: Icon(
                      section.icon,
                      size: compact ? 29 : 31,
                      color: const Color(0xFFE8D5A8),
                    ),
                  ),
                  SizedBox(height: compact ? 7 : 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Text(
                      section.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFF4F0E7),
                        fontSize: compact ? 10.5 : 11,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TwilightGlassPanel extends StatelessWidget {
  const _TwilightGlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(15),
    this.margin = EdgeInsets.zero,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white.withValues(alpha: 0.105),
                turquoise.withValues(alpha: 0.075),
                panelBlack.withValues(alpha: 0.76),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: twilightBorder, width: 0.85),
            boxShadow: [
              BoxShadow(
                color: turquoise.withValues(alpha: 0.07),
                blurRadius: 16,
                spreadRadius: 0.2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 1;
  int _lastReadPage = 1;
  bool _fontsReady = false;
  bool _fontError = false;

  @override
  void initState() {
    super.initState();
    _loadQuranFonts();
    _loadLastReadPage();
  }

  Future<void> _loadLastReadPage() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedPage = (preferences.getInt('quran_last_page') ?? 1).clamp(1, 604).toInt();
      if (mounted) setState(() => _lastReadPage = savedPage);
    } catch (_) {
      // The Mushaf remains available if local progress cannot be read.
    }
  }

  Future<void> _saveLastReadPage(int page) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('quran_last_page', page);
      if (mounted) setState(() => _lastReadPage = page);
    } catch (_) {
      // Reading continues even if progress cannot be saved.
    }
  }

  Future<void> _loadQuranFonts() async {
    try {
      await QcfFontLoader.setupFontsAtStartup(onProgress: (_) {});
      if (mounted) setState(() => _fontsReady = true);
    } catch (_) {
      if (mounted) setState(() => _fontError = true);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final target = page.clamp(1, 604);
    _pageController.jumpToPage(target - 1);
    setState(() => _currentPage = target);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EBDD),
        appBar: _TwilightSubpageAppBar(title: 'القرآن الكريم'),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: _TwilightGlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                radius: 18,
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, color: gold, size: 21),
                    const SizedBox(width: 9),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('آخر قراءة', style: TextStyle(color: ivory, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('صفحة $_lastReadPage من 604', style: const TextStyle(color: mutedIvory, fontSize: 11)),
                    ])),
                    TextButton.icon(onPressed: () => _goToPage(_lastReadPage), icon: const Icon(Icons.play_arrow_rounded, size: 18), label: const Text('متابعة')),
                    IconButton(tooltip: 'فهرس السور', onPressed: _showSurahIndex, icon: const Icon(Icons.list_alt_rounded, color: turquoise)),
                  ],
                ),
              ),
            ),
            _TwilightGlassPanel(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              radius: 16,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'الصفحة السابقة',
                    onPressed: _currentPage > 1
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                    icon: const Icon(Icons.chevron_right, color: gold),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'الصفحة $_currentPage من 604',
                        style: const TextStyle(color: ivory, fontSize: 13),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'الصفحة التالية',
                    onPressed: _currentPage < 604
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                    icon: const Icon(Icons.chevron_left, color: gold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _fontsReady
                  ? QuranPageView(
                      pageController: _pageController,
                      highlights: const <HighlightVerse>[],
                      isDarkMode: false,
                      isTajweed: true,
                      enableTwoPageLayout: false,
                      pageBackgroundColor: const Color(0xFFFFFCF4),
                      onPageChanged: (page) {
                        final current = page + 1;
                        setState(() => _currentPage = current);
                        _saveLastReadPage(current);
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: gold),
                            const SizedBox(height: 14),
                            Text(
                              _fontError
                                  ? 'تعذّر تهيئة خط المصحف. أعد فتح التطبيق.'
                                  : 'تهيئة صفحات المصحف والخطوط...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: royalBlack,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            _TwilightGlassPanel(
              margin: const EdgeInsets.fromLTRB(10, 3, 10, 8),
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
              radius: 16,
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: gold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مصحف حفص • أحكام التجويد الملوّنة',
                      style: TextStyle(
                        color: ivory.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showPagePicker(context),
                    child: const Text(
                      'انتقال',
                      style: TextStyle(color: turquoise),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSurahIndex() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: _TwilightGlassPanel(
          margin: const EdgeInsets.only(top: 8),
          padding: EdgeInsets.zero,
          radius: 26,
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.78,
            child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 12), child: Row(children: [
              const Icon(Icons.menu_book_rounded, color: gold),
              const SizedBox(width: 9),
              const Expanded(child: Text('فهرس سور القرآن الكريم', style: TextStyle(color: ivory, fontSize: 17, fontWeight: FontWeight.bold))),
              IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close_rounded, color: mutedIvory)),
            ])),
            Expanded(child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 22),
              itemCount: 114,
              separatorBuilder: (_, __) => const SizedBox(height: 7),
              itemBuilder: (context, index) {
                final number = index + 1;
                final name = getSurahNameArabic(number);
                final verses = getVerseCount(number);
                final page = getPageNumber(number, 1).clamp(1, 604).toInt();
                return _TwilightGlassPanel(padding: EdgeInsets.zero, radius: 14, child: ListTile(
                  onTap: () { Navigator.pop(sheetContext); _goToPage(page); },
                  leading: Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: turquoise.withValues(alpha: 0.16), border: Border.all(color: twilightBorder)), child: Text('$number', style: const TextStyle(color: ivory, fontWeight: FontWeight.bold))),
                  title: Text(name, style: const TextStyle(color: ivory, fontWeight: FontWeight.bold)),
                  subtitle: Text('$verses آية • صفحة $page', style: const TextStyle(color: mutedIvory, fontSize: 11)),
                  trailing: const Icon(Icons.chevron_left_rounded, color: turquoise),
                ));
              },
            )),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _showPagePicker(BuildContext context) async {
    final controller = TextEditingController(text: '$_currentPage');
    final page = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panelBlack,
        title: const Text(
          'الانتقال إلى صفحة',
          style: TextStyle(color: ivory),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: ivory),
          decoration: const InputDecoration(
            hintText: 'من 1 إلى 604',
            hintStyle: TextStyle(color: mutedIvory),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value != null && value >= 1 && value <= 604) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (page != null) _goToPage(page);
  }
}

class _DhikrOption {
  const _DhikrOption({
    required this.id,
    required this.title,
    required this.target,
    required this.description,
  });

  final String id;
  final String title;
  final int target;
  final String description;
}

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  static const List<_DhikrOption> _options = [
    _DhikrOption(
      id: 'takbir',
      title: 'الله أكبر',
      target: 34,
      description: 'من تسبيح الزهراء (عليها السلام)',
    ),
    _DhikrOption(
      id: 'hamd',
      title: 'الحمد لله',
      target: 33,
      description: 'من تسبيح الزهراء (عليها السلام)',
    ),
    _DhikrOption(
      id: 'tasbih',
      title: 'سبحان الله',
      target: 33,
      description: 'من تسبيح الزهراء (عليها السلام)',
    ),
    _DhikrOption(
      id: 'salawat',
      title: 'اللهم صلّ على محمد وآل محمد',
      target: 100,
      description: 'الصلاة على محمد وآل محمد',
    ),
    _DhikrOption(
      id: 'istighfar',
      title: 'أستغفر الله ربي وأتوب إليه',
      target: 100,
      description: 'الاستغفار',
    ),
  ];

  final Map<String, int> _counts = {};
  String _selectedId = 'takbir';
  bool _loading = true;

  _DhikrOption get _selected =>
      _options.firstWhere((option) => option.id == _selectedId);

  int get _count => _counts[_selectedId] ?? 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedSelection = preferences.getString('tasbeeh_selected');
      for (final option in _options) {
        _counts[option.id] =
            preferences.getInt('tasbeeh_count_${option.id}') ?? 0;
      }
      if (mounted) {
        setState(() {
          if (_options.any((option) => option.id == savedSelection)) {
            _selectedId = savedSelection!;
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveCount(String id, int count) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('tasbeeh_count_$id', count);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر حفظ العدد على الجهاز')),
        );
      }
    }
  }

  void _increment() {
    final next = _count + 1;
    setState(() => _counts[_selectedId] = next);
    _saveCount(_selectedId, next);
  }

  void _decrement() {
    if (_count == 0) return;
    final next = _count - 1;
    setState(() => _counts[_selectedId] = next);
    _saveCount(_selectedId, next);
  }

  Future<void> _resetCount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panelBlack,
        title: const Text('تصفير العداد', style: TextStyle(color: ivory)),
        content: const Text(
          'هل تريد تصفير عداد هذا الذكر فقط؟',
          style: TextStyle(color: mutedIvory),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _counts[_selectedId] = 0);
    await _saveCount(_selectedId, 0);
  }

  void _selectDhikr(String? id) {
    if (id == null) return;
    setState(() => _selectedId = id);
    SharedPreferences.getInstance().then(
      (preferences) => preferences.setString('tasbeeh_selected', id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_count % _selected.target) / _selected.target;
    final completed = _count > 0 && _count % _selected.target == 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: _TwilightSubpageAppBar(title: 'المسبحة الإلكترونية'),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    children: [
                      _TwilightGlassPanel(
                        padding: const EdgeInsets.all(16),
                        radius: 18,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: gold,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'وَاذْكُرُوا اللَّهَ كَثِيرًا',
                              style: TextStyle(
                                color: gold,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'عداد مستقل لكل ذكر، مع حفظ تلقائي على جهازك',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: mutedIvory,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'اختر الذكر',
                          style: TextStyle(
                            color: ivory,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _TwilightGlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        radius: 17,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedId,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF211D3D),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: turquoise),
                            style: const TextStyle(color: ivory, fontSize: 15),
                            items: _options.map((option) => DropdownMenuItem<String>(
                              value: option.id,
                              child: Text(option.title, overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: _selectDhikr,
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      _TwilightGlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        radius: 14,
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: gold, size: 17),
                            const SizedBox(width: 9),
                            Expanded(child: Text(_selected.description, style: const TextStyle(color: mutedIvory, fontSize: 12))),
                            Text('الهدف: ${_selected.target}', style: const TextStyle(color: turquoise, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _options.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 2.25),
                        itemBuilder: (context, index) {
                          final option = _options[index];
                          final selected = option.id == _selectedId;
                          final count = _counts[option.id] ?? 0;
                          return Material(color: Colors.transparent, child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => _selectDhikr(option.id),
                            child: _TwilightGlassPanel(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), radius: 15, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [Expanded(child: Text(option.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? gold : ivory, fontSize: 11, fontWeight: FontWeight.bold))), if (selected) const Icon(Icons.check_circle_rounded, color: turquoise, size: 15)]),
                              const SizedBox(height: 5),
                              Text('$count / ${option.target}', style: const TextStyle(color: mutedIvory, fontSize: 10)),
                            ])),
                          ));
                        },
                      ),
                      const SizedBox(height: 24),
                      _TwilightGlassPanel(
                        padding: const EdgeInsets.all(10),
                        radius: 140,
                        child: Container(
                          width: 236,
                          height: 236,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF9B8BEA).withValues(alpha: 0.20),
                                const Color(0xFF342D59).withValues(alpha: 0.78),
                                panelBlack.withValues(alpha: 0.92),
                              ],
                            ),
                            border: Border.all(color: turquoise.withValues(alpha: 0.72), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9B8BEA).withValues(alpha: 0.16),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 210,
                              height: 210,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                backgroundColor: mutedIvory.withValues(
                                  alpha: 0.12,
                                ),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  turquoise,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'العدد',
                                  style: TextStyle(
                                    color: mutedIvory,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '$_count',
                                  key: const ValueKey('tasbeeh-count'),
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'الهدف: ${_selected.target}',
                                  style: const TextStyle(
                                    color: mutedIvory,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (completed)
                        const Text(
                          'أحسنت، أتممت العدد المحدد',
                          style: TextStyle(
                            color: turquoise,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          'استمر بالذكر، تقبّل الله أعمالكم',
                          style: TextStyle(color: mutedIvory, fontSize: 12),
                        ),
                      const SizedBox(height: 18),
                      _TwilightGlassPanel(
                        padding: const EdgeInsets.all(14),
                        radius: 20,
                        child: Column(
                          children: [
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton.icon(
                          onPressed: _increment,
                          style: FilledButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: royalBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.touch_app_rounded, size: 22),
                          label: const Text(
                            'سبّح',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _count > 0 ? _decrement : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: turquoise,
                                side: const BorderSide(color: turquoise),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                              ),
                              icon: const Icon(Icons.undo_rounded),
                              label: const Text('تراجع عن ضغطة'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _count > 0 ? _resetCount : null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: gold,
                                side: BorderSide(
                                  color: gold.withValues(alpha: 0.7),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                              ),
                              icon: const Icon(Icons.restart_alt_rounded),
                              label: const Text('تصفير'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'كل ذكر له عدّاده الخاص، ولا يؤثر تغيير الذكر في الأعداد المحفوظة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: mutedIvory,
                          fontSize: 11,
                          height: 1.7,
                        ),
                      ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _LibraryItem {
  const _LibraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
  });

  final String id;
  final String title;
  final String description;
  final String source;
}

const Map<String, List<_LibraryItem>> _libraryItems = {
  'الزيارات': [
    _LibraryItem(id: 'visit_ashura', title: 'زيارة عاشوراء', description: 'زيارة الإمام الحسين (عليه السلام)', source: 'مفاتيح الجنان، الشيخ عباس القمي، الزيارة الأولى: زيارة عاشوراء المشهورة، ص 665–669. تختلف بعض الألفاظ بين الطبعات والنسخ.',),
    _LibraryItem(id: 'visit_warith', title: 'زيارة وارث', description: 'زيارة الإمام الحسين (عليه السلام)', source: 'مفاتيح الجنان، الشيخ عباس القمي، الزيارة السابعة: زيارة وارث، ص 630–632؛ وينقل المؤلف أصلها عن مصباح المتهجد للشيخ الطوسي.'),
    _LibraryItem(id: 'visit_amin', title: 'زيارة أمين الله', description: 'زيارة جامعة', source: 'مفاتيح الجنان، الشيخ عباس القمي، الزيارة الثانية المعروفة بأمين الله، ص 526–527.'),
    _LibraryItem(id: 'visit_jamia', title: 'الزيارة الجامعة الكبيرة', description: 'زيارة جامعة للأئمة (عليهم السلام)', source: 'وردت في كتاب من لا يحضره الفقيه للشيخ الصدوق، ج 2، وفي تهذيب الأحكام للشيخ الطوسي، ج 6. النص قيد المطابقة الحرفية مع نسخة معتمدة قبل إتاحته.'),
  ],
  'الأدعية العامة': [
    _LibraryItem(id: 'dua_kumayl', title: 'دعاء كميل', description: 'من الأدعية المشهورة في ليالي الجمعة', source: 'مفتاح الجنان؛ يلزم تثبيت بيانات الطبعة والموضع'),
    _LibraryItem(id: 'dua_tawassul', title: 'دعاء التوسل', description: 'التوسل إلى الله تعالى', source: 'مفاتيح الجنان، الشيخ عباس القمي، الباب الأول، الفصل السابع، الثاني: التوسل، ص 194؛ وينقل المؤلف روايته عن العلامة المجلسي.'),
    _LibraryItem(id: 'dua_ahd', title: 'دعاء العهد', description: 'دعاء العهد', source: 'مفاتيح الجنان، الشيخ عباس القمي، الباب الخاص بزيارة صاحب الزمان، الثالث: دعاء العهد، ص 775–776؛ توجد فروق لفظية يسيرة بين النسخ.'),
    _LibraryItem(id: 'dua_iftitah', title: 'دعاء الافتتاح', description: 'من أدعية شهر رمضان', source: 'مفاتيح الجنان، الشيخ عباس القمي، أعمال شهر رمضان العامة، الدعاء الحادي عشر: دعاء الافتتاح، ص 290.'),
    _LibraryItem(id: 'dua_nudba', title: 'دعاء الندبة', description: 'يُستحب الدعاء به في الأعياد الأربعة وفق نقل مفاتيح الجنان', source: 'مفاتيح الجنان، الشيخ عباس القمي، ضمن أعمال سرداب الغيبة، ص 637–640 في النسخة المصورة على مكتبة رافد. النص الكامل قيد المطابقة صفحةً صفحة قبل إتاحته.'),
    _LibraryItem(id: 'dua_abu_hamza', title: 'دعاء أبي حمزة الثمالي', description: 'من أدعية أسحار شهر رمضان', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'dua_jawshan', title: 'دعاء الجوشن الكبير', description: 'دعاء الجوشن الكبير', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'dua_mashlul', title: 'دعاء المشلول', description: 'دعاء المشلول', source: 'المصدر والتخريج قيد المراجعة'),
  ],
  'أدعية الأيام': [
    _LibraryItem(id: 'day_saturday', title: 'دعاء يوم السبت', description: 'الأعمال والأدعية الخاصة بيوم السبت', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'day_sunday', title: 'دعاء يوم الأحد', description: 'الأعمال والأدعية الخاصة بيوم الأحد', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'day_monday', title: 'دعاء يوم الاثنين', description: 'الأعمال والأدعية الخاصة بيوم الاثنين', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'day_tuesday', title: 'دعاء يوم الثلاثاء', description: 'الأعمال والأدعية الخاصة بيوم الثلاثاء', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'day_wednesday', title: 'دعاء يوم الأربعاء', description: 'الأعمال والأدعية الخاصة بيوم الأربعاء', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'day_thursday', title: 'دعاء يوم الخميس', description: 'الأعمال والأدعية الخاصة بيوم الخميس', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'day_friday', title: 'دعاء يوم الجمعة', description: 'الأعمال والأدعية الخاصة بيوم الجمعة', source: 'المصدر والتخريج قيد المراجعة'),
  ],
  'تعقيبات الصلوات': [
    _LibraryItem(id: 'taqib_fajr', title: 'تعقيبات صلاة الفجر', description: 'التعقيب المشترك بعد الفريضة، مع فضيلة الجلوس للذكر إلى طلوع الشمس', source: 'المصدر الفقهي: السيد علي الحسيني السيستاني، التعليقة على العروة الوثقى، ج 2، فصل في التعقيب، المسائل 1692–1694. الأذكار المذكورة مستحبات وليست واجبات. https://www.sistani.org/arabic/book/23/1900/'),
    _LibraryItem(id: 'taqib_dhuhr', title: 'تعقيبات صلاة الظهر', description: 'الأذكار والأدعية المأثورة بعد فريضة الظهر', source: 'المصدر الفقهي: السيد علي الحسيني السيستاني، التعليقة على العروة الوثقى، ج 2، فصل في التعقيب، المسائل 1690–1694. https://www.sistani.org/arabic/book/23/1900/'),
    _LibraryItem(id: 'taqib_asr', title: 'تعقيبات صلاة العصر', description: 'الأذكار والأدعية المأثورة بعد فريضة العصر', source: 'المصدر الفقهي: السيد علي الحسيني السيستاني، التعليقة على العروة الوثقى، ج 2، فصل في التعقيب، المسائل 1690–1694. https://www.sistani.org/arabic/book/23/1900/'),
    _LibraryItem(id: 'taqib_maghrib', title: 'تعقيبات صلاة المغرب', description: 'الأذكار والأدعية المأثورة بعد فريضة المغرب', source: 'المصدر الفقهي: السيد علي الحسيني السيستاني، التعليقة على العروة الوثقى، ج 2، فصل في التعقيب، المسائل 1690–1694. https://www.sistani.org/arabic/book/23/1900/'),
    _LibraryItem(id: 'taqib_isha', title: 'تعقيبات صلاة العشاء', description: 'الأذكار والأدعية المأثورة بعد فريضة العشاء', source: 'المصدر الفقهي: السيد علي الحسيني السيستاني، التعليقة على العروة الوثقى، ج 2، فصل في التعقيب، المسائل 1690–1694. https://www.sistani.org/arabic/book/23/1900/'),
  ],
  'الصحيفة السجادية': [
    _LibraryItem(id: 'sahifa_intro', title: 'فهرس أدعية الصحيفة', description: 'فهرس موضوعي للصحيفة السجادية', source: 'الصحيفة السجادية؛ تُضاف أرقام الأدعية بعد المطابقة'),
  ],
  'نهج البلاغة': [
    _LibraryItem(id: 'nahj_sermons', title: 'الخطب', description: 'فهرس خطب نهج البلاغة', source: 'نهج البلاغة؛ تُضاف أرقام الخطب بعد المطابقة'),
    _LibraryItem(id: 'nahj_letters', title: 'الكتب والرسائل', description: 'فهرس كتب ورسائل أمير المؤمنين (عليه السلام)', source: 'نهج البلاغة؛ تُضاف أرقام الكتب بعد المطابقة'),
    _LibraryItem(id: 'nahj_wisdom', title: 'الحِكَم', description: 'فهرس الحكم والكلمات القصار', source: 'نهج البلاغة؛ تُضاف الأرقام بعد المطابقة'),
  ],
  'وصايا أهل البيت': [
    _LibraryItem(id: 'wasaya_worship', title: 'العبادة والتقوى', description: 'نصوص في العبادة ومراقبة الله', source: 'تُذكر المصادر والأسانيد وحالة النسبة لكل نص على حدة'),
    _LibraryItem(id: 'wasaya_akhlaq', title: 'الأخلاق وحسن المعاملة', description: 'نصوص في الأخلاق والحقوق', source: 'تُذكر المصادر والأسانيد وحالة النسبة لكل نص على حدة'),
    _LibraryItem(id: 'wasaya_knowledge', title: 'العلم وطلب المعرفة', description: 'نصوص في العلم والتعلّم', source: 'تُذكر المصادر والأسانيد وحالة النسبة لكل نص على حدة'),
  ],
  'تعليم صلاة الليل': [
    _LibraryItem(id: 'night_overview', title: 'التعريف بصلاة الليل', description: 'مدخل إلى صلاة الليل وأهميتها', source: 'تُراجع الأحكام وفق فتاوى المرجع الذي يختاره المستخدم'),
    _LibraryItem(id: 'night_steps', title: 'ترتيب الصلاة', description: 'عرض تعليمي مرتب للركعات والأعمال', source: 'تُراجع الأحكام وفق فتاوى المرجع الذي يختاره المستخدم'),
    _LibraryItem(id: 'night_qunut', title: 'القنوت والأدعية', description: 'مواضع القنوت والأدعية', source: 'تُراجع الأحكام وفق فتاوى المرجع الذي يختاره المستخدم'),
  ],
  'الصوتيات': [
    _LibraryItem(id: 'audio_library', title: 'مكتبة التلاوات والأدعية', description: 'إدارة الملفات الصوتية المحفوظة على الجهاز', source: 'لا توجد تسجيلات مرفقة في هذه النسخة بعد'),
  ],
};


const String _commonTaqibatText = '''
تنبيه فقهي
هذا عرض للتعقيبات المستحبة وفق النص المنشور في موقع مكتب السيد السيستاني. الأذكار الآتية ليست واجبة ولا تتوقف صحة الصلاة عليها، ولا يلزم الإتيان بها كلها. يمكن اختيار ما يتيسر.

١ ـ التكبير بعد التسليم
يُستحب التكبير ثلاث مرات بعد التسليم، مع رفع اليدين.

٢ ـ تسبيح الزهراء (عليها السلام)
اللهُ أَكْبَرُ — ٣٤ مرة
الْحَمْدُ لِلَّهِ — ٣٣ مرة
سُبْحَانَ اللَّهِ — ٣٣ مرة
المجموع: ١٠٠ ذكر. والترتيب المذكور هو الأولى.

٣ ـ ذكر التوحيد
لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ وَحْدَهُ، أَنْجَزَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَأَعَزَّ جُنْدَهُ، وَغَلَبَ الْأَحْزَابَ وَحْدَهُ، فَلَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ، وَهُوَ حَيٌّ لَا يَمُوتُ، بِيَدِهِ الْخَيْرُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.

٤ ـ دعاء الهداية والبركة
اللَّهُمَّ اهْدِنِي مِنْ عِنْدِكَ، وَأَفِضْ عَلَيَّ مِنْ فَضْلِكَ، وَانْشُرْ عَلَيَّ مِنْ رَحْمَتِكَ، وَأَنْزِلْ عَلَيَّ مِنْ بَرَكَاتِكَ.

٥ ـ الذكر الجامع
سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ.
ورد في المصدر استحباب الإتيان به مائة مرة أو أربعين أو ثلاثين مرة.

٦ ـ دعاء الاستعاذة والرجاء
اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ، وَأَجِرْنِي مِنَ النَّارِ، وَارْزُقْنِي الْجَنَّةَ، وَزَوِّجْنِي مِنَ الْحُورِ الْعِينِ.

٧ ـ دعاء العافية
اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ كُلِّ خَيْرٍ أَحَاطَ بِهِ عِلْمُكَ، وَأَعُوذُ بِكَ مِنْ كُلِّ شَرٍّ أَحَاطَ بِهِ عِلْمُكَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ عَافِيَتَكَ فِي أُمُورِي كُلِّهَا، وَأَعُوذُ بِكَ مِنْ خِزْيِ الدُّنْيَا وَعَذَابِ الْآخِرَةِ.

٨ ـ قراءة قرآنية
يذكر المصدر قراءة سورة الحمد، وآية الكرسي، وآية (شَهِدَ اللَّهُ أَنَّهُ لَا إِلَٰهَ إِلَّا هُوَ...) من سورة آل عمران (١٨)، وآية (قُلِ اللَّهُمَّ مَالِكَ الْمُلْكِ...) من سورة آل عمران (٢٦).

٩ ـ الاستغفار
قبل أن يغيّر المصلي جلسته، يُستحب أن يقول ثلاث مرات:
أَسْتَغْفِرُ اللَّهَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ذُو الْجَلَالِ وَالْإِكْرَامِ، وَأَتُوبُ إِلَيْهِ.

١٠ ـ الشهادتان والإقرار بالأئمة
يذكر المصدر استحباب الشهادتين والإقرار بالأئمة (عليهم السلام) ضمن التعقيب.

١١ ـ سجود الشكر
يُستحب سجود الشكر بعد كل صلاة، فريضة كانت أو نافلة.

ملاحظة علمية
هذه مجموعة منتقاة من التعقيبات المذكورة في فصل فقهي. نقلها في الكتاب لا يعني أننا حققنا أسانيد كل رواية على حدة. لم نضف نصوصاً منسوبة بلا مصدر، ولم ننسب هذه المجموعة العامة إلى صلاة بعينها.
''';

const Map<String, String> _verifiedPrayerTexts = {
  'taqib_fajr': '''$_commonTaqibatText

خصوصية تعقيب صلاة الفجر
يُستحب الجلوس في مصلّى صلاة الصبح إلى طلوع الشمس مع الاشتغال بذكر الله تعالى. هذا عمل مستحب، وليس شرطاً لصحة الصلاة، ولا يلزم من تعذّر عليه الجلوس.
''',
  'taqib_dhuhr': _commonTaqibatText,
  'taqib_asr': _commonTaqibatText,
  'taqib_maghrib': _commonTaqibatText,
  'taqib_isha': _commonTaqibatText,
  'visit_ashura': '''
السَّلامُ عَلَيْكَ يا أَبا عَبْدِ اللهِ، السَّلامُ عَلَيْكَ يا ابْنَ رَسُولِ اللهِ، السَّلامُ عَلَيْكَ يا ابْنَ أَمِيرِ المُؤْمِنِينَ وَابْنَ سَيِّدِ الوَصِيِّينَ، السَّلامُ عَلَيْكَ يا ابْنَ فاطِمَةَ سَيِّدَةِ نِساءِ العالَمِينَ، السَّلامُ عَلَيْكَ يا ثارَ اللهِ وَابْنَ ثارِهِ وَالوِتْرَ المَوْتُورَ، السَّلامُ عَلَيْكَ وَعَلَى الأَرْواحِ الَّتِي حَلَّتْ بِفِنائِكَ، عَلَيْكُمْ مِنِّي جَميعاً سَلامُ اللهِ أَبَداً ما بَقِيتُ وَبَقِيَ اللَّيْلُ وَالنَّهارُ.

يا أَبا عَبْدِ اللهِ، لَقَدْ عَظُمَتِ الرَّزِيَّةُ وَجَلَّتْ، وَعَظُمَتِ المُصِيبَةُ بِكَ عَلَيْنا وَعَلى جَميعِ أَهْلِ الإِسْلامِ، وَجَلَّتْ وَعَظُمَتْ مُصِيبَتُكَ فِي السَّماواتِ عَلى جَميعِ أَهْلِ السَّماواتِ. فَلَعَنَ اللهُ أُمَّةً أَسَّسَتْ أَساسَ الظُّلْمِ وَالجَوْرِ عَلَيْكُمْ أَهْلَ البَيْتِ، وَلَعَنَ اللهُ أُمَّةً دَفَعَتْكُمْ عَنْ مَقامِكُمْ وَأَزالَتْكُمْ عَنْ مَراتِبِكُمُ الَّتِي رَتَّبَكُمُ اللهُ فِيها، وَلَعَنَ اللهُ أُمَّةً قَتَلَتْكُمْ، وَلَعَنَ اللهُ المُمَهِّدِينَ لَهُمْ بِالتَّمْكِينِ مِنْ قِتالِكُمْ. بَرِئْتُ إِلَى اللهِ وَإِلَيْكُمْ مِنْهُمْ وَمِنْ أَشْياعِهِمْ وَأَتْباعِهِمْ وَأَوْلِيائِهِمْ.

يا أَبا عَبْدِ اللهِ، إِنِّي سِلْمٌ لِمَنْ سالَمَكُمْ وَحَرْبٌ لِمَنْ حارَبَكُمْ إِلى يَوْمِ القِيامَةِ، وَلَعَنَ اللهُ آلَ زِيادٍ وَآلَ مَرْوانَ، وَلَعَنَ اللهُ بَنِي أُمَيَّةَ قاطِبَةً، وَلَعَنَ اللهُ ابْنَ مَرْجانَةَ، وَلَعَنَ اللهُ عُمَرَ بْنَ سَعْدٍ، وَلَعَنَ اللهُ شِمْراً، وَلَعَنَ اللهُ أُمَّةً أَسْرَجَتْ وَأَلْجَمَتْ وَتَنَقَّبَتْ لِقِتالِكَ. بِأَبِي أَنْتَ وَأُمِّي، لَقَدْ عَظُمَ مُصابِي بِكَ، فَأَسْأَلُ اللهَ الَّذِي أَكْرَمَ مَقامَكَ وَأَكْرَمَنِي بِكَ أَنْ يَرْزُقَنِي طَلَبَ ثارِكَ مَعَ إِمامٍ مَنْصُورٍ مِنْ أَهْلِ بَيْتِ مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَآلِهِ.

اللّهُمَّ اجْعَلْنِي عِنْدَكَ وَجِيهاً بِالحُسَيْنِ عَلَيْهِ السَّلامُ فِي الدُّنْيا وَالآخِرَةِ. يا أَبا عَبْدِ اللهِ، إِنِّي أَتَقَرَّبُ إِلَى اللهِ وَإِلَى رَسُولِهِ وَإِلَى أَمِيرِ المُؤْمِنِينَ وَإِلَى فاطِمَةَ وَإِلَى الحَسَنِ وَإِلَيْكَ بِمُوالاتِكَ، وَبِالبَراءَةِ مِمَّنْ قاتَلَكَ وَنَصَبَ لَكَ الحَرْبَ، وَبِالبَراءَةِ مِمَّنْ أَسَّسَ أَساسَ الظُّلْمِ وَالجَوْرِ عَلَيْكُمْ، وَأَبْرَأُ إِلَى اللهِ وَإِلَى رَسُولِهِ مِمَّنْ أَسَّسَ أَساسَ ذلِكَ وَبَنى عَلَيْهِ بُنْيانَهُ وَجَرى فِي ظُلْمِهِ وَجَوْرِهِ عَلَيْكُمْ وَعَلى أَشْياعِكُمْ وَأَتْباعِكُمْ.

إِنِّي سِلْمٌ لِمَنْ سالَمَكُمْ وَحَرْبٌ لِمَنْ حارَبَكُمْ، وَوَلِيٌّ لِمَنْ والاكُمْ وَعَدُوٌّ لِمَنْ عاداكُمْ. فَأَسْأَلُ اللهَ الَّذِي أَكْرَمَنِي بِمَعْرِفَتِكُمْ وَمَعْرِفَةِ أَوْلِيائِكُمْ وَرَزَقَنِي البَراءَةَ مِنْ أَعْدائِكُمْ أَنْ يَجْعَلَنِي مَعَكُمْ فِي الدُّنْيا وَالآخِرَةِ، وَأَنْ يُثَبِّتَ لِي عِنْدَكُمْ قَدَمَ صِدْقٍ فِي الدُّنْيا وَالآخِرَةِ، وَأَسْأَلُهُ أَنْ يُبَلِّغَنِي المَقامَ المَحْمُودَ لَكُمْ عِنْدَ اللهِ، وَأَنْ يَرْزُقَنِي طَلَبَ ثارِي مَعَ إِمامِ هُدىً ناطِقٍ بِالحَقِّ مِنْكُمْ.

اللّهُمَّ إِنِّي أَسْأَلُكَ بِحَقِّكُمْ وَبِالشَّأْنِ الَّذِي لَكُمْ عِنْدَكَ أَنْ تُعْطِيَنِي بِمُصابِي بِكُمْ أَفْضَلَ ما تُعْطِي مُصاباً بِمُصِيبَتِهِ. اللّهُمَّ اجْعَلْنِي فِي مَقامِي هذا مِمَّنْ تَنالُهُ مِنْكَ صَلَواتٌ وَرَحْمَةٌ وَمَغْفِرَةٌ. اللّهُمَّ اجْعَلْ مَحْيايَ مَحْيا مُحَمَّدٍ وَآلِ مُحَمَّدٍ، وَمَماتِي مَماتَ مُحَمَّدٍ وَآلِ مُحَمَّدٍ.

اللّهُمَّ إِنَّ هذا يَوْمٌ تَبَرَّكَتْ بِهِ بَنُو أُمَيَّةَ وَابْنُ آكِلَةِ الأَكْبادِ اللَّعِينُ ابْنُ اللَّعِينِ عَلى لِسانِكَ وَلِسانِ نَبِيِّكَ صَلَّى اللهُ عَلَيْهِ وَآلِهِ. اللّهُمَّ الْعَنْ أَبا سُفْيانَ وَمُعاوِيَةَ وَيَزِيدَ بْنَ مُعاوِيَةَ، وَضاعِفْ عَلَيْهِمُ اللَّعْنَ وَالعَذابَ الأَلِيمَ.

اللّهُمَّ إِنِّي أَتَقَرَّبُ إِلَيْكَ فِي هذا اليَوْمِ وَفِي مَوْقِفِي هذا وَأَيّامِ حَياتِي بِالبَراءَةِ مِنْهُمْ وَاللَّعْنَةِ عَلَيْهِمْ، وَبِالمُوالاةِ لِنَبِيِّكَ وَآلِ نَبِيِّكَ عَلَيْهِ وَعَلَيْهِمُ السَّلامُ.

اللّهُمَّ الْعَنْ أَوَّلَ ظالِمٍ ظَلَمَ حَقَّ مُحَمَّدٍ وَآلِ مُحَمَّدٍ، وَآخِرَ تابِعٍ لَهُ عَلى ذلِكَ. اللّهُمَّ الْعَنْ العِصابَةَ الَّتِي جاهَدَتِ الحُسَيْنَ وَشايَعَتْ وَبايَعَتْ وَتابَعَتْ عَلى قَتْلِهِ، اللّهُمَّ الْعَنْهُمْ جَميعاً. (يُكَرَّرُ هذا المقطع مائة مرة).

السَّلامُ عَلَيْكَ يا أَبا عَبْدِ اللهِ وَعَلَى الأَرْواحِ الَّتِي حَلَّتْ بِفِنائِكَ، عَلَيْكَ مِنِّي سَلامُ اللهِ أَبَداً ما بَقِيتُ وَبَقِيَ اللَّيْلُ وَالنَّهارُ، وَلا جَعَلَهُ اللهُ آخِرَ العَهْدِ مِنِّي لِزِيارَتِكُمْ. السَّلامُ عَلَى الحُسَيْنِ، وَعَلى عَلِيِّ بْنِ الحُسَيْنِ، وَعَلى أَوْلادِ الحُسَيْنِ، وَعَلى أَصْحابِ الحُسَيْنِ. (يُكَرَّرُ هذا المقطع مائة مرة).

اللّهُمَّ خُصَّ أَنْتَ أَوَّلَ ظالِمٍ بِاللَّعْنِ مِنِّي، وَابْدَأْ بِهِ أَوَّلاً، ثُمَّ الثّانِيَ وَالثّالِثَ وَالرّابِعَ. اللّهُمَّ الْعَنْ يَزِيدَ خامِساً، وَالْعَنْ عُبَيْدَ اللهِ بْنَ زِيادٍ وَابْنَ مَرْجانَةَ وَعُمَرَ بْنَ سَعْدٍ وَشِمْراً وَآلَ أَبي سُفْيانَ وَآلَ زِيادٍ وَآلَ مَرْوانَ إِلى يَوْمِ القِيامَةِ.

ثُمَّ تَسْجُدُ وَتَقُولُ: اللّهُمَّ لَكَ الحَمْدُ حَمْدَ الشّاكِرِينَ لَكَ عَلى مُصابِهِمْ، الحَمْدُ للهِ عَلى عَظِيمِ رَزِيَّتِي، اللّهُمَّ ارْزُقْنِي شَفاعَةَ الحُسَيْنِ يَوْمَ الوُرُودِ، وَثَبِّتْ لِي قَدَمَ صِدْقٍ عِنْدَكَ مَعَ الحُسَيْنِ وَأَصْحابِ الحُسَيْنِ الَّذِينَ بَذَلُوا مُهَجَهُمْ دُونَ الحُسَيْنِ عَلَيْهِ السَّلامُ.
''',
  'visit_warith': '''
السَّلامُ عَلَيْكَ يا وارِثَ آدَمَ صَفْوَةِ اللهِ، السَّلامُ عَلَيْكَ يا وارِثَ نُوحٍ نَبِيِّ اللهِ، السَّلامُ عَلَيْكَ يا وارِثَ إِبْراهِيمَ خَلِيلِ اللهِ، السَّلامُ عَلَيْكَ يا وارِثَ مُوسى كَلِيمِ اللهِ، السَّلامُ عَلَيْكَ يا وارِثَ عِيسى رُوحِ اللهِ، السَّلامُ عَلَيْكَ يا وارِثَ مُحَمَّدٍ حَبِيبِ اللهِ، السَّلامُ عَلَيْكَ يا وارِثَ أَمِيرِ المُؤْمِنِينَ عَلَيْهِ السَّلامُ، السَّلامُ عَلَيْكَ يا ابْنَ مُحَمَّدٍ المُصْطَفى، السَّلامُ عَلَيْكَ يا ابْنَ عَلِيٍّ المُرْتَضى، السَّلامُ عَلَيْكَ يا ابْنَ فاطِمَةَ الزَّهْراءِ، السَّلامُ عَلَيْكَ يا ابْنَ خَدِيجَةَ الكُبْرى، السَّلامُ عَلَيْكَ يا ثارَ اللهِ وَابْنَ ثارِهِ وَالوِتْرَ المَوْتُورَ.

أَشْهَدُ أَنَّكَ قَدْ أَقَمْتَ الصَّلاةَ وَآتَيْتَ الزَّكاةَ وَأَمَرْتَ بِالمَعْرُوفِ وَنَهَيْتَ عَنِ المُنْكَرِ وَأَطَعْتَ اللهَ وَرَسُولَهُ حَتّى أَتاكَ اليَقِينُ، فَلَعَنَ اللهُ أُمَّةً قَتَلَتْكَ وَلَعَنَ اللهُ أُمَّةً ظَلَمَتْكَ وَلَعَنَ اللهُ أُمَّةً سَمِعَتْ بِذلِكَ فَرَضِيَتْ بِهِ.

يا مَوْلايَ يا أَبا عَبْدِ اللهِ، أَشْهَدُ أَنَّكَ كُنْتَ نُوراً فِي الأَصْلابِ الشّامِخَةِ وَالأَرْحامِ المُطَهَّرَةِ، لَمْ تُنَجِّسْكَ الجاهِلِيَّةُ بِأَنْجاسِها وَلَمْ تُلْبِسْكَ مِنْ مُدْلَهِمّاتِ ثِيابِها. وَأَشْهَدُ أَنَّكَ مِنْ دَعائِمِ الدِّينِ وَأَرْكانِ المُؤْمِنِينَ، وَأَشْهَدُ أَنَّكَ الإِمامُ البَرُّ التَّقِيُّ الرَّضِيُّ الزَّكِيُّ الهادِي المَهْدِيُّ، وَأَشْهَدُ أَنَّ الأَئِمَّةَ مِنْ وُلْدِكَ كَلِمَةُ التَّقْوى وَأَعْلامُ الهُدى وَالعُرْوَةُ الوُثْقى وَالحُجَّةُ عَلى أَهْلِ الدُّنْيا.

وَأُشْهِدُ اللهَ وَمَلائِكَتَهُ وَأَنْبِياءَهُ وَرُسُلَهُ أَنِّي بِكُمْ مُؤْمِنٌ وَبِإِيابِكُمْ مُوقِنٌ بِشَرائِعِ دِينِي وَخَواتِيمِ عَمَلِي، وَقَلْبِي لِقَلْبِكُمْ سِلْمٌ وَأَمْرِي لأَمْرِكُمْ مُتَّبِعٌ. صَلَواتُ اللهِ عَلَيْكُمْ وَعَلى أَرْواحِكُمْ وَعَلى أَجْسادِكُمْ وَعَلى أَجْسامِكُمْ وَعَلى شاهِدِكُمْ وَعَلى غائِبِكُمْ وَعَلى ظاهِرِكُمْ وَعَلى باطِنِكُمْ.

بِأَبِي أَنْتَ وَأُمِّي يا ابْنَ رَسُولِ اللهِ، بِأَبِي أَنْتَ وَأُمِّي يا أَبا عَبْدِ اللهِ، لَقَدْ عَظُمَتِ الرَّزِيَّةُ وَجَلَّتِ المُصِيبَةُ بِكَ عَلَيْنا وَعَلى جَميعِ أَهْلِ السَّماواتِ وَالأَرْضِ، فَلَعَنَ اللهُ أُمَّةً أَسْرَجَتْ وَأَلْجَمَتْ وَتَهَيَّأَتْ لِقِتالِكَ. يا مَوْلايَ يا أَبا عَبْدِ اللهِ، قَصَدْتُ حَرَمَكَ وَأَتَيْتُ إِلى مَشْهَدِكَ، أَسْأَلُ اللهَ بِالشَّأْنِ الَّذِي لَكَ عِنْدَهُ وَبِالمَحَلِّ الَّذِي لَكَ لَدَيْهِ أَنْ يُصَلِّيَ عَلى مُحَمَّدٍ وَآلِ مُحَمَّدٍ وَأَنْ يَجْعَلَنِي مَعَكُمْ فِي الدُّنْيا وَالآخِرَةِ.
''',
  'visit_amin': '''
السَّلامُ عَلَيْكَ يا أَمِينَ اللهِ فِي أَرْضِهِ وَحُجَّتَهُ عَلى عِبادِهِ، السَّلامُ عَلَيْكَ يا أَمِيرَ المُؤْمِنِينَ. أَشْهَدُ أَنَّكَ جاهَدْتَ فِي اللهِ حَقَّ جِهادِهِ، وَعَمِلْتَ بِكِتابِهِ، وَاتَّبَعْتَ سُنَنَ نَبِيِّهِ مُحَمَّدٍ صَلّى اللهُ عَلَيْهِ وَآلِهِ، حَتّى دَعاكَ اللهُ إِلى جِوارِهِ، فَقَبَضَكَ إِلَيْهِ بِاخْتِيارِهِ، وَأَلْزَمَ أَعْداءَكَ الحُجَّةَ مَعَ ما لَكَ مِنَ الحُجَجِ البالِغَةِ عَلى جَميعِ خَلْقِهِ.

اللّهُمَّ فَاجْعَلْ نَفْسِي مُطْمَئِنَّةً بِقَدَرِكَ، راضِيَةً بِقَضائِكَ، مُولَعَةً بِذِكْرِكَ وَدُعائِكَ، مُحِبَّةً لِصَفْوَةِ أَوْلِيائِكَ، مَحْبُوبَةً فِي أَرْضِكَ وَسَمائِكَ، صابِرَةً عِنْدَ نُزُولِ بَلائِكَ، شاكِرَةً لِفَواضِلِ نَعْمائِكَ، ذاكِرَةً لِسَوابِغِ آلائِكَ، مُشْتاقَةً إِلى فَرْحَةِ لِقائِكَ، مُتَزَوِّدَةً التَّقْوى لِيَوْمِ جَزائِكَ، مُسْتَنَّةً بِسُنَنِ أَوْلِيائِكَ، مُفارِقَةً لِأَخْلاقِ أَعْدائِكَ، مَشْغُولَةً عَنِ الدُّنْيا بِحَمْدِكَ وَثَنائِكَ.
''',
  'dua_tawassul': '''
اللّهُمَّ إِنِّي أَسْأَلُكَ وَأَتَوَجَّهُ إِلَيْكَ بِنَبِيِّكَ نَبِيِّ الرَّحْمَةِ مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَآلِهِ، يا أَبا القاسِمِ يا رَسُولَ اللهِ يا إِمامَ الرَّحْمَةِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا الحَسَنِ يا أَمِيرَ المُؤْمِنِينَ يا عَلِيَّ بْنَ أَبي طالِبٍ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا فاطِمَةَ الزَّهْراءُ يا بِنْتَ مُحَمَّدٍ يا قُرَّةَ عَيْنِ الرَّسُولِ يا سَيِّدَتَنا وَمَوْلاتَنا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكِ إِلَى اللهِ، وَقَدَّمْناكِ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهَةً عِنْدَ اللهِ اشْفَعِي لَنا عِنْدَ اللهِ.

يا أَبا مُحَمَّدٍ يا حَسَنَ بْنَ عَلِيٍّ أَيُّها المُجْتَبى يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا عَبْدِ اللهِ يا حُسَيْنَ بْنَ عَلِيٍّ أَيُّها الشَّهِيدُ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا الحَسَنِ يا عَلِيَّ بْنَ الحُسَيْنِ يا زَيْنَ العابِدِينَ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا جَعْفَرٍ يا مُحَمَّدَ بْنَ عَلِيٍّ أَيُّها الباقِرُ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا عَبْدِ اللهِ يا جَعْفَرَ بْنَ مُحَمَّدٍ أَيُّها الصّادِقُ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا الحَسَنِ يا مُوسى بْنَ جَعْفَرٍ أَيُّها الكاظِمُ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا الحَسَنِ يا عَلِيَّ بْنَ مُوسى أَيُّها الرِّضا يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا جَعْفَرٍ يا مُحَمَّدَ بْنَ عَلِيٍّ أَيُّها التَّقِيُّ الجَوادُ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا الحَسَنِ يا عَلِيَّ بْنَ مُحَمَّدٍ أَيُّها الهادِي النَّقِيُّ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا أَبا مُحَمَّدٍ يا حَسَنَ بْنَ عَلِيٍّ أَيُّها الزَّكِيُّ العَسْكَرِيُّ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

يا وَصِيَّ الحَسَنِ وَالخَلَفَ الحُجَّةَ أَيُّها القائِمُ المُنْتَظَرُ المَهْدِيُّ يا ابْنَ رَسُولِ اللهِ يا حُجَّةَ اللهِ عَلى خَلْقِهِ يا سَيِّدَنا وَمَوْلانا، إِنّا تَوَجَّهْنا وَاسْتَشْفَعْنا وَتَوَسَّلْنا بِكَ إِلَى اللهِ، وَقَدَّمْناكَ بَيْنَ يَدَيْ حاجاتِنا، يا وَجِيهاً عِنْدَ اللهِ اشْفَعْ لَنا عِنْدَ اللهِ.

ثُمَّ سَلْ حَوائِجَكَ، فَإِنَّها تُقْضى إِنْ شاءَ اللهُ تَعالى. وَعَلى رِوايَةٍ أُخْرى قُلْ بَعْدَ ذلِكَ:
يا سادَتِي وَمَوالِيَّ، إِنِّي تَوَجَّهْتُ بِكُمْ أَئِمَّتِي وَعُدَّتِي لِيَوْمِ فَقْرِي وَحاجَتِي إِلَى اللهِ، وَتَوَسَّلْتُ بِكُمْ إِلَى اللهِ، وَاسْتَشْفَعْتُ بِكُمْ إِلَى اللهِ، فَاشْفَعُوا لِي عِنْدَ اللهِ، وَاسْتَنْقِذُونِي مِنْ ذُنُوبِي عِنْدَ اللهِ، فَإِنَّكُمْ وَسِيلَتِي إِلَى اللهِ وَبِحُبِّكُمْ وَبِقُرْبِكُمْ أَرْجُو النَّجاةَ مِنَ اللهِ، فَكُونُوا عِنْدَ اللهِ رَجائِي يا سادَتِي يا أَوْلِياءَ اللهِ، صَلَّى اللهُ عَلَيْهِمْ أَجْمَعِينَ وَلَعَنَ اللهُ أَعْداءَ اللهِ ظالِمِيهِمْ مِنَ الأَوَّلِينَ وَالآخِرِينَ، آمِينَ رَبَّ العالَمِينَ.
''',

  'dua_ahd': '''
اللّهُمَّ رَبَّ النُّورِ العَظِيمِ وَرَبَّ الكُرْسِيِّ الرَّفِيعِ وَرَبَّ البَحْرِ المَسْجُورِ وَمُنْزِلَ التَّوْراةِ وَالإِنْجِيلِ وَالزَّبُورِ وَرَبَّ الظِّلِّ وَالحَرُورِ وَمُنْزِلَ القُرْآنِ العَظِيمِ وَرَبَّ المَلائِكَةِ المُقَرَّبِينَ وَالأَنْبِياءِ وَالمُرْسَلِينَ.

اللّهُمَّ إِنِّي أَسْأَلُكَ بِوَجْهِكَ الكَرِيمِ وَبِنُورِ وَجْهِكَ المُنِيرِ وَمُلْكِكَ القَدِيمِ، يا حَيُّ يا قَيُّومُ، أَسْأَلُكَ بِاسْمِكَ الَّذِي أَشْرَقَتْ بِهِ السَّماواتُ وَالأَرَضُونَ وَبِاسْمِكَ الَّذِي يَصْلَحُ بِهِ الأَوَّلُونَ وَالآخِرُونَ، يا حَيّاً قَبْلَ كُلِّ حَيٍّ وَيا حَيّاً بَعْدَ كُلِّ حَيٍّ وَيا حَيّاً حِينَ لا حَيَّ، يا مُحْيِيَ المَوْتى وَمُمِيتَ الأَحْياءِ، يا حَيُّ لا إِلهَ إِلّا أَنْتَ.

اللّهُمَّ بَلِّغْ مَوْلانا الإِمامَ الهادِيَ المَهْدِيَّ القائِمَ بِأَمْرِكَ صَلَواتُ اللهِ عَلَيْهِ وَعَلى آبائِهِ الطّاهِرِينَ، عَنْ جَمِيعِ المُؤْمِنِينَ وَالمُؤْمِناتِ فِي مَشارِقِ الأَرْضِ وَمَغارِبِها، سَهْلِها وَجَبَلِها وَبَرِّها وَبَحْرِها، وَعَنِّي وَعَنْ والِدَيَّ مِنَ الصَّلَواتِ زِنَةَ عَرْشِ اللهِ وَمِدادَ كَلِماتِهِ وَما أَحْصاهُ عِلْمُهُ وَأَحاطَ بِهِ كِتابُهُ.

اللّهُمَّ إِنِّي أُجَدِّدُ لَهُ فِي صَبيحَةِ يَوْمِي هذا وَما عِشْتُ مِنْ أَيّامِي عَهْداً وَعَقْداً وَبَيْعَةً لَهُ فِي عُنُقِي، لا أَحُولُ عَنْها وَلا أَزُولُ أَبَداً.

اللّهُمَّ اجْعَلْنِي مِنْ أَنْصارِهِ وَأَعْوانِهِ وَالذّابِّينَ عَنْهُ وَالمُسارِعِينَ إِلَيْهِ فِي قَضاءِ حَوائِجِهِ وَالمُمْتَثِلِينَ لِأَوامِرِهِ وَالمُحامِينَ عَنْهُ وَالسّابِقِينَ إِلى إِرادَتِهِ وَالمُسْتَشْهَدِينَ بَيْنَ يَدَيْهِ.

اللّهُمَّ إِنْ حالَ بَيْنِي وَبَيْنَهُ المَوْتُ الَّذِي جَعَلْتَهُ عَلى عِبادِكَ حَتْماً مَقْضِيّاً، فَأَخْرِجْنِي مِنْ قَبْرِي مُؤْتَزِراً كَفَنِي، شاهِراً سَيْفِي، مُجَرِّداً قَناتِي، مُلَبِّياً دَعْوَةَ الدّاعِي فِي الحاضِرِ وَالبادِي.

اللّهُمَّ أَرِنِي الطَّلْعَةَ الرَّشِيدَةَ وَالغُرَّةَ الحَمِيدَةَ، وَاكْحُلْ ناظِرِي بِنَظْرَةٍ مِنِّي إِلَيْهِ، وَعَجِّلْ فَرَجَهُ وَسَهِّلْ مَخْرَجَهُ وَأَوْسِعْ مَنْهَجَهُ وَاسْلُكْ بِي مَحَجَّتَهُ وَأَنْفِذْ أَمْرَهُ وَاشْدُدْ أَزْرَهُ.

وَاعْمُرِ اللّهُمَّ بِهِ بِلادَكَ وَأَحْيِ بِهِ عِبادَكَ، فَإِنَّكَ قُلْتَ وَقَوْلُكَ الحَقُّ: ظَهَرَ الفَسادُ فِي البَرِّ وَالبَحْرِ بِما كَسَبَتْ أَيْدِي النّاسِ. فَأَظْهِرِ اللّهُمَّ لَنا وَلِيَّكَ وَابْنَ بِنْتِ نَبِيِّكَ المُسَمّى بِاسْمِ رَسُولِكَ، حَتّى لا يَظْفَرَ بِشَيْءٍ مِنَ الباطِلِ إِلّا مَزَّقَهُ وَيُحِقَّ الحَقَّ وَيُحَقِّقَهُ.

وَاجْعَلْهُ اللّهُمَّ مَفْزَعاً لِمَظْلُومِ عِبادِكَ وَناصِراً لِمَنْ لا يَجِدُ لَهُ ناصِراً غَيْرَكَ، وَمُجَدِّداً لِما عُطِّلَ مِنْ أَحْكامِ كِتابِكَ وَمُشَيِّداً لِما وَرَدَ مِنْ أَعْلامِ دِينِكَ وَسُنَنِ نَبِيِّكَ صَلّى اللهُ عَلَيْهِ وَآلِهِ.

وَاجْعَلْهُ اللّهُمَّ مِمَّنْ حَصَّنْتَهُ مِنْ بَأْسِ المُعْتَدِينَ. اللّهُمَّ وَسُرَّ نَبِيَّكَ مُحَمَّداً صَلّى اللهُ عَلَيْهِ وَآلِهِ بِرُؤْيَتِهِ وَمَنْ تَبِعَهُ عَلى دَعْوَتِهِ، وَارْحَمِ اسْتِكانَتَنا بَعْدَهُ.

اللّهُمَّ اكْشِفْ هذِهِ الغُمَّةَ عَنْ هذِهِ الأُمَّةِ بِحُضُورِهِ، وَعَجِّلْ لَنا ظُهُورَهُ، إِنَّهُمْ يَرَوْنَهُ بَعِيداً وَنَراهُ قَرِيباً، بِرَحْمَتِكَ يا أَرْحَمَ الرّاحِمِينَ.

العَجَلَ العَجَلَ يا مَوْلايَ يا صاحِبَ الزَّمانِ.
''',
  'dua_iftitah': '''
اللّهُمَّ إِنِّي أَفْتَتِحُ الثَّناءَ بِحَمْدِكَ، وَأَنْتَ مُسَدِّدٌ لِلصَّوابِ بِمَنِّكَ، وَأَيْقَنْتُ أَنَّكَ أَنْتَ أَرْحَمُ الرّاحِمِينَ فِي مَوْضِعِ العَفْوِ وَالرَّحْمَةِ، وَأَشَدُّ المُعاقِبِينَ فِي مَوْضِعِ النَّكالِ وَالنَّقِمَةِ، وَأَعْظَمُ المُتَجَبِّرِينَ فِي مَوْضِعِ الكِبْرِياءِ وَالعَظَمَةِ.

اللّهُمَّ أَذِنْتَ لِي فِي دُعائِكَ وَمَسْأَلَتِكَ، فَاسْمَعْ يا سَمِيعُ مِدْحَتِي، وَأَجِبْ يا رَحِيمُ دَعْوَتِي، وَأَقِلْ يا غَفُورُ عَثْرَتِي، فَكَمْ يا إِلهِي مِنْ كُرْبَةٍ قَدْ فَرَّجْتَها، وَهُمُومٍ قَدْ كَشَفْتَها، وَعَثْرَةٍ قَدْ أَقَلْتَها، وَرَحْمَةٍ قَدْ نَشَرْتَها، وَحَلْقَةِ بَلاءٍ قَدْ فَكَكْتَها. الحَمْدُ للهِ الَّذِي لَمْ يَتَّخِذْ صاحِبَةً وَلا وَلَداً، وَلَمْ يَكُنْ لَهُ شَرِيكٌ فِي المُلكِ، وَلَمْ يَكُنْ لَهُ وَلِيٌّ مِنَ الذُّلِّ، وَكَبِّرْهُ تَكْبِيراً. الحَمْدُ للهِ بِجَمِيعِ مَحامِدِهِ كُلِّها عَلى جَمِيعِ نِعَمِهِ كُلِّها، الحَمْدُ للهِ الَّذِي لا مُضادَّ لَهُ فِي مُلْكِهِ وَلا مُنازِعَ لَهُ فِي أَمْرِهِ، الحَمْدُ للهِ الَّذِي لا شَرِيكَ لَهُ فِي خَلْقِهِ وَلا شَبِيهَ لَهُ فِي عَظَمَتِهِ، الحَمْدُ للهِ الفاشِي فِي الخَلْقِ أَمْرُهُ وَحَمْدُهُ، الظّاهِرِ بِالكَرَمِ مَجْدُهُ، الباسِطِ بِالجُودِ يَدَهُ، الَّذِي لا تَنْقُصُ خَزائِنُهُ وَلا يَزِيدُهُ كَثْرَةُ العَطاءِ إِلّا جُوداً وَكَرَماً، إِنَّهُ هُوَ العَزِيزُ الوَهّابُ. اللّهُمَّ إِنِّي أَسْأَلُكَ قَلِيلاً مِنْ كَثِيرٍ مَعَ حاجَةٍ بِي إِلَيْهِ عَظِيمَةٍ وَغِناكَ عَنْهُ قَدِيمٌ، وَهُوَ عِنْدِي كَثِيرٌ وَهُوَ عَلَيْكَ سَهْلٌ يَسِيرٌ. اللّهُمَّ إِنَّ عَفْوَكَ عَنْ ذَنْبِي وَتَجاوُزَكَ عَنْ خَطِيئَتِي وَصَفْحَكَ عَنْ ظُلْمِي وَسَتْرَكَ عَلى قَبِيحِ عَمَلِي وَحِلْمَكَ عَنْ كَثِيرِ جُرْمِي، عِنْدَما كانَ مِنْ خَطَئِي وَعَمْدِي، أَطْمَعَنِي فِي أَنْ أَسْأَلَكَ ما لا أَسْتَوْجِبُهُ مِنْكَ، الَّذِي رَزَقْتَنِي مِنْ رَحْمَتِكَ وَأَرَيْتَنِي مِنْ قُدْرَتِكَ وَعَرَّفْتَنِي مِنْ إِجابَتِكَ، فَصِرْتُ أَدْعُوكَ آمِناً وَأَسْأَلُكَ مُسْتَأْنِساً، لا خائِفاً وَلا وَجِلاً، مُدِلّاً عَلَيْكَ فِيما قَصَدْتُ فِيهِ إِلَيْكَ، فَإِنْ أَبْطَأَ عَنِّي عَتَبْتُ بِجَهْلِي عَلَيْكَ، وَلَعَلَّ الَّذِي أَبْطَأَ عَنِّي هُوَ خَيْرٌ لِي لِعِلْمِكَ بِعاقِبَةِ الأُمُورِ، فَلَمْ أَرَ مَوْلىً كَرِيماً أَصْبَرَ عَلى عَبْدٍ لَئِيمٍ مِنْكَ عَلَيَّ يا رَبِّ.

إِنَّكَ تَدْعُونِي فَأُوَلِّي عَنْكَ، وَتَتَحَبَّبُ إِلَيَّ فَأَتَبَغَّضُ إِلَيْكَ، وَتَتَوَدَّدُ إِلَيَّ فَلا أَقْبَلُ مِنْكَ، كَأَنَّ لِيَ التَّطَوُّلَ عَلَيْكَ، فَلَمْ يَمْنَعْكَ ذلِكَ مِنَ الرَّحْمَةِ لِي وَالإِحْسانِ إِلَيَّ وَالتَّفَضُّلِ عَلَيَّ بِجُودِكَ وَكَرَمِكَ، فَارْحَمْ عَبْدَكَ الجاهِلَ وَجُدْ عَلَيْهِ بِفَضْلِ إِحْسانِكَ، إِنَّكَ جَوادٌ كَرِيمٌ.

الحَمْدُ للهِ مالِكِ المُلكِ، مُجْرِي الفُلْكِ، مُسَخِّرِ الرِّياحِ، فالِقِ الإِصْباحِ، دَيّانِ الدِّينِ رَبِّ العالَمِينَ. الحَمْدُ للهِ عَلى حِلْمِهِ بَعْدَ عِلْمِهِ، وَالحَمْدُ للهِ عَلى عَفْوِهِ بَعْدَ قُدْرَتِهِ، وَالحَمْدُ للهِ عَلى طُولِ أَناتِهِ فِي غَضَبِهِ وَهُوَ قادِرٌ عَلى ما يُرِيدُ. الحَمْدُ للهِ خالِقِ الخَلْقِ باسِطِ الرِّزْقِ فالِقِ الإِصْباحِ ذِي الجَلالِ وَالإِكْرامِ وَالفَضْلِ وَالإِنْعامِ، الَّذِي بَعُدَ فَلا يُرى وَقَرُبَ فَشَهِدَ النَّجْوى، تَبارَكَ وَتَعالى. الحَمْدُ للهِ الَّذِي لَيْسَ لَهُ مُنازِعٌ يُعادِلُهُ وَلا شَبِيهٌ يُشاكِلُهُ وَلا ظَهِيرٌ يُعاضِدُهُ، قَهَرَ بِعِزَّتِهِ الأَعِزّاءَ وَتَواضَعَ لِعَظَمَتِهِ العُظَماءُ، فَبَلَغَ بِقُدْرَتِهِ ما يَشاءُ. الحَمْدُ للهِ الَّذِي يُجِيبُنِي حِينَ أُنادِيهِ وَيَسْتُرُ عَلَيَّ كُلَّ عَوْرَةٍ وَأَنا أَعْصِيهِ، وَيُعَظِّمُ النِّعْمَةَ عَلَيَّ فَلا أُجازِيهِ، فَكَمْ مِنْ مَوْهِبَةٍ هَنِيئَةٍ قَدْ أَعْطانِي، وَعَظِيمَةٍ مَخُوفَةٍ قَدْ كَفانِي، وَبَهْجَةٍ مُونِقَةٍ قَدْ أَرانِي، فَأُثْنِي عَلَيْهِ حامِداً وَأَذْكُرُهُ مُسَبِّحاً.

الحَمْدُ للهِ الَّذِي لا يُهْتَكُ حِجابُهُ وَلا يُغْلَقُ بابُهُ وَلا يُرَدُّ سائِلُهُ وَلا يُخَيَّبُ آمِلُهُ، الحَمْدُ للهِ الَّذِي يُؤْمِنُ الخائِفِينَ وَيُنَجِّي الصّالِحِينَ وَيَرْفَعُ المُسْتَضْعَفِينَ وَيَضَعُ المُسْتَكْبِرِينَ وَيُهْلِكُ مُلُوكاً وَيَسْتَخْلِفُ آخَرِينَ. الحَمْدُ للهِ قاصِمِ الجَبّارِينَ مُبِيرِ الظّالِمِينَ مُدْرِكِ الهارِبِينَ نَكالِ الظّالِمِينَ صَرِيخِ المُسْتَصْرِخِينَ مَوْضِعِ حاجاتِ الطّالِبِينَ مُعْتَمَدِ المُؤْمِنِينَ. الحَمْدُ للهِ الَّذِي مِنْ خَشْيَتِهِ تَرْعَدُ السَّماءُ وَسُكّانُها وَتَرْجُفُ الأَرْضُ وَعُمّارُها وَتَمُوجُ البِحارُ وَمَنْ يَسْبَحُ فِي غَمَراتِها. الحَمْدُ للهِ الَّذِي هَدانا لِهذا وَما كُنّا لِنَهْتَدِيَ لَوْلا أَنْ هَدانَا اللهُ. الحَمْدُ للهِ الَّذِي يَخْلُقُ وَلَمْ يُخْلَقْ وَيَرْزُقُ وَلا يُرْزَقُ وَيُطْعِمُ وَلا يُطْعَمُ وَيُمِيتُ الأَحْياءَ وَيُحْيِي المَوْتى وَهُوَ حَيٌّ لا يَمُوتُ، بِيَدِهِ الخَيْرُ وَهُوَ عَلى كُلِّ شَيْءٍ قَدِيرٌ.

اللّهُمَّ صَلِّ عَلى مُحَمَّدٍ عَبْدِكَ وَرَسُولِكَ وَأَمِينِكَ وَصَفِيِّكَ وَحَبِيبِكَ وَخِيَرَتِكَ مِنْ خَلْقِكَ وَحافِظِ سِرِّكَ وَمُبَلِّغِ رِسالاتِكَ، أَفْضَلَ وَأَحْسَنَ وَأَجْمَلَ وَأَكْمَلَ وَأَزْكى وَأَنْمى وَأَطْيَبَ وَأَطْهَرَ وَأَسْنى وَأَكْثَرَ ما صَلَّيْتَ وَبارَكْتَ وَتَرَحَّمْتَ وَتَحَنَّنْتَ وَسَلَّمْتَ عَلى أَحَدٍ مِنْ عِبادِكَ وَأَنْبِيائِكَ وَرُسُلِكَ وَصَفْوَتِكَ وَأَهْلِ الكَرامَةِ عَلَيْكَ مِنْ خَلْقِكَ. اللّهُمَّ وَصَلِّ عَلى عَلِيٍّ أَمِيرِ المُؤْمِنِينَ وَوَصِيِّ رَسُولِ رَبِّ العالَمِينَ عَبْدِكَ وَوَلِيِّكَ وَأَخِي رَسُولِكَ وَحُجَّتِكَ عَلى خَلْقِكَ وَآيَتِكَ الكُبْرى وَالنَّبَأِ العَظِيمِ، وَصَلِّ عَلى الصِّدِّيقَةِ الطّاهِرَةِ فاطِمَةَ سَيِّدَةِ نِساءِ العالَمِينَ، وَصَلِّ عَلى سِبْطَيِ الرَّحْمَةِ وَإِمامَيِ الهُدى الحَسَنِ وَالحُسَيْنِ سَيِّدَي شَبابِ أَهْلِ الجَنَّةِ، وَصَلِّ عَلى أَئِمَّةِ المُسْلِمِينَ عَلِيِّ بْنِ الحُسَيْنِ وَمُحَمَّدِ بْنِ عَلِيٍّ وَجَعْفَرِ بْنِ مُحَمَّدٍ وَمُوسى بْنِ جَعْفَرٍ وَعَلِيِّ بْنِ مُوسى وَمُحَمَّدِ بْنِ عَلِيٍّ وَعَلِيِّ بْنِ مُحَمَّدٍ وَالحَسَنِ بْنِ عَلِيٍّ وَالخَلَفِ الهادِي المَهْدِيِّ، حُجَجِكَ عَلى عِبادِكَ وَأُمَنائِكَ فِي بِلادِكَ، صَلاةً كَثِيرَةً دائِمَةً.

اللّهُمَّ وَصَلِّ عَلى وَلِيِّ أَمْرِكَ القائِمِ المُؤَمَّلِ وَالعَدْلِ المُنْتَظَرِ، وَحُفَّهُ بِمَلائِكَتِكَ المُقَرَّبِينَ وَأَيِّدْهُ بِرُوحِ القُدُسِ يا رَبَّ العالَمِينَ. اللّهُمَّ اجْعَلْهُ الدّاعِيَ إِلى كِتابِكَ وَالقائِمَ بِدِينِكَ، اسْتَخْلِفْهُ فِي الأَرْضِ كَما اسْتَخْلَفْتَ الَّذِينَ مِنْ قَبْلِهِ، مَكِّنْ لَهُ دِينَهُ الَّذِي ارْتَضَيْتَهُ لَهُ، أَبْدِلْهُ مِنْ بَعْدِ خَوْفِهِ أَمْناً يَعْبُدُكَ لا يُشْرِكُ بِكَ شَيْئاً. اللّهُمَّ أَعِزَّهُ وَأَعْزِزْ بِهِ، وَانْصُرْهُ وَانْتَصِرْ بِهِ، وَانْصُرْهُ نَصْراً عَزِيزاً، وَافْتَحْ لَهُ فَتْحاً يَسِيراً، وَاجْعَلْ لَهُ مِنْ لَدُنْكَ سُلْطاناً نَصِيراً. اللّهُمَّ أَظْهِرْ بِهِ دِينَكَ وَسُنَّةَ نَبِيِّكَ حَتّى لا يَسْتَخْفِيَ بِشَيْءٍ مِنَ الحَقِّ مَخافَةَ أَحَدٍ مِنَ الخَلْقِ. اللّهُمَّ إِنّا نَرْغَبُ إِلَيْكَ فِي دَوْلَةٍ كَرِيمَةٍ تُعِزُّ بِها الإِسْلامَ وَأَهْلَهُ وَتُذِلُّ بِها النِّفاقَ وَأَهْلَهُ، وَتَجْعَلُنا فِيها مِنَ الدُّعاةِ إِلى طاعَتِكَ وَالقادَةِ إِلى سَبِيلِكَ، وَتَرْزُقُنا بِها كَرامَةَ الدُّنْيا وَالآخِرَةِ.

اللّهُمَّ ما عَرَّفْتَنا مِنَ الحَقِّ فَحَمِّلْناهُ، وَما قَصُرْنا عَنْهُ فَبَلِّغْناهُ. اللّهُمَّ أَلْمِمْ بِهِ شَعْثَنا وَاشْعَبْ بِهِ صَدْعَنا وَارْتُقْ بِهِ فَتْقَنا وَكَثِّرْ بِهِ قِلَّتَنا وَأَعْزِزْ بِهِ ذِلَّتَنا وَأَغْنِ بِهِ عائِلَنا وَاقْضِ بِهِ عَنْ مُغْرَمِنا وَاجْبُرْ بِهِ فَقْرَنا وَسُدَّ بِهِ خَلَّتَنا وَيَسِّرْ بِهِ عُسْرَنا وَبَيِّضْ بِهِ وُجُوهَنا وَفُكَّ بِهِ أَسْرَنا وَأَنْجِحْ بِهِ طَلِبَتَنا وَأَنْجِزْ بِهِ مَواعِيدَنا وَاسْتَجِبْ بِهِ دَعْوَتَنا وَأَعْطِنا بِهِ سُؤْلَنا وَبَلِّغْنا بِهِ مِنَ الدُّنْيا وَالآخِرَةِ آمالَنا وَأَعْطِنا بِهِ فَوْقَ رَغْبَتِنا، يا خَيْرَ المَسْؤُولِينَ وَأَوْسَعَ المُعْطِينَ. اشْفِ بِهِ صُدُورَنا وَأَذْهِبْ بِهِ غَيْظَ قُلُوبِنا وَاهْدِنا بِهِ لِما اخْتُلِفَ فِيهِ مِنَ الحَقِّ بِإِذْنِكَ، إِنَّكَ تَهْدِي مَنْ تَشاءُ إِلى صِراطٍ مُسْتَقِيمٍ. وَانْصُرْنا بِهِ عَلى عَدُوِّكَ وَعَدُوِّنا، إِلهَ الحَقِّ آمِينَ.

اللّهُمَّ إِنّا نَشْكُو إِلَيْكَ فَقْدَ نَبِيِّنا صَلَواتُكَ عَلَيْهِ وَآلِهِ وَغَيْبَةَ وَلِيِّنا وَكَثْرَةَ عَدُوِّنا وَقِلَّةَ عَدَدِنا وَشِدَّةَ الفِتَنِ بِنا وَتَظاهُرَ الزَّمانِ عَلَيْنا، فَصَلِّ عَلى مُحَمَّدٍ وَآلِهِ، وَأَعِنّا عَلى ذلِكَ بِفَتْحٍ مِنْكَ تُعَجِّلُهُ وَبِضُرٍّ تَكْشِفُهُ وَنَصْرٍ تُعِزُّهُ وَسُلْطانِ حَقٍّ تُظْهِرُهُ وَرَحْمَةٍ مِنْكَ تُجَلِّلُناها وَعافِيَةٍ مِنْكَ تُلْبِسُناها، بِرَحْمَتِكَ يا أَرْحَمَ الرّاحِمِينَ.
''',
};

class LibrarySectionScreen extends StatefulWidget {
  const LibrarySectionScreen({super.key, required this.title});

  final String title;

  @override
  State<LibrarySectionScreen> createState() => _LibrarySectionScreenState();
}

class _LibrarySectionScreenState extends State<LibrarySectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _favorites = {};
  String? _lastReadId;
  bool _loading = true;
  String _query = '';

  List<_LibraryItem> get _allItems =>
      _libraryItems.values.expand((items) => items).toList();

  List<_LibraryItem> get _visibleItems {
    final source = widget.title == 'المفضلة'
        ? _allItems.where((item) => _favorites.contains(item.id)).toList()
        : widget.title == 'آخر قراءة'
            ? _allItems.where((item) => item.id == _lastReadId).toList()
            : _libraryItems[widget.title] ?? <_LibraryItem>[];
    if (_query.trim().isEmpty) return source;
    final query = _query.trim().toLowerCase();
    return source
        .where((item) =>
            item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorites = preferences.getStringList('library_favorites')?.toSet() ?? {};
      _lastReadId = preferences.getString('library_last_read');
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(_LibraryItem item) async {
    final next = Set<String>.from(_favorites);
    if (!next.add(item.id)) next.remove(item.id);
    setState(() => _favorites = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList('library_favorites', next.toList());
  }

  Future<void> _openItem(_LibraryItem item) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('library_last_read', item.id);
    if (!mounted) return;
    setState(() => _lastReadId = item.id);
    if (item.id.startsWith('night_')) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const NightPrayerTutorialScreen(),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LibraryItemDetail(
          item: item,
          isFavorite: _favorites.contains(item.id),
          onToggleFavorite: () => _toggleFavorite(item),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: _TwilightSubpageAppBar(title: widget.title),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: _TwilightGlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                      radius: 19,
                      child: Row(children: [
                        const _TwilightGlassOrb(icon: Icons.auto_stories_rounded, size: 44),
                        const SizedBox(width: 11),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.title, style: const TextStyle(color: ivory, fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('${items.length} عنصر • بحث ومفضلة وحفظ آخر قراءة', style: const TextStyle(color: mutedIvory, fontSize: 10, height: 1.5)),
                        ])),
                        const Icon(Icons.chevron_left_rounded, color: turquoise),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    child: _TwilightGlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      radius: 17,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        style: const TextStyle(color: ivory),
                        decoration: InputDecoration(
                          hintText: 'ابحث في هذا القسم...',
                          hintStyle: const TextStyle(color: mutedIvory),
                          prefixIcon: const Icon(Icons.search_rounded, color: turquoise),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: _TwilightGlassPanel(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                                radius: 22,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _TwilightGlassOrb(
                                      icon: widget.title == 'المفضلة'
                                          ? Icons.bookmark_border_rounded
                                          : widget.title == 'آخر قراءة'
                                              ? Icons.history_rounded
                                              : Icons.search_off_rounded,
                                      size: 58,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      widget.title == 'المفضلة'
                                          ? 'قائمة المفضلة فارغة'
                                          : widget.title == 'آخر قراءة'
                                              ? 'لا توجد قراءة سابقة'
                                              : 'لا توجد نتائج مطابقة',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: ivory,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.title == 'المفضلة'
                                          ? 'يمكنك حفظ النصوص المهمة بالضغط على علامة الحفظ بجانب كل عنصر.'
                                          : widget.title == 'آخر قراءة'
                                              ? 'عند فتح أي نص من المكتبة سيظهر هنا لتعود إليه بسهولة.'
                                              : 'جرّب تغيير عبارة البحث أو حذفها لعرض عناصر القسم.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: mutedIvory,
                                        height: 1.8,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final favorite = _favorites.contains(item.id);
                              return _TwilightGlassPanel(
                                padding: EdgeInsets.zero,
                                radius: 14,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _openItem(item),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                                      child: Row(
                                        children: [
                                          _TwilightGlassOrb(icon: _readerItemIcon(item), size: 46),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.title,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: ivory,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.description,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: mutedIvory,
                                                    fontSize: 11,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          IconButton(
                                            tooltip: favorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                                            onPressed: () => _toggleFavorite(item),
                                            icon: Icon(
                                              favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                              color: favorite ? gold : mutedIvory,
                                            ),
                                          ),
                                          const Icon(Icons.chevron_left_rounded, color: turquoise, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}


IconData _readerItemIcon(_LibraryItem item) {
  final id = item.id.toLowerCase();
  if (id.startsWith('night_')) {
    return Icons.nightlight_round;
  }
  if (id.startsWith('nahj_')) {
    return Icons.menu_book_rounded;
  }
  if (id.startsWith('audio_')) {
    return Icons.graphic_eq_rounded;
  }
  if (id.startsWith('taqib_')) {
    return Icons.self_improvement_rounded;
  }
  if (id.contains('ziyarat') || id.contains('visit')) {
    return Icons.mosque_rounded;
  }
  if (id.contains('sahifa') || id.contains('sajjad')) {
    return Icons.article_rounded;
  }
  if (id.contains('daily') || id.contains('day')) {
    return Icons.today_rounded;
  }
  if (id.contains('wasaya') || id.contains('advice')) {
    return Icons.format_quote_rounded;
  }
  if (id.contains('dua')) {
    return Icons.volunteer_activism_rounded;
  }
  return Icons.auto_stories_rounded;
}

class _LibraryItemDetail extends StatefulWidget {
  const _LibraryItemDetail({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final _LibraryItem item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  State<_LibraryItemDetail> createState() => _LibraryItemDetailState();
}

class _LibraryItemDetailState extends State<_LibraryItemDetail> {
  static const int _minimumFontSize = 14;
  static const int _maximumFontSize = 36;
  static const int _defaultFontSize = 18;

  int _fontSize = _defaultFontSize;
  late bool _isFavorite;
  late final TextEditingController _readerSearchController;
  String _readerSearch = '';
  bool _taqibCompleted = false;

  bool get _isTaqibat => widget.item.id.startsWith('taqib_');
  String get _taqibProgressKey => 'taqibat_completed_${widget.item.id}';

  String? get _verifiedText => _verifiedPrayerTexts[widget.item.id];

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _readerSearchController = TextEditingController();
    _loadFontSize();
    _loadTaqibProgress();
  }

  @override
  void dispose() {
    _readerSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadTaqibProgress() async {
    if (!_isTaqibat) return;
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _taqibCompleted = preferences.getBool(_taqibProgressKey) ?? false;
    });
  }

  Future<void> _toggleTaqibProgress() async {
    final next = !_taqibCompleted;
    setState(() => _taqibCompleted = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_taqibProgressKey, next);
  }

  int _countMatches(String text, String query) {
    if (query.trim().isEmpty) return 0;
    return RegExp(RegExp.escape(query.trim()), caseSensitive: false)
        .allMatches(text)
        .length;
  }

  List<TextSpan> _highlightedSpans(String text) {
    final query = _readerSearch.trim();
    if (query.isEmpty) return [TextSpan(text: text)];
    final expression = RegExp(RegExp.escape(query), caseSensitive: false);
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in expression.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          backgroundColor: gold.withValues(alpha: 0.38),
          color: ivory,
          fontWeight: FontWeight.bold,
        ),
      ));
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return spans;
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onToggleFavorite();
  }

  Future<void> _loadFontSize() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedSize = preferences.getInt('reader_font_size') ?? _defaultFontSize;
      if (!mounted) return;
      setState(() => _fontSize = savedSize.clamp(_minimumFontSize, _maximumFontSize));
    } catch (_) {
      // Keep the reader available with its default font size.
    }
  }

  Future<void> _changeFontSize(int delta) async {
    final nextSize = (_fontSize + delta).clamp(_minimumFontSize, _maximumFontSize);
    setState(() => _fontSize = nextSize);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('reader_font_size', nextSize);
  }

  Future<void> _copyText() async {
    final text = _verifiedText;
    if (text == null || text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ النص إلى الحافظة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = _verifiedText;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: _TwilightSubpageAppBar(
          title: widget.item.title,
          actions: [
            IconButton(
              tooltip: 'تصغير الخط',
              onPressed: _fontSize > _minimumFontSize
                  ? () => _changeFontSize(-1)
                  : null,
              icon: const Icon(Icons.text_decrease_rounded),
            ),
            Center(
              child: Text(
                '$_fontSize',
                style: const TextStyle(color: ivory, fontSize: 12),
              ),
            ),
            IconButton(
              tooltip: 'تكبير الخط',
              onPressed: _fontSize < _maximumFontSize
                  ? () => _changeFontSize(1)
                  : null,
              icon: const Icon(Icons.text_increase_rounded),
            ),
            IconButton(
              tooltip: _isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: gold,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _TwilightGlassPanel(
              padding: const EdgeInsets.all(17),
              radius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TwilightGlassOrb(icon: _readerItemIcon(widget.item), size: 46),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: const TextStyle(color: gold, fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    widget.item.description,
                    style: const TextStyle(color: ivory, fontSize: 14, height: 1.8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isTaqibat) ...[
              _TwilightGlassPanel(
                padding: const EdgeInsets.all(14),
                radius: 17,
                child: Row(
                  key: const Key('taqibat_progress_card'),
                  children: [
                    Expanded(
                      child: Text(
                        _taqibCompleted
                            ? 'تم تسجيل إتمام تعقيبات هذه الصلاة على جهازك'
                            : 'تابع قراءتك واحفظ إنجازك لهذه الصلاة',
                        style: const TextStyle(color: ivory, height: 1.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      key: const Key('taqibat_progress_toggle'),
                      onPressed: _toggleTaqibProgress,
                      icon: Icon(
                        _taqibCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      label: Text(_taqibCompleted ? 'تم' : 'إتمام'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (text != null && text.trim().isNotEmpty) ...[
              _TwilightGlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                radius: 17,
                child: TextField(
                  key: const Key('reader_text_search'),
                  controller: _readerSearchController,
                  onChanged: (value) => setState(() => _readerSearch = value),
                  style: const TextStyle(color: ivory),
                  decoration: InputDecoration(
                    hintText: 'ابحث داخل هذا النص...',
                    hintStyle: const TextStyle(color: mutedIvory),
                    prefixIcon: const Icon(Icons.manage_search_rounded, color: turquoise),
                    suffixText: _readerSearch.trim().isEmpty
                        ? null
                        : 'النتائج: ${_countMatches(text, _readerSearch)}',
                    suffixStyle: const TextStyle(color: gold, fontSize: 11),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'النص',
                      style: TextStyle(
                        color: gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _copyText,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('نسخ النص'),
                    style: TextButton.styleFrom(foregroundColor: turquoise),
                  ),
                ],
              ),
              _TwilightGlassPanel(
                padding: const EdgeInsets.all(16),
                radius: 18,
                child: SelectableText.rich(
                  TextSpan(
                    style: TextStyle(
                      color: ivory,
                      height: 2.0,
                      fontSize: _fontSize.toDouble(),
                    ),
                    children: _highlightedSpans(text),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ] else
              _TwilightGlassPanel(
                padding: const EdgeInsets.all(16),
                radius: 18,
                child: const Text(
                  'النص الكامل قيد المطابقة مع المصدر، لذلك لم نعرض نصاً جزئياً أو غير متحقق منه.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ivory, height: 1.9, fontSize: 14),
                ),
              ),
            const SizedBox(height: 18),
            _TwilightGlassPanel(
              padding: const EdgeInsets.all(15),
              radius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book_rounded, color: turquoise, size: 19),
                      SizedBox(width: 8),
                      Text('بيانات المصدر', style: TextStyle(color: gold, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.source,
                    style: const TextStyle(color: ivory, height: 1.8, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NightPrayerTutorialScreen extends StatefulWidget {
  const NightPrayerTutorialScreen({super.key});

  @override
  State<NightPrayerTutorialScreen> createState() => _NightPrayerTutorialScreenState();
}

class _NightPrayerTutorialScreenState extends State<NightPrayerTutorialScreen> {
  static const String _progressKey = 'night_prayer_completed_steps';
  static const List<_NightPrayerLesson> _lessons = [
    _NightPrayerLesson(
      title: 'وقت صلاة الليل',
      summary: 'يبدأ وقتها من أول الليل، والأفضل الإتيان بها في وقت السحر قبل الفجر.',
      detail: 'وقت الأداء والتفاصيل الفقهية قد تختلف باختلاف فتوى المرجع؛ راجع مرجع تقليدك.',
    ),
    _NightPrayerLesson(
      title: 'الركعات الثماني: نافلة الليل',
      summary: 'أربع صلوات، كل صلاة ركعتان، بتشهد وتسليم بعد الركعة الثانية.',
      detail: 'تؤدّى كل ركعتين بصورة صلاة الصبح، مع نية نافلة الليل.',
    ),
    _NightPrayerLesson(
      title: 'ركعتا الشفع',
      summary: 'ركعتان مستقلتان بعد نافلة الليل، بنية الشفع.',
      detail: 'بحسب الصيغة المعروضة هنا تكون ركعتا الشفع من دون قنوت.',
    ),
    _NightPrayerLesson(
      title: 'ركعة الوتر',
      summary: 'ركعة واحدة، ويكون القنوت قبل الركوع.',
      detail: 'تتضمن هذه الصفحة عدّادات محلية لمتابعة الأذكار المستحبة.',
    ),
  ];

  Set<int> _completed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _completed = preferences.getStringList(_progressKey)?.map(int.parse).toSet() ?? {};
      _loading = false;
    });
  }

  Future<void> _toggleLesson(int index, bool checked) async {
    final next = Set<int>.from(_completed);
    if (checked) {
      next.add(index);
    } else {
      next.remove(index);
    }
    setState(() => _completed = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _progressKey,
      next.map((value) => value.toString()).toList()..sort(),
    );
  }

  Future<void> _resetProgress() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_progressKey);
    if (mounted) setState(() => _completed = {});
  }

  Widget _sectionCard({required String title, required Widget child, IconData icon = Icons.auto_awesome}) {
    return _TwilightGlassPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gold, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _instruction(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: const TextStyle(color: ivory, height: 1.85, fontSize: 13)),
  );

  @override
  Widget build(BuildContext context) {
    final progress = _completed.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: _TwilightSubpageAppBar(title: 'تعليم صلاة الليل'),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  _TwilightGlassPanel(
                    padding: const EdgeInsets.all(18),
                    radius: 20,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('صلاة الليل', style: TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          'صلاة الليل ١١ ركعة: ٨ ركعات نافلة الليل، وركعتا الشفع، وركعة الوتر.',
                          style: TextStyle(color: ivory, height: 1.9, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'توضيح: الثماني تُصلّى أربع صلوات، كل صلاة ركعتان، ثم الشفع ركعتان، ثم الوتر ركعة واحدة.',
                          style: TextStyle(color: mutedIvory, height: 1.8, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: 'أولاً: الركعات الثماني – نافلة الليل',
                    icon: Icons.nightlight_round,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _instruction('النية قبل كل صلاة من الركعتين: نويت أن أصلي نافلة الليل قربةً إلى الله تعالى، الله أكبر.'),
                        _instruction('الصلاة الأولى – الركعتان الأوليان:'),
                        _instruction('• الركعة الأولى: سورة الفاتحة وسورة الإخلاص.'),
                        _instruction('• الركعة الثانية: سورة الفاتحة وسورة الكافرون.'),
                        const Divider(color: Color(0xFF47416D)),
                        _instruction('الصلاة الثانية – الركعتان الثالثة والرابعة:'),
                        _instruction('• الركعة الأولى: الفاتحة وما تيسّر من السور.'),
                        _instruction('• الركعة الثانية: الفاتحة وما تيسّر من السور.'),
                        const Divider(color: Color(0xFF51452F)),
                        _instruction('الصلاة الثالثة – الركعتان الخامسة والسادسة:'),
                        _instruction('• الركعة الأولى: الفاتحة وما تيسّر من السور.'),
                        _instruction('• الركعة الثانية: الفاتحة وما تيسّر من السور.'),
                        const Divider(color: Color(0xFF51452F)),
                        _instruction('الصلاة الرابعة – الركعتان السابعة والثامنة:'),
                        _instruction('• الركعة الأولى: الفاتحة وما تيسّر من السور.'),
                        _instruction('• الركعة الثانية: الفاتحة وما تيسّر من السور.'),
                        _instruction('بعد كل ركعتين: الركوع والسجود، ثم التشهد والتسليم، وبعدها تقوم للصلاة التالية بالنية نفسها.'),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'ثانياً: ركعتا الشفع',
                    icon: Icons.brightness_2_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _instruction('النية: نويت أن أصلي ركعتي الشفع قربةً إلى الله تعالى، الله أكبر.'),
                        _instruction('• الركعة الأولى: الفاتحة وسورة الناس.'),
                        _instruction('• الركعة الثانية: الفاتحة وسورة الفلق.'),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF292744),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text('ملاحظة: ركعتا الشفع من دون قنوت في هذه الصيغة.', style: TextStyle(color: gold, height: 1.7)),
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'ثالثاً: ركعة الوتر',
                    icon: Icons.star_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _instruction('النية: نويت أن أصلي ركعة الوتر قربةً إلى الله تعالى، الله أكبر.'),
                        _instruction('القراءة: سورة الفاتحة، ثم سورة الإخلاص ثلاث مرات، ثم سورتا الفلق والناس.'),
                        _instruction('القنوت: ترفع يديك للدعاء، وتأتي بالأذكار المستحبة الآتية، ويمكن استخدام العدّادات لمتابعة العدد.'),
                        const SizedBox(height: 6),
                        _NightPrayerDhikrCounter(
                          key: const Key('night_counter_forty'),
                          storageKey: 'night_prayer_counter_forty',
                          title: 'اللهم اغفر لفلان ابن فلان – الدعاء لأربعين شخصاً',
                          target: 40,
                        ),
                        _NightPrayerDhikrCounter(
                          key: const Key('night_counter_istighfar'),
                          storageKey: 'night_prayer_counter_istighfar',
                          title: 'أستغفر الله ربي وأتوب إليه',
                          target: 70,
                        ),
                        _NightPrayerDhikrCounter(
                          key: const Key('night_counter_aidh'),
                          storageKey: 'night_prayer_counter_aidh',
                          title: 'هذا مقام العائذ بك من النار',
                          target: 7,
                        ),
                        _NightPrayerDhikrCounter(
                          key: const Key('night_counter_afw'),
                          storageKey: 'night_prayer_counter_afw',
                          title: 'العفو',
                          target: 300,
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'بعد إكمال الصلاة',
                    icon: Icons.favorite_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _instruction('إلى هنا تمت صلاة الليل. ويُستحب بعد إكمالها:'),
                        _instruction('❤️ تسبيح فاطمة الزهراء عليها السلام.'),
                        _instruction('❤️ دعاء الحزين.'),
                        _instruction('❤️ قراءة زيارة عاشوراء لمن أحب.'),
                        _instruction('ونسألكم الدعاء.'),
                        const Divider(color: Color(0xFF51452F)),
                        const Text(
                          'وأخيراً: نرجو نشر التطبيق بين الأهل والأصدقاء، ولكم الأجر والثواب.',
                          style: TextStyle(color: gold, height: 1.9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  _TwilightGlassPanel(
                    padding: const EdgeInsets.all(14),
                    radius: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Text('متابعة التعلّم', style: TextStyle(color: ivory, fontWeight: FontWeight.bold))),
                            Text('$progress من ${_lessons.length}', style: const TextStyle(color: gold)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        LinearProgressIndicator(
                          value: progress / _lessons.length,
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: royalBlack,
                          color: turquoise,
                        ),
                        const SizedBox(height: 10),
                        for (var index = 0; index < _lessons.length; index++)
                          Material(
                            color: royalBlack,
                            borderRadius: BorderRadius.circular(10),
                            clipBehavior: Clip.antiAlias,
                            child: CheckboxListTile(
                              key: Key('night_prayer_step_$index'),
                              value: _completed.contains(index),
                              onChanged: (value) => _toggleLesson(index, value ?? false),
                              activeColor: turquoise,
                              checkColor: royalBlack,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                _lessons[index].title,
                                style: const TextStyle(color: ivory, fontSize: 12),
                              ),
                              subtitle: Text(
                                _lessons[index].summary,
                                style: const TextStyle(color: mutedIvory, fontSize: 11, height: 1.6),
                              ),
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: progress == 0 ? null : _resetProgress,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('إعادة ضبط متابعة التعلّم'),
                          style: OutlinedButton.styleFrom(foregroundColor: gold, side: BorderSide(color: gold.withValues(alpha: 0.5))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TwilightGlassPanel(
                    padding: const EdgeInsets.all(14),
                    radius: 16,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: turquoise, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'تنبيه فقهي: هذه طريقة تعليمية معروضة وفق النص المطلوب، وقد تختلف بعض التفاصيل والأذكار والقراءات باختلاف فتوى مرجع التقليد. الأعداد المذكورة مستحبة وليست شرطاً لصحة الصلاة؛ يُرجى مراجعة مرجع التقليد في الأحكام.',
                            style: TextStyle(color: ivory, height: 1.9, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SelectableText(
                    'للمراجعة الفقهية: https://www.sistani.org/arabic/qa/0552/\nhttps://www.sistani.org/arabic/book/13/565/',
                    style: TextStyle(color: turquoise, fontSize: 11, height: 1.8),
                  ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _NightPrayerDhikrCounter extends StatefulWidget {
  const _NightPrayerDhikrCounter({
    super.key,
    required this.storageKey,
    required this.title,
    required this.target,
  });

  final String storageKey;
  final String title;
  final int target;

  @override
  State<_NightPrayerDhikrCounter> createState() => _NightPrayerDhikrCounterState();
}

class _NightPrayerDhikrCounterState extends State<_NightPrayerDhikrCounter> {
  int _count = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _count = preferences.getInt(widget.storageKey) ?? 0;
      _loading = false;
    });
  }

  Future<void> _increment() async {
    if (_count >= widget.target) return;
    final next = _count + 1;
    setState(() => _count = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(widget.storageKey, next);
  }

  Future<void> _reset() async {
    setState(() => _count = 0);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(widget.storageKey, 0);
  }

  @override
  Widget build(BuildContext context) {
    final completed = _count >= widget.target;
    return _TwilightGlassPanel(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(11),
      radius: 14,
      child: Column(
        key: ValueKey(widget.storageKey),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(color: ivory, fontSize: 12, height: 1.7, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  _loading ? 'جارٍ تحميل العداد…' : '$_count / ${widget.target}',
                  style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              IconButton(
                key: Key('${widget.storageKey}_reset'),
                tooltip: 'تصفير العداد',
                onPressed: _count == 0 ? null : _reset,
                icon: const Icon(Icons.refresh_rounded, color: mutedIvory),
              ),
              FilledButton.icon(
                key: Key('${widget.storageKey}_increment'),
                onPressed: _loading || completed ? null : _increment,
                icon: const Icon(Icons.add, size: 17),
                label: Text(completed ? 'اكتمل' : 'عدّ'),
                style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: royalBlack),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: widget.target == 0 ? 0 : (_count / widget.target).clamp(0.0, 1.0),
            backgroundColor: panelBlack,
            color: turquoise,
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

class _NightPrayerLesson {
  const _NightPrayerLesson({
    required this.title,
    required this.summary,
    required this.detail,
  });

  final String title;
  final String summary;
  final String detail;
}


String _normalizeLocalSearch(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[\\u064B-\\u065F\\u0670\\u0640]'), '')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .trim();
}

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Set<String> _favorites = {};
  bool _loading = true;
  String _query = '';

  List<_LibraryItem> get _results {
    final normalized = _normalizeLocalSearch(_query);
    if (normalized.isEmpty) return <_LibraryItem>[];
    return _libraryItems.values
        .expand((items) => items)
        .where((item) {
          final searchable = _normalizeLocalSearch([
            item.title,
            item.description,
            item.source,
            _verifiedPrayerTexts[item.id] ?? '',
          ].join(' '));
          return searchable.contains(normalized);
        })
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorites =
          preferences.getStringList('library_favorites')?.toSet() ?? {};
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(_LibraryItem item) async {
    final next = Set<String>.from(_favorites);
    if (!next.add(item.id)) next.remove(item.id);
    setState(() => _favorites = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList('library_favorites', next.toList()..sort());
  }

  Future<void> _openItem(_LibraryItem item) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('library_last_read', item.id);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LibraryItemDetail(
          item: item,
          isFavorite: _favorites.contains(item.id),
          onToggleFavorite: () => _toggleFavorite(item),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: _TwilightSubpageAppBar(title: 'البحث الشامل', showSearch: false),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: _TwilightGlassPanel(
                      padding: const EdgeInsets.all(4),
                      radius: 17,
                      child: TextField(
                      key: const Key('global_local_search'),
                      controller: _controller,
                      autofocus: true,
                      onChanged: (value) => setState(() => _query = value),
                      style: const TextStyle(color: ivory, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'ابحث في الزيارات والأدعية والتعقيبات...',
                        hintStyle: const TextStyle(color: mutedIvory),
                        prefixIcon: const Icon(Icons.search, color: gold),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'مسح البحث',
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close, color: mutedIvory),
                              ),
                        filled: true,
                        fillColor: panelBlack,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _query.trim().isEmpty
                            ? 'يبحث محلياً في عناوين النصوص ومتونها ومصادرها.'
                            : 'عدد النتائج: ${results.length}',
                        style: const TextStyle(color: mutedIvory, fontSize: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _query.trim().isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: _TwilightGlassPanel(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                                radius: 22,
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _TwilightGlassOrb(icon: Icons.manage_search_rounded, size: 58),
                                    SizedBox(height: 14),
                                    Text(
                                      'ابدأ البحث في مكتبة التطبيق',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: ivory, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'اكتب كلمة أو عبارة للبحث في محتوى التطبيق المحفوظ على جهازك.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: mutedIvory, height: 1.9, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : results.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: _TwilightGlassPanel(
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                                    radius: 20,
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.search_off_rounded, color: mutedIvory, size: 34),
                                        SizedBox(height: 12),
                                        Text(
                                          'لا توجد نتائج مطابقة',
                                          style: TextStyle(color: ivory, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'جرّب كلمة أخرى أو عبارة أقصر للبحث في المحتوى المتاح.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: mutedIvory, height: 1.8, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                                itemCount: results.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = results[index];
                                  final hasText =
                                      (_verifiedPrayerTexts[item.id] ?? '').isNotEmpty;
                                  return _TwilightGlassPanel(
                                    padding: EdgeInsets.zero,
                                    radius: 14,
                                    child: ListTile(
                                      onTap: () => _openItem(item),
                                      title: Text(
                                        item.title,
                                        style: const TextStyle(
                                          color: ivory,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          item.description,
                                          style: const TextStyle(
                                            color: mutedIvory,
                                            height: 1.6,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      trailing: Icon(
                                        hasText
                                            ? Icons.menu_book_rounded
                                            : Icons.info_outline_rounded,
                                        color: hasText ? turquoise : mutedIvory,
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}


class _TwilightSubpageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TwilightSubpageAppBar({
    required this.title,
    this.showSearch = true,
    this.actions = const [],
  });

  final String title;
  final bool showSearch;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 8,
      title: Row(
        children: [
          _TwilightGlassPanel(
            padding: const EdgeInsets.all(2),
            radius: 22,
            child: IconButton(
              tooltip: 'رجوع',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: ivory),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: ivory, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          if (showSearch) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const GlobalSearchScreen()),
                ),
                child: _TwilightGlassPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                  radius: 22,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('بحث', style: TextStyle(color: mutedIvory, fontSize: 11)),
                      SizedBox(width: 7),
                      Icon(Icons.search_rounded, color: ivory, size: 17),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: actions,
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const int _minimumFontSize = 14;
  static const int _maximumFontSize = 36;
  int _fontSize = 18;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getInt('reader_font_size') ?? 18;
      if (!mounted) return;
      setState(() {
        _fontSize = saved.clamp(_minimumFontSize, _maximumFontSize);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveFontSize(double value) async {
    final next = value.round().clamp(_minimumFontSize, _maximumFontSize);
    setState(() => _fontSize = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('reader_font_size', next);
  }

  void _openLibrary(String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LibrarySectionScreen(title: title),
      ),
    );
  }

  Widget _quickAccess({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: _TwilightGlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            radius: 16,
            child: Row(
              children: [
                _TwilightGlassOrb(icon: icon, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: ivory, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(color: mutedIvory, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: turquoise),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: _TwilightSubpageAppBar(title: 'الإعدادات'),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
                children: [
                  _TwilightGlassPanel(
                    padding: const EdgeInsets.all(16),
                    radius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.text_fields_rounded, color: gold, size: 21),
                            SizedBox(width: 9),
                            Text('حجم خط القراءة', style: TextStyle(color: ivory, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'يتحكم هذا الخيار بحجم النص داخل صفحات قراءة الزيارات والأدعية، ويُحفظ تلقائياً على جهازك.',
                          style: TextStyle(color: mutedIvory, fontSize: 12, height: 1.8),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('14', style: TextStyle(color: mutedIvory, fontSize: 11)),
                            Expanded(
                              child: _TwilightGlassPanel(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                radius: 16,
                                child: Slider(
                                  value: _fontSize.toDouble(),
                                  min: _minimumFontSize.toDouble(),
                                  max: _maximumFontSize.toDouble(),
                                  divisions: _maximumFontSize - _minimumFontSize,
                                  activeColor: turquoise,
                                  inactiveColor: twilightBorder,
                                  label: '$_fontSize',
                                  onChanged: (value) => setState(() => _fontSize = value.round()),
                                  onChangeEnd: _saveFontSize,
                                ),
                              ),
                            ),
                            const Text('36', style: TextStyle(color: mutedIvory, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Center(
                          child: Text(
                            '$_fontSize',
                            style: TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(color: twilightBorder, height: 24),
                        const Text('معاينة النص', style: TextStyle(color: mutedIvory, fontSize: 11)),
                        const SizedBox(height: 8),
                        Text(
                          'اللهم صلّ على محمد وآل محمد',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: ivory, fontSize: _fontSize.toDouble(), height: 1.8, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 9, right: 3),
                    child: Text('الوصول السريع', style: TextStyle(color: ivory, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  _quickAccess(
                    icon: Icons.bookmark_rounded,
                    title: 'المفضلة',
                    subtitle: 'النصوص التي حفظتها',
                    onTap: () => _openLibrary('المفضلة'),
                  ),
                  _quickAccess(
                    icon: Icons.history_rounded,
                    title: 'آخر قراءة',
                    subtitle: 'متابعة آخر نص فتحته',
                    onTap: () => _openLibrary('آخر قراءة'),
                  ),
                  _TwilightGlassPanel(
                    padding: const EdgeInsets.all(14),
                    radius: 16,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.phonelink_lock_rounded, color: turquoise, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'إعدادات القراءة والمفضلة محفوظة محلياً على هذا الجهاز.',
                            style: TextStyle(color: mutedIvory, fontSize: 11, height: 1.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

IconData _sectionPlaceholderIcon(String title) => switch (title) {
      'المناسبات الإسلامية' => Icons.event_available_rounded,
      'التنبيهات' => Icons.notifications_active_rounded,
      _ => Icons.auto_stories_rounded,
    };

class SectionPage extends StatelessWidget {
  const SectionPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: _TwilightSubpageAppBar(title: title),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _TwilightGlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
              radius: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x3DF1E7D0),
                        Color(0x28D8BE83),
                        Color(0x302D3152),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFD8BE83).withValues(alpha: 0.62),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD8BE83).withValues(alpha: 0.13),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Icon(
                    _sectionPlaceholderIcon(title),
                    size: 39,
                    color: const Color(0xFFE8D5A8),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    color: ivory,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'يجري تجهيز المحتوى الموثق لهذا القسم ليعمل دون إنترنت.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedIvory,
                    fontSize: 14,
                    height: 1.8,
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
