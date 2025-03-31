import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/api_service.dart';

class SuggestionPage extends StatefulWidget {
  final dynamic subProfile; // ข้อมูล sub profile (ถ้าต้องการ)
  final String userId;

  const SuggestionPage({
    Key? key,
    required this.subProfile,
    required this.userId,
  }) : super(key: key);

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final ApiService apiService = ApiService(
      baseUrl: 'https://secretly-big-lobster.ngrok-free.app'); // เปลี่ยน URL ให้ตรงกับ API ของคุณ
  List<dynamic> menuItems = [];
  bool isLoading = false;
  String errorMessage = '';

  // ดึงข้อมูลเมนูอาหารทั้งหมดจาก API
  Future<void> _fetchMenuItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await apiService.post(
        '/api/elder/food/recommendation',
        data: {'elder_id': widget.subProfile['elder_id']},
      );
      if (response['isSuccess'] == true) {
        setState(() {
          menuItems = response['content'] as List<dynamic>;
          print(menuItems);
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'เกิดข้อผิดพลาดในการโหลดเมนูอาหาร';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // สมมุติว่า dotenv.load() ถูกเรียกใน main.dart แล้ว
    _fetchMenuItems();
  }

  // ฟังก์ชันตรวจสอบและแสดงรูปจาก Base64 string หรือ URL
  Widget _buildMenuImage(String imageString) {
    if (imageString.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 50),
      );
    }
    // หากไม่ใช่ URL (ไม่ขึ้นต้นด้วย "http") ให้ถือว่าเป็น Base64 string
    if (!imageString.startsWith("http")) {
      try {
        final imageBytes = base64Decode(imageString);
        return Image.memory(imageBytes, fit: BoxFit.cover);
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 50),
        );
      }
    }
    // ถ้าเป็น URL ธรรมดา
    return Image.network(imageString, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แนะนำเมนูอาหาร'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // แสดง 2 คอลัมน์
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final menu = menuItems[index] as Map<String, dynamic>;
                    final menuName = menu['name'] ?? 'ไม่ทราบชื่อ';
                    final menuImage = menu['image'] ?? ''; 
                    return GestureDetector(
                      onTap: () {
                        // เมื่อกดแสดงรายละเอียดของเมนู ให้เรียก API รายละเอียดของเมนู
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuDetailPage(
                              menu: menu,
                              elderId: widget.subProfile['elder_id'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildMenuImage(menuImage),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                menuName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                menu['description'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// หน้าแสดงรายละเอียดเมนูอาหาร
class MenuDetailPage extends StatefulWidget {
  final Map<String, dynamic> menu;
  final String elderId;

  const MenuDetailPage({Key? key, required this.menu, required this.elderId}) : super(key: key);

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  bool isLoading = false;
  String errorMessage = '';
  Map<String, dynamic>? menuDetail;

  Future<void> _fetchMenuDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final ApiService apiService = ApiService(
        baseUrl: 'https://secretly-big-lobster.ngrok-free.app',
      );
      // ส่ง elderId และ food_name ไปยัง API endpoint
      final response = await apiService.post(
        '/api/elder/food/detail',
        data: {
          'elder_id': widget.elderId,
          'food': widget.menu['name'],
        },
      );
      if (response['isSuccess'] == true) {
        setState(() {
          menuDetail = response['content'] as Map<String, dynamic>;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'เกิดข้อผิดพลาดในการโหลดรายละเอียดเมนู';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ฟังก์ชันตรวจสอบและแสดงรูปจาก Base64 string หรือ URL สำหรับรายละเอียดเมนู
  Widget _buildMenuImage(String imageString) {
    if (imageString.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 50),
      );
    }
    // หากไม่ใช่ URL (ไม่ขึ้นต้นด้วย "http") ให้ถือว่าเป็น Base64 string
    if (!imageString.startsWith("http")) {
      try {
        final imageBytes = base64Decode(imageString);
        return Image.memory(imageBytes, fit: BoxFit.cover);
      } catch (e) {
        return Container(
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 50),
        );
      }
    }
    return Image.network(imageString, fit: BoxFit.cover);
  }

  @override
  void initState() {
    super.initState();
    _fetchMenuDetail();
  }

  @override
  Widget build(BuildContext context) {
    final menuName = widget.menu['name'] ?? 'ไม่ทราบชื่อ';
    final description = menuDetail != null
        ? menuDetail!['description'] ?? 'ไม่ทราบรายละเอียด'
        : 'Loading details...';
    // สมมุติว่า menuDetail มี key: name, nutrient, ingredients, image1, image2

    return Scaffold(
      appBar: AppBar(
        title: Text(menuName),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                 child: Column(
  crossAxisAlignment: CrossAxisAlignment.start, // จัดข้อความชิดซ้าย
  children: [
    // แถวสำหรับแสดงรูปภาพทั้งสองข้างกัน
    Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1, // กำหนดให้เป็นรูปสี่เหลี่ยม
            child: _buildMenuImage(menuDetail?['image1'] ?? ''),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: _buildMenuImage(menuDetail?['image2'] ?? ''),
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    // ข้อความรายละเอียด
    Text(
      'เมนู: ${menuDetail?['name'] ?? 'ไม่ทราบชื่อ'}',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.left,
    ),
    const SizedBox(height: 8),
    Text(
      'สารอาหาร: ${menuDetail?['nutrient'] ?? 'ไม่ทราบ'}',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.left,
    ),
    const SizedBox(height: 8),
    Text(
      'วัตถุดิบ: ${menuDetail?['ingredients'] ?? 'ไม่ทราบ'}',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.left,
    ),
    const SizedBox(height: 16),
    Text(
      'ทำไมเหมาะสม: ${menuDetail?['why_is_good'] ?? 'ไม่มีข้อมูล'}',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.left,
    ),
    const SizedBox(height: 16),
  ],
),
                ),
    );
  }
}
