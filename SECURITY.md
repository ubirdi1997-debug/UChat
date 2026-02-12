# Security Guide - UChat

## Overview

UChat implements enterprise-grade security practices to protect user data and authentication credentials. This document outlines the security architecture and best practices.

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Security Layers                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Layer 1: Network Security                              │
│  ├─ HTTPS only (TLS 1.2+)                              │
│  ├─ Certificate validation                              │
│  └─ Request timeout protection                          │
│                                                          │
│  Layer 2: Authentication Security                       │
│  ├─ OAuth 2.0 Authorization Code Flow                   │
│  ├─ PKCE (Proof Key for Code Exchange)                 │
│  ├─ No client secrets                                   │
│  └─ Secure random generation                            │
│                                                          │
│  Layer 3: Token Security                                │
│  ├─ Access token in memory only                         │
│  ├─ Refresh token encrypted at rest                     │
│  ├─ Token rotation on refresh                           │
│  └─ Automatic expiry handling                           │
│                                                          │
│  Layer 4: Storage Security                              │
│  ├─ iOS: Keychain (hardware-backed)                     │
│  ├─ Android: Keystore (AES encryption)                  │
│  └─ No sensitive data in SharedPreferences              │
│                                                          │
│  Layer 5: Application Security                          │
│  ├─ No tokens in logs (production)                      │
│  ├─ Session validation on startup                       │
│  ├─ Secure memory management                            │
│  └─ Clean logout with data wipe                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Authentication Security

### OAuth 2.0 with PKCE

**Why PKCE?**

PKCE (RFC 7636) protects against authorization code interception attacks. It's essential for mobile apps where client secrets cannot be safely stored.

**How it Works:**

1. **Code Verifier Generation**
   ```
   - Generate 128 cryptographically random bytes
   - Base64URL encode
   - Remove padding
   - Result: 128-character random string
   ```

2. **Code Challenge Generation**
   ```
   - SHA-256 hash of code verifier
   - Base64URL encode
   - Remove padding
   - Result: Challenge sent to authorization server
   ```

3. **Authorization Request**
   ```
   Include: code_challenge, code_challenge_method=S256
   Server stores the challenge
   ```

4. **Token Exchange**
   ```
   Include: code_verifier
   Server verifies: SHA256(verifier) == stored_challenge
   ```

**Security Properties:**
- ✅ Protects against code interception
- ✅ No client secret needed
- ✅ Prevents token replay attacks
- ✅ One-time use authorization codes

### Token Lifecycle

#### Access Token
- **Lifespan**: 15 minutes
- **Storage**: Memory only
- **Purpose**: API authentication
- **Rotation**: Every refresh

**Why memory only?**
- Reduces attack surface
- Auto-cleared on app termination
- Cannot be extracted from device storage

#### Refresh Token
- **Lifespan**: 30 days
- **Storage**: Platform secure storage (encrypted)
- **Purpose**: Obtain new access tokens
- **Rotation**: Supported (token rotation)

**Security Measures:**
- Encrypted at rest (AES-256)
- Hardware-backed on supported devices
- Cleared on logout
- Revoked on server on logout

## Storage Security

### iOS Keychain

```swift
kSecAttrAccessible = kSecAttrAccessibleAfterFirstUnlock
```

**Features:**
- Hardware-backed encryption (when available)
- Automatic encryption at rest
- Protected by device passcode
- Survives app reinstall (configurable)

**Access Control:**
- Only accessible by UChat app
- Requires device unlock
- Can use biometric protection

### Android Keystore

```kotlin
EncryptedSharedPreferences with AES-256
```

**Features:**
- Hardware-backed keys (Android 6.0+)
- StrongBox support (Android 9.0+)
- AES-256 encryption
- Key isolation in hardware

**Access Control:**
- App-specific keys
- Protected by Android security
- Cannot be extracted without root

## Network Security

### TLS Configuration

```dart
// Enforced by platform
- TLS 1.2 minimum
- Strong cipher suites only
- Certificate validation enabled
```

### Request Protection

```dart
- Connection timeout: 30s
- Receive timeout: 30s
- Request retry with exponential backoff
- Automatic token refresh before expiry
```

### Certificate Pinning (Future)

```dart
// Planned for enhanced security
dio.interceptors.add(
  CertificatePinningInterceptor(
    allowedSHAFingerprints: [...],
  ),
);
```

## Session Management

### Session Validation

```dart
On App Launch:
1. Check for refresh token in secure storage
2. If exists, attempt silent refresh
3. If refresh succeeds → authenticated
4. If refresh fails → clear session, show login
```

### Token Refresh Strategy

```
Access Token Timeline:
0 min  ────────────── 13 min ─────────── 15 min
 ↓                       ↓                  ↓
Issue              Refresh Buffer        Expiry

Auto-refresh triggered at 13 minutes (2-minute buffer)
```

**Refresh Triggers:**
1. **Proactive**: Before each API call if near expiry
2. **Reactive**: On 401 Unauthorized response
3. **Periodic**: Background refresh (if app is active)

### Logout Security

