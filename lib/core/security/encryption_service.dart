import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

/// End-to-end encryption service for messages
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();
  
  /// Generate a new encryption key
  String generateKey() {
    final key = encrypt.Key.fromSecureRandom(32);
    return base64Encode(key.bytes);
  }
  
  /// Encrypt a message
  String encryptMessage(String message, String keyString) {
    try {
      final key = encrypt.Key(base64Decode(keyString));
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final encrypted = encrypter.encrypt(message, iv: iv);
      
      // Combine IV and encrypted data
      final combined = '${base64Encode(iv.bytes)}:${encrypted.base64}';
      return combined;
    } catch (e) {
      throw EncryptionException('Failed to encrypt message: $e');
    }
  }
  
  /// Decrypt a message
  String decryptMessage(String encryptedMessage, String keyString) {
    try {
      final parts = encryptedMessage.split(':');
      if (parts.length != 2) {
        throw EncryptionException('Invalid encrypted message format');
      }
      
      final key = encrypt.Key(base64Decode(keyString));
      final iv = encrypt.IV(base64Decode(parts[0]));
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final decrypted = encrypter.decrypt64(parts[1], iv: iv);
      return decrypted;
    } catch (e) {
      throw EncryptionException('Failed to decrypt message: $e');
    }
  }
  
  /// Encrypt file data
  Uint8List encryptFile(Uint8List data, String keyString) {
    try {
      final key = encrypt.Key(base64Decode(keyString));
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      final encrypted = encrypter.encryptBytes(data, iv: iv);
      
      // Prepend IV to encrypted data
      final result = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
      return result;
    } catch (e) {
      throw EncryptionException('Failed to encrypt file: $e');
    }
  }
  
  /// Decrypt file data
  Uint8List decryptFile(Uint8List encryptedData, String keyString) {
    try {
      final key = encrypt.Key(base64Decode(keyString));
      
      // Extract IV from first 16 bytes
      final iv = encrypt.IV(Uint8List.fromList(encryptedData.sublist(0, 16)));
      final encrypted = encrypt.Encrypted(Uint8List.fromList(encryptedData.sublist(16)));
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(encrypted, iv: iv);
      
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw EncryptionException('Failed to decrypt file: $e');
    }
  }
  
  /// Generate hash of data
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);
  
  @override
  String toString() => 'EncryptionException: $message';
}
