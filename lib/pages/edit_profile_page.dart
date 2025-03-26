import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> subProfile;

  const EditProfilePage({super.key, required this.subProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers สำหรับ TextField ต่างๆ
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _genderController; // Gender (เพศสภาพ)
  // sex (เพศกำเนิด) ใช้ Dropdown
  String _sex = 'Male';
  String _physicalActivityLevel = 'Low';
  String _mealPreference = 'Vegeterian';
  String _appetiteLevel = 'Low';
  late TextEditingController _favoriteFoodController;
  late TextEditingController _foodAllergiesController;
  late TextEditingController _drugAllergiesController;
  late TextEditingController _medicationsController;
  late TextEditingController _otherConditionsController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from widget.subProfile
    _nameController =
        TextEditingController(text: widget.subProfile['name']?.toString() ?? '');
    _heightController = TextEditingController(
        text: widget.subProfile['height']?.toString() ?? '');
    _weightController = TextEditingController(
        text: widget.subProfile['weight']?.toString() ?? '');
    _ageController =
        TextEditingController(text: widget.subProfile['age']?.toString() ?? '');
    _genderController = TextEditingController(
        text: widget.subProfile['gender']?.toString() ?? '');
    _sex = widget.subProfile['sex']?.toString() ?? 'Male';
    _physicalActivityLevel =
        widget.subProfile['physicalActivityLevel']?.toString() ?? 'Low';
    _mealPreference =
        widget.subProfile['mealPreference']?.toString() ?? 'Vegeterian';
    _appetiteLevel =
        widget.subProfile['appetiteLevel']?.toString() ?? 'Low';
    _favoriteFoodController = TextEditingController(
        text: widget.subProfile['favoriteFood']?.toString() ?? '');
    _foodAllergiesController = TextEditingController(
        text: widget.subProfile['foodAllergies']?.toString() ?? '');
    _drugAllergiesController = TextEditingController(
        text: widget.subProfile['drugAllergies']?.toString() ?? '');
    _medicationsController = TextEditingController(
        text: widget.subProfile['medications']?.toString() ?? '');
    _otherConditionsController = TextEditingController(
        text: widget.subProfile['otherConditions']?.toString() ?? '');
    _noteController = TextEditingController(
        text: widget.subProfile['note']?.toString() ?? '');
  }

  Future<void> _updateSubProfile() async {
    // สร้าง Map ใหม่จากข้อมูลใน form
    Map<String, dynamic> updatedProfile = {
      'id': widget.subProfile['id'], // รักษา id เดิมไว้
      'name': _nameController.text.trim(),
      'height': double.tryParse(_heightController.text) ?? 0.0,
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'age': int.tryParse(_ageController.text) ?? 0,
      'sex': _sex,
      'gender': _genderController.text.trim(),
      'physicalActivityLevel': _physicalActivityLevel,
      'mealPreference': _mealPreference,
      'appetiteLevel': _appetiteLevel,
      'favoriteFood': _favoriteFoodController.text.trim(),
      'foodAllergies': _foodAllergiesController.text.trim(),
      'drugAllergies': _drugAllergiesController.text.trim(),
      'medications': _medicationsController.text.trim(),
      'otherConditions': _otherConditionsController.text.trim(),
      'note': _noteController.text.trim(),
    };

    // สมมุติว่าในแอปเราบันทึก sub profiles ไว้ใน SharedPreferences
    // ตาม key 'subProfiles_<currentUsername>'
    // เราจะอัปเดตข้อมูลใน SharedPreferences ด้วยข้อมูลที่แก้ไขแล้ว
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // สมมุติว่า currentUsername ถูกเก็บไว้ใน widget.subProfile ด้วย key 'account'
    String currentUsername = widget.subProfile['account'] ?? '';
    String key = 'subProfiles_$currentUsername';
    String? jsonStr = prefs.getString(key);
    List<dynamic> subProfiles = jsonStr != null ? jsonDecode(jsonStr) : [];
    // หา index ของ sub profile ที่ต้องการอัปเดตโดยใช้ id
    int index = subProfiles.indexWhere((sp) => sp['id'] == widget.subProfile['id']);
    if (index != -1) {
      subProfiles[index] = updatedProfile;
      await prefs.setString(key, jsonEncode(subProfiles));
      // แสดงข้อความสำเร็จ (SnackBar) แล้ว pop กลับไปพร้อมส่งข้อมูลที่อัปเดตกลับ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sub profile updated successfully')),
      );
      Navigator.pop(context, updatedProfile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Sub profile not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sub Profile'),
        backgroundColor: const Color(0xFF4E614D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Sub Profile Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              // Height
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              // Weight
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              // Age
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              // Sex (เพศกำเนิด) แบบ Dropdown
              Row(
                children: [
                  const Text('Sex: '),
                  DropdownButton<String>(
                    value: _sex,
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _sex = val ?? 'Male';
                      });
                    },
                  ),
                ],
              ),
              // Gender (เพศสภาพ) แบบ TextField
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(
                    labelText:
                        'Gender (e.g., Transgender, Non-binary, etc.)'),
              ),
              // Physical Activity Level
              Row(
                children: [
                  const Text('Physical Activity: '),
                  DropdownButton<String>(
                    value: _physicalActivityLevel,
                    items: const [
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                      DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _physicalActivityLevel = val ?? 'Low';
                      });
                    },
                  ),
                ],
              ),
              // Meal Preference
              Row(
                children: [
                  const Text('Meal Preference: '),
                  DropdownButton<String>(
                    value: _mealPreference,
                    items: const [
                      DropdownMenuItem(value: 'Vegeterian', child: Text('Vegeterian')),
                      DropdownMenuItem(value: 'Non-Vegeterian', child: Text('Non-Vegeterian')),
                      DropdownMenuItem(value: 'Vegan', child: Text('Vegan')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _mealPreference = val ?? 'Vegeterian';
                      });
                    },
                  ),
                ],
              ),
              // Appetite Level
              Row(
                children: [
                  const Text('Appetite Level: '),
                  DropdownButton<String>(
                    value: _appetiteLevel,
                    items: const [
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                      DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _appetiteLevel = val ?? 'Low';
                      });
                    },
                  ),
                ],
              ),
              // Favorite Food
              TextField(
                controller: _favoriteFoodController,
                decoration: const InputDecoration(labelText: 'Favorite Food'),
              ),
              // Food Allergies
              TextField(
                controller: _foodAllergiesController,
                decoration: const InputDecoration(labelText: 'Food Allergies'),
              ),
              // Drug Allergies
              TextField(
                controller: _drugAllergiesController,
                decoration: const InputDecoration(labelText: 'Drug Allergies'),
              ),
              // Medications
              TextField(
                controller: _medicationsController,
                decoration: const InputDecoration(labelText: 'Medications'),
              ),
              // Other Conditions
              TextField(
                controller: _otherConditionsController,
                decoration: const InputDecoration(labelText: 'Other Conditions'),
              ),
              // Note
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _updateSubProfile,
                  child: const Text('Update Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
