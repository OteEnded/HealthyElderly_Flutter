import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'suggestion_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> subProfile;
  final String userId;

  const MainPage({
    Key? key,
    required this.subProfile,
    required this.userId,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // สร้างหน้า pages พร้อมส่งข้อมูล subProfile และ userId ไปด้วย
    _pages = [
      DashboardPage(subProfile: widget.subProfile, userId: widget.userId),
      SuggestionPage(subProfile: widget.subProfile, userId: widget.userId),
      ProfilePage(subProfile: widget.subProfile, userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // แสดงหน้าตาม index ที่เลือก
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Suggestion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
