// presentation/providers/summary_provider.dart - UPDATED
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/ai_api_datasource.dart';
import '../../data/local/hive_database.dart';
import '../../domain/entities/summary.dart';

class SummaryState {
  final Map<String, List<Summary>> summaries; // Map of tabId to summaries
  final bool isSummarizing;
  final bool isTranslating;
  final String? error;

  const SummaryState({
    this.summaries = const {},
    this.isSummarizing = false,
    this.isTranslating = false,
    this.error,
  });

  SummaryState copyWith({
    Map<String, List<Summary>>? summaries,
    bool? isSummarizing,
    bool? isTranslating,
    String? error,
  }) {
    return SummaryState(
      summaries: summaries ?? this.summaries,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      isTranslating: isTranslating ?? this.isTranslating,
      error: error ?? this.error,
    );
  }

  // Get summaries for a specific tab
  List<Summary> getSummariesForTab(String? tabId) {
    if (tabId == null) return [];
    return summaries[tabId] ?? [];
  }
}

class SummaryNotifier extends StateNotifier<SummaryState> {
  final AIDataSource aiDataSource;

  SummaryNotifier({required this.aiDataSource}) : super(const SummaryState()) {
    _loadCachedSummaries();
  }

  Future<void> _loadCachedSummaries() async {
    final cached = HiveDatabase.getCachedSummaries();
  
    // Organize summaries by tabId
    final Map<String, List<Summary>> summariesByTab = {};
    for (final summary in await cached) {
      final tabId = summary.tabId ?? 'global'; // Use 'global' for summaries without tabId
      if (!summariesByTab.containsKey(tabId)) {
        summariesByTab[tabId] = [];
      }
      summariesByTab[tabId]!.add(summary);
    }
  
    state = state.copyWith(summaries: summariesByTab);
  }

  Future<void> summarizeText({
    required String text,
    required String source,
    required String sourceType,
    String? tabId,
  }) async {
    // Check cache first for this specific tab
    final cachedSummary = _findCachedSummary(text, source, tabId);
    if (cachedSummary != null) {
      state = state.copyWith(
        summaries: {
          ...state.summaries,
          tabId!: [cachedSummary, ...(state.summaries[tabId] ?? [])],
        },
      );
      return;
    }

    state = state.copyWith(isSummarizing: true, error: null);

    try {
      final summarizedText = await aiDataSource.summarizeText(text);

      const uuid = Uuid();
      final summary = Summary(
        id: uuid.v4(),
        originalText: text,
        summarizedText: summarizedText,
        source: source,
        sourceType: sourceType,
        tabId: tabId,
        createdAt: DateTime.now(),
        originalWordCount: text.split(' ').length,
        summarizedWordCount: summarizedText.split(' ').length,
      );

      // Add to state and cache
      state = state.copyWith(
        summaries: {
          ...state.summaries,
          tabId!: [summary, ...(state.summaries[tabId] ?? [])],
        },
        isSummarizing: false,
      );

      await HiveDatabase.cacheSummary(summary);
    } catch (e) {
      state = state.copyWith(
        isSummarizing: false,
        error: 'Failed to summarize: ${e.toString()}',
      );
    }
  }

  Future<void> translateSummary(String summaryId, String targetLanguage, TranslationService translationService) async {
    print('Starting translation for summary: $summaryId to language: $targetLanguage'); // Debug print
    
    // Reset any previous translation state
    resetTranslationState();
    
    state = state.copyWith(isTranslating: true, error: null);

    try {
      // Find the summary across all tabs
      Summary? targetSummary;
      String? targetTabId;
      
      for (final entry in state.summaries.entries) {
        try {
          final found = entry.value.firstWhere((s) => s.id == summaryId);
          targetSummary = found;
          targetTabId = entry.key;
          print('Found summary in tab: $targetTabId'); // Debug print
          break;
        } catch (e) {
          // Summary not found in this tab, continue searching
          continue;
        }
      }
      
      if (targetSummary == null) {
        throw Exception('Summary not found');
      }

      print('Translating text: ${targetSummary.summarizedText}'); // Debug print

      final translatedText = await translationService.translateText(
        targetSummary.summarizedText,
        targetLanguage,
      );

      print('Translation completed: $translatedText'); // Debug print

      final updatedSummary = targetSummary.copyWith(translatedText: translatedText);
      
      print('Created updated summary with translation'); // Debug print
      
      // Update the summary in the correct tab
      final newSummaries = Map<String, List<Summary>>.from(state.summaries);
      if (targetTabId != null) {
        print('Updating summary in tab: $targetTabId'); // Debug print
        newSummaries[targetTabId] = newSummaries[targetTabId]!.map((s) => 
          s.id == summaryId ? updatedSummary : s
        ).toList();
        print('Summary updated in tab summaries list'); // Debug print
      }

      print('Updating state with translated summary'); // Debug print
      state = state.copyWith(
        summaries: newSummaries,
        isTranslating: false,
        error: null, // Clear any previous error
      );
      
      print('Translation state updated successfully'); // Debug print
      print('New translated text: ${updatedSummary.translatedText}'); // Debug print
    } catch (e) {
      print('Translation error: $e'); // Debug print
      state = state.copyWith(
        isTranslating: false,
        error: 'Failed to translate: $e',
      );
    }
  }

  Summary? _findCachedSummary(String text, String source, String? tabId) {
    // Simple cache check - in production, use proper hashing
    final snippet = text.length > 50 ? text.substring(0, 50) : text;
    final tabSummaries = state.summaries[tabId ?? 'global'] ?? [];
    
    try {
      return tabSummaries.firstWhere(
        (s) => s.source == source && s.originalText.contains(snippet),
      );
    } catch (_) {
      return null;
    }
  }

  void clearSummaries() {
    state = state.copyWith(summaries: {}, error: null);
  }

  void clearSummariesForTab(String? tabId) {
    if (tabId == null) return;
    final newSummaries = Map<String, List<Summary>>.from(state.summaries);
    newSummaries.remove(tabId);
    state = state.copyWith(summaries: newSummaries, error: null);
  }

  void resetTranslationState() {
    print('Resetting translation state'); // Debug print
    state = state.copyWith(isTranslating: false, error: null);
    print('Translation state reset completed'); // Debug print
  }
}

// Update provider initialization
final aiDataSourceProvider = Provider<AIDataSource>((ref) {
  // return AIDataSource(apiKey: 'your-openai-api-key-here');
  return AIDataSource(apiKey: AppConstants.defaultAiApiKey);
});

final summaryProvider =
    StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  final aiDataSource = ref.watch(aiDataSourceProvider);
  return SummaryNotifier(aiDataSource: aiDataSource);
});
