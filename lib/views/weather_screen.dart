import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/weather_service.dart';
import '../services/location_helper.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final weatherService = WeatherService();
  final locationHelper = LocationHelper();
  WeatherData? currentWeather;
  List<WeatherData> forecast = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  bool showSearchBox = false;

  @override
  void initState() {
    super.initState();
    loadWeatherByLocation();
  }

  Future<void> loadWeatherByLocation() async {
    try {
      final pos = await locationHelper.getCurrentLocation();
      await loadWeather(pos.latitude, pos.longitude);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> loadWeather(double lat, double lon) async {
    setState(() => isLoading = true);
    try {
      final current = await weatherService.fetchCurrentWeather(lat, lon);
      final forecastData = await weatherService.fetchFiveDayForecast(lat, lon);
      setState(() {
        currentWeather = current;
        forecast = forecastData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading weather: $e');
    }
  }

  Icon getColorfulWeatherIcon(String iconCode) {
    if (iconCode.contains("01")) return const Icon(Icons.wb_sunny, color: Colors.orange, size: 40);
    if (iconCode.contains("02")) return const Icon(Icons.cloud_queue, color: Colors.amber, size: 40);
    if (iconCode.contains("03") || iconCode.contains("04")) return const Icon(Icons.cloud, color: Colors.blueGrey, size: 40);
    if (iconCode.contains("09") || iconCode.contains("10")) return const Icon(Icons.grain, color: Colors.blue, size: 40);
    if (iconCode.contains("11")) return const Icon(Icons.flash_on, color: Colors.deepPurple, size: 40);
    if (iconCode.contains("13")) return const Icon(Icons.nightlight_round, color: Colors.indigo, size: 40);
    return const Icon(Icons.wb_cloudy, color: Colors.grey, size: 40);
  }

  Widget buildForecastCard(WeatherData data) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(DateFormat('E').format(data.dateTime), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          getColorfulWeatherIcon(data.icon),
          const SizedBox(height: 6),
          Text("${data.temperature.toStringAsFixed(1)}°C", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(data.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TypeAheadField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Enter location name',
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        suggestionsCallback: (pattern) async => await weatherService.getCitySuggestions(pattern),
        itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
        onSuggestionSelected: (suggestion) async {
          final coords = await weatherService.getLatLonFromCity(suggestion);
          await loadWeather(coords['lat']!, coords['lon']!);
          setState(() {
            showSearchBox = false;
            _searchController.clear();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Weather Forecast", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => setState(() => showSearchBox = !showSearchBox),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (showSearchBox) buildSearchBox(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentWeather!.city, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(DateFormat('EEEE, MMM d • h:mm a').format(currentWeather!.dateTime),
                            style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            getColorfulWeatherIcon(currentWeather!.icon),
                            const SizedBox(width: 12),
                            Text("${currentWeather!.temperature.toStringAsFixed(1)}°C",
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("💧 Humidity: ${currentWeather!.humidity}%", style: const TextStyle(fontSize: 14)),
                            Text("💨 Wind: ${currentWeather!.windSpeed} km/h", style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("🌡️ Feels Like: ${currentWeather!.feelsLike.toStringAsFixed(1)}°C",
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Next 5 Days", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: forecast.map(buildForecastCard).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (forecast.isNotEmpty && forecast.first.description.toLowerCase().contains("rain"))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "⚠️ Heavy rainfall expected tomorrow. Prepare drainage.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            const SizedBox(width: 40),
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
