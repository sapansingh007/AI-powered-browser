// presentation/widgets/chrome_summary_panel.dart - Chrome-style Summary Panel
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/summary_provider.dart';
import '../providers/browser_provider.dart';
import '../providers/offline_provider.dart';
import '../widgets/web_view_container.dart';
import '../../data/datasources/ai_api_datasource.dart';
import '../../core/themes/app_theme.dart';

class ChromeSummaryPanel extends ConsumerStatefulWidget {
  const ChromeSummaryPanel({super.key});

  @override
  ConsumerState<ChromeSummaryPanel> createState() => _ChromeSummaryPanelState();
}

class _ChromeSummaryPanelState extends ConsumerState<ChromeSummaryPanel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _selectedLanguage = 'en';
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(summaryProvider);
    final browserState = ref.watch(browserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth < 900;
    
    // Get summaries for the active tab
    final activeTabId = browserState.activeTab?.id;
    print('Chrome Summary Panel - Active Tab ID: $activeTabId'); // Debug print
    print('Chrome Summary Panel - All summaries: ${summaryState.summaries.keys}'); // Debug print
    
    final tabSummaries = summaryState.getSummariesForTab(activeTabId);
    print('Chrome Summary Panel - Tab summaries count: ${tabSummaries.length}'); // Debug print
    
    final latestSummary = tabSummaries.isNotEmpty ? tabSummaries.last : null;
    print('Chrome Summary Panel - Latest summary: ${latestSummary?.id}'); // Debug print

    // Responsive padding and margins
    final horizontalPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 24.0);
    final verticalPadding = isSmallScreen ? 8.0 : 12.0;
    final contentMaxWidth = isSmallScreen ? double.infinity : (isMediumScreen ? 700.0 : 800.0);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8, // Max 80% of screen height
          ),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isSmallScreen ? 12.0 : 16.0),
              topRight: Radius.circular(isSmallScreen ? 12.0 : 16.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: verticalPadding),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Summary',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 18 : 20,
                            ),
                          ),
                          if (browserState.activeTab != null)
                            Text(
                              browserState.activeTab!.title.length > 30
                                  ? '${browserState.activeTab!.title.substring(0, 30)}...'
                                  : browserState.activeTab!.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (summaryState.isSummarizing)
                      SizedBox(
                        width: isSmallScreen ? 16 : 20,
                        height: isSmallScreen ? 16 : 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                          ),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: isDark ? Colors.white : Colors.black87,
                          size: isSmallScreen ? 20 : 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: isSmallScreen ? 32 : 40,
                          minHeight: isSmallScreen ? 32 : 40,
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              if (_isExpanded) ...[
                const Divider(height: 1),
                // Scrollable content area
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.5, // Max 50% of screen height for content
                    ),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: contentMaxWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(horizontalPadding),
                          child: latestSummary != null 
                            ? _buildSummaryContent(latestSummary!, theme, isDark, isSmallScreen)
                            : _buildEmptyState(theme, isDark, isSmallScreen),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent(summary, ThemeData theme, bool isDark, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary text
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF202124) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
              width: 0.5,
            ),
          ),
          child: Text(
            summary.summarizedText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              height: 1.5,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        // Translation section
        _buildTranslationSection(summary, theme, isDark, isSmallScreen),
        SizedBox(height: isSmallScreen ? 12 : 16),

        // Action buttons
        _buildActionButtons(summary, theme, isDark, isSmallScreen),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
      child: Column(
        children: [
          Icon(
            Icons.summarize_outlined,
            size: isSmallScreen ? 40 : 48,
            color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'No Summary Available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'Navigate to a webpage and click the summarize button to generate an AI-powered summary.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          ElevatedButton.icon(
            onPressed: () => _generateSummary(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Summary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20, 
                vertical: isSmallScreen ? 10 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationSection(summary, ThemeData theme, bool isDark, bool isSmallScreen) {
    final summaryState = ref.watch(summaryProvider);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202124) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate,
                color: const Color(0xFF4285F4),
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Translation',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
              const Spacer(),
              if (summary.translatedText != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8, 
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: isSmallScreen ? 10 : 12,
                        color: Colors.green,
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Text(
                        'Translated',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 10 : 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          Row(
            children: [
              Text(
                'Translate to:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF303134) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
                      width: 0.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                        DropdownMenuItem(value: 'fr', child: Text('Français')),
                        DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                        DropdownMenuItem(value: 'zh', child: Text('中文')),
                        DropdownMenuItem(value: 'ja', child: Text('日本語')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              ElevatedButton(
                onPressed: summaryState.isTranslating ? null : () => _translateSummary(summary.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16, 
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: summaryState.isTranslating
                    ? SizedBox(
                        width: isSmallScreen ? 12 : 16,
                        height: isSmallScreen ? 12 : 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Translate',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
              ),
            ],
          ),

          if (summary.translatedText != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4285F4).withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Text(
                summary.translatedText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(summary, ThemeData theme, bool isDark, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _copyToClipboard(summary.summarizedText),
            icon: Icon(Icons.copy, size: isSmallScreen ? 16 : 18),
            label: Text('Copy', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black87,
              side: BorderSide(
                color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareSummary(summary.summarizedText),
            icon: Icon(Icons.share, size: isSmallScreen ? 16 : 18),
            label: Text('Share', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black87,
              side: BorderSide(
                color: isDark ? const Color(0xFF5F6368) : const Color(0xFFDADCE0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _generateSummary() async {
    final browserState = ref.read(browserProvider);
    if (browserState.activeTab != null) {
      // Get the active tab ID
      final activeTabId = browserState.activeTab!.id;
      
      try {
        // Show loading state
        setState(() {
          _isExpanded = true; // Expand panel to show loading
        });

        // Extract actual page content from WebView
        final pageContent = await WebViewContainer.extractCurrentPageContent();
        
        if (pageContent.isNotEmpty && 
            pageContent != 'No content found on this page.' &&
            pageContent != 'Failed to extract page content. The page might not support content extraction.') {
          
          // Create a better prompt for the AI
          final currentPageUrl = browserState.activeTab!.url;
          final pageTitle = browserState.activeTab?.title ?? 'Unknown Page';
          
          // Enhanced prompt for better summaries
          final enhancedPrompt = """
Please provide a comprehensive and intelligent summary of the following web content:

**Page Title:** $pageTitle
**Source URL:** $currentPageUrl

**Content to Summarize:**
$pageContent

**Instructions:**
1. Create a concise but comprehensive summary (2-3 paragraphs)
2. Extract the main key points and insights
3. Identify the most important information
4. Maintain accuracy and avoid hallucination
5. Use clear, professional language
6. If the content is news, include key facts and context
7. If it's educational, highlight main concepts
8. If it's technical, explain in accessible terms

**Format your response as:**
**Summary:** [Your 2-3 paragraph summary here]

**Key Points:**
• [Key point 1]
• [Key point 2] 
• [Key point 3]
• [Key point 4]

**Content Type:** [News/Article/Blog/Educational/Technical/Other]
""";

          // Use the enhanced prompt for summarization
          ref.read(summaryProvider.notifier).summarizeText(
            text: enhancedPrompt,
            source: currentPageUrl,
            sourceType: 'webpage',
            tabId: activeTabId, // Pass the active tab ID
          );
          
          // Cache the latest summary for offline access
          Future.delayed(const Duration(seconds: 2), () async {
            final summaryState = ref.read(summaryProvider);
            final tabSummaries = summaryState.getSummariesForTab(activeTabId);
            final latestSummary = tabSummaries.isNotEmpty ? tabSummaries.last : null;
            
            if (latestSummary != null) {
              ref.read(offlineProvider.notifier).cacheSummary(latestSummary);
            }
          });
          
        } else {
          // Fallback for content extraction failure
          ref.read(summaryProvider.notifier).summarizeText(
            text: "**Page Information:**\n"
                "- Title: ${browserState.activeTab?.title ?? 'Unknown'}\n"
                "- URL: ${browserState.activeTab!.url}\n\n"
                "**Status:** Unable to extract meaningful content from this page. This might be because:\n"
                "- The page is a login page or requires authentication\n"
                "- The page is heavily JavaScript-based\n"
                "- The page has minimal text content\n"
                "- The page blocks content extraction\n\n"
                "**Recommendation:** Try navigating to a content-rich page like a news article, blog post, or documentation page for better summarization results.",
            source: browserState.activeTab!.url,
            sourceType: 'webpage',
            tabId: activeTabId, // Pass the active tab ID
          );
          
          // Cache the latest summary for offline access
          Future.delayed(const Duration(seconds: 2), () async {
            final summaryState = ref.read(summaryProvider);
            final tabSummaries = summaryState.getSummariesForTab(activeTabId);
            final latestSummary = tabSummaries.isNotEmpty ? tabSummaries.last : null;
            
            if (latestSummary != null) {
              ref.read(offlineProvider.notifier).cacheSummary(latestSummary);
            }
          });
        }
      } catch (e) {
        print('Error generating summary: $e');
        // Show helpful error message
        ref.read(summaryProvider.notifier).summarizeText(
          text: "**Summary Generation Failed**\n\n"
              "**Error:** Unable to process this page content.\n\n"
              "**Possible Reasons:**\n"
              "- The page is still loading\n"
              "- The page blocks content extraction\n"
              "- Network connectivity issues\n"
              "- The page contains no readable text\n\n"
              "**Suggestions:**\n"
              "1. Wait for the page to fully load\n"
              "2. Try refreshing the page\n"
              "3. Navigate to a different page with more content\n"
              "4. Check your internet connection\n\n"
              "**Current Page:** ${browserState.activeTab!.url}",
          source: browserState.activeTab!.url,
          sourceType: 'webpage',
          tabId: activeTabId, // Pass the active tab ID
        );
      }
    }
  }

  void _translateSummary(String summaryId) {
    print('Chrome Summary Panel: Starting translation for summary: $summaryId'); // Debug print
    print('Chrome Summary Panel: Selected language: $_selectedLanguage'); // Debug print
    
    final translationService = TranslationService();
    ref.read(summaryProvider.notifier).translateSummary(
      summaryId,
      _selectedLanguage,
      translationService,
    );
    
    print('Chrome Summary Panel: Translation method called'); // Debug print
  }

  void _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Summary copied to clipboard!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy: $e'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareSummary(String text) {
    // Implement share functionality
  }
}
