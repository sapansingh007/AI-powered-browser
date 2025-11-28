// data/local/hive_database.dart
import 'package:hive/hive.dart';
import '../../domain/entities/browser_tab.dart';
import '../../domain/entities/downloaded_file.dart';
import '../../domain/entities/summary.dart';

class HiveDatabase {
  // static late Box<Map<dynamic, dynamic>> _tabsBox;
  // static late Box<Map<dynamic, dynamic>> _filesBox;
  // static late Box<Map<dynamic, dynamic>> _summariesBox;
  // static late Box<Map<dynamic, dynamic>> _settingsBox;
  static late Box<List<dynamic>> _tabsBox;
  static late Box<List<dynamic>> _filesBox;
  static late Box<List<dynamic>> _summariesBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    // _tabsBox = await Hive.openBox('browser_tabs');
    // _filesBox = await Hive.openBox('downloaded_files');
    // _summariesBox = await Hive.openBox('summaries_cache');
    // _settingsBox = await Hive.openBox('app_settings');
    _tabsBox = await Hive.openBox<List<dynamic>>('browser_tabs');
    _filesBox = await Hive.openBox<List<dynamic>>('downloaded_files');
    _summariesBox = await Hive.openBox<List<dynamic>>('summaries_cache');
    _settingsBox = await Hive.openBox<dynamic>('app_settings');
  }

  // Tabs Management
  static Future<void> saveTabs(List<BrowserTab> tabs) async {
    final data = tabs.map((tab) => _tabToMap(tab)).toList();
    await _tabsBox.put('current_tabs', data);
  }

  static List<BrowserTab> getTabs() {
    final data = _tabsBox.get('current_tabs', defaultValue: <dynamic>[]);
    final tabList = data ?? <dynamic>[];
    return tabList.map((item) => _tabFromMap(Map<dynamic, dynamic>.from(item))).toList();
  }

  static Map<String, dynamic> _tabToMap(BrowserTab tab) {
    return {
      'id': tab.id,
      'title': tab.title,
      'url': tab.url,
      'createdAt': tab.createdAt.millisecondsSinceEpoch,
      'isActive': tab.isActive,
    };
  }

  static BrowserTab _tabFromMap(Map<dynamic, dynamic> map) {
    return BrowserTab(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isActive: map['isActive'] ?? false,
    );
  }

  // Files Management
  static Future<void> saveFile(DownloadedFile file) async {
    final files = getFiles();
    files.add(file);
    final data = files.map(_fileToMap).toList();
    await _filesBox.put('downloaded_files', data);
  }

  static List<DownloadedFile> getFiles() {
    final data = _filesBox.get('downloaded_files', defaultValue: <dynamic>[]);
    final filesList = data ?? <dynamic>[];
    return filesList.map((item) => _fileFromMap(Map<dynamic, dynamic>.from(item))).toList();
  }

  static Map<String, dynamic> _fileToMap(DownloadedFile file) {
    return {
      'id': file.id,
      'name': file.name,
      'path': file.path,
      'type': file.type,
      'size': file.size,
      'downloadedAt': file.downloadedAt.millisecondsSinceEpoch,
    };
  }

  static DownloadedFile _fileFromMap(Map<dynamic, dynamic> map) {
    return DownloadedFile(
      id: map['id'],
      name: map['name'],
      path: map['path'],
      type: map['type'],
      size: map['size'],
      downloadedAt: DateTime.fromMillisecondsSinceEpoch(map['downloadedAt']),
    );
  }

  static Map<String, dynamic> _summaryToMap(Summary summary) {
    return {
      'id': summary.id,
      'originalText': summary.originalText,
      'summarizedText': summary.summarizedText,
      'translatedText': summary.translatedText,
      'source': summary.source,
      'sourceType': summary.sourceType,
      'tabId': summary.tabId, // ✅ Add tabId field
      'createdAt': summary.createdAt.millisecondsSinceEpoch,
      'originalWordCount': summary.originalWordCount,
      'summarizedWordCount': summary.summarizedWordCount,
    };
  }

  static Summary _summaryFromMap(Map<dynamic, dynamic> map) {
    return Summary(
      id: map['id'],
      originalText: map['originalText'],
      summarizedText: map['summarizedText'],
      translatedText: map['translatedText'],
      source: map['source'],
      sourceType: map['sourceType'],
      tabId: map['tabId'], // ✅ Add tabId field
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      originalWordCount: map['originalWordCount'],
      summarizedWordCount: map['summarizedWordCount'],
    );
  }

  static Future<void> replaceAllFiles(List<DownloadedFile> files) async {
    final data = files.map(_fileToMap).toList();
    await _filesBox.put('downloaded_files', data);
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    final value = _settingsBox.get(key, defaultValue: defaultValue);
    return value as T?;
  }

  // Offline Mode Methods
  static Future<void> cachePage(BrowserTab page) async {
    print('Caching page to Hive: ${page.url}'); // Debug print
    final cachedPages = await getCachedPages();
    
    // Remove existing page with same URL if exists
    cachedPages.removeWhere((p) => p.url == page.url);
    
    // Add new page
    cachedPages.add(page);
    
    // Save to cache
    final data = cachedPages.map(_tabToMap).toList();
    await _tabsBox.put('cached_pages', data);
    
    print('Page cached successfully'); // Debug print
  }

  static Future<List<BrowserTab>> getCachedPages() async {
    try {
      final data = _tabsBox.get('cached_pages', defaultValue: <dynamic>[]);
      return data!.map((item) => _tabFromMap(item as Map<dynamic, dynamic>)).toList();
    } catch (e) {
      print('Error getting cached pages: $e'); // Debug print
      return [];
    }
  }

  static Future<void> cacheSummary(Summary summary) async {
    print('Caching summary to Hive: ${summary.id}'); // Debug print
    final cachedSummaries = await getCachedSummaries();
    
    // Remove existing summary with same ID if exists
    cachedSummaries.removeWhere((s) => s.id == summary.id);
    
    // Add new summary
    cachedSummaries.add(summary);
    
    // Save to cache
    final data = cachedSummaries.map(_summaryToMap).toList();
    await _summariesBox.put('cached_summaries', data);
    
    print('Summary cached successfully'); // Debug print
  }

  static Future<List<Summary>> getCachedSummaries() async {
    try {
      final data = _summariesBox.get('cached_summaries', defaultValue: <dynamic>[]);
      return data!.map((item) => _summaryFromMap(item as Map<dynamic, dynamic>)).toList();
    } catch (e) {
      print('Error getting cached summaries: $e'); // Debug print
      return [];
    }
  }

  static Future<void> clearCache() async {
    print('Clearing all cache data'); // Debug print
    
    try {
      await _tabsBox.delete('cached_pages');
      await _summariesBox.delete('cached_summaries');
      print('Cache cleared successfully'); // Debug print
    } catch (e) {
      print('Error clearing cache: $e'); // Debug print
      rethrow;
    }
  }
}