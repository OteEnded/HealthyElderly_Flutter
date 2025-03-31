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
  String _physicalActivityLevel = 'Moderate';
  String _mealPreference = 'Non_Vegetarian';
  String _appetiteLevel = 'Normal';

  // สำหรับโรค (diseases)
  List<dynamic> _diseases = []; // รายการโรคที่ดึงมาจาก API (แต่ละรายการเป็น Map)
  List<String> _selectedDiseases = []; // รายการโรคที่ผู้ใช้เลือก (เก็บเป็น String เช่น english_name หรือ thai_name)
  // (ถ้าต้องการฟิลด์เพิ่มเติมสำหรับโรคที่ไม่ได้อยู่ในตัวเลือก ให้เพิ่ม controller นี้)
  // final TextEditingController _additionalDiseasesController = TextEditingController();

  // Instance ของ uuid
  final Uuid uuid = Uuid();

  // ฟังก์ชันดึงรายการโรคจาก API
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
    // ในที่นี้เราจะใช้ _selectedDiseases ที่เก็บเป็น thai_name แล้ว map ให้เป็น medical_condition_id จาก _diseases
    List<String> elderMedicalConditions = _diseases
        .where((disease) =>
            _selectedDiseases.contains(disease['thai_name']))
        .map<String>((disease) =>
            disease['medical_condition_id'] as String)
        .toList();

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
      "elder_medical_conditions": elderMedicalConditions,
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
          content: Text(apiResponse['message'] ?? 'เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
        ),
      );
    }
  }

  // ฟังก์ชันสำหรับสร้าง label ที่มีเครื่องหมาย * สีแดง และกำหนด fontSize เป็น 10
  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontSize: 10),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontSize: 10),
          ),
        ],
      ),
    );
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
        title: const Text('เพิ่มโปรไฟล์ผู้สูงอายุ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ข้อมูลผู้สูงอายุ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  label: _buildRequiredLabel('ชื่อเล่น'),
                ),
                keyboardType: TextInputType.text,
              ),
              // Height
              TextField(
                controller: _heightController,
                decoration: InputDecoration(
                  label: _buildRequiredLabel('ส่วนสูง (ซม.)'),
                ),
                keyboardType: TextInputType.number,
              ),
              // Weight
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  label: _buildRequiredLabel('น้ำหนัก (กิโลกรัม)'),
                ),
                keyboardType: TextInputType.number,
              ),
              // Age
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  label: _buildRequiredLabel('อายุ'),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Sex (เพศกำเนิด) แบบ Dropdown พร้อม label ที่มี * สีแดง
              Row(
                children: [
                  _buildRequiredLabel('เพศกำเนิด: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sex,
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('ชาย')),
                      DropdownMenuItem(value: 'Female', child: Text('หญิง')),
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
                  labelText: 'เพศสภาพ (เช่น Transgender, Non-binary และอื่นๆ)',
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              // Physical Activity Level (มี *)
              Row(
                children: [
                  _buildRequiredLabel('ความถี่ในการออกกำลังกาย: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _physicalActivityLevel,
                    items: const [
                      DropdownMenuItem(value: 'Low', child: Text('0-2วัน/สัปดาห์')),
                      DropdownMenuItem(value: 'Moderate', child: Text('3-5วัน/สัปดาห์')),
                      DropdownMenuItem(value: 'Active', child: Text('6-7วัน/สัปดาห์')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _physicalActivityLevel = val ?? 'Moderate';
                      });
                    },
                  ),
                ],
              ),
              // Meal Preference (มี *)
              Row(
                children: [
                  _buildRequiredLabel('ประเภทอาหารที่ทาน: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _mealPreference,
                    items: const [
                      DropdownMenuItem(value: 'Vegetarian', child: Text('ทานมังสวิรัติ')),
                      DropdownMenuItem(value: 'Non_Vegetarian', child: Text('ทานปกติ')),
                      DropdownMenuItem(value: 'Vegan', child: Text('ทานเจ')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _mealPreference = val ?? 'Non_Vegetarian';
                      });
                    },
                  ),
                ],
              ),
              // Appetite Level (มี *)
              Row(
                children: [
                  _buildRequiredLabel('ความอยากอาหาร: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _appetiteLevel,
                    items: const [
                      DropdownMenuItem(value: 'Low', child: Text('เบื่ออาหาร')),
                      DropdownMenuItem(value: 'Normal', child: Text('ปกติ')),
                      DropdownMenuItem(value: 'High', child: Text('ทานมากกว่าปกติ')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _appetiteLevel = val ?? 'Normal';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Favorite Food
              TextField(
                controller: _favoriteFoodController,
                decoration: const InputDecoration(labelText: 'อาหารที่ชอบ'),
                keyboardType: TextInputType.text,
              ),
              // Food Allergies
              TextField(
                controller: _foodAllergiesController,
                decoration: const InputDecoration(labelText: 'อาหารที่แพ้'),
                keyboardType: TextInputType.text,
              ),
              // Drug Allergies
              TextField(
                controller: _drugAllergiesController,
                decoration: const InputDecoration(labelText: 'ยาที่แพ้'),
                keyboardType: TextInputType.text,
              ),
              // Medications
              TextField(
                controller: _medicationsController,
                decoration: const InputDecoration(labelText: 'ยาที่ทานปัจจุบัน'),
                keyboardType: TextInputType.text,
              ),
              // Other Conditions
              TextField(
                controller: _otherConditionsController,
                decoration: const InputDecoration(labelText: 'อื่นๆ'),
                keyboardType: TextInputType.text,
              ),
              // Note
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'บันทึกเพิ่มเติม'),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              // Diseases (select and add extra if needed)
              const Text(
                'โรคประจำตัว:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // ตัวเลือกโรคที่ได้จาก API โดยใช้ FilterChip (แสดงด้วย thai_name)
              Wrap(
                spacing: 8.0,
                children: _diseases.map((disease) {
                  final diseaseName = disease['thai_name'] ?? '[loading]';
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
              // (ถ้าต้องการฟิลด์เพิ่มเติมสำหรับโรคที่ไม่ได้อยู่ในตัวเลือก ให้เพิ่มที่นี่)
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveSubProfile,
                  child: const Text('ยืนยันการบันทึกข้อมูลโปรไฟล์ผู้สูงอายุ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
