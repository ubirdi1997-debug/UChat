# Changelog

All notable changes to UChat will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Real-time messaging WebSocket backend
- Group chat implementation  
- Push notifications service

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
