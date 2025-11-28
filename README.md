# AI Browser & Summarizer

A sophisticated multi-tab browser with integrated AI-powered content summarization and translation capabilities, built with Flutter and Clean Architecture principles.

## Project Overview

**AI Browser & Summarizer** is a production-ready browser application that combines web browsing with intelligent content analysis. It features Chrome-like multi-tab management, offline mode, file downloads, and AI-powered summarization with real-time translation support.

### Key Features
- **Chrome-like Multi-tab Browsing** - Seamless tab management with persistence
- **AI-Powered Summarization** - OpenAI integration for content analysis
- **Multi-language Translation** - Real-time translation of summaries
- **Cross-Platform Support** - Android, iOS, Web, and Desktop
- **Offline Mode** - Cached pages and summaries for offline access
- **Advanced File Management** - Download, organize, and manage files
- **Material Design 3** - Modern, adaptive UI with dark/light themes
- **Secure API Management** - Environment-based secret handling
- **High Performance** - Optimized state management and caching

### Use Cases
- **Research & Study** - Summarize academic papers and articles
- **Content Curation** - Quick overview of lengthy web content
- **Language Learning** - Translate and understand foreign content
- **Productivity** - Efficient information processing
- **Accessibility** - Simplified content for better comprehension

## Architecture

### Clean Architecture Diagram

┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ │
│  │   Pages     │ │  Widgets    │ │  Providers  │ │ Themes  │ │
│  │ ChromePage  │ │ WebView     │ │ Browser     │ │ Material│ │
│  │ FilesPage   │ │ SummaryPanel│ │ Download    │ │ Design  │ │
│  │ Settings    │ │ TabBar      │ │ Summary     │ │ 3      │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────┘ │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ │
│  │  Entities   │ │ Repositories │ │  Use Cases  │ │ Values  │ │
│  │ BrowserTab  │ │ BrowserRepo  │ │ ManageTabs  │ │ Enums  │ │
│  │ Summary     │ │ DownloadRepo │ │ Download    │ │ Models │ │
│  │ Downloaded  │ │ SummaryRepo  │ │ Summarize   │ │        │ │
│  │ File        │ │             │ │ Translate   │ │        │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────┘ │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ │
│  │ Local DB    │ │ Remote APIs │ │ Datasources │ │ Models  │ │
│  │ Hive        │ │ OpenAI API  │ │ AIDataSource│ │ DTOs   │ │
│  │ Database    │ │ Translation │ │ Translation │ │        │ │
│  │             │ │ Services    │ │ DataSource  │ │        │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────┘ │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     CORE LAYER                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ │
│  │ Constants   │ │ Themes      │ │ Providers   │ │ Utils   │ │
│  │ AppConstants│ │ AppTheme    │ │ ThemeProvider│ │ File    │ │
│  │ Env Vars    │ │ Dark/Light  │ │             │ │ Network │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Project Structure

```
lib/
├── core/                    # Shared utilities & configuration
│   ├── constants/          # App-wide constants
│   ├── themes/             # Material Design themes
│   └── providers/          # Core state providers
├── data/                   # Data layer implementation
│   ├── local/              # Local storage (Hive)
│   ├── remote/             # API integrations
│   └── repositories/       # Repository implementations
├── domain/                 # Business logic
│   ├── entities/           # Core data models
│   ├── repositories/       # Repository interfaces
│   └── use_cases/          # Business use cases
├── presentation/           # UI layer
│   ├── pages/              # Screen-level widgets
│   ├── widgets/            # Reusable UI components
│   └── providers/         # UI state management
└── main.dart              # App entry point
```

## Setup & Run Instructions

### Prerequisites
- Flutter SDK (>= 3.9.0)
- Dart SDK (>= 3.9.0)
- Android Studio / VS Code
- OpenAI API Key (for AI features)

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd task_kuvaka_1
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables:**
   ```bash
   # Copy the template
   cp .env.example .env
   
   # Edit .env with your API key
   OPENAI_API_KEY=sk-proj-your-openai-api-key-here
   ```

4. **Get your OpenAI API Key:**
   - Visit: https://platform.openai.com/api-keys
   - Create a new API key
   - Add it to your `.env` file

### Android Setup

1. **Set up Android:**
   ```bash
   flutter config --enable-android
   flutter create --platforms android .
   ```

