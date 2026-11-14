import 'package:material_ui/material_ui.dart';

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
        fontFamily: 'sans-serif',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_Section> sections = [
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
    _Section('التنبيهات', Icons.notifications_active_rounded),
    _Section('الإعدادات', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 19,
                        decoration: BoxDecoration(
                          color: turquoise,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'أقسام الكامل',
                        style: TextStyle(
                          color: ivory,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'كل ما تحتاجه في مكان واحد',
                        style: TextStyle(color: mutedIvory, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = sections[index];
                      return _SectionTile(
                        section: section,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SectionPage(title: section.title),
                            ),
                          );
                        },
                      );
                    },
                    childCount: sections.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 9,
                    crossAxisSpacing: 9,
                    childAspectRatio: 1.02,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text(
                      'الكامل • رفيق المعرفة والعبادة',
                      style: TextStyle(
                        color: Color(0xFF817968),
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 116,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF29251B), Color(0xFF171819), Color(0xFF102322)],
        ),
        border: Border.all(color: gold.withValues(alpha: 0.48), width: 0.8),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -18,
            top: -30,
            child: Icon(
              Icons.mosque_rounded,
              size: 150,
              color: gold.withValues(alpha: 0.07),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.23),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: gold.withValues(alpha: 0.65)),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    size: 35,
                    color: gold,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الكامل',
                        style: TextStyle(
                          color: ivory,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'رفيقك إلى المعرفة والعبادة',
                        style: TextStyle(
                          color: mutedIvory,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 76,
                        height: 2,
                        decoration: BoxDecoration(
                          color: turquoise,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.auto_awesome,
                  color: gold,
                  size: 17,
                ),
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
  });

  final _Section section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: panelBlack,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: gold.withValues(alpha: 0.27), width: 0.7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(section.icon, size: 23, color: gold),
              const SizedBox(height: 7),
              Text(
                section.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ivory,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
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
                  'القسم قيد تجهيز محتواه الموثق للعمل دون إنترنت.',
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
