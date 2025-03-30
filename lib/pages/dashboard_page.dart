import 'package:flutter/material.dart';
import '../utils/api_service.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> subProfile;
  final String userId;

  const DashboardPage(
      {Key? key, required this.subProfile, required this.userId})
      : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _promptController = TextEditingController();
  bool _isPromptLoading = false;

  Future<void> _sendPrompt() async {
    final elderId = widget.subProfile['elder_id'];
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your prompt.")),
      );
      return;
    }
    setState(() {
      _isPromptLoading = true;
    });
    try {
      final ApiService apiService = ApiService(
        baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
      );
      final response = await apiService.post(
        '/api/elder/prompt',
        data: {
          'elder_id': elderId,
          'prompt': prompt,
        },
      );
      String resultMessage;
      if (response['isSuccess'] == true) {
        resultMessage = response['content'] ?? "Prompt sent successfully.";
      } else {
        resultMessage = response['message'] ?? "Failed to send prompt.";
      }
      // แสดงผลลัพธ์ใน popup dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("ข้อความให้คำปรึกษาจาก AI"),
            content: SingleChildScrollView(
              child: Text(resultMessage),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Error: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isPromptLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.subProfile['nickname'] ?? 'Unknown';
    String heightStr = widget.subProfile['height'] != null
        ? widget.subProfile['height'].toString()
        : 'N/A';
    String weightStr = widget.subProfile['weight'] != null
        ? widget.subProfile['weight'].toString()
        : 'N/A';
    String ageStr = widget.subProfile['age'] != null
        ? widget.subProfile['age'].toString()
        : 'N/A';
    String sex = widget.subProfile['sex']?.toString().toLowerCase() ?? 'male';

    // ตัวอย่างคำนวณ BMR (อาจปรับเปลี่ยนได้)
    double? weight = double.tryParse(weightStr);
    double? height = double.tryParse(heightStr);
    int? age = int.tryParse(ageStr);
    double multiplier = 1.2;
    double bmr = 0.0;
    if (weight != null && height != null && age != null) {
      if (sex == 'male') {
        bmr = (66 + (13.7 * weight) + (5 * height) - (6.8 * age)) * multiplier;
      } else {
        bmr =
            (665 + (9.6 * weight) + (1.8 * height) - (4.7 * age)) * multiplier;
      }
    }
    int bmrInt = bmr.round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFFECE9E1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome $name to your Dashboard!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E614D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ส่วนสูง: $heightStr cm   |   น้ำหนัก: $weightStr kg',
              style: const TextStyle(fontSize: 16, color: Color(0xFF4E614D)),
            ),
            const SizedBox(height: 16),
            Text(
              'แคลลอรี่ที่ควรทานต่อวัน: ${bmrInt > 0 ? '$bmrInt kcal' : 'N/A'}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF4E614D)),
            ),
            const SizedBox(height: 16),
            const Text(
              'สารอาหารโดยรวมที่ควรได้รับต่อวัน:',
              style: TextStyle(fontSize: 16, color: Color(0xFF4E614D)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant,
                          color: Color(0xFF4E614D)),
                      title: const Text('แคลลอรี่ที่ควรทานต่อวัน'),
                      subtitle: Text(bmrInt > 0 ? '$bmrInt kcal' : 'N/A'),
                    ),
                  ),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.local_dining,
                          color: Color(0xFF4E614D)),
                      title: const Text('โปรตีนที่ควรทานต่อวัน'),
                      subtitle: Text('$weightStr per day'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // พื้นที่สำหรับส่งข้อความ prompt
            const Text(
              'ข้อความให้คำปรึกษาจาก AI:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'เขียน ข้อความ ที่นี่...',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: _isPromptLoading ? null : _sendPrompt,
                child: _isPromptLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('ส่งข้อความ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
