import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SuggestionPage extends StatefulWidget {
  final dynamic subProfile;
  // หรือถ้าต้องการระบุ type ให้ชัดเจน: final Map<String, dynamic> subProfile;

  const SuggestionPage({super.key, required this.subProfile});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService apiService =
      ApiService(baseUrl: 'https://bad2-184-22-230-101.ngrok-free.app');
  String _response = '';
  String _test = 'false';
  

  Future<void> _fetchWeather(String city) async {
    // สมมุติว่า dotenv.load() ถูกเรียกใน main.dart แล้ว
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      
      return;
    }
    try {
      final response = await apiService.get('/api/Users/get/user_id/1', headers: {'api-key': 'I am the real admin',
       'ngrok-skip-browser-warning' : 'true'});
      setState(() {
        _response = response.toString();
        print(_response);
      });
    } catch (e) {
      print(e);
    }
  }

  

  @override
  Widget build(BuildContext context) {
    // ดึงชื่อ subProfile ที่ส่งเข้ามา
    String profileName = widget.subProfile != null &&
            widget.subProfile['name'] != null
        ? widget.subProfile['name'].toString()
        : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Suggestion for $profileName'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField(
            //   controller: _controller,
            //   decoration: const InputDecoration(
            //     labelText: 'Enter City Name',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            // const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (true) {
                  _fetchWeather(_controller.text);
                  setState(() {
                    _test = 'true';
                  });
                }
              },
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 16),Text('Response: $_test'),
            Text('Response: $_response'),
            // if (_cityName.isNotEmpty)
            //   Text(
            //     'Weather in $_cityName',
            //     style: const TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // if (_weatherIcon.isNotEmpty)
            //   Text(
            //     _weatherIcon,
            //     style: const TextStyle(fontSize: 48),
            //   ),
            // if (_weatherInfo.isNotEmpty)
            //   Text(
            //     _weatherInfo,
            //     style: const TextStyle(fontSize: 16),
            //     textAlign: TextAlign.center,
            //   ),
          ],
        ),
      ),
    );
  }
}
