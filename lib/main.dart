import 'package:flutter/material.dart';
import 'package:healthy_elderly/pages/login_page.dart';
import 'pages/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const HealthyElderlyApp());
}

class HealthyElderlyApp extends StatelessWidget {
  const HealthyElderlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Elderly',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF4E614D), // Primary color
          onPrimary: Colors.white,
          secondary: const Color(0xFFA6CBBC), // Secondary color
          onSecondary: Colors.white,
          background: const Color(0xFFECE9E1), // Background color
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFECE9E1),
        fontFamily: 'ThaiSansLite', // Set the default font to ThaiSansLite
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold), // Largest text
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16), // Default body text
          bodyMedium: TextStyle(fontSize: 14), // Secondary body text
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Subtitles
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Buttons
          bodySmall: TextStyle(fontSize: 12), // Small text
          labelSmall: TextStyle(fontSize: 10), // Very small text
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}