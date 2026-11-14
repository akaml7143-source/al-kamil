import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlKamilApp());
}

const Color navy = Color(0xFF172554);
const Color gold = Color(0xFFD6B66A);
const Color cream = Color(0xFFF7F4EC);

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
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
          secondary: gold,
          surface: cream,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  static const pages = <Widget>[
    HomePage(),
    LibraryPage(),
    PrayerPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: pages[selectedIndex]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'المكتبة',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_time_outlined),
              selectedIcon: Icon(Icons.access_time_filled),
              label: 'الصلاة',
            ),
            NavigationDestination(
              icon: Icon(Icons.apps_outlined),
              selectedIcon: Icon(Icons.apps),
              label: 'المزيد',
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const sections = [
    _Section('القرآن الكريم', Icons.menu_book, 'القرآن الكريم'),
    _Section('مواقيت الصلاة', Icons.mosque, 'مواقيت الصلاة'),
    _Section('الأدعية والزيارات', Icons.auto_awesome, 'الأدعية والزيارات'),
    _Section('الصحيفة السجادية', Icons.library_books, 'الصحيفة السجادية'),
    _Section('نهج البلاغة', Icons.account_balance, 'نهج البلاغة'),
    _Section('وصايا أهل البيت', Icons.volunteer_activism, 'وصايا أهل البيت'),
    _Section('المناسبات الإسلامية', Icons.calendar_month, 'المناسبات الإسلامية'),
    _Section('القبلة والتسبيح', Icons.explore, 'القبلة والتسبيح'),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 170,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('الكامل'),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [navy, Color(0xFF334B78)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.mosque, size: 76, color: gold),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
            child: Text(
              'رفيقك إلى المعرفة والعبادة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: navy,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(14),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = sections[index];
                return Card(
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE9DFC7)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SectionPage(title: section.title),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(section.icon, size: 34, color: navy),
                          const SizedBox(height: 12),
                          Text(
                            section.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: sections.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.12,
            ),
          ),
        ),
      ],
    );
  }
}

class _Section {
  const _Section(this.label, this.icon, this.title);
  final String label;
  final IconData icon;
  final String title;
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) => const SectionPage(
        title: 'المكتبة الإسلامية',
        description: 'تجتمع هنا أقسام القرآن والأدعية والزيارات والكتب.',
      );
}

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) => const SectionPage(
        title: 'مواقيت الصلاة',
        description:
            'سيُضاف حساب المواقيت حسب الدولة والمدينة وطريقة الحساب المختارة. لن نعرض أوقاتاً تقديرية على أنها مواقيت دقيقة.',
      );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) => const SectionPage(
        title: 'المزيد',
        description: 'الإعدادات والمعلومات والأدوات الإضافية للتطبيق.',
      );
}

class SectionPage extends StatelessWidget {
  const SectionPage({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 48, color: gold),
              const SizedBox(height: 18),
              Text(
                description ?? 'هذا القسم قيد التجهيز وإضافة المحتوى الموثق.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, height: 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
