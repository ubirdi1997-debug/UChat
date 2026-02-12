import 'package:dio/dio.dart';
import '../auth/auth_service.dart';

/// HTTP interceptor for automatic token refresh
class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  final Dio _dio;
  
  AuthInterceptor(this._authService) : _dio = Dio();
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Check if token needs refresh
      final token = _authService.currentToken;
      
      if (token != null && token.needsRefresh()) {
        // Refresh token before request
        await _authService.refreshSession();
      }
      
      // Add authorization header
      final currentToken = _authService.currentToken;
      if (currentToken != null) {
        options.headers['Authorization'] = 'Bearer ${currentToken.accessToken}';
      }
      
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to refresh token: $e',
        ),
      );
    }
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      try {
        // Try to refresh token
        final refreshed = await _authService.refreshSession();
        
        if (refreshed) {
          // Retry original request with new token
          final options = err.requestOptions;
          final token = _authService.currentToken;
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer ${token.accessToken}';
          }
          
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } else {
          // Refresh failed - force logout
          await _authService.logout();
        }
      } catch (e) {
        // Refresh failed - force logout
        await _authService.logout();
      }
    }
    
    handler.next(err);
  }
}
