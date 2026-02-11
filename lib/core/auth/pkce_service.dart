import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// PKCE (Proof Key for Code Exchange) utility
/// Implements RFC 7636 for OAuth 2.0 PKCE
class PKCEService {
  static final PKCEService _instance = PKCEService._internal();
  factory PKCEService() => _instance;
  PKCEService._internal();
  
  /// Generate a cryptographically random code verifier
  /// Length: 43-128 characters (using 128 for maximum security)
  String generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(96, (i) => random.nextInt(256));
    return base64UrlEncode(values)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .substring(0, 128);
  }
  
  /// Generate code challenge from code verifier using SHA-256
  String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }
  
  /// Generate both verifier and challenge
  PKCEPair generatePKCEPair() {
    final verifier = generateCodeVerifier();
    final challenge = generateCodeChallenge(verifier);
    return PKCEPair(
      codeVerifier: verifier,
      codeChallenge: challenge,
    );
  }
}

class PKCEPair {
  final String codeVerifier;
  final String codeChallenge;
  
  PKCEPair({
    required this.codeVerifier,
    required this.codeChallenge,
  });
}
