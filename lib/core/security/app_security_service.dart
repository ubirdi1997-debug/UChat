import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../storage/secure_storage_service.dart';

/// App security service for MPIN and biometric authentication
class AppSecurityService {
  static final AppSecurityService _instance = AppSecurityService._internal();
  factory AppSecurityService() => _instance;
  AppSecurityService._internal();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage = SecureStorageService();
  
  static const String _keyMpinEnabled = 'mpin_enabled';
  static const String _keyMpin = 'mpin_hash';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyAutoLockEnabled = 'auto_lock_enabled';
  
  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to access UChat',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
  
  /// Check if MPIN is enabled
  Future<bool> isMpinEnabled() async {
    final enabled = await _secureStorage.read(_keyMpinEnabled);
    return enabled == 'true';
  }
  
  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(_keyBiometricEnabled);
    return enabled == 'true';
  }
  
  /// Check if auto lock is enabled
  Future<bool> isAutoLockEnabled() async {
    final enabled = await _secureStorage.read(_keyAutoLockEnabled);
    return enabled == 'true';
  }
  
  /// Set MPIN
  Future<void> setMpin(String mpin) async {
    // Hash the MPIN before storing
    final hash = _hashMpin(mpin);
    await _secureStorage.write(_keyMpin, hash);
    await _secureStorage.write(_keyMpinEnabled, 'true');
  }
  
  /// Verify MPIN
  Future<bool> verifyMpin(String mpin) async {
    final storedHash = await _secureStorage.read(_keyMpin);
    if (storedHash == null) return false;
    
    final hash = _hashMpin(mpin);
    return hash == storedHash;
  }
  
  /// Enable/disable MPIN
  Future<void> setMpinEnabled(bool enabled) async {
    await _secureStorage.write(_keyMpinEnabled, enabled.toString());
  }
  
  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(_keyBiometricEnabled, enabled.toString());
  }
  
  /// Enable/disable auto lock
  Future<void> setAutoLockEnabled(bool enabled) async {
    await _secureStorage.write(_keyAutoLockEnabled, enabled.toString());
  }
  
  /// Remove MPIN
  Future<void> removeMpin() async {
    await _secureStorage.delete(_keyMpin);
    await _secureStorage.delete(_keyMpinEnabled);
  }
  
  /// Check if app needs to be locked
  Future<bool> shouldLockApp() async {
    final mpinEnabled = await isMpinEnabled();
    final biometricEnabled = await isBiometricEnabled();
    final autoLockEnabled = await isAutoLockEnabled();
    
    return (mpinEnabled || biometricEnabled) && autoLockEnabled;
  }
  
  /// Simple hash function for MPIN (in production, use a proper crypto library)
  String _hashMpin(String mpin) {
    // Simple hash - in production use proper crypto
    return mpin.split('').map((c) => c.codeUnitAt(0) * 7).join('');
  }
}
