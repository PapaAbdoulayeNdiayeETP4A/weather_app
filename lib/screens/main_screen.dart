import 'dart:convert';
import 'dart:math';
import 'dart:async';
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

  double progress = 0.0;
  int step = 0;
  List<String> loadingMessages = [
    "Nous téléchargeons les données...",
    "C'est presque fini...",
    "Plus que quelques secondes avant d'avoir le résultat...",
    "Plus que quelques secondes avant d'avoir le résultat...",
  ];

  String currentMessage = "";

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

      for (int i = 0; i < cities.length; i++) {
        final city = cities[i];

        final result = await api.getWeatherByCity(
          city,
          'a815888716625f4d0475480e124cf089',
        );
        results.add(result);

        setState(() {
          forecasts = results;
          progress = (i + 1) / cities.length;
          currentMessage = loadingMessages[i % loadingMessages.length];
        });

        if (i < cities.length - 1) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      setState(() {
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

  String getWeatherIcon(String icon) {
    final baseUrl = 'https://openweathermap.org/img/wn/';
    return baseUrl + icon + '@2x.png';
  }

  Color getTemperatureColor(double tempC) {
    if (tempC < 0) {
      return Colors.blue.shade100;
    } else if (tempC < 10) {
      return Colors.lightBlue.shade50;
    } else if (tempC < 20) {
      return Colors.green.shade50;
    } else if (tempC < 30) {
      return Colors.orange.shade50;
    } else {
      return Colors.red.shade50;
    }
  }

  void navigateToDetails(WeatherResponse forecast) {
    // Navigation vers la page de détails
    //Navigator.push(
    //context,
    //MaterialPageRoute(
    //builder: (context) => WeatherDetailsScreen(forecast: forecast),
    //),
    //);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Prévisions météo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          isLoading
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blueAccent.shade100, Colors.white],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_download,
                            size: 50,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            currentMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : error != null
              ? Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Erreur : $error",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: fetchWeather,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: forecasts.length,
                  itemBuilder: (context, index) {
                    final forecast = forecasts[index];
                    final weather = forecast.weather[0];
                    final tempC = forecast.main.temp - 273.15;
                    final tempString = tempC.toStringAsFixed(1);
                    final desc = weather.description;
                    final icon = weather.icon;
                    final humidity = forecast.main.humidity;
                    final windSpeed = forecast.wind.speed.toStringAsFixed(1);

                    return GestureDetector(
                      onTap: () => navigateToDetails(forecast),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: getTemperatureColor(tempC),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Image.network(
                                  getWeatherIcon(icon),
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      forecast.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      desc,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.water_drop_outlined,
                                          size: 16,
                                          color: Colors.blue.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$humidity%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.air,
                                          size: 16,
                                          color: Colors.green.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$windSpeed m/s',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Température
                              Column(
                                children: [
                                  Text(
                                    '$tempString°',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'C',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              // Indicateur de clic
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
