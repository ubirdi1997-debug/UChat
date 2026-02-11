import 'package:flutter_test/flutter_test.dart';
import 'package:uchat/core/auth/pkce_service.dart';

void main() {
  group('PKCEService', () {
    late PKCEService pkceService;

    setUp(() {
      pkceService = PKCEService();
    });

    test('generates code verifier of correct length', () {
      final verifier = pkceService.generateCodeVerifier();
      
      expect(verifier.length, equals(128));
      expect(verifier, matches(RegExp(r'^[A-Za-z0-9\-_]+$')));
    });

    test('generates different code verifiers each time', () {
      final verifier1 = pkceService.generateCodeVerifier();
      final verifier2 = pkceService.generateCodeVerifier();
      
      expect(verifier1, isNot(equals(verifier2)));
    });

    test('generates code challenge from verifier', () {
      final verifier = pkceService.generateCodeVerifier();
      final challenge = pkceService.generateCodeChallenge(verifier);
      
      expect(challenge, isNotEmpty);
      expect(challenge, matches(RegExp(r'^[A-Za-z0-9\-_]+$')));
    });

    test('generates consistent challenge for same verifier', () {
      final verifier = 'test-verifier-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
      final challenge1 = pkceService.generateCodeChallenge(verifier);
      final challenge2 = pkceService.generateCodeChallenge(verifier);
      
      expect(challenge1, equals(challenge2));
    });

    test('generates PKCE pair with verifier and challenge', () {
      final pair = pkceService.generatePKCEPair();
      
      expect(pair.codeVerifier, isNotEmpty);
      expect(pair.codeChallenge, isNotEmpty);
      expect(pair.codeVerifier.length, equals(128));
    });

    test('PKCE pair challenge matches verifier', () {
      final pair = pkceService.generatePKCEPair();
      final expectedChallenge = pkceService.generateCodeChallenge(pair.codeVerifier);
      
      expect(pair.codeChallenge, equals(expectedChallenge));
    });
  });
}
