// presentation/pages/tabs_manager_page.dart - Tabs Management Page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/browser_provider.dart';

class TabsManagerPage extends ConsumerWidget {
  const TabsManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserState = ref.watch(browserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF202124) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF292A2D) : const Color(0xFFF8F9FA),
        title: Text(
          'Tabs Manager',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: browserState.tabs.length,
        itemBuilder: (context, index) {
          final tab = browserState.tabs[index];
          final isActive = tab.id == browserState.activeTabId;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isDark ? const Color(0xFF292A2D) : Colors.white,
            elevation: isActive ? 4 : 1,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isActive 
                    ? const Color(0xFF4285F4)
                    : (isDark ? const Color(0xFF5F6368) : Colors.grey[300]),
                child: Icon(
                  Icons.tab,
                  color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                  size: 20,
                ),
              ),
              title: Text(
                tab.title.isEmpty ? 'New Tab' : tab.title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                tab.url.isEmpty ? 'about:blank' : tab.url,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isActive)
                    IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () {
                        ref.read(browserProvider.notifier).switchToTab(tab.id);
                        Navigator.pop(context);
                      },
                      tooltip: 'Switch to Tab',
                    ),
                  if (browserState.tabs.length > 1)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () {
                        ref.read(browserProvider.notifier).closeTab(tab.id);
                      },
                      tooltip: 'Close Tab',
                    ),
                ],
              ),
              onTap: () {
                if (!isActive) {
                  ref.read(browserProvider.notifier).switchToTab(tab.id);
                  Navigator.pop(context);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(browserProvider.notifier).addNewTab();
          Navigator.pop(context);
        },
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Tab'),
      ),
    );
  }
}
