import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService apiService = ApiService(baseUrl: 'https://api.openweathermap.org/data/2.5');
  String _weatherInfo = '';
  String _weatherIcon = '';
  String _cityName = '';

  Future<void> _fetchWeather(String city) async {
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY'];
    try {
      final response = await apiService.get('/weather?q=$city&units=metric&appid=$apiKey');
      final sunrise = DateTime.fromMillisecondsSinceEpoch(response['sys']['sunrise'] * 1000);
      final sunset = DateTime.fromMillisecondsSinceEpoch(response['sys']['sunset'] * 1000);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Suggestion'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
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