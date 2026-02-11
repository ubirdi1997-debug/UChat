import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../../../core/auth/auth_service.dart';

/// Authentication state
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthStateNotifier(this._authService) : super(AuthState.initial);
  
  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  
  /// Initialize authentication
  Future<void> initialize() async {
    state = AuthState.loading;
    
    try {
      final hasSession = await _authService.initialize();
      state = hasSession ? AuthState.authenticated : AuthState.unauthenticated;
    } catch (e) {
      state = AuthState.unauthenticated;
    }
  }
  
  /// Login
  Future<void> login() async {
    state = AuthState.loading;
    
    try {
      await _authService.login();
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.unauthenticated;
      rethrow;
    }
  }
  
  /// Logout
  Future<void> logout() async {
    state = AuthState.loading;
    
    try {
      await _authService.logout();
    } finally {
      state = AuthState.unauthenticated;
    }
  }
  
  /// Refresh session
  Future<void> refreshSession() async {
    try {
      await _authService.refreshSession();
      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.unauthenticated;
    }
  }
}

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});
