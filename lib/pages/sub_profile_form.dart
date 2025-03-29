import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../utils/api_service.dart';

class SubProfileFormPage extends StatefulWidget {
  final String userId; // รับ user_id ที่ส่งมาจาก PrehomePage

  const SubProfileFormPage({Key? key, required this.userId}) : super(key: key);

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
  String _mealPreference = 'Vegetarian';
  String _appetiteLevel = 'Low';

  // สำหรับโรค (diseases)
  List<dynamic> _diseases = []; // รายการโรคที่ดึงมาจาก API (แต่ละรายการเป็น Map)
  List<String> _selectedDiseases = []; // รายการโรคที่ผู้ใช้เลือก (เก็บเป็น String เช่น english_name)
  final TextEditingController _additionalDiseasesController = TextEditingController();

  // Instance ของ uuid
  final Uuid uuid = Uuid();

  // (ฟังก์ชัน _loadDiseases() สำหรับดึงข้อมูลโรคจาก API อยู่ที่นี่)
  // ...
  Future<void> _loadDiseases() async {
    try {
      final ApiService apiService = ApiService(
        baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
      );
      final apiResponse = await apiService.get('/api/medical-condition/get-all');
      if (apiResponse['isSuccess'] == true) {
        setState(() {
          _diseases = apiResponse['content'] as List<dynamic>;
        });
      } else {
        setState(() {
          _diseases = [];
        });
      }
    } catch (e) {
      setState(() {
        _diseases = [];
      });
      print("Error loading diseases: $e");
    }
  }

  Future<void> _saveSubProfile() async {
    // รวมรายการโรคจาก FilterChip และจาก TextField (แยกด้วย comma)
    List<String> additionalDiseases = _additionalDiseasesController.text
        .split(',')
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty)
        .toList();
    // สำหรับโรคที่เลือกจาก API เราใช้ _selectedDiseases (ซึ่งเก็บ english_name)
    // แล้ว map ให้เป็น medical_condition_id จาก _diseases
    List<String> elderMedicalConditions = _diseases
        .where((disease) =>
            _selectedDiseases.contains(disease['english_name']))
        .map<String>((disease) =>
            disease['medical_condition_id'] as String)
        .toList();

    // หากมีโรคเพิ่มเติมจาก TextField ให้รวมเข้าด้วย (อาจจะเป็น string ที่ไม่ได้มี medical_condition_id)
    List<String> diseases = [...elderMedicalConditions, ...additionalDiseases];

    // สร้าง Map subProfileData จากข้อมูลใน form พร้อมแนบ user_id จาก widget.userId
    Map<String, dynamic> subProfileData = {
      // 'id': uuid.v4(), // หากต้องการสร้าง UID ด้วย uuid ให้ปลดคอมเมนต์บรรทัดนี้
      "nickname": _nameController.text.trim(),
      "height": double.tryParse(_heightController.text) ?? 0.0,
      "weight": double.tryParse(_weightController.text) ?? 0.0,
      "age": int.tryParse(_ageController.text) ?? 0,
      "sex": _sex, // เพศกำเนิด
      "gender": _genderController.text.trim(), // เพศสภาพ
      "physical_activity_level": _physicalActivityLevel,
      "meal_preferences": _mealPreference,
      "appetite_level": _appetiteLevel,
      "favorite_food": _favoriteFoodController.text.trim(),
      "food_allergies": _foodAllergiesController.text.trim(),
      "drug_allergies": _drugAllergiesController.text.trim(),
      "medications": _medicationsController.text.trim(),
      "other_conditions": _otherConditionsController.text.trim(),
      "carer_notes": _noteController.text.trim(),
      // แนบ user_id ที่ส่งมาจาก PrehomePage
      "carer_id": widget.userId,
      // ส่งค่า medical_condition_id ของโรคที่เลือก
      "elder_medical_conditions": diseases,
    };

    print("SubProfileData: ${jsonEncode(subProfileData)}");

    final ApiService apiService = ApiService(
      baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
    );
    final apiResponse =
        await apiService.post('/api/elder/create', data: subProfileData);

    if (apiResponse['isSuccess'] == true) {
      Navigator.pop(context, subProfileData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiResponse['message'] ?? 'Failed to save sub profile'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDiseases();
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
                keyboardType: TextInputType.text,
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
                keyboardType: TextInputType.text,
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
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
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
                      DropdownMenuItem(value: 'Vegetarian', child: Text('Vegetarian')),
                      DropdownMenuItem(value: 'Non-Vegetarian', child: Text('Non-Vegetarian')),
                      DropdownMenuItem(value: 'Vegan', child: Text('Vegan')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _mealPreference = val ?? 'Vegetarian';
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
                keyboardType: TextInputType.text,
              ),
              // Food Allergies
              TextField(
                controller: _foodAllergiesController,
                decoration: const InputDecoration(labelText: 'Food Allergies'),
                keyboardType: TextInputType.text,
              ),
              // Drug Allergies
              TextField(
                controller: _drugAllergiesController,
                decoration: const InputDecoration(labelText: 'Drug Allergies'),
                keyboardType: TextInputType.text,
              ),
              // Medications
              TextField(
                controller: _medicationsController,
                decoration: const InputDecoration(labelText: 'Medications'),
                keyboardType: TextInputType.text,
              ),
              const Text(
                'Diseases (select and add extra if needed):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // ตัวเลือกโรคที่ได้จาก API โดยใช้ FilterChip
              Wrap(
                spacing: 8.0,
                children: _diseases.map((disease) {
                  // ใช้ english_name เป็นตัวแสดง
                  final diseaseName = disease['english_name'] ?? 'Unknown';
                  final selected = _selectedDiseases.contains(diseaseName);
                  return FilterChip(
                    label: Text(diseaseName),
                    selected: selected,
                    onSelected: (bool value) {
                      setState(() {
                        if (value) {
                          _selectedDiseases.add(diseaseName);
                        } else {
                          _selectedDiseases.remove(diseaseName);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              // เพิ่มฟิลด์โรคที่กำลังเป็น (diseases)
              
              // ฟิลด์เพิ่มเติมสำหรับโรคที่ไม่ได้อยู่ในตัวเลือก
              // TextField(
              //   controller: _additionalDiseasesController,
              //   decoration: const InputDecoration(
              //     labelText: 'Additional Diseases (comma separated)',
              //   ),
              // ),
              // const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveSubProfile,
                  child: const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
