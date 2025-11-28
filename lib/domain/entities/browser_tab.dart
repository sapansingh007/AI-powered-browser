// domain/entities/browser_tab.dart
class BrowserTab {
  final String id;
  final String title;
  final String url;
  final DateTime createdAt;
  final bool isActive;
  final bool isLoading;

  BrowserTab({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    this.isActive = false,
    this.isLoading = false,
  });

  BrowserTab copyWith({
    String? id,
    String? title,
    String? url,
    DateTime? createdAt,
    bool? isActive,
    bool? isLoading,
  }) {
    return BrowserTab(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}