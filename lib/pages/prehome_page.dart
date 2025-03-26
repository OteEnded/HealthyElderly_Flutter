import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'sub_profile_form.dart';
import 'main_page.dart';

class PrehomePage extends StatefulWidget {
  const PrehomePage({super.key});

  @override
  State<PrehomePage> createState() => _PrehomePageState();
}

class _PrehomePageState extends State<PrehomePage> {
  String? currentUsername;
  List<dynamic> subProfiles = [];

  // ดึง currentUsername จาก SharedPreferences
  Future<void> _loadCurrentUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('currentUsername');
  }

  // ดึง subProfiles ของ currentUsername
  Future<void> _loadSubProfiles() async {
    if (currentUsername == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'subProfiles_$currentUsername';
    String? jsonStr = prefs.getString(key);
    if (jsonStr != null) {
      try {
        subProfiles = jsonDecode(jsonStr) as List<dynamic>;
      } catch (e) {
        subProfiles = [];
      }
    } else {
      subProfiles = [];
    }
  }

  // โหลดข้อมูลทั้งหมด
  Future<void> _loadAllData() async {
    await _loadCurrentUsername();
    await _loadSubProfiles();
  }

  // ฟังก์ชันสร้างโปรไฟล์ย่อย
  Future<void> _createSubProfile() async {
    if (currentUsername == null) return;
    // ไปหน้า SubProfileFormPage เพื่อสร้าง sub profile ใหม่
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubProfileFormPage(username: currentUsername!),
      ),
    );
    // ถ้ามีการสร้าง sub profile ใหม่ (result != null)
    if (result != null) {
      await _loadSubProfiles();
      setState(() {});
    }
  }

  // ฟังก์ชันลบ sub profile
  Future<void> _deleteSubProfile(dynamic subProfile) async {
  if (currentUsername == null) return;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String key = 'subProfiles_$currentUsername';
  String? jsonStr = prefs.getString(key);
  if (jsonStr != null) {
    List<dynamic> subProfilesList;
    try {
      subProfilesList = jsonDecode(jsonStr) as List<dynamic>;
    } catch (e) {
      subProfilesList = [];
    }
    // ค้นหา index โดยเช็คว่าข้อมูลเป็น Map หรือไม่
    int index = subProfilesList.indexWhere((sp) {
      if (sp is Map<String, dynamic>) {
        return sp['id'] == subProfile['id'];
      }
      return false;
    });
    if (index != -1) {
      subProfilesList.removeAt(index);
      await prefs.setString(key, jsonEncode(subProfilesList));
      setState(() {
        subProfiles = subProfilesList;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sub Profile deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sub Profile not found")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No sub profiles data available")),
    );
  }
}

  // ไปหน้า MainPage พร้อมส่งข้อมูล subProfile
  void _goToMainPage(dynamic subProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(subProfile: subProfile),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAllData().then((_) {
      setState(() {});
    });
  }

  @override
Widget build(BuildContext context) {
  String displayName = currentUsername ?? '';

  return Scaffold(
    appBar: AppBar(
      title: Text('Home Page - $displayName'),
      backgroundColor: const Color(0xFFECE9E1),
    ),
    body: Column(
      children: [
        Expanded(
          child: subProfiles.isEmpty
              ? const Center(child: Text("No sub profiles found."))
              : ListView.builder(
                  itemCount: subProfiles.length,
                  itemBuilder: (context, index) {
                    var sp = subProfiles[index];
                    if (sp is Map<String, dynamic>) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(sp['name'] ?? 'Unknown'),
                          subtitle: Text('Height: ${sp['height']}, Weight: ${sp['weight']}'),
                          onTap: () => _goToMainPage(sp),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              // แสดง Alert Dialog เพื่อยืนยันการลบ
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Confirm Deletion"),
                                    content: const Text("Are you sure you want to delete this sub profile?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // ปิด dialog
                                          _deleteSubProfile(sp);
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text('Logout'),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _createSubProfile,
      child: const Icon(Icons.add),
    ),
  );
}
}
