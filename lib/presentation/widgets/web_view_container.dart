// presentation/widgets/web_view_container.dart - Chrome WebView Container
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/browser_provider.dart';
import '../providers/download_provider.dart';
import '../../core/themes/app_theme.dart';

class WebViewContainer extends ConsumerStatefulWidget {
  const WebViewContainer({super.key});

  // Static reference to the current instance for content extraction
  static _WebViewContainerState? _currentState;

  static Future<String> extractCurrentPageContent() async {
    if (_currentState != null) {
      return await _currentState!.extractPageContent();
    }
    return 'No active WebView found.';
  }

  @override
  ConsumerState<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends ConsumerState<WebViewContainer> {
  final Map<String, WebViewController> _controllers = {};
  bool _isLoading = true;
  String? _currentUrl;
  String? _lastActiveTabId;

  @override
  void initState() {
    super.initState();
    WebViewContainer._currentState = this;
  }

  @override
  void dispose() {
    WebViewContainer._currentState = null;
    
    // Unregister all controllers from browser provider
    for (final tabId in _controllers.keys) {
      ref.read(browserProvider.notifier).unregisterWebController(tabId);
    }
    
    super.dispose();
  }

  WebViewController _getOrCreateController(String tabId) {
    if (!_controllers.containsKey(tabId)) {
      print('Creating new WebView controller for tab: $tabId'); // Debug print
      _controllers[tabId] = _createController(tabId);
    }
    return _controllers[tabId]!;
  }

  WebViewController _createController(String tabId) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false) // Disable zoom for better UX
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              final browserState = ref.read(browserProvider);
              // Only update state for the active tab
              if (browserState.activeTab?.id == tabId) {
                setState(() {
                  _isLoading = true;
                  _currentUrl = url;
                });
              }
              print('Page started for tab $tabId: $url'); // Debug print
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              final browserState = ref.read(browserProvider);
              // Only update state for the active tab
              if (browserState.activeTab?.id == tabId) {
                setState(() {
                  _isLoading = false;
                  _currentUrl = url;
                });
              }
              print('Page finished for tab $tabId: $url'); // Debug print
              
              // Update browser state and tab URL
              _controllers[tabId]!.canGoBack().then((canGoBack) {
                _controllers[tabId]!.canGoForward().then((canGoForward) {
                  if (browserState.activeTab != null) {
                    // Update navigation state and tab URL
                    ref.read(browserProvider.notifier).updateNavigationState(
                      tabId,
                      canGoBack: canGoBack,
                      canGoForward: canGoForward,
                      currentUrl: url,
                    );
                    
                    print('Updated tab $tabId URL to: $url'); // Debug print
                  }
                });
              });

              // Update tab title
              _controllers[tabId]!.getTitle().then((title) {
                if (title != null && browserState.activeTab != null) {
                  ref.read(browserProvider.notifier).updateTabTitle(
                    browserState.activeTab!.id,
                    title.isEmpty ? 'New Tab' : title,
                  );
                }
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              final browserState = ref.read(browserProvider);
              // Only update state for the active tab
              if (browserState.activeTab?.id == tabId) {
                setState(() {
                  _isLoading = false;
                });
              }
              print('WebView error for tab $tabId: ${error.description}'); // Debug print
            }
          },
          // Handle navigation decisions for downloads
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            final uri = Uri.parse(url);
            
            // Check if this is a downloadable file
            if (_isDownloadableFile(url)) {
              if (mounted) {
                _showDownloadDialog(url, _getFileNameFromUrl(url));
              }
              return NavigationDecision.prevent; // Prevent navigation
            }
            
