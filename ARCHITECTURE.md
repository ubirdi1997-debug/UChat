# UChat - Production-Grade Flutter Chat Application

## Overview

UChat is a secure, production-ready Flutter chat application that uses **uSafe ID** as its identity provider. Built with enterprise-grade security, clean architecture, and scalability in mind.

## 🏗️ Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UChat App                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │   Auth UI    │    │   Chat UI    │    │ Profile UI   │ │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘ │
│         │                   │                    │          │
│  ┌──────▼───────────────────▼────────────────────▼───────┐ │
│  │              State Management (Riverpod)              │ │
│  └──────┬───────────────────┬────────────────────┬───────┘ │
│         │                   │                    │          │
│  ┌──────▼───────┐    ┌──────▼───────┐    ┌──────▼───────┐ │
│  │ Auth Service │    │ Chat Service │    │  API Client  │ │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘ │
│         │                   │                    │          │
│  ┌──────▼────────────────────────────────────────▼───────┐ │
│  │           OAuth 2.0 + PKCE + Token Manager            │ │
│  └──────┬────────────────────────────────────────────────┘ │
│         │                                                   │
│  ┌──────▼───────────────────────────────────────────────┐ │
│  │              Secure Storage (Keychain/AES)           │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                              │
└─────────────────────┬────────────────────────────────────────┘
                      │
                      ▼
         ┌────────────────────────────┐
         │      uSafe ID Server       │
         │  https://id.usafe.in       │
         │                            │
         │  • OAuth Authorization     │
         │  • Token Exchange          │
         │  • User Info               │
         │  • Token Revocation        │
         └────────────────────────────┘
```

### Folder Structure

```
lib/
├── core/
│   ├── auth/
│   │   ├── auth_service.dart         # OAuth + session management
│   │   └── pkce_service.dart         # PKCE code generation
│   ├── config/
│   │   ├── app_config.dart           # App-wide configuration
│   │   └── theme_config.dart         # Theme definitions
│   ├── networking/
│   │   ├── api_client.dart           # HTTP client wrapper
│   │   └── auth_interceptor.dart     # Auto token refresh
│   └── storage/
│       └── secure_storage_service.dart # Encrypted storage
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart    # Auth state management
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── splash_screen.dart
│   │       │   └── login_screen.dart
│   │       └── widgets/
│   ├── chat/
│   │   ├── models/
│   │   │   ├── chat.dart
│   │   │   └── message.dart
│   │   ├── providers/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── chat_list_screen.dart
│   │       └── widgets/
│   └── profile/
│       ├── providers/
│       └── presentation/
├── models/
│   ├── auth_token.dart               # Token model
│   └── user.dart                     # User model
└── main.dart                         # App entry point
```

## 🔐 OAuth 2.0 Authorization Code Flow with PKCE

### Flow Diagram

```
┌─────────┐                                    ┌──────────┐                                  ┌────────────┐
│  UChat  │                                    │  uSafe   │                                  │   User     │
│   App   │                                    │    ID    │                                  │            │
└────┬────┘                                    └────┬─────┘                                  └─────┬──────┘
     │                                              │                                              │
     │ 1. Generate Code Verifier & Challenge        │                                              │
     │    (PKCE - RFC 7636)                         │                                              │
     ├──────────────────────────────────────────────┤                                              │
     │                                              │                                              │
     │ 2. Authorization Request                     │                                              │
     │    + client_id                               │                                              │
     │    + redirect_uri                            │                                              │
     │    + scope                                   │                                              │
     │    + code_challenge                          │                                              │
     │    + code_challenge_method=S256              │                                              │
     │────────────────────────────────────────────▶│                                              │
     │                                              │                                              │
     │                                              │ 3. Show Login Page                           │
     │                                              │    (Email/Google)                            │
     │                                              │────────────────────────────────────────────▶│
     │                                              │                                              │
     │                                              │ 4. User Authenticates                        │
     │                                              │◀────────────────────────────────────────────│
     │                                              │                                              │
     │ 5. Authorization Code                        │                                              │
     │    (via redirect)                            │                                              │
     │◀────────────────────────────────────────────│                                              │
     │                                              │                                              │
     │ 6. Token Exchange Request                    │                                              │
     │    + code                                    │                                              │
     │    + code_verifier                           │                                              │
     │    + client_id                               │                                              │
     │    + redirect_uri                            │                                              │
     │────────────────────────────────────────────▶│                                              │
     │                                              │                                              │
     │ 7. Access + Refresh Tokens                   │                                              │
     │◀────────────────────────────────────────────│                                              │
     │                                              │                                              │
     │ 8. Store Refresh Token                       │                                              │
     │    (Encrypted Storage)                       │                                              │
     │                                              │                                              │
     │ 9. Access Token (in memory only)             │                                              │
     │                                              │                                              │
