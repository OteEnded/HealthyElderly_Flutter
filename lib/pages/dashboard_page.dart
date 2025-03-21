import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Dashboard'),
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to your Dashboard!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E614D), // Primary color
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Here is an overview of your nutrition and health:',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFBCC8C8), // Accent color
              ),
            ),
            const SizedBox(height: 16),
            // Mockup Data
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.restaurant, color: Color(0xFF4E614D)),
                      title: const Text('Daily Calorie Intake'),
                      subtitle: const Text('1,800 kcal'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_dining, color: Color(0xFF4E614D)),
                      title: const Text('Recommended Protein'),
                      subtitle: const Text('50g per day'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.water_drop, color: Color(0xFF4E614D)),
                      title: const Text('Water Intake'),
                      subtitle: const Text('2 liters per day'),
                    ),
                  ),
                  Card(
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