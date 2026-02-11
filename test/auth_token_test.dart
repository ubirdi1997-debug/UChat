import 'package:flutter_test/flutter_test.dart';
import 'package:uchat/models/auth_token.dart';

void main() {
  group('AuthToken', () {
    test('creates token from JSON', () {
      final json = {
        'access_token': 'test_access_token',
        'refresh_token': 'test_refresh_token',
        'token_type': 'Bearer',
        'expires_in': 900,
        'scope': 'openid profile email',
      };

      final token = AuthToken.fromJson(json);

      expect(token.accessToken, equals('test_access_token'));
      expect(token.refreshToken, equals('test_refresh_token'));
      expect(token.tokenType, equals('Bearer'));
      expect(token.expiresIn, equals(900));
      expect(token.scopes, equals(['openid', 'profile', 'email']));
    });

    test('converts token to JSON', () {
      final token = AuthToken(
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        tokenType: 'Bearer',
        expiresIn: 900,
        issuedAt: DateTime(2024, 1, 1, 12, 0, 0),
        scopes: const ['openid', 'profile'],
      );

      final json = token.toJson();

      expect(json['access_token'], equals('test_access_token'));
      expect(json['refresh_token'], equals('test_refresh_token'));
      expect(json['token_type'], equals('Bearer'));
      expect(json['expires_in'], equals(900));
      expect(json['scope'], equals('openid profile'));
    });

    test('detects expired token', () {
      final expiredToken = AuthToken(
        accessToken: 'test',
        tokenType: 'Bearer',
        expiresIn: 900,
        issuedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      );

      expect(expiredToken.isExpired, isTrue);
    });

    test('detects non-expired token', () {
      final validToken = AuthToken(
        accessToken: 'test',
        tokenType: 'Bearer',
        expiresIn: 900,
        issuedAt: DateTime.now(),
      );

      expect(validToken.isExpired, isFalse);
    });

    test('detects token needs refresh', () {
      final token = AuthToken(
        accessToken: 'test',
        tokenType: 'Bearer',
        expiresIn: 900, // 15 minutes
        issuedAt: DateTime.now().subtract(const Duration(minutes: 14)),
      );

      // Should need refresh with 2 minute buffer (14 + 2 > 15)
      expect(token.needsRefresh(buffer: const Duration(minutes: 2)), isTrue);
    });

    test('token does not need refresh when fresh', () {
      final token = AuthToken(
        accessToken: 'test',
        tokenType: 'Bearer',
        expiresIn: 900, // 15 minutes
        issuedAt: DateTime.now(),
      );

      expect(token.needsRefresh(buffer: const Duration(minutes: 2)), isFalse);
    });

    test('calculates time until expiry correctly', () {
      final token = AuthToken(
        accessToken: 'test',
        tokenType: 'Bearer',
        expiresIn: 900,
        issuedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final timeLeft = token.timeUntilExpiry;
      
      // Should have approximately 10 minutes left (15 - 5)
      expect(timeLeft.inMinutes, greaterThanOrEqualTo(9));
      expect(timeLeft.inMinutes, lessThanOrEqualTo(10));
    });

    test('copyWith creates new token with updated fields', () {
      final original = AuthToken(
        accessToken: 'old_token',
        tokenType: 'Bearer',
        expiresIn: 900,
        issuedAt: DateTime.now(),
      );

      final updated = original.copyWith(accessToken: 'new_token');

      expect(updated.accessToken, equals('new_token'));
      expect(updated.tokenType, equals(original.tokenType));
      expect(updated.expiresIn, equals(original.expiresIn));
    });
  });
}
