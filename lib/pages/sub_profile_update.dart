import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:healthy_elderly/pages/prehome_page.dart';
import 'package:healthy_elderly/pages/profile_page.dart';
import 'package:uuid/uuid.dart';
import '../utils/api_service.dart';

class SubProfileUpdatePage extends StatefulWidget {
  final Map<String, dynamic> subProfile; // ข้อมูล sub profile ที่ต้องการแก้ไข
  final String userId; // userId ของผู้ใช้ที่ล็อกอินอยู่

  const SubProfileUpdatePage({Key? key, required this.subProfile, required this.userId})
    : super(key: key);

  @override
  State<SubProfileUpdatePage> createState() => _SubProfileUpdatePageState();
}

class _SubProfileUpdatePageState extends State<SubProfileUpdatePage> {
  
  // Controllers สำหรับ TextField
  late TextEditingController _elderIDController;
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _genderController; // เพศสภาพ

  // sex (เพศกำเนิด) ใช้ Dropdown
  late String _sex;

  late TextEditingController _favoriteFoodController;
  late TextEditingController _foodAllergiesController;
  late TextEditingController _drugAllergiesController;
  late TextEditingController _medicationsController;
  late TextEditingController _otherConditionsController;
  late TextEditingController _noteController;

  // Dropdown สำหรับ physicalActivityLevel, mealPreference, appetiteLevel
  late String _physicalActivityLevel;
  late String _mealPreference;
  late String _appetiteLevel;

  // สำหรับโรค (diseases) – รายการโรคจาก API และรายชื่อที่ผู้ใช้เลือก (medical_condition_id)
  List<dynamic> _diseases =
      []; // รายการโรคที่ดึงมาจาก API (แต่ละรายการเป็น Map)
  List<String> _selectedDiseases =
      []; // เก็บ medical_condition_id ของโรคที่เลือก
  final TextEditingController _additionalDiseasesController =
      TextEditingController();

  // Instance ของ uuid (ถ้าต้องการสร้าง UID ใหม่)

  @override
  void initState() {
    super.initState();
    // Pre-populate controllers จากข้อมูลใน subProfile
    _elderIDController = TextEditingController(
        text: widget.subProfile["elder_id"]?.toString() ?? "");
    _nameController = TextEditingController(
        text: widget.subProfile["nickname"]?.toString() ?? "");
    _heightController = TextEditingController(
        text: widget.subProfile["height"]?.toString() ?? "");
    _weightController = TextEditingController(
        text: widget.subProfile["weight"]?.toString() ?? "");
    _ageController =
        TextEditingController(text: widget.subProfile["age"]?.toString() ?? "");
    _genderController = TextEditingController(
        text: widget.subProfile["gender"]?.toString() ?? "");
    _sex = widget.subProfile["sex"]!.toString();

    _favoriteFoodController = TextEditingController(
        text: widget.subProfile["favorite_food"]?.toString() ?? "");
    _foodAllergiesController = TextEditingController(
        text: widget.subProfile["food_allergies"]?.toString() ?? "");
    _drugAllergiesController = TextEditingController(
        text: widget.subProfile["drug_allergies"]?.toString() ?? "");
    _medicationsController = TextEditingController(
        text: widget.subProfile["medications"]?.toString() ?? "");
    _otherConditionsController = TextEditingController(
        text: widget.subProfile["other_conditions"]?.toString() ?? "");
    _noteController = TextEditingController(
        text: widget.subProfile["carer_notes"]?.toString() ?? "");

    _physicalActivityLevel =
        widget.subProfile["physical_activity_level"]!.toString();
    _mealPreference = widget.subProfile["meal_preferences"]!.toString();
    _appetiteLevel = widget.subProfile["appetite_level"]!.toString();

    // สำหรับโรคที่เคยเลือกไว้ (ในฐานข้อมูลเก็บเป็น List ของ medical_condition_id)
    _selectedDiseases =
        (widget.subProfile["elder_medical_conditions"] as List<dynamic>?)
                ?.map<String>((item) => item['medical_condition_id'].toString())
                .toList() ??
            [];
    print(widget.subProfile["elder_id"]);
    _loadDiseases();
  }

