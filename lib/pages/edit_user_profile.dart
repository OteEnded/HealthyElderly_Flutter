import 'package:flutter/material.dart';
import '../utils/api_service.dart';

class EditUserDataPage extends StatefulWidget {
  final Map<String, dynamic> userData; // ข้อมูลบัญชีหลักที่ต้องการแก้ไข

  const EditUserDataPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<EditUserDataPage> createState() => _EditUserDataPageState();
}

class _EditUserDataPageState extends State<EditUserDataPage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userData['username'] ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  Future<void> _updateUserData() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // ตรวจสอบว่ารหัสผ่านใหม่ทั้งสองตรงกันหรือไม่
    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'รหัสผ่านใหม่ไม่ตรงกัน';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final ApiService apiService = ApiService(
      baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
    );

    try {
      final response = await apiService.post(
        '/api/user/update',
        data: {
          'user_id': widget.userData['user_id'],
          'username': _usernameController.text.trim(),
          'password': newPassword,
        },
      );
      if (response['isSuccess'] == true) {
        Navigator.pop(context, response['content']);
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'เกิดข้อผิดพลาดในการอัปเดตข้อมูล';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขข้อมูลบัญชีหลัก"),
        backgroundColor: const Color(0xFF4E614D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'ซื่อผู้ใช้'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่านใหม่'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateUserData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("ยืนยันการแก้ไขข้อมูลบัญชีหลัก"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
