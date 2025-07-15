class WeatherData {
  final String city;
  final double temperature;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime dateTime;
  final int humidity;
  final double feelsLike;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.dateTime,
    required this.humidity,
    required this.feelsLike,
  });
}