            return NavigationDecision.navigate; // Allow navigation
          },
        ),
      );
  }

  bool _isDownloadableFile(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    
    // Check for common file extensions
    final downloadableExtensions = [
      '.pdf', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx',
      '.txt', '.zip', '.rar', '.7z', '.tar', '.gz',
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg',
      '.mp3', '.wav', '.flac', '.aac', '.ogg',
      '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv',
      '.exe', '.dmg', '.pkg', '.deb', '.rpm', '.apk',
      '.csv', '.json', '.xml', '.yaml', '.yml'
    ];
    
    // Check if path ends with a downloadable extension
    for (final ext in downloadableExtensions) {
      if (path.endsWith(ext)) {
        return true;
      }
    }
    
    // Check for common download patterns in URL
    if (url.toLowerCase().contains('download') || 
        url.toLowerCase().contains('attachment') ||
        url.toLowerCase().contains('file=')) {
      return true;
    }
    
    // Check content disposition (would need to be handled via JavaScript)
    // For now, just check if the URL has query parameters suggesting a download
    if (uri.queryParameters.containsKey('download') ||
        uri.queryParameters.containsKey('attachment')) {
      return true;
    }
    
    return false;
  }

  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    String fileName = '';
    
    // Try to get filename from path
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      fileName = pathSegments.last;
    }
    
    // Try to get filename from query parameters
    final downloadParam = uri.queryParameters['download'];
    final filenameParam = uri.queryParameters['filename'];
    final fileParam = uri.queryParameters['file'];
    
    if (filenameParam != null && filenameParam.isNotEmpty) {
      fileName = filenameParam;
    } else if (downloadParam != null && downloadParam.isNotEmpty) {
      fileName = downloadParam;
    } else if (fileParam != null && fileParam.isNotEmpty) {
      fileName = fileParam;
    }
    
    // If no filename found, generate one
    if (fileName.isEmpty) {
      fileName = 'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    // Ensure filename has an extension
    if (!fileName.contains('.') && uri.path.contains('.')) {
      final ext = uri.path.split('.').last;
      fileName += '.$ext';
    }
    
    return fileName;
  }

  void _showDownloadDialog(String url, String fileName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkElevated : AppTheme.lightElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.download_rounded,
                  color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Download File',
                style: TextStyle(
                  color: isDark ? const Color(0xFFE8EAED) : const Color(0xFF202124),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do you want to download this file?',
                style: TextStyle(
                  color: isDark ? const Color(0xFF9AA0A6) : const Color(0xFF5F6368),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          color: isDark ? const Color(0xFF5F6368) : const Color(0xFF9AA0A6),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            Uri.parse(url).host,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF5F6368) : const Color(0xFF9AA0A6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F3F2F) : const Color(0xFFF0F9F4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF34A853) : const Color(0xFF34A853).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security_rounded,
                      color: const Color(0xFF34A853),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Files are scanned for security before download',
                        style: TextStyle(
                          color: const Color(0xFF34A853),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF4285F4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Start download
                ref.read(downloadProvider.notifier).downloadFile(url, fileName);
                
                // Show download started notification
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.download_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text('Download started...'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF34A853),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Download',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _loadUrl(String url) {
    if (Uri.tryParse(url) != null && url != _currentUrl && _lastActiveTabId != null) {
      final controller = _controllers[_lastActiveTabId];
      if (controller != null) {
        print('Loading URL: $url (current: $_currentUrl) for tab: $_lastActiveTabId'); // Debug print
        controller.loadRequest(Uri.parse(url));
        setState(() {
          _currentUrl = url;
        });
      } else {
        print('No controller found for tab: $_lastActiveTabId'); // Debug print
      }
    } else {
      print('URL already loaded or invalid: $url'); // Debug print
    }
  }

  // Listen for URL changes from browser provider
  void _onBrowserStateChanged() {
    final browserState = ref.read(browserProvider);
    if (browserState.activeTab != null && 
        browserState.activeTab!.id == _lastActiveTabId &&
        browserState.activeTab!.url != _currentUrl) {
      // Same tab but URL changed (e.g., from address bar)
      _loadUrl(browserState.activeTab!.url);
    }
  }

  // Extract page content for AI summarization
  Future<String> extractPageContent() async {
    try {
      // Check if WebView is ready and has content
      if (_currentUrl == null || _isLoading || _lastActiveTabId == null) {
        return 'Page is still loading. Please wait for the page to fully load before summarizing.';
      }

      final controller = _controllers[_lastActiveTabId];
      if (controller == null) {
        return 'No active WebView controller found.';
      }

      // Use JavaScript to extract the main content from the page
      final result = await controller.runJavaScriptReturningResult("""
        (function() {
          try {
            // Intelligent content extraction for better summaries
            function extractMainContent() {
              // Remove unwanted elements first
              const unwantedSelectors = [
                'script', 'style', 'nav', 'header', 'footer', 
                'aside', '.sidebar', '.menu', '.navigation',
                '.ads', '.advertisement', '.social-media',
                '.comments', '.related', '.popup'
              ];
              
              unwantedSelectors.forEach(selector => {
                try {
                  const elements = document.querySelectorAll(selector);
                  elements.forEach(el => el.remove());
                } catch (e) {
                  // Ignore errors in element removal
                }
              });
              
              // Try to find the main content area
              const contentSelectors = [
                'article', 'main', '[role="main"]', '.content', 
                '.post-content', '.entry-content', '.article-content',
                '.story-body', '.post-body', '.news-content',
                '.blog-content', '.text-content', '.main-content'
              ];
              
              let bestContent = '';
              let maxLength = 0;
              
              // Find the content area with the most text
              contentSelectors.forEach(selector => {
                try {
                  const elements = document.querySelectorAll(selector);
                  elements.forEach(element => {
                    const text = element.innerText || element.textContent || '';
                    if (text.length > maxLength && text.length > 200) {
                      maxLength = text.length;
                      bestContent = text;
                    }
                  });
                } catch (e) {
                  // Ignore errors in content selection
                }
              });
              
              // If no good content found, try paragraphs
              if (bestContent.length < 200) {
                try {
                  const paragraphs = document.querySelectorAll('p');
                  let paragraphText = '';
                  paragraphs.forEach(p => {
                    const text = p.innerText || p.textContent || '';
                    if (text.length > 50) {
                      paragraphText += text + '\\n\\n';
                    }
                  });
                  bestContent = paragraphText;
                } catch (e) {
                  // Ignore errors in paragraph extraction
                }
              }
              
              // Final fallback - all body text
              if (bestContent.length < 100) {
                try {
                  bestContent = document.body.innerText || document.body.textContent || '';
                } catch (e) {
                  return 'Unable to extract content from this page.';
                }
              }
              
              // Clean and format the content
              bestContent = bestContent
                .replace(/\\s+/g, ' ')                    // Multiple spaces to single
                .replace(/\\n+/g, '\\n')                   // Multiple newlines to single
                .replace(/\\t+/g, ' ')                    // Tabs to spaces
                .replace(/\\[\\d+\\]/g, '')                // Remove citations like [1]
                .replace(/\\(Fig\\. \\d+\\)/g, '')         // Remove figure references
                .replace(/\\(Table \\d+\\)/g, '')         // Remove table references
                .trim();
              
              // Split into sentences and keep only meaningful ones
              const sentences = bestContent.split(/[.!?]+/).filter(s => s.trim().length > 20);
              const cleanedSentences = sentences.slice(0, 30); // Limit to 30 sentences
              const finalContent = cleanedSentences.join('. ').trim();
              
              // Add period at the end if missing
              if (finalContent && !finalContent.match(/[.!?]/)) {
                return finalContent + '.';
              }
              
              return finalContent || 'No meaningful content found on this page.';
            }
            
            return extractMainContent();
          } catch (error) {
            return 'Error extracting content: ' + error.message;
          }
        })();
      """);
      
      // Parse the result with error handling
      String content = '';
      try {
        if (result is String) {
          content = result.replaceAll(RegExp(r'^"|"$'), '');
        } else if (result is Map) {
          content = result['value']?.toString() ?? 'No content found';
        } else {
          content = result.toString() ?? 'No content found';
        }
      } catch (e) {
        print('Error parsing JavaScript result: $e');
        return 'Failed to parse extracted content.';
      }
      
      // Limit content length for API
      if (content.length > 6000) {
        content = content.substring(0, 6000) + '...';
      }
      
      print('Extracted content length: ${content.length} characters');
      return content;
      
    } catch (e) {
      print('Error extracting content: $e');
      return 'Failed to extract page content. The page might not support content extraction or may still be loading.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if active tab changed
    final currentActiveTabId = browserState.activeTab?.id;
    if (currentActiveTabId != null && 
        currentActiveTabId != _lastActiveTabId) {
      // Tab switched, get or create controller for this tab
      _lastActiveTabId = currentActiveTabId;
      
      // Get or create controller for this tab
      final controller = _getOrCreateController(currentActiveTabId);
      
      // Register this controller with the browser provider
      ref.read(browserProvider.notifier).registerWebController(currentActiveTabId, controller);
      
      final targetUrl = browserState.activeTab!.url;
      print('Tab switched to: $targetUrl'); // Debug print
      
      // Load the tab's URL if it's different from current
      if (targetUrl.isNotEmpty && Uri.tryParse(targetUrl) != null) {
        controller.loadRequest(Uri.parse(targetUrl));
        print('Loading URL for tab $currentActiveTabId: $targetUrl'); // Debug print
      }
    }

    // Get current controller for the active tab
    final currentController = _lastActiveTabId != null ? _controllers[_lastActiveTabId] : null;

    return Column(
      children: [
        // Chrome-style loading bar
        if (_isLoading)
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4285F4),
                  const Color(0xFF34A853),
                  const Color(0xFFFBBC04),
                  const Color(0xFFEA4335),
                ],
              ),
            ),
          ),

        // WebView content
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF202124) : Colors.white,
            child: currentController != null 
                ? WebViewWidget(controller: currentController)
                : Container(), // Show empty container if no controller yet
          ),
        ),
      ],
    );
  }
}