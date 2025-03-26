import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> subProfile;

  const DashboardPage({super.key, required this.subProfile});

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลจาก subProfile
    String name = subProfile['name'] ?? 'Unknown';
    String heightStr = subProfile['height'] != null ? subProfile['height'].toString() : 'N/A';
    String weightStr = subProfile['weight'] != null ? subProfile['weight'].toString() : 'N/A';
    String ageStr = subProfile['age'] != null ? subProfile['age'].toString() : 'N/A';
    String sex = subProfile['sex']?.toString().toLowerCase() ?? 'male';
    String activityLevelStr = subProfile['physicalActivityLevel']?.toString().toLowerCase() ?? 'low';

    // แปลงค่าสำหรับการคำนวณ
    double? weight = double.tryParse(weightStr);
    double? height = double.tryParse(heightStr);
    int? age = int.tryParse(ageStr);

    // กำหนด multiplier ตาม activity level
    double multiplier = 1.2;
    if (activityLevelStr == 'moderate') {
      multiplier = 1.55;
    } else if (activityLevelStr == 'high') {
      multiplier = 1.9;
    }

    double bmr = 0.0;
    if (weight != null && height != null && age != null) {
      if (sex == 'male') {
        bmr = (66 + (13.7 * weight) + (5 * height) - (6.8 * age)) * multiplier;
      } else if (sex == 'female') {
        bmr = (665 + (9.6 * weight) + (1.8 * height) - (4.7 * age)) * multiplier;
      }
    }
    int bmrInt = bmr.round();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - $name'),
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
              'Height: $heightStr cm   |   Weight: $weightStr kg',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4E614D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Daily Calorie Intake: ${bmrInt > 0 ? '$bmrInt kcal' : 'N/A'}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4E614D),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Here is an overview of your nutrition and health:',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4E614D),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, color: Color(0xFF4E614D)),
                      title: const Text('Daily Calorie Intake'),
                      subtitle: Text(
                        bmrInt > 0 ? '$bmrInt kcal' : 'N/A',
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.local_dining, color: Color(0xFF4E614D)),
                      title: const Text('Recommended Protein'),
                      subtitle: Text('$weightStr per day'),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.water_drop, color: Color(0xFF4E614D)),
                      title: const Text('Water Intake'),
                      subtitle: const Text('2 liters per day'),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.directions_walk, color: Color(0xFF4E614D)),
                      title: const Text('Daily Steps'),
                      subtitle: const Text('5,000 steps'),
                    ),
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
