import 'package:flutter/material.dart';
import 'package:healthy_elderly/pages/prehome_page.dart';
import 'package:healthy_elderly/pages/sub_profile_update.dart';
import '../utils/api_service.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> subProfile;
  final String userId;

  const ProfilePage({super.key, required this.subProfile, required this.userId});

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
        builder: (context) => SubProfileUpdatePage(
          subProfile: currentSubProfile,
          userId: widget.userId, // ส่ง userId ไปด้วย
        ),
      ),
    );
    if (updatedProfile != null) {
      setState(() {
        currentSubProfile = Map<String, dynamic>.from(updatedProfile);
      });
    }
  }

  // ฟังก์ชันลบ sub profile ผ่าน API และนำไปที่ PrehomePage หลังลบเสร็จ
  Future<void> _deleteProfile() async {
    final elderId = currentSubProfile['elder_id'];
    if (elderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่สามารถลบโปรไฟล์ได้")),
      );
      return;
    }

    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("ยืนยันการลบโปรไฟล์"),
              content: const Text("คุณแน่ใจหรือไม่ว่าต้องการลบโปรไฟล์นี้?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("ยกเลิก"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("ยืนยันการลบ"
                  , style: TextStyle(color: Colors.red)),
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
        '/api/elder/delete',
        data: {'elder_id': elderId},
      );

      if (apiResponse['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบโปรไฟล์เรียบร้อยแล้ว!")),
        );
        // นำผู้ใช้ไปยังหน้า PrehomePage พร้อมส่ง response ที่มี user_id
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PrehomePage(
              response: {
                "content": {"user_id": widget.userId},
                "isSuccess": true,
                "message": "ข้อมูลผู้ใช้ถูกลบเรียบร้อยแล้ว",
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiResponse['message'] ?? "เกิดข้อผิดพลาดในการลบโปรไฟล์")),
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
    String name = currentSubProfile['nickname'] ?? 'ไม่ทราบชื่อ';
    String height = currentSubProfile['height']?.toString() ?? 'N/A';
    String weight = currentSubProfile['weight']?.toString() ?? 'N/A';
    String age = currentSubProfile['age']?.toString() ?? 'N/A';
    String sex = currentSubProfile['sex'] ?? 'N/A';
    String gender = currentSubProfile['gender'] ?? 'N/A';
    String physicalActivity = currentSubProfile['physical_activity_level'] ?? 'N/A';
    String mealPreference = currentSubProfile['meal_preferences'] ?? 'N/A';
    String appetiteLevel = currentSubProfile['appetite_level'] ?? 'N/A';
    String favoriteFood = currentSubProfile['favorite_food'] ?? '';
    String foodAllergies = currentSubProfile['food_allergies'] ?? '';
    String drugAllergies = currentSubProfile['drug_allergies'] ?? '';
    String medications = currentSubProfile['medications'] ?? '';
    String otherConditions = currentSubProfile['other_conditions'] ?? '';
    String note = currentSubProfile['carer_notes'] ?? '';

    // ดึงข้อมูลโรคที่เลือกไว้ (elder_medical_conditions) ซึ่งเป็น List ของ Map
    List<dynamic> diseasesList = currentSubProfile['elder_medical_conditions'] ?? [];
    // map ค่า thai_name จากแต่ละโรค
    List<String> diseaseNames = diseasesList
        .map((disease) => disease['thai_name']?.toString() ?? 'ไม่ทราบชื่อโรค')
        .toList();
    String diseasesText = diseaseNames.isNotEmpty ? diseaseNames.join(', ') : "ไม่มี";

    return Scaffold(
      appBar: AppBar(
        title: Text('โปรไฟล์ผู้สูงอายุของ $name'),
        backgroundColor: const Color(0xFF4E614D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ชื่อ: $name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('อายุ: $age'),
            Text('เพศกำเนิด: $sex'),
            Text('เพศสภาพ: $gender'),
            Text('ส่วนสูง: $height ซม.'),
            Text('น้ำหนัก: $weight กิโลกรัม'),
            Text('ความถี่ในการออกกำลังกาย: $physicalActivity'),
            Text('ประเภทอาหารที่ทาน: $mealPreference'),
            Text('ความอยากอาการ: $appetiteLevel'),
            const SizedBox(height: 16),
            const Text(
              'รายละเอียดเพิ่มเติม:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('อาหารที่ชอบ: $favoriteFood'),
            Text('อาหารที่แพ้: $foodAllergies'),
            Text('ยาที่แพ้: $drugAllergies'),
            Text('ยาที่ทานปัจจุบัน: $medications'),
            Text('อื่นๆ: $otherConditions'),
            Text('บันทึกจากผู้ดูแล: $note'),
            const SizedBox(height: 16),
            Text(
              'โรคประจำตัว: $diseasesText',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _navigateToEdit,
                    child: const Text('แก้ไขโปรไฟล์'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _deleteProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      textStyle: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    child: const Text('ลบโปรไฟล์นี้', style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
