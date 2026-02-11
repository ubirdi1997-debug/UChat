import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  /// Write a value to secure storage
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException('Failed to write to secure storage: $e');
    }
  }
  
  /// Read a value from secure storage
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to read from secure storage: $e');
    }
  }
  
  /// Delete a value from secure storage
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException('Failed to delete from secure storage: $e');
    }
  }
  
  /// Delete all values from secure storage
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to clear secure storage: $e');
    }
  }
  
  /// Check if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      throw SecureStorageException('Failed to check key in secure storage: $e');
    }
  }
  
  /// Get all keys from secure storage
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw SecureStorageException('Failed to read all from secure storage: $e');
    }
  }
}

class SecureStorageException implements Exception {
  final String message;
  SecureStorageException(this.message);
  
  @override
  String toString() => 'SecureStorageException: $message';
}
