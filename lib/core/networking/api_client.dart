import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../auth/auth_service.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// API client with automatic token refresh
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _initializeDio();
  }
  
  late final Dio _dio;
  
  Dio get dio => _dio;
  
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add auth interceptor
    _dio.interceptors.add(AuthInterceptor(AuthService()));
    
    // Add logger in debug mode
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }
  
  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Handle API errors
  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException('Connection timeout', statusCode: 408);
          
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 500;
          final message = error.response?.data?['message'] as String? ??
              error.response?.statusMessage ??
              'Request failed';
          return ApiException(message, statusCode: statusCode);
          
        case DioExceptionType.cancel:
          return ApiException('Request cancelled', statusCode: 499);
          
        case DioExceptionType.connectionError:
          return ApiException('No internet connection', statusCode: 503);
          
        default:
          return ApiException('Unknown error occurred', statusCode: 500);
      }
    }
    
    return ApiException('Unknown error: $error', statusCode: 500);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, {required this.statusCode});
  
  @override
  String toString() => 'ApiException($statusCode): $message';
}
