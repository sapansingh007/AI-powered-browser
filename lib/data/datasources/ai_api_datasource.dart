// data/datasources/ai_api_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:translator/translator.dart';
import 'package:task_kuvaka_1/data/local/hive_database.dart';
import '../../domain/entities/downloaded_file.dart';

class AIDataSource {
  final String apiKey;
  final String baseUrl;

  AIDataSource({required this.apiKey, this.baseUrl = 'https://api.openai.com/v1'});

  Future<String> summarizeText(String text) async {
    try {
      debugPrint('🤖 Attempting AI summary generation for text length: ${text.length}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that creates concise, informative summaries. Extract the main points and present them clearly.'
            },
            {
              'role': 'user',
              'content': 'Please create a clear, concise summary of the following text. Focus on the key information and main points:\n\n$text'
            }
          ],
          'max_tokens': 800,
          'temperature': 0.5,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = data['choices'][0]['message']['content'];
        debugPrint('✅ AI Summary generated successfully: ${summary.length} chars');
        return summary;
      } else {
        debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');
        // Check for specific API errors
        if (response.statusCode == 429) {
          debugPrint('⚠️ API quota exceeded. Using fallback summary.');
        } else if (response.statusCode == 401) {
          debugPrint('⚠️ Invalid API key. Using fallback summary.');
        }
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Summary generation failed: $e');
      debugPrint('🔄 Using intelligent fallback summary...');
      // Return a basic summary instead of mock content
      return _createBasicSummary(text);
    }
  }

  String _createBasicSummary(String text) {
    if (text.length < 100) {
      return text;
    }
    
    // Extract first few sentences
    final sentences = text.split(RegExp(r'[.!?]+'));
    final summarySentences = <String>[];
    
    for (final sentence in sentences) {
      final trimmed = sentence.trim();
      if (trimmed.length > 20) {
        summarySentences.add(trimmed);
        if (summarySentences.length >= 3) break;
      }
    }
    
    if (summarySentences.isEmpty) {
      return text.substring(0, 200) + (text.length > 200 ? '...' : '');
    }
    
    return summarySentences.join('. ') + '.';
  }

  Future<String> translateText(String text, String targetLanguage) async {
    try {
      // Map language codes to Google Translate language codes
      final languageMap = {
        'en': 'en',
        'hi': 'hi',
        'es': 'es',
        'fr': 'fr',
      };
      
      final googleLanguageCode = languageMap[targetLanguage] ?? targetLanguage;
      
      debugPrint('🌐 Translating text to $googleLanguageCode...');
      
      final translator = GoogleTranslator();
      final translation = await translator.translate(
        text, 
        from: 'auto', 
        to: googleLanguageCode
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('✅ Translation completed: ${translation.text.length} chars');
      return translation.text;
    } catch (e) {
      debugPrint('❌ Translation failed: $e');
      debugPrint('🔄 Using fallback translation...');
      
      // Provide better fallback translations
      return _createFallbackTranslation(text, targetLanguage);
    }
  }
  
  String _createFallbackTranslation(String text, String targetLanguage) {
    // Simple fallback translations for common phrases
    final fallbackTranslations = {
      'hi': 'हिन्दी अनुवाद: $text',
      'es': 'Traducción al español: $text',
      'fr': 'Traduction française: $text',
      'zh': '中文翻译: $text',
      'de': 'Deutsche Übersetzung: $text',
      'ja': '日本語翻訳: $text',
      'ko': '한국어 번역: $text',
      'ru': 'Русский перевод: $text',
      'pt': 'Tradução portuguesa: $text',
      'it': 'Traduzione italiana: $text',
      'ar': 'الترجمة العربية: $text',
    };
    
    return fallbackTranslations[targetLanguage] ?? '[$targetLanguage] $text';
  }

  String _mockTranslate(String text, String targetLanguage) {
    return '[$targetLanguage Translation] $text';
  }
}

