import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _newUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  String _message = '';

  Future<void> _register() async {
    String username = _newUsernameController.text.trim();
    String password = _newPasswordController.text.trim();
     String email = _newEmailController.text.trim();

    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      setState(() {
        _message = 'โปดกรอกข้อมูลให้ครบถ้วน';
      });
      return;
    }

    final ApiService apiService = ApiService(
        baseUrl: 'https://secretly-big-lobster.ngrok-free.app');
    final response = await apiService.post('/api/auth/register', data: {
      'username': username,
      'identity_email': email,
      'password': password,
    });

    if (response['isSuccess']) {
      setState(() {
        _message = 'ลงทะเบียนสำเร็จ กรุณาเข้าสู่ระบบ';
      });
      return;
    }

    setState(() {
      _message =
          response['message'] ?? response['error'] ?? 'เกิดข้อผิดพลาดในการลงทะเบียน';
    });

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลงทะเบียนผู้ดูแล'),
        centerTitle: true,
        backgroundColor: const Color(0xFFECE9E1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _newUsernameController,
              decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
            ),
            TextField(
              controller: _newEmailController,
              decoration: const InputDecoration(labelText: 'อีเมล'),
            ),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: const Text('ลงทะเบียน'),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
