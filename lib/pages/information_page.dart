import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  final Map<String, dynamic> subProfile;

  const InformationPage({super.key, required this.subProfile});

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลจาก subProfile
    String name = subProfile['name'] ?? 'Unknown';
    String height = subProfile['height'] != null ? subProfile['height'].toString() : 'N/A';
    String weight = subProfile['weight'] != null ? subProfile['weight'].toString() : 'N/A';
    String gender = subProfile['gender'] ?? 'N/A';
    // คุณสามารถเพิ่มข้อมูลอื่นๆ จาก subProfile ได้ตามต้องการ

    return Scaffold(
      appBar: AppBar(
        title: Text('Information - $name'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Height: $height cm',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Weight: $weight kg',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Gender: $gender',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Additional Information:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // เพิ่มข้อมูลเพิ่มเติมหรือ widget อื่นๆ ที่ต้องการแสดงข้อมูลของ sub profile ได้ที่นี่
          ],
        ),
      ),
    );
  }
}
