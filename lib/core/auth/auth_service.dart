import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import '../../models/auth_token.dart';
import '../../models/user.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'pkce_service.dart';

/// Authentication service for uSafe ID OAuth 2.0 with PKCE
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final SecureStorageService _secureStorage = SecureStorageService();
  final PKCEService _pkceService = PKCEService();
  final Dio _dio = Dio();
  
  AuthToken? _currentToken;
  User? _currentUser;
  
  /// Get current auth token (from memory)
  AuthToken? get currentToken => _currentToken;
  
  /// Get current user
  User? get currentUser => _currentUser;
  
  /// Check if user is authenticated
  bool get isAuthenticated => _currentToken != null && !_currentToken!.isExpired;
  
  /// Initialize auth service - check for existing session
  Future<bool> initialize() async {
    try {
      // Try to load refresh token from secure storage
      final refreshToken = await _secureStorage.read(AppConfig.storageKeyRefreshToken);
      
      if (refreshToken != null) {
        // Try to refresh the session
        final success = await refreshSession();
        if (success) {
          // Load user info
          await loadUserInfo();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      // Silent fail - user needs to login
      return false;
    }
  }
  
  /// Start OAuth 2.0 login flow with PKCE
  Future<AuthToken> login() async {
    try {
      // Generate PKCE pair
      final pkcePair = _pkceService.generatePKCEPair();
      
      // Start OAuth flow
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AppConfig.clientId,
          AppConfig.redirectUrl,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: AppConfig.authorizationEndpoint,
            tokenEndpoint: AppConfig.tokenEndpoint,
          ),
          scopes: AppConfig.scopes,
          codeVerifier: pkcePair.codeVerifier,
          preferEphemeralSession: true,
        ),
      );
      
      if (result == null) {
        throw AuthException('OAuth flow was cancelled');
      }
      
      // Create token from response
      final token = AuthToken(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken,
        tokenType: result.tokenType ?? 'Bearer',
        expiresIn: result.accessTokenExpirationDateTime != null
            ? result.accessTokenExpirationDateTime!.difference(DateTime.now()).inSeconds
            : 900, // Default 15 minutes
        issuedAt: DateTime.now(),
        scopes: AppConfig.scopes,
      );
      
      // Store token
      await _storeToken(token);
      _currentToken = token;
      
      // Load user info
      await loadUserInfo();
      
      return token;
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }
  
  /// Refresh access token using refresh token
  Future<bool> refreshSession() async {
    try {
      final refreshToken = await _secureStorage.read(AppConfig.storageKeyRefreshToken);
      
      if (refreshToken == null) {
        return false;
      }
      
      final result = await _appAuth.token(
        TokenRequest(
          AppConfig.clientId,
          AppConfig.redirectUrl,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: AppConfig.authorizationEndpoint,
            tokenEndpoint: AppConfig.tokenEndpoint,
          ),
          refreshToken: refreshToken,
        ),
      );
      
      if (result == null) {
        return false;
      }
      
      // Create new token
      final token = AuthToken(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken ?? refreshToken,
        tokenType: result.tokenType ?? 'Bearer',
        expiresIn: result.accessTokenExpirationDateTime != null
            ? result.accessTokenExpirationDateTime!.difference(DateTime.now()).inSeconds
            : 900,
        issuedAt: DateTime.now(),
        scopes: AppConfig.scopes,
      );
      
      // Store new token
      await _storeToken(token);
      _currentToken = token;
      
      return true;
    } catch (e) {
      // Refresh failed - clear session
      await logout();
      return false;
    }
  }
  
  /// Load user information from uSafe ID
  Future<User> loadUserInfo() async {
    try {
      if (_currentToken == null) {
        throw AuthException('No active session');
      }
      
      final response = await _dio.get(
        AppConfig.userInfoEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_currentToken!.accessToken}',
          },
        ),
      );
      
      _currentUser = User.fromJson(response.data);
      return _currentUser!;
    } catch (e) {
      throw AuthException('Failed to load user info: $e');
    }
  }
  
  /// Logout and revoke tokens
  Future<void> logout() async {
    try {
      // Revoke refresh token if available
      final refreshToken = await _secureStorage.read(AppConfig.storageKeyRefreshToken);
      
      if (refreshToken != null) {
        try {
          await _dio.post(
            AppConfig.logoutEndpoint,
            data: {
              'token': refreshToken,
              'client_id': AppConfig.clientId,
            },
          );
        } catch (e) {
          // Ignore revocation errors
        }
      }
    } finally {
      // Clear local session regardless of server response
      _currentToken = null;
      _currentUser = null;
      await _secureStorage.deleteAll();
    }
  }
  
  /// Store token securely
  Future<void> _storeToken(AuthToken token) async {
    if (token.refreshToken != null) {
      await _secureStorage.write(
        AppConfig.storageKeyRefreshToken,
        token.refreshToken!,
      );
    }
    
    final expiry = token.issuedAt.add(Duration(seconds: token.expiresIn));
    await _secureStorage.write(
      AppConfig.storageKeyTokenExpiry,
      expiry.toIso8601String(),
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}
