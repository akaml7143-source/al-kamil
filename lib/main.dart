import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlKamilApp());
}

const Color royalBlack = Color(0xFF101112);
const Color panelBlack = Color(0xFF1B1D1F);
const Color gold = Color(0xFFD8B66A);
const Color turquoise = Color(0xFF55C5BC);
const Color ivory = Color(0xFFF5F0E5);
const Color mutedIvory = Color(0xFFC9C2B5);

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
          seedColor: gold,
          brightness: Brightness.dark,
          primary: gold,
          secondary: turquoise,
          surface: panelBlack,
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
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_Section> _sections = [
    _Section('القرآن الكريم', Icons.menu_book_rounded),
    _Section('مواقيت الصلاة', Icons.access_time_rounded),
    _Section('الزيارات', Icons.account_balance_rounded),
    _Section('الأدعية العامة', Icons.volunteer_activism_rounded),
    _Section('أدعية الأيام', Icons.calendar_today_rounded),
    _Section('تعليم صلاة الليل', Icons.nightlight_round),
    _Section('تعقيبات الصلوات', Icons.auto_awesome_rounded),
    _Section('المسبحة الإلكترونية', Icons.radio_button_checked_rounded),
    _Section('الصحيفة السجادية', Icons.menu_book_outlined),
    _Section('نهج البلاغة', Icons.library_books_rounded),
    _Section('وصايا أهل البيت', Icons.diversity_3_rounded),
    _Section('المناسبات الإسلامية', Icons.event_available_rounded),
    _Section('القبلة', Icons.explore_rounded),
    _Section('الصوتيات', Icons.headphones_rounded),
    _Section('المفضلة', Icons.bookmark_rounded),
    _Section('آخر قراءة', Icons.history_rounded),
    _Section('التنبيهات', Icons.notifications_active_rounded),
    _Section('الإعدادات', Icons.settings_rounded),
  ];

  void _openSection(BuildContext context, _Section section) {
    final Widget page = switch (section.title) {
      'القرآن الكريم' => const QuranScreen(),
      'تعليم صلاة الليل' => const NightPrayerTutorialScreen(),
      'المسبحة الإلكترونية' => const TasbeehScreen(),
      'المفضلة' => const LibrarySectionScreen(title: 'المفضلة'),
      'آخر قراءة' => const LibrarySectionScreen(title: 'آخر قراءة'),
      'الزيارات' ||
      'الأدعية العامة' ||
      'أدعية الأيام' ||
      'تعقيبات الصلوات' ||
      'الصحيفة السجادية' ||
      'نهج البلاغة' ||
      'وصايا أهل البيت' ||
      'الصوتيات' => LibrarySectionScreen(title: section.title),
      _ => SectionPage(title: section.title),
    };
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 680;
              final headerHeight = compact ? 88.0 : 102.0;
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 5),
                child: Column(
                  children: [
                    _ShrineHeader(height: headerHeight),
                    SizedBox(height: compact ? 7 : 10),
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 17,
                          decoration: BoxDecoration(
                            color: turquoise,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'أقسام الكامل',
                          style: TextStyle(
                            color: ivory,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'رفيق المعرفة والعبادة',
                          style: TextStyle(color: mutedIvory, fontSize: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sections.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: compact ? 5 : 7,
                          childAspectRatio: compact ? 1.16 : 1.04,
                        ),
                        itemBuilder: (context, index) {
                          final section = _sections[index];
                          return _SectionTile(
                            section: section,
                            compact: compact,
                            onTap: () => _openSection(context, section),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'الكامل • محتوى إسلامي في مكان واحد',
                      style: TextStyle(
                        color: Color(0xFF817968),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShrineHeader extends StatelessWidget {
  const _ShrineHeader({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF40331D), Color(0xFF171819), Color(0xFF102322)],
        ),
        border: Border.all(color: gold.withValues(alpha: 0.62), width: 0.9),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 2,
            bottom: -26,
            child: Icon(
              Icons.mosque_rounded,
              size: height + 54,
              color: gold.withValues(alpha: 0.11),
            ),
          ),
          Positioned(
            left: 25,
            top: 8,
            child: Icon(
              Icons.auto_awesome,
              size: 17,
              color: gold.withValues(alpha: 0.75),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: height - 18,
                  height: height - 18,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.26),
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withValues(alpha: 0.72)),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    size: 38,
                    color: gold,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الكامل',
                        style: TextStyle(
                          color: ivory,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'على نهج أمير المؤمنين (عليه السلام)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: mutedIvory, fontSize: 10),
                      ),
                      SizedBox(height: 7),
                      SizedBox(
                        width: 82,
                        child: Divider(
                          color: turquoise,
                          thickness: 2,
                          height: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.auto_awesome, color: gold, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
    return Material(
      color: panelBlack,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: gold.withValues(alpha: 0.30), width: 0.7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(section.icon, size: compact ? 18 : 20, color: gold),
              SizedBox(height: compact ? 3 : 5),
              Text(
                section.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ivory,
                  fontSize: compact ? 8.5 : 9.2,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
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
  bool _fontsReady = false;
  bool _fontError = false;

  @override
  void initState() {
    super.initState();
    _loadQuranFonts();
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
        appBar: AppBar(
          backgroundColor: royalBlack,
          foregroundColor: gold,
          centerTitle: true,
          title: const Text(
            'القرآن الكريم',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: royalBlack,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        setState(() => _currentPage = page + 1);
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
            Container(
              color: royalBlack,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
        appBar: AppBar(
          title: const Text('المسبحة الإلكترونية'),
          backgroundColor: panelBlack,
          foregroundColor: gold,
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: panelBlack,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: gold.withValues(alpha: 0.45),
                          ),
                        ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: panelBlack,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: gold.withValues(alpha: 0.35),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedId,
                            isExpanded: true,
                            dropdownColor: panelBlack,
                            style: const TextStyle(
                              color: ivory,
                              fontSize: 15,
                            ),
                            items: _options
                                .map(
                                  (option) => DropdownMenuItem<String>(
                                    value: option.id,
                                    child: Text(option.title),
                                  ),
                                )
                                .toList(),
                            onChanged: _selectDhikr,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _selected.description,
                        style: const TextStyle(
                          color: mutedIvory,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 236,
                        height: 236,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: panelBlack,
                          border: Border.all(color: gold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withValues(alpha: 0.10),
                              blurRadius: 24,
                              spreadRadius: 3,
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
                      const SizedBox(height: 22),
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
  'taqib_fajr': '''${_commonTaqibatText}

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
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: panelBlack,
          foregroundColor: gold,
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      style: const TextStyle(color: ivory),
                      decoration: InputDecoration(
                        hintText: 'ابحث في هذا القسم...',
                        hintStyle: const TextStyle(color: mutedIvory),
                        prefixIcon: const Icon(Icons.search, color: gold),
                        filled: true,
                        fillColor: panelBlack,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                widget.title == 'المفضلة'
                                    ? 'لم تضف عناصر إلى المفضلة بعد.'
                                    : widget.title == 'آخر قراءة'
                                        ? 'سيظهر هنا آخر عنصر فتحته من المكتبة.'
                                        : 'لا توجد نتائج مطابقة.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: mutedIvory,
                                  height: 1.8,
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
                              return Card(
                                color: panelBlack,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: gold.withValues(alpha: 0.24),
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () => _openItem(item),
                                  leading: const Icon(
                                    Icons.menu_book_rounded,
                                    color: gold,
                                  ),
                                  title: Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: ivory,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.description,
                                    style: const TextStyle(
                                      color: mutedIvory,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    tooltip: favorite
                                        ? 'إزالة من المفضلة'
                                        : 'إضافة إلى المفضلة',
                                    onPressed: () => _toggleFavorite(item),
                                    icon: Icon(
                                      favorite
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: gold,
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
        appBar: AppBar(
          title: Text(widget.item.title),
          backgroundColor: panelBlack,
          foregroundColor: gold,
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
            Text(
              widget.item.title,
              style: const TextStyle(
                color: gold,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.description,
              style: const TextStyle(color: ivory, fontSize: 15),
            ),
            const SizedBox(height: 20),
            if (_isTaqibat) ...[
              Container(
                key: const Key('taqibat_progress_card'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: panelBlack,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: turquoise.withValues(alpha: 0.45)),
                ),
                child: Row(
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
              TextField(
                key: const Key('reader_text_search'),
                controller: _readerSearchController,
                onChanged: (value) => setState(() => _readerSearch = value),
                style: const TextStyle(color: ivory),
                decoration: InputDecoration(
                  hintText: 'ابحث داخل هذا النص...',
                  hintStyle: const TextStyle(color: mutedIvory),
                  prefixIcon: const Icon(Icons.manage_search, color: turquoise),
                  suffixText: _readerSearch.trim().isEmpty
                      ? null
                      : 'النتائج: ${_countMatches(text, _readerSearch)}',
                  suffixStyle: const TextStyle(color: gold, fontSize: 11),
                  filled: true,
                  fillColor: panelBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelBlack,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: gold.withValues(alpha: 0.35)),
                ),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelBlack,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: turquoise.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'النص الكامل قيد المطابقة مع المصدر، لذلك لم نعرض نصاً جزئياً أو غير متحقق منه.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ivory, height: 1.9, fontSize: 14),
                ),
              ),
            const SizedBox(height: 18),
            const Text(
              'بيانات المصدر',
              style: TextStyle(
                color: gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.source,
              style: const TextStyle(color: ivory, height: 1.8),
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
      summary: 'يبدأ وقتها من أول الليل، والأفضل بعد منتصف الليل، وكلما اقترب السحر من الفجر كان أفضل.',
      detail: 'إذا فاتك أفضل الوقت فلا تجعل ذلك سبباً لترك النافلة؛ راجع أحكام مرجع التقليد في وقتها عند الحاجة.',
    ),
    _NightPrayerLesson(
      title: 'الركعات الثماني: نافلة الليل',
      summary: 'صلِّ أربع صلوات، كل صلاة ركعتان، بتشهد وتسليم بعد الركعة الثانية.',
      detail: 'تكون النية نافلة الليل. تؤدّى كل ركعتين بصورة صلاة الصبح من حيث الركوع والسجود والتشهد والتسليم. ويجوز في النافلة الاكتفاء بقراءة الحمد وفق المصدر الفقهي المذكور.',
    ),
    _NightPrayerLesson(
      title: 'ركعتا الشفع',
      summary: 'بعد الركعات الثماني، صلِّ ركعتين بنية الشفع، ثم التشهد والتسليم.',
      detail: 'في هذا العرض وفق استفتاءات مكتب السيد السيستاني: لا قنوت في الشفع. تفاصيل القراءة والأحكام تُراجع في الرسالة العملية.',
    ),
    _NightPrayerLesson(
      title: 'ركعة الوتر',
      summary: 'صلِّ ركعة واحدة بنية الوتر، ثم أتمّ الركوع والسجود والتشهد والتسليم.',
      detail: 'يُستحب القنوت قبل الركوع. لا يشترط ذكر خاص للقنوت، ويجوز الدعاء بما تيسّر.',
    ),
    _NightPrayerLesson(
      title: 'مستحبات قنوت الوتر',
      summary: 'من المستحبات: الدعاء لأربعين مؤمناً، والاستغفار للنفس سبعين مرة، وقول «هذا مقام العائذ بك من النار» سبع مرات، ثم «العفو» ثلاثمائة مرة.',
      detail: 'هذه الأعداد مستحبة وليست شرطاً لصحة الصلاة، ولا يلزم ترك الوتر إذا لم تستطع الإتيان بها كلها. يمكنك الدعاء بما تيسّر.',
    ),
    _NightPrayerLesson(
      title: 'التخفيف عند ضيق الوقت',
      summary: 'يجوز الاقتصار على الشفع والوتر، بل على الوتر وحدها وفق الاستفتاء المذكور.',
      detail: 'لا تجعل عدم القدرة على أداء الركعات كلها سبباً لترك ما تستطيع. راجع فتوى مرجعك في التفاصيل.',
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
      _completed =
          preferences.getStringList(_progressKey)?.map(int.parse).toSet() ?? {};
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

  @override
  Widget build(BuildContext context) {
    final progress = _completed.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: AppBar(
          title: const Text('تعليم صلاة الليل'),
          backgroundColor: panelBlack,
          foregroundColor: gold,
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B301D), panelBlack],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      border: Border.all(color: gold.withValues(alpha: 0.55)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صلاة الليل',
                          style: TextStyle(
                            color: gold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'الصورة المشهورة: ١١ ركعة؛ ثمانٍ نافلة الليل، ثم ركعتا الشفع، ثم ركعة الوتر.',
                          style: TextStyle(color: ivory, height: 1.9),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: panelBlack,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: turquoise.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'متابعة التعلّم',
                                style: TextStyle(
                                  color: ivory,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '$progress من \${_lessons.length}',
                              style: const TextStyle(color: gold),
                            ),
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
                        const SizedBox(height: 5),
                        const Text(
                          'علّم الدرس بعد قراءته؛ هذا سجل تعلّم محلي على جهازك فقط.',
                          style: TextStyle(color: mutedIvory, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var index = 0; index < _lessons.length; index++)
                    Card(
                      key: ValueKey('night_prayer_lesson_$index'),
                      color: panelBlack,
                      margin: const EdgeInsets.only(bottom: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: gold.withValues(alpha: 0.22)),
                      ),
                      child: ExpansionTile(
                        iconColor: gold,
                        collapsedIconColor: turquoise,
                        title: Text(
                          _lessons[index].title,
                          style: const TextStyle(
                            color: ivory,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _lessons[index].summary,
                          style: const TextStyle(
                            color: mutedIvory,
                            height: 1.7,
                            fontSize: 12,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _lessons[index].detail,
                              style: const TextStyle(
                                color: ivory,
                                height: 1.9,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            key: Key('night_prayer_step_$index'),
                            value: _completed.contains(index),
                            onChanged: (value) =>
                                _toggleLesson(index, value ?? false),
                            activeColor: turquoise,
                            checkColor: royalBlack,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'تمت قراءة هذا الدرس',
                              style: TextStyle(color: turquoise, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: progress == 0 ? null : _resetProgress,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('إعادة ضبط متابعة التعلّم'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: BorderSide(color: gold.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29251D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'تنبيه فقهي: هذا الدرس يعرض مثالاً تعليمياً وفق الاستفتاءات المنشورة في موقع مكتب السيد علي السيستاني، وليس حكماً موحّداً لجميع المراجع. ينبغي للمكلّف الرجوع إلى مرجع تقليده في التفاصيل.',
                      style: TextStyle(color: ivory, height: 1.9, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'المصدر: موقع مكتب السيد السيستاني، استفتاء «صلاة الليل» وكتاب «المسائل المنتخبة»، أحكام النوافل اليومية.',
                    style: TextStyle(color: mutedIvory, height: 1.8, fontSize: 11),
                  ),
                  const SelectableText(
                    'https://www.sistani.org/arabic/qa/0552/\\nhttps://www.sistani.org/arabic/book/13/565/',
                    style: TextStyle(color: turquoise, fontSize: 11, height: 1.8),
                  ),
                ],
              ),
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

class SectionPage extends StatelessWidget {
  const SectionPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: panelBlack,
          foregroundColor: ivory,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 34, color: gold),
                const SizedBox(height: 16),
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
    );
  }
}