  // ฟังก์ชันดึงรายการโรคจาก API
  Future<void> _loadDiseases() async {
    try {
      final ApiService apiService = ApiService(
        baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
      );
      final apiResponse =
          await apiService.get('/api/medical-condition/get-all');
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

  Future<void> _updateSubProfile() async {
    // รวมรายการโรคจาก FilterChip และจาก TextField (แยกด้วย comma)
    List<String> additionalDiseases = _additionalDiseasesController.text
        .split(',')
        .map((e) => e.trim())
        .where((element) => element.isNotEmpty)
        .toList();

    // _selectedDiseases ตอนนี้เก็บเป็น medical_condition_id อยู่แล้ว
    List<String> diseases = [..._selectedDiseases, ...additionalDiseases];

    // สร้าง Map updatedProfileData จากข้อมูลในฟอร์มที่ถูกแก้ไข
    Map<String, dynamic> updatedProfileData = {
      "elder_id": _elderIDController.text.trim(), // รักษา id เดิมไว้ ถ้ามี (เช่น elder_id)
      // รักษา id เดิมไว้ ถ้ามี (เช่น elder_id)
      "nickname": _nameController.text.trim(),
      "height": double.tryParse(_heightController.text) ?? 0.0,
      "weight": double.tryParse(_weightController.text) ?? 0.0,
      "age": int.tryParse(_ageController.text) ?? 0,
      "sex": _sex,
      "gender": _genderController.text.trim(),
      "physical_activity_level": _physicalActivityLevel,
      "meal_preferences": _mealPreference,
      "appetite_level": _appetiteLevel,
      "favorite_food": _favoriteFoodController.text.trim(),
      "food_allergies": _foodAllergiesController.text.trim(),
      "drug_allergies": _drugAllergiesController.text.trim(),
      "medications": _medicationsController.text.trim(),
      "other_conditions": _otherConditionsController.text.trim(),
      "carer_notes": _noteController.text.trim(),
      // ส่งค่า medical_condition_id ของโรคที่เลือก
      "elder_medical_conditions": diseases,
    };

    print("Updated SubProfileData: ${jsonEncode(updatedProfileData)}");

    final ApiService apiService = ApiService(
      baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
    );
    // ส่งข้อมูลไปยัง API สำหรับ update sub profile (ปรับ endpoint ตามที่ API ของคุณกำหนด)
    final apiResponse =
        await apiService.post('/api/elder/update', data: updatedProfileData);

     if (apiResponse['isSuccess'] == true) {
      // หลังจาก update เสร็จแล้ว ให้นำผู้ใช้ไปที่ ProfilePage เสมอ
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrehomePage(response: {
            "content": {
              "user_id": widget.userId,
              "elder_id": _elderIDController.text.trim(),
            },
          }),
            
          ),
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(apiResponse['message'] ?? 'Failed to update sub profile'),
        ),
      );
    }
  }

  // ฟังก์ชันสำหรับสร้าง label ที่มีเครื่องหมาย * สีแดง และ fontSize 10
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Elder Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update ข้อมูลผู้สูงอายุ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(label: _buildRequiredLabel('ชื่อเล่น')),
                keyboardType: TextInputType.text,
              ),
              // Height
              TextField(
                controller: _heightController,
                decoration:
                    InputDecoration(label: _buildRequiredLabel('ส่วนสูง (cm)')),
                keyboardType: TextInputType.number,
              ),
              // Weight
              TextField(
                controller: _weightController,
                decoration:
                    InputDecoration(label: _buildRequiredLabel('น้ำหนัก (kg)')),
                keyboardType: TextInputType.number,
              ),
              // Age
              TextField(
                controller: _ageController,
                decoration: InputDecoration(label: _buildRequiredLabel('อายุ')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Sex (เพศกำเนิด) แบบ Dropdown พร้อม label ที่มี *
              Row(
                children: [
                  _buildRequiredLabel('เพศกำเนิด: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sex,
                    items: const [
                      DropdownMenuItem(value: 'MALE', child: Text('ชาย')),
                      DropdownMenuItem(value: 'FEMALE', child: Text('หญิง')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _sex = val!;
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
                      DropdownMenuItem(value: 'LOW', child: Text('0-2วัน/สัปดาห์')),
                      DropdownMenuItem(
                          value: 'MODERATE', child: Text('3-5วัน/สัปดาห์')),
                      DropdownMenuItem(value: 'ACTIVE', child: Text('6-7วัน/สัปดาห์')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _physicalActivityLevel = val!;
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
                      DropdownMenuItem(
                          value: 'VEGETARIAN', child: Text('ทานมังสวิรัติ')),
                      DropdownMenuItem(
                          value: 'NON_VEGETARIAN',
                          child: Text('ทานปกติ')),
                      DropdownMenuItem(value: 'VEGAN', child: Text('ทานเจ')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _mealPreference = val!;
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
                      DropdownMenuItem(value: 'LOW', child: Text('เบื่ออาหาร')),
                      DropdownMenuItem(value: 'NORMAL', child: Text('ปกติ')),
                      DropdownMenuItem(value: 'HIGH', child: Text('ทานมากกว่าปกติ')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _appetiteLevel = val!;
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
                decoration:
                    const InputDecoration(labelText: 'อื่นๆ'),
                keyboardType: TextInputType.text,
              ),
              // Note
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              const Text(
                'โรคประจำตัว:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // ตัวเลือกโรคที่ได้จาก API โดยใช้ FilterChip (แสดงด้วย thai_name)
              Wrap(
                spacing: 8.0,
                children: _diseases.map((disease) {
                  final diseaseId = disease['medical_condition_id'];
                  final diseaseLabel = disease['thai_name'] ?? 'Unknown';
                  final selected = _selectedDiseases.contains(diseaseId);
                  return FilterChip(
                    label: Text(diseaseLabel),
                    selected: selected,
                    onSelected: (bool value) {
                      setState(() {
                        if (value) {
                          _selectedDiseases.add(diseaseId);
                        } else {
                          _selectedDiseases.remove(diseaseId);
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
