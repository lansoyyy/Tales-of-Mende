import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'theme/app_theme.dart';
import 'screens/panel1_splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to landscape — Tales of Mende is a landscape-only game
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const TalesOfMendeApp());
}

class TalesOfMendeApp extends StatelessWidget {
  const TalesOfMendeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const Panel1SplashScreen(),
    );
  }
}

// _PlaceholderHome removed — Panel1SplashScreen is now the entry point.