```

### PKCE Implementation

**Why PKCE?**
- Protects against authorization code interception attacks
- No client secret needed (safe for mobile apps)
- Recommended for all OAuth 2.0 clients (RFC 8252)

**How it works:**

1. **Generate Code Verifier** (128 random bytes)
   ```dart
   final verifier = base64UrlEncode(randomBytes(96))
       .replaceAll('=', '')
       .substring(0, 128);
   ```

2. **Generate Code Challenge** (SHA-256 hash)
   ```dart
   final challenge = base64UrlEncode(sha256.convert(utf8.encode(verifier)))
       .replaceAll('=', '');
   ```

3. **Send challenge in authorization request**
   - Server stores the challenge

4. **Send verifier in token exchange**
   - Server verifies: SHA256(verifier) == stored challenge

## 🔑 Token Lifecycle Management

### Token Types

| Token Type | Lifespan | Storage | Purpose |
|------------|----------|---------|---------|
| Access Token | 15 min | Memory only | API authentication |
| Refresh Token | 30 days | Encrypted storage | Refresh access tokens |

### Token Refresh Strategy

```
┌────────────────────────────────────────────────────────────┐
│                    Token Lifecycle                          │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Login ────▶ Access Token (15 min) + Refresh Token (30d)   │
│              │                                              │
│              │  Time: 0 min                                 │
│              │  ▼                                           │
│              │  Token in memory                             │
│              │  Auto-injected in API calls                  │
│              │                                              │
│              │  Time: 13 min (Refresh Buffer = 2 min)       │
│              │  ▼                                           │
│              │  Interceptor detects near-expiry             │
│              │  Triggers refresh before expiry              │
│              │                                              │
│              │  ────▶ Refresh Token Request                 │
│              │        │                                     │
│              │        ▼                                     │
│              │  New Access Token + New Refresh Token        │
│              │  (Token Rotation)                            │
│              │                                              │
│              │  Time: 15 min                                │
│              │  ▼                                           │
│              │  Token expired in memory                     │
│              │  (Already refreshed at 13 min)               │
│              │                                              │
│  Day 30 ─────▶ Refresh Token Expires                        │
│              │                                              │
│              ▼                                              │
│         Force Re-login                                      │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

### Auto-Refresh Mechanism

The `AuthInterceptor` automatically refreshes tokens:

```dart
// Before each API request
if (token.needsRefresh(buffer: 2 minutes)) {
  await refreshSession();
}

// On 401 Unauthorized
try {
  await refreshSession();
  retryRequest();
} catch {
  logout();
}
```

## 🔒 Security Implementation

### 1. Token Storage

| Item | Storage Method | Justification |
|------|----------------|---------------|
| Access Token | Memory only | Short-lived, never persisted |
| Refresh Token | Secure Storage | iOS Keychain / Android Keystore |
| User ID | Secure Storage | Encrypted at rest |

**Never stored:**
- Tokens in SharedPreferences
- Tokens in logs
- Tokens in plain text files

### 2. Network Security

