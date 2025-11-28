// core/constants/app_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const List<String> supportedFileTypes = [
    'pdf', 'docx', 'pptx', 'xlsx', 'txt'
  ];

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
  ];

  static const String mockSummaryApi = 'https://api.example.com/summarize';
  static const String mockTranslateApi = 'https://api.example.com/translate';
  
  // Load API key from environment variables
  static String get defaultAiApiKey {
    // Try to load from .env file, fallback to demo key
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      return apiKey ?? 'demo-api-key';
    } catch (e) {
      // If dotenv fails to load, return demo key
      return 'demo-api-key';
    }
  }
}