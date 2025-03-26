import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _newUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String _message = '';

  Future<void> _register() async {
    String username = _newUsernameController.text.trim();
    String password = _newPasswordController.text.trim();
    
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Please fill in all fields.';
      });
      return;
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountsJson = prefs.getString('accounts');
    List<dynamic> accounts = accountsJson != null ? jsonDecode(accountsJson) : [];
    
    bool exists = accounts.any((acc) => acc['username'] == username);
    
    if (exists) {
      setState(() {
        _message = 'Username already exists. Please choose another.';
      });
      return;
    }
    
    // Add new account to the list
    accounts.add({'username': username, 'password': password});
    await prefs.setString('accounts', jsonEncode(accounts));
    
    setState(() {
      _message = 'Registration successful! Please login.';
    });
    
    // Delay for 2 seconds and then pop back to login page
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Register'),
  centerTitle: true,
  backgroundColor: const Color(0xFFECE9E1),
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _newUsernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
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