```dart
// All API calls use HTTPS
baseUrl: 'https://api.usafe.in'

// Certificate pinning (future enhancement)
// Rate limiting on client side
// Request timeout: 30 seconds
```

### 3. Session Management

```dart
// On app launch
if (hasRefreshToken) {
  try {
    await refreshSession();
  } catch {
    clearSession();
    showLogin();
  }
}

// On logout
await revokeTokenOnServer();
await clearSecureStorage();
clearMemory();
```

## 📱 UI/UX Features

### Screens

1. **Splash Screen**
   - App logo and branding
   - Auto-initialization of auth state
   - Seamless navigation to appropriate screen

2. **Login Screen**
   - Clean, minimal design
   - Single "Login with uSafe ID" button
   - Security badges and trust indicators
   - Loading states

3. **Chat List Screen**
   - User profile display
   - Chat list (placeholder for future)
   - Logout functionality
   - Empty state messaging

### Theme Support

- **Light Theme**: Clean, professional, high contrast
- **Dark Theme**: OLED-friendly, reduced eye strain
- **System Theme**: Automatically follows OS preference

## 🚀 Scaling for Millions of Users

### Performance Optimization

1. **Token Management**
   - In-memory token cache
   - Proactive refresh (before expiry)
   - Minimal secure storage I/O

2. **Network Optimization**
   - Request deduplication
   - Connection pooling (Dio)
   - Automatic retry with exponential backoff

3. **State Management**
   - Efficient Riverpod providers
   - Minimal rebuilds
   - Lazy loading

### Infrastructure Considerations

1. **Backend Scaling**
   ```
   Load Balancer
        │
        ├─── API Server 1
        ├─── API Server 2
        └─── API Server N
             │
             ├─── OAuth Service (uSafe ID)
             ├─── Chat Service (WebSocket)
             ├─── Push Notification Service
             └─── Message Queue (Redis)
   ```

2. **Database Optimization**
   - Read replicas for user data
   - Sharding by user ID
   - Caching layer (Redis)
   - Message pagination

3. **CDN for Assets**
   - User avatars
   - Media files
   - Static assets

### Monitoring & Analytics

- Error tracking (Sentry/Firebase Crashlytics)
- Performance monitoring
- Token refresh success rate
- Authentication funnel metrics

## 🔮 Future Enhancements

### Phase 2 Features

1. **End-to-End Encryption**
   - Signal Protocol
   - Perfect Forward Secrecy
   - Encrypted local storage

2. **Push Notifications**
   - FCM for Android
   - APNS for iOS
   - Background message sync

3. **UAuth Integration**
   - Approval-based login
   - Passwordless authentication
   - Multi-device management

4. **Advanced Chat Features**
   - Group chats
   - Media sharing
   - Voice/video calls
   - Message reactions

5. **Passkeys / WebAuthn**
   - Biometric authentication
   - FIDO2 support
   - Seamless cross-device login

## 📚 Dependencies

### Core Dependencies

- `flutter_riverpod` - State management
- `dio` - HTTP client
- `flutter_appauth` - OAuth 2.0 implementation
- `flutter_secure_storage` - Secure token storage
- `crypto` - PKCE hash generation
- `equatable` - Value equality

### Dev Dependencies

- `flutter_lints` - Code quality
- `mockito` - Testing
- `build_runner` - Code generation

## 🏁 Getting Started

### Prerequisites

```bash
Flutter SDK >= 3.0.0
Dart SDK >= 3.0.0
```

### Installation

```bash
# Clone repository
git clone https://github.com/ubirdi1997-debug/UChat.git
cd UChat

# Install dependencies
flutter pub get

# Run app
flutter run
```

### Configuration

Update `lib/core/config/app_config.dart` with your OAuth client ID:

```dart
static const String clientId = 'your-client-id-here';
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 📄 License

Copyright © 2024 uSafe. All rights reserved.

---

**Built with ❤️ using Flutter & uSafe ID**
