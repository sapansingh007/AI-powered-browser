// presentation/providers/offline_provider.dart - Offline Mode Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/local/hive_database.dart';
import '../../domain/entities/summary.dart';
import '../../domain/entities/browser_tab.dart';

class OfflineState {
  final bool isOnline;
  final bool isOfflineMode;
  final List<BrowserTab> cachedPages;
  final List<Summary> cachedSummaries;
  final String? error;

  const OfflineState({
    this.isOnline = true,
    this.isOfflineMode = false,
    this.cachedPages = const [],
    this.cachedSummaries = const [],
    this.error,
  });

  OfflineState copyWith({
    bool? isOnline,
    bool? isOfflineMode,
    List<BrowserTab>? cachedPages,
    List<Summary>? cachedSummaries,
    String? error,
  }) {
    return OfflineState(
      isOnline: isOnline ?? this.isOnline,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      cachedPages: cachedPages ?? this.cachedPages,
      cachedSummaries: cachedSummaries ?? this.cachedSummaries,
      error: error,
    );
  }

  // ✅ ADDED: shouldUseOfflineMode getter
  bool get shouldUseOfflineMode {
    return !isOnline || isOfflineMode;
  }
}

class OfflineNotifier extends StateNotifier<OfflineState> {
  OfflineNotifier() : super(const OfflineState()) {
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    await _checkConnectivity();
    
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      // Check if any connection is available (not none)
      final isOnline = connectivityResults.any((result) => result != ConnectivityResult.none);
      
      print('Connectivity check: $isOnline'); // Debug print
      
      state = state.copyWith(isOnline: isOnline);
      
      if (isOnline) {
        // We're back online, disable offline mode
        state = state.copyWith(isOfflineMode: false, error: null);
      }
    } catch (e) {
      print('Connectivity check error: $e'); // Debug print
      state = state.copyWith(error: 'Failed to check connectivity: $e');
    }
  }

  void enableOfflineMode() {
    print('Enabling offline mode'); // Debug print
    state = state.copyWith(isOfflineMode: true);
    _loadCachedData();
  }

  void disableOfflineMode() {
    print('Disabling offline mode'); // Debug print
    state = state.copyWith(isOfflineMode: false);
  }

  Future<void> _loadCachedData() async {
    try {
      print('Loading cached data for offline mode'); // Debug print
      
      // Load cached pages
      final cachedPages = await HiveDatabase.getCachedPages();
      
      // Load cached summaries
      final cachedSummaries = await HiveDatabase.getCachedSummaries();
      
      print('Loaded ${cachedPages.length} cached pages'); // Debug print
      print('Loaded ${cachedSummaries.length} cached summaries'); // Debug print
      
      state = state.copyWith(
        cachedPages: cachedPages,
        cachedSummaries: cachedSummaries,
      );
    } catch (e) {
      print('Error loading cached data: $e'); // Debug print
      state = state.copyWith(error: 'Failed to load cached data: $e');
    }
  }

  Future<void> cachePage(BrowserTab page) async {
    try {
      print('Caching page: ${page.title}'); // Debug print
      await HiveDatabase.cachePage(page);
      
      // Update cached pages list
      final updatedCachedPages = List<BrowserTab>.from(state.cachedPages);
      
      // Remove existing page with same URL if exists
      updatedCachedPages.removeWhere((p) => p.url == page.url);
      
      // Add new page
      updatedCachedPages.add(page);
      
      state = state.copyWith(cachedPages: updatedCachedPages);
      print('Page cached successfully'); // Debug print
    } catch (e) {
      print('Error caching page: $e'); // Debug print
      state = state.copyWith(error: 'Failed to cache page: $e');
    }
  }

  Future<void> cacheSummary(Summary summary) async {
    try {
      print('Caching summary: ${summary.id}'); // Debug print
      await HiveDatabase.cacheSummary(summary);
      
      // Update cached summaries list
      final updatedCachedSummaries = List<Summary>.from(state.cachedSummaries);
      
      // Remove existing summary with same ID if exists
      updatedCachedSummaries.removeWhere((s) => s.id == summary.id);
      
      // Add new summary
      updatedCachedSummaries.add(summary);
      
      state = state.copyWith(cachedSummaries: updatedCachedSummaries);
      print('Summary cached successfully'); // Debug print
    } catch (e) {
      print('Error caching summary: $e'); // Debug print
      state = state.copyWith(error: 'Failed to cache summary: $e');
    }
  }

  List<BrowserTab> getCachedPages() {
    return state.cachedPages;
  }

  List<Summary> getCachedSummaries() {
    return state.cachedSummaries;
  }

  bool get shouldUseOfflineMode {
    return !state.isOnline || state.isOfflineMode;
  }

  Future<void> clearCache() async {
    try {
      print('Clearing offline cache'); // Debug print
      await HiveDatabase.clearCache();
      
      state = state.copyWith(
        cachedPages: [],
        cachedSummaries: [],
        error: null,
      );
      
      print('Cache cleared successfully'); // Debug print
    } catch (e) {
      print('Error clearing cache: $e'); // Debug print
      state = state.copyWith(error: 'Failed to clear cache: $e');
    }
  }
}

// Provider
final offlineProvider = StateNotifierProvider<OfflineNotifier, OfflineState>((ref) {
  return OfflineNotifier();
});
