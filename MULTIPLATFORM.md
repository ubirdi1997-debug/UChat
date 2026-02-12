# UChat Multi-Platform Architecture Guide

## Overview

UChat now supports multiple platforms with unified OAuth authentication via uSafe ID:

1. **Android** - Native Flutter app with deep link support
2. **Web** - Flutter Web hosted at https://chat.usafe.in
3. **iOS** - PWA via web (native Flutter support planned)
4. **Desktop** - Web-based access

All platforms use the same backend API and identity provider (uSafe ID).

---

## Platform Support Matrix

| Platform | Implementation | OAuth Redirect | Token Storage |
|----------|---------------|----------------|---------------|
| Android | Native Flutter | `uchat://oauth/callback` | Secure Storage (Keystore) |
| Web | Flutter Web | `https://chat.usafe.in/oauth/callback` | Encrypted localStorage |
| iOS (PWA) | Flutter Web | `https://chat.usafe.in/oauth/callback` | Encrypted localStorage |
| Desktop | Flutter Web | `https://chat.usafe.in/oauth/callback` | Encrypted localStorage |

---

## Authentication Flow

### Universal OAuth Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     User Opens UChat                            │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │Platform?│
                    └────┬────┘
         ┌───────────────┼───────────────┐
         │               │               │
    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
    │ Android │    │   Web   │    │   iOS   │
    │ Native  │    │ Browser │    │  (PWA)  │
    └────┬────┘    └────┬────┘    └────┬────┘
         │               │               │
         │         OAuth Flow           │
         │               │               │
         │    ┌──────────▼──────────┐   │
         └────►  uSafe ID Login     ◄───┘
              │  https://id.usafe.in│
              └──────────┬──────────┘
                         │
              ┌──────────▼──────────┐
              │  Platform-Specific   │
              │  Redirect Handling   │
              └──────────┬──────────┘
                         │
              ┌──────────▼──────────┐
              │ Token Exchange      │
              │ (Authorization Code)│
              └──────────┬──────────┘
                         │
              ┌──────────▼──────────┐
              │ Store Tokens        │
              │ (Platform-Specific) │
              └──────────┬──────────┘
                         │
              ┌──────────▼──────────┐
              │   Chat Interface    │
              └─────────────────────┘
```

### Platform-Specific Redirect Handling

#### Android (Deep Link)
1. User clicks "Login with uSafe ID"
2. App opens browser to `https://id.usafe.in/oauth/authorize`
3. User authenticates
4. Browser redirects to `uchat://oauth/callback?code=...`
5. Android OS launches UChat app (if installed)
6. App captures authorization code from deep link
7. App exchanges code for tokens
8. Tokens stored in Android Keystore

#### Web
1. User navigates to `https://chat.usafe.in`
2. App redirects to `https://id.usafe.in/oauth/authorize`
3. User authenticates
4. Browser redirects to `https://chat.usafe.in/oauth/callback?code=...`
5. App captures authorization code from URL
6. App exchanges code for tokens
7. Tokens stored in encrypted localStorage
8. URL is cleaned (code removed)

#### iOS (PWA)
- Same flow as Web
- PWA can be "installed" on home screen
- Behaves like standalone app
- Uses web authentication flow

---

## OAuth Configuration

### Redirect URIs Registered with uSafe ID

```yaml
Client ID: uchat-mobile-client

Redirect URIs:
  - uchat://oauth/callback          # Android deep link
  - https://chat.usafe.in/oauth/callback  # Web/iOS PWA
```

### Platform Detection in Code

```dart
// lib/core/config/app_config.dart
static String get redirectUrl {
  if (PlatformInfo.isAndroid) {
    return 'uchat://oauth/callback';
  } else if (PlatformInfo.isWeb || PlatformInfo.isIOS) {
    return 'https://chat.usafe.in/oauth/callback';
  }
  return 'https://chat.usafe.in/oauth/callback';
}
```

---

## Deep Link Configuration

### Android Setup

**AndroidManifest.xml**
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="uchat"
        android:host="oauth"
        android:path="/callback" />
</intent-filter>
```

**Deep Link Handler**
```dart
// lib/core/auth/deep_link_handler.dart
final deepLinkHandler = DeepLinkHandler();
await deepLinkHandler.initialize();

deepLinkHandler.linkStream.listen((uri) {
  if (deepLinkHandler.isOAuthCallback(uri)) {
    final code = deepLinkHandler.extractAuthCode(uri);
    // Exchange code for tokens
  }
});
```

### iOS (Future Native Support)

When native iOS is implemented:

**Info.plist**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>uchat</string>
        </array>
    </dict>
</array>
```

---

## Token Storage Strategy

### Android/iOS (Native)

**Secure Storage (Keychain/Keystore)**
```dart
// Uses flutter_secure_storage
final secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);

await secureStorage.write(key: 'refresh_token', value: token);
```

### Web

**Encrypted localStorage**
```dart
// lib/core/storage/platform_storage_service.dart
// 1. Generate or retrieve encryption key (stored in localStorage)
// 2. Encrypt token value with AES-256
// 3. Store encrypted value in localStorage
// 4. On read: decrypt value
```

**Security Notes:**
- Encryption key is generated per browser
- Key persists in localStorage
- Not as secure as native keychain, but acceptable for web
- Refresh tokens should be short-lived on web
- Consider HTTP-only cookies for production

---

## Web Deployment Configuration

### Build for Web

```bash
# Development
flutter run -d chrome

# Production build
flutter build web --release --web-renderer html

# Build output: build/web/
```

### Nginx Configuration

**nginx.conf** for `chat.usafe.in`:

```nginx
server {
    listen 443 ssl http2;
    server_name chat.usafe.in;
    
    ssl_certificate /etc/ssl/certs/chat.usafe.in.crt;
    ssl_certificate_key /etc/ssl/private/chat.usafe.in.key;
    
    root /var/www/uchat/build/web;
    index index.html;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # CORS for uSafe ID
    add_header Access-Control-Allow-Origin "https://id.usafe.in" always;
    add_header Access-Control-Allow-Credentials "true" always;
    
    # Handle Flutter Web routing
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # OAuth callback (ensure clean routing)
    location /oauth/callback {
        try_files $uri /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name chat.usafe.in;
    return 301 https://$server_name$request_uri;
}
```

### Docker Deployment (Alternative)

**Dockerfile**:
```dockerfile
FROM nginx:alpine

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy Flutter web build
COPY build/web /usr/share/nginx/html

# Expose port
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
```

---

## PWA Support (iOS)

### Install Prompt

The PWA manifest enables "Add to Home Screen" on iOS:

```json
{
  "name": "UChat - Secure Chat",
  "short_name": "UChat",
  "display": "standalone",
  "start_url": ".",
  "icons": [...]
}
```

### Detection and Instructions

```dart
// Detect iOS Safari
bool isIOSSafari = PlatformInfo.isWeb && 
                   userAgent.contains('iPhone') && 
                   userAgent.contains('Safari');

if (isIOSSafari) {
  // Show install instructions
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Install UChat'),
      content: Text(
        'Tap the Share button, then "Add to Home Screen" '
        'for the best experience.'
      ),
    ),
  );
}
```

---

## Device Detection & Smart Routing

### On Landing Page (chat.usafe.in)

```dart
class DeviceDetector {
  static DeviceType detectDevice() {
    if (PlatformInfo.isAndroid) {
      return DeviceType.android;
    } else if (PlatformInfo.isIOS) {
      return DeviceType.ios;
    } else if (PlatformInfo.isDesktop) {
      return DeviceType.desktop;
    }
    return DeviceType.web;
  }
  
  static Widget buildLandingPage(DeviceType device) {
    switch (device) {
      case DeviceType.android:
        return AndroidPrompt(); // "Download app" or "Continue in browser"
      case DeviceType.ios:
        return IOSPrompt(); // PWA install instructions
      case DeviceType.desktop:
        return WebChatInterface(); // Full web interface
      default:
        return WebChatInterface();
    }
  }
}
```

**Never block login** - always provide a way to continue in browser.

---

## Security Considerations

### PKCE Implementation

All platforms use PKCE (Proof Key for Code Exchange):

```dart
// Generate code verifier (128 random characters)
final verifier = generateCodeVerifier();

// Generate code challenge (SHA256 hash)
final challenge = generateCodeChallenge(verifier);

// Send challenge in authorization request
// Send verifier in token exchange
```

### URL Cleanup (Web)

After OAuth callback, remove sensitive data from URL:

```dart
// Remove code from URL after exchange
if (uri.queryParameters.containsKey('code')) {
  window.history.replaceState(
    null,
    '',
    uri.path // Clean URL without query params
  );
}
```

### CSRF Protection

Use state parameter in OAuth flow:

```dart
final state = generateRandomState();
// Store state in session
// Send state in authorization request
// Verify state in callback
```

---

## Build Commands

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### Web
```bash
flutter build web --release --web-renderer html
```

### Development
```bash
# Android
flutter run

# Web
flutter run -d chrome

# Web with specific URL
flutter run -d chrome --web-port=8080 --web-hostname=localhost
```

---

## Testing

### Test OAuth Flow

1. **Android**:
   ```bash
   adb shell am start -W -a android.intent.action.VIEW -d "uchat://oauth/callback?code=test_code&state=test_state"
   ```

2. **Web**:
   - Navigate to: `http://localhost:8080/oauth/callback?code=test_code&state=test_state`
   - Verify code extraction and token exchange

3. **Deep Link Handling**:
   ```dart
   test('Deep link handler extracts auth code', () {
     final uri = Uri.parse('uchat://oauth/callback?code=abc123');
     final handler = DeepLinkHandler();
     
     expect(handler.isOAuthCallback(uri), isTrue);
     expect(handler.extractAuthCode(uri), equals('abc123'));
   });
   ```

---

## Troubleshooting

### Android Deep Links Not Working

1. Verify AndroidManifest.xml configuration
2. Check app is set as default handler:
   ```bash
   adb shell dumpsys package d
   ```
3. Test deep link:
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "uchat://oauth/callback"
   ```

### Web OAuth Redirect Not Working

1. Check nginx configuration
2. Verify CORS headers
3. Check browser console for errors
4. Ensure redirect URI matches uSafe ID configuration

### iOS PWA Issues

1. Verify manifest.json is accessible
2. Check that display mode is "standalone"
3. Ensure HTTPS is used
4. Test in Safari (not Chrome)

---

## Future Enhancements

### Native iOS App

When native iOS support is added:

1. Update redirect URI: `uchat://oauth/callback`
2. Configure Info.plist for deep links
3. Use secure storage (Keychain)
4. Maintain web fallback for compatibility

### HTTP-Only Cookies (Web)

For enhanced security on web:

1. Backend sets refresh token in HTTP-only cookie
2. Frontend never sees refresh token
3. Token refresh happens server-side
4. Eliminates XSS token theft risk

### Multi-Device Sync

1. Backend tracks active devices
2. Push notifications for new logins
3. Device management UI
4. Remote logout capability

---

## Support

For issues or questions:
- **Technical**: GitHub Issues
- **Security**: security@usafe.in
- **General**: support@usafe.in

---

**Built with ❤️ for multi-platform excellence**

*Version 3.0.0 - Multi-Platform Support*