```dart
Logout Process:
1. Revoke refresh token on server
2. Clear access token from memory
3. Delete refresh token from secure storage
4. Clear all app state
5. Navigate to login screen
```

**Force Logout Scenarios:**
- User initiates logout
- Refresh token expired
- Refresh token revoked by server
- Token validation fails
- Security policy violation

## Data Protection

### What is Stored Securely

| Data | Storage | Encryption |
|------|---------|------------|
| Refresh Token | Secure Storage | ✅ AES-256 |
| Token Expiry | Secure Storage | ✅ AES-256 |
| User ID | Secure Storage | ✅ AES-256 |

### What is NOT Stored

- ❌ Access tokens (memory only)
- ❌ Passwords (OAuth flow, no local passwords)
- ❌ User credentials
- ❌ PKCE code verifiers (one-time use)

### Log Security

**Development Mode:**
```dart
// Safe to log structure, NOT values
debugPrint('Token received: [${token.tokenType}]');
debugPrint('Expires in: ${token.expiresIn}s');
```

**Production Mode:**
```dart
// NO token logging
// Use error tracking (Sentry) without token values
```

## Vulnerability Mitigation

### Authorization Code Interception

**Threat**: Attacker intercepts authorization code

**Mitigation**: 
- ✅ PKCE implementation
- ✅ One-time use codes
- ✅ Code expiry (typically 60 seconds)
- ✅ Redirect URI validation

### Token Theft

**Threat**: Attacker steals stored tokens

**Mitigation**:
- ✅ No access tokens persisted
- ✅ Refresh tokens encrypted at rest
- ✅ Hardware-backed encryption
- ✅ Token rotation on refresh

### Man-in-the-Middle (MITM)

**Threat**: Network traffic interception

**Mitigation**:
- ✅ HTTPS only (enforced)
- ✅ TLS 1.2+ minimum
- ✅ Certificate validation
- ⏳ Certificate pinning (planned)

### Replay Attacks

**Threat**: Reuse of captured requests

**Mitigation**:
- ✅ One-time authorization codes
- ✅ Short-lived access tokens
- ✅ Token rotation
- ✅ Server-side request validation

### Session Fixation

**Threat**: Attacker forces known session

**Mitigation**:
- ✅ Server-issued tokens only
- ✅ Cryptographically random tokens
- ✅ No predictable token generation

## Security Best Practices

### For Developers

1. **Never log tokens**
   ```dart
   // ❌ NEVER
   print('Token: ${token.accessToken}');
   
   // ✅ SAFE
   debugPrint('Token received (length: ${token.accessToken.length})');
   ```

2. **Always use secure storage**
   ```dart
   // ❌ NEVER
   SharedPreferences.setString('refresh_token', token);
   
   // ✅ SECURE
   SecureStorageService().write('refresh_token', token);
   ```

3. **Validate token before use**
   ```dart
   if (token.needsRefresh()) {
     await authService.refreshSession();
   }
   ```

4. **Handle errors securely**
   ```dart
   try {
     await apiCall();
   } catch (e) {
     // ❌ Don't expose sensitive details
     throw 'Request failed';
     
     // ✅ Log securely, show generic message
     logger.error('API call failed', error: e);
     throw ApiException('Request failed');
   }
   ```

### For Users

1. **Keep app updated** - Security patches are critical
2. **Use device lock** - Protects keychain/keystore
3. **Logout when needed** - Revokes tokens
4. **Report suspicious activity** - Security team monitors

## Compliance

### Standards

- ✅ OAuth 2.0 (RFC 6749)
- ✅ PKCE (RFC 7636)
- ✅ OAuth 2.0 for Native Apps (RFC 8252)
- ✅ OWASP Mobile Security

### Data Protection

- Minimal data collection
- No unnecessary permissions
- Transparent data usage
- User-controlled data deletion

## Incident Response

### If Token is Compromised

1. **User Action**: Logout from app
2. **Server Action**: Revoke all tokens for user
3. **App Action**: Force re-authentication
4. **Notify**: Security team

### If Vulnerability is Found

1. **Report**: security@usafe.in
2. **Assessment**: Security team evaluates
3. **Patch**: Fix implemented and tested
4. **Release**: Emergency update if critical
5. **Disclosure**: Responsible disclosure timeline

## Security Audit Checklist

- [ ] OAuth implementation reviewed
- [ ] PKCE correctly implemented
- [ ] Tokens properly stored
- [ ] Network security verified
- [ ] Logging audited (no sensitive data)
- [ ] Session management tested
- [ ] Logout properly clears data
- [ ] Error handling doesn't leak info
- [ ] Dependencies up to date
- [ ] Security scan passed

## Future Security Enhancements

### Phase 2
- Certificate pinning
- Biometric authentication
- Advanced threat detection
- Runtime security checks

### Phase 3
- End-to-end encryption
- Perfect Forward Secrecy
- Hardware security module integration
- Zero-knowledge architecture

## References

- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)
- [OAuth 2.0 for Native Apps RFC 8252](https://tools.ietf.org/html/rfc8252)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

---

**Security is a continuous process. Stay vigilant! 🔒**
