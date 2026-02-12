import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/platform_info.dart';
import '../security/encryption_service.dart';

/// Platform-aware secure storage service
/// - Android/iOS: Uses flutter_secure_storage (Keychain/Keystore)
/// - Web: Uses encrypted localStorage via shared_preferences
class PlatformStorageService {
  static final PlatformStorageService _instance = PlatformStorageService._internal();
  factory PlatformStorageService() => _instance;
  PlatformStorageService._internal();
  
  final FlutterSecureStorage? _secureStorage = PlatformInfo.isMobile
      ? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        )
      : null;
  
  final EncryptionService _encryptionService = EncryptionService();
  
  // Web storage key for encryption
  static const String _webEncryptionKey = 'uchat_web_storage_key_v1';
  
  /// Write a value to secure storage
  Future<void> write(String key, String value) async {
    try {
      if (PlatformInfo.isMobile && _secureStorage != null) {
        // Use platform secure storage for mobile
        await _secureStorage!.write(key: key, value: value);
      } else if (PlatformInfo.isWeb) {
        // Use encrypted localStorage for web
        final prefs = await SharedPreferences.getInstance();
        
        // Get or generate encryption key for web
        String? encKey = prefs.getString(_webEncryptionKey);
        if (encKey == null) {
          encKey = _encryptionService.generateKey();
          await prefs.setString(_webEncryptionKey, encKey);
        }
        
        // Encrypt the value
        final encrypted = _encryptionService.encryptMessage(value, encKey);
        await prefs.setString(key, encrypted);
      }
    } catch (e) {
      throw PlatformStorageException('Failed to write to storage: $e');
    }
  }
  
  /// Read a value from secure storage
  Future<String?> read(String key) async {
    try {
      if (PlatformInfo.isMobile && _secureStorage != null) {
        // Read from platform secure storage
        return await _secureStorage!.read(key: key);
      } else if (PlatformInfo.isWeb) {
        // Read from encrypted localStorage
        final prefs = await SharedPreferences.getInstance();
        final encKey = prefs.getString(_webEncryptionKey);
        
        if (encKey == null) return null;
        
        final encrypted = prefs.getString(key);
        if (encrypted == null) return null;
        
        // Decrypt the value
        try {
          return _encryptionService.decryptMessage(encrypted, encKey);
        } catch (e) {
          // If decryption fails, return null (corrupted data)
          return null;
        }
      }
      return null;
    } catch (e) {
      throw PlatformStorageException('Failed to read from storage: $e');
    }
  }
  
  /// Delete a value from secure storage
  Future<void> delete(String key) async {
    try {
      if (PlatformInfo.isMobile && _secureStorage != null) {
        await _secureStorage!.delete(key: key);
      } else if (PlatformInfo.isWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      }
    } catch (e) {
      throw PlatformStorageException('Failed to delete from storage: $e');
    }
  }
  
  /// Delete all values from secure storage
  Future<void> deleteAll() async {
    try {
      if (PlatformInfo.isMobile && _secureStorage != null) {
        await _secureStorage!.deleteAll();
      } else if (PlatformInfo.isWeb) {
        final prefs = await SharedPreferences.getInstance();
        // Only clear UChat-related keys, not all SharedPreferences
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith('uchat_') || key.contains('token') || key.contains('auth')) {
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      throw PlatformStorageException('Failed to clear storage: $e');
    }
  }
  
  /// Check if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    try {
      if (PlatformInfo.isMobile && _secureStorage != null) {
        final value = await _secureStorage!.read(key: key);
        return value != null;
      } else if (PlatformInfo.isWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.containsKey(key);
      }
      return false;
    } catch (e) {
      throw PlatformStorageException('Failed to check key in storage: $e');
    }
  }
}

class PlatformStorageException implements Exception {
  final String message;
  PlatformStorageException(this.message);
  
  @override
  String toString() => 'PlatformStorageException: $message';
}
