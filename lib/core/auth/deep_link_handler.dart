import 'dart:async';
import 'package:uni_links/uni_links.dart';
import '../utils/platform_info.dart';

/// Deep link handler for OAuth callbacks
class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal();
  
  StreamSubscription? _linkSubscription;
  final StreamController<Uri> _linkController = StreamController<Uri>.broadcast();
  
  /// Stream of incoming deep links
  Stream<Uri> get linkStream => _linkController.stream;
  
  /// Initialize deep link listening (Android/iOS only)
  Future<void> initialize() async {
    if (!PlatformInfo.supportsDeepLinks) {
      return; // Web doesn't use deep links
    }
    
    try {
      // Check for initial link (app opened via deep link)
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _linkController.add(Uri.parse(initialLink));
      }
      
      // Listen for links while app is running
      _linkSubscription = linkStream.listen(
        (link) {
          _linkController.add(link);
        },
        onError: (err) {
          // Handle error
        },
      );
    } catch (e) {
      // Deep link initialization failed
    }
  }
  
  /// Check if URI is an OAuth callback
  bool isOAuthCallback(Uri uri) {
    if (PlatformInfo.isAndroid) {
      // Android: uchat://oauth/callback
      return uri.scheme == 'uchat' && 
             uri.host == 'oauth' && 
             uri.path == '/callback';
    } else if (PlatformInfo.isIOS) {
      // iOS might use universal links in the future
      return uri.host == 'chat.usafe.in' && 
             uri.path.startsWith('/oauth/callback');
    }
    return false;
  }
  
  /// Extract authorization code from OAuth callback URI
  String? extractAuthCode(Uri uri) {
    return uri.queryParameters['code'];
  }
  
  /// Extract state parameter from OAuth callback URI
  String? extractState(Uri uri) {
    return uri.queryParameters['state'];
  }
  
  /// Extract error from OAuth callback URI
  String? extractError(Uri uri) {
    return uri.queryParameters['error'];
  }
  
  /// Dispose of the deep link handler
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
  }
}
