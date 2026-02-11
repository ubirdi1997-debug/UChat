# Changelog

All notable changes to UChat will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Real-time messaging functionality
- Message pagination
- Typing indicators
- Message status indicators (sent/delivered/seen)
- Group chat support
- Media sharing
- Push notifications
- End-to-end encryption

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
