import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = '10d373990de1178a89f48de590d7a004';

  Future<WeatherData> fetchCurrentWeather(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    return WeatherData(
      city: data['name'],
      temperature: (data['main']['temp'] as num).toDouble(),
      windSpeed: (data['wind']['speed'] as num).toDouble(),
      humidity: data['main']['humidity'],
      feelsLike: (data['main']['feels_like'] as num).toDouble(),
      description: data['weather'][0]['description'],
      icon: data['weather'][0]['icon'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000),
    );
  }

  Future<List<WeatherData>> fetchFiveDayForecast(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    final List<WeatherData> forecast = [];
    for (var i = 0; i < data['list'].length; i += 8) {
      final item = data['list'][i];
      forecast.add(WeatherData(
        city: data['city']['name'],
        temperature: (item['main']['temp'] as num).toDouble(),
        windSpeed: (item['wind']['speed'] as num).toDouble(),
        humidity: item['main']['humidity'],
        feelsLike: (item['main']['feels_like'] as num).toDouble(),
        description: item['weather'][0]['description'],
        icon: item['weather'][0]['icon'],
        dateTime: DateTime.parse(item['dt_txt']),
      ));
    }
    return forecast;
  }

  Future<List<String>> getCitySuggestions(String query) async {
    final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey';
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    return List<String>.from(data.map((item) => "${item['name']}, ${item['country']}"));
  }

  Future<Map<String, double>> getLatLonFromCity(String cityName) async {
    final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey';
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    if (data.isNotEmpty) {
      return {
        'lat': data[0]['lat'],
        'lon': data[0]['lon'],
      };
    } else {
      throw Exception('City not found');
    }
  }
}
