// presentation/widgets/tab_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/browser_tab.dart';
import '../providers/browser_provider.dart';

/*
class TabBar extends ConsumerWidget {
  const TabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserState = ref.watch(browserProvider);
    final tabs = browserState.tabs;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return TabItem(
            tab: tab,
            isActive: tab.isActive,
            onTap: () => ref.read(browserProvider.notifier).switchToTab(tab.id),
            onClose: () => ref.read(browserProvider.notifier).closeTab(tab.id),
          );
        },
      ),
    );
  }
}
*/

class BrowserTabsBar extends ConsumerWidget {
  const BrowserTabsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserState = ref.watch(browserProvider);
    final tabs = browserState.tabs;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return TabItem(
            tab: tab,
            isActive: tab.isActive,
            onTap: () => ref.read(browserProvider.notifier).switchToTab(tab.id),
            onClose: () => ref.read(browserProvider.notifier).closeTab(tab.id),
          );
        },
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final BrowserTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const TabItem({
    super.key,
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tab.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}