2. **Run on Android:**
   ```bash
   # Connect device or start emulator
   flutter devices
   
   # Run the app
   flutter run -d android
   ```

3. **Build APK:**
   ```bash
   # Debug build
   flutter build apk --debug
   
   # Release build
   flutter build apk --release
   ```

### Web Setup

1. **Enable Web:**
   ```bash
   flutter config --enable-web
   flutter create --platforms web .
   ```

2. **Run on Web:**
   ```bash
   flutter run -d chrome
   # or
   flutter run -d web-server
   ```

3. **Build for Web:**
   ```bash
   flutter build web
   ```

### Additional Platforms

```bash
# iOS
flutter config --enable-ios
flutter run -d ios

# Windows
flutter config --enable-windows-desktop
flutter run -d windows

# macOS
flutter config --enable-macos-desktop
flutter run -d macos

# Linux
flutter config --enable-linux-desktop
flutter run -d linux
```

## Package List & Versioning

### Core Dependencies
```yaml
flutter:
  sdk: flutter

# UI Framework
cupertino_icons: ^1.0.8                    # iOS-style icons
flutter_riverpod: ^2.5.1                   # State management

# WebView & Web Content
webview_flutter: ^4.8.0                    # WebView integration
webview_flutter_android: ^3.16.0          # Android WebView
webview_flutter_wkwebview: ^3.12.0        # iOS WebView

# File Management
file_picker: ^8.1.2                        # File selection
path_provider: ^2.1.4                      # File paths
path: ^1.9.0                               # Path utilities
open_file: ^3.3.2                          # File opening

# Storage & Database
hive: ^2.2.3                               # NoSQL database
hive_flutter: ^1.1.0                       # Hive Flutter integration
shared_preferences: ^2.3.2                 # Simple key-value storage

# Networking & APIs
http: ^1.2.2                               # HTTP client
url_launcher: ^6.3.0                       # URL launching
connectivity_plus: ^6.1.1                  # Network connectivity

# AI & Translation
translator: ^1.0.3                         # Google Translate
flutter_dotenv: ^5.1.0                     # Environment variables

# UI Components & Utilities
share_plus: ^10.0.2                        # Content sharing
flutter_markdown: ^0.7.3+1                 # Markdown rendering
lottie: ^3.1.2                             # Animations
cached_network_image: ^3.4.1               # Image caching
permission_handler: ^11.3.1                # Device permissions
uuid: ^4.5.1                               # Unique identifiers
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2                     # Dart linting rules
  hive_generator: ^2.0.1                    # Hive code generation
  build_runner: ^2.4.9                      # Code generation runner
```

## State Management & Storage Logic

### State Management: Riverpod

**Why Riverpod?**
- **Compile-time safety** - No runtime exceptions for providers
- **Testability** - Easy dependency injection and mocking
- **Performance** - Selective rebuilds and caching
- **Flexibility** - Multiple provider types (StateNotifier, Provider, etc.)

### State Flow Architecture

```
User Interaction → UI Event → Provider → Repository → DataSource
       ↑                                                    ↓
UI Rebuild ← State Update ← Business Logic ← Data Processing
```

### Key Providers

```dart
// Browser State Management
final browserProvider = StateNotifierProvider<BrowserNotifier, BrowserState>((ref) {
  return BrowserNotifier(ref);
});

// Download State Management  
final downloadProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier();
});

// AI Summary State Management
final summaryProvider = StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  final aiDataSource = ref.watch(aiDataSourceProvider);
  return SummaryNotifier(aiDataSource: aiDataSource);
});
```

### Storage Strategy: Hive Database

**Why Hive?**
- **NoSQL** - Flexible schema for complex data
- **Fast** - Written in pure Dart, optimized for Flutter
- **Cross-platform** - Works on all supported platforms
- **Encryption-ready** - Built-in encryption support

### Data Persistence Model

```dart
// Box Structure
├── browser_tabs/           # Tab management
│   └── current_tabs        # Active tab list
├── downloaded_files/       # File management
│   └── downloaded_files   # Downloaded file registry
├── summaries_cache/        # AI summaries
│   └── cached_summaries  # Summary history
└── app_settings/          # User preferences
    └── theme_mode        # UI preferences
```

### Caching Strategy

