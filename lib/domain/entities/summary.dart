// domain/entities/summary.dart
class Summary {
  final String id;
  final String originalText;
  final String summarizedText;
  final String? translatedText;
  final String source;
  final String sourceType; // 'webpage' or 'document'
  final String? tabId; // Track which tab this summary belongs to
  final DateTime createdAt;
  final int originalWordCount;
  final int summarizedWordCount;

  Summary({
    required this.id,
    required this.originalText,
    required this.summarizedText,
    this.translatedText,
    required this.source,
    required this.sourceType,
    this.tabId, // Optional tab ID
    required this.createdAt,
    required this.originalWordCount,
    required this.summarizedWordCount,
  });

  Summary copyWith({
    String? id,
    String? originalText,
    String? summarizedText,
    String? translatedText,
    String? source,
    String? sourceType,
    String? tabId,
    DateTime? createdAt,
    int? originalWordCount,
    int? summarizedWordCount,
  }) {
    return Summary(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      summarizedText: summarizedText ?? this.summarizedText,
      translatedText: translatedText ?? this.translatedText,
      source: source ?? this.source,
      sourceType: sourceType ?? this.sourceType,
      tabId: tabId ?? this.tabId,
      createdAt: createdAt ?? this.createdAt,
      originalWordCount: originalWordCount ?? this.originalWordCount,
      summarizedWordCount: summarizedWordCount ?? this.summarizedWordCount,
    );
  }
}