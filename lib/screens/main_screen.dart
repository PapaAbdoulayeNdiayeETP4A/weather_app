import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../models/weather_response.dart';
import '../services/weather_api.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<WeatherResponse> forecasts = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      final dio = Dio();
      final api = WeatherApi(dio);
      final cities = await getRandomCities();

      List<WeatherResponse> results = [];

      for (final city in cities) {
        final result = await api.getWeatherByCity(
            city, 'a815888716625f4d0475480e124cf089');
        results.add(result);
      }

      setState(() {
        forecasts = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<List<String>> getRandomCities() async {
    final jsonString = await rootBundle.loadString('assets/cities.json');
    final List<dynamic> allCities = json.decode(jsonString);
    allCities.shuffle(Random());
    return allCities.take(5).cast<String>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prévisions météo')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Erreur : $error"))
          : ListView.builder(
        itemCount: forecasts.length,
        itemBuilder: (context, index) {
          final forecast = forecasts[index];
          final weather = forecast.weather.isNotEmpty
              ? forecast.weather[0]
              : null;
          final tempC = (forecast.main.temp - 273.15).toStringAsFixed(1);
          final desc = weather?.description ?? "N/A";

          return ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(forecast.name),
            subtitle: Text("$tempC°C - $desc"),
          );
        },
      ),
    );
  }
}