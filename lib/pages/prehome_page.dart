import 'package:flutter/material.dart';
import 'package:healthy_elderly/pages/edit_user_profile.dart';
import 'package:healthy_elderly/pages/sub_profile_form.dart';
import 'package:healthy_elderly/pages/sub_profile_update.dart';
import 'package:healthy_elderly/pages/main_page.dart';
import 'package:healthy_elderly/pages/register_page.dart';
import 'package:healthy_elderly/pages/login_page.dart';
import 'package:healthy_elderly/pages/edit_user_profile.dart'; // import หน้า EditUserDataPage
import 'package:healthy_elderly/utils/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      if (apiResponse['isSuccess'] == true) {
        setState(() {
          subProfiles = (apiResponse['content'] ?? []) as List<dynamic>;
        });
      } else {
        setState(() {
          errorMessage = apiResponse['message'] ?? 'Failed to load sub profiles';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
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
        builder: (context) => MainPage(
          subProfile: subProfile,
          userId: widget.response["content"]["user_id"],
        ),
      ),
    );
  }

  void _goToUpdateSubProfile(dynamic subProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubProfileUpdatePage(
          subProfile: subProfile,
          userId: widget.response["content"]["user_id"],
        ),
      ),
    ).then((value) {
      if (value != null) {
        _loadSubProfiles();
      }
    });
  }

  Future<void> _deleteSubProfile(dynamic subProfile) async {
    final userId = widget.response["content"]["user_id"] ?? 'Unknown';
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirm Deletion"),
              content: const Text("Are you sure you want to delete this sub profile?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirm) return;

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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.response["content"]["username"] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('User - $username'),
        backgroundColor: const Color(0xFF4E614D),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // นำผู้ใช้ไปที่หน้า EditUserDataPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserDataPage(
                    userData: widget.response["content"],
                  ),
                ),
              ).then((updatedUserData) {
                if (updatedUserData != null) {
                  setState(() {
                    widget.response["content"] = updatedUserData;
                  });
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
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
                              subtitle: Text('ส่วนสูง: $height, น้ำหนัก: $weight'),
                              onTap: () => _goToMainPage(sp),
                              // trailing: Row(
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: [
                              //     IconButton(
                              //       icon: const Icon(Icons.edit, color: Colors.blue),
                              //       onPressed: () => _goToUpdateSubProfile(sp),
                              //     ),
                              //     IconButton(
                              //       icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              //       onPressed: () {
                              //         _deleteSubProfile(sp);
                              //       },
                              //     ),
                              //   ],
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
