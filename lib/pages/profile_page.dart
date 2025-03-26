import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> subProfile;

  const ProfilePage({super.key, required this.subProfile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> currentSubProfile;

  @override
  void initState() {
    super.initState();
    // เริ่มต้นด้วยข้อมูลที่ส่งเข้ามาจาก widget.subProfile
    currentSubProfile = Map<String, dynamic>.from(widget.subProfile);
  }

  // ฟังก์ชันอัปเดต sub profile หลังจากแก้ไข
  void _navigateToEdit() async {
    var updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(subProfile: currentSubProfile),
      ),
    );
    if (updatedProfile != null) {
      setState(() {
        currentSubProfile = Map<String, dynamic>.from(updatedProfile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = currentSubProfile['name'] ?? 'Unknown';
    String height = currentSubProfile['height']?.toString() ?? 'N/A';
    String weight = currentSubProfile['weight']?.toString() ?? 'N/A';
    String age = currentSubProfile['age']?.toString() ?? 'N/A';
    String sex = currentSubProfile['sex'] ?? 'N/A';
    String gender = currentSubProfile['gender'] ?? 'N/A';
    String physicalActivity = currentSubProfile['physicalActivityLevel'] ?? 'N/A';
    String mealPreference = currentSubProfile['mealPreference'] ?? 'N/A';
    String appetiteLevel = currentSubProfile['appetiteLevel'] ?? 'N/A';
    String favoriteFood = currentSubProfile['favoriteFood'] ?? '';
    String foodAllergies = currentSubProfile['foodAllergies'] ?? '';
    String drugAllergies = currentSubProfile['drugAllergies'] ?? '';
    String medications = currentSubProfile['medications'] ?? '';
    String otherConditions = currentSubProfile['otherConditions'] ?? '';
    String note = currentSubProfile['note'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile - $name'),
        backgroundColor: const Color(0xFF4E614D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('Age: $age'),
            Text('Sex (Birth): $sex'),
            Text('Gender: $gender'),
            Text('Height: $height cm'),
            Text('Weight: $weight kg'),
            Text('Physical Activity: $physicalActivity'),
            Text('Meal Preference: $mealPreference'),
            Text('Appetite Level: $appetiteLevel'),
            const SizedBox(height: 16),
            const Text(
              'Additional Details:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Favorite Food: $favoriteFood'),
            Text('Food Allergies: $foodAllergies'),
            Text('Drug Allergies: $drugAllergies'),
            Text('Medications: $medications'),
            Text('Other Conditions: $otherConditions'),
            Text('Note: $note'),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _navigateToEdit,
                child: const Text('Update Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
