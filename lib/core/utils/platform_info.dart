import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform detection utility for multi-platform support
class PlatformInfo {
  /// Check if running on web
  static bool get isWeb => kIsWeb;
  
  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Check if running on mobile (Android or iOS)
  static bool get isMobile => isAndroid || isIOS;
  
  /// Check if running on desktop (Windows, macOS, Linux)
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  
  /// Get platform name
  static String get platformName {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
  
  /// Check if PWA install is supported (iOS Safari)
  static bool get supportsPWA => isWeb;
  
  /// Check if deep links are supported
  static bool get supportsDeepLinks => isAndroid || isIOS;
}
