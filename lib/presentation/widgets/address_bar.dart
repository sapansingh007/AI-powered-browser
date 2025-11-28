/*
// presentation/widgets/address_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/browser_provider.dart';
import 'web_view_container.dart';

class AddressBar extends ConsumerStatefulWidget {
  const AddressBar({
    super.key,
    this.navigationController,
  });

  final WebViewNavigationController? navigationController;

  @override
  ConsumerState<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends ConsumerState<AddressBar> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Listen to active tab changes
    */
/*
    ref.listen(browserProvider, (previous, next) {
      if (next.activeTab != null && next.activeTab!.url != _urlController.text) {
        _urlController.text = next.activeTab!.url;
      }
    });
    *//*

    ref.listen<BrowserState>(browserProvider, (previous, next) {
      final newUrl = next.activeTab?.url;
      if (newUrl != null && newUrl != _urlController.text) {
        _urlController.text = newUrl;
      }
    });
  }

  void _navigateToUrl() {
    final url = _urlController.text;
    if (url.isNotEmpty) {
      final formattedUrl = _formatUrl(url);
      final activeTab = ref.read(browserProvider).activeTab;
      if (activeTab != null) {
        ref.read(browserProvider.notifier).updateTabUrl(
          activeTab.id,
          formattedUrl,
        );
      }
      _focusNode.unfocus();
    }
  }

  String _formatUrl(String input) {
    if (input.contains('.') && !input.startsWith('http')) {
      return 'https://$input';
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Navigation buttons
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Implement back navigation
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // Implement forward navigation
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Implement refresh
            },
          ),

          // URL bar
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _urlController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search or enter website name',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _navigateToUrl(),
              ),
            ),
          ),

          // New tab button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ref.read(browserProvider.notifier).addTab();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}*/
// presentation/widgets/address_bar.dart - CORRECTED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/browser_provider.dart';

class AddressBar extends ConsumerStatefulWidget {
  const AddressBar({super.key});

  @override
  ConsumerState<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends ConsumerState<AddressBar> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _currentActiveUrl = '';

  @override
  void initState() {
    super.initState();

    // Initialize with current active tab URL
    final activeTab = ref.read(browserProvider).activeTab;
    if (activeTab != null) {
      _urlController.text = activeTab.url;
      _currentActiveUrl = activeTab.url;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final formattedUrl = _formatUrl(url);
    final activeTab = ref.read(browserProvider).activeTab;

    if (activeTab != null) {
      ref.read(browserProvider.notifier).updateTabUrl(
        activeTab.id,
        formattedUrl,
      );
      _currentActiveUrl = formattedUrl;
    }
    _focusNode.unfocus();
  }

  String _formatUrl(String input) {
    if (input.contains('.') && !input.startsWith('http')) {
      return 'https://$input';
    }

    // Add https if no protocol specified
    if (!input.startsWith('http')) {
      return 'https://$input';
    }

    return input;
  }

  @override
  Widget build(BuildContext context) {
    // Watch for active tab changes and update URL controller
    final activeTab = ref.watch(browserProvider).activeTab;
    final activeTabUrl = activeTab?.url ?? '';

    // Update controller if active tab URL changed and we're not currently editing
    if (activeTabUrl != _currentActiveUrl && !_focusNode.hasFocus) {
      _urlController.text = activeTabUrl;
      _currentActiveUrl = activeTabUrl;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Navigation buttons
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // TODO: Hook into WebView navigation controller
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // TODO: Hook into WebView navigation controller
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Hook into WebView navigation controller
            },
          ),

          // URL bar
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _urlController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search or enter website name',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _navigateToUrl(),
                onTap: () {
                  // Select all text when tapped
                  _urlController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _urlController.text.length,
                  );
                },
              ),
            ),
          ),

          // New tab button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ref.read(browserProvider.notifier).addTab();
            },
          ),
        ],
      ),
    );
  }
}