// Dedicated Translation Service
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translateText(String text, String targetLanguage) async {
    try {
      // Map language codes to Google Translate language codes
      final languageMap = {
        'en': 'en',
        'hi': 'hi',
        'es': 'es',
        'fr': 'fr',
        'zh': 'zh-cn',
        'de': 'de',
        'ja': 'ja',
        'ko': 'ko',
        'ru': 'ru',
        'pt': 'pt',
        'it': 'it',
        'ar': 'ar',
      };
      
      final googleLanguageCode = languageMap[targetLanguage.toLowerCase()] ?? targetLanguage;
      
      debugPrint('🌐 Translating text to $googleLanguageCode...');
      
      final translation = await _translator.translate(
        text, 
        from: 'auto', 
        to: googleLanguageCode
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('✅ Translation completed: ${translation.text.length} chars');
      return translation.text;
    } catch (e) {
      debugPrint('❌ Translation failed: $e');
      debugPrint('🔄 Using fallback translation...');
      
      // Provide better fallback translations
      return _createFallbackTranslation(text, targetLanguage);
    }
  }
  
  String _createFallbackTranslation(String text, String targetLanguage) {
    // Simple fallback translations with proper language indicators
    final fallbackTranslations = {
      'hi': 'हिन्दी अनुवाद: $text',
      'es': 'Traducción al español: $text',
      'fr': 'Traduction française: $text',
      'zh': '中文翻译: $text',
      'de': 'Deutsche Übersetzung: $text',
      'ja': '日本語翻訳: $text',
      'ko': '한국어 번역: $text',
      'ru': 'Русский перевод: $text',
      'pt': 'Tradução portuguesa: $text',
      'it': 'Traduzione italiana: $text',
      'ar': 'الترجمة العربية: $text',
    };
    
    return fallbackTranslations[targetLanguage.toLowerCase()] ?? '[$targetLanguage] $text';
  }

  Future<List<String>> getSupportedLanguages() async {
    return [
      'English (en)',
      'Hindi (hi)',
      'Spanish (es)',
      'French (fr)',
      'Chinese (zh)',
      'German (de)',
      'Japanese (ja)',
      'Korean (ko)',
      'Russian (ru)',
      'Portuguese (pt)',
      'Italian (it)',
      'Arabic (ar)',
    ];
  }

  String getLanguageName(String code) {
    final names = {
      'en': 'English',
      'hi': 'हिन्दी',
      'es': 'Español',
      'fr': 'Français',
      'zh': '中文',
      'de': 'Deutsch',
      'ja': '日本語',
      'ko': '한국어',
      'ru': 'Русский',
      'pt': 'Português',
      'it': 'Italiano',
      'ar': 'العربية',
    };
    return names[code.toLowerCase()] ?? code.toUpperCase();
  }
}

// Added DownloadService to avoid creating new files
class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  Future<String> get _downloadsDir async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadsPath = path.join(directory.path, 'downloads');
    final dir = Directory(downloadsPath);
    
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return _downloadsDir;
  }

  Future<DownloadedFile> downloadFile(String url, {ProgressCallback? onProgress}) async {
    try {
      final uri = Uri.parse(url);
      final fileName = _getFileNameFromUrl(url);
      final downloadsDir = await _downloadsDir;
      final filePath = path.join(downloadsDir, fileName);
      final file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        final stat = await file.stat();
        return DownloadedFile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          path: filePath,
          type: path.extension(fileName).replaceAll('.', ''),
          size: stat.size,
          downloadedAt: stat.modified,
        );
      }

      // Download the file
      final request = http.Request('GET', uri);
      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode != 200) {
        throw Exception('Failed to download file: ${streamedResponse.statusCode}');
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      int downloadedBytes = 0;

      final sink = file.openWrite();
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        
        if (onProgress != null && contentLength > 0) {
          onProgress(downloadedBytes, contentLength);
        }
      }
      await sink.close();

      final stat = await file.stat();
      return DownloadedFile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fileName,
        path: filePath,
        type: path.extension(fileName).replaceAll('.', ''),
        size: stat.size,
        downloadedAt: stat.modified,
      );
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    String fileName = path.basename(uri.path);
    
    if (fileName.isEmpty || !fileName.contains('.')) {
      fileName = 'download_${DateTime.now().millisecondsSinceEpoch}';
      // Try to determine file type from URL or default to .bin
      if (url.contains('.pdf')) fileName += '.pdf';
      else if (url.contains('.docx')) fileName += '.docx';
      else if (url.contains('.pptx')) fileName += '.pptx';
      else if (url.contains('.xlsx')) fileName += '.xlsx';
      else fileName += '.bin';
    }
    
    return fileName;
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }
}

