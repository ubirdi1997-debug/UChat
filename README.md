# UChat 🔐💬

Production-grade Flutter chat application with enterprise-level security powered by **uSafe ID**.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

## ✨ Features

- 🔐 **Enterprise-Grade Security** - OAuth 2.0 with PKCE
- 🎯 **Single Sign-On (SSO)** - Seamless integration with uSafe ecosystem
- 🔄 **Auto Token Refresh** - Transparent session management
- 🌓 **Dark Mode** - Beautiful UI with system theme support
- 💬 **1-to-1 Chat** - Real-time messaging (Phase 1)
- 🚀 **Production-Ready** - Clean architecture, scalable design
- 🔒 **Secure Storage** - iOS Keychain / Android Keystore
- ⚡ **Future-Proof** - Built for E2E encryption, WebAuthn, and more

## 🏗️ Architecture

UChat follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────┐
│  Presentation Layer (UI + State)            │
├─────────────────────────────────────────────┤
│  Business Logic Layer (Providers/Services)  │
├─────────────────────────────────────────────┤
│  Data Layer (Models + API Client)           │
├─────────────────────────────────────────────┤
│  Infrastructure (Storage + Network)         │
└─────────────────────────────────────────────┘
```

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

## 🚀 Quick Start

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- iOS 12+ / Android 5.0+ (API 21+)

### Installation

```bash
# Clone the repository
git clone https://github.com/ubirdi1997-debug/UChat.git
cd UChat

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 🔐 Authentication Flow

UChat uses **OAuth 2.0 Authorization Code Flow with PKCE** for authentication:

1. **App Launch** → Check for existing refresh token
2. **Login** → Redirect to uSafe ID (https://id.usafe.in)
3. **OAuth Flow** → Authorization code exchange with PKCE
4. **Token Storage** → Refresh token in secure storage, access token in memory
5. **Auto-Refresh** → Transparent token refresh before expiry

No passwords stored locally. No Firebase Auth. No Supabase Auth. 
**Only uSafe ID** as the identity authority.

## 📱 Screens

### Splash Screen
- Auto-initialization
- Session validation
- Smart navigation

### Login Screen
- Clean, minimal design
- Single "Login with uSafe ID" button
- Security trust indicators

### Chat List Screen
- User profile display
- Chat list (coming soon)
- Logout functionality

## 🔒 Security Features

✅ **Token Security**
- Access tokens stored in memory only (never persisted)
- Refresh tokens encrypted in platform secure storage
- Automatic token rotation support

✅ **Network Security**
- HTTPS only
- Certificate validation
- Request timeout protection

✅ **Session Management**
- Secure token refresh
- Automatic session validation
- Clean logout with token revocation

✅ **Code Quality**
- No tokens in logs
- No sensitive data in SharedPreferences
- Secure random generation for PKCE

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Networking | Dio |
| OAuth Client | flutter_appauth |
| Secure Storage | flutter_secure_storage |
| Authentication | uSafe ID |

## 📦 Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0      # State management
  dio: ^5.4.0                   # HTTP client
  flutter_appauth: ^6.0.0       # OAuth 2.0
  flutter_secure_storage: ^9.0.0 # Secure storage
  crypto: ^3.0.3                # PKCE hashing
  equatable: ^2.0.5             # Value equality
```

## 🎨 UI/UX

- **Material Design 3** - Modern, clean interface
- **Dark Mode** - Full theme support
- **Smooth Animations** - Native-feel transitions
- **Responsive Design** - Works on all screen sizes

## 🚦 Development Status

### Phase 1: Authentication & Core (✅ Complete)
- [x] OAuth 2.0 with PKCE implementation
- [x] Secure token storage
- [x] Auto token refresh
- [x] Login/logout flow
- [x] Clean architecture setup
- [x] Dark mode support

### Phase 2: Chat Features (🚧 In Progress)
- [ ] 1-to-1 messaging
- [ ] Message status indicators
- [ ] Typing indicators
- [ ] Real-time updates
- [ ] Message pagination

### Phase 3: Advanced Features (📋 Planned)
- [ ] End-to-end encryption
- [ ] Push notifications
- [ ] Group chats
- [ ] Media sharing
- [ ] UAuth integration
- [ ] Passkeys support

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📚 Documentation

- [Architecture Guide](ARCHITECTURE.md) - Detailed system design
- [API Documentation](docs/API.md) - API endpoints and usage (coming soon)
- [Security Guide](docs/SECURITY.md) - Security best practices (coming soon)
- [Deployment Guide](docs/DEPLOYMENT.md) - Production deployment (coming soon)

## 🤝 Contributing

This is a private repository. For questions or issues, please contact the maintainers.

## 📄 License

Copyright © 2024 uSafe. All rights reserved.

---

## 🔗 Related Projects

- **uSafe ID** - https://github.com/ubirdi1997-debug/uSafe-ID
- **UAuth** - Approval-based authentication (coming soon)

## 📧 Support

For support or questions:
- Email: support@usafe.in
- Website: https://usafe.in

---

**Built with ❤️ by the uSafe team** 
