import 'package:material_ui/material_ui.dart';
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
      'تعليم صلاة الليل' ||
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
    _LibraryItem(id: 'visit_ashura', title: 'زيارة عاشوراء', description: 'زيارة الإمام الحسين (عليه السلام)', source: 'المصدر والتخريج: يُستكمل بعد مراجعة النص والطبعة'),
    _LibraryItem(id: 'visit_warith', title: 'زيارة وارث', description: 'زيارة الإمام الحسين (عليه السلام)', source: 'المصدر والتخريج: يُستكمل بعد مراجعة النص والطبعة'),
    _LibraryItem(id: 'visit_amin', title: 'زيارة أمين الله', description: 'زيارة جامعة', source: 'المصدر والتخريج: يُستكمل بعد مراجعة النص والطبعة'),
    _LibraryItem(id: 'visit_jamia', title: 'الزيارة الجامعة الكبيرة', description: 'زيارة جامعة للأئمة (عليهم السلام)', source: 'المصدر والتخريج: يُستكمل بعد مراجعة النص والطبعة'),
  ],
  'الأدعية العامة': [
    _LibraryItem(id: 'dua_kumayl', title: 'دعاء كميل', description: 'من الأدعية المشهورة في ليالي الجمعة', source: 'مفتاح الجنان؛ يلزم تثبيت بيانات الطبعة والموضع'),
    _LibraryItem(id: 'dua_tawassul', title: 'دعاء التوسل', description: 'التوسل إلى الله تعالى', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'dua_ahd', title: 'دعاء العهد', description: 'دعاء العهد', source: 'مفتاح الجنان؛ يلزم تثبيت بيانات الطبعة والموضع'),
    _LibraryItem(id: 'dua_iftitah', title: 'دعاء الافتتاح', description: 'من أدعية شهر رمضان', source: 'مفتاح الجنان؛ يلزم تثبيت بيانات الطبعة والموضع'),
    _LibraryItem(id: 'dua_nudba', title: 'دعاء الندبة', description: 'دعاء الندبة', source: 'مفتاح الجنان؛ يلزم تثبيت بيانات الطبعة والموضع'),
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
    _LibraryItem(id: 'taqib_fajr', title: 'تعقيبات صلاة الفجر', description: 'الأذكار والأعمال بعد صلاة الفجر', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'taqib_dhuhr', title: 'تعقيبات الظهر', description: 'الأذكار والأعمال بعد صلاة الظهر', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'taqib_asr', title: 'تعقيبات العصر', description: 'الأذكار والأعمال بعد صلاة العصر', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'taqib_maghrib', title: 'تعقيبات المغرب', description: 'الأذكار والأعمال بعد صلاة المغرب', source: 'المصدر والتخريج قيد المراجعة'),
    _LibraryItem(id: 'taqib_isha', title: 'تعقيبات العشاء', description: 'الأذكار والأعمال بعد صلاة العشاء', source: 'المصدر والتخريج قيد المراجعة'),
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

class _LibraryItemDetail extends StatelessWidget {
  const _LibraryItemDetail({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final _LibraryItem item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: royalBlack,
        appBar: AppBar(
          title: Text(item.title),
          backgroundColor: panelBlack,
          foregroundColor: gold,
          actions: [
            IconButton(
              tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
              onPressed: onToggleFavorite,
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: gold,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              item.title,
              style: const TextStyle(
                color: gold,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: const TextStyle(color: ivory, fontSize: 15),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panelBlack,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gold.withValues(alpha: 0.35)),
              ),
              child: const Text(
                'هذا مدخل في فهرس المكتبة. لم يُدرج النص الكامل هنا بعد؛ لن نعرض نصاً دينياً غير مطابق للمصدر. ستضاف المادة بعد مراجعة النص والتخريج وبيانات الطبعة.',
                style: TextStyle(
                  color: mutedIvory,
                  height: 1.9,
                  fontSize: 14,
                ),
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
              item.source,
              style: const TextStyle(color: ivory, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
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