1. **Tab Persistence** - Auto-save on state changes
2. **Summary Caching** - AI responses cached per tab
3. **Offline Mode** - Pages cached for offline access
4. **File Metadata** - Download information stored locally

## API Flow: Summarization & Translation

### Summarization Flow

```
1. User navigates to webpage
   ↓
2. WebView loads content
   ↓
3. User clicks "Summarize" button
   ↓
4. JavaScript extracts page content
   ↓
5. Content sent to OpenAI API
   ↓
6. AI processes and returns summary
   ↓
7. Summary cached locally
   ↓
8. Summary displayed in UI
```

### Translation Flow

```
1. User selects target language
   ↓
2. Summary text sent to Translation API
   ↓
3. API returns translated text
   ↓
4. Translation stored with summary
   ↓
5. UI updates with translated content
```

### API Integration Details

```dart
// OpenAI API Integration
class AIDataSource {
  Future<String> summarizeText(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/completions'),
      headers: {'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({
        'model': 'gpt-3.5-turbo-instruct',
        'prompt': 'Summarize this text: $text',
        'max_tokens': 500,
      }),
    );
    return _extractSummary(response);
  }
}

// Translation Service
class TranslationService {
  Future<String> translateText(String text, String targetLang) async {
    return translator.translate(text, to: targetLang);
  }
}
```

### Security Architecture

```
.env file → flutter_dotenv → AppConstants → AIDataSource
```

**Security Layers:**
1. **Environment Variables** - Never commit secrets
2. **Constants Class** - Centralized API key access
3. **Fallback Values** - Graceful degradation
4. **Error Handling** - Secure error messages

## Known Limitations

### Current Constraints

1. **API Rate Limits**
   - OpenAI API has usage limits
   - Translation services may have quotas
   - **Solution:** Implement request queuing and caching

2. **Large Content Handling**
   - Very long pages may exceed API limits
   - **Solution:** Content chunking and progressive summarization

3. **Offline Capabilities**
   - Limited offline AI functionality
   - **Solution:** On-device ML models for basic summarization

4. **WebView Limitations**
   - Some sites block WebView access
   - JavaScript injection may fail on secure sites
   - **Solution:** Fallback content extraction methods

5. **File Format Support**
   - Limited to common file types
   - **Solution:** Expand format support and preview capabilities

### Known Issues

1. **Memory Usage** - Multiple tabs with heavy content may use significant memory
2. **Startup Time** - Initial app load can be slow with many cached tabs
3. **Translation Accuracy** - Depends on third-party service quality

## Future Improvements

### Short-term Goals (1-3 months)

1. **Enhanced AI Features**
   - [ ] Support for multiple AI models (Claude, Gemini)
   - [ ] Custom summarization prompts
   - [ ] Sentiment analysis and keyword extraction

2. **Performance Optimizations**
   - [ ] Lazy loading for tabs
   - [ ] Memory management improvements
   - [ ] Background processing for AI tasks

3. **User Experience**
   - [ ] Gesture-based navigation
   - [ ] Voice commands for browsing
   - [ ] Reading mode for articles

### Medium-term Goals (3-6 months)

1. **Advanced Features**
   - [ ] Bookmark management with AI tagging
   - [ ] History search with semantic search
   - [ ] Collaborative reading sessions

2. **Platform Expansion**
   - [ ] Desktop apps (Windows, macOS, Linux)
   - [ ] Browser extensions (Chrome, Firefox)
   - [ ] Progressive Web App (PWA)

3. **AI Enhancements**
   - [ ] On-device summarization (TensorFlow Lite)
   - [ ] Real-time translation overlay
   - [ ] Content recommendation engine

### Long-term Vision (6+ months)

1. **Enterprise Features**
   - [ ] Team collaboration tools
   - [ ] Admin dashboard and analytics
   - [ ] Custom AI model training

2. **Advanced Technologies**
   - [ ] AR/VR browsing experience
   - [ ] Blockchain-based content verification
   - [ ] Quantum-resistant security

3. **Ecosystem Integration**
   - [ ] Third-party plugin system
   - [ ] API for developers
   - [ ] Integration with popular tools

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Flutter Team** - For the amazing framework
- **OpenAI** - For the powerful AI capabilities
- **Riverpod Community** - For the excellent state management solution
- **Hive Team** - For the fast NoSQL database

---

**Built with Flutter and Clean Architecture principles**