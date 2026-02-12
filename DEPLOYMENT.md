# UChat Deployment Guide

## Quick Start

This guide covers deploying UChat across all supported platforms: Android, Web, and iOS (PWA).

---

## Platform Builds

### 1. Android

#### Development Build
```bash
flutter run
```

#### Production APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Production App Bundle (Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Signing Configuration

Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=uchat-key
storeFile=/path/to/keystore.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 2. Web

#### Development
```bash
flutter run -d chrome

# With custom port
flutter run -d chrome --web-port=8080
```

#### Production Build
```bash
flutter build web --release --web-renderer html
# Output: build/web/
```

#### Build Options

**Auto renderer** (recommended):
```bash
flutter build web --release --web-renderer auto
```

**Canvas kit** (better performance, larger size):
```bash
flutter build web --release --web-renderer canvaskit
```

**HTML** (smaller size, good compatibility):
```bash
flutter build web --release --web-renderer html
```

#### Environment-Specific Builds

For different environments (dev, staging, prod):

```bash
# Development
flutter build web --release --dart-define=ENV=dev

# Staging
flutter build web --release --dart-define=ENV=staging

# Production
flutter build web --release --dart-define=ENV=prod
```

Update `app_config.dart`:
```dart
static String get apiBaseUrl {
  const env = String.fromEnvironment('ENV', defaultValue: 'prod');
  switch (env) {
    case 'dev':
      return 'https://api-dev.usafe.in';
    case 'staging':
      return 'https://api-staging.usafe.in';
    case 'prod':
    default:
      return 'https://api.usafe.in';
  }
}
```

### 3. iOS (PWA)

iOS users access UChat via web browser. No native build required for Phase 3.

**Future Native iOS**:
```bash
flutter build ios --release
# Requires macOS with Xcode
```

---

## Web Deployment to chat.usafe.in

### Option 1: Nginx (Recommended)

#### Prerequisites
- Ubuntu/Debian server
- Domain: chat.usafe.in
- SSL certificate (Let's Encrypt)

#### Step 1: Build
```bash
flutter build web --release --web-renderer html
```

#### Step 2: Install Nginx
```bash
sudo apt update
sudo apt install nginx
```

#### Step 3: Copy Build Files
```bash
sudo mkdir -p /var/www/uchat
sudo cp -r build/web/* /var/www/uchat/
sudo chown -R www-data:www-data /var/www/uchat
```

#### Step 4: Nginx Configuration

Create `/etc/nginx/sites-available/uchat`:

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name chat.usafe.in;
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name chat.usafe.in;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/chat.usafe.in/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/chat.usafe.in/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Root directory
    root /var/www/uchat;
    index index.html;

    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # CORS for uSafe ID
    add_header Access-Control-Allow-Origin "https://id.usafe.in" always;
    add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;
    add_header Access-Control-Allow-Credentials "true" always;

    # Handle Flutter routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # OAuth callback (ensure proper routing)
    location /oauth/callback {
        try_files $uri /index.html;
    }

    # Static assets caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|map)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Service worker (no cache)
    location = /flutter_service_worker.js {
        add_header Cache-Control "no-cache";
        expires 0;
    }

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
    gzip_disable "msie6";
}
```

#### Step 5: Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/uchat /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Step 6: SSL Certificate (Let's Encrypt)
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d chat.usafe.in
```

### Option 2: Docker

#### Dockerfile
```dockerfile
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy Flutter web build
COPY build/web /usr/share/nginx/html

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/index.html || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

#### nginx.conf for Docker
```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### Build and Run
```bash
# Build Flutter app
flutter build web --release

# Build Docker image
docker build -t uchat-web:latest .

# Run container
docker run -d \
  --name uchat-web \
  -p 80:80 \
  -p 443:443 \
  uchat-web:latest
```

#### Docker Compose
```yaml
version: '3.8'

services:
  uchat-web:
    image: uchat-web:latest
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/nginx/ssl:ro
    restart: unless-stopped
    environment:
      - NGINX_HOST=chat.usafe.in
      - NGINX_PORT=80
```

### Option 3: Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Select build/web as public directory
# Configure as single-page app: Yes
# Don't overwrite index.html

# Deploy
firebase deploy --only hosting
```

### Option 4: Cloudflare Pages

1. Connect GitHub repository
2. Build command: `flutter build web --release`
3. Output directory: `build/web`
4. Deploy

---

## OAuth Configuration in uSafe ID

### Register Redirect URIs

In uSafe ID backend, register these redirect URIs for your OAuth client:

```json
{
  "client_id": "uchat-mobile-client",
  "redirect_uris": [
    "uchat://oauth/callback",
    "https://chat.usafe.in/oauth/callback",
    "http://localhost:8080/oauth/callback"
  ],
  "allowed_scopes": ["openid", "profile", "email", "chat"],
  "client_name": "UChat Multi-Platform"
}
```

### Update App Config

In `lib/core/config/app_config.dart`, ensure:
```dart
static const String clientId = 'uchat-mobile-client';
```

---

## Testing Deployments

### Android

1. **Install APK**:
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Test Deep Link**:
   ```bash
   adb shell am start -W -a android.intent.action.VIEW \
     -d "uchat://oauth/callback?code=test_code&state=test_state"
   ```

3. **Check Logs**:
   ```bash
   adb logcat | grep Flutter
   ```

### Web

1. **Local Testing**:
   ```bash
   cd build/web
   python3 -m http.server 8080
   ```
   Navigate to: http://localhost:8080

2. **Test OAuth Callback**:
   Navigate to: http://localhost:8080/oauth/callback?code=test&state=test

3. **Test on Mobile**:
   - Connect phone to same WiFi
   - Find computer IP: `ifconfig` or `ipconfig`
   - Navigate to: http://[YOUR_IP]:8080

### iOS PWA

1. Open Safari on iOS
2. Navigate to https://chat.usafe.in
3. Tap Share button
4. Select "Add to Home Screen"
5. Verify app opens in standalone mode

---

## Monitoring & Logging

### Nginx Access Logs
```bash
sudo tail -f /var/log/nginx/access.log
```

### Nginx Error Logs
```bash
sudo tail -f /var/log/nginx/error.log
```

### Application Logs

For production, integrate logging service:

```dart
// lib/core/logging/logger.dart
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    
    // Send errors to Sentry
    if (record.level >= Level.SEVERE) {
      Sentry.captureMessage(
        record.message,
        level: SentryLevel.error,
      );
    }
  });
}
```

---

## Performance Optimization

### Web Performance

1. **Enable Gzip** (already in nginx config)
2. **Cache Static Assets** (already configured)
3. **Use CDN** for static files:
   ```bash
   # Upload build/web assets to CDN
   # Update base href in index.html
   ```

4. **Lazy Loading**:
   ```dart
   // Use deferred imports
   import 'package:uchat/features/chat/chat.dart' deferred as chat;
   
   // Load when needed
   await chat.loadLibrary();
   ```

### Android Optimization

1. **ProGuard/R8** (already enabled in release builds)
2. **App Bundle** (smaller download size)
3. **Split APKs** by architecture:
   ```bash
   flutter build apk --release --split-per-abi
   ```

---

## CI/CD Pipeline

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy UChat

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web --release
      - uses: actions/upload-artifact@v3
        with:
          name: web-build
          path: build/web

  deploy-web:
    needs: build-web
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: web-build
      - name: Deploy to Server
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_KEY }}
          source: "."
          target: "/var/www/uchat"
```

---

## Rollback Plan

### Web Rollback

Keep previous builds:
```bash
# Before deploying new version
sudo cp -r /var/www/uchat /var/www/uchat.backup.$(date +%Y%m%d)

# Rollback if needed
sudo rm -rf /var/www/uchat
sudo cp -r /var/www/uchat.backup.YYYYMMDD /var/www/uchat
sudo systemctl restart nginx
```

### Android Rollback

Google Play Console allows rollback to previous versions.

---

## Support & Maintenance

### Health Checks

```bash
# Check if web app is running
curl -I https://chat.usafe.in

# Check SSL certificate
echo | openssl s_client -servername chat.usafe.in -connect chat.usafe.in:443 2>/dev/null | openssl x509 -noout -dates
```

### Automated Monitoring

Use services like:
- Uptime Robot
- Pingdom
- New Relic
- Datadog

---

## Troubleshooting

### Web App Not Loading

1. Check nginx status: `sudo systemctl status nginx`
2. Check nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Verify files exist: `ls -la /var/www/uchat`
4. Test nginx config: `sudo nginx -t`

### Deep Links Not Working (Android)

1. Verify manifest configuration
2. Check default app settings on device
3. Test with adb command
4. Clear app defaults: Settings > Apps > UChat > Open by default

### OAuth Redirect Issues

1. Verify redirect URI in uSafe ID matches exactly
2. Check CORS headers in response
3. Verify network connectivity
4. Check browser console for errors

---

**Ready for Production Deployment!** 🚀
