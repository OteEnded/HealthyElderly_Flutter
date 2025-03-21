import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'pages/dashboard_page.dart';
// import 'pages/suggestion_page.dart';
// import 'pages/information_page.dart';
// import 'pages/profile_page.dart';

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
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}