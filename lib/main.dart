import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'core/auth/deep_link_handler.dart';
import 'core/utils/platform_info.dart';
import 'features/auth/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set URL strategy for web (removes # from URLs)
  if (PlatformInfo.isWeb) {
    setPathUrlStrategy();
  }
  
  // Initialize deep link handler for mobile
  if (PlatformInfo.supportsDeepLinks) {
    await DeepLinkHandler().initialize();
  }
  
  runApp(
    const ProviderScope(
      child: UChatApp(),
    ),
  );
}

class UChatApp extends StatelessWidget {
  const UChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
