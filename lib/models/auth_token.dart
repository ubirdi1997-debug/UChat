import 'package:equatable/equatable.dart';

/// OAuth token model
class AuthToken extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;
  final List<String> scopes;
  
  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.issuedAt,
    this.scopes = const [],
  });
  
  /// Check if access token is expired
  bool get isExpired {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expiryTime);
  }
  
  /// Check if access token needs refresh (with buffer time)
  bool needsRefresh({Duration buffer = const Duration(minutes: 2)}) {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    final refreshTime = expiryTime.subtract(buffer);
    return DateTime.now().isAfter(refreshTime);
  }
  
  /// Get time until expiry
  Duration get timeUntilExpiry {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    final now = DateTime.now();
    if (now.isAfter(expiryTime)) {
      return Duration.zero;
    }
    return expiryTime.difference(now);
  }
  
  /// Create from JSON response
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int,
      issuedAt: DateTime.now(),
      scopes: json['scope'] != null 
          ? (json['scope'] as String).split(' ')
          : [],
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'issued_at': issuedAt.toIso8601String(),
      'scope': scopes.join(' '),
    };
  }
  
  /// Create a copy with updated fields
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    List<String>? scopes,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      scopes: scopes ?? this.scopes,
    );
  }
  
  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    tokenType,
    expiresIn,
    issuedAt,
    scopes,
  ];
}
