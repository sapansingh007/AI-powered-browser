// presentation/providers/browser_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/hive_database.dart';
import '../../domain/entities/browser_tab.dart';
import '../../domain/entities/summary.dart';
import 'offline_provider.dart';
import 'summary_provider.dart';

class BrowserState {
  final List<BrowserTab> tabs;
  final BrowserTab? activeTab;
  final String? activeTabId;
  final bool isLoading;
  final bool canGoBack;
  final bool canGoForward;
  final String? currentUrl;

  BrowserState({
    required this.tabs,
    this.activeTab,
    this.activeTabId,
    this.isLoading = false,
    this.canGoBack = false,
    this.canGoForward = false,
    this.currentUrl,
  });

  BrowserState copyWith({
    List<BrowserTab>? tabs,
    BrowserTab? activeTab,
    String? activeTabId,
    bool? isLoading,
    bool? canGoBack,
    bool? canGoForward,
    String? currentUrl,
  }) {
    return BrowserState(
      tabs: tabs ?? this.tabs,
      activeTab: activeTab ?? this.activeTab,
      activeTabId: activeTabId ?? this.activeTabId,
      isLoading: isLoading ?? this.isLoading,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      currentUrl: currentUrl ?? this.currentUrl,
    );
  }
}

class BrowserNotifier extends StateNotifier<BrowserState> {
  final Ref ref; // Add Ref to access other providers

  BrowserNotifier(this.ref) : super(BrowserState(tabs: [])) {
    _loadTabsFromCache();
  }

  // Store WebView controllers for each tab
  final Map<String, dynamic> _webControllers = {};

  Future<void> _loadTabsFromCache() async {
    print('Loading tabs from cache...'); // Debug print
    // Load persisted tabs if available
    final cachedTabs = HiveDatabase.getTabs();
    if (cachedTabs.isNotEmpty) {
      final active = cachedTabs.firstWhere(
        (t) => t.isActive,
        orElse: () => cachedTabs.last,
      );
      print('Loaded ${cachedTabs.length} cached tabs'); // Debug print
      state = state.copyWith(
        tabs: cachedTabs,
        activeTab: active,
        activeTabId: active.id,
        currentUrl: active.url,
      );
    } else {
      // If no cached tabs, create an initial one
      print('No cached tabs, creating initial tab'); // Debug print
      addTab();
    }
  }

  Future<void> _persistTabs(List<BrowserTab> tabs) async {
    await HiveDatabase.saveTabs(tabs);
  }

  void registerWebController(String tabId, dynamic controller) {
    _webControllers[tabId] = controller;
  }

  void unregisterWebController(String tabId) {
    _webControllers.remove(tabId);
  }

  void updateNavigationState(String tabId, {bool? canGoBack, bool? canGoForward, String? currentUrl}) {
    // Update the tab's URL in the tabs list
    if (currentUrl != null) {
      print('Updating tab $tabId URL to: $currentUrl'); // Debug print
      
      final updatedTabs = state.tabs
          .map((tab) => tab.id == tabId ? tab.copyWith(url: currentUrl) : tab)
          .toList();

      final updatedActiveTab = state.activeTab?.id == tabId
          ? state.activeTab!.copyWith(url: currentUrl)
          : state.activeTab;

      state = state.copyWith(
        tabs: updatedTabs,
        activeTab: updatedActiveTab,
        currentUrl: currentUrl,
        canGoBack: canGoBack,
        canGoForward: canGoForward,
      );

      // Persist the updated tabs
      _persistTabs(updatedTabs);
      
      print('Tab URL updated and persisted'); // Debug print
    } else if (state.activeTab?.id == tabId) {
      // Only update navigation state if no URL change
      state = state.copyWith(
        canGoBack: canGoBack,
        canGoForward: canGoForward,
      );
    }
  }

  void addTab({String initialUrl = 'https://google.com'}) {
    print('Adding new tab with URL: $initialUrl'); // Debug print
    const uuid = Uuid();
    final newTab = BrowserTab(
      id: uuid.v4(),
      title: 'New Tab',
      url: initialUrl,
      createdAt: DateTime.now(),
      isActive: true,
    );

    // Deactivate all current tabs
    final updatedTabs = state.tabs.map((tab) => tab.copyWith(isActive: false)).toList();
    updatedTabs.add(newTab);

    print('Tab created with ID: ${newTab.id}'); // Debug print
    state = state.copyWith(
      tabs: updatedTabs,
      activeTab: newTab,
      activeTabId: newTab.id,
      currentUrl: initialUrl,
    );

    // Persist updated tabs
    _persistTabs(updatedTabs);
  }

