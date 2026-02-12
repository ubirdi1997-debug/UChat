# Changelog

All notable changes to UChat will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Real-time messaging WebSocket backend
- Group chat implementation  
- Push notifications service
- Native iOS Flutter build

## [3.0.0] - 2024-02-12

### Added - Phase 3: Multi-Platform Support

#### Platform Support
- **Flutter Web**: Full web application support at chat.usafe.in
- **Android Deep Links**: `uchat://oauth/callback` for seamless app launch
- **iOS PWA**: Progressive Web App support for iOS Safari
- **Desktop Web**: Full desktop browser support
- **Unified Authentication**: Single OAuth flow across all platforms

#### Platform Detection & Routing
- **PlatformInfo Utility**: Automatic platform detection (Android/iOS/Web/Desktop)
- **Platform-Specific URLs**: Automatic redirect URI selection per platform
- **Deep Link Handler**: Android deep link capture and OAuth callback processing
- **URL Strategy**: Clean URLs for web (removes # from routes)

#### Storage Strategy
- **PlatformStorageService**: Unified storage API for all platforms
- **Android/iOS**: flutter_secure_storage (Keychain/Keystore)
- **Web**: Encrypted localStorage with AES-256
- **Automatic Platform Selection**: Transparent storage selection

#### Web Infrastructure
- **index.html**: Optimized for PWA with CSP headers
- **manifest.json**: PWA configuration for installability
- **Nginx Configuration**: Production-ready web server setup
- **Docker Support**: Containerized deployment option
- **SSL/HTTPS**: Complete security configuration

#### OAuth Updates
- **Multi-Platform Redirect URIs**:
  - Android: `uchat://oauth/callback`
  - Web/iOS: `https://chat.usafe.in/oauth/callback`
- **Platform-Aware Config**: Dynamic redirect URL selection
- **Android Manifest**: Updated deep link scheme
- **Web Callback Handling**: URL parameter extraction and cleanup

#### Dependencies
- `universal_html: ^2.2.4` - Cross-platform HTML support
- `universal_io: ^2.2.2` - Cross-platform IO operations
- `url_strategy: ^0.2.0` - Web URL strategy (removes #)
- `uni_links: ^0.5.1` - Deep link handling

#### Documentation
- **MULTIPLATFORM.md** (13KB): Complete multi-platform architecture guide
  - Platform support matrix
  - OAuth flow diagrams
  - Deep link configuration
  - Token storage strategies
  - Web deployment guide
  
- **DEPLOYMENT.md** (13KB): Comprehensive deployment guide
  - Platform-specific build commands
  - Nginx/Docker configuration
  - SSL setup with Let's Encrypt
  - CI/CD pipeline examples
  - Monitoring and rollback procedures

#### UI & Main App
- **URL Strategy**: Initialized in main.dart for clean web URLs
- **Deep Link Initialization**: Automatic on mobile platforms
- **Platform Detection**: Early initialization for routing

### Changed
- **AppConfig**: Now platform-aware with dynamic redirect URLs
- **Main.dart**: Added URL strategy and deep link initialization
- **AndroidManifest.xml**: Updated OAuth deep link scheme
- **README.md**: Updated with multi-platform information

### Technical Details
- **Build Targets**: Android APK/AAB, Web (HTML/CanvasKit), iOS PWA
- **Deployment**: Nginx, Docker, Firebase Hosting, Cloudflare Pages
- **OAuth Clients**: Single client ID with multiple redirect URIs
- **Security**: Platform-specific secure storage, PKCE maintained

## [2.0.0] - 2024-02-12

### Added - Phase 2: Advanced Features

#### Media & Communication
- **Photo Sharing**: Pick from gallery or take with camera, auto-compression to 1920x1920
- **Video Sharing**: Pick from gallery or record, max 5 minutes duration
- **Location Sharing**: Share GPS coordinates with address lookup via geocoding
- **Voice Messages**: Record and send audio messages with AAC-LC encoding
- **File Sharing**: Share any file type through native file picker
- **Emoji Picker**: Full emoji support with search and categories
- **Voice Calls**: WebRTC-based real-time audio communication (infrastructure ready)
- **Video Calls**: WebRTC-based HD video streaming (infrastructure ready)

#### Security & Privacy
- **End-to-End Encryption**: AES-256 encryption for all messages and media
- **MPIN Support**: 4-6 digit PIN for app lock with secure hash storage
- **Biometric Authentication**: Fingerprint and Face ID support
- **Auto-Lock**: Lock app when going to background
- **Auto-Delete Messages**: Configurable per-chat (1h, 2h, 24h, or never)
- **Encryption Service**: Secure encryption/decryption for messages and files
- **Security Settings Screen**: Comprehensive security configuration UI

#### Performance
- **Image Compression**: Automatic compression before upload
- **Lazy Loading**: On-demand resource loading
- **Cached Media**: Intelligent caching strategy
- **Background Processing**: Efficient background task handling

#### Models & Services
- **MessageMedia Model**: Support for all media types (image, video, audio, voice, location, file)
- **ChatSettings Model**: Per-chat configuration including auto-delete
- **MediaService**: Comprehensive media handling service
- **EncryptionService**: End-to-end encryption implementation
- **AppSecurityService**: MPIN and biometric authentication

#### UI Enhancements
- **Feature Badges**: Visual indicators for available features
- **Security Settings**: Dedicated security configuration screen
- **Enhanced Chat List**: Feature showcase on main screen
- **Permission Handling**: Runtime permission requests

### Changed
- **Message Model**: Extended with media support, encryption flag, and expiry timestamp
- **Chat List Screen**: Added security settings access and feature badges
- **Dependencies**: Added 15+ new packages for media, encryption, and communication

### Technical
- **Android Permissions**: Camera, microphone, storage, location, biometric
- **iOS Permissions**: Camera, microphone, photo library, location, Face ID
- **Platform Configuration**: Full permission setup for both platforms

## [1.0.0] - 2024-02-11

### Added
- Initial release of UChat
- OAuth 2.0 Authorization Code Flow with PKCE implementation
- uSafe ID integration as identity provider
- Secure token storage using platform-specific secure storage
  - iOS: Keychain
  - Android: EncryptedSharedPreferences with Keystore
- Automatic token refresh mechanism with HTTP interceptor
- Authentication state management using Riverpod
- Clean architecture implementation
- Material Design 3 UI with dark mode support
- Splash screen with auto-initialization
- Login screen with uSafe ID integration
- Chat list screen (placeholder for Phase 1)
- User profile display
- Comprehensive documentation
  - Architecture guide
  - Implementation guide
  - Security documentation
  - README with quick start
- Unit tests for core functionality
  - PKCE service tests
  - Token model tests
- Android and iOS platform configuration
- OAuth redirect URI configuration

### Security
- Access tokens stored in memory only
- Refresh tokens encrypted at rest
- No sensitive data in logs
- Secure session management
- Token rotation support
- Clean logout with token revocation
- PKCE implementation for mobile OAuth security

### Technical
- Flutter 3.0+ support
- Riverpod for state management
- Dio for HTTP client
- flutter_appauth for OAuth 2.0
- flutter_secure_storage for encrypted storage
- Material Design 3 theming
- Clean architecture pattern
- Comprehensive error handling

### Documentation
- High-level architecture diagram
- OAuth 2.0 + PKCE flow documentation
- Token lifecycle management guide
- Security best practices
- Scaling considerations
- Implementation guide
- Platform-specific setup instructions

[Unreleased]: https://github.com/ubirdi1997-debug/UChat/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ubirdi1997-debug/UChat/releases/tag/v1.0.0
