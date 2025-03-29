import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import 'login_page.dart';
import 'sub_profile_form.dart';
import 'main_page.dart';

class PrehomePage extends StatefulWidget {
  final Map<String, dynamic> response;

  const PrehomePage({Key? key, required this.response}) : super(key: key);

  @override
  State<PrehomePage> createState() => _PrehomePageState();
}

class _PrehomePageState extends State<PrehomePage> {
  List<dynamic> subProfiles = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSubProfiles();
  }

  Future<void> _loadSubProfiles() async {
  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  // ดึง userId จาก response
  final userId = widget.response["content"]["user_id"] ?? 'Unknown';

  try {
    final ApiService apiService = ApiService(
      baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
    );

    final apiResponse = await apiService.post(
      '/api/elder/get-all',
      data: {'carer_id': userId},
      
    );
    print("apiResponse: $apiResponse");
    if (apiResponse['isSuccess'] == true) {
      // ถ้า apiResponse['data'] เป็น null ให้แทนที่ด้วย List ว่าง
      subProfiles = (apiResponse['content'] ?? []) as List<dynamic>;
    } else {
      errorMessage = apiResponse['message'] ?? 'Failed to load sub profiles';
    }
  } catch (e) {
    errorMessage = 'Error: $e';
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  void _goToAddSubProfile() {
    final userId = widget.response["content"]["user_id"] ?? 'Unknown';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubProfileFormPage(userId: userId),
      ),
    ).then((value) {
      if (value != null) {
        _loadSubProfiles();
      }
    });
  }

  void _goToMainPage(dynamic subProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(subProfile: subProfile),
      ),
    );
  }

  Future<void> _deleteSubProfile(dynamic subProfile) async {
    final userId = widget.response["content"]["user_id"] ?? 'Unknown';
    try {
      final ApiService apiService = ApiService(
        baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
      );
      final apiResponse = await apiService.post(
        '/api/elder/delete', // สมมุติ endpoint สำหรับลบ sub profile
        data: {'elder_id': subProfile['elder_id']},
      );
      if (apiResponse['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sub Profile deleted successfully")),
        );
        _loadSubProfiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiResponse['message'] ?? "Deletion failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.response["content"]["username"] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('User - $username'),
        backgroundColor: const Color(0xFF4E614D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : subProfiles.isEmpty
                  ? const Center(child: Text("No sub profiles found."))
                  : ListView.builder(
                      itemCount: subProfiles.length,
                      itemBuilder: (context, index) {
                        final sp = subProfiles[index];
                        if (sp is Map<String, dynamic>) {
                          final nickname = sp['nickname'] ?? 'Unknown';
                          final height = sp['height']?.toString() ?? 'N/A';
                          final weight = sp['weight']?.toString() ?? 'N/A';
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(nickname),
                              subtitle: Text('Height: $height, Weight: $weight'),
                              onTap: () => _goToMainPage(sp),
                              // trailing: IconButton(
                              //   icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              //   onPressed: () {
                              //     // แสดง Alert Dialog ยืนยันการลบ
                              //     showDialog(
                              //       context: context,
                              //       builder: (context) {
                              //         return AlertDialog(
                              //           title: const Text("Confirm Deletion"),
                              //           content: const Text("Are you sure you want to delete this sub profile?"),
                              //           actions: [
                              //             TextButton(
                              //               onPressed: () => Navigator.of(context).pop(),
                              //               child: const Text("Cancel"),
                              //             ),
                              //             TextButton(
                              //               onPressed: () {
                              //                 Navigator.of(context).pop();
                              //                 _deleteSubProfile(sp);
                              //               },
                              //               child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              //             ),
                              //           ],
                              //         );
                              //       },
                              //     );
                              //   },
                              // ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddSubProfile,
        child: const Icon(Icons.add),
      ),
    );
  }
}