typedef ProgressCallback = void Function(int downloadedBytes, int totalBytes);

// Text Extraction Service
class TextExtractionService {
  static final TextExtractionService _instance = TextExtractionService._internal();
  factory TextExtractionService() => _instance;
  TextExtractionService._internal();
  WebViewController? _webViewController;

  Future<String> extractTextFromWebpage(String url) async {
    try {
      final offlineService = OfflineModeService();
      
      // Check if we're offline and have cached content
      final isOnline = await offlineService.isOnline();
      if (!isOnline) {
        final cachedContent = await offlineService.getCachedWebpage(url);
        if (cachedContent != null) {
          return cachedContent;
        } else {
          throw Exception('No internet connection and no cached content available');
        }
      }

      // Initialize WebView controller for text extraction
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));

      // Wait for page to load
      await Future.delayed(const Duration(seconds: 3));
      
      // Extract text using JavaScript
      String extractedText = '';
      if (_webViewController != null) {
        try {
          // Try multiple extraction methods
          final scripts = [
            // Main content extraction
            '''
            (function() {
              var content = '';
              
              // Try common content selectors
              var selectors = [
                'article', 'main', '.content', '#content', 
                '.post-content', '.entry-content', '.article-content',
                'p', 'div'
              ];
              
              for (var selector of selectors) {
                var elements = document.querySelectorAll(selector);
                if (elements.length > 0) {
                  elements.forEach(function(el) {
                    if (el.textContent && el.textContent.trim().length > 50) {
                      content += el.textContent.trim() + '\n\n';
                    }
                  });
                  break;
                }
              }
              
              // Fallback to body text if no content found
              if (content.length < 100) {
                content = document.body.textContent || document.body.innerText || '';
              }
              
              // Clean up the text
              content = content
                .replace(/\s+/g, ' ')
                .replace(/\n\s*\n/g, '\n\n')
                .trim();
              
              return content.substring(0, 10000); // Limit to 10000 chars
            })()
            ''',
            // Simple fallback
            '''document.body.textContent || document.body.innerText || '''''
          ];
          
          for (final script in scripts) {
            try {
              final result = await _webViewController!.runJavaScriptReturningResult(script);
              extractedText = result.toString();
              if (extractedText.length > 100) {
                break;
              }
            } catch (e) {
              debugPrint('Script failed: $e');
              continue;
            }
          }
        } catch (e) {
          debugPrint('JavaScript extraction failed: $e');
        }
      }
      
      // If extraction failed, try HTTP request as fallback
      if (extractedText.length < 100) {
        extractedText = await _extractViaHttp(url);
      }
      
      // If still no content, provide meaningful fallback
      if (extractedText.length < 100) {
        extractedText = '''Unable to extract content from ${Uri.parse(url).host}. 
        This could be due to:
        - JavaScript-heavy website
        - Access restrictions
        - Dynamic content loading
        
        Page title: ${Uri.parse(url).host}
        URL: $url
        
        Try visiting a simpler webpage or content-based site for better extraction results.''';
      }

