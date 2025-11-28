// presentation/widgets/browser_tab_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/browser_provider.dart';
import 'web_view_container.dart';

class BrowserTabView extends ConsumerWidget {
  const BrowserTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserState = ref.watch(browserProvider);
    final activeTab = browserState.activeTab;

    return Column(
      children: [
        // WebView Content
        Expanded(
          child: activeTab != null
              ? const WebViewContainer()
              : const Center(child: Text('No active tab')),
        ),
      ],
    );
  }
}