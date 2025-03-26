import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prehome_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountsJson = prefs.getString('accounts');
    
    if (accountsJson == null) {
      setState(() {
        _message = 'No accounts found. Please register first.';
      });
      return;
    }
    
    List<dynamic> accounts = jsonDecode(accountsJson);
    bool valid = accounts.any((acc) =>
        acc['username'] == _usernameController.text.trim() &&
        acc['password'] == _passwordController.text.trim());
        
    if (valid) {
      // บันทึก current username เพื่อนำไปแสดงใน PrehomePage
      await prefs.setString('currentUsername', _usernameController.text.trim());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PrehomePage()),
      );
    } else {
      setState(() {
        _message = 'Invalid username or password.';
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
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: _goToRegister,
              child: const Text("Don't have an account? Register"),
            ),
            const SizedBox(height: 8),
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