  // Alias for addTab to maintain Chrome-like naming
  void addNewTab({String initialUrl = 'https://google.com'}) {
    addTab(initialUrl: initialUrl);
  }

  void closeTab(String tabId) {
    final updatedTabs = state.tabs.where((tab) => tab.id != tabId).toList();
    _webControllers.remove(tabId); // Remove controller

    if (updatedTabs.isEmpty) {
      addTab();
    } else {
      final newActiveTab = updatedTabs.last.copyWith(isActive: true);
      final finalTabs = updatedTabs
          .map((tab) =>
              tab.id == newActiveTab.id ? newActiveTab : tab.copyWith(isActive: false))
          .toList();

      state = state.copyWith(
        tabs: finalTabs,
        activeTab: newActiveTab,
        activeTabId: newActiveTab.id,
        currentUrl: newActiveTab.url,
      );

      // Persist after close
      _persistTabs(finalTabs);
    }
  }

  void switchToTab(String tabId) {
    final updatedTabs = state.tabs
        .map((tab) =>
            tab.id == tabId ? tab.copyWith(isActive: true) : tab.copyWith(isActive: false))
        .toList();

    final newActiveTab = updatedTabs.firstWhere((tab) => tab.id == tabId);

    state = state.copyWith(
      tabs: updatedTabs,
      activeTab: newActiveTab,
      activeTabId: tabId,
      currentUrl: newActiveTab.url,
    );

    // Persist after switch
    _persistTabs(updatedTabs);
  }

  void updateTabUrl(String tabId, String url) {
    print('Updating tab URL: $tabId -> $url'); // Debug print
    
    final updatedTabs = state.tabs
        .map((tab) => tab.id == tabId ? tab.copyWith(url: url) : tab)
        .toList();

    final updatedActiveTab = state.activeTab?.id == tabId
        ? state.activeTab!.copyWith(url: url)
        : state.activeTab;

    state = state.copyWith(
      tabs: updatedTabs,
      activeTab: updatedActiveTab,
      currentUrl: url,
    );

    // Clear previous summaries for this tab when URL changes to show fresh content
    ref.read(summaryProvider.notifier).clearSummariesForTab(tabId);

    // Cache the page for offline access
    if (updatedActiveTab != null) {
      ref.read(offlineProvider.notifier).cachePage(updatedActiveTab);
    }

    // Persist URL change
    _persistTabs(updatedTabs);
  }

  void updateTabTitle(String tabId, String title) {
    final updatedTabs = state.tabs
        .map((tab) => tab.id == tabId ? tab.copyWith(title: title) : tab)
        .toList();

    final updatedActiveTab = state.activeTab?.id == tabId
        ? state.activeTab!.copyWith(title: title)
        : state.activeTab;

    state = state.copyWith(
      tabs: updatedTabs,
      activeTab: updatedActiveTab,
    );

    // Persist title change
    _persistTabs(updatedTabs);
  }

  void goBack() {
    if (state.activeTab != null && _webControllers.containsKey(state.activeTab!.id)) {
      final controller = _webControllers[state.activeTab!.id];
      controller?.goBack();
    }
  }

  void goForward() {
    if (state.activeTab != null && _webControllers.containsKey(state.activeTab!.id)) {
      final controller = _webControllers[state.activeTab!.id];
      controller?.goForward();
    }
  }

  void refresh() {
    if (state.activeTab != null && _webControllers.containsKey(state.activeTab!.id)) {
      final controller = _webControllers[state.activeTab!.id];
      controller?.reload();
    }
  }

  void refreshAllTabs() {
    print('Refreshing all tabs'); // Debug print
    
    // Refresh all tabs that have controllers
    for (final entry in _webControllers.entries) {
      final tabId = entry.key;
      final controller = entry.value;
      
      if (controller != null) {
        print('Refreshing tab: $tabId'); // Debug print
        controller.reload();
      }
    }
    
    print('All tabs refreshed'); // Debug print
  }

  void loadUrl(String url) {
    if (state.activeTab != null) {
      updateTabUrl(state.activeTab!.id, url);
      // Load URL in the WebView controller if it exists
      if (_webControllers.containsKey(state.activeTab!.id)) {
        final controller = _webControllers[state.activeTab!.id];
        controller?.loadRequest(Uri.parse(url));
      }
    }
  }
}

final browserProvider = StateNotifierProvider<BrowserNotifier, BrowserState>((ref) {
  return BrowserNotifier(ref);
});