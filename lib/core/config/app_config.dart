/// Application-wide configuration constants
class AppConfig {
  static const String appName = 'UChat';
  static const String appVersion = '1.0.0';
  
  // uSafe ID OAuth Configuration
  static const String authBaseUrl = 'https://id.usafe.in';
  static const String authorizationEndpoint = '$authBaseUrl/oauth/authorize';
  static const String tokenEndpoint = '$authBaseUrl/oauth/token';
  static const String logoutEndpoint = '$authBaseUrl/oauth/revoke';
  static const String userInfoEndpoint = '$authBaseUrl/oauth/userinfo';
  
  // OAuth Client Configuration
  static const String clientId = 'uchat-mobile-client';
  static const String redirectUrl = 'in.usafe.uchat://oauth-callback';
  static const List<String> scopes = ['openid', 'profile', 'email', 'chat'];
  
  // Token Configuration
  static const Duration accessTokenLifespan = Duration(minutes: 15);
  static const Duration refreshTokenLifespan = Duration(days: 30);
  static const Duration tokenRefreshBuffer = Duration(minutes: 2);
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.usafe.in';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyTokenExpiry = 'token_expiry';
  static const String storageKeyUserId = 'user_id';
  
  // Chat Configuration
  static const int messagePageSize = 50;
  static const Duration typingIndicatorTimeout = Duration(seconds: 3);
}
