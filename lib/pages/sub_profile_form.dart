import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SubProfileFormPage extends StatefulWidget {
  final String username; // บัญชีหลักที่เราจะผูกโปรไฟล์ย่อย

  const SubProfileFormPage({super.key, required this.username});

  @override
  State<SubProfileFormPage> createState() => _SubProfileFormPageState();
}

class _SubProfileFormPageState extends State<SubProfileFormPage> {
  // Controllers สำหรับ TextField
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController(); // เพศสภาพ
  // sex (เพศกำเนิด) ใช้ Dropdown
  String _sex = 'Male';

  final TextEditingController _favoriteFoodController = TextEditingController();
  final TextEditingController _foodAllergiesController = TextEditingController();
  final TextEditingController _drugAllergiesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _otherConditionsController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Dropdown สำหรับ physicalActivityLevel, mealPreference, appetiteLevel
  String _physicalActivityLevel = 'Low';
  String _mealPreference = 'Vegeterian';
  String _appetiteLevel = 'Low';

  // สร้าง instance ของ uuid
  final Uuid uuid = Uuid();

  Future<void> _saveSubProfile() async {
    // สร้าง Map เก็บข้อมูลทั้งหมด โดยใช้ uuid เพื่อสร้าง id ที่ไม่ซ้ำกัน
    Map<String, dynamic> subProfileData = {
      'id': uuid.v4(), // สร้าง UID แบบ UUID v4
      'name': _nameController.text.trim(),
      'height': double.tryParse(_heightController.text) ?? 0.0,
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'age': int.tryParse(_ageController.text) ?? 0,
      'sex': _sex, // เพศกำเนิด (จาก dropdown)
      'gender': _genderController.text.trim(), // เพศสภาพ (จาก TextField)
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

    // ดึง subProfiles ของ user นี้จาก SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'subProfiles_${widget.username}';
    String? jsonStr = prefs.getString(key);
    List<dynamic> subProfiles = jsonStr != null ? jsonDecode(jsonStr) : [];

    // เพิ่ม subProfile ใหม่
    subProfiles.add(subProfileData);

    // บันทึกกลับใน SharedPreferences
    await prefs.setString(key, jsonEncode(subProfiles));

    // กลับไปหน้าเดิม (เช่น PrehomePage) หรือ pop พร้อมส่งข้อมูลกลับไปด้วย
    Navigator.pop(context, subProfileData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Sub Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sub Profile Information',
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              // Gender (เพศสภาพ) แบบ TextField
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender (e.g., Transgender, Non-binary, etc.)',
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              ElevatedButton(
                onPressed: _saveSubProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
