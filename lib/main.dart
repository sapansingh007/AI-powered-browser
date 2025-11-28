// main.dart - Chrome-like AI Browser & Summarizer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/local/hive_database.dart';
import 'presentation/pages/chrome_browser_page.dart';
import 'presentation/pages/files_page.dart';
import 'presentation/pages/tabs_manager_page.dart';
import 'presentation/pages/settings_page.dart';
import 'core/themes/app_theme.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Continue without .env if file doesn't exist
    print('No .env file found, using default values');
  }

  await Hive.initFlutter();

  try {
    await HiveDatabase.init();
  } catch (e) {
    // Continue without persistence if storage fails
  }

  runApp(const ProviderScope(child: ChromeBrowserApp()));
}

class ChromeBrowserApp extends ConsumerWidget {
  const ChromeBrowserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'AI Chrome Browser',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const ChromeMainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChromeMainPage extends ConsumerStatefulWidget {
  const ChromeMainPage({super.key});

  @override
  ConsumerState<ChromeMainPage> createState() => _ChromeMainPageState();
}

class _ChromeMainPageState extends ConsumerState<ChromeMainPage> 
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  final List<Widget> _pages = [
    const ChromeBrowserPage(),
    const FilesPage(),
    const TabsManagerPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }



  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF202124) : const Color(0xFFF8F9FA),
        body: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF292A2D) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore),
                selectedIcon: Icon(Icons.explore),
                label: 'Browser',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder),
                selectedIcon: Icon(Icons.folder),
                label: 'Files',
              ),
              NavigationDestination(
                icon: Icon(Icons.tab),
                selectedIcon: Icon(Icons.tab),
                label: 'Tabs',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Theme provider is now centralized in core/providers/theme_provider.dart