import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prehome_page.dart';
import 'register_page.dart';
import '../utils/api_service.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _message = '';
  String _a = '';
  Future<void> _login() async {
  final ApiService apiService = ApiService(
      baseUrl: 'https://secretly-big-lobster.ngrok-free.app');
  final response = await apiService.post('/api/auth/login', data: {
    'identity_email': _emailController.text.trim(),
    'password': _passwordController.text.trim(),
  });

  if (response['isSuccess']) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PrehomePage(response: response)),
    );
  } else {
    setState(() {
      _message = response['message'] ?? response['error'] ?? 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
    });
  }
}

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ทำให้ Column มีขนาดพอดีกับเนื้อหา
            children: [
              Text(
                'Healthy Elderly',
                style: TextStyle(
                  fontFamily: 'TanMonCheri', // Use the custom font for the logo
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4E614D), // Primary color
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'อีเมล'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _login,
                child: const Text('ลงชื่อเข้าใช้'),
              ),
              TextButton(
                onPressed: _goToRegister,
                child: const Text("ยังไม่มีบัญชีผู้ใช้? ลงทะเบียนที่นี่"),
              ),
              const SizedBox(height: 8),
              // Text(
              //   _a,
              //   style: const TextStyle(color: Colors.red),
              // ),
              Text(
                _message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
