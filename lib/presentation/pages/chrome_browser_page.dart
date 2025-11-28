// presentation/pages/chrome_browser_page.dart - Chrome-like Browser Interface
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/browser_provider.dart';
import '../widgets/chrome_address_bar.dart';
import '../widgets/chrome_tab_strip.dart';
import '../widgets/web_view_container.dart';
import '../widgets/chrome_summary_panel.dart';
import '../widgets/offline_mode_indicator.dart';

class ChromeBrowserPage extends ConsumerStatefulWidget {
  const ChromeBrowserPage({super.key});

  @override
  ConsumerState<ChromeBrowserPage> createState() => _ChromeBrowserPageState();
}

class _ChromeBrowserPageState extends ConsumerState<ChromeBrowserPage>
    with TickerProviderStateMixin {
  late AnimationController _summaryController;
  bool _showSummary = false;

  @override
  void initState() {
    super.initState();
    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _toggleSummary() {
    setState(() {
      _showSummary = !_showSummary;
    });
    if (_showSummary) {
      _summaryController.forward();
    } else {
      _summaryController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF202124) : Colors.white,
        body: Column(
          children: [
            // Offline mode indicator
            const OfflineModeBanner(),
            
            // Chrome-style header with tabs and address bar
            Container(
              color: isDark ? const Color(0xFF292A2D) : const Color(0xFFF8F9FA),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tab strip
                  SizedBox(
                    height: 40,
                    child: ChromeTabStrip(
                      tabs: browserState.tabs,
                      activeTabId: browserState.activeTabId,
                      onTabSelected: (tabId) {
                        ref.read(browserProvider.notifier).switchToTab(tabId);
                      },
                      onTabClosed: (tabId) {
                        ref.read(browserProvider.notifier).closeTab(tabId);
                      },
                      onNewTab: () {
                        ref.read(browserProvider.notifier).addNewTab();
                      },
                    ),
                  ),
                  
                  // Divider between tabs and address bar
                  Container(
                    height: 1,
                    color: isDark ? const Color(0xFF3F4042) : const Color(0xFFDADCE0),
                  ),
                  
                  // Address bar
                  Container(
                    height: 56,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 600 ? 8 : 16,
                      vertical: 8,
                    ),
                    child: ChromeAddressBar(
                      url: browserState.activeTab?.url ?? '',
                      title: browserState.activeTab?.title ?? 'New Tab',
                      isLoading: browserState.activeTab?.isLoading ?? false,
                      canGoBack: browserState.canGoBack,
                      canGoForward: browserState.canGoForward,
                      onBackPressed: () => ref.read(browserProvider.notifier).goBack(),
                      onForwardPressed: () => ref.read(browserProvider.notifier).goForward(),
                      onRefreshPressed: () => ref.read(browserProvider.notifier).refreshAllTabs(),
                      onHomePressed: () => ref.read(browserProvider.notifier).loadUrl('https://google.com'),
                      onUrlSubmitted: (url) {
                        final finalUrl = url.startsWith('http') ? url : 'https://$url';
                        ref.read(browserProvider.notifier).loadUrl(finalUrl);
                      },
                      onMenuPressed: () => _showChromeMenu(context),
                    ),
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: Stack(
                children: [
                  // WebView content
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF202124) : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: const WebViewContainer(),
                  ),
                  
                  // Summary panel
                  if (_showSummary)
                    Positioned.fill(
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(_summaryController),
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 100,
                            left: screenWidth < 600 ? 8 : 16,
                            right: screenWidth < 600 ? 8 : 16,
                            bottom: 100,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF292A2D) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: const ChromeSummaryPanel(),
                        ),
                      ),
                    ),
                  
                  // Floating action button for summary
                  Positioned(
                    bottom: _showSummary ? 320 : 20,
                    right: 20,
                    child: FloatingActionButton.extended(
                      onPressed: _toggleSummary,
                      backgroundColor: const Color(0xFF4285F4),
                      icon: Icon(
                        _showSummary ? Icons.expand_less : Icons.summarize,
                        color: Colors.white,
                      ),
                      label: Text(
                        _showSummary ? 'Hide' : 'Summarize',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  void _showChromeMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF292A2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Menu items
            _buildMenuItem(
              icon: Icons.history,
              title: 'History',
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              icon: Icons.download,
              title: 'Downloads',
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              icon: Icons.bookmark,
              title: 'Bookmarks',
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black87,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