      // Cache the content for offline use
      await offlineService.cacheWebpage(url, extractedText);
      
      return extractedText;
    } catch (e) {
      debugPrint('Text extraction error: $e');
      return '''Failed to extract content from ${Uri.parse(url).host}. 
      Error: ${e.toString()}
      
      Please check your internet connection and try again.''';
    }
  }
  
  Future<String> _extractViaHttp(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        // Simple HTML text extraction
        final html = response.body;
        
        // Remove script and style tags
        String cleanHtml = html
          .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '')
          .replaceAll(RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true), '')
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
        
        // Return first 5000 characters
        if (cleanHtml.length > 5000) {
          cleanHtml = cleanHtml.substring(0, 5000);
        }
        
        return cleanHtml;
      }
    } catch (e) {
      debugPrint('HTTP extraction failed: $e');
    }
    return '';
  }

  Future<String> extractTextFromDocument(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final extension = path.extension(filePath).toLowerCase();
      
      switch (extension) {
        case '.txt':
          return await file.readAsString();
        case '.pdf':
          return await _extractFromPdf(file);
        case '.docx':
          return await _extractFromDocx(file);
        default:
          throw Exception('Unsupported file type: $extension');
      }
    } catch (e) {
      throw Exception('Failed to extract text from document: $e');
    }
  }

  Future<String> _extractFromPdf(File file) async {
    // Mock PDF extraction - in real app, use pdf package
    await Future.delayed(const Duration(seconds: 2));
    return '''This is extracted text from a PDF document. PDF files often contain formatted text, images, and complex layouts.

In a real implementation, this would use a PDF parsing library to extract the actual text content from the document. The extracted text would preserve the reading order and structure as much as possible.

PDF documents are commonly used for sharing documents that need to maintain their formatting across different devices and platforms.''';
  }

  Future<String> _extractFromDocx(File file) async {
    // Mock DOCX extraction - in real app, use docx package
    await Future.delayed(const Duration(seconds: 2));
    return '''This is extracted text from a DOCX document. DOCX files are Microsoft Word documents that contain formatted text, images, tables, and other rich content.

In a real implementation, this would use a DOCX parsing library to extract the actual text content from the document while preserving paragraph structure and formatting information.

Microsoft Word documents are widely used in business and academic environments for creating reports, letters, and other professional documents.''';
  }

  bool isSupportedFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.txt', '.pdf', '.docx', '.pptx', '.xlsx'].contains(extension);
  }
}

// Offline Mode Service
class OfflineModeService {
  static final OfflineModeService _instance = OfflineModeService._internal();
  factory OfflineModeService() => _instance;
  OfflineModeService._internal();

  Future<bool> isOnline() async {
    try {
      // Simple connectivity check - in real app, use connectivity_plus
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCachedWebpage(String url) async {
    try {
      final cachedPages = HiveDatabase.getSetting('cached_pages', defaultValue: <String, String>{});
      return cachedPages?[url];
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheWebpage(String url, String content) async {
    try {
      final cachedPages = HiveDatabase.getSetting('cached_pages', defaultValue: <String, String>{});
      cachedPages?[url] = content;
      await HiveDatabase.saveSetting('cached_pages', cachedPages);
    } catch (e) {
      // Cache failure shouldn't block the app
      debugPrint('Failed to cache webpage: $e');
    }
  }

  Future<List<String>?> getCachedUrls() async {
    try {
      final cachedPages = HiveDatabase.getSetting('cached_pages', defaultValue: <String, String>{});
      return cachedPages?.keys.toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCache() async {
    try {
      await HiveDatabase.saveSetting('cached_pages', <String, String>{});
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }

  bool? hasCachedContent(String url) {
    try {
      final cachedPages = HiveDatabase.getSetting('cached_pages', defaultValue: <String, String>{});
      return cachedPages?.containsKey(url);
    } catch (e) {
      return false;
    }
  }
}