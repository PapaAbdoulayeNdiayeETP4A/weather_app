import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/weather_response.dart';
import '../services/weather_api.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  WeatherResponse? forecast;
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
      final result = await api.getWeatherByCity("Paris", "a815888716625f4d0475480e124cf089");

      setState(() {
        forecast = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prévision météo')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Erreur: $error"))
          : forecastWidget(),
    );
  }

  Widget forecastWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "📍 ${forecast!.name}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: forecast!.weather.length < 10 ? forecast!.weather.length : 10,
            itemBuilder: (context, index) {
              final item = forecast!.weather[index];
              //final date = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000);
             // final tempC = (item.main.temp - 273.15).toStringAsFixed(1);
              //final desc = item.weather.first.description;

              //return ListTile(
                //leading: Text("${date.hour}h"),
                //title: Text("$tempC°C - $desc"),
              //);
            },
          ),
        ),
      ],
    );
  }
}