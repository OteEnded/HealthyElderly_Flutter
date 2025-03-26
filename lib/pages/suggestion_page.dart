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
      ApiService(baseUrl: 'https://api.openweathermap.org/data/2.5');
  String _weatherInfo = '';
  String _weatherIcon = '';
  String _cityName = '';

  Future<void> _fetchWeather(String city) async {
    // สมมุติว่า dotenv.load() ถูกเรียกใน main.dart แล้ว
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _weatherInfo = 'API Key is missing!';
        _weatherIcon = '';
      });
      return;
    }
    try {
      final response = await apiService.get(
          '/weather?q=$city&units=metric&appid=$apiKey');
      final sunrise = DateTime.fromMillisecondsSinceEpoch(
          response['sys']['sunrise'] * 1000);
      final sunset = DateTime.fromMillisecondsSinceEpoch(
          response['sys']['sunset'] * 1000);
      setState(() {
        _cityName = response['name'];
        _weatherInfo = 'Temperature: ${response['main']['temp']}°C\n'
            'Min Temp: ${response['main']['temp_min']}°C\n'
            'Max Temp: ${response['main']['temp_max']}°C\n'
            'Weather: ${response['weather'][0]['description']}\n'
            'Humidity: ${response['main']['humidity']}%\n'
            'Wind Speed: ${response['wind']['speed']} m/s\n'
            'Sunrise: ${sunrise.hour}:${sunrise.minute}\n'
            'Sunset: ${sunset.hour}:${sunset.minute}';
        _weatherIcon = _getWeatherIcon(response['weather'][0]['main']);
      });
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error fetching weather data: $e';
        _weatherIcon = '';
      });
    }
  }

  String _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      case 'drizzle':
        return '🌦️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌈';
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
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter City Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _fetchWeather(_controller.text);
                }
              },
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 16),
            if (_cityName.isNotEmpty)
              Text(
                'Weather in $_cityName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (_weatherIcon.isNotEmpty)
              Text(
                _weatherIcon,
                style: const TextStyle(fontSize: 48),
              ),
            if (_weatherInfo.isNotEmpty)
              Text(
                _weatherInfo,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
