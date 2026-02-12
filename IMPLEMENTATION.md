# UChat Implementation Guide

## Prerequisites

Before starting development, ensure you have:

1. **Flutter SDK** (3.0.0 or higher)
   ```bash
   flutter --version
   ```

2. **Development Environment**
   - Android Studio (for Android)
   - Xcode (for iOS, macOS only)
   - VS Code or Android Studio with Flutter plugins

3. **uSafe ID Credentials**
   - Client ID from uSafe ID
   - OAuth redirect URI configured
   - Access to https://id.usafe.in

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
# Clone repository
git clone https://github.com/ubirdi1997-debug/UChat.git
cd UChat

# Install dependencies
flutter pub get

# Verify installation
flutter doctor
```

### 2. Configure OAuth Client ID

Edit `lib/core/config/app_config.dart`:

```dart
static const String clientId = 'your-uchat-client-id';
```

Request your client ID from the uSafe ID team.

### 3. Platform-Specific Setup

#### Android

1. Verify `android/app/build.gradle` has correct `applicationId`:
   ```gradle
   defaultConfig {
       applicationId "in.usafe.uchat"
   }
   ```

2. The OAuth redirect is already configured in `AndroidManifest.xml`:
   ```xml
   <intent-filter>
       <data android:scheme="in.usafe.uchat" />
   </intent-filter>
   ```

#### iOS

1. Open `ios/Runner.xcworkspace` in Xcode

2. Update Bundle Identifier to `in.usafe.uchat`

3. The URL scheme is already configured in `Info.plist`:
   ```xml
   <key>CFBundleURLSchemes</key>
   <array>
       <string>in.usafe.uchat</string>
   </array>
   ```

### 4. Run the App

```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Run in release mode
flutter run --release
```

## Development Workflow

### Project Structure

```
lib/
├── core/                    # Core infrastructure
│   ├── auth/               # Authentication logic
│   ├── config/             # Configuration
│   ├── networking/         # HTTP client
│   └── storage/            # Secure storage
├── features/               # Feature modules
│   ├── auth/              # Auth UI
│   ├── chat/              # Chat UI
│   └── profile/           # Profile UI
├── models/                 # Data models
└── main.dart              # Entry point
```

### State Management

UChat uses **Riverpod** for state management:

```dart
// Define a provider
final myProvider = Provider<MyService>((ref) {
  return MyService();
});

// Use in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(myProvider);
    return ...;
  }
}
```

### Adding New Features

1. **Create feature folder**:
   ```bash
   lib/features/my_feature/
   ├── models/
   ├── providers/
   └── presentation/
       ├── pages/
       └── widgets/
   ```

2. **Define models**:
   ```dart
   class MyModel extends Equatable {
     final String id;
     final String name;
     
     const MyModel({required this.id, required this.name});
     
     @override
     List<Object?> get props => [id, name];
   }
   ```

3. **Create provider**:
   ```dart
   final myFeatureProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
     return MyNotifier();
   });
   ```

4. **Build UI**:
   ```dart
   class MyFeatureScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final state = ref.watch(myFeatureProvider);
       return Scaffold(...);
     }
   }
   ```

## Testing

### Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/pkce_service_test.dart

# With coverage
flutter test --coverage
```

### Writing Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:uchat/core/auth/pkce_service.dart';

void main() {
  group('PKCEService', () {
    test('generates valid code verifier', () {
      final service = PKCEService();
      final verifier = service.generateCodeVerifier();
      
      expect(verifier.length, equals(128));
    });
  });
}
```

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output location
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build iOS app
flutter build ios --release

# Build Archive (for App Store)
# Open ios/Runner.xcworkspace in Xcode
# Product > Archive
```

## Debugging

### Enable Debug Logging

The app uses `pretty_dio_logger` for HTTP request logging in debug mode.

### Common Issues

1. **OAuth Redirect Not Working**
   - Verify redirect URI in uSafe ID matches `in.usafe.uchat://oauth-callback`
   - Check platform-specific configuration

2. **Secure Storage Error**
   - Android: Ensure min SDK is 21+
   - iOS: Ensure proper entitlements

3. **Token Refresh Failing**
   - Check network connectivity
   - Verify refresh token is stored
   - Check token expiry configuration

### Debug Tools

```dart
// Enable detailed auth logs
debugPrint('Token: ${token.accessToken}'); // Remove in production!
debugPrint('Expiry: ${token.timeUntilExpiry}');
```

**⚠️ IMPORTANT**: Never log tokens in production builds!

## Code Quality

### Linting

```bash
# Run analyzer
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Formatting

```bash
# Format all Dart files
dart format lib/ test/

# Check formatting
dart format --set-exit-if-changed lib/ test/
```

## Security Checklist

Before production release:

- [ ] Remove all debug logging of tokens
- [ ] Verify secure storage is enabled
- [ ] Test token refresh mechanism
- [ ] Verify logout clears all data
- [ ] Test on physical devices (not just emulator)
- [ ] Enable ProGuard/R8 (Android)
- [ ] Enable code obfuscation
- [ ] Test OAuth flow with real uSafe ID
- [ ] Verify deep linking works correctly

## Deployment

### Version Bumping

Edit `pubspec.yaml`:

```yaml
version: 1.0.1+2
#        ^     ^ Build number
#        | Version name
```

### Release Notes

Create `CHANGELOG.md`:

```markdown
## [1.0.0] - 2024-02-11

### Added
- OAuth 2.0 with PKCE authentication
- Secure token storage
- Auto token refresh
- Dark mode support

### Security
- Encrypted token storage
- No tokens in logs
- Secure session management
```

## Continuous Integration

### GitHub Actions (Example)

```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

## Support

For issues or questions:

- **Technical Issues**: Create a GitHub issue
- **Security Concerns**: Email security@usafe.in
- **Feature Requests**: Create a GitHub issue with label `enhancement`

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)
- [uSafe ID Documentation](https://github.com/ubirdi1997-debug/uSafe-ID)

---

**Happy Coding! 🚀